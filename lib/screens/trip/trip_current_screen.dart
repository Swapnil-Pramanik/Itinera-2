import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/trip_service.dart';
import '../../widgets/common/common.dart';
import '../../widgets/buttons/buttons.dart';

/// Trip Current Screen - Active trip dashboard with "Now" focus (Dark Theme)
class TripCurrentScreen extends StatefulWidget {
  final String tripId;
  const TripCurrentScreen({super.key, required this.tripId});

  @override
  State<TripCurrentScreen> createState() => _TripCurrentScreenState();
}

class _TripCurrentScreenState extends State<TripCurrentScreen> {
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
  String get _title => _trip?['destinations']?['name'] ?? _trip?['title'] ?? 'CURRENT TRIP';
  String get _country => _trip?['destinations']?['country'] ?? '';
  String? get _imageUrl => _trip?['destinations']?['image_url'];

  int get _currentDayNumber {
    if (_trip?['start_date'] == null) return 1;
    final start = DateTime.tryParse(_trip!['start_date']);
    if (start == null) return 1;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(start).inDays;
    return (diff + 1).clamp(1, _itinerary.length.clamp(1, 100));
  }

  Map<String, dynamic>? get _currentDayData {
    if (_itinerary.isEmpty) return null;
    final dayNum = _currentDayNumber;
    return _itinerary.firstWhere(
      (d) => d['day_number'] == dayNum,
      orElse: () => _itinerary.first,
    );
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

    final dayData = _currentDayData;
    final activities = (dayData?['activities'] as List? ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          // Cinematic Header
          SliverAppBar(
            expandedHeight: 280,
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
                  
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                          const Color(0xFF121212),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Text(
                              '$_title, $_country'.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'DAY $_currentDayNumber: ${dayData?['day_title'] ?? 'EXPLORATION'}',
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicators
                  Row(
                    children: [
                      _buildStatusPulse(),
                      const SizedBox(width: 8),
                      const Text(
                        'LIVE UPDATES',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.wb_sunny_outlined, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      const Text(
                        '24°C',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Map Placeholder (Dark style)
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(Icons.map_outlined, size: 40, color: Colors.white24),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: PrimaryButton(
                            text: 'OPEN MAPS',
                            onPressed: () {},
                            showArrow: false,
                            width: 140,
                            height: 44,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Timeline Section
                  Text(
                    'COMING UP NEXT',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.4),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (activities.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text('Relax and enjoy the day!', style: TextStyle(color: Colors.white.withOpacity(0.3))),
                    )
                  else
                    ...activities.map((act) => _buildLiveActivityCard(act)),

                  const SizedBox(height: 24),

                  // AI Input - The common AiInputBar already has some white background, but I'll make it fit
                  const AiInputBar(hintText: 'Ask Itinera to find food nearby...'),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPulse() {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.redAccent, blurRadius: 4, spreadRadius: 1),
        ],
      ),
    );
  }

  Widget _buildLiveActivityCard(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                activity['time'] ?? 'NOW',
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Icon(Icons.arrow_downward, size: 12, color: Colors.white.withOpacity(0.3)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (activity['type'] ?? 'VISIT').toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent.shade100,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity['title'] ?? 'Activity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['description'] ?? 'Enjoy your time here.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.check_circle_outline, color: Colors.white.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }
}
