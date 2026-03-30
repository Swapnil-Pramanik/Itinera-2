import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';

/// Service for searching destinations and fetching details from the backend.
class DestinationService {
  static const String _backendUrl = AppConstants.backendUrl;

  /// Search destinations — backend (Nominatim + DB cache) first, Supabase fallback.
  static Future<List<Map<String, dynamic>>> searchDestinations(String query) async {
    if (query.trim().length < 2) return [];

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return [];

    // Try backend
    try {
      final url = '$_backendUrl/api/destinations/search?q=${Uri.encodeComponent(query)}';
      debugPrint('[DestinationService] Searching backend: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      debugPrint('[DestinationService] Backend response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('[DestinationService] Got ${data.length} results from backend');
        return data.cast<Map<String, dynamic>>();
      } else {
        debugPrint('[DestinationService] Backend error body: ${response.body}');
      }
    } catch (e) {
      debugPrint('[DestinationService] Backend search error: $e');
    }

    // Fallback: search destinations table directly
    debugPrint('[DestinationService] Falling back to direct Supabase search');
    try {
      final response = await Supabase.instance.client
          .from('destinations')
          .select('id, name, country, description, rating, image_url, tags, latitude, longitude')
          .ilike('name', '%$query%')
          .limit(10);
      debugPrint('[DestinationService] Supabase fallback got ${response.length} results');
      
      final results = List<Map<String, dynamic>>.from(response);
      
      // Link the best match to search history
      if (results.isNotEmpty) {
        try {
          final userId = session.user.id;
          await Supabase.instance.client.from('search_history').insert({
            'user_id': userId,
            'query': query,
            'destination_id': results.first['id'],
          });
        } catch (_) {}
      }
      
      return results;
    } catch (e) {
      debugPrint('[DestinationService] Supabase fallback error: $e');
      return [];
    }
  }

  /// Get destination details by name+country — backend creates/caches via Wikipedia if needed.
  static Future<Map<String, dynamic>?> getDestinationByName(
    String name,
    String country, {
    double? lat,
    double? lon,
  }) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;

    // Try backend
    try {
      var url = '$_backendUrl/api/destinations/detail-by-name'
          '?name=${Uri.encodeComponent(name)}'
          '&country=${Uri.encodeComponent(country)}';

      if (lat != null && lon != null) {
        url += '&lat=$lat&lon=$lon';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Backend unavailable
    }

    // Fallback: direct Supabase query
    try {
      final response = await Supabase.instance.client
          .from('destinations')
          .select('*, attractions(*)')
          .ilike('name', name)
          .ilike('country', country)
          .limit(1);
      if (response.isNotEmpty) {
        return response.first;
      }
    } catch (_) {}

    return null;
  }

  /// Get destination details by ID.
  static Future<Map<String, dynamic>?> getDestinationById(String id) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;

    // Try backend
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/destinations/$id'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}

    // Fallback
    try {
      final response = await Supabase.instance.client
          .from('destinations')
          .select('*, attractions(*)')
          .eq('id', id)
          .single();
      return response;
    } catch (_) {
      return null;
    }
  }

  /// Get weather by destination ID.
  static Future<Map<String, dynamic>?> getDestinationWeather(String id) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;

    try {
      final url = '$_backendUrl/api/destinations/$id/weather';
      debugPrint('[DestinationService] Fetching weather from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('[DestinationService] Failed to fetch weather: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[DestinationService] Error fetching weather: $e');
    }
    return null;
  }

  /// Fetch atlas articles for home screen.
  static Future<List<Map<String, dynamic>>> getAtlasArticles() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return [];

    // Try backend
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/destinations/atlas/articles'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (_) {}

    // Fallback: direct Supabase query
    try {
      final response = await Supabase.instance.client
          .from('atlas_articles')
          .select('*, destinations(id, name, country)')
          .order('created_at', ascending: false)
          .limit(10);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }

  /// Fetch recent search queries for the current user.
  static Future<List<String>> getRecentSearches() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return [];

    // Try backend
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/destinations/search/recent'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item['query']?.toString() ?? '').where((q) => q.isNotEmpty).toList();
      }
    } catch (_) {}

    // Fallback
    try {
      final userId = session.user.id;
      final response = await Supabase.instance.client
          .from('search_history')
          .select('query')
          .eq('user_id', userId)
          .order('searched_at', ascending: false)
          .limit(5);
      final seen = <String>{};
      return (response as List)
          .map((item) => item['query']?.toString() ?? '')
          .where((q) => q.isNotEmpty && seen.add(q.toLowerCase()))
          .toList();
    } catch (_) {
      return [];
    }
  }
  /// Fetch the actual recent destinations that were fetched and cached in the DB for THIS user.
  static Future<List<Map<String, dynamic>>> getRecentDestinations() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return [];

    // Try backend history endpoint
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/destinations/history?limit=5'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (_) {}

    // Fallback: direct Supabase join via search_history
    try {
      final userId = session.user.id;
      final response = await Supabase.instance.client
          .from('search_history')
          .select('searched_at, destinations!inner(*)')
          .eq('user_id', userId)
          .order('searched_at', ascending: false)
          .limit(5);

      final List<Map<String, dynamic>> results = [];
      final seenIds = <String>{};

      for (var item in response) {
        final dest = item['destinations'] as Map<String, dynamic>?;
        if (dest != null && seenIds.add(dest['id'])) {
          results.add(dest);
        }
      }
      return results;
    } catch (e) {
      debugPrint('DestinationService.getRecentDestinations Fallback Error: $e');
      return [];
    }
  }

  /// Fetch a larger history of all stored destinations for THIS user.
  static Future<List<Map<String, dynamic>>> getAllDestinations() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return [];

    // Try backend history endpoint
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/destinations/history?limit=50'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (_) {}

    // Fallback: direct Supabase join via search_history
    try {
      final userId = session.user.id;
      final response = await Supabase.instance.client
          .from('search_history')
          .select('searched_at, destinations!inner(*)')
          .eq('user_id', userId)
          .order('searched_at', ascending: false)
          .limit(50);

      final List<Map<String, dynamic>> results = [];
      final seenIds = <String>{};

      for (var item in response) {
        final dest = item['destinations'] as Map<String, dynamic>?;
        if (dest != null && seenIds.add(dest['id'])) {
          results.add(dest);
        }
      }
      return results;
    } catch (e) {
      debugPrint('DestinationService.getAllDestinations Error: $e');
      return [];
    }
  }
}
