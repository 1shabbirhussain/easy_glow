import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../utils/glow_utils.dart';

/// Paints [waveCount] staggered rings that expand and fade out, like a radar
/// ping or a "live" indicator.
///
/// Each ring starts at the size of the painted area, grows by up to
/// [maxScale] and fades to transparent. Rings are evenly staggered across
/// one cycle of [progress], so the loop is seamless.
///
/// ```dart
/// CustomPaint(
///   painter: RipplePainter(
///     progress: controller, // repeating 0..1
///     color: Colors.greenAccent,
///     circle: true,
///   ),
///   child: const CircleAvatar(radius: 32),
/// )
/// ```
class RipplePainter extends CustomPainter {
  /// Creates a ripple painter.
  RipplePainter({
    required this.progress,
    required this.color,
    this.waveCount = 3,
    this.maxScale = 1.6,
    this.curve = Curves.easeOut,
    this.circle = true,
    this.borderRadius,
    this.blurRadius = 6.0,
    this.ringWidth = 0.0,
    this.intensity = 0.85,
    this.offset = Offset.zero,
    this.opacity,
  }) : super(repaint: Listenable.merge(<Listenable?>[progress, opacity]));

  /// Wave cycle progress from `0.0` to `1.0`.
  final Animation<double> progress;

  /// Ring color.
  final Color color;

  /// Number of simultaneous rings.
  final int waveCount;

  /// Maximum ring size relative to the painted area's shortest side.
  final double maxScale;

  /// Easing applied to ring expansion.
  final Curve curve;

  /// Whether rings are circles (`true`) or follow a rounded rectangle.
  final bool circle;

  /// Corner radius for rectangular rings.
  final BorderRadius? borderRadius;

  /// Softness of the rings in logical pixels.
  final double blurRadius;

  /// Stroke width of outlined rings; `0` paints filled pulses.
  final double ringWidth;

  /// Peak opacity of a newly emitted ring (`0..1`).
  final double intensity;

  /// Moves the ripple origin relative to the center.
  final Offset offset;

  /// Optional animated opacity (`0..1`) applied to all rings.
  final Animation<double>? opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final double o = (opacity?.value ?? 1.0).clamp(0.0, 1.0);
    if (size.isEmpty || waveCount <= 0 || intensity <= 0 || o <= 0) return;
    final Offset center = size.center(Offset.zero) + offset;
    final double grow = (maxScale - 1) * size.shortestSide / 2;
    final double sigma = GlowUtils.radiusToSigma(blurRadius);
    final Paint paint = Paint()
      ..style = ringWidth > 0 ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = ringWidth;
    if (sigma > 0) paint.maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);

    for (int i = 0; i < waveCount; i++) {
      final double t = (progress.value + i / waveCount) % 1.0;
      final double eased = curve.transform(t);
      final double alpha = (1 - t) * intensity.clamp(0.0, 1.0) * o;
      if (alpha <= 0.001) continue;
      paint.color = color.withValues(alpha: color.a * alpha);
      final double inflate = grow * eased;
      if (circle) {
        canvas.drawCircle(center, size.shortestSide / 2 + inflate, paint);
      } else {
        final Rect rect = Rect.fromCenter(
          center: center,
          width: size.width,
          height: size.height,
        );
        canvas.drawRRect(
          GlowUtils.outline(
            rect,
            circle: false,
            radius: borderRadius,
          ).inflate(inflate),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.waveCount != waveCount ||
      oldDelegate.maxScale != maxScale ||
      oldDelegate.curve != curve ||
      oldDelegate.circle != circle ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.blurRadius != blurRadius ||
      oldDelegate.ringWidth != ringWidth ||
      oldDelegate.intensity != intensity ||
      oldDelegate.offset != offset ||
      oldDelegate.opacity != opacity;
}
