import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/cards/cards.dart';
import 'timeline_final_preview_screen.dart';
import '../../core/trip_service.dart';

/// Timeline Update Preview Screen - Shows updated itinerary after editing
class TimelineUpdatePreviewScreen extends StatefulWidget {
  final String tripId;
  const TimelineUpdatePreviewScreen({super.key, required this.tripId});

  @override
  State<TimelineUpdatePreviewScreen> createState() => _TimelineUpdatePreviewScreenState();
}

class _TimelineUpdatePreviewScreenState extends State<TimelineUpdatePreviewScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _days = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final days = await TripService.getTripDays(widget.tripId);
    if (mounted) {
      setState(() {
        _days = days;
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

    final firstDay = _days.isNotEmpty ? _days.first : null;
    final List<dynamic> activities = firstDay?['activities'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.black)),
        title: const Text('UPDATED ITINERARY', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1, color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Update notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Your itinerary has been updated based on your changes.', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 13, color: Colors.blue.shade800))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Day header
            const Text('DAY 1 • UPDATED', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
            const SizedBox(height: 16),
            // Updated activities
            if (activities.isEmpty)
              const Center(child: Text("No activities found."))
            else
              ...activities.map((act) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ActivityCard(
                    time: act['time'] ?? '??',
                    title: act['title'] ?? 'Activity',
                    subtitle: 'Updated',
                    icon: _getIconForCategory(act['type'] ?? ''),
                    iconColor: _getColorForCategory(act['type'] ?? ''),
                  ),
                );
              }).toList(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: PrimaryButton(
            text: 'CONTINUE TO FINAL PREVIEW',
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => TimelineFinalPreviewScreen(
                    tripId: widget.tripId,
                    onFinalized: () {},
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'SIGHTSEEING': return Icons.camera_alt_outlined;
      case 'DINING': return Icons.restaurant_outlined;
      case 'TRANSPORT': return Icons.directions_bus_outlined;
      case 'RELAXATION': return Icons.hotel_outlined;
      default: return Icons.explore_outlined;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'SIGHTSEEING': return Colors.orange;
      case 'DINING': return Colors.green;
      case 'TRANSPORT': return Colors.blue;
      case 'RELAXATION': return Colors.teal;
      default: return Colors.grey;
    }
  }
}
