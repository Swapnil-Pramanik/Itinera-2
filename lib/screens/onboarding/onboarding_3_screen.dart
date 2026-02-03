import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import 'onboarding_completion_screen.dart';

/// Onboarding Screen 3 - Preferences selection
class Onboarding3Screen extends StatefulWidget {
  const Onboarding3Screen({super.key});

  @override
  State<Onboarding3Screen> createState() => _Onboarding3ScreenState();
}

class _Onboarding3ScreenState extends State<Onboarding3Screen> {
  String _selectedStyle = 'BALANCED';
  String _selectedPace = 'FLEXIBLE';
  Set<String> _selectedInterests = {'Food', 'Culture'};
  bool _autoPlanning = true;

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
              color: Colors.black.withValues(alpha: 0.3),
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
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Text(
                        'STEP 3 OF 4',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PREFERENCES',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tell us your travel DNA. We\'ll handle the rest.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSectionLabel('TRAVEL STYLE'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildStyleOption('RELAXED', Icons.spa_outlined,
                                  _selectedStyle == 'RELAXED'),
                              const SizedBox(width: 12),
                              _buildStyleOption('BALANCED', Icons.balance,
                                  _selectedStyle == 'BALANCED'),
                              const SizedBox(width: 12),
                              _buildStyleOption(
                                  'PACKED',
                                  Icons.flash_on_outlined,
                                  _selectedStyle == 'PACKED'),
                            ],
                          ),
                          const SizedBox(height: 28),
                          _buildSectionLabel('DAILY PACE'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ChipButton(
                                label: 'SLOW MORNINGS',
                                isSelected: _selectedPace == 'SLOW MORNINGS',
                                onTap: () => setState(
                                    () => _selectedPace = 'SLOW MORNINGS'),
                              ),
                              ChipButton(
                                label: 'FLEXIBLE',
                                isSelected: _selectedPace == 'FLEXIBLE',
                                onTap: () =>
                                    setState(() => _selectedPace = 'FLEXIBLE'),
                              ),
                              ChipButton(
                                label: 'EARLY STARTS',
                                isSelected: _selectedPace == 'EARLY STARTS',
                                onTap: () => setState(
                                    () => _selectedPace = 'EARLY STARTS'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          _buildSectionLabel('INTERESTS'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildInterestChip(
                                  'Food', Icons.restaurant_outlined),
                              _buildInterestChip(
                                  'Culture', Icons.museum_outlined),
                              _buildInterestChip('Nature', Icons.park_outlined),
                              _buildInterestChip(
                                  'Shopping', Icons.shopping_bag_outlined),
                              _buildInterestChip(
                                  'Nightlife', Icons.nightlife_outlined),
                              _buildInterestChip(
                                  'Adventure', Icons.hiking_outlined),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildSectionLabel('AUTOMATION LEVEL'),
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 40),
                          PrimaryButton(
                            text: 'CONTINUE',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const OnboardingCompletionScreen(),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'RobotoMono',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildStyleOption(String label, IconData icon, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStyle = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.black : Colors.grey.shade600,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.black : Colors.grey.shade600,
                ),
              ),
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 12,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.black : Colors.grey.shade600,
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
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey.shade400,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
