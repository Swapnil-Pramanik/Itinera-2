import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../onboarding/onboarding_1_screen.dart';
import '../home/home_screen.dart';

/// Login/Signup Screen - Entry point of the app
class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Full Screen Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          // 2. Fixed Logo & App Name
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo_white.png',
                  height: 64,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Itinera',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 3. Dynamic Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Welcome text
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plan your next journey with ease',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tab toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTab('Log In', _isLogin),
                          ),
                          Expanded(
                            child: _buildTab('Sign Up', !_isLogin),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Email field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email Address',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'user@example.com',
                            prefixIcon: Icon(
                              Icons.mail_outline,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Password field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_isLogin)
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Forgot?',
                                  style: TextStyle(
                                    fontFamily: 'RobotoMono',
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.grey.shade500,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Login/Signup button
                    PrimaryButton(
                      text: _isLogin ? 'Log In' : 'Sign Up',
                      onPressed: () {
                        if (_isLogin) {
                          // Login -> Go directly to Home
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        } else {
                          // Signup -> Go to Onboarding
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Onboarding1Screen(),
                            ),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Social buttons
                    Row(
                      children: [
                        Expanded(
                          child: SocialButton(
                            label: 'Google',
                            iconAsset: 'google',
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SocialButton(
                            label: 'Apple',
                            iconAsset: 'apple',
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Terms
                    Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to Itinera\'s ',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              color: Colors.grey.shade800,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              color: Colors.grey.shade800,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isLogin = label == 'Log In';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.black : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
