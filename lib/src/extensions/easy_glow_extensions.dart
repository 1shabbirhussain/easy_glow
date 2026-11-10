import 'package:flutter/widgets.dart';

import '../enums/glow_type.dart';
import '../models/glow_config.dart';
import '../widgets/easy_glow_widget.dart';

/// One-line glow helpers for any [Widget].
///
/// ```dart
/// const Icon(Icons.favorite, color: Colors.pink, size: 48)
///     .glow(color: Colors.pinkAccent, animate: true);
///
/// Image.asset('assets/album.png').ambientGlow();
///
/// FilledButton(onPressed: () {}, child: const Text('Ask AI'))
///     .borderGlow(borderRadius: 24);
///
/// const CircleAvatar(radius: 32).rippleGlow(color: Colors.greenAccent);
/// ```
extension EasyGlowExtension on Widget {
  /// Wraps this widget in an [EasyGlow] described by [config].
  Widget withGlow(GlowConfig config, {Key? key, Widget? silhouette}) =>
      EasyGlow(key: key, config: config, silhouette: silhouette, child: this);

  /// Adds a glow of the given [type] (an alpha-contour neon glow by default).
  ///
  /// `null` [color] falls back to the theme's primary color.
  Widget glow({
    Key? key,
    Color? color,
    double blurRadius = 18.0,
    double spreadScale = 1.05,
    double intensity = 0.85,
    GlowType type = GlowType.contour,
    GlowQuality quality = GlowQuality.standard,
    Offset offset = Offset.zero,
    bool animate = false,
    GlowAnimationMode animationMode = GlowAnimationMode.breathe,
    Duration duration = const Duration(milliseconds: 1600),
    Curve curve = Curves.easeInOut,
    double minIntensity = 0.4,
    double maxIntensity = 1.0,
    GlowTrigger trigger = GlowTrigger.always,
    bool enabled = true,
  }) => EasyGlow(
    key: key,
    config: GlowConfig(
      type: type,
      color: color,
      blurRadius: blurRadius,
      spreadScale: spreadScale,
      intensity: intensity,
      quality: quality,
      offset: offset,
      animate: animate,
      animationMode: animationMode,
      duration: duration,
      curve: curve,
      minIntensity: minIntensity,
      maxIntensity: maxIntensity,
      trigger: trigger,
      enabled: enabled,
    ),
    child: this,
  );

  /// Adds a neon contour glow with a bright core and soft halo
  /// ([GlowQuality.high]). Shortcut for [EasyGlow.neon].
  Widget neonGlow({
    Key? key,
    Color? color,
    double blurRadius = 16.0,
    double intensity = 0.9,
    bool animate = false,
    GlowAnimationMode animationMode = GlowAnimationMode.breathe,
    Duration duration = const Duration(milliseconds: 1600),
    GlowTrigger trigger = GlowTrigger.always,
    bool enabled = true,
  }) => EasyGlow.neon(
    key: key,
    color: color,
    blurRadius: blurRadius,
    intensity: intensity,
    animate: animate,
    animationMode: animationMode,
    duration: duration,
    trigger: trigger,
    enabled: enabled,
    child: this,
  );

  /// Adds an ambient backlight that bleeds this widget's own colors.
  /// Shortcut for [EasyGlow.ambient].
  Widget ambientGlow({
    Key? key,
    double blurRadius = 24.0,
    double spreadScale = 1.08,
    double intensity = 0.8,
    double saturationBoost = 1.2,
    Offset offset = Offset.zero,
    bool animate = false,
    Duration duration = const Duration(milliseconds: 2400),
    GlowTrigger trigger = GlowTrigger.always,
    bool enabled = true,
  }) => EasyGlow.ambient(
    key: key,
    blurRadius: blurRadius,
    spreadScale: spreadScale,
    intensity: intensity,
    saturationBoost: saturationBoost,
    offset: offset,
    animate: animate,
    duration: duration,
    trigger: trigger,
    enabled: enabled,
    child: this,
  );

  /// Adds a rotating gradient border glow. Shortcut for
  /// [EasyGlow.borderSweep].
  ///
  /// Set [circle] to `true` for round widgets such as avatars and FABs.
  Widget borderGlow({
    Key? key,
    List<Color> colors = EasyGlow.defaultSweepColors,
    double borderRadius = 16.0,
    bool circle = false,
    double borderWidth = 2.0,
    double spread = 6.0,
    double blurRadius = 14.0,
    double intensity = 0.9,
    bool showBorder = true,
    bool clockwise = true,
    bool animate = true,
    Duration duration = const Duration(seconds: 3),
    GlowTrigger trigger = GlowTrigger.always,
    bool enabled = true,
  }) => EasyGlow.borderSweep(
    key: key,
    colors: colors,
    borderRadius: BorderRadius.circular(borderRadius),
    shape: circle ? BoxShape.circle : BoxShape.rectangle,
    borderWidth: borderWidth,
    spread: spread,
    blurRadius: blurRadius,
    intensity: intensity,
    showBorder: showBorder,
    clockwise: clockwise,
    animate: animate,
    duration: duration,
    trigger: trigger,
    enabled: enabled,
    child: this,
  );

  /// Adds expanding ripple / radar rings. Shortcut for [EasyGlow.ripple].
  ///
  /// Rings are circular by default; set [circle] to `false` and provide
  /// [borderRadius] for rounded-rectangle rings.
  Widget rippleGlow({
    Key? key,
    Color? color,
    int waveCount = 3,
    double maxScale = 1.6,
    double blurRadius = 6.0,
    double ringWidth = 0.0,
    double intensity = 0.6,
    bool circle = true,
    double borderRadius = 16.0,
    Duration duration = const Duration(seconds: 2),
    Curve curve = Curves.easeOut,
    GlowTrigger trigger = GlowTrigger.always,
    bool enabled = true,
  }) => EasyGlow.ripple(
    key: key,
    color: color,
    waveCount: waveCount,
    maxScale: maxScale,
    blurRadius: blurRadius,
    ringWidth: ringWidth,
    intensity: intensity,
    shape: circle ? BoxShape.circle : BoxShape.rectangle,
    borderRadius: BorderRadius.circular(borderRadius),
    duration: duration,
    curve: curve,
    trigger: trigger,
    enabled: enabled,
    child: this,
  );

  /// Adds a fast neon glow around a rectangle, rounded rectangle or circle.
  /// Shortcut for [EasyGlow.box].
  Widget boxGlow({
    Key? key,
    Color? color,
    List<Color>? colors,
    double borderRadius = 16.0,
    bool circle = false,
    double blurRadius = 18.0,
    double spread = 2.0,
    double intensity = 0.85,
    bool innerGlow = false,
    Offset offset = Offset.zero,
    bool animate = false,
    GlowAnimationMode animationMode = GlowAnimationMode.breathe,
    Duration duration = const Duration(milliseconds: 1600),
    GlowTrigger trigger = GlowTrigger.always,
    bool enabled = true,
  }) => EasyGlow.box(
    key: key,
    color: color,
    colors: colors,
    borderRadius: BorderRadius.circular(borderRadius),
    shape: circle ? BoxShape.circle : BoxShape.rectangle,
    blurRadius: blurRadius,
    spread: spread,
    intensity: intensity,
    innerGlow: innerGlow,
    offset: offset,
    animate: animate,
    animationMode: animationMode,
    duration: duration,
    trigger: trigger,
    enabled: enabled,
    child: this,
  );
}
