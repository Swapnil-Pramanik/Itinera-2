import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/cards/cards.dart';
import 'timeline_final_preview_screen.dart';

/// Timeline Update Preview Screen - Shows updated itinerary after editing
class TimelineUpdatePreviewScreen extends StatelessWidget {
  const TimelineUpdatePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            ActivityCard(time: '09:00', title: 'Senso-ji Temple', subtitle: '2.5 hours • Updated', icon: Icons.temple_buddhist, iconColor: Colors.orange),
            const SizedBox(height: 12),
            ActivityCard(time: '11:30', title: 'Nakamise Street', subtitle: 'Adjusted for new schedule', icon: Icons.store, iconColor: Colors.blue),
            const SizedBox(height: 12),
            ActivityCard(time: '13:30', title: 'Lunch at Asakusa', subtitle: 'New: Traditional Japanese', icon: Icons.restaurant, iconColor: Colors.green),
            const SizedBox(height: 12),
            ActivityCard(time: '15:00', title: 'Ueno Park', subtitle: 'Rescheduled', icon: Icons.park, iconColor: Colors.teal),
            const SizedBox(height: 12),
            ActivityCard(time: '18:00', title: 'Shibuya Crossing', subtitle: 'Evening visit as planned', icon: Icons.location_city, iconColor: Colors.purple),
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TimelineFinalPreviewScreen()));
            },
          ),
        ),
      ),
    );
  }
}
