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

  /// Creates a new trip record via the backend.
  static Future<Map<String, dynamic>?> createTrip({
    required String destinationId,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    String? notes,
  }) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/trips/'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'destination_id': destinationId,
          'title': title,
          'start_date': startDate?.toIso8601String().split('T')[0],
          'end_date': endDate?.toIso8601String().split('T')[0],
          'tags': tags ?? [],
          'notes': notes,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('[TripService] createTrip failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('[TripService] createTrip error: $e');
    }
    return null;
  }

  /// Deletes a trip record by its ID.
  static Future<bool> deleteTrip(String tripId) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$_backendUrl/api/trips/$tripId'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 204;
    } catch (e) {
      print('[TripService] deleteTrip error: $e');
      return false;
    }
  }

  /// Updates an existing trip (e.g., to finalize status).
  static Future<Map<String, dynamic>?> updateTrip(
    String tripId, {
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    String? notes,
    String? status,
  }) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;

    try {
      final response = await http.put(
        Uri.parse('$_backendUrl/api/trips/$tripId'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (title != null) 'title': title,
          if (startDate != null) 'start_date': startDate.toIso8601String().split('T')[0],
          if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
          if (tags != null) 'tags': tags,
          if (notes != null) 'notes': notes,
          if (status != null) 'status': status,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('[TripService] updateTrip error: $e');
    }
    return null;
  }

  /// Triggers the AI itinerary generation for a specific trip.
  static Future<bool> generateItinerary(String tripId) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/trips/$tripId/generate'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(minutes: 2)); // Increased timeout for AI generation

      return response.statusCode == 200;
    } catch (e) {
      print('[TripService] generateItinerary error: $e');
      return false;
    }
  }

  /// Fetches the day-by-day itinerary for a trip.
  static Future<List<Map<String, dynamic>>> getTripDays(String tripId) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/trips/$tripId/itinerary'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('[TripService] getTripDays error: $e');
    }
    return [];
  }
}
