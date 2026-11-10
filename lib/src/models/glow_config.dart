import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../enums/glow_type.dart';

/// Immutable description of a glow effect.
///
/// A [GlowConfig] holds every knob understood by `EasyGlow`. Most fields only
/// apply to some [GlowType]s; unused fields are simply ignored, so a single
/// config can be switched between types at runtime (as the example
/// playground does).
///
/// ```dart
/// const config = GlowConfig(
///   type: GlowType.contour,
///   color: Colors.cyanAccent,
///   blurRadius: 20,
///   animate: true,
/// );
///
/// EasyGlow(config: config, child: const Icon(Icons.bolt, size: 64));
/// ```
@immutable
class GlowConfig with Diagnosticable {
  /// Creates a glow configuration.
  ///
  /// All numeric values must be non-negative; [minIntensity] must not exceed
  /// [maxIntensity].
  const GlowConfig({
    this.type = GlowType.contour,
    this.color,
    this.colors,
    this.blurRadius = 18.0,
    this.spreadScale = 1.05,
    this.spread = 0.0,
    this.intensity = 0.85,
    this.offset = Offset.zero,
    this.quality = GlowQuality.standard,
    this.saturationBoost = 1.0,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.borderWidth = 2.0,
    this.showBorder = true,
    this.clockwise = true,
    this.innerGlow = false,
    this.waveCount = 3,
    this.maxScale = 1.6,
    this.ringWidth = 0.0,
    this.enabled = true,
    this.animate = false,
    this.animationMode = GlowAnimationMode.breathe,
    this.duration = const Duration(milliseconds: 1600),
    this.curve = Curves.easeInOut,
    this.minIntensity = 0.4,
    this.maxIntensity = 1.0,
    this.trigger = GlowTrigger.always,
    this.fadeDuration = const Duration(milliseconds: 250),
  }) : assert(blurRadius >= 0, 'blurRadius must be >= 0'),
       assert(spreadScale > 0, 'spreadScale must be > 0'),
       assert(spread >= 0, 'spread must be >= 0'),
       assert(intensity >= 0 && intensity <= 1, 'intensity must be 0..1'),
       assert(saturationBoost >= 0, 'saturationBoost must be >= 0'),
       assert(borderWidth >= 0, 'borderWidth must be >= 0'),
       assert(waveCount > 0, 'waveCount must be > 0'),
       assert(maxScale >= 1, 'maxScale must be >= 1'),
       assert(ringWidth >= 0, 'ringWidth must be >= 0'),
       assert(minIntensity >= 0 && minIntensity <= 1, 'minIntensity 0..1'),
       assert(maxIntensity >= 0 && maxIntensity <= 1, 'maxIntensity 0..1'),
       assert(
         minIntensity <= maxIntensity,
         'minIntensity must be <= maxIntensity',
       );

  /// Which glow engine renders the effect.
  final GlowType type;

  /// Glow tint.
  ///
  /// Used by [GlowType.contour], [GlowType.ripple] and [GlowType.box]. When
  /// `null`, `Theme.of(context).colorScheme.primary` is used. Ignored by
  /// [GlowType.ambient] (which uses the child's own colors) and
  /// [GlowType.borderSweep] (which uses [colors]).
  final Color? color;

  /// Gradient colors for [GlowType.borderSweep] (and, when given, for
  /// [GlowType.box], which then paints a sweep gradient glow).
  ///
  /// The gradient is automatically closed (the first color is appended at
  /// the end) so the rotation is seamless.
  final List<Color>? colors;

  /// Blur radius of the glow in logical pixels. `0` produces a hard edge.
  final double blurRadius;

  /// How much larger than the child the silhouette glow is
  /// ([GlowType.contour] and [GlowType.ambient]). `1.0` means same size.
  final double spreadScale;

  /// Extra glow spread in logical pixels for [GlowType.box] (the glow rect
  /// is inflated by this amount) and [GlowType.borderSweep] (the halo stroke
  /// is this much wider than [borderWidth]).
  final double spread;

