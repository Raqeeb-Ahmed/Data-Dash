import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated World Map Background widget with automatic Light & Dark mode adaptation.
/// Features:
/// - Light & Dark theme responsive styling.
/// - Vector world map continent silhouettes with animated glowing line shaders.
/// - Interactive ambient light spheres that react to mouse/touch movement.
class AnimatedWorldMapBackground extends StatefulWidget {
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
  State<AnimatedWorldMapBackground> createState() =>
      _AnimatedWorldMapBackgroundState();
}

class _AnimatedWorldMapBackgroundState extends State<AnimatedWorldMapBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _pointerOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerMove(Offset localPosition, Size size) {
    if (size.width == 0 || size.height == 0) return;
    setState(() {
      _pointerOffset = Offset(
        (localPosition.dx / size.width) * 2 - 1.0,
        (localPosition.dy / size.height) * 2 - 1.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Theme-dependent colors
    final baseBgColor = widget.backgroundColor ??
        (isDarkMode ? const Color(0xFF07090E) : const Color(0xFFF1F5F9));

    final glow1Colors = isDarkMode
        ? const [Color(0x403B0764), Color(0x201E1B4B), Colors.transparent]
        : const [Color(0x30C084FC), Color(0x15A855F7), Colors.transparent];

    final glow2Colors = isDarkMode
        ? const [Color(0x351E293B), Color(0x184F46E5), Colors.transparent]
        : const [Color(0x3038BDF8), Color(0x150284C7), Colors.transparent];

    final vignetteColors = isDarkMode
        ? const [Colors.transparent, Color(0x6007090E), Color(0xFF07090E)]
        : const [Colors.transparent, Color(0x40F1F5F9), Color(0xFFF1F5F9)];

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return MouseRegion(
          onHover: (event) => _onPointerMove(event.localPosition, size),
          child: Listener(
            onPointerMove: (event) => _onPointerMove(event.localPosition, size),
            child: Stack(
              children: [
                // 1. Base Canvas Background (Light/Dark Theme adapt)
                Container(
                  color: baseBgColor,
                  width: double.infinity,
                  height: double.infinity,
                ),

                // 2. Ambient Light Spheres (Interactive)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final pulse =
                        math.sin(_controller.value * 2 * math.pi) * 0.08 + 0.92;
                    return Stack(
                      children: [
                        // Glow 1
                        Positioned(
                          top: -size.height * 0.15 + (_pointerOffset.dy * -15),
                          left: size.width * 0.25 + (_pointerOffset.dx * -15),
                          child: Transform.scale(
                            scale: pulse,
                            child: Container(
                              width: size.width * 0.5,
                              height: size.height * 0.5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: glow1Colors,
                                  stops: const [0.0, 0.55, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Glow 2
                        Positioned(
                          top: size.height * 0.15 + (_pointerOffset.dy * -20),
                          right: size.width * 0.05 + (_pointerOffset.dx * -20),
                          child: Transform.scale(
                            scale: 2.0 - pulse,
                            child: Container(
                              width: size.width * 0.45,
                              height: size.height * 0.55,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: glow2Colors,
                                  stops: const [0.0, 0.6, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // 3. Vector World Map Graphic Layer
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(
                      _pointerOffset.dx * -8,
                      _pointerOffset.dy * -8,
                    ),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: DetailedWorldMapPainter(
                            progress: _controller.value,
                            isDarkMode: isDarkMode,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 4. Subtle Vignette Overlay
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.15,
                        colors: vignetteColors,
                        stops: const [0.35, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),

                // 5. Child Content
                if (widget.child != null) Positioned.fill(child: widget.child!),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// CustomPainter rendering continent vector paths & glowing border outlines adapted to light/dark themes.
class DetailedWorldMapPainter extends CustomPainter {
  final double progress;
  final bool isDarkMode;

  DetailedWorldMapPainter({
    required this.progress,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Rect rect = Rect.fromLTWH(0, 0, w, h);

    final shaderColors = isDarkMode
        ? const [
            Color(0x663B82F6),
            Color(0x998B5CF6),
            Color(0x662DD4BF),
            Color(0x663B82F6),
          ]
        : const [
            Color(0x884F46E5),
            Color(0xAA7C3AED),
            Color(0x880284C7),
            Color(0x884F46E5),
          ];

    final fillPaintColor = isDarkMode ? const Color(0x2E1E294B) : const Color(0x1864748B);
    final borderPaintColor = isDarkMode ? const Color(0x35384674) : const Color(0x3094A3B8);
    final gridLineColor = isDarkMode ? const Color(0x0CFFFFFF) : const Color(0x15000000);
    final dotColor = isDarkMode ? const Color(0x3B8B5CF6) : const Color(0x406366F1);

    // Multi-color glowing outline shader
    final Paint outlineShaderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1.0 + (progress * 2), -0.5),
        end: Alignment(1.0 + (progress * 2), 0.5),
        colors: shaderColors,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final Paint fillPaint = Paint()
      ..color = fillPaintColor
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = borderPaintColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Build Detailed World Map Paths
    final Path mapPath = Path();

    // 1. North America
    final Path na = Path()
      ..moveTo(w * 0.06, h * 0.12)
      ..cubicTo(w * 0.12, h * 0.05, w * 0.28, h * 0.06, w * 0.32, h * 0.14)
      ..cubicTo(w * 0.35, h * 0.20, w * 0.30, h * 0.28, w * 0.25, h * 0.34)
      ..lineTo(w * 0.22, h * 0.42)
      ..cubicTo(w * 0.18, h * 0.46, w * 0.15, h * 0.42, w * 0.14, h * 0.36)
      ..cubicTo(w * 0.11, h * 0.30, w * 0.04, h * 0.20, w * 0.06, h * 0.12)
      ..close();
    mapPath.addPath(na, Offset.zero);

    // 2. Greenland
    final Path greenland = Path()
      ..moveTo(w * 0.34, h * 0.05)
      ..cubicTo(w * 0.38, h * 0.03, w * 0.43, h * 0.04, w * 0.44, h * 0.10)
      ..cubicTo(w * 0.42, h * 0.15, w * 0.36, h * 0.14, w * 0.34, h * 0.09)
      ..close();
    mapPath.addPath(greenland, Offset.zero);

    // 3. South America
    final Path sa = Path()
      ..moveTo(w * 0.24, h * 0.46)
      ..cubicTo(w * 0.30, h * 0.48, w * 0.34, h * 0.56, w * 0.30, h * 0.68)
      ..cubicTo(w * 0.27, h * 0.78, w * 0.24, h * 0.85, w * 0.22, h * 0.82)
      ..cubicTo(w * 0.20, h * 0.75, w * 0.21, h * 0.58, w * 0.24, h * 0.46)
      ..close();
    mapPath.addPath(sa, Offset.zero);

    // 4. Europe
    final Path europe = Path()
      ..moveTo(w * 0.46, h * 0.12)
      ..cubicTo(w * 0.52, h * 0.10, w * 0.58, h * 0.14, w * 0.56, h * 0.24)
      ..cubicTo(w * 0.52, h * 0.28, w * 0.45, h * 0.27, w * 0.44, h * 0.20)
      ..close();
    mapPath.addPath(europe, Offset.zero);

    // 5. Africa
    final Path africa = Path()
      ..moveTo(w * 0.44, h * 0.30)
      ..cubicTo(w * 0.52, h * 0.28, w * 0.60, h * 0.35, w * 0.58, h * 0.48)
      ..cubicTo(w * 0.56, h * 0.62, w * 0.52, h * 0.72, w * 0.48, h * 0.70)
      ..cubicTo(w * 0.44, h * 0.62, w * 0.42, h * 0.42, w * 0.44, h * 0.30)
      ..close();
    mapPath.addPath(africa, Offset.zero);

    // 6. Asia
    final Path asia = Path()
      ..moveTo(w * 0.58, h * 0.12)
      ..cubicTo(w * 0.72, h * 0.08, w * 0.90, h * 0.12, w * 0.94, h * 0.24)
      ..cubicTo(w * 0.96, h * 0.34, w * 0.85, h * 0.45, w * 0.72, h * 0.44)
      ..cubicTo(w * 0.66, h * 0.42, w * 0.60, h * 0.32, w * 0.58, h * 0.22)
      ..close();
    mapPath.addPath(asia, Offset.zero);

    // 7. Australia & Indonesia
    final Path australia = Path()
      ..moveTo(w * 0.76, h * 0.55)
      ..cubicTo(w * 0.84, h * 0.52, w * 0.92, h * 0.58, w * 0.90, h * 0.70)
      ..cubicTo(w * 0.86, h * 0.76, w * 0.78, h * 0.74, w * 0.75, h * 0.65)
      ..close();
    mapPath.addPath(australia, Offset.zero);

    // Draw Map
    canvas.drawPath(mapPath, fillPaint);
    canvas.drawPath(mapPath, borderPaint);
    canvas.drawPath(mapPath, outlineShaderPaint);

    // Tech Dots inside Map
    final Paint dotsPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    const double step = 16.0;
    for (double x = 0; x < w; x += step) {
      for (double y = 0; y < h; y += step) {
        if (mapPath.contains(Offset(x, y))) {
          final pulse = math.sin((x + y + progress * 120) * 0.04) * 0.5 + 1.6;
          canvas.drawCircle(Offset(x, y), pulse, dotsPaint);
        }
      }
    }

    // Grid lines
    final Paint gridLinePaint = Paint()
      ..color = gridLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int i = 1; i <= 5; i++) {
      final double y = h * (i / 6);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridLinePaint);
    }
    for (int i = 1; i <= 8; i++) {
      final double x = w * (i / 9);
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridLinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant DetailedWorldMapPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDarkMode != isDarkMode;
  }
}
