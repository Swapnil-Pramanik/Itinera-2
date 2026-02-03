import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/cards/cards.dart';

/// Trip Completed Screen - Past trip summary
class TripCompletedScreen extends StatelessWidget {
  const TripCompletedScreen({super.key});

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
        title: const Text(
          'Itinera',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Completed badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 14, color: Colors.green.shade800),
                  const SizedBox(width: 6),
                  Text(
                    'COMPLETED',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'KYOTO, JAPAN',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'OCT 12 - OCT 18',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Expanded(child: _buildStatItem('24', 'PLACES\nVISITED')),
                  Container(width: 1, height: 50, color: Colors.grey.shade300),
                  Expanded(child: _buildStatItem('36', 'ACTIVITIES\nDONE')),
                  Container(width: 1, height: 50, color: Colors.grey.shade300),
                  Expanded(child: _buildStatItem('7', 'DAYS\nCOVERED')),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const DaySummaryCard(
              dayNumber: 'D1',
              date: 'OCT 12',
              title: 'ARRIVAL',
              highlights: ['Landed at KIX Airport', 'Check-in at Ryokan'],
            ),
            const DaySummaryCard(
              dayNumber: 'D2',
              date: 'OCT 13',
              title: 'TEMPLES',
              highlights: ['Visited Golden Pavilion', 'Ryoan-ji Rock Garden'],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PrimaryButton(
                text: 'SHARE ITINERARY',
                icon: Icons.share,
                showArrow: false,
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'RobotoMono', fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}
