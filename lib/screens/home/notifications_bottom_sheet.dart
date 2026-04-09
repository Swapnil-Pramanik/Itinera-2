import 'package:flutter/material.dart';
import 'dart:ui';

/// Notifications Bottom Sheet - Modal to display alerts and suggestions
class NotificationsBottomSheet extends StatelessWidget {
  const NotificationsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'NOTIFICATIONS',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Clear all',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Notification List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildNotificationItem(
                  context,
                  type: _NotificationType.alert,
                  title: 'BUDGET ALERT',
                  message: 'Your Florence trip exceeds target budget by ₹12,400. Optimization suggested.',
                  time: '2 hours ago',
                  actionLabel: 'Adjust Budget',
                ),
                _buildNotificationItem(
                  context,
                  type: _NotificationType.weather,
                  title: 'WEATHER UPDATE',
                  message: 'Heavy rain forecast for London tomorrow. Don\'t forget your umbrella!',
                  time: '5 hours ago',
                  actionLabel: 'View Checklist',
                ),
                _buildNotificationItem(
                  context,
                  type: _NotificationType.suggestion,
                  title: 'SMART SUGGESTION',
                  message: '✨ Found 3 cheaper transport options for your Kyoto trip next month.',
                  time: '1 day ago',
                  actionLabel: 'View Details',
                ),
                _buildNotificationItem(
                  context,
                  type: _NotificationType.info,
                  title: 'TRIP READY',
                  message: 'Your custom itinerary for Tokyo is fully generated and ready!',
                  time: '2 days ago',
                  actionLabel: 'Open Itinerary',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required _NotificationType type,
    required String title,
    required String message,
    required String time,
    String? actionLabel,
  }) {
    Color iconColor;
    IconData iconData;
    Color bgColor;

    switch (type) {
      case _NotificationType.alert:
        iconColor = const Color(0xFFFF5252);
        iconData = Icons.warning_amber_rounded;
        bgColor = const Color(0xFFFF5252).withOpacity(0.1);
        break;
      case _NotificationType.suggestion:
        iconColor = const Color(0xFFFFB300);
        iconData = Icons.lightbulb_outline_rounded;
        bgColor = const Color(0xFFFFB300).withOpacity(0.1);
        break;
      case _NotificationType.weather:
        iconColor = const Color(0xFF40C4FF);
        iconData = Icons.wb_sunny_outlined;
        bgColor = const Color(0xFF40C4FF).withOpacity(0.1);
        break;
      case _NotificationType.info:
        iconColor = const Color(0xFF4CAF50);
        iconData = Icons.check_circle_outline_rounded;
        bgColor = const Color(0xFF4CAF50).withOpacity(0.1);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconData, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: iconColor,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _NotificationType { alert, suggestion, weather, info }
