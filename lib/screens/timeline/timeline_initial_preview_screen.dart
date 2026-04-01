import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/cards/cards.dart';
import 'timeline_editor_screen.dart';
import 'timeline_final_preview_screen.dart';
import '../../core/trip_service.dart';

/// Timeline Initial Preview Screen - First generated itinerary view
class TimelineInitialPreviewScreen extends StatefulWidget {
  final String tripId;
  const TimelineInitialPreviewScreen({super.key, required this.tripId});

  @override
  State<TimelineInitialPreviewScreen> createState() => _TimelineInitialPreviewScreenState();
}

class _TimelineInitialPreviewScreenState extends State<TimelineInitialPreviewScreen> {
  bool _isFinalized = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _days = [];
  int _selectedDayIndex = 0;
  String _destinationName = "Destination";

  @override
  void initState() {
    super.initState();
    _loadItinerary();
  }

  Future<void> _loadItinerary() async {
    setState(() => _isLoading = true);
    final days = await TripService.getTripDays(widget.tripId);
    
    // Also fetch destination name for the header
    final trips = await TripService.getMyTrips();
    final currentTrip = trips.firstWhere((t) => t['id'] == widget.tripId, orElse: () => {});
    final destName = currentTrip['destinations']?['name'] ?? "Trip";

    if (mounted) {
      setState(() {
        _days = days;
        _destinationName = destName.toUpperCase();
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

    final selectedDay = _days.isNotEmpty ? _days[_selectedDayIndex] : null;
    final List<dynamic> activities = selectedDay?['activities'] ?? [];

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && !_isFinalized) {
          // Rollback: Delete the draft trip
          TripService.deleteTrip(widget.tripId);
        }
      },
      child: Scaffold(
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
              const Text('Itinera', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.check, size: 14, color: Colors.green.shade800),
                  const SizedBox(width: 4),
                  Text('DAY 1 PLANNED', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 10, color: Colors.green.shade800)),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('YOUR $_destinationName\nITINERARY',
                  style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.2)),
              const SizedBox(height: 8),
              Text('Exploring ${_days.length} days of adventure',
                  style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 14,
                      color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              // Day tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_days.length, (index) {
                    return _buildDayTab(
                      'DAY ${index + 1}',
                      _selectedDayIndex == index,
                      () => setState(() => _selectedDayIndex = index),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              // Activities
              if (activities.isEmpty)
                const Center(child: Text("No activities planned for this day."))
              else
                ...activities.map((activity) {
                  IconData icon = Icons.explore_outlined;
                  Color iconColor = Colors.grey;

                  switch (activity['type']) {
                    case 'SIGHTSEEING':
                      icon = Icons.camera_alt_outlined;
                      iconColor = Colors.orange;
                      break;
                    case 'DINING':
                      icon = Icons.restaurant_outlined;
                      iconColor = Colors.red;
                      break;
                    case 'TRANSIT':
                      icon = Icons.directions_bus_outlined;
                      iconColor = Colors.blue;
                      break;
                    case 'BREAK':
                      icon = Icons.hotel_outlined;
                      iconColor = Colors.green;
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ActivityCard(
                      time: activity['time'] ?? '??',
                      title: activity['title'] ?? 'Activity',
                      subtitle: activity['description'] ?? '',
                      icon: icon,
                      iconColor: iconColor,
                    ),
                  );
                }).toList(),
              const SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Edit',
                    icon: Icons.edit_outlined,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimelineEditorScreen(
                            tripId: widget.tripId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Complete',
                    showArrow: false,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimelineFinalPreviewScreen(
                            tripId: widget.tripId,
                            onFinalized: () {
                              setState(() {
                                _isFinalized = true;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayTab(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'RobotoMono', fontSize: 12, fontWeight: FontWeight.w500, color: isActive ? Colors.white : Colors.grey.shade700)),
      ),
    );
  }
}
