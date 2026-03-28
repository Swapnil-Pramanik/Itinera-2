import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/user_service.dart';
import '../../core/profile_service.dart';
import '../auth/login_signup_screen.dart';
import '../../widgets/blur_page_route.dart';
import 'edit_profile_screen.dart';

/// Profile Screen - User profile displaying actual database stats
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await ProfileService.getMyProfile();
    if (mounted) {
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );
    }

    final displayName = _profileData?['display_name'] ?? UserService.getDisplayName();
    final email = _profileData?['email'] ?? UserService.getEmail();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'PROFILE',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Name
            Text(
              displayName.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 4),

            // Email
            Text(
              email,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 12,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 32),

            // Settings sections backed by DB
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: 'PERSONAL INFORMATION',
              subtitle: email, // Showing actual email
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      initialName: displayName,
                      email: email,
                    ),
                  ),
                );
                // If user saved changes, reload profile
                if (result == true) {
                  setState(() => _isLoading = true);
                  _loadProfile();
                }
              },
            ),

            _buildSettingsItem(
              icon: Icons.tune,
              title: 'TRAVEL PREFERENCES',
              subtitle: 'No preferences set', // Pending implementation hooked to user_preferences table
              onTap: () {},
            ),

            const SizedBox(height: 48),

            // Buttons
            TextButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    BlurPageRoute(page: const LoginSignupScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'LOG OUT',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Version
            Text(
              'ITINERA V1.4.0',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 10,
                color: Colors.grey.shade400,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
