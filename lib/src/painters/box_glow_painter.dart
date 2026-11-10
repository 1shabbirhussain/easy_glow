import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import '../utils/glow_utils.dart';

/// Paints a neon glow around a rectangle, rounded rectangle or oval.
///
/// With [inner] set to `false` (the default) the glow is drawn only
/// *outside* the shape using `BlurStyle.outer`, so translucent children
/// (glass cards, outlined buttons) are not tinted. With [inner] set to
/// `true` the painter draws an inset glow hugging the inside of the edges —
/// use it as a `foregroundPainter`.
class BoxGlowPainter extends CustomPainter {
  /// Creates a box glow painter.
  BoxGlowPainter({
    required this.color,
    this.colors,
    this.borderRadius,
    this.circle = false,
    this.blurRadius = 18.0,
    this.spread = 0.0,
    this.offset = Offset.zero,
    this.inner = false,
    this.opacity,
  }) : super(repaint: opacity);

  /// Glow color (ignored when [colors] is non-null).
  final Color color;

  /// Optional sweep-gradient colors for a multi-color glow.
  final List<Color>? colors;

  /// Corner radius; ignored when [circle] is `true`.
  final BorderRadius? borderRadius;

  /// Paints an oval glow instead of a rounded rectangle.
  final bool circle;

  /// Blur radius in logical pixels.
  final double blurRadius;

  /// Inflates the glow shape by this many logical pixels (outer glow only).
  final double spread;

  /// Shifts the outer glow.
  final Offset offset;

  /// Paints an inset glow instead of an outer glow.
  final bool inner;

  /// Optional animated opacity (`0..1`) applied to the glow. The painter
  /// repaints when it changes, without rebuilding any widgets.
  final Animation<double>? opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final double o = (opacity?.value ?? 1.0).clamp(0.0, 1.0);
    if (size.isEmpty || o <= 0) return;
    final Rect bounds = Offset.zero & size;
    final double sigma = GlowUtils.radiusToSigma(blurRadius);
    final Paint paint = Paint()..color = color.withValues(alpha: color.a * o);
    final List<Color>? gradient = colors;
    if (gradient != null && gradient.isNotEmpty) {
      paint
        ..color = Color.fromRGBO(0, 0, 0, o)
        ..shader = SweepGradient(
          colors: GlowUtils.closeLoop(gradient),
        ).createShader(bounds);
    }

    if (inner) {
      final RRect shape = GlowUtils.outline(
        bounds,
        circle: circle,
        radius: borderRadius,
      );
      canvas
        ..save()
        ..clipRRect(shape);
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = blurRadius.clamp(1.0, double.infinity);
      if (sigma > 0) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, sigma / 2);
      }
      canvas
        ..drawRRect(shape, paint)
        ..restore();
      return;
    }

    final RRect shape = GlowUtils.outline(
      bounds.shift(offset).inflate(spread),
      circle: circle,
      radius: borderRadius,
    );
    if (sigma > 0) paint.maskFilter = MaskFilter.blur(BlurStyle.outer, sigma);
    canvas.drawRRect(shape, paint);
  }

  @override
  bool shouldRepaint(BoxGlowPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.colors != colors ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.circle != circle ||
      oldDelegate.blurRadius != blurRadius ||
      oldDelegate.spread != spread ||
      oldDelegate.offset != offset ||
      oldDelegate.inner != inner ||
      oldDelegate.opacity != opacity;
}
