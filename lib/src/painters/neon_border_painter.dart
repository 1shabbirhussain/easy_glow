import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../utils/glow_utils.dart';

/// Paints a rotating multi-color `SweepGradient` border with a soft halo.
///
/// Two passes are drawn:
///
/// 1. A wide, blurred stroke (the halo) using `MaskFilter.blur`.
/// 2. A crisp stroke of [borderWidth] on top (when [showBorder] is `true`).
///
/// The border is drawn *inside* the painted bounds, so pair this painter
/// with a child padded by [borderWidth] (as `EasyGlow.borderSweep` does).
/// The painter repaints from [progress] without rebuilding any widgets.
///
/// ```dart
/// CustomPaint(
///   painter: NeonBorderPainter(
///     progress: controller, // 0..1, one full turn per cycle
///     colors: const [Colors.cyan, Colors.purple, Colors.pink],
///     borderRadius: BorderRadius.circular(16),
///   ),
///   child: const Padding(padding: EdgeInsets.all(2), child: Text('AI')),
/// )
/// ```
class NeonBorderPainter extends CustomPainter {
  /// Creates a rotating gradient border painter.
  NeonBorderPainter({
    required this.progress,
    required this.colors,
    this.borderRadius,
    this.circle = false,
    this.borderWidth = 2.0,
    this.spread = 6.0,
    this.blurRadius = 14.0,
    this.intensity = 1.0,
    this.showBorder = true,
    this.clockwise = true,
    this.opacity,
  }) : super(repaint: Listenable.merge(<Listenable?>[progress, opacity]));

  /// Rotation progress from `0.0` to `1.0` (one full turn).
  final Animation<double> progress;

  /// Gradient colors. The loop is closed automatically.
  final List<Color> colors;

  /// Corner radius of the border; ignored when [circle] is `true`.
  final BorderRadius? borderRadius;

  /// Draws an oval border instead of a rounded rectangle.
  final bool circle;

  /// Width of the crisp border stroke.
  final double borderWidth;

  /// Additional width of the halo stroke beyond [borderWidth].
  final double spread;

  /// Blur radius of the halo in logical pixels.
  final double blurRadius;

  /// Opacity of the halo (`0..1`). The crisp border is always opaque.
  final double intensity;

  /// Whether to draw the crisp border on top of the halo.
  final bool showBorder;

  /// Rotation direction.
  final bool clockwise;

  /// Optional animated opacity (`0..1`) applied to the whole border, e.g.
  /// for fading it in and out.
  final Animation<double>? opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final double o = (opacity?.value ?? 1.0).clamp(0.0, 1.0);
    if (size.isEmpty || colors.isEmpty || o <= 0) return;
    final Rect bounds = Offset.zero & size;
    final RRect rrect = GlowUtils.outline(
      bounds,
      circle: circle,
      radius: borderRadius,
    ).deflate(borderWidth / 2);

    final double turns = progress.value * (clockwise ? 1 : -1);
    final Shader shader = SweepGradient(
      colors: GlowUtils.closeLoop(colors),
      transform: GradientRotation(turns * 2 * math.pi),
    ).createShader(bounds);

    if (intensity > 0 && (blurRadius > 0 || spread > 0)) {
      final Paint halo = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth + spread
        ..color = Color.fromRGBO(0, 0, 0, intensity.clamp(0.0, 1.0) * o);
      final double sigma = GlowUtils.radiusToSigma(blurRadius);
      if (sigma > 0) halo.maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
      canvas.drawRRect(rrect, halo);
    }

    if (showBorder && borderWidth > 0) {
      final Paint border = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = Color.fromRGBO(0, 0, 0, o);
      canvas.drawRRect(rrect, border);
    }
  }

  @override
  bool shouldRepaint(NeonBorderPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      !_listEquals(oldDelegate.colors, colors) ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.circle != circle ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.spread != spread ||
      oldDelegate.blurRadius != blurRadius ||
      oldDelegate.intensity != intensity ||
      oldDelegate.showBorder != showBorder ||
      oldDelegate.clockwise != clockwise ||
      oldDelegate.opacity != opacity;
}

bool _listEquals(List<Color> a, List<Color> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
