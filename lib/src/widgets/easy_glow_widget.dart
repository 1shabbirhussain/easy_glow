import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../enums/glow_type.dart';
import '../models/glow_config.dart';
import '../painters/box_glow_painter.dart';
import '../painters/neon_border_painter.dart';
import '../painters/ripple_wave_painter.dart';
import 'silhouette_glow_layer.dart';

/// Adds a glow effect to any widget.
///
/// `EasyGlow` never changes the layout size of its child: glows are painted
/// outside the child's bounds without clipping. The only exception is
/// [GlowType.borderSweep], which pads the child by
/// [GlowConfig.borderWidth] so the crisp border never covers content.
///
/// Use the default constructor with a [GlowConfig], or one of the
/// pre-configured named constructors:
///
/// * [EasyGlow.neon] – alpha-contour glow for icons, text and transparent
///   images.
/// * [EasyGlow.ambient] – backlight that bleeds the child's own colors.
/// * [EasyGlow.borderSweep] – rotating gradient border for CTAs and cards.
/// * [EasyGlow.ripple] – expanding pulse rings for avatars and badges.
/// * [EasyGlow.box] – cheap neon glow for rectangular / circular widgets.
///
/// For one-liners, see the extension methods such as `Widget.glow()`.
///
/// ```dart
/// EasyGlow.neon(
///   color: Colors.cyanAccent,
///   animate: true,
///   child: const Icon(Icons.bolt, size: 64, color: Colors.white),
/// )
/// ```
///
/// ### Silhouette types and the child
///
/// [GlowType.contour] and [GlowType.ambient] render a second, blurred copy
/// of [child] behind it. The copy ignores pointers, focus, semantics and
/// heroes, but if [child] has a `GlobalKey`, owns a controller (e.g. a
/// `TextField`) or is expensive to build, pass a lightweight look-alike via
/// [silhouette], or use [GlowType.box] / [GlowType.borderSweep] instead.
class EasyGlow extends StatefulWidget {
  /// Creates a glow described by [config].
  const EasyGlow({
    super.key,
    required this.child,
    this.config = const GlowConfig(),
    this.silhouette,
  });

  /// Pre-configured alpha-contour neon glow ([GlowType.contour]).
  ///
  /// Follows the exact shape of icons, text, transparent PNGs and SVGs.
  /// Uses [GlowQuality.high] (bright core + soft halo) by default.
  EasyGlow.neon({
    Key? key,
    required Widget child,
    Color? color,
    double blurRadius = 16.0,
    double spreadScale = 1.04,
    double intensity = 0.9,
    Offset offset = Offset.zero,
    GlowQuality quality = GlowQuality.high,
    bool enabled = true,
    bool animate = false,
    GlowAnimationMode animationMode = GlowAnimationMode.breathe,
    Duration duration = const Duration(milliseconds: 1600),
    Curve curve = Curves.easeInOut,
    double minIntensity = 0.4,
    double maxIntensity = 1.0,
    GlowTrigger trigger = GlowTrigger.always,
    Widget? silhouette,
  }) : this(
         key: key,
         silhouette: silhouette,
         config: GlowConfig(
           type: GlowType.contour,
           color: color,
           blurRadius: blurRadius,
           spreadScale: spreadScale,
           intensity: intensity,
           offset: offset,
           quality: quality,
           enabled: enabled,
           animate: animate,
           animationMode: animationMode,
           duration: duration,
           curve: curve,
           minIntensity: minIntensity,
           maxIntensity: maxIntensity,
           trigger: trigger,
         ),
         child: child,
       );

