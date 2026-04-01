import 'package:flutter/material.dart';
import 'timeline_initial_preview_screen.dart';
import '../../core/trip_service.dart';

/// Timeline Generation Loading Screen
class TimelineGenerationLoadingScreen extends StatefulWidget {
  final String tripId;
  const TimelineGenerationLoadingScreen({super.key, required this.tripId});

  @override
  State<TimelineGenerationLoadingScreen> createState() => _TimelineGenerationLoadingScreenState();
}

class _TimelineGenerationLoadingScreenState extends State<TimelineGenerationLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  Future<void> _startGeneration() async {
    final success = await TripService.generateItinerary(widget.tripId);
    
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TimelineInitialPreviewScreen(
            tripId: widget.tripId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generation failed. Please try again.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Rollback: Delete the draft trip
          TripService.deleteTrip(widget.tripId);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Compass icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.explore,
                  size: 40,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'GENERATING YOUR\nITINERARY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'OPTIMIZING ROUTES...',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
