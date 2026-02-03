import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/common/common.dart';
import 'onboarding_2_screen.dart';

/// Onboarding Screen 1 - Hero image with "Effortless Adaptive Planning"
class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({super.key});

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
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'EFFORTLESS\nADAPTIVE\nPLANNING',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Itinera intelligently crafts and adjusts your journeys automatically, so you can focus on the experience.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Progress dots
                  const ProgressDots(currentIndex: 0, totalDots: 3),

                  const SizedBox(height: 24),

                  // Start button
                  PrimaryButton(
                    text: 'START PLANNING',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Onboarding2Screen(),
                        ),
                      );
                    },
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
