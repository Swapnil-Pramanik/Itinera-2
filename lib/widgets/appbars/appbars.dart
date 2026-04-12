import 'package:flutter/material.dart';
import '../overlays/weather_popup.dart';
import '../overlays/weather_theme.dart';

/// Home screen app bar with logo, weather, and menu
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationsTap;
  final Map<String, dynamic>? weatherData;
  final String? locationName;
  final bool hasNotifications;

  const HomeAppBar({
    super.key,
    this.onMenuTap,
    this.onNotificationsTap,
    this.weatherData,
    this.locationName,
    this.hasNotifications = false,
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
          Image.asset(
            'assets/images/logo_black.png',
            height: 24,
          ),
          const SizedBox(width: 8),
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
          if (weatherData != null && locationName != null)
            _buildWeatherChip(context),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: onNotificationsTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_outlined,
                  size: 20,
                  color: Colors.black87,
                ),
                if (hasNotifications)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5252),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
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

  Widget _buildWeatherChip(BuildContext context) {
    final current = weatherData!['current'];
    final code = current?['weather_code'];
    final temp = current?['temperature_2m']?.round()?.toString() ?? '--';
    
    final theme = WeatherThemeMapper.getTheme(code);
    
    String label = '$temp°';
    
    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.cardGradient.last.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(theme.icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    final heroTag = 'home-weather-hero';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            transitionDuration: const Duration(milliseconds: 700),
            reverseTransitionDuration: const Duration(milliseconds: 250),
            pageBuilder: (context, animation, secondaryAnimation) => WeatherPopup(
              locationName: locationName!,
              weatherData: weatherData!,
              heroTag: heroTag,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: animation.status == AnimationStatus.forward
                      ? Curves.easeOutBack
                      : Curves.easeInBack,
                ),
                child: child,
              );
            },
          ),
        );
      },
      child: Hero(
        tag: heroTag,
        placeholderBuilder: (context, size, widget) => widget,
        flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
          return toHeroContext.widget;
        },
        child: Material(color: Colors.transparent, child: chip),
      ),
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
