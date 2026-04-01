import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../budget/budget_loading_screen.dart';
import '../../core/trip_service.dart';

/// Timeline Final Preview Screen - Complete multi-day itinerary view
class TimelineFinalPreviewScreen extends StatelessWidget {
  final String tripId;
  final VoidCallback onFinalized;

  const TimelineFinalPreviewScreen({
    super.key,
    required this.tripId,
    required this.onFinalized,
  });

  @override
  Widget build(BuildContext context) {
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
                Text('ALL 7 DAYS PLANNED',
                    style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 10,
                        color: Colors.green.shade800)),
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
            const Text('TOKYO, JAPAN',
                style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 24,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('OCT 14 - OCT 21 • 7 Days',
                style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 14,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            // Day summary cards
            _buildDayCard(
                'DAY 1',
                'Asakusa & Ueno',
                ['Senso-ji Temple', 'Nakamise Street', 'Ueno Park'],
                Icons.temple_buddhist),
            _buildDayCard(
                'DAY 2',
                'Shibuya & Harajuku',
                ['Shibuya Crossing', 'Meiji Shrine', 'Takeshita Street'],
                Icons.location_city),
            _buildDayCard(
                'DAY 3',
                'Shinjuku & Akihabara',
                ['Tokyo Metropolitan Bldg', 'Golden Gai', 'Akihabara'],
                Icons.nightlife),
            _buildDayCard(
                'DAY 4',
                'Odaiba & TeamLab',
                ['Rainbow Bridge', 'TeamLab Borderless', 'Gundam Statue'],
                Icons.museum),
            _buildDayCard('DAY 5', 'Day Trip to Nikko',
                ['Toshogu Shrine', 'Kegon Falls', 'Lake Chuzenji'], Icons.park),
            _buildDayCard(
                'DAY 6',
                'Ginza & Tsukiji',
                ['Tsukiji Outer Market', 'Ginza Shopping', 'Kabuki-za Theatre'],
                Icons.restaurant),
            _buildDayCard(
                'DAY 7',
                'Departure Day',
                [
                  'Souvenir Shopping',
                  'Last-minute sightseeing',
                  'Airport Transfer'
                ],
                Icons.flight),
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
              onFinalized(); // Tell the previous screen we're finalized
              await TripService.updateTrip(tripId, status: 'PLANNED');

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
                Text(activities.join(' • '),
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
