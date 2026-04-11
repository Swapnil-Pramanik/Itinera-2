import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/trip_service.dart';
import '../trip/trip_scheduled_screen.dart';
import '../trip/trip_current_screen.dart';
import '../trip/trip_completed_screen.dart';

/// Dark-themed bottom sheet displaying all planned trips.
/// Design mirrors the MyAtlasBottomSheet for visual consistency.
class MyTripsBottomSheet extends StatefulWidget {
  const MyTripsBottomSheet({super.key});

  @override
  State<MyTripsBottomSheet> createState() => _MyTripsBottomSheetState();
}

class _MyTripsBottomSheetState extends State<MyTripsBottomSheet> {
  List<Map<String, dynamic>> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final trips = await TripService.getMyTrips();
    if (mounted) {
      setState(() {
        _trips = trips;
        _sortTrips();
        _isLoading = false;
      });
    }
  }

  void _sortTrips() {
    _trips.sort((a, b) {
      final aDate = DateTime.tryParse(a['start_date'] ?? '');
      final bDate = DateTime.tryParse(b['start_date'] ?? '');
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });
  }

  String _calculateTripStatus(String? start, String? end) {
    if (start == null || start.isEmpty) return "PLANNING";
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime.tryParse(start);
    final endDate = end != null ? DateTime.tryParse(end) : null;
    if (startDate == null) return "PLANNING";
    if (today.isBefore(startDate)) return "UPCOMING";
    if (endDate != null && today.isAfter(endDate)) return "PAST";
    return "ONGOING";
  }

  Color _statusColor(String status) {
    switch (status) {
      case "ONGOING":
        return Colors.blueAccent;
      case "UPCOMING":
        return Colors.greenAccent;
      case "PAST":
        return Colors.white38;
      default:
        return Colors.amber;
    }
  }

  void _navigateToTrip(Map<String, dynamic> trip) {
    final tripId = trip['id'];
    if (tripId == null) return;

    final status = _calculateTripStatus(trip['start_date'], trip['end_date']);
    Widget targetScreen;
    switch (status) {
      case "ONGOING":
        targetScreen = TripCurrentScreen(tripId: tripId);
        break;
      case "PAST":
        targetScreen = TripCompletedScreen(tripId: tripId);
        break;
      default:
        targetScreen = TripScheduledScreen(tripId: tripId);
    }

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.67,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.luggage_outlined, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'MY PLANNED TRIPS',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, thickness: 1, height: 24),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white54),
                  )
                : _trips.isEmpty
                    ? Center(
                        child: Text(
                          'No trips planned yet.',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Colors.grey.shade500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: _trips.length,
                        itemBuilder: (context, index) {
                          final trip = _trips[index];
                          return _buildTripListItem(trip);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripListItem(Map<String, dynamic> trip) {
    final destination = (trip['destinations'] as Map?)?.cast<String, dynamic>();
    final name = destination?['name'] ?? trip['title'] ?? 'Trip';
    final country = destination?['country'] ?? '';
    final imageUrl = destination?['image_url'];
    final status = _calculateTripStatus(trip['start_date'], trip['end_date']);
    final statusCol = _statusColor(status);
    final tags = (destination?['tags'] as List<dynamic>?)
            ?.map((t) => t.toString())
            .toList() ??
        (trip['tags'] as List<dynamic>?)
            ?.map((t) => t.toString())
            .toList() ??
        [];

    // Date range
    String dateRange = '';
    final startDate = DateTime.tryParse(trip['start_date'] ?? '');
    final endDate = DateTime.tryParse(trip['end_date'] ?? '');
    if (startDate != null) {
      final months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
      dateRange = '${months[startDate.month - 1]} ${startDate.day}';
      if (endDate != null) {
        dateRange += ' - ${months[endDate.month - 1]} ${endDate.day}';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _navigateToTrip(trip),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                if (imageUrl != null && imageUrl.toString().isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey.shade800),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.landscape, color: Colors.white10, size: 48),
                    ),
                  )
                else
                  Container(
                    color: Colors.grey.shade800,
                    child: const Center(
                      child: Icon(Icons.landscape, color: Colors.white10, size: 48),
                    ),
                  ),

                // Cinematic gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.9),
                      ],
                      stops: const [0.0, 0.3, 0.6, 1.0],
                    ),
                  ),
                ),

                // Status badge (top-left, glassmorphism)
                Positioned(
                  top: 14,
                  left: 14,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: statusCol.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: statusCol.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (status == "ONGOING") ...[
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: statusCol,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              status,
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: statusCol,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Date chip (top-right)
                if (dateRange.isNotEmpty)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        dateRange,
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                // Bottom content
                Positioned(
                  left: 20,
                  bottom: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        country.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 1.5,
                        ),
                      ),
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: tags.take(3).map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow indicator (right)
                Positioned(
                  right: 16,
                  bottom: 20,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
