import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/common/common.dart';
import 'onboarding_3_screen.dart';

/// Onboarding Screen 2 - "How It Works" with feature list
class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

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
            top: statusBarHeight + 20,
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
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    'How It Works',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Effortless travel planning powered by automation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Feature items
                  const FeatureItem(
                    icon: Icons.tune,
                    title: 'Your Preferences',
                    description:
                        'Use our sliders to set your budget, dates, and travel intensity.',
                  ),

                  const FeatureItem(
                    icon: Icons.auto_awesome,
                    title: 'Smart Generation',
                    description:
                        'Our AI instantly builds a personalized, day-by-day itinerary.',
                  ),

                  const FeatureItem(
                    icon: Icons.toggle_on_outlined,
                    title: 'Total Control',
                    description:
                        'Toggle activities, swap restaurants, and finalize your plan.',
                  ),

                  const SizedBox(height: 40),

                  // Progress dots
                  const ProgressDots(currentIndex: 1, totalDots: 3),

                  const SizedBox(height: 24),

                  // Continue button
                  PrimaryButton(
                    text: 'Continue',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Onboarding3Screen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Skip button
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Onboarding3Screen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
