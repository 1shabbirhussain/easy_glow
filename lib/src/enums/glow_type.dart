/// The rendering engine used by an `EasyGlow` widget.
///
/// Each type is tuned for a different kind of child:
///
/// | Type | Best for | Duplicates child? |
/// | --- | --- | --- |
/// | [contour] | Icons, text, transparent PNG/SVG, logos | Yes |
/// | [ambient] | Photos, album art, product images, cards | Yes |
/// | [borderSweep] | CTA buttons, search bars, pricing cards | No |
/// | [ripple] | Avatars, live badges, FABs | No |
/// | [box] | Cards, buttons, containers | No |
enum GlowType {
  /// Alpha-aware silhouette glow that follows the exact shape of the child.
  ///
  /// The child is re-rendered behind itself, tinted with a single color and
  /// blurred, so transparent pixels never glow. Works on irregular shapes
  /// such as icons, text and transparent images.
  contour,

  /// YouTube-style ambient backlight that bleeds the child's own colors.
  ///
  /// The child is re-rendered behind itself, scaled up, blurred and
  /// optionally saturated — without overriding its colors.
  ambient,

  /// A rotating multi-color `SweepGradient` border with a soft outer glow,
  /// similar to AI / cyberpunk call-to-action styles.
  borderSweep,

  /// Staggered rings that expand and fade out behind the child, like a
  /// radar ping or a "live" indicator.
  ripple,

  /// A fast rectangular / rounded / circular neon glow drawn with a
  /// `MaskFilter`. The cheapest option for cards and buttons.
  box,
}

/// Rendering quality for silhouette based glows ([GlowType.contour] and
/// [GlowType.ambient]).
enum GlowQuality {
  /// One blurred layer. Cheapest; ideal for long lists and grids.
  standard,

  /// Two stacked layers: a tight bright core plus a wide soft halo.
  /// Produces the most convincing neon look at roughly twice the cost.
  high,
}

/// How the glow intensity changes over time when animation is enabled.
///
/// Rotation ([GlowType.borderSweep]) and wave emission ([GlowType.ripple])
/// are driven by the same animation clock and ignore this setting.
enum GlowAnimationMode {
  /// Smoothly oscillates between the minimum and maximum intensity.
  breathe,

  /// Ramps from the minimum to the maximum intensity, then restarts.
  pulse,

  /// Mostly steady with short, irregular dips — like a neon tube sign.
  flicker,
}

/// When the glow is shown.
enum GlowTrigger {
  /// The glow is always shown (while enabled).
  always,

  /// The glow fades in while a mouse pointer hovers over the child.
  ///
  /// On touch-only devices the glow never appears; consider [hoverOrPress].
  hover,

  /// The glow fades in while the child is being pressed.
  press,

  /// The glow fades in while the child is hovered or pressed.
  hoverOrPress,
}
