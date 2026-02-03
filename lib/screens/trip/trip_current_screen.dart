import 'package:flutter/material.dart';
import '../../widgets/common/common.dart';

/// Trip Current Screen - Active/ongoing trip view
class TripCurrentScreen extends StatelessWidget {
  const TripCurrentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Text(
              'Itinera',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Icon(Icons.wb_sunny_outlined, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '22°C',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: Colors.black87),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location
                  Row(
                    children: [
                      Icon(Icons.place, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'KYOTO, JAPAN',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Today • Day 3
                  const Text(
                    'Today • Day 3',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Current activity indicator
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'CURRENT ACTIVITY',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '09:00 - 11:00',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Map with current location
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Map pattern
                  CustomPaint(
                    size: const Size(double.infinity, 200),
                    painter: _MapPatternPainter(),
                  ),
                  // Location title
                  Positioned(
                    left: 16,
                    bottom: 50,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KINKAKU-JI',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'TEMPLE',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.navigation_outlined, size: 18),
                      label: const Text('NAVIGATE'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('MARK DONE'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            
            // Coming up section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'COMING UP',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Upcoming activities
            _buildUpcomingActivity(
              'RYOAN-JI',
              'Zen rock garden',
              '11:30',
            ),
            
            _buildUpcomingActivity(
              'NISHIKI MARKET',
              'Kyoto\'s Kitchen',
              '13:00',
            ),
            
            const SizedBox(height: 24),
            
            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildQuickAction('RUNNING LATE'),
                  _buildQuickAction('FIND FOOD NEARBY'),
                  _buildQuickAction('SKIP THIS'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // AI input bar
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AiInputBar(
                hintText: 'ASK ITINERA...',
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingActivity(String title, String subtitle, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
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
                        'SKIP',
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
                        'DELAY 30M',
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
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < size.width; i += 25) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
    for (var i = 0; i < size.height; i += 25) {
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
