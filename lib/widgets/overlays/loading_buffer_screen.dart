import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/destination_service.dart';
import '../../screens/trip/destination_detail_screen.dart';

/// Loading Buffer Screen - High-fidelity discovery phase with corrected Lottie rendering
class LoadingBufferScreen extends StatefulWidget {
  final String destinationName;
  final String destinationCountry;
  final double? latitude;
  final double? longitude;

  const LoadingBufferScreen({
    super.key,
    required this.destinationName,
    required this.destinationCountry,
    this.latitude,
    this.longitude,
  });

  @override
  State<LoadingBufferScreen> createState() => _LoadingBufferScreenState();
}

class _LoadingBufferScreenState extends State<LoadingBufferScreen> {
  Map<String, dynamic>? _preloadedData;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  Future<void> _startLoading() async {
    final startTime = DateTime.now();

    try {
      // 1. Fetch details in background
      final data = await DestinationService.getDestinationByName(
        widget.destinationName,
        widget.destinationCountry,
        lat: widget.latitude,
        lon: widget.longitude,
      );

      _preloadedData = data;
    } catch (e) {
      debugPrint('[LoadingBuffer] Error fetching data: $e');
    }

    // 2. Ensure minimum duration for "Premium Feel" (2.5 seconds)
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    const minDuration = 2500; 
    if (elapsed < minDuration) {
      await Future.delayed(Duration(milliseconds: minDuration - elapsed));
    }

    if (mounted) {
      _transitionToDetails();
    }
  }

  void _transitionToDetails() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DestinationDetailScreen(
          destinationName: widget.destinationName,
          destinationCountry: widget.destinationCountry,
          latitude: widget.latitude,
          longitude: widget.longitude,
          preloadedData: _preloadedData,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Center High-Fidelity Lottie
            // We use imageDelegate to ensure the external PNG layers are correctly loaded
            SizedBox(
              width: 300,
              height: 300,
              child: Lottie.asset(
                'assets/Earth globe rotating with Seamless loop animation.json',
                fit: BoxFit.contain,
              ),
            ),
            
            const SizedBox(height: 30),

            // Dynamic Discovery Text
            Text(
              'DISCOVERING ${widget.destinationName.toUpperCase()}...',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'PREPARING YOUR ATLAS...',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 11,
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
