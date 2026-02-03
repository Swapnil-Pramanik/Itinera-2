import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/material3_theme.dart';
import 'screens/auth/login_signup_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ItineraApp());
}

class ItineraApp extends StatelessWidget {
  const ItineraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Itinera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginSignupScreen(),
    );
  }
}
