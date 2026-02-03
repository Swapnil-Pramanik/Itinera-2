import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/common/common.dart';

/// Trip Checklist Screen - Pre-trip preparation checklist
class TripChecklistScreen extends StatefulWidget {
  const TripChecklistScreen({super.key});

  @override
  State<TripChecklistScreen> createState() => _TripChecklistScreenState();
}

class _TripChecklistScreenState extends State<TripChecklistScreen> {
  final Map<String, bool> _checklistItems = {
    'Book flights': true,
    'Book accommodation': true,
    'Get travel insurance': true,
    'Check passport validity': false,
    'Apply for visa if needed': false,
    'Purchase JR Pass': false,
    'Download offline maps': false,
    'Pack luggage': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'PRE-TRIP CHECKLIST',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'ADD',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_checklistItems.values.where((v) => v).length}/${_checklistItems.length} COMPLETED',
                      style: const TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${((_checklistItems.values.where((v) => v).length / _checklistItems.length) * 100).round()}%',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _checklistItems.values.where((v) => v).length / _checklistItems.length,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          // Checklist items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildSectionLabel('TRAVEL'),
                const SizedBox(height: 8),
                ..._buildChecklistItems(['Book flights', 'Get travel insurance', 'Check passport validity', 'Apply for visa if needed']),
                const SizedBox(height: 24),
                _buildSectionLabel('STAY'),
                const SizedBox(height: 8),
                ..._buildChecklistItems(['Book accommodation']),
                const SizedBox(height: 24),
                _buildSectionLabel('ESSENTIALS'),
                const SizedBox(height: 8),
                ..._buildChecklistItems(['Purchase JR Pass', 'Download offline maps', 'Pack luggage']),
              ],
            ),
          ),
          // Save button
          Padding(
            padding: const EdgeInsets.all(20),
            child: PrimaryButton(
              text: 'SAVE CHECKLIST',
              showArrow: false,
              onPressed: () => Navigator.pop(context),
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
        color: Colors.grey.shade600,
        letterSpacing: 1.2,
      ),
    );
  }

  List<Widget> _buildChecklistItems(List<String> items) {
    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ChecklistItem(
          label: item,
          isChecked: _checklistItems[item] ?? false,
          onChanged: (value) => setState(() => _checklistItems[item] = value),
        ),
      );
    }).toList();
  }
}
