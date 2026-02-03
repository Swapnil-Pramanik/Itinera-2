import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../home/home_screen.dart';
import 'trip_checklist_screen.dart';

/// Trip Scheduled Screen - Upcoming trip with itinerary
class TripScheduledScreen extends StatelessWidget {
  const TripScheduledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header with map
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.grey.shade900,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.green),
                    SizedBox(width: 6),
                    Text(
                      'STARTS IN 4 DAYS',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 10,
                        color: Colors.green,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.grey.shade800,
                child: Stack(
                  children: [
                    // Map placeholder
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                      ),
                      child: CustomPaint(
                        size: const Size(double.infinity, 200),
                        painter: _MapPatternPainter(),
                      ),
                    ),
                    // Overlay content
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOKYO, JAPAN',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'OCT 14 - OCT 21',
                                style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 12,
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
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tip card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: Colors.amber.shade800,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TIP: CHERRY BLOSSOMS ARE IN PEAK BLOOM',
                                style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'We\'ve prioritized outdoor activities in Ueno Park for Day 1 to capture the best views.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber.shade800,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Pre-trip checklist
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TripChecklistScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.checklist, size: 20),
                          const SizedBox(width: 12),
                          const Text(
                            'PRE-TRIP CHECKLIST',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Checklist items preview
                  _buildChecklistPreviewItem('Flights confirmed', true),
                  _buildChecklistPreviewItem('Accommodation booked', true),
                  _buildChecklistPreviewItem('Purchase Suica Card', false),
                  
                  const SizedBox(height: 24),
                  
                  // Confirm plan button
                  const PrimaryButton(
                    text: 'CONFIRM PLAN',
                    showArrow: false,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Edit request
                  Center(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      label: Text(
                        'Ask Itinera to change something...',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Day itinerary
                  _buildDayHeader('10:00', 'Senso-ji Temple', 'SIGHTSEEING',
                      'Tokyo\'s oldest temple. Enter through the Kaminarimon (Thunder Gate) and explore Nakamise street.'),
                  
                  const SizedBox(height: 20),
                  
                  _buildActivityRow('13:00', Icons.park_outlined, 'Ueno Park',
                      'Stroll around Shinobazu Pond. Perfect spot for cherry blossom viewing as per smart alert.',
                      hasTag: true, tagText: 'BLOOM'),
                  
                  const SizedBox(height: 20),
                  
                  _buildActivityRow('17:00', Icons.restaurant_outlined,
                      'Omakase at Sushi Dai', 'Reservation confirmed for 2 pax. 12-course seasonal tasting menu.',
                      tagText: 'DINING'),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom button to go back home
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SecondaryButton(
            text: 'Back to Home',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistPreviewItem(String label, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isChecked ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isChecked ? Colors.black : Colors.grey.shade400,
              ),
            ),
            child: isChecked
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isChecked ? Colors.grey : Colors.black87,
              decoration: isChecked ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(String time, String title, String tag, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            time,
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'SWAP',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'ADJUST',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityRow(String time, IconData icon, String title,
      String description, {bool hasTag = false, String? tagText}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            time,
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (hasTag && tagText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tagText,
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Colors.pink.shade700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'SWAP',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'ADJUST',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
    for (var i = 0; i < size.height; i += 30) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
