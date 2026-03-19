import 'package:supabase_flutter/supabase_flutter.dart';

/// Lightweight service to access current user profile data from the Supabase session.
class UserService {
  static User? get _currentUser => Supabase.instance.client.auth.currentUser;

  /// Returns the display name from user metadata, falling back to email prefix or 'Traveler'.
  static String getDisplayName() {
    final user = _currentUser;
    if (user == null) return 'Traveler';

    // Check user_metadata for display_name (set during signup)
    final metadata = user.userMetadata;
    if (metadata != null && metadata['display_name'] != null) {
      final name = metadata['display_name'].toString().trim();
      if (name.isNotEmpty) return name;
    }

    // Fallback to email prefix
    final email = user.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Traveler';
  }

  /// Returns the current user's email or empty string.
  static String getEmail() {
    return _currentUser?.email ?? '';
  }

  /// Returns a time-of-day based greeting.
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}