  /// Pre-configured ambient backlight glow ([GlowType.ambient]).
  ///
  /// Spreads the child's own colors behind it — ideal for album art,
  /// product shots and media cards.
  EasyGlow.ambient({
    Key? key,
    required Widget child,
    double blurRadius = 28.0,
    double spreadScale = 1.08,
    double intensity = 0.8,
    double saturationBoost = 1.3,
    Offset offset = Offset.zero,
    bool enabled = true,
    bool animate = false,
    GlowAnimationMode animationMode = GlowAnimationMode.breathe,
    Duration duration = const Duration(milliseconds: 2400),
    Curve curve = Curves.easeInOut,
    double minIntensity = 0.5,
    double maxIntensity = 1.0,
    GlowTrigger trigger = GlowTrigger.always,
    Widget? silhouette,
  }) : this(
         key: key,
         silhouette: silhouette,
         config: GlowConfig(
           type: GlowType.ambient,
           blurRadius: blurRadius,
           spreadScale: spreadScale,
           intensity: intensity,
           saturationBoost: saturationBoost,
           offset: offset,
           enabled: enabled,
           animate: animate,
           animationMode: animationMode,
           duration: duration,
           curve: curve,
           minIntensity: minIntensity,
           maxIntensity: maxIntensity,
           trigger: trigger,
         ),
         child: child,
       );

  /// Pre-configured rotating gradient border ([GlowType.borderSweep]).
  ///
  /// Rotates by default (`animate: true`). Set [borderRadius] to match the
  /// child's own corner radius, or use `shape: BoxShape.circle`.
  EasyGlow.borderSweep({
    Key? key,
    required Widget child,
    List<Color> colors = defaultSweepColors,
    BorderRadius? borderRadius = const BorderRadius.all(Radius.circular(16)),
    BoxShape shape = BoxShape.rectangle,
    double borderWidth = 2.0,
    double spread = 6.0,
    double blurRadius = 14.0,
    double intensity = 0.9,
    bool showBorder = true,
    bool clockwise = true,
    bool enabled = true,
    bool animate = true,
    Duration duration = const Duration(seconds: 3),
    GlowTrigger trigger = GlowTrigger.always,
  }) : this(
         key: key,
         config: GlowConfig(
           type: GlowType.borderSweep,
           colors: colors,
           borderRadius: borderRadius,
           shape: shape,
           borderWidth: borderWidth,
           spread: spread,
           blurRadius: blurRadius,
           intensity: intensity,
           showBorder: showBorder,
           clockwise: clockwise,
           enabled: enabled,
           animate: animate,
           duration: duration,
           trigger: trigger,
         ),
         child: child,
       );

  /// Pre-configured expanding ripple / radar pulse ([GlowType.ripple]).
  ///
  /// Always animates while enabled. Use `ringWidth > 0` for outlined radar
  /// rings instead of soft filled pulses.
  EasyGlow.ripple({
    Key? key,
    required Widget child,
    Color? color,
    int waveCount = 3,
    double maxScale = 1.6,
    double blurRadius = 6.0,
    double ringWidth = 0.0,
    double intensity = 0.6,
    BoxShape shape = BoxShape.circle,
    BorderRadius? borderRadius,
    Offset offset = Offset.zero,
    bool enabled = true,
    Duration duration = const Duration(seconds: 2),
    Curve curve = Curves.easeOut,
    GlowTrigger trigger = GlowTrigger.always,
  }) : this(
         key: key,
         config: GlowConfig(
           type: GlowType.ripple,
           color: color,
           waveCount: waveCount,
           maxScale: maxScale,
           blurRadius: blurRadius,
           ringWidth: ringWidth,
           intensity: intensity,
           shape: shape,
           borderRadius: borderRadius,
           offset: offset,
           enabled: enabled,
           animate: true,
           duration: duration,
           curve: curve,
           trigger: trigger,
         ),
         child: child,
       );

