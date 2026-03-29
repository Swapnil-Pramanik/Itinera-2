import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'weather_theme.dart';
import 'weather_animations.dart';

class WeatherPopup extends StatelessWidget {
  final String locationName;
  final Map<String, dynamic> weatherData;
  final String heroTag;

  const WeatherPopup({
    super.key,
    required this.locationName,
    required this.weatherData,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final current = weatherData['current'];
    final hourly = weatherData['hourly'];
    final now = DateTime.now();
    final theme = WeatherThemeMapper.getTheme(current?['weather_code']);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Hero(
            tag: heroTag,
            child: Material(
              color: Colors.transparent,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  constraints: const BoxConstraints(minHeight: 260),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: theme.cardGradient,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Animation Layer
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: WeatherAnimationBackground(type: theme.type),
                        ),
                      ),

                      // Content Layer
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            // Left Section
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _parseWeatherCode(current?['weather_code']),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${current?['temperature_2m']?.round() ?? '--'}°',
                                    style: const TextStyle(
                                      fontSize: 64,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                      height: 1.0,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('EEEE').format(now),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd.MM.yyyy').format(now),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.air, size: 24, color: Colors.white70),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          '${current?['wind_speed_10m'] ?? '--'}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Right Section (Hourly)
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    locationName.toLowerCase(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: _buildHourlyList(hourly),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyList(Map<String, dynamic>? hourly) {
    if (hourly == null) return const SizedBox();

    final times = hourly['time'] as List<dynamic>?;
    final temps = hourly['temperature_2m'] as List<dynamic>?;
    final codes = hourly['weather_code'] as List<dynamic>?;
    final windSpeeds = hourly['wind_speed_10m'] as List<dynamic>?;
    final windDirs = hourly['wind_direction_10m'] as List<dynamic>?;

    if (times == null) return const SizedBox();

    final currentHour = DateTime.now().hour;
    final startIndex = times.indexWhere((t) {
      final dt = DateTime.parse(t.toString());
      return dt.hour >= currentHour && dt.day == DateTime.now().day;
    });

    if (startIndex == -1) return const SizedBox();

    final List<Widget> items = [];
    for (int i = 0; i < 5; i++) {
      final index = startIndex + i;
      if (index >= times.length) break;

      final dt = DateTime.parse(times[index].toString());
      final isNow = i == 0;

      items.add(
        _HourlyItem(
          time: isNow ? 'Now' : DateFormat('h a').format(dt),
          temp: temps?[index]?.round() ?? 0,
          code: codes?[index],
          windSpeed: windSpeeds?[index]?.toString() ?? '--',
          windDir: windDirs?[index] ?? 0,
          isHighlighted: isNow,
        ),
      );
    }

    return ListView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      children: items,
    );
  }

  String _parseWeatherCode(dynamic code) {
    if (code == null) return 'Unknown';
    final intCode = code is int ? code : int.tryParse(code.toString()) ?? -1;
    if (intCode == 0) return 'Clear';
    if (intCode >= 1 && intCode <= 3) return 'Cloudy';
    if (intCode == 45 || intCode == 48) return 'Fog';
    if (intCode >= 51 && intCode <= 57) return 'Drizzle';
    if (intCode >= 61 && intCode <= 67) return 'Rain';
    if (intCode >= 71 && intCode <= 77) return 'Snow';
    if (intCode >= 80 && intCode <= 82) return 'Showers';
    if (intCode >= 95) return 'Storm';
    return 'Clear';
  }
}

class _HourlyItem extends StatelessWidget {
  final String time;
  final int temp;
  final dynamic code;
  final String windSpeed;
  final dynamic windDir;
  final bool isHighlighted;

  const _HourlyItem({
    required this.time,
    required this.temp,
    this.code,
    required this.windSpeed,
    this.windDir,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: isHighlighted
          ? BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
              color: Colors.white,
            ),
          ),
          Icon(
            _getWeatherIcon(code),
            size: 24,
            color: Colors.white,
          ),
          Text(
            '$temp°',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Transform.rotate(
            angle: (windDir ?? 0) * (3.14159 / 180),
            child: const Icon(
              Icons.navigation,
              size: 14,
              color: Colors.white70,
            ),
          ),
          Text(
            windSpeed,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(dynamic code) {
    final intCode = code is int ? code : int.tryParse(code?.toString() ?? '') ?? -1;
    if (intCode == 0) return Icons.wb_sunny;
    if (intCode >= 1 && intCode <= 3) return Icons.cloud;
    if (intCode == 45 || intCode == 48) return Icons.cloud_queue;
    if (intCode >= 51 && intCode <= 57) return Icons.water_drop;
    if (intCode >= 61 && intCode <= 67) return Icons.umbrella;
    if (intCode >= 71 && intCode <= 77) return Icons.ac_unit;
    if (intCode >= 80 && intCode <= 82) return Icons.beach_access;
    if (intCode >= 95) return Icons.thunderstorm;
    return Icons.wb_cloudy;
  }
}
