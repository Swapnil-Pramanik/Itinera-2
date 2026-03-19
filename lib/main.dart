import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants.dart';
import 'theme/material3_theme.dart';
import 'screens/auth/login_signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

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