  /// Pre-configured box / container neon glow ([GlowType.box]).
  ///
  /// The cheapest glow: a single blurred shape behind the child. Match
  /// [borderRadius] (or [shape]) to the child's outline.
  EasyGlow.box({
    Key? key,
    required Widget child,
    Color? color,
    List<Color>? colors,
    BorderRadius? borderRadius = const BorderRadius.all(Radius.circular(16)),
    BoxShape shape = BoxShape.rectangle,
    double blurRadius = 18.0,
    double spread = 2.0,
    double intensity = 0.85,
    bool innerGlow = false,
    Offset offset = Offset.zero,
    bool enabled = true,
    bool animate = false,
    GlowAnimationMode animationMode = GlowAnimationMode.breathe,
    Duration duration = const Duration(milliseconds: 1600),
    Curve curve = Curves.easeInOut,
    double minIntensity = 0.4,
    double maxIntensity = 1.0,
    GlowTrigger trigger = GlowTrigger.always,
  }) : this(
         key: key,
         config: GlowConfig(
           type: GlowType.box,
           color: color,
           colors: colors,
           borderRadius: borderRadius,
           shape: shape,
           blurRadius: blurRadius,
           spread: spread,
           intensity: intensity,
           innerGlow: innerGlow,
           offset: offset,
           enabled: enabled,
           animate: animate,
           animationMode: animationMode,
           duration: duration,
           curve: curve,
           minIntensity: minIntensity,
           maxIntensity: maxIntensity,
           trigger: trigger,
         ),
         child: child,
       );

  /// The default cyan → purple → pink gradient used by border glows.
  static const List<Color> defaultSweepColors = <Color>[
    Color(0xFF18FFFF),
    Color(0xFFE040FB),
    Color(0xFFFF4081),
    Color(0xFF18FFFF),
  ];

  /// The widget that receives the glow.
  final Widget child;

  /// Describes the glow. See [GlowConfig].
  final GlowConfig config;

  /// Optional stand-in rendered (blurred) instead of [child] by the
  /// silhouette types ([GlowType.contour] and [GlowType.ambient]).
  ///
  /// Use it when [child] carries a `GlobalKey`, owns controllers or is
  /// expensive — e.g. pass the same `Icon` or `Image` without its
  /// surrounding button.
  final Widget? silhouette;

  @override
  State<EasyGlow> createState() => _EasyGlowState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GlowConfig>('config', config));
  }
}

class _EasyGlowState extends State<EasyGlow> with TickerProviderStateMixin {
  static const Key _childKey = ValueKey<String>('easy_glow.child');
  static const Key _backKey = ValueKey<String>('easy_glow.back');
  static const Key _frontKey = ValueKey<String>('easy_glow.front');

  /// Drives the glow visibility (enable / hover / press fades).
  late final AnimationController _visibility;
  late final CurvedAnimation _visibilityCurve;

  /// The animation clock: breathing, rotation or ripple emission.
  /// Created lazily, only while an animation is actually running.
  AnimationController? _clock;
  bool _clockReverses = false;

  Animation<double> _intensity = const AlwaysStoppedAnimation<double>(1);

  bool _hovered = false;
  bool _pressed = false;

  GlowConfig get _config => widget.config;

  bool get _shouldShow {
    final GlowConfig c = _config;
    if (!c.enabled) return false;
    switch (c.trigger) {
      case GlowTrigger.always:
        return true;
      case GlowTrigger.hover:
        return _hovered;
      case GlowTrigger.press:
        return _pressed;
      case GlowTrigger.hoverOrPress:
        return _hovered || _pressed;
    }
  }

  bool get _glowVisible =>
      _shouldShow || _visibility.status != AnimationStatus.dismissed;

  @override
  void initState() {
    super.initState();
    _visibility = AnimationController(
      vsync: this,
      duration: _config.fadeDuration,
      value: _shouldShow ? 1.0 : 0.0,
    )..addStatusListener(_onVisibilityStatus);
    _visibilityCurve = CurvedAnimation(
      parent: _visibility,
      curve: Curves.easeOut,
    );
    _syncClock();
  }

  @override
  void didUpdateWidget(EasyGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _visibility.duration = _config.fadeDuration;
    if (oldWidget.config != _config) {
      _updateVisibility();
      _syncClock(force: true);
    }
  }

  @override
  void dispose() {
    _visibilityCurve.dispose();
    _visibility.dispose();
    _clock?.dispose();
    super.dispose();
  }

