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

class _LoadingBufferScreenState extends State<LoadingBufferScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? _preloadedData;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  int _currentLabelIndex = 0;
  final List<String> _loadingLabels = [
    'CONSULTING LOCAL AI EXPERTS...',
    'CURATING SEASONAL ATTRACTIONS...',
    'CALCULATING BUDGET BENCHMARKS...',
    'OPTIMIZING YOUR TRAVEL ATLAS...',
    'STITCHING DESTINATION INSIGHTS...',
  ];

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40), // Typical max AI time
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 0.92).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _progressController.forward();
    _rotateLabels();
    _startLoading();
  }

  void _rotateLabels() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          _currentLabelIndex = (_currentLabelIndex + 1) % _loadingLabels.length;
        });
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _startLoading() async {
    try {
      // 1. Fetch details in background
      final data = await DestinationService.getDestinationByName(
        widget.destinationName,
        widget.destinationCountry,
        lat: widget.latitude,
        lon: widget.longitude,
      );

      _preloadedData = data;
      
      // Snap progress to completion
      if (mounted) {
        _progressController.animateTo(1.0, duration: const Duration(milliseconds: 500));
      }
    } catch (e) {
      debugPrint('[LoadingBuffer] Error fetching data: $e');
    }

    // 2. Minimum wait for cinematic effect AND progress snap
    await Future.delayed(const Duration(milliseconds: 800));

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
            
            const SizedBox(height: 48),

            // Progress Bar Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _progressAnimation.value,
                              backgroundColor: Colors.white.withOpacity(0.05),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(_progressAnimation.value * 100).toInt()}%',
                                style: const TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 10,
                                  color: Colors.white38,
                                ),
                              ),
                              Text(
                                'EST. ${40 - (40 * _progressAnimation.value).toInt()}s REMAINING',
                                style: const TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 10,
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Animated Label
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _loadingLabels[_currentLabelIndex],
                      key: ValueKey(_currentLabelIndex),
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
