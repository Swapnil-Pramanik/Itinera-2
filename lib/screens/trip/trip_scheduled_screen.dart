import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/trip_service.dart';
import '../../widgets/buttons/buttons.dart';
import '../home/home_screen.dart';
import 'trip_checklist_screen.dart';

/// Trip Scheduled Screen - Upcoming trip with cinematic itinerary view (Dark Theme)
class TripScheduledScreen extends StatefulWidget {
  final String tripId;
  const TripScheduledScreen({super.key, required this.tripId});

  @override
  State<TripScheduledScreen> createState() => _TripScheduledScreenState();
}

class _TripScheduledScreenState extends State<TripScheduledScreen> {
  Map<String, dynamic>? _trip;
  List<Map<String, dynamic>> _itinerary = [];
  List<Map<String, dynamic>> _checklist = [];
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
      final checklistData = await TripService.getChecklist(widget.tripId);

      if (mounted) {
        setState(() {
          _trip = tripData;
          _itinerary = itineraryData;
          _checklist = checklistData;
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
  String get _title => _trip?['destinations']?['name'] ?? _trip?['title'] ?? 'UPCOMING TRIP';
  String get _country => _trip?['destinations']?['country'] ?? '';
  String? get _imageUrl => _trip?['destinations']?['image_url'];
  
  String get _dateRange {
    if (_trip?['start_date'] == null) return '';
    final start = DateTime.tryParse(_trip!['start_date']);
    final end = _trip!['end_date'] != null ? DateTime.tryParse(_trip!['end_date']) : null;
    if (start == null) return '';
    
    final fmt = DateFormat('MMM d');
    if (end == null) return fmt.format(start).toUpperCase();
    return '${fmt.format(start)} - ${fmt.format(end)}'.toUpperCase();
  }

  String get _countdownText {
    if (_trip?['start_date'] == null) return 'READY';
    final start = DateTime.tryParse(_trip!['start_date']);
    if (start == null) return 'READY';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = start.difference(today).inDays;
    
    if (diff == 0) return 'STARTS TODAY';
    if (diff < 0) return 'IN PROGRESS';
    return 'STARTS IN $diff DAYS';
  }

  int get _remainingChecklistItems {
    return _checklist.where((item) => !(item['is_completed'] ?? false)).length;
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
      backgroundColor: const Color(0xFF121212), // Dark Theme Background
      body: CustomScrollView(
        slivers: [
          // Cinematic Header
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            actions: [
              // Improved Status Badge for readability
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E), // Solid darker background for contrast
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.4), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _countdownText,
                      style: const TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                        fontWeight: FontWeight.w800, // Bold for readability
                        color: Colors.greenAccent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                  
                  // Darker Gradient Overlay for Dark Theme
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

                  // Header Content
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              _country.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(color: Colors.white.withOpacity(0.5)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _dateRange,
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  
                  // Pre-trip checklist card - Active
                  _buildChecklistCard(),

                  const SizedBox(height: 32),

                  // Itinerary Section Header
                  Row(
                    children: [
                      const Text(
                        'YOUR ITINERARY',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.auto_awesome, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        'AI OPTIMIZED',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade300,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Build itinerary days
                  if (_itinerary.isEmpty)
                    _buildEmptyItinerary()
                  else
                    ..._itinerary.map((day) => _buildDayItem(day)),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildChecklistCard() {
    final remaining = _remainingChecklistItems;
    final subtitle = remaining == 0 ? 'All steps completed' : '$remaining steps remaining';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripChecklistScreen(tripId: widget.tripId),
          ),
        ).then((_) => _fetchTripData()); // Refresh count when coming back
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05), // Glassy card
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.checklist_rtl_rounded, size: 24, color: Colors.white70),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRE-TRIP CHECKLIST',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyItinerary() {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.event_note_outlined, size: 48, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'NO ITINERARY YET',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(Map<String, dynamic> day) {
    final activities = (day['activities'] as List? ?? []);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day['day_number']}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'RobotoMono',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAY ${day['day_number']}'.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      (day['day_title'] ?? 'Exploring Area').toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...activities.take(3).map((activity) => _buildActivityRow(activity)),
          if (activities.length > 3)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 8),
              child: Text(
                '+ ${activities.length - 3} more activities',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, bottom: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line
            Container(
              width: 1,
              color: Colors.white.withOpacity(0.1),
              margin: const EdgeInsets.only(right: 28),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        activity['time'] ?? '--:--',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (activity['type'] ?? 'VISIT').toUpperCase(),
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: SecondaryButton(
          text: 'BACK TO HOME',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}