  void _onVisibilityStatus(AnimationStatus status) {
    // Rebuild only at the edges so the glow subtree is added/removed and
    // the clock started/stopped. Intermediate values never rebuild.
    if (status == AnimationStatus.dismissed ||
        status == AnimationStatus.forward) {
      _syncClock();
      if (mounted) setState(() {});
    }
  }

  void _updateVisibility() {
    if (_shouldShow) {
      if (_visibility.status != AnimationStatus.completed &&
          _visibility.status != AnimationStatus.forward) {
        _visibility.forward();
      }
    } else if (_visibility.status != AnimationStatus.dismissed &&
        _visibility.status != AnimationStatus.reverse) {
      _visibility.reverse();
    }
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    _hovered = value;
    _updateVisibility();
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    _pressed = value;
    _updateVisibility();
  }

  void _syncClock({bool force = false}) {
    final GlowConfig c = _config;
    final bool needed = c.needsTicker && c.enabled && _glowVisible;
    if (!needed) {
      _clock?.dispose();
      _clock = null;
      _intensity = AlwaysStoppedAnimation<double>(c.intensity);
      return;
    }
    final bool reverse =
        c.animationMode == GlowAnimationMode.breathe &&
        c.type != GlowType.borderSweep &&
        c.type != GlowType.ripple;
    AnimationController? clock = _clock;
    if (clock == null) {
      clock = _clock = AnimationController(vsync: this, duration: c.duration);
      force = true;
    } else if (clock.duration != c.duration) {
      clock.duration = c.duration;
      force = true;
    }
    if (force || reverse != _clockReverses || !clock.isAnimating) {
      _clockReverses = reverse;
      clock.repeat(reverse: reverse);
    }
    _intensity = _buildIntensity(clock, c);
  }

