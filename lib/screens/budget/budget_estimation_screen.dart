import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/budget_service.dart';
import '../../core/trip_service.dart';
import '../../widgets/buttons/buttons.dart';
import '../home/home_screen.dart';

/// Budget Estimation Screen - AI powered deep budget breakdown
class BudgetEstimationScreen extends StatefulWidget {
  final String tripId;
  final Map<String, dynamic>? preloadedBudget;
  const BudgetEstimationScreen({
    super.key, 
    required this.tripId,
    this.preloadedBudget,
  });

  @override
  State<BudgetEstimationScreen> createState() => _BudgetEstimationScreenState();
}

class _BudgetEstimationScreenState extends State<BudgetEstimationScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _budgetData;
  Map<String, dynamic>? _tripData;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        bool isCollapsed = _scrollController.offset > 200;
        if (isCollapsed != _isCollapsed) {
          setState(() => _isCollapsed = isCollapsed);
        }
      }
    });
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // If preloaded budget is available, use it immediately
    if (widget.preloadedBudget != null) {
      _budgetData = widget.preloadedBudget;
    }
    
    // Fetch trip data for the header/image using dedicated endpoint
    final currentTrip = await TripService.getTripById(widget.tripId);
    
    // Only fetch deep budget insights if not pre-fetched
    final budget = widget.preloadedBudget ?? await BudgetService.getTripBudget(widget.tripId);
    
    if (mounted) {
      setState(() {
        _tripData = currentTrip ?? <String, dynamic>{};
        _budgetData = budget;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get _title => _tripData?['destinations']?['name'] ?? _tripData?['title'] ?? "Your Trip";
  String get _country => _tripData?['destinations']?['country'] ?? "";
  String get _imageUrl => _tripData?['destinations']?['image_url'] ?? "";
  String get _departureCity => _tripData?['departure_city'] ?? "New Delhi";

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              const SizedBox(height: 24),
              const Text(
                'COLLECTING BUDGET DATA',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_budgetData == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent, leading: const BackButton(color: Colors.white)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              const Text('Failed to load budget insights', style: TextStyle(color: Colors.white70)),
              TextButton(onPressed: _loadData, child: const Text('RETRY', style: TextStyle(color: Colors.white))),
            ],
          ),
        ),
      );
    }

    final flight = _budgetData!['flight_estimate'] != null ? Map<String, dynamic>.from(_budgetData!['flight_estimate'] as Map) : <String, dynamic>{};
    final hotels = _budgetData!['hotel_tiers'] != null ? Map<String, dynamic>.from(_budgetData!['hotel_tiers'] as Map) : <String, dynamic>{};
    final activities = _budgetData!['activity_breakdown'] as List? ?? [];
    final daily = _budgetData!['daily_expenses'] != null ? Map<String, dynamic>.from(_budgetData!['daily_expenses'] as Map) : <String, dynamic>{};
    final totalRange = _budgetData!['total_estimated_range'] != null ? Map<String, dynamic>.from(_budgetData!['total_estimated_range'] as Map) : <String, dynamic>{};

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hero Header with Destination Image
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.black,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero Image
                  if (_imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: _imageUrl, 
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey.shade900),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade900,
                        child: const Icon(Icons.landscape, color: Colors.white10, size: 64),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey.shade900,
                      child: const Center(child: Icon(Icons.landscape, color: Colors.white10, size: 64)),
                    ),
                  
                  // Cinematic Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                          Colors.black,
                        ],
                        stops: const [0.0, 0.4, 0.8, 1.0],
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
                          _country.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.5),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _title,
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                          ),
                          child: Text(
                            'EST. ₹${totalRange['min_total'] ?? '??'} - ₹${totalRange['max_total'] ?? '??'}',
                            style: const TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flights Section
                  _buildSectionHeader('ROUND-TRIP FLIGHTS', Icons.flight_takeoff),
                  const SizedBox(height: 12),
                  _buildFlightCard(flight),
                  
                  const SizedBox(height: 32),
                  
                  // Hotels Section
                  _buildSectionHeader('ACCOMMODATION OPTIONS', Icons.hotel_outlined),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildHotelTierCard('3★', hotels['three_star'])),
                      const SizedBox(width: 12),
                      Expanded(child: _buildHotelTierCard('4★', hotels['four_star'], highlight: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildHotelTierCard('5★', hotels['five_star'])),
                    ],
                  ),
                  
                  const SizedBox(height: 32),

                  // Activities Section
                  _buildSectionHeader('MAJOR ACTIVITY SPENDING', Icons.explore_outlined),
                  const SizedBox(height: 12),
                  ...activities.map((a) => _buildActivityExpenseRow(a)).toList(),
                  
                  const SizedBox(height: 32),

                  // Daily Subsistence
                  _buildSectionHeader('DAILY ESTIMATES', Icons.payments_outlined),
                  const SizedBox(height: 12),
                  _buildDailyGrid(daily),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))
          ],
        ),
        child: SafeArea(
          child: PrimaryButton(
            text: 'FINALISE & SAVE TRIP',
            onPressed: () async {
              // Finalize!
              await TripService.updateTrip(widget.tripId, status: 'PLANNED');
              
              if (mounted) {
                // Navigate back to Home
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white38),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white38, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildFlightCard(Map flight) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FROM $_departureCity'.toUpperCase(), style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      flight['description'] ?? 'Standard Economy',
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4), height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${flight['round_trip_min'] ?? '??'}', style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.blueAccent)),
                  const Text('EST. LOWEST', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white24)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.05),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.white.withOpacity(0.3)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Subject to seasonal availability. We recommend booking at least 45 days in advance.',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.3), fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHotelTierCard(String tier, dynamic data, {bool highlight = false}) {
    final perNight = data?['per_night'] ?? '??';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: highlight ? Colors.blueAccent.withOpacity(0.1) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: highlight ? Colors.blueAccent.withOpacity(0.5) : Colors.white10),
      ),
      child: Column(
        children: [
          Text(tier, style: TextStyle(fontFamily: 'RobotoMono', fontSize: 12, fontWeight: FontWeight.w700, color: highlight ? Colors.blueAccent : Colors.white60)),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('₹$perNight', style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const Text('PER NIGHT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white24, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildActivityExpenseRow(dynamic activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity['activity_title'] ?? 'Generic Activity', style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  activity['description'] ?? 'Estimated entrance/fee',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.3), height: 1.4),
                ),
              ],
            ),
          ),
          Text(
            '₹${activity['estimated_cost'] ?? '0'}',
            style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGrid(Map daily) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _buildDailyItem('FOOD', daily['food_per_day'])),
            VerticalDivider(color: Colors.white.withOpacity(0.1), width: 40),
            Expanded(child: _buildDailyItem('TRANSPORT', daily['local_transport_per_day'])),
            VerticalDivider(color: Colors.white.withOpacity(0.1), width: 40),
            Expanded(child: _buildDailyItem('OTHER', daily['total_daily_other'])),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyItem(String label, dynamic amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white24, letterSpacing: 1)),
        const SizedBox(height: 8),
        Text('₹${amount ?? '??'}', style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }
}
