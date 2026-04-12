import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class LocationService {
  /// Fetches the user's approximate location based on their IP address using ip-api.com.
  /// Returns a map containing 'city', 'country', 'lat', and 'lon'.
  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json/'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return {
            'city': data['city'],
            'country': data['country'],
            'lat': data['lat']?.toDouble(),
            'lon': data['lon']?.toDouble(),
          };
        }
      }
    } catch (e) {
      debugPrint('[LocationService] Error fetching IP location: $e');
    }
    return null;
  }
}
