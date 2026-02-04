import 'dart:ui';
import 'package:flutter/material.dart';

/// Custom page route with blur transition effect
class BlurPageRoute extends PageRouteBuilder {
  final Widget page;

  BlurPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade animation
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            );

            // Blur animation (blur reduces as page appears)
            final blurAnimation = Tween<double>(
              begin: 8.0,
              end: 0.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            );

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: blurAnimation.value,
                    sigmaY: blurAnimation.value,
                  ),
                  child: Opacity(
                    opacity: fadeAnimation.value,
                    child: child,
                  ),
                );
              },
              child: child,
            );
          },
        );
}
