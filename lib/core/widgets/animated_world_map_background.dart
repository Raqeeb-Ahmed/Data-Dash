import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated Earth Globe Background widget with automatic Light & Dark mode adaptation.
///
/// Features:
/// - A rotating, more "realistic" globe: blue ocean with lighting, green/brown
///   terrain-colored continents, white polar ice caps, a soft day/night
///   terminator, a drifting semi-transparent cloud layer, faint city lights
///   on the night side (dark mode), and a subtle starfield behind it.
/// - Smoothed (inertia-based) parallax tilt that follows the pointer.
/// - A brief "shake" wobble when the user taps/drags on empty background —
///   but NOT when they tap an interactive widget you place in `child`
///   (buttons, text fields, etc. are unaffected).
/// - Light & Dark theme responsive styling throughout.
///
/// Everything lives in this single file and the public constructor is
/// unchanged (`child`, `watermarkText`, `backgroundColor`), so it's a
/// drop-in replacement for the previous version.
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
    with TickerProviderStateMixin {
  // Slow continuous spin of the globe (also drives cloud drift & starlight twinkle).
  late final AnimationController _rotationController;

  // Short-lived "shake" pulse triggered by tapping empty background.
  late final AnimationController _shakeController;

  Offset _targetTilt = Offset.zero; // raw pointer position, -1..1
  Offset _smoothedTilt = Offset.zero; // eased toward _targetTilt each frame

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 55),
    )..repeat();

    // Piggy-back on the rotation ticks to ease the tilt smoothly (inertia),
    // instead of snapping the globe straight to the pointer position.
    _rotationController.addListener(_easeTilt);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  void _easeTilt() {
    final next = Offset.lerp(_smoothedTilt, _targetTilt, 0.06)!;
    if ((next - _smoothedTilt).distanceSquared > 0.0000004) {
      setState(() => _smoothedTilt = next);
    }
  }

  @override
  void dispose() {
    _rotationController.removeListener(_easeTilt);
    _rotationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onPointerMove(Offset localPosition, Size size) {
    if (size.width == 0 || size.height == 0) return;
    _targetTilt = Offset(
      (localPosition.dx / size.width) * 2 - 1.0,
      (localPosition.dy / size.height) * 2 - 1.0,
    );
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final baseBgColor =
        widget.backgroundColor ??
        (isDarkMode ? const Color(0xFF05070C) : const Color(0xFFEFF4FA));

    final glow1Colors = isDarkMode
        ? const [Color(0x30264A7A), Color(0x181B2A4A), Colors.transparent]
        : const [Color(0x2892C5FC), Color(0x1560A5FA), Colors.transparent];

    final glow2Colors = isDarkMode
        ? const [Color(0x301B3A2E), Color(0x18143024), Colors.transparent]
        : const [Color(0x2886EFAC), Color(0x1534D399), Colors.transparent];

    final vignetteColors = isDarkMode
        ? const [Colors.transparent, Color(0x6005070C), Color(0xFF05070C)]
        : const [Colors.transparent, Color(0x40EFF4FA), Color(0xFFEFF4FA)];

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return MouseRegion(
          onHover: (event) => _onPointerMove(event.localPosition, size),
          // Translucent = always tracks pointer movement for the parallax
          // tilt, but never blocks or steals gestures from `child` below.
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerMove: (event) => _onPointerMove(event.localPosition, size),
            onPointerDown: (event) => _onPointerMove(event.localPosition, size),
            child: Stack(
              children: [
                // --- Background + globe group ---------------------------------
                // Wrapped in its own opaque Listener so it only receives a tap
                // when nothing interactive in `child` (added below, on top)
                // has claimed it first — that's what stops the shake from
                // firing when the user taps a real button/text field/etc.
                Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) => _triggerShake(),
                  child: Stack(
                    children: [
                      // 1. Base canvas background.
                      Container(
                        color: baseBgColor,
                        width: double.infinity,
                        height: double.infinity,
                      ),

                      // 2. Ambient light spheres (interactive, follow pointer).
                      AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          final pulse =
                              math.sin(
                                    _rotationController.value * 2 * math.pi,
                                  ) *
                                  0.08 +
                              0.92;
                          return Stack(
                            children: [
                              Positioned(
                                top:
                                    -size.height * 0.15 +
                                    (_smoothedTilt.dy * -15),
                                left:
                                    size.width * 0.2 + (_smoothedTilt.dx * -15),
                                child: Transform.scale(
                                  scale: pulse,
                                  child: Container(
                                    width: size.width * 0.6,
                                    height: size.height * 0.6,
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
                              Positioned(
                                bottom:
                                    -size.height * 0.1 +
                                    (_smoothedTilt.dy * -20),
                                right:
                                    -size.width * 0.05 +
                                    (_smoothedTilt.dx * -20),
                                child: Transform.scale(
                                  scale: 2.0 - pulse,
                                  child: Container(
                                    width: size.width * 0.5,
                                    height: size.height * 0.5,
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

                      // 3. The Earth globe: rotates continuously, tilts toward
                      //    the pointer, and wobbles briefly on tap.
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _rotationController,
                            _shakeController,
                          ]),
                          builder: (context, child) {
                            final shakeT = _shakeController.value; // 0 -> 1
                            final shakeDecay = (1 - shakeT);
                            final shakeAngle =
                                math.sin(shakeT * math.pi * 10) *
                                0.07 *
                                shakeDecay;
                            final shakeOffsetX =
                                math.sin(shakeT * math.pi * 14) *
                                12 *
                                shakeDecay;
                            final shakeOffsetY =
                                math.cos(shakeT * math.pi * 11) *
                                7 *
                                shakeDecay;
                            final shakeScale =
                                1.0 +
                                (shakeDecay *
                                    math.sin(shakeT * math.pi * 6) *
                                    0.02);

                            return Transform.translate(
                              offset: Offset(
                                _smoothedTilt.dx * -10 + shakeOffsetX,
                                _smoothedTilt.dy * -10 + shakeOffsetY,
                              ),
                              child: Transform.rotate(
                                angle: shakeAngle,
                                child: CustomPaint(
                                  painter: RealisticEarthPainter(
                                    rotation:
                                        _rotationController.value * 2 * math.pi,
                                    tilt: _smoothedTilt,
                                    isDarkMode: isDarkMode,
                                    scale: shakeScale,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // 4. Subtle vignette overlay.
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

                      // 5. Optional watermark.
                      if (widget.watermarkText != null)
                        Positioned(
                          bottom: 16,
                          right: 20,
                          child: IgnorePointer(
                            child: Text(
                              widget.watermarkText!,
                              style: TextStyle(
                                color:
                                    (isDarkMode ? Colors.white : Colors.black)
                                        .withOpacity(0.15),
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // --- Foreground content ----------------------------------------
                // Sits on top, untouched by the shake Listener above: any
                // GestureDetector/InkWell/etc. inside `child` claims its own
                // taps first, so the Stack never even tests the layer below it.
                if (widget.child != null) Positioned.fill(child: widget.child!),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// CustomPainter rendering a more realistic Earth globe:
/// - starfield behind the globe
/// - shaded ocean sphere with a soft day/night terminator
/// - terrain-toned dotted continents (green/brown) fading toward night
/// - white polar ice caps
/// - a drifting translucent cloud layer (parallax vs. the landmass)
/// - faint warm city lights on the night side (dark mode)
/// - a thin rotating atmosphere rim
class RealisticEarthPainter extends CustomPainter {
  final double rotation; // continuous spin, radians
  final Offset tilt; // pointer offset, -1..1, smoothed
  final bool isDarkMode;
  final double scale; // shake "bump"

  RealisticEarthPainter({
    required this.rotation,
    required this.tilt,
    required this.isDarkMode,
    required this.scale,
  });

  // Fixed "sun" direction in 3D globe space (matches the upper-left highlight
  // used for the sphere gradient) — used to compute day/night shading.
  static final Offset3 _lightDir = Offset3(-0.55, 0.35, 0.76).normalized();

  // Land + cloud point clouds, generated once and reused every frame.
  static final List<Offset> _landPoints = _generateRegionPoints(
    includeAntarctica: true,
  );
  static final List<Offset> _cloudPoints = _generateCloudPoints();

  static List<Offset> _generateRegionPoints({required bool includeAntarctica}) {
    final List<Offset> pts = [];

    void addRegion(
      double latMin,
      double latMax,
      double lonMin,
      double lonMax,
      double density,
    ) {
      final rnd = math.Random(
        ((latMin * 1000).toInt()) ^ ((lonMin * 1000).toInt()),
      );
      final area = (latMax - latMin) * (lonMax - lonMin);
      final count = (area * density).clamp(10, 420).toInt();
      for (int i = 0; i < count; i++) {
        final lat = latMin + rnd.nextDouble() * (latMax - latMin);
        final lon = lonMin + rnd.nextDouble() * (lonMax - lonMin);
        pts.add(Offset(lat, lon)); // dx = lat, dy = lon
      }
    }

    addRegion(15, 72, -170, -55, 0.06); // North America
    addRegion(-56, 12, -82, -34, 0.075); // South America
    addRegion(36, 71, -10, 40, 0.1); // Europe
    addRegion(-35, 37, -18, 52, 0.05); // Africa
    addRegion(5, 77, 40, 180, 0.035); // Asia
    addRegion(-44, -10, 112, 154, 0.11); // Australia
    addRegion(60, 83, -73, -12, 0.09); // Greenland
    if (includeAntarctica) addRegion(-90, -66, -180, 180, 0.02); // Antarctica

    return pts;
  }

  static List<Offset> _generateCloudPoints() {
    final rnd = math.Random(777);
    final List<Offset> pts = [];
    for (int i = 0; i < 220; i++) {
      final lat = -80 + rnd.nextDouble() * 160;
      final lon = -180 + rnd.nextDouble() * 360;
      pts.add(Offset(lat, lon));
    }
    return pts;
  }

  static final List<_Star> _stars = List.generate(90, (i) {
    final rnd = math.Random(i * 97 + 13);
    return _Star(
      rnd.nextDouble(),
      rnd.nextDouble(),
      0.5 + rnd.nextDouble() * 1.3,
      rnd.nextDouble() * math.pi * 2,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.42 * scale;

    _paintStars(canvas, size);

    // --- Atmosphere glow ---
    final atmoPaint = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0x4433C1FF), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.28));
    canvas.drawCircle(center, radius * 1.28, atmoPaint);

    // --- Ocean sphere base ---
    final sphereGradient = isDarkMode
        ? const RadialGradient(
            center: Alignment(-0.35, -0.4),
            radius: 1.15,
            colors: [Color(0xFF1B3A6B), Color(0xFF0C2040), Color(0xFF040A16)],
            stops: [0.0, 0.6, 1.0],
          )
        : const RadialGradient(
            center: Alignment(-0.35, -0.4),
            radius: 1.15,
            colors: [Color(0xFF6FB6F5), Color(0xFF2E86D6), Color(0xFF1A5FA8)],
            stops: [0.0, 0.6, 1.0],
          );
    final spherePaint = Paint()
      ..shader = sphereGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, spherePaint);

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );

    final double tiltX = (tilt.dy * 0.35).clamp(-0.5, 0.5);
    final double lonOffset = rotation;

    // --- Soft day/night terminator (screen-space shadow toward lower-right) ---
    final terminatorPaint = Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-0.6, -0.6),
        end: const Alignment(0.9, 0.9),
        colors: [
          Colors.transparent,
          Colors.transparent,
          (isDarkMode ? Colors.black : const Color(0xFF0A1B33)).withOpacity(
            isDarkMode ? 0.55 : 0.35,
          ),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, terminatorPaint);

    // --- Faint lat/long grid (kept minimal for realism) ---
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    for (int latDeg = -60; latDeg <= 60; latDeg += 30) {
      final path = Path();
      bool started = false;
      for (int lonDeg = 0; lonDeg <= 360; lonDeg += 4) {
        final p = _project(
          latDeg.toDouble(),
          lonDeg.toDouble(),
          lonOffset,
          tiltX,
          center,
          radius,
        );
        if (p == null) {
          started = false;
          continue;
        }
        started
            ? path.lineTo(p.screen.dx, p.screen.dy)
            : path.moveTo(p.screen.dx, p.screen.dy);
        started = true;
      }
      canvas.drawPath(path, gridPaint);
    }

    // --- Landmass: terrain-toned, ice caps, day/night aware ---
    final dotPaint = Paint();
    for (final pt in _landPoints) {
      final lat = pt.dx;
      final p = _project(lat, pt.dy, lonOffset, tiltX, center, radius);
      if (p == null || p.depth <= 0.02) continue;

      final lit = _litFactor(lat, pt.dy, lonOffset, tiltX);
      final isPolar = lat.abs() > 64;

      Color base;
      if (isPolar) {
        base = const Color(0xFFF3F7FB);
      } else {
        // Cheap terrain variation: hash lat/lon into a green<->brown mix.
        final hash =
            (math.sin(lat * 12.9898 + pt.dy * 78.233) * 43758.5453) % 1.0;
        final t = hash.abs();
        base = Color.lerp(const Color(0xFF3E8E4F), const Color(0xFF9C7B4A), t)!;
      }

      if (lit > 0.05) {
        final brightness = (0.55 + lit * 0.6).clamp(0.0, 1.15);
        final litColor = Color.lerp(
          base,
          Colors.white,
          (brightness - 1.0).clamp(0.0, 0.4),
        )!;
        dotPaint.color = litColor.withOpacity(
          (0.55 + p.depth * 0.4).clamp(0.0, 1.0),
        );
        canvas.drawCircle(p.screen, 1.0 + p.depth * 1.3, dotPaint);
      } else {
        // Night side: land barely visible, but show occasional warm city lights.
        dotPaint.color = base.withOpacity(0.12 * p.depth);
        canvas.drawCircle(p.screen, 0.8 + p.depth * 0.9, dotPaint);

        if (isDarkMode && !isPolar) {
          final cityHash =
              ((lat * 1000).toInt() ^ (pt.dy * 1000).toInt()).abs() % 100;
          if (cityHash < 10) {
            dotPaint.color = const Color(
              0xFFFFD98A,
            ).withOpacity(0.55 * p.depth);
            canvas.drawCircle(p.screen, 1.1 * p.depth, dotPaint);
          }
        }
      }
    }

    // --- Cloud layer (drifts a little faster than the landmass) ---
    final cloudLonOffset = rotation * 1.18;
    final cloudPaint = Paint();
    for (final pt in _cloudPoints) {
      final p = _project(pt.dx, pt.dy, cloudLonOffset, tiltX, center, radius);
      if (p == null || p.depth <= 0.05) continue;
      final lit = _litFactor(pt.dx, pt.dy, cloudLonOffset, tiltX);
      final brightness = lit > 0 ? 0.5 : 0.18;
      cloudPaint.color = Colors.white.withOpacity(brightness * p.depth * 0.6);
      canvas.drawCircle(p.screen, 2.6 + p.depth * 2.2, cloudPaint);
    }

    // --- Rotating atmosphere-edge gradient rim ---
    final rimPaint = Paint()
      ..shader = SweepGradient(
        colors: const [
          Color(0x552196F3),
          Color(0x8877E1E8),
          Color(0x5533C1FF),
          Color(0x552196F3),
        ],
        transform: GradientRotation(rotation),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(center, radius - 1, rimPaint);

    canvas.restore();

    // --- Outer highlight ring ---
    final outerRing = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, outerRing);
  }

  void _paintStars(Canvas canvas, Size size) {
    final starPaint = Paint();
    for (final star in _stars) {
      final twinkle =
          0.35 + 0.65 * (0.5 + 0.5 * math.sin(rotation * 3 + star.phase));
      starPaint.color = Colors.white.withOpacity(
        (isDarkMode ? 0.55 : 0.18) * twinkle,
      );
      canvas.drawCircle(
        Offset(star.fx * size.width, star.fy * size.height),
        star.radius,
        starPaint,
      );
    }
  }

  /// Dot product of a projected point's (post-tilt) 3D normal against the
  /// fixed light direction — positive means "facing the sun" (day side).
  double _litFactor(
    double latDeg,
    double lonDeg,
    double lonOffset,
    double tiltX,
  ) {
    final lat = latDeg * math.pi / 180;
    final lon = (lonDeg * math.pi / 180) + lonOffset;
    final x = math.cos(lat) * math.sin(lon);
    final y = math.sin(lat);
    final z = math.cos(lat) * math.cos(lon);
    final cosT = math.cos(tiltX);
    final sinT = math.sin(tiltX);
    final y2 = y * cosT - z * sinT;
    final z2 = y * sinT + z * cosT;
    return x * _lightDir.x + y2 * _lightDir.y + z2 * _lightDir.z;
  }

  /// Orthographic projection of a lat/long point to screen space.
  /// Returns null when the point is on the far side of the globe.
  _Projected? _project(
    double latDeg,
    double lonDeg,
    double lonOffset,
    double tiltX,
    Offset center,
    double radius,
  ) {
    final lat = latDeg * math.pi / 180;
    final lon = (lonDeg * math.pi / 180) + lonOffset;

    final x = math.cos(lat) * math.sin(lon);
    final y = math.sin(lat);
    final z = math.cos(lat) * math.cos(lon);

    final cosT = math.cos(tiltX);
    final sinT = math.sin(tiltX);
    final y2 = y * cosT - z * sinT;
    final z2 = y * sinT + z * cosT;

    if (z2 < -0.05) return null;

    final depth = ((z2 + 1) / 2).clamp(0.0, 1.0);
    final screen = Offset(center.dx + x * radius, center.dy - y2 * radius);
    return _Projected(screen, depth);
  }

  @override
  bool shouldRepaint(covariant RealisticEarthPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.tilt != tilt ||
        oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.scale != scale;
  }
}

class _Projected {
  final Offset screen;
  final double depth;
  const _Projected(this.screen, this.depth);
}

class _Star {
  final double fx, fy; // fractional canvas position, 0..1
  final double radius;
  final double phase;
  const _Star(this.fx, this.fy, this.radius, this.phase);
}

/// Tiny 3D vector helper used only for the fixed light direction.
class Offset3 {
  final double x, y, z;
  const Offset3(this.x, this.y, this.z);

  Offset3 normalized() {
    final len = math.sqrt(x * x + y * y + z * z);
    return Offset3(x / len, y / len, z / len);
  }
}
