import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../enums/glow_type.dart';
import '../utils/glow_utils.dart';

/// Renders a blurred copy of [child] to be placed *behind* the real child.
///
/// * When [color] is non-null the copy is flattened to a single-color
///   silhouette that keeps the child's alpha channel (contour / neon glow).
/// * When [color] is `null` the child's own colors are kept, optionally
///   saturated by [saturationBoost] (ambient / backlight glow).
///
/// The copy is wrapped in [IgnorePointer], [ExcludeSemantics],
/// [ExcludeFocus] and a disabled [HeroMode] so it never receives taps,
/// focus, screen-reader announcements or hero flights.
///
/// This widget is used internally by `EasyGlow`; most apps never need it
/// directly.
class SilhouetteGlowLayer extends StatelessWidget {
  /// Creates a silhouette glow layer.
  const SilhouetteGlowLayer({
    super.key,
    required this.child,
    this.color,
    this.blurRadius = 18.0,
    this.spreadScale = 1.05,
    this.saturationBoost = 1.0,
    this.quality = GlowQuality.standard,
    this.offset = Offset.zero,
    this.opacity,
  });

  /// The widget to copy. Pass a lightweight, key-less version of the real
  /// child when the real child holds a `GlobalKey` or controller.
  final Widget child;

  /// Silhouette tint; `null` keeps the child's own colors.
  final Color? color;

  /// Blur radius in logical pixels.
  final double blurRadius;

  /// Scale of the copy relative to the child.
  final double spreadScale;

  /// Saturation multiplier applied when [color] is `null`.
  final double saturationBoost;

  /// Number of blurred layers. See [GlowQuality].
  final GlowQuality quality;

  /// Translation applied to the copy.
  final Offset offset;

  /// Optional animated opacity (`0..1`) of the glow.
  ///
  /// Opacity is folded into a color filter instead of an opacity layer,
  /// which keeps the blur cached and avoids opacity-inheritance issues on
  /// the Impeller renderer.
  final Animation<double>? opacity;

  Widget _blurred(double radius, double scale) {
    Widget copy = child;
    final double sigma = GlowUtils.radiusToSigma(radius);
    if (sigma > 0) {
      copy = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: sigma,
          sigmaY: sigma,
          tileMode: TileMode.decal,
        ),
        child: copy,
      );
    }
    if (scale != 1.0) copy = Transform.scale(scale: scale, child: copy);
    return copy;
  }

  ColorFilter _filter(double o) {
    final Color? tint = color;
    if (tint != null) {
      // Flatten to a single-color silhouette that keeps the child's alpha.
      return ColorFilter.mode(
        tint.withValues(alpha: tint.a * o),
        BlendMode.srcIn,
      );
    }
    // Keep the child's colors; boost saturation and scale alpha.
    final List<double> m = GlowUtils.saturationMatrix(saturationBoost);
    m[18] = o;
    return ColorFilter.matrix(m);
  }

  @override
  Widget build(BuildContext context) {
    Widget blurred = quality == GlowQuality.high
        ? Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: <Widget>[
              _blurred(blurRadius, spreadScale),
              _blurred(blurRadius * 0.35, 1 + (spreadScale - 1) * 0.5),
            ],
          )
        : _blurred(blurRadius, spreadScale);
    // Isolate the blurred copy so animating the filter does not re-record it.
    blurred = RepaintBoundary(child: blurred);

    final Animation<double>? animation = opacity;
    Widget result = animation == null
        ? ColorFiltered(colorFilter: _filter(1), child: blurred)
        : AnimatedBuilder(
            animation: animation,
            child: blurred,
            builder: (BuildContext context, Widget? child) => ColorFiltered(
              colorFilter: _filter(animation.value.clamp(0.0, 1.0)),
              child: child,
            ),
          );
    if (offset != Offset.zero) {
      result = Transform.translate(offset: offset, child: result);
    }
    return IgnorePointer(
      child: ExcludeSemantics(
        child: ExcludeFocus(child: HeroMode(enabled: false, child: result)),
      ),
    );
  }
}