  /// Glow opacity from `0.0` (invisible) to `1.0` (full strength) when not
  /// animating. While [animate] is `true`, [minIntensity] and
  /// [maxIntensity] are used instead.
  final double intensity;

  /// Shifts the glow relative to the child, e.g. `Offset(0, 8)` for a glow
  /// that falls below the child like a light source from above.
  final Offset offset;

  /// Number of blur layers for silhouette glows. See [GlowQuality].
  final GlowQuality quality;

  /// Color saturation multiplier for [GlowType.ambient]. `1.0` keeps the
  /// original colors; `1.3` makes the backlight more vivid; `0.0` is gray.
  final double saturationBoost;

  /// Corner radius for [GlowType.box], [GlowType.borderSweep] and
  /// rectangular [GlowType.ripple] shapes. Ignored when [shape] is
  /// [BoxShape.circle].
  final BorderRadius? borderRadius;

  /// Outline used by [GlowType.box], [GlowType.borderSweep] and
  /// [GlowType.ripple].
  final BoxShape shape;

  /// Width of the crisp border stroke for [GlowType.borderSweep]. The child
  /// is padded by this amount so the border never covers content.
  final double borderWidth;

  /// Whether [GlowType.borderSweep] draws its crisp inner border. When
  /// `false` only the soft halo is drawn.
  final bool showBorder;

  /// Rotation direction for [GlowType.borderSweep].
  final bool clockwise;

  /// Adds an inner (inset) glow on top of the child's edges for
  /// [GlowType.box], for a glowing-tube look.
  final bool innerGlow;

  /// Number of simultaneous rings for [GlowType.ripple].
  final int waveCount;

  /// How far each ripple ring grows, relative to the child size.
  final double maxScale;

  /// Ripple ring stroke width. `0` draws soft filled pulses; a positive
  /// value draws radar-style outlined rings.
  final double ringWidth;

  /// Whether the glow is shown. Toggling fades the glow in/out over
  /// [fadeDuration]; when fully faded out nothing extra is rendered.
  final bool enabled;

  /// Whether the glow animates (breathing intensity, border rotation or
  /// ripple emission depending on [type]).
  ///
  /// [GlowType.ripple] always animates while enabled.
  final bool animate;

  /// How the intensity changes while animating. See [GlowAnimationMode].
  final GlowAnimationMode animationMode;

  /// Length of one animation cycle (one breath, one rotation or one ripple
  /// wave lifetime).
  final Duration duration;

  /// Easing applied to breathing intensity and ripple expansion.
  /// Border rotation is always linear for a seamless loop.
  final Curve curve;

  /// Lowest intensity reached while animating.
  final double minIntensity;

  /// Highest intensity reached while animating.
  final double maxIntensity;

  /// When the glow should be visible. See [GlowTrigger].
  final GlowTrigger trigger;

  /// Duration of the fade when the glow is enabled/disabled or triggered by
  /// hover or press.
  final Duration fadeDuration;

  /// Whether this configuration needs a running animation clock.
  ///
  /// `true` for [GlowType.ripple] (which always animates) and whenever
  /// [animate] is set.
  bool get needsTicker => type == GlowType.ripple || animate;

