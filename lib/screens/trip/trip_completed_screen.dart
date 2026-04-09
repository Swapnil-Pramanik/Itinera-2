import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/trip_service.dart';
import '../../widgets/buttons/buttons.dart';

/// Trip Completed Screen - Nostalgic trip summary (Dark Theme)
class TripCompletedScreen extends StatefulWidget {
  final String tripId;
  const TripCompletedScreen({super.key, required this.tripId});

  @override
  State<TripCompletedScreen> createState() => _TripCompletedScreenState();
}

class _TripCompletedScreenState extends State<TripCompletedScreen> {
  Map<String, dynamic>? _trip;
  List<Map<String, dynamic>> _itinerary = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTripData();
  }

  Future<void> _fetchTripData() async {
    try {
      final tripData = await TripService.getTripById(widget.tripId);
      final itineraryData = await TripService.getTripDays(widget.tripId);

      if (mounted) {
        setState(() {
          _trip = tripData;
          _itinerary = itineraryData;
          _isLoading = false;
          if (_trip == null) _error = 'Trip not found';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load trip: $e';
        });
      }
    }
  }

  // Helpers
  String get _title => _trip?['destinations']?['name'] ?? _trip?['title'] ?? 'PAST TRIP';
  String? get _imageUrl => _trip?['destinations']?['image_url'];

  String get _dateRange {
    if (_trip?['start_date'] == null) return '';
    final start = DateTime.tryParse(_trip!['start_date']);
    final end = _trip!['end_date'] != null ? DateTime.tryParse(_trip!['end_date']) : null;
    if (start == null) return '';
    
    final fmt = DateFormat('MMM d, yyyy');
    if (end == null) return fmt.format(start).toUpperCase();
    return '${fmt.format(start)} - ${fmt.format(end)}'.toUpperCase();
  }

  int get _totalActivities {
    int count = 0;
    for (var day in _itinerary) {
      count += (day['activities'] as List? ?? []).length;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              PrimaryButton(text: 'RETRY', onPressed: _fetchTripData),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          // Cinematic Header
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (_imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: _imageUrl!,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(color: Colors.grey.shade900),
                  
                  // Black & White / Nostalgic overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          const Color(0xFF121212),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),

                  // Completed Badge
                  Positioned(
                    top: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.greenAccent),
                            SizedBox(width: 8),
                            Text(
                              'TRIP COMPLETED',
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Header Content
                  Positioned(
                    bottom: 60,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _title.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _dateRange,
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('${_itinerary.length}', 'DAYS'),
                      _buildStatItem('$_totalActivities', 'PLACES'),
                      _buildStatItem('1.2K', 'KM'),
                    ],
                  ),

                  const SizedBox(height: 48),

                  Text(
                    'MEMORIES & HIGHLIGHTS',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.4),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Memory Cards
                  if (_itinerary.isNotEmpty)
                    ..._itinerary.take(3).map((day) => _buildMemoryCard(day))
                  else
                    const Text('No memories recorded.', style: TextStyle(color: Colors.white24)),

                  const SizedBox(height: 40),

                  PrimaryButton(
                    text: 'SHARE ITINERARY',
                    onPressed: () {},
                    icon: Icons.share_outlined,
                  ),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    text: 'PLAN AGAIN',
                    onPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 10,
            color: Colors.white.withOpacity(0.4),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryCard(Map<String, dynamic> day) {
    final activities = (day['activities'] as List? ?? []);
    final highlights = activities.take(2).map((a) => a['title'] as String).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'D${day['day_number']}',
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'RobotoMono',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (day['day_title'] ?? 'Exploring').toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ...highlights.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 10, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          h,
                          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
