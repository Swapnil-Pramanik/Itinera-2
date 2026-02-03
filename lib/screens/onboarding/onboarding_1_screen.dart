import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'onboarding_2_screen.dart';

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Half: Animation + Logo
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              color:
                  Colors.white, // Changed to white to match screen background
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Lottie Animation (Local Asset)
                  Positioned.fill(
                    child: Lottie.asset(
                      'assets/images/world_map_pinging.json',
                      // decoder: LottieComposition.decodeZip, // Removed as it's now JSON
                      fit: BoxFit.cover,
                      repeat: true,
                    ),
                  ),

                  // Logo centered on globe
                  Image.asset(
                    'assets/images/logo_black.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Half: Content
          Expanded(
            flex: 4,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Indicator
                  Text(
                    'STEP 1 OF 4',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  const Text(
                    'WELCOME TO\nITINERA',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.0,
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Your personal travel companion that learns what you love and builds the perfect trip, every time.',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(),

                  // Bottom Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Onboarding2Screen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'CONTINUE',
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
