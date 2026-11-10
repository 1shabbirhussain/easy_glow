## 0.1.0

Initial release.

* `EasyGlow` widget with five glow engines:
  * `GlowType.contour` — alpha-aware silhouette / neon glow for icons, text and transparent images.
  * `GlowType.ambient` — backlight that bleeds the child's own colors, with saturation boost.
  * `GlowType.borderSweep` — rotating multi-color gradient border with a soft halo.
  * `GlowType.ripple` — staggered expanding pulse / radar rings.
  * `GlowType.box` — fast outer (and optional inner) neon glow for cards and buttons.
* Named constructors: `EasyGlow.neon`, `.ambient`, `.borderSweep`, `.ripple`, `.box`.
* Widget extensions: `.glow()`, `.neonGlow()`, `.ambientGlow()`, `.borderGlow()`, `.rippleGlow()`, `.boxGlow()`, `.withGlow()`.
* Immutable `GlowConfig` with `copyWith`, value equality and diagnostics.
* Breathe, pulse and flicker animations; smooth enable/disable fades.
* Hover / press triggers via `GlowTrigger`.
* `GlowQuality.high` two-layer neon rendering.
* Exported painters: `NeonBorderPainter`, `RipplePainter`, `BoxGlowPainter`.
* Interactive example playground.
