import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import 'timeline_generation_loading_screen.dart';

/// Timeline Selector Screen - Calendar date picker
class TimelineSelectorScreen extends StatefulWidget {
  const TimelineSelectorScreen({super.key});

  @override
  State<TimelineSelectorScreen> createState() => _TimelineSelectorScreenState();
}

class _TimelineSelectorScreenState extends State<TimelineSelectorScreen> {
  DateTime _startDate = DateTime.now().add(const Duration(days: 30));
  DateTime _endDate = DateTime.now().add(const Duration(days: 37));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Row(
          children: [
            const Icon(Icons.send, size: 18, color: Colors.black87),
            const SizedBox(width: 8),
            const Text(
              'Itinera',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'SELECT YOUR\nDATES',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll generate a day-by-day plan for Tokyo, Japan',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              // Date selection boxes
              Row(
                children: [
                  Expanded(
                    child: _buildDateBox('START', _startDate, () => _selectDate(true)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateBox('END', _endDate, () => _selectDate(false)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Duration info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 20, color: Colors.grey.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'IDEAL DURATION: 7-10 DAYS',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            'Based on your travel style and interests',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Trip length display
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    '${_endDate.difference(_startDate).inDays} DAYS',
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Generate button
              PrimaryButton(
                text: 'GENERATE MY ITINERARY',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TimelineGenerationLoadingScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateBox(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 11,
                color: Colors.grey.shade600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_monthName(date.month)} ${date.day}',
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${date.year}',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 7));
          }
        } else {
          _endDate = date;
        }
      });
    }
  }
}
