import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';

/// Service for fetching trip budget breakdown from the backend.
class BudgetService {
  static const String _backendUrl = AppConstants.backendUrl;

  /// Fetches the AI-powered budget breakdown for a specific trip.
  static Future<Map<String, dynamic>?> getTripBudget(String tripId) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/trips/$tripId/budget'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 300));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
        return null;
      } else {
        print('[BudgetService] getTripBudget failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('[BudgetService] getTripBudget error: $e');
    }
    return null;
  }
}
