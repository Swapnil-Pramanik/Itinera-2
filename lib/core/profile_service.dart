import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for fetching and updating user profile data from the backend or Supabase.
class ProfileService {
  static const String _backendUrl = 'http://localhost:8000';

  /// Fetches the current user's profile data from the `users` table.
  static Future<Map<String, dynamic>?> getMyProfile() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;

    // Try backend first
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/users/me'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Fallback
    }

    // Fallback: query Supabase directly
    try {
      final userId = session.user.id;
      final response = await Supabase.instance.client
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();
      
      return response;
    } catch (_) {
      return null;
    }
  }

  /// Updates the current user's profile data.
  static Future<bool> updateProfile({String? displayName, String? avatarUrl}) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return false;

    try {
      final body = {};
      if (displayName != null) body['display_name'] = displayName;
      if (avatarUrl != null) body['avatar_url'] = avatarUrl;

      final response = await http.post(
        Uri.parse('$_backendUrl/api/users/me'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) return true;
    } catch (_) {
      // Fallback
    }

    // Fallback: update Supabase directly
    try {
      final userId = session.user.id;
      final data = <String, dynamic>{};
      if (displayName != null) data['display_name'] = displayName;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      
      await Supabase.instance.client
          .from('users')
          .update(data)
          .eq('id', userId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
