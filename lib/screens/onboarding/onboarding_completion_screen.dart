import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            children: [
              // Header with logo
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 40),
                  child: Image.asset(
                    'assets/images/logo_black.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Expanded Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'PREPARING YOUR\nEXPERIENCE',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: -1.0,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Loading status items
                    _buildStatusItem(
                      text: 'CHECKING WEATHER...',
                      isComplete: _step1Complete,
                      isLoading: !_step1Complete,
                    ),

                    _buildStatusItem(
                      text: 'OPTIMIZING ROUTES...',
                      isComplete: _step2Complete,
                      isLoading: _step1Complete && !_step2Complete,
                    ),
                  ],
                ),
              ),

              // Start Exploring button - pill shaped
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey.shade400,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'START EXPLORING',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required String text,
    required bool isComplete,
    required bool isLoading,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          if (isComplete)
            Icon(
              Icons.check_circle,
              size: 24,
              color: Colors.green.shade600,
            )
          else if (isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.black,
              ),
            )
          else
            Icon(
              Icons.circle_outlined,
              size: 24,
              color: Colors.grey.shade300,
            ),
          const SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isComplete ? Colors.black : Colors.grey.shade400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
