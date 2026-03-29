import 'package:flutter/material.dart';

enum WeatherType { sunny, cloudy, rainy, foggy, snowy, stormy }

class WeatherThemeConfig {
  final WeatherType type;
  final List<Color> cardGradient;
  final Color buttonBg;
  final Color accentColor;
  final IconData icon;

  const WeatherThemeConfig({
    required this.type,
    required this.cardGradient,
    required this.buttonBg,
    required this.accentColor,
    required this.icon,
  });
}

class WeatherThemeMapper {
  static WeatherThemeConfig getTheme(dynamic code) {
    final int codeInt = (code is int) ? code : int.tryParse(code.toString()) ?? 0;

    // Open-Meteo Weather Codes
    if (codeInt == 0) return _sunny; // Clear sky
    if (codeInt >= 1 && codeInt <= 3) return _cloudy; // Mainly clear, partly cloudy, overcast
    if (codeInt == 45 || codeInt == 48) return _foggy; // Fog, rime fog
    if (codeInt >= 51 && codeInt <= 67) return _rainy; // Drizzle, rain
    if (codeInt >= 71 && codeInt <= 77) return _snowy; // Snow
    if (codeInt >= 80 && codeInt <= 82) return _rainy; // Showers
    if (codeInt >= 95) return _stormy; // Thunderstorm

    return _sunny;
  }

  static final _sunny = WeatherThemeConfig(
    type: WeatherType.sunny,
    cardGradient: [const Color(0xFF4FA7F9), const Color(0xFF1F5AF4)],
    buttonBg: Colors.amber.withOpacity(0.2),
    accentColor: Colors.amber.shade200,
    icon: Icons.wb_sunny_rounded,
  );

  static final _cloudy = WeatherThemeConfig(
    type: WeatherType.cloudy,
    cardGradient: [const Color(0xFF7E8EA1), const Color(0xFF4A5568)],
    buttonBg: Colors.blueGrey.withOpacity(0.2),
    accentColor: Colors.blueGrey.shade100,
    icon: Icons.wb_cloudy_rounded,
  );

  static final _fogggy = WeatherThemeConfig(
    type: WeatherType.foggy,
    cardGradient: [const Color(0xFFADB5BD), const Color(0xFF6C757D)],
    buttonBg: Colors.grey.withOpacity(0.2),
    accentColor: Colors.grey.shade300,
    icon: Icons.foggy,
  );

  static final _rainy = WeatherThemeConfig(
    type: WeatherType.rainy,
    cardGradient: [const Color(0xFF335C67), const Color(0xFF0F2027)],
    buttonBg: Colors.cyan.withOpacity(0.2),
    accentColor: Colors.cyan.shade200,
    icon: Icons.umbrella_rounded,
  );

  static final _snowy = WeatherThemeConfig(
    type: WeatherType.snowy,
    cardGradient: [const Color(0xFFE9ECEF), const Color(0xFFADB5BD)],
    buttonBg: Colors.lightBlue.withOpacity(0.1),
    accentColor: Colors.white,
    icon: Icons.ac_unit_rounded,
  );

  static final _stormy = WeatherThemeConfig(
    type: WeatherType.stormy,
    cardGradient: [const Color(0xFF1A1A1D), const Color(0xFF4E4E50)],
    buttonBg: Colors.deepPurple.withOpacity(0.2),
    accentColor: Colors.deepPurple.shade100,
    icon: Icons.bolt_rounded,
  );

  // Fallback
  static final _foggy = _fogggy;
}
