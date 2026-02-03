import 'package:flutter/material.dart';

/// Primary filled button with arrow icon
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool showArrow;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.showArrow = true,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                  if (showArrow) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Secondary outlined button
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(text),
          ],
        ),
      ),
    );
  }
}

/// Selectable chip button with optional icon
class ChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const ChipButton({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Social login button (Google, Apple)
class SocialButton extends StatelessWidget {
  final String label;
  final String iconAsset;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.label,
    required this.iconAsset,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Using text icons since we don't have asset images
          Text(
            iconAsset == 'google' ? 'G' : '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: iconAsset == 'google' ? Colors.red : Colors.black,
            ),
          ),
          if (iconAsset == 'apple')
            const Icon(Icons.apple, size: 20, color: Colors.black),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
