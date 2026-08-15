import 'package:flutter/material.dart';

/// Clean background widget that provides a solid/simple background color,
/// automatically adapting to Light & Dark themes.
class AnimatedWorldMapBackground extends StatelessWidget {
  final Widget? child;
  final String? watermarkText;
  final Color? backgroundColor;

  const AnimatedWorldMapBackground({
    super.key,
    this.child,
    this.watermarkText,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseBgColor = backgroundColor ??
        (isDarkMode ? const Color(0xFF070B13) : Colors.grey[50]!);

    return Container(
      color: baseBgColor,
      width: double.infinity,
      height: double.infinity,
      child: child,
    );
  }
}
