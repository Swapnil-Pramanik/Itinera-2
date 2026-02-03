import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/cards/cards.dart';
import 'timeline_editor_screen.dart';
import 'timeline_final_preview_screen.dart';

/// Timeline Initial Preview Screen - First generated itinerary view
class TimelineInitialPreviewScreen extends StatelessWidget {
  const TimelineInitialPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const Text('YOUR TOKYO\nITINERARY', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 24, fontWeight: FontWeight.w700, height: 1.2)),
            const SizedBox(height: 8),
            Text('Generating 7 days of adventure', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            // Day tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDayTab('DAY 1', true),
                  _buildDayTab('DAY 2', false),
                  _buildDayTab('DAY 3', false),
                  _buildDayTab('DAY 4', false),
                  _buildDayTab('DAY 5', false),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Activities
            ActivityCard(time: '09:00', title: 'Senso-ji Temple', subtitle: 'Explore Tokyo\'s oldest temple', icon: Icons.temple_buddhist, iconColor: Colors.orange),
            const SizedBox(height: 12),
            ActivityCard(time: '12:00', title: 'Nakamise Street', subtitle: 'Traditional shopping district', icon: Icons.store, iconColor: Colors.blue),
            const SizedBox(height: 12),
            ActivityCard(time: '14:00', title: 'Ueno Park', subtitle: 'Relaxing afternoon stroll', icon: Icons.park, iconColor: Colors.green),
            const SizedBox(height: 12),
            ActivityCard(time: '18:00', title: 'Shibuya Crossing', subtitle: 'Iconic scramble intersection', icon: Icons.location_city, iconColor: Colors.purple),
            const SizedBox(height: 12),
            ActivityCard(time: '20:00', title: 'Dinner at Ichiran', subtitle: 'Famous ramen experience', icon: Icons.restaurant, iconColor: Colors.red),
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TimelineEditorScreen()));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: 'Complete',
                  showArrow: false,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TimelineFinalPreviewScreen()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayTab(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontFamily: 'RobotoMono', fontSize: 12, fontWeight: FontWeight.w500, color: isActive ? Colors.white : Colors.grey.shade700)),
    );
  }
}
