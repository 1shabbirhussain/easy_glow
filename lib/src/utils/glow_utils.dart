import 'package:flutter/painting.dart';

/// Internal helpers shared by the glow painters and layers.
///
/// Not exported from `package:easy_glow/easy_glow.dart`.
abstract final class GlowUtils {
  /// Converts a blur radius in logical pixels to a Gaussian sigma, using the
  /// same formula as Flutter's `BoxShadow` so values feel familiar.
  static double radiusToSigma(double radius) =>
      radius > 0 ? radius * 0.57735 + 0.5 : 0.0;

  /// Returns [colors] with the first color appended to the end, so a
  /// `SweepGradient` built from it has no visible seam.
  static List<Color> closeLoop(List<Color> colors) {
    if (colors.isEmpty) return const <Color>[Color(0x00000000)];
    if (colors.length == 1) return <Color>[colors.first, colors.first];
    if (colors.first == colors.last) return colors;
    return <Color>[...colors, colors.first];
  }

  /// A 5x4 color matrix that scales saturation by [s] (1.0 = unchanged).
  static List<double> saturationMatrix(double s) {
    const double r = 0.2126;
    const double g = 0.7152;
    const double b = 0.0722;
    final double inv = 1 - s;
    return <double>[
      inv * r + s, inv * g, inv * b, 0, 0, //
      inv * r, inv * g + s, inv * b, 0, 0, //
      inv * r, inv * g, inv * b + s, 0, 0, //
      0, 0, 0, 1, 0, //
    ];
  }

  /// Builds the outline of [rect]: an inscribed oval when [circle] is
  /// `true`, otherwise a rounded rectangle using [radius] (square corners
  /// when `null`).
  static RRect outline(
    Rect rect, {
    required bool circle,
    BorderRadius? radius,
  }) {
    if (circle) {
      return RRect.fromRectXY(rect, rect.width / 2, rect.height / 2);
    }
    return (radius ?? BorderRadius.zero).toRRect(rect);
  }
}
