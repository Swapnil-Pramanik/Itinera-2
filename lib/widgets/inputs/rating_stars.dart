import 'package:flutter/material.dart';

/// Interactive Star Rating Widget - Premium animated 1-5 star selector
class RatingStars extends StatefulWidget {
  final int initialRating;
  final Function(int) onRatingChanged;
  final double starSize;
  final bool interactive;
  final MainAxisAlignment alignment;

  const RatingStars({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.starSize = 32.0,
    this.interactive = true,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  void didUpdateWidget(RatingStars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRating != widget.initialRating) {
      setState(() {
        _currentRating = widget.initialRating;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.alignment,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isSelected = starIndex <= _currentRating;

        return GestureDetector(
          onTap: widget.interactive
              ? () {
                  setState(() {
                    _currentRating = starIndex;
                  });
                  widget.onRatingChanged(starIndex);
                  Feedback.forTap(context);
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.8, end: isSelected ? 1.1 : 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isSelected ? Colors.amber : Colors.white12,
                    size: widget.starSize,
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
