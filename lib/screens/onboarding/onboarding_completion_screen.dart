import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/common/common.dart';
import '../home/home_screen.dart';

/// Onboarding Completion Screen - Loading state before home
class OnboardingCompletionScreen extends StatefulWidget {
  const OnboardingCompletionScreen({super.key});

  @override
  State<OnboardingCompletionScreen> createState() =>
      _OnboardingCompletionScreenState();
}

class _OnboardingCompletionScreenState
    extends State<OnboardingCompletionScreen> {
  bool _step1Complete = false;
  bool _step2Complete = false;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _step1Complete = true);
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _step2Complete = true);
    }
  }

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
                    'PREPARING YOUR\nEXPERIENCE',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Loading status items
                  LoadingStatusItem(
                    text: 'CHECKING WEATHER...',
                    isComplete: _step1Complete,
                    isLoading: !_step1Complete,
                  ),

                  LoadingStatusItem(
                    text: 'OPTIMIZING ROUTES...',
                    isComplete: _step2Complete,
                    isLoading: _step1Complete && !_step2Complete,
                  ),

                  const SizedBox(height: 40),

                  // Start Exploring button
                  PrimaryButton(
                    text: 'START EXPLORING',
                    icon: Icons.auto_awesome,
                    showArrow: false,
                    onPressed: _step2Complete
                        ? () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        : null,
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
