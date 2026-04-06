import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';

/// Trip card for horizontal scrolling in home screen
class TripCard extends StatelessWidget {
  final String destination;
  final String country;
  final List<String> tags;
  final String? imageUrl;
  final String? statusLabel;
  final VoidCallback? onTap;

  const TripCard({
    super.key,
    required this.destination,
    required this.country,
    this.tags = const [],
    this.imageUrl,
    this.statusLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOngoing = statusLabel?.toUpperCase() == "ONGOING";
    final String displayStatus = statusLabel?.toUpperCase() ?? "UPCOMING";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              if (imageUrl != null && imageUrl!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey.shade200),
                  errorWidget: (context, url, error) => _buildFallbackMap(),
                )
              else
                _buildFallbackMap(),

              // Cinematic Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),

              // Top Left Status Chip (Glassmorphism)
              Positioned(
                top: 14,
                left: 14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isOngoing 
                            ? Colors.blueAccent.withOpacity(0.8) 
                            : Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isOngoing 
                              ? Colors.blueAccent.withOpacity(0.4) 
                              : Colors.white.withOpacity(0.1),
                        ),
                        boxShadow: isOngoing ? [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ] : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isOngoing) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            displayStatus,
                            style: const TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Content
              Positioned(
                left: 20,
                bottom: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      destination,
                      style: const TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      country.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 1,
                      ),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: tags.take(2).map((tag) => _buildGlassTag(tag)).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFallbackMap() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
      ),
      child: CustomPaint(
        size: const Size(240, 180),
        painter: _MapPatternPainter(),
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

/// Atlas destination card for vertical and horizontal lists
class AtlasCard extends StatelessWidget {
  final String title;
  final String description;
  final String? duration;
  final String? imageUrl;
  final double? rating;
  final List<String> tags;
  final VoidCallback? onTap;
  final VoidCallback? onPlanTap;

  const AtlasCard({
    super.key,
    required this.title,
    required this.description,
    this.duration,
    this.imageUrl,
    this.rating,
    this.tags = const [],
    this.onTap,
    this.onPlanTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              if (imageUrl != null && imageUrl!.isNotEmpty)
                Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                )
              else
                _buildPlaceholder(),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),

              // Top Left Rating Chip
              if (rating != null)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),

              // Top Right Duration/Cost Chip
              if (duration != null)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      duration!,
                      style: const TextStyle(
                        fontFamily: 'RobotoMono',
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

              // Bottom Content
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.4,
                      ),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.map((t) => _buildBlurTag(t)).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlurTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'RobotoMono',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(Icons.landscape, size: 48, color: Colors.white24),
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
  final double? durationHours;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const ActivityCard({
    super.key,
    required this.time,
    required this.title,
    this.subtitle,
    this.durationHours,
    this.icon = Icons.place,
    this.iconColor,
    this.hasAlert = false,
    this.alertText,
    this.onTap,
    this.onEdit,
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
                      if (durationHours != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${durationHours!.toStringAsFixed(1)} hrs',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: iconColor ?? Colors.blue,
                          ),
                        ),
                      ],
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
                if (onEdit != null) ...[
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade400),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ],
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

/// Transport connector card for gapless transitions
class TransportConnectorCard extends StatelessWidget {
  final String time;
  final String mode; // WALK, TRANSIT, TAXI
  final double durationHours;
  final double? priceDelta;
  final String currencySymbol;

  const TransportConnectorCard({
    super.key,
    required this.time,
    required this.mode,
    required this.durationHours,
    this.priceDelta,
    this.currencySymbol = '₹',
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    String label;

    switch (mode) {
      case 'WALK':
        icon = Icons.directions_walk;
        iconColor = Colors.grey.shade600;
        label = 'Walk';
        break;
      case 'TRAIN':
      case 'TRANSIT':
        icon = Icons.train_outlined;
        iconColor = Colors.blue.shade600;
        label = 'Public Transport';
        break;
      case 'TAXI':
        icon = Icons.local_taxi_outlined;
        iconColor = Colors.orange.shade700;
        label = 'Taxi';
        break;
      default:
        icon = Icons.directions_bus_outlined;
        iconColor = Colors.blue.shade600;
        label = 'Transport';
    }

    final durationMin = (durationHours * 60).round();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 50,
            child: Text(
              time,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Connection visual
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Colors.blue.shade900.withOpacity(0.8),
                  ),
                ),
                Text(
                  '$durationMin min${priceDelta != null && priceDelta! != 0 ? ' • $currencySymbol${priceDelta!.abs().toStringAsFixed(0)}' : ''}',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Right indicator
          Icon(Icons.unfold_more, size: 16, color: Colors.blue.shade200),
        ],
      ),
    );
  }
}
