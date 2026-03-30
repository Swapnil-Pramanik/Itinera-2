import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'onboarding_completion_screen.dart';
import '../../widgets/blur_page_route.dart';
import '../../core/preference_service.dart';

/// Onboarding Screen 3 - Preferences selection with multi-step wizard
class Onboarding3Screen extends StatefulWidget {
  const Onboarding3Screen({super.key});

  @override
  State<Onboarding3Screen> createState() => _Onboarding3ScreenState();
}

class _Onboarding3ScreenState extends State<Onboarding3Screen>
    with SingleTickerProviderStateMixin {
  // Current step (0-3)
  int _currentStep = 0;
  bool _isLoading = false;

  // Selection state
  String _selectedStyle = 'BALANCED';
  String _selectedPace = 'FLEXIBLE';
  Set<String> _selectedInterests = {'Food', 'Culture'};
  bool _autoPlanning = true;

  // Animation controller for blur transition
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _blurAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_currentStep < 3) {
      // Animate out
      await _animationController.forward();

      // Change step
      setState(() {
        _currentStep++;
      });

      // Animate in
      await _animationController.reverse();
    } else {
      // Final step - save preferences and navigate to completion
      setState(() => _isLoading = true);
      
      try {
        final prefs = {
          'TRAVEL_STYLE': [_selectedStyle],
          'DAILY_PACE': [_selectedPace],
          'INTERESTS': _selectedInterests.toList(),
          'AUTOMATION': [_autoPlanning ? 'PLAN EVERYTHING AUTOMATICALLY' : 'SUGGEST, I\'LL DECIDE'],
        };
        
        await PreferenceService.saveMultiplePreferences(prefs);
      } catch (e) {
        print('Error saving preferences during onboarding: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            BlurPageRoute(
              page: const OnboardingCompletionScreen(),
            ),
          );
        }
      }
    }
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'TRAVEL STYLE';
      case 1:
        return 'DAILY PACE';
      case 2:
        return 'INTERESTS';
      case 3:
        return 'AUTOMATION LEVEL';
      default:
        return 'PREFERENCES';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildTravelStyle();
      case 1:
        return _buildDailyPace();
      case 2:
        return _buildInterests();
      case 3:
        return _buildAutomationLevel();
      default:
        return const SizedBox();
    }
  }

  Widget _buildTravelStyle() {
    return Row(
      children: [
        _buildStyleOption(
            'RELAXED', Icons.spa_outlined, _selectedStyle == 'RELAXED'),
        const SizedBox(width: 12),
        _buildStyleOption(
            'BALANCED', Icons.balance, _selectedStyle == 'BALANCED'),
        const SizedBox(width: 12),
        _buildStyleOption(
            'PACKED', Icons.flash_on_outlined, _selectedStyle == 'PACKED'),
      ],
    );
  }

  Widget _buildDailyPace() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildPaceChip('SLOW MORNINGS', _selectedPace == 'SLOW MORNINGS'),
        _buildPaceChip('FLEXIBLE', _selectedPace == 'FLEXIBLE'),
        _buildPaceChip('EARLY STARTS', _selectedPace == 'EARLY STARTS'),
      ],
    );
  }

  Widget _buildInterests() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildInterestChip('Food', Icons.restaurant_outlined),
        _buildInterestChip('Culture', Icons.museum_outlined),
        _buildInterestChip('Nature', Icons.park_outlined),
        _buildInterestChip('Shopping', Icons.shopping_bag_outlined),
        _buildInterestChip('Nightlife', Icons.nightlife_outlined),
        _buildInterestChip('Adventure', Icons.hiking_outlined),
      ],
    );
  }

  Widget _buildAutomationLevel() {
    return Column(
      children: [
        _buildAutomationOption(
          'PLAN EVERYTHING AUTOMATICALLY',
          'We build the entire schedule for you.',
          Icons.auto_awesome,
          _autoPlanning,
          () => setState(() => _autoPlanning = true),
        ),
        const SizedBox(height: 12),
        _buildAutomationOption(
          'SUGGEST, I\'LL DECIDE',
          'Get recommendations, build it yourself.',
          Icons.edit_note,
          !_autoPlanning,
          () => setState(() => _autoPlanning = false),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              // Header Row with Back Button & Step
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  Text(
                    'STEP 3 OF 4',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Animation
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: Lottie.asset(
                    'assets/planning_route.json',
                    height: 360,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Animation Unavailable',
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Static Preferences heading
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREFERENCES',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.0,
                        color: Colors.black,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tell us your travel DNA. We\'ll handle the rest.',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Step content with blur transition
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: _blurAnimation.value,
                        sigmaY: _blurAnimation.value,
                      ),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getStepTitle(),
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStepContent(),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleContinue,
                    child: _isLoading ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ) : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep < 3 ? 'NEXT' : 'CONTINUE',
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleOption(String label, IconData icon, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStyle = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.black : Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.black : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaceChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPace = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildInterestChip(String label, IconData icon) {
    final isSelected = _selectedInterests.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedInterests.remove(label);
          } else {
            _selectedInterests.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey.shade500,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutomationOption(
    String title,
    String description,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.black : Colors.grey.shade400,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.black : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey.shade300,
                  width: isSelected ? 7 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
