import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/user_service.dart';
import '../../widgets/buttons/buttons.dart';
import '../auth/login_signup_screen.dart';
import '../../widgets/blur_page_route.dart';

/// Profile Screen - User profile with settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
          ),
        ],
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
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Name
            Text(
              UserService.getDisplayName().toUpperCase(),
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'EXPLORER LEVEL 4',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 12,
                color: Colors.grey.shade600,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 32),

            // Settings sections
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: 'PERSONAL INFORMATION',
              subtitle: 'Name, email, and phone',
              onTap: () {},
            ),

            _buildSettingsItem(
              icon: Icons.tune,
              title: 'TRAVEL PREFERENCES',
              subtitle: 'Tailor your automation',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMiniChip('URBAN'),
                  const SizedBox(width: 4),
                  _buildMiniChip('FOOD'),
                  const SizedBox(width: 4),
                  _buildMiniChip('+3 MORE'),
                ],
              ),
              onTap: () {},
            ),

            _buildSettingsItem(
              icon: Icons.notifications_outlined,
              title: 'NOTIFICATION SETTINGS',
              subtitle: 'Alerts & travel updates',
              onTap: () {},
            ),

            _buildSettingsItem(
              icon: Icons.lock_outline,
              title: 'PRIVACY & SECURITY',
              subtitle: 'Passkeys & data control',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // Linked accounts
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'LINKED ACCOUNTS',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            _buildLinkedAccount(
              icon: 'G',
              iconColor: Colors.red,
              name: 'GOOGLE',
              status: 'CONNECTED',
              isConnected: true,
            ),

            _buildLinkedAccount(
              icon: '',
              iconWidget: const Icon(Icons.apple, size: 20),
              name: 'APPLE',
              status: 'LINK ACCOUNT',
              isConnected: false,
            ),

            const SizedBox(height: 32),

            // Buttons
            const PrimaryButton(
              text: 'SAVE CHANGES',
              showArrow: false,
            ),

            const SizedBox(height: 12),

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
    Widget? trailing,
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
                  if (trailing != null)
                    trailing
                  else
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

  Widget _buildMiniChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLinkedAccount({
    String? icon,
    Widget? iconWidget,
    Color? iconColor,
    required String name,
    required String status,
    required bool isConnected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          if (iconWidget != null)
            iconWidget
          else
            Text(
              icon ?? '',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 11,
              color: isConnected ? Colors.green : Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
