import 'package:intl/intl.dart';

enum NotificationType { alert, suggestion, weather, info }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? actionLabel;
  final String? actionRoute;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionRoute,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: _parseType(json['type']),
      title: json['title'],
      message: json['message'],
      actionLabel: json['action_label'],
      actionRoute: json['action_route'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static NotificationType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'alert':
        return NotificationType.alert;
      case 'suggestion':
        return NotificationType.suggestion;
      case 'weather':
        return NotificationType.weather;
      case 'info':
      default:
        return NotificationType.info;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