  Animation<double> _buildIntensity(AnimationController clock, GlowConfig c) {
    if (!c.animate) return AlwaysStoppedAnimation<double>(c.intensity);
    final double lo = c.minIntensity;
    final double hi = c.maxIntensity;
    switch (c.animationMode) {
      case GlowAnimationMode.breathe:
      case GlowAnimationMode.pulse:
        return clock
            .drive(CurveTween(curve: c.curve))
            .drive(Tween<double>(begin: lo, end: hi));
      case GlowAnimationMode.flicker:
        return clock.drive(
          TweenSequence<double>(<TweenSequenceItem<double>>[
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(hi),
              weight: 40,
            ),
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(lo),
              weight: 3,
            ),
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(hi),
              weight: 6,
            ),
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(lo),
              weight: 2,
            ),
            TweenSequenceItem<double>(
              tween: ConstantTween<double>(hi),
              weight: 30,
            ),
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: hi, end: (lo + hi) / 2),
              weight: 4,
            ),
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: (lo + hi) / 2, end: hi),
              weight: 15,
            ),
          ]),
        );
    }
  }

  Color _resolveColor(BuildContext context) =>
      _config.color ?? Theme.of(context).colorScheme.primary;

  Animation<double> get _clockOrZero =>
      _clock ?? const AlwaysStoppedAnimation<double>(0);

  /// Combined glow opacity: animated intensity × visibility fade.
  ///
  /// Opacity is applied inside the painters and color filters instead of
  /// with opacity layers, because an opacity layer over a blurred
  /// mask-filter draw triggers validation errors on the Impeller renderer.
  Animation<double> get _glowOpacity =>
      _ProductAnimation(_intensity, _visibilityCurve);

  Widget _buildBackground(BuildContext context) {
    final GlowConfig c = _config;
    final bool circle = c.shape == BoxShape.circle;
    switch (c.type) {
      case GlowType.contour:
      case GlowType.ambient:
        return SilhouetteGlowLayer(
          color: c.type == GlowType.contour ? _resolveColor(context) : null,
          blurRadius: c.blurRadius,
          spreadScale: c.spreadScale,
          saturationBoost: c.saturationBoost,
          quality: c.quality,
          offset: c.offset,
          opacity: _glowOpacity,
          child: widget.silhouette ?? widget.child,
        );
      case GlowType.box:
        return RepaintBoundary(
          child: CustomPaint(
            painter: BoxGlowPainter(
              color: _resolveColor(context),
              colors: c.colors,
              borderRadius: c.borderRadius,
              circle: circle,
              blurRadius: c.blurRadius,
              spread: c.spread,
              offset: c.offset,
              opacity: _glowOpacity,
            ),
          ),
        );
      case GlowType.borderSweep:
        return RepaintBoundary(
          child: CustomPaint(
            painter: NeonBorderPainter(
              progress: _clockOrZero,
              colors: c.colors ?? EasyGlow.defaultSweepColors,
              borderRadius: c.borderRadius,
              circle: circle,
              borderWidth: c.borderWidth,
              spread: c.spread,
              blurRadius: c.blurRadius,
              intensity: c.intensity,
              showBorder: c.showBorder,
              clockwise: c.clockwise,
              opacity: _visibilityCurve,
            ),
          ),
        );
      case GlowType.ripple:
        return RepaintBoundary(
          child: CustomPaint(
            painter: RipplePainter(
              progress: _clockOrZero,
              color: _resolveColor(context),
              waveCount: c.waveCount,
              maxScale: c.maxScale,
              curve: c.curve,
              circle: circle,
              borderRadius: c.borderRadius,
              blurRadius: c.blurRadius,
              ringWidth: c.ringWidth,
              intensity: c.intensity,
              offset: c.offset,
              opacity: _visibilityCurve,
            ),
          ),
        );
    }
  }

  Widget _buildForeground(BuildContext context) {
    final GlowConfig c = _config;
    return RepaintBoundary(
      child: CustomPaint(
        painter: BoxGlowPainter(
          color: _resolveColor(context),
          colors: c.colors,
          borderRadius: c.borderRadius,
          circle: c.shape == BoxShape.circle,
          blurRadius: c.blurRadius,
          inner: true,
          opacity: _glowOpacity,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlowConfig c = _config;
    assert(
      !(c.type == GlowType.contour || c.type == GlowType.ambient) ||
          widget.silhouette != null ||
          widget.child.key is! GlobalKey,
      'EasyGlow: the child has a GlobalKey, but contour/ambient glows render '
      'a second copy of the child, which would duplicate the key. Pass a '
      'key-less look-alike via `silhouette:`, or use GlowType.box / '
      'GlowType.borderSweep.',
    );
    final bool show = _glowVisible;
    final bool front = show && c.type == GlowType.box && c.innerGlow;

    final Widget content = Padding(
      key: _childKey,
      padding: c.type == GlowType.borderSweep
          ? EdgeInsets.all(c.borderWidth)
          : EdgeInsets.zero,
      child: widget.child,
    );

    final bool tracksHover =
        c.trigger == GlowTrigger.hover || c.trigger == GlowTrigger.hoverOrPress;
    final bool tracksPress =
        c.trigger == GlowTrigger.press || c.trigger == GlowTrigger.hoverOrPress;

    return MouseRegion(
      opaque: false,
      onEnter: tracksHover ? (_) => _setHovered(true) : null,
      onExit: tracksHover ? (_) => _setHovered(false) : null,
      child: Listener(
        onPointerDown: tracksPress ? (_) => _setPressed(true) : null,
        onPointerUp: tracksPress ? (_) => _setPressed(false) : null,
        onPointerCancel: tracksPress ? (_) => _setPressed(false) : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            if (show)
              Positioned.fill(
                key: _backKey,
                child: IgnorePointer(child: _buildBackground(context)),
              ),
            content,
            if (front)
              Positioned.fill(
                key: _frontKey,
                child: IgnorePointer(child: _buildForeground(context)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Multiplies two animations, e.g. intensity × visibility.
class _ProductAnimation extends CompoundAnimation<double> {
  _ProductAnimation(Animation<double> a, Animation<double> b)
    : super(first: a, next: b);

  @override
  double get value => first.value * next.value;
}