  /// Returns a copy of this config with the given fields replaced.
  ///
  /// Nullable fields ([color], [colors], [borderRadius]) cannot be reset to
  /// `null` through [copyWith]; create a new [GlowConfig] instead.
  GlowConfig copyWith({
    GlowType? type,
    Color? color,
    List<Color>? colors,
    double? blurRadius,
    double? spreadScale,
    double? spread,
    double? intensity,
    Offset? offset,
    GlowQuality? quality,
    double? saturationBoost,
    BorderRadius? borderRadius,
    BoxShape? shape,
    double? borderWidth,
    bool? showBorder,
    bool? clockwise,
    bool? innerGlow,
    int? waveCount,
    double? maxScale,
    double? ringWidth,
    bool? enabled,
    bool? animate,
    GlowAnimationMode? animationMode,
    Duration? duration,
    Curve? curve,
    double? minIntensity,
    double? maxIntensity,
    GlowTrigger? trigger,
    Duration? fadeDuration,
  }) {
    return GlowConfig(
      type: type ?? this.type,
      color: color ?? this.color,
      colors: colors ?? this.colors,
      blurRadius: blurRadius ?? this.blurRadius,
      spreadScale: spreadScale ?? this.spreadScale,
      spread: spread ?? this.spread,
      intensity: intensity ?? this.intensity,
      offset: offset ?? this.offset,
      quality: quality ?? this.quality,
      saturationBoost: saturationBoost ?? this.saturationBoost,
      borderRadius: borderRadius ?? this.borderRadius,
      shape: shape ?? this.shape,
      borderWidth: borderWidth ?? this.borderWidth,
      showBorder: showBorder ?? this.showBorder,
      clockwise: clockwise ?? this.clockwise,
      innerGlow: innerGlow ?? this.innerGlow,
      waveCount: waveCount ?? this.waveCount,
      maxScale: maxScale ?? this.maxScale,
      ringWidth: ringWidth ?? this.ringWidth,
      enabled: enabled ?? this.enabled,
      animate: animate ?? this.animate,
      animationMode: animationMode ?? this.animationMode,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      minIntensity: minIntensity ?? this.minIntensity,
      maxIntensity: maxIntensity ?? this.maxIntensity,
      trigger: trigger ?? this.trigger,
      fadeDuration: fadeDuration ?? this.fadeDuration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GlowConfig &&
        other.type == type &&
        other.color == color &&
        listEquals(other.colors, colors) &&
        other.blurRadius == blurRadius &&
        other.spreadScale == spreadScale &&
        other.spread == spread &&
        other.intensity == intensity &&
        other.offset == offset &&
        other.quality == quality &&
        other.saturationBoost == saturationBoost &&
        other.borderRadius == borderRadius &&
        other.shape == shape &&
        other.borderWidth == borderWidth &&
        other.showBorder == showBorder &&
        other.clockwise == clockwise &&
        other.innerGlow == innerGlow &&
        other.waveCount == waveCount &&
        other.maxScale == maxScale &&
        other.ringWidth == ringWidth &&
        other.enabled == enabled &&
        other.animate == animate &&
        other.animationMode == animationMode &&
        other.duration == duration &&
        other.curve == curve &&
        other.minIntensity == minIntensity &&
        other.maxIntensity == maxIntensity &&
        other.trigger == trigger &&
        other.fadeDuration == fadeDuration;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    type,
    color,
    colors == null ? null : Object.hashAll(colors!),
    blurRadius,
    spreadScale,
    spread,
    intensity,
    offset,
    quality,
    saturationBoost,
    borderRadius,
    shape,
    borderWidth,
    showBorder,
    clockwise,
    innerGlow,
    waveCount,
    maxScale,
    ringWidth,
    enabled,
    animate,
    animationMode,
    duration,
    curve,
    minIntensity,
    maxIntensity,
    trigger,
    fadeDuration,
  ]);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    const defaults = GlowConfig();
    properties
      ..add(EnumProperty<GlowType>('type', type))
      ..add(ColorProperty('color', color, defaultValue: null))
      ..add(IterableProperty<Color>('colors', colors, defaultValue: null))
      ..add(DoubleProperty('blurRadius', blurRadius))
      ..add(
        DoubleProperty(
          'spreadScale',
          spreadScale,
          defaultValue: defaults.spreadScale,
        ),
      )
      ..add(DoubleProperty('spread', spread, defaultValue: defaults.spread))
      ..add(DoubleProperty('intensity', intensity))
      ..add(DiagnosticsProperty<Offset>('offset', offset))
      ..add(EnumProperty<GlowQuality>('quality', quality))
      ..add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'))
      ..add(FlagProperty('animate', value: animate, ifTrue: 'animated'))
      ..add(EnumProperty<GlowAnimationMode>('animationMode', animationMode))
      ..add(DiagnosticsProperty<Duration>('duration', duration))
      ..add(EnumProperty<GlowTrigger>('trigger', trigger));
  }
}
