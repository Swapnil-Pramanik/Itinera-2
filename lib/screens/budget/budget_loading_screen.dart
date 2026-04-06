import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/budget_service.dart';
import 'budget_estimation_screen.dart';

/// Budget Loading Screen - Premium high-fidelity loading state for AI insights
class BudgetLoadingScreen extends StatefulWidget {
  final String tripId;
  const BudgetLoadingScreen({super.key, required this.tripId});

  @override
  State<BudgetLoadingScreen> createState() => _BudgetLoadingScreenState();
}

class _BudgetLoadingScreenState extends State<BudgetLoadingScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  Map<String, dynamic>? _preloadedBudget;
  int _currentLabelIndex = 0;
  
  final List<String> _loadingLabels = [
    'CONSULTING LOCAL AI EXPERTS...',
    'CALCULATING FLIGHT TRENDS...',
    'ANALYZING HOTEL STAR RATINGS...',
    'MAPPING ACTIVITY COSTS...',
    'STITCHING TRIP BREAKDOWN...',
    'FINALIZING BUDGET INSIGHTS...',
  ];

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 240), // Support very long AI processing
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 0.95).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _progressController.forward();
    _rotateLabels();
    _startLoading();
  }

  void _rotateLabels() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          _currentLabelIndex = (_currentLabelIndex + 1) % _loadingLabels.length;
        });
      }
    }
  }

  Future<void> _startLoading() async {
    try {
      debugPrint('[BudgetLoading] Fetching budget for: ${widget.tripId}');
      final budget = await BudgetService.getTripBudget(widget.tripId);
      _preloadedBudget = budget;
      
      if (mounted) {
        // Snap progress to completion
        _progressController.animateTo(1.0, duration: const Duration(milliseconds: 500));
      }
    } catch (e) {
      debugPrint('[BudgetLoading] Error: $e');
    }

    // Minimum cinematic wait
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      if (_preloadedBudget == null) {
        // Show an error instead of transitioning to an empty screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget calculation took too long or failed. Retrying...'),
            backgroundColor: Colors.redAccent,
          ),
        );
        // Maybe go back or show a retry button? 
        // For now, let's still transition but the backend fallback will now handle it.
      }
      _transitionToDetails();
    }
  }

  void _transitionToDetails() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => BudgetEstimationScreen(
          tripId: widget.tripId,
          preloadedBudget: _preloadedBudget,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Center High-Fidelity Lottie
            SizedBox(
              width: 320,
              height: 320,
              child: Lottie.asset(
                'assets/planning_route.json',
                fit: BoxFit.contain,
              ),
            ),
            
            const SizedBox(height: 10),

            // Premium Analysis Text
            const Text(
              'ANALYZING BUDGET ECOSYSTEM',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 48),

            // Progress Bar Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                children: [
                   AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _progressAnimation.value,
                              backgroundColor: Colors.white.withOpacity(0.05),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(_progressAnimation.value * 100).toInt()}%',
                                style: const TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 10,
                                  color: Colors.white38,
                                ),
                              ),
                              Text(
                                'AI OPTIMIZATION IN PROGRESS',
                                style: const TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 10,
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Animated Label
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _loadingLabels[_currentLabelIndex],
                      key: ValueKey(_currentLabelIndex),
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
