import 'package:flutter/material.dart';

/// Home screen app bar with logo, weather, and menu
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final String? temperature;

  const HomeAppBar({
    super.key,
    this.onMenuTap,
    this.temperature,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          const Text(
            'Itinera',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          if (temperature != null) ...[
            Icon(
              Icons.wb_sunny_outlined,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              temperature!,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
      actions: [
        GestureDetector(
          onTap: onMenuTap,
          child: Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 20,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

/// Detail screen app bar with back button and title
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const DetailAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.actions,
    this.onBack,
    this.showBackButton = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final fgColor = foregroundColor ?? Colors.black87;

    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back, color: fgColor),
            )
          : null,
      title: title != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: fgColor,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: fgColor.withOpacity(0.7),
                    ),
                  ),
              ],
            )
          : null,
      actions: actions,
    );
  }
}

/// Trip screen app bar with location, date, and status
class TripAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String location;
  final String? dateRange;
  final String? status;
  final Color? statusColor;
  final VoidCallback? onBack;
  final VoidCallback? onMore;

  const TripAppBar({
    super.key,
    required this.location,
    this.dateRange,
    this.status,
    this.statusColor,
    this.onBack,
    this.onMore,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: onBack ?? () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
      ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (dateRange != null)
                  Text(
                    dateRange!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          if (status != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (statusColor ?? Colors.green).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status!,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: statusColor ?? Colors.green.shade700,
                ),
              ),
            ),
        ],
      ),
      actions: [
        if (onMore != null)
          IconButton(
            onPressed: onMore,
            icon: const Icon(Icons.more_horiz, color: Colors.black87),
          ),
      ],
    );
  }
}
