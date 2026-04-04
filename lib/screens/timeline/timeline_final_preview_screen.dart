import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../budget/budget_loading_screen.dart';
import '../../core/trip_service.dart';
import 'package:intl/intl.dart';

/// Timeline Final Preview Screen - Complete multi-day itinerary view
class TimelineFinalPreviewScreen extends StatefulWidget {
  final String tripId;
  final VoidCallback onFinalized;

  const TimelineFinalPreviewScreen({
    super.key,
    required this.tripId,
    required this.onFinalized,
  });

  @override
  State<TimelineFinalPreviewScreen> createState() => _TimelineFinalPreviewScreenState();
}

class _TimelineFinalPreviewScreenState extends State<TimelineFinalPreviewScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _days = [];
  String _destinationName = "TRIP";
  String _dateRange = "";
  int _dayCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // 1. Fetch itinerary days
    final days = await TripService.getTripDays(widget.tripId);
    
    // 2. Fetch trip details for the header
    final trips = await TripService.getMyTrips();
    final currentTrip = trips.firstWhere((t) => t['id'] == widget.tripId, orElse: () => {});
    
    final destination = currentTrip['destinations'] ?? {};
    final name = (destination['name'] ?? "Destination").toString().toUpperCase();
    final country = (destination['country'] ?? "").toString().toUpperCase();
    
    // Format dates
    String range = "";
    if (currentTrip['start_date'] != null) {
      final start = DateTime.parse(currentTrip['start_date']);
      final end = currentTrip['end_date'] != null ? DateTime.parse(currentTrip['end_date']) : start.add(const Duration(days: 6));
      final formatter = DateFormat('MMM d');
      range = "${formatter.format(start).toUpperCase()} - ${formatter.format(end).toUpperCase()} • ${days.length} DAYS";
    }

    if (mounted) {
      setState(() {
        _days = days;
        _destinationName = "$name, $country";
        _dateRange = range;
        _dayCount = days.length;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black)),
        title: const Text('FINAL ITINERARY',
            style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: Colors.black)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.check_circle,
                    size: 14, color: Colors.green.shade800),
                const SizedBox(width: 4),
                Text('ALL $_dayCount DAYS PLANNED',
                    style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 10,
                        color: Colors.green.shade800)),
              ],
            ),
          ),
        ],
      ),
      body: _days.isEmpty 
          ? const Center(child: Text("No itinerary found.")) 
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_destinationName,
                style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 24,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(_dateRange,
                style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 14,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            // Day summary cards
            ..._days.map((day) {
              final List<dynamic> acts = day['activities'] ?? [];
              final List<String> activityTitles = acts.map((a) => (a['title'] ?? "").toString()).toList();
              
              return _buildDayCard(
                'DAY ${day['day_number']}',
                day['day_title'] ?? 'Exploring',
                activityTitles,
                _getIconForDay(day['day_number']),
              );
            }).toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4))
        ]),
        child: SafeArea(
          child: PrimaryButton(
            text: 'CONFIRM & ESTIMATE BUDGET',
            onPressed: () async {
              // Finalize the trip status in the backend
              widget.onFinalized(); // Tell the previous screen we're finalized
              await TripService.updateTrip(widget.tripId, status: 'PLANNED');

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BudgetLoadingScreen(),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  IconData _getIconForDay(int dayNum) {
    List<IconData> icons = [
      Icons.temple_buddhist,
      Icons.location_city,
      Icons.nightlife,
      Icons.museum,
      Icons.park,
      Icons.restaurant,
      Icons.flight
    ];
    return icons[(dayNum - 1) % icons.length];
  }

  Widget _buildDayCard(
      String day, String title, List<String> activities, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(day,
                        style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(title,
                            style: const TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 14,
                                fontWeight: FontWeight.w600))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(activities.take(3).join(' • '), // Show only top 3 to keep it clean
                    style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 12,
                        color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
