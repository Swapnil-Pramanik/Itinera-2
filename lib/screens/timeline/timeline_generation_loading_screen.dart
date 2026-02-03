import 'package:flutter/material.dart';
import 'timeline_initial_preview_screen.dart';

/// Timeline Generation Loading Screen
class TimelineGenerationLoadingScreen extends StatefulWidget {
  const TimelineGenerationLoadingScreen({super.key});

  @override
  State<TimelineGenerationLoadingScreen> createState() => _TimelineGenerationLoadingScreenState();
}

class _TimelineGenerationLoadingScreenState extends State<TimelineGenerationLoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate generation delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TimelineInitialPreviewScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
