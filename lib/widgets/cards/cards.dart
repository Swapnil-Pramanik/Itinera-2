import 'package:flutter/material.dart';

/// Trip card for horizontal scrolling in home screen
class TripCard extends StatelessWidget {
  final String destination;
  final String country;
  final List<String> tags;
  final VoidCallback? onTap;

  const TripCard({
    super.key,
    required this.destination,
    required this.country,
    this.tags = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Map placeholder background
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                child: CustomPaint(
                  size: const Size(180, 140),
                  painter: _MapPatternPainter(),
                ),
              ),
            ),
            // Content overlay
            Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$destination, $country',
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: tags.map((tag) => _buildTag(tag)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
    );
  }
}

/// Simple map pattern painter
class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw grid lines to simulate map
    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
    for (var i = 0; i < size.height; i += 20) {
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

/// Atlas destination card for vertical list
class AtlasCard extends StatelessWidget {
  final String title;
  final String description;
  final String? duration;
  final VoidCallback? onTap;
  final VoidCallback? onPlanTap;

  const AtlasCard({
    super.key,
    required this.title,
    required this.description,
    this.duration,
    this.onTap,
    this.onPlanTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.landscape,
                  size: 32,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (duration != null) ...[
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          duration!,
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const Spacer(),
                      ],
                      TextButton.icon(
                        onPressed: onPlanTap,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('PLAN'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
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
    );
  }
}

/// Activity card for timeline
class ActivityCard extends StatelessWidget {
  final String time;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final bool hasAlert;
  final String? alertText;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.time,
    required this.title,
    this.subtitle,
    this.icon = Icons.place,
    this.iconColor,
    this.hasAlert = false,
    this.alertText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: hasAlert 
              ? Border.all(color: Colors.orange.shade200, width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasAlert && alertText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alertText!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time
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
                const SizedBox(width: 12),
                // Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (iconColor ?? Colors.blue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: iconColor ?? Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
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
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Menu
                Icon(
                  Icons.more_horiz,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Day summary card for trip completed view
class DaySummaryCard extends StatelessWidget {
  final String dayNumber;
  final String date;
  final String title;
  final List<String> highlights;
  final String? quote;

  const DaySummaryCard({
    super.key,
    required this.dayNumber,
    required this.date,
    required this.title,
    this.highlights = const [],
    this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    dayNumber,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Container(
                width: 2,
                height: 80,
                color: Colors.grey.shade200,
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$date • $title',
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...highlights.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Text(
                          h,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                if (quote != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.format_quote,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            quote!,
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
