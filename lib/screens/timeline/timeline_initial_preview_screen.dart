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
  String _city = "";
  String _country = "";
  double _savedTime = 0.0;
  bool _isRegeneratingDay = false;

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
    final destCountry = currentTrip['destinations']?['country'] ?? "";

    if (mounted) {
      setState(() {
        _days = days;
        _destinationName = destName.toUpperCase();
        _city = destName;
        _country = destCountry;
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
              Image.asset('assets/images/logo_black.png', height: 20),
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
                  Text('${_days.length} DAYS PLANNED', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 10, color: Colors.green.shade800)),
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
              const SizedBox(height: 16),
              
              if (_savedTime != 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _savedTime > 0 ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _savedTime > 0 ? Colors.green.shade200 : Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _savedTime > 0 ? Icons.timer_outlined : Icons.warning_amber_rounded, 
                        color: _savedTime > 0 ? Colors.green.shade700 : Colors.red.shade700
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _savedTime > 0 
                                ? 'TIME SAVED: ${_savedTime.toStringAsFixed(1)} HOURS' 
                                : 'OVER SCHEDULED: ${(_savedTime.abs()).toStringAsFixed(1)} HOURS SHORT',
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _savedTime > 0 ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isRegeneratingDay 
                                ? 'Regenerating day...' 
                                : (_savedTime > 0 ? 'Would you like to add something else?' : 'Would you like to re-balance the day?'),
                              style: TextStyle(
                                fontSize: 13,
                                color: _savedTime > 0 ? Colors.green.shade900 : Colors.red.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isRegeneratingDay)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _savedTime = 0.0;
                                });
                              },
                              child: Text(
                                'DISMISS',
                                style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _savedTime > 0 ? Colors.green.shade800 : Colors.red.shade800,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  _isRegeneratingDay = true;
                                });
                                final success = await TripService.regenerateDay(
                                  widget.tripId, 
                                  _selectedDayIndex + 1,
                                  currentActivities: activities,
                                );
                                if (success) {
                                  await _loadItinerary();
                                }
                                if (mounted) {
                                  setState(() {
                                    _isRegeneratingDay = false;
                                    _savedTime = 0.0;
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: _savedTime > 0 ? Colors.green.shade200 : Colors.red.shade200,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                'YES',
                                style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _savedTime > 0 ? Colors.green.shade900 : Colors.red.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
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
                ...activities.asMap().entries.map((entry) {
                  final int actIdx = entry.key;
                  final activity = entry.value;
                  IconData icon = Icons.explore_outlined;
                  Color iconColor = Colors.grey;

                  if (activity['type'] == 'TRANSPORT') {
                    // Skip transport before Arrival or Hotel check-in
                    final nextIdx = actIdx + 1;
                    if (nextIdx < activities.length) {
                      final nextTitle = (activities[nextIdx]['title'] ?? '').toString().toLowerCase();
                      if (nextTitle.contains('arrival') || nextTitle.contains('hotel') || nextTitle.contains('check-in') || nextTitle.contains('check in')) {
                        return const SizedBox.shrink();
                      }
                    }
                    // Skip if first activity in the day
                    if (actIdx == 0) {
                      return const SizedBox.shrink();
                    }
                    return TransportConnectorCard(
                      time: activity['time'] ?? '??',
                      mode: activity['transport_mode'] ?? 'TRANSIT',
                      durationHours: (activity['duration_hours'] as num?)?.toDouble() ?? 0.3,
                      priceDelta: (activity['price_delta'] as num?)?.toDouble(),
                      currencySymbol: activity['currency_symbol'] ?? '₹',
                    );
                  }

                  switch (activity['type']) {
                    case 'SIGHTSEEING':
                      icon = Icons.camera_alt_outlined;
                      iconColor = Colors.orange;
                      break;
                    case 'DINING':
                      icon = Icons.restaurant_outlined;
                      iconColor = Colors.red;
                      break;
                    case 'TRANSPORT':
                      icon = Icons.directions_bus_outlined;
                      iconColor = Colors.blue;
                      break;
                    case 'RELAXATION':
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
                      durationHours: activity['duration_hours'] != null ? (activity['duration_hours'] as num).toDouble() : null,
                      icon: icon,
                      iconColor: iconColor,
                      onEdit: () async {
                        // Find previous non-transport activity title
                        String? prevTitle;
                        for (int pi = actIdx - 1; pi >= 0; pi--) {
                          if (activities[pi]['type'] != 'TRANSPORT') {
                            prevTitle = activities[pi]['title'];
                            break;
                          }
                        }
                        
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimelineEditorScreen(
                              tripId: widget.tripId,
                              activity: Map<String, dynamic>.from(activity),
                              previousActivityTitle: prevTitle,
                              city: _city,
                              country: _country,
                            ),
                          ),
                        );
                        
                        // Handle result from TimelineEditorScreen
                        if (result != null && result is Map<String, dynamic>) {
                          if (mounted) {
                            setState(() {
                              // Replace the activity internally to mock UI update
                              final double timeSaved = result['savedTime'] ?? 0.0;
                              if (timeSaved != 0) {
                                _savedTime += timeSaved;
                              }
                              
                              final updatedAct = result['activity'];
                              int idx = activities.indexOf(activity);
                              if (idx != -1) {
                                activities[idx] = updatedAct;
                                
                                // Sync transport card if it exists before this activity
                                if (idx > 0 && activities[idx - 1]['type'] == 'TRANSPORT') {
                                  activities[idx - 1]['transport_mode'] = result['transport_mode'];
                                  activities[idx - 1]['duration_hours'] = result['transport_duration_hours'];
                                  activities[idx - 1]['price_delta'] = result['transport_price_delta'];
                                  activities[idx - 1]['currency_symbol'] = result['currency_symbol'] ?? '₹';
                                }
                              }
                            });
                          }
                        }
                      },
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
