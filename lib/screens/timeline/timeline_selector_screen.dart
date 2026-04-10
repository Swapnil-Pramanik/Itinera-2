import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import 'timeline_generation_loading_screen.dart';
import '../../core/trip_service.dart';

/// Timeline Selector Screen - Calendar date picker
class TimelineSelectorScreen extends StatefulWidget {
  final String destinationId;
  final String destinationName;
  final double? dailyCost;
  final double? luxuryDailyCost;

  const TimelineSelectorScreen({
    super.key,
    required this.destinationId,
    required this.destinationName,
    this.dailyCost,
    this.luxuryDailyCost,
  });

  @override
  State<TimelineSelectorScreen> createState() => _TimelineSelectorScreenState();
}

class _TimelineSelectorScreenState extends State<TimelineSelectorScreen> {
  DateTime _startDate = DateTime.now().add(const Duration(days: 30));
  DateTime _endDate = DateTime.now().add(const Duration(days: 37));
  String _selectedBudget = 'STANDARD';
  final TextEditingController _departureCityController = TextEditingController();

  @override
  void dispose() {
    _departureCityController.dispose();
    super.dispose();
  }

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
            Image.asset(
              'assets/images/logo_black.png',
              height: 20,
            ),
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
                'We\'ll generate a day-by-day plan for ${widget.destinationName}',
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
              // Departure city
              Text(
                'STARTING FROM',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _departureCityController,
                  style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'e.g. New Delhi, Mumbai...',
                    hintStyle: TextStyle(fontFamily: 'RobotoMono', fontSize: 14, color: Colors.grey.shade400),
                    icon: Icon(Icons.flight_takeoff, size: 20, color: Colors.grey.shade600),
                  ),
                ),
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
              // Try to calculate budget
              if (widget.dailyCost != null) ...[
                const SizedBox(height: 16),
                _buildBudgetSelector(),
              ],
              const Spacer(),
               // Generate button
              PrimaryButton(
                text: 'GENERATE MY ITINERARY',
                onPressed: () async {
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );

                  // Calculate target budget based on selected level
                  final days = _endDate.difference(_startDate).inDays;
                  final baseDaily = widget.dailyCost ?? 100.0;
                  final luxuryDaily = widget.luxuryDailyCost ?? (baseDaily * 2.5);
                  final comfortDaily = (baseDaily + luxuryDaily) / 2;
                  
                  int targetBudget;
                  if (_selectedBudget == 'LUXURY') {
                    targetBudget = (luxuryDaily * days).round();
                  } else if (_selectedBudget == 'COMFORT') {
                    targetBudget = (comfortDaily * days).round();
                  } else {
                    targetBudget = (baseDaily * days).round();
                  }

                  // 1. Create the trip record
                  final trip = await TripService.createTrip(
                    destinationId: widget.destinationId,
                    startDate: _startDate,
                    endDate: _endDate,
                    departureCity: _departureCityController.text.trim().isNotEmpty 
                      ? _departureCityController.text.trim() 
                      : null,
                    budgetLevel: _selectedBudget,
                    targetBudget: targetBudget,
                  );

                  // Hide loading
                  if (mounted) Navigator.pop(context);

                    if (trip != null && mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimelineGenerationLoadingScreen(
                            tripId: trip['id'],
                            budgetLevel: _selectedBudget,
                          ),
                        ),
                      );
                    } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to initialize trip. Please try again.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSelector() {
    final days = _endDate.difference(_startDate).inDays;
    final baseDaily = widget.dailyCost ?? 100.0;
    final luxuryDaily = widget.luxuryDailyCost ?? (baseDaily * 2.5);
    final comfortDaily = (baseDaily + luxuryDaily) / 2;

    final standardTotal = (baseDaily * days).round();
    final comfortTotal = (comfortDaily * days).round();
    final luxuryTotal = (luxuryDaily * days).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BUDGET PREFERENCE',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              _buildBudgetOption('STANDARD', '₹$standardTotal', Icons.travel_explore),
              _buildBudgetOption('COMFORT', '₹$comfortTotal', Icons.local_taxi),
              _buildBudgetOption('LUXURY', '₹$luxuryTotal', Icons.diamond_outlined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetOption(String level, String price, IconData icon) {
    final isSelected = _selectedBudget == level;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedBudget = level;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey.shade500,
              ),
              const SizedBox(height: 4),
              Text(
                level,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                price,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade800,
                ),
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
