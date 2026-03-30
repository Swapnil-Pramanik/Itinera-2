import 'package:flutter/material.dart';
import '../../core/preference_service.dart';

class TravelPreferencesScreen extends StatefulWidget {
  const TravelPreferencesScreen({super.key});

  @override
  State<TravelPreferencesScreen> createState() =>
      _TravelPreferencesScreenState();
}

class _TravelPreferencesScreenState extends State<TravelPreferencesScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  // Selection state
  String _selectedStyle = 'BALANCED';
  String _selectedPace = 'FLEXIBLE';
  Set<String> _selectedInterests = {};
  String _selectedAutomation = 'PLAN EVERYTHING AUTOMATICALLY';

  final List<String> _styles = ['RELAXED', 'BALANCED', 'PACKED'];
  final List<String> _paces = ['SLOW MORNINGS', 'FLEXIBLE', 'EARLY STARTS'];
  final List<Map<String, dynamic>> _interestOptions = [
    {'label': 'Food', 'icon': Icons.restaurant_outlined},
    {'label': 'Culture', 'icon': Icons.museum_outlined},
    {'label': 'Nature', 'icon': Icons.park_outlined},
    {'label': 'Shopping', 'icon': Icons.shopping_bag_outlined},
    {'label': 'Nightlife', 'icon': Icons.nightlife_outlined},
    {'label': 'Adventure', 'icon': Icons.hiking_outlined},
  ];
  final List<String> _automationOptions = [
    'PLAN EVERYTHING AUTOMATICALLY',
    'SUGGEST, I\'LL DECIDE'
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await PreferenceService.getPreferences();
      setState(() {
        if (prefs.containsKey('TRAVEL_STYLE') && prefs['TRAVEL_STYLE']!.isNotEmpty) {
          _selectedStyle = prefs['TRAVEL_STYLE']!.first;
        }
        if (prefs.containsKey('DAILY_PACE') && prefs['DAILY_PACE']!.isNotEmpty) {
          _selectedPace = prefs['DAILY_PACE']!.first;
        }
        if (prefs.containsKey('INTERESTS')) {
          _selectedInterests = Set<String>.from(prefs['INTERESTS']!);
        }
        if (prefs.containsKey('AUTOMATION') && prefs['AUTOMATION']!.isNotEmpty) {
          _selectedAutomation = prefs['AUTOMATION']!.first;
        }
      });
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    try {
      final prefs = {
        'TRAVEL_STYLE': [_selectedStyle],
        'DAILY_PACE': [_selectedPace],
        'INTERESTS': _selectedInterests.toList(),
        'AUTOMATION': [_selectedAutomation],
      };
      final success = await PreferenceService.saveMultiplePreferences(prefs);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'TRAVEL PREFERENCES',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: Colors.black,
          ),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _savePreferences,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text(
                      'SAVE',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('TRAVEL STYLE'),
                  _buildStyleSection(),
                  const Divider(height: 64, thickness: 1, indent: 24, endIndent: 24),
                  _buildSectionHeader('DAILY PACE'),
                  _buildPaceSection(),
                  const Divider(height: 64, thickness: 1, indent: 24, endIndent: 24),
                  _buildSectionHeader('INTERESTS'),
                  _buildInterestsSection(),
                  const Divider(height: 64, thickness: 1, indent: 24, endIndent: 24),
                  _buildSectionHeader('AUTOMATION'),
                  _buildAutomationSection(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildStyleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your desired travel vibe?',
            style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ..._styles.map((style) => _buildRadioOption(
                title: style,
                isSelected: _selectedStyle == style,
                onTap: () => setState(() => _selectedStyle = style),
              )),
        ],
      ),
    );
  }

  Widget _buildPaceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How do you like your days scheduled?',
            style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ..._paces.map((pace) => _buildRadioOption(
                title: pace,
                isSelected: _selectedPace == pace,
                onTap: () => setState(() => _selectedPace = pace),
              )),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select your areas of interest',
            style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _interestOptions.map((opt) {
              final label = opt['label'] as String;
              final icon = opt['icon'] as IconData;
              final isSelected = _selectedInterests.contains(label);
              return FilterChip(
                label: Text(label),
                avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterests.add(label);
                    } else {
                      _selectedInterests.remove(label);
                    }
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: Colors.black,
                labelStyle: TextStyle(
                  fontFamily: 'RobotoMono',
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: isSelected ? Colors.black : Colors.grey.shade300),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Level of AI assistance',
            style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ..._automationOptions.map((opt) => _buildRadioOption(
                title: opt,
                isSelected: _selectedAutomation == opt,
                onTap: () => setState(() => _selectedAutomation = opt),
              )),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey.shade700,
                ),
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
