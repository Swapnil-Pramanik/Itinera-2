import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';

/// Service for fetching and updating user preferences from the backend.
class PreferenceService {
  static const String _backendUrl = AppConstants.backendUrl;

  /// Fetches all preferences for the current user.
  static Future<Map<String, List<String>>> getPreferences() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return {};

    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/users/me/preferences'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data.map((key, value) => MapEntry(key, List<String>.from(value)));
      }
    } catch (e) {
      // Fallback or log error
      print('Error fetching preferences: $e');
    }

    // Fallback: Query Supabase directly if backend fails
    try {
      final userId = session.user.id;
      final response = await Supabase.instance.client
          .from('user_preferences')
          .select('preference_key, preference_value')
          .eq('user_id', userId);

      final Map<String, List<String>> prefs = {};
      for (var item in response) {
        final key = item['preference_key'] as String;
        final val = item['preference_value'] as String;
        prefs.putIfAbsent(key, () => []).add(val);
      }
      return prefs;
    } catch (e) {
      print('Fallback error fetching preferences: $e');
      return {};
    }
  }

  /// Saves preferences for a specific key (e.g., 'INTERESTS').
  static Future<bool> savePreferences(String key, List<String> values) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/users/me/preferences'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({key: values}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) return true;
    } catch (e) {
      print('Error saving preferences: $e');
    }

    // Fallback: update Supabase directly
    try {
      final userId = session.user.id;
      
      // Delete existing
      await Supabase.instance.client
          .from('user_preferences')
          .delete()
          .eq('user_id', userId)
          .eq('preference_key', key);
          
      // Insert new
      if (values.isNotEmpty) {
        final rows = values.map((val) => {
          'user_id': userId,
          'preference_key': key,
          'preference_value': val,
        }).toList();
        
        await Supabase.instance.client.from('user_preferences').insert(rows);
      }
      return true;
    } catch (e) {
      print('Fallback error saving preferences: $e');
      return false;
    }
  }

  /// Saves multiple preference sets at once.
  static Future<bool> saveMultiplePreferences(Map<String, List<String>> prefs) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/users/me/preferences'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(prefs),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) return true;
    } catch (e) {
      print('Error saving multiple preferences: $e');
    }

    // Fallback: series of updates to Supabase
    bool allSuccess = true;
    for (var entry in prefs.entries) {
      final success = await savePreferences(entry.key, entry.value);
      if (!success) allSuccess = false;
    }
    return allSuccess;
  }
}
