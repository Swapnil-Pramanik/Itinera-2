import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';
import '../models/notification_model.dart';

/// Service for interacting with the notifications API.
class NotificationService {
  static const String _backendUrl = AppConstants.backendUrl;

  /// Fetches all notifications for the current user.
  static Future<List<NotificationModel>> getNotifications() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/notifications'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => NotificationModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('[NotificationService] getNotifications error: $e');
    }
    return [];
  }

  /// Marks a specific notification as read.
  static Future<bool> markAsRead(String notificationId) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('[NotificationService] markAsRead error: $e');
      return false;
    }
  }

  /// Clears all notifications for the current user.
  static Future<bool> clearAll() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$_backendUrl/api/notifications/clear'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('[NotificationService] clearAll error: $e');
      return false;
    }
  }

  /// Fetches the count of unread notifications.
  static Future<int> getUnreadCount() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return 0;

    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/notifications/unread-count'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      }
    } catch (e) {
      print('[NotificationService] getUnreadCount error: $e');
    }
    return 0;
  }
}
