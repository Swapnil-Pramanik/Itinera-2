import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';

/// Service for fetching trip data from the backend or Supabase directly.
class TripService {
  static const String _backendUrl = AppConstants.backendUrl;

  /// Fetches the current user's trips.
  /// Tries the FastAPI backend first; falls back to direct Supabase query.
  static Future<List<Map<String, dynamic>>> getMyTrips() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return [];

    // Try backend first
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/trips/me'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (_) {
      // Backend unavailable — fall back to direct Supabase query
    }

    // Fallback: query Supabase directly
    try {
      final userId = session.user.id;
      final response = await Supabase.instance.client
          .from('trips')
          .select('*, destinations(name, country, tags, image_url)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }
}
