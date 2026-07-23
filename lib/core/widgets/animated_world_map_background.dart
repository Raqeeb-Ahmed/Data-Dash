import 'dart:math' as math;
import 'package:flutter/material.dart';

/// World map background replicating the exact design from the screenshot:
/// Dark navy/indigo theme (#07090E) with realistic vector world map continent paths,
/// glowing purple ambient spheres, and animated multi-color gradient lines.
class AnimatedWorldMapBackground extends StatefulWidget {
  final Widget? child;
  final String? watermarkText;
  final Color backgroundColor;

  const AnimatedWorldMapBackground({
    super.key,
    this.child,
    this.watermarkText,
    this.backgroundColor = const Color(0xFF07090E),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return MouseRegion(
          onHover: (event) => _onPointerMove(event.localPosition, size),
          child: Listener(
            onPointerMove: (event) => _onPointerMove(event.localPosition, size),
            child: Stack(
              children: [
                // 1. Base Dark Background (#07090E)
                Container(
                  color: widget.backgroundColor,
                  width: double.infinity,
                  height: double.infinity,
                ),

                // 2. Ambient Purple & Blue Radial Light Spheres
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final pulse =
                        math.sin(_controller.value * 2 * math.pi) * 0.08 + 0.92;
                    return Stack(
                      children: [
                        // Top-Center Purple Glow Behind Map
                        Positioned(
                          top: -size.height * 0.15 + (_pointerOffset.dy * -15),
                          left: size.width * 0.25 + (_pointerOffset.dx * -15),
                          child: Transform.scale(
                            scale: pulse,
                            child: Container(
                              width: size.width * 0.5,
                              height: size.height * 0.5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Color(0x403B0764), // Purple glow
                                    Color(0x201E1B4B), // Dark indigo
                                    Colors.transparent,
                                  ],
                                  stops: [0.0, 0.55, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Center-Right Indigo Glow
                        Positioned(
                          top: size.height * 0.15 + (_pointerOffset.dy * -20),
                          right: size.width * 0.05 + (_pointerOffset.dx * -20),
                          child: Transform.scale(
                            scale: 2.0 - pulse,
                            child: Container(
                              width: size.width * 0.45,
                              height: size.height * 0.55,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Color(0x351E293B), // Soft slate blue glow
                                    Color(0x184F46E5), // Indigo hint
                                    Colors.transparent,
                                  ],
                                  stops: [0.0, 0.6, 1.0],
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
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 4. Subtle Vignette Overlay for Contrast
                IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.15,
                        colors: [
                          Colors.transparent,
                          Color(0x6007090E),
                          Color(0xFF07090E),
                        ],
                        stops: [0.35, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),

                // 5. Child Content (Dashboard content)
                if (widget.child != null) Positioned.fill(child: widget.child!),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// CustomPainter rendering realistic continent vector paths & glowing border outlines matching screenshot.
class DetailedWorldMapPainter extends CustomPainter {
  final double progress;

  DetailedWorldMapPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Rect rect = Rect.fromLTWH(0, 0, w, h);

    // Multi-color glowing outline shader
    final Paint outlineShaderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1.0 + (progress * 2), -0.5),
        end: Alignment(1.0 + (progress * 2), 0.5),
        colors: const [
          Color(0x663B82F6), // Vibrant Blue
          Color(0x998B5CF6), // Purple
          Color(0x662DD4BF), // Cyan
          Color(0x663B82F6), // Blue
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // Dark Navy Continent Fill Paint
    final Paint fillPaint = Paint()
      ..color = const Color(0x2E1E294B)
      ..style = PaintingStyle.fill;

    // Outer Border Line Paint
    final Paint borderPaint = Paint()
      ..color = const Color(0x35384674)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Build Detailed World Map Paths
    final Path mapPath = Path();

    // 1. North America Path
    final Path na = Path()
      ..moveTo(w * 0.06, h * 0.12)
      ..cubicTo(w * 0.12, h * 0.05, w * 0.28, h * 0.06, w * 0.32, h * 0.14)
      ..cubicTo(w * 0.35, h * 0.20, w * 0.30, h * 0.28, w * 0.25, h * 0.34)
      ..lineTo(w * 0.22, h * 0.42)
      ..cubicTo(w * 0.18, h * 0.46, w * 0.15, h * 0.42, w * 0.14, h * 0.36)
      ..cubicTo(w * 0.11, h * 0.30, w * 0.04, h * 0.20, w * 0.06, h * 0.12)
      ..close();
    mapPath.addPath(na, Offset.zero);

    // 2. Greenland Path
    final Path greenland = Path()
      ..moveTo(w * 0.34, h * 0.05)
      ..cubicTo(w * 0.38, h * 0.03, w * 0.43, h * 0.04, w * 0.44, h * 0.10)
      ..cubicTo(w * 0.42, h * 0.15, w * 0.36, h * 0.14, w * 0.34, h * 0.09)
      ..close();
    mapPath.addPath(greenland, Offset.zero);

    // 3. South America Path
    final Path sa = Path()
      ..moveTo(w * 0.24, h * 0.46)
      ..cubicTo(w * 0.30, h * 0.48, w * 0.34, h * 0.56, w * 0.30, h * 0.68)
      ..cubicTo(w * 0.27, h * 0.78, w * 0.24, h * 0.85, w * 0.22, h * 0.82)
      ..cubicTo(w * 0.20, h * 0.75, w * 0.21, h * 0.58, w * 0.24, h * 0.46)
      ..close();
    mapPath.addPath(sa, Offset.zero);

    // 4. Europe Path
    final Path europe = Path()
      ..moveTo(w * 0.46, h * 0.12)
      ..cubicTo(w * 0.52, h * 0.10, w * 0.58, h * 0.14, w * 0.56, h * 0.24)
      ..cubicTo(w * 0.52, h * 0.28, w * 0.45, h * 0.27, w * 0.44, h * 0.20)
      ..close();
    mapPath.addPath(europe, Offset.zero);

    // 5. Africa Path
    final Path africa = Path()
      ..moveTo(w * 0.44, h * 0.30)
      ..cubicTo(w * 0.52, h * 0.28, w * 0.60, h * 0.35, w * 0.58, h * 0.48)
      ..cubicTo(w * 0.56, h * 0.62, w * 0.52, h * 0.72, w * 0.48, h * 0.70)
      ..cubicTo(w * 0.44, h * 0.62, w * 0.42, h * 0.42, w * 0.44, h * 0.30)
      ..close();
    mapPath.addPath(africa, Offset.zero);

    // 6. Asia Path
    final Path asia = Path()
      ..moveTo(w * 0.58, h * 0.12)
      ..cubicTo(w * 0.72, h * 0.08, w * 0.90, h * 0.12, w * 0.94, h * 0.24)
      ..cubicTo(w * 0.96, h * 0.34, w * 0.85, h * 0.45, w * 0.72, h * 0.44)
      ..cubicTo(w * 0.66, h * 0.42, w * 0.60, h * 0.32, w * 0.58, h * 0.22)
      ..close();
    mapPath.addPath(asia, Offset.zero);

    // 7. Australia & Indonesia Path
    final Path australia = Path()
      ..moveTo(w * 0.76, h * 0.55)
      ..cubicTo(w * 0.84, h * 0.52, w * 0.92, h * 0.58, w * 0.90, h * 0.70)
      ..cubicTo(w * 0.86, h * 0.76, w * 0.78, h * 0.74, w * 0.75, h * 0.65)
      ..close();
    mapPath.addPath(australia, Offset.zero);

    // Render Continent Silhouette Fills & Outlines
    canvas.drawPath(mapPath, fillPaint);
    canvas.drawPath(mapPath, borderPaint);
    canvas.drawPath(mapPath, outlineShaderPaint);

    // Render Tech Dots Grid inside Map Path
    final Paint dotPaint = Paint()
      ..color = const Color(0x3B8B5CF6)
      ..style = PaintingStyle.fill;

    const double step = 16.0;
    for (double x = 0; x < w; x += step) {
      for (double y = 0; y < h; y += step) {
        if (mapPath.contains(Offset(x, y))) {
          final pulse = math.sin((x + y + progress * 120) * 0.04) * 0.5 + 1.6;
          canvas.drawCircle(Offset(x, y), pulse, dotPaint);
        }
      }
    }

    // Render Latitude / Longitude Subtle Curved Grid Lines across background
    final Paint gridLinePaint = Paint()
      ..color = const Color(0x0CFFFFFF)
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
    return oldDelegate.progress != progress;
  }
}
