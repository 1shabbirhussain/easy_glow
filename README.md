<p align="center">
  <img src="https://raw.githubusercontent.com/dawateislami/easy_glow/main/doc/images/banner.png" alt="easy_glow — glow effects for any Flutter widget" width="100%">
</p>

<p align="center">
  <a href="https://pub.dev/packages/easy_glow"><img src="https://img.shields.io/pub/v/easy_glow.svg?label=pub&color=00E5FF" alt="pub version"></a>
  <a href="https://pub.dev/packages/easy_glow/score"><img src="https://img.shields.io/pub/points/easy_glow?color=8BA888" alt="pub points"></a>
  <a href="https://pub.dev/packages/easy_glow/score"><img src="https://img.shields.io/pub/likes/easy_glow?color=DB4840" alt="pub likes"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-B026FF.svg" alt="MIT license"></a>
  <img src="https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20windows%20%7C%20linux-0B0F19.svg" alt="platforms">
</p>

# easy_glow

**Add neon, contour, ambient backlight, rotating gradient border, ripple pulse and box glow effects to _any_ Flutter widget — in one line.**

```dart
const Icon(Icons.bolt, size: 64).glow(color: Colors.cyanAccent);
```

- ✨ **5 glow engines** — contour, ambient, border sweep, ripple, box.
- 🧩 **Works on anything** — icons, text, transparent PNG/SVG, images, buttons, cards, avatars, text fields.
- ⚡ **One-line extensions** — `.glow()`, `.neonGlow()`, `.ambientGlow()`, `.borderGlow()`, `.rippleGlow()`, `.boxGlow()`.
- 🎛️ **Fully dynamic** — change color, blur, spread, intensity or type at runtime; toggling fades smoothly.
- 🫁 **Animations built in** — breathe, pulse, neon flicker, rotation and ripple waves.
- 🖱️ **Interactive** — show the glow only on hover and/or press.
- 🚀 **Fast** — repaint boundaries, no rebuilds per frame, tickers only while something actually animates, zero cost when disabled.
- 📦 **Zero dependencies** — pure Flutter SDK, every platform.

---

## Table of contents

- [Installation](#installation)
- [Glow types at a glance](#glow-types-at-a-glance)
- [Usage](#usage)
  - [Contour / neon glow](#1-contour--neon-glow)
  - [Ambient backlight](#2-ambient-backlight)
  - [Rotating gradient border](#3-rotating-gradient-border)
  - [Ripple / radar pulse](#4-ripple--radar-pulse)
  - [Box glow](#5-box-glow)
- [Animation](#animation)
- [Hover & press triggers](#hover--press-triggers)
- [Dynamic glows with `GlowConfig`](#dynamic-glows-with-glowconfig)
- [API reference](#api-reference)
- [Performance tips](#performance-tips)
- [Good to know](#good-to-know)
- [Example app](#example-app)

---

## Installation

```bash
flutter pub add easy_glow
```

```dart
import 'package:easy_glow/easy_glow.dart';
```

Requires Flutter 3.32+ (Dart 3.8+).

## Glow types at a glance

| Type | Extension | Named constructor | Best for | Re-renders child? |
| --- | --- | --- | --- | --- |
| `GlowType.contour` | `.glow()` / `.neonGlow()` | `EasyGlow.neon` | Icons, text, logos, transparent PNG/SVG | Yes (blurred copy) |
| `GlowType.ambient` | `.ambientGlow()` | `EasyGlow.ambient` | Album art, product shots, media cards | Yes (blurred copy) |
| `GlowType.borderSweep` | `.borderGlow()` | `EasyGlow.borderSweep` | CTA buttons, search bars, pricing cards | No |
| `GlowType.ripple` | `.rippleGlow()` | `EasyGlow.ripple` | Live avatars, mic/record buttons, badges | No |
| `GlowType.box` | `.boxGlow()` | `EasyGlow.box` | Cards, buttons, containers | No |

<!-- SCREENSHOT: add a GIF of the five types, e.g.
<p align="center"><img src="https://raw.githubusercontent.com/dawateislami/easy_glow/main/doc/images/types.gif" alt="The five glow types" width="100%"></p>
-->

## Usage

### 1. Contour / neon glow

Follows the **alpha channel** of the child, so transparent pixels never glow and there is no rectangular box — the glow hugs the exact outline of icons, letters and cut-out images.

```dart
// One-liner
const Icon(Icons.favorite, size: 64, color: Colors.white)
    .glow(color: Colors.pinkAccent, blurRadius: 20);

// Bright core + soft halo (GlowQuality.high)
Text('NEON', style: TextStyle(fontSize: 64, color: Colors.white))
    .neonGlow(color: Colors.cyanAccent, animate: true);

// Transparent PNG
Image.asset('assets/logo.png', width: 120).glow(color: Colors.amber);

// Widget form with every option
EasyGlow.neon(
  color: Colors.cyanAccent,
  blurRadius: 18,
  spreadScale: 1.05,
  intensity: 0.9,
  offset: const Offset(0, 4),
  animate: true,
  animationMode: GlowAnimationMode.flicker,
  child: SvgPicture.asset('assets/rocket.svg'), // any widget works
);
```

### 2. Ambient backlight

A YouTube-style "ambient mode": the child's **own colors** bleed outward behind it. No color to pick — it adapts to the image.

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: Image.network(albumCoverUrl, width: 160),
).ambientGlow(blurRadius: 28, spreadScale: 1.1, saturationBoost: 1.3);
```

### 3. Rotating gradient border

An AI / cyberpunk-style multi-color border that rotates around the child, with a soft halo. The child is **not duplicated**, so it is safe on `TextField`s and stateful widgets.

```dart
FilledButton(onPressed: () {}, child: const Text('Ask AI'))
    .borderGlow(borderRadius: 24);

// Custom colors, slower, counter-clockwise
TextField(decoration: InputDecoration(hintText: 'Search…'))
    .borderGlow(
      colors: [Colors.cyan, Colors.purple, Colors.pink],
      borderRadius: 16,
      borderWidth: 2,
      duration: const Duration(seconds: 5),
      clockwise: false,
    );

// Round widgets
const CircleAvatar(radius: 32).borderGlow(circle: true);
```

> The child is padded by `borderWidth` so the border never covers content. Match `borderRadius` to the child's own corner radius.

### 4. Ripple / radar pulse

Staggered rings expand and fade behind the child — perfect for "live" indicators.

```dart
// Soft pulses
const CircleAvatar(radius: 32).rippleGlow(color: Colors.greenAccent);

// Radar rings
const Icon(Icons.wifi_tethering).rippleGlow(ringWidth: 2, waveCount: 4, maxScale: 2.4);

// Rounded-rectangle rings for a FAB
FloatingActionButton(onPressed: () {}, child: const Icon(Icons.mic))
    .rippleGlow(circle: false, borderRadius: 16, color: Colors.redAccent);
```

### 5. Box glow

The cheapest glow: one blurred shape painted **outside** the child (so translucent cards are not tinted). Optional inset glow for a neon-tube look.

```dart
Card(child: ...).boxGlow(color: Colors.purpleAccent, borderRadius: 12);

Container(...).boxGlow(innerGlow: true, colors: [Colors.cyan, Colors.pink]);

FloatingActionButton(onPressed: () {}).boxGlow(circle: true);
```

## Animation

Set `animate: true` on any glow:

| Mode | Effect |
| --- | --- |
| `GlowAnimationMode.breathe` (default) | Smoothly oscillates between `minIntensity` and `maxIntensity` |
| `GlowAnimationMode.pulse` | Ramps up from `minIntensity` to `maxIntensity`, then restarts |
| `GlowAnimationMode.flicker` | Steady with short irregular dips, like a neon sign |

```dart
const Icon(Icons.bolt, size: 64).glow(
  animate: true,
  animationMode: GlowAnimationMode.breathe,
  minIntensity: 0.3,
  maxIntensity: 1.0,
  duration: const Duration(milliseconds: 1200),
  curve: Curves.easeInOut,
);
```

`borderSweep` uses `animate` for **rotation** (on by default, one turn per `duration`), and `ripple` **always** animates (one wave lifetime per `duration`).

## Hover & press triggers

```dart
ElevatedButton(onPressed: () {}, child: const Text('Buy'))
    .boxGlow(trigger: GlowTrigger.hoverOrPress);
```

| Trigger | Glow is shown |
| --- | --- |
| `GlowTrigger.always` | Always (default) |
| `GlowTrigger.hover` | While a mouse hovers the child |
| `GlowTrigger.press` | While the child is pressed |
| `GlowTrigger.hoverOrPress` | Either — works on desktop, web and touch |

Triggers use passive listeners: your `onPressed`/`onTap` callbacks keep working unchanged. The fade length is `GlowConfig.fadeDuration` (250 ms by default).

## Dynamic glows with `GlowConfig`

Every glow is described by an immutable `GlowConfig`. Rebuild with a new config and the glow updates in place — the child keeps its state and `enabled` changes fade smoothly.

```dart
class LikeButton extends StatefulWidget { ... }

class _LikeButtonState extends State<LikeButton> {
  bool liked = false;

  @override
  Widget build(BuildContext context) {
    return EasyGlow(
      config: GlowConfig(
        type: GlowType.contour,
        color: Colors.pinkAccent,
        enabled: liked,          // fades in/out
        animate: liked,
        blurRadius: 22,
      ),
      child: IconButton(
        icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
        onPressed: () => setState(() => liked = !liked),
      ),
    );
  }
}
```

Reuse a config anywhere with `.withGlow(config)` or tweak it with `config.copyWith(...)`.

## API reference

<details>
<summary><b>GlowConfig fields</b> (click to expand)</summary>

| Field | Default | Applies to | Description |
| --- | --- | --- | --- |
| `type` | `contour` | all | Glow engine |
| `color` | theme primary | contour, ripple, box | Glow tint |
| `colors` | cyan→purple→pink | borderSweep, box | Gradient colors (loop closed automatically) |
| `blurRadius` | `18` | all | Blur in logical pixels |
| `spreadScale` | `1.05` | contour, ambient | Size of the glow relative to the child |
| `spread` | `0` | box, borderSweep | Extra glow size in logical pixels |
| `intensity` | `0.85` | all | Opacity `0..1` when not animating |
| `offset` | `Offset.zero` | contour, ambient, box, ripple | Shifts the glow |
| `quality` | `standard` | contour, ambient | `high` = bright core + soft halo |
| `saturationBoost` | `1.0` | ambient | Color vividness |
| `borderRadius` | `null` | box, borderSweep, ripple | Corner radius |
| `shape` | `rectangle` | box, borderSweep, ripple | `BoxShape.circle` for round widgets |
| `borderWidth` | `2` | borderSweep | Crisp border width (child is padded by this) |
| `showBorder` | `true` | borderSweep | `false` = halo only |
| `clockwise` | `true` | borderSweep | Rotation direction |
| `innerGlow` | `false` | box | Adds an inset glow |
| `waveCount` | `3` | ripple | Number of rings |
| `maxScale` | `1.6` | ripple | How far rings grow |
| `ringWidth` | `0` | ripple | `> 0` draws outlined radar rings |
| `enabled` | `true` | all | Show/hide with a fade |
| `animate` | `false` | all | Breathing / rotation |
| `animationMode` | `breathe` | contour, ambient, box | `breathe`, `pulse`, `flicker` |
| `duration` | `1600 ms` | all | Length of one cycle |
| `curve` | `easeInOut` | contour, ambient, box, ripple | Easing |
| `minIntensity` / `maxIntensity` | `0.4` / `1.0` | contour, ambient, box | Animated intensity range |
| `trigger` | `always` | all | `hover`, `press`, `hoverOrPress` |
| `fadeDuration` | `250 ms` | all | Enable / trigger fade length |

</details>

Full API docs: [pub.dev/documentation/easy_glow](https://pub.dev/documentation/easy_glow/latest/).

The painters (`NeonBorderPainter`, `RipplePainter`, `BoxGlowPainter`) are exported too, if you want to use them in your own `CustomPaint`.

## Performance tips

- Glow layers are wrapped in `RepaintBoundary`, and animations drive `FadeTransition`s and painters directly, so **no widgets rebuild per frame** and the parent never repaints.
- Tickers run **only** while a glow is visible and animating; disabled / un-hovered glows cost nothing.
- `GlowType.box` and `GlowType.borderSweep` are the cheapest options for rectangular widgets — prefer them in long lists.
- `GlowQuality.high` renders two blurred layers; use `GlowQuality.standard` (default for `.glow()`) in grids.
- Very large blur radii on large widgets are GPU-heavy on low-end devices; 10–30 px usually looks best.

## Good to know

- **Silhouette types re-render the child.** `contour` and `ambient` draw a blurred copy of your widget behind it. The copy ignores taps, focus, semantics and heroes, but:
  - If the child has a **`GlobalKey`**, or owns a controller (e.g. a `TextField`), pass a lightweight look-alike via `silhouette:` — or use `borderSweep` / `box`.
  - Stateful children (e.g. a running animation) get a separate state in the copy.
  ```dart
  EasyGlow(
    config: const GlowConfig(color: Colors.cyanAccent),
    silhouette: const Icon(Icons.search, size: 28), // what glows
    child: IconButton(key: myGlobalKey, icon: const Icon(Icons.search, size: 28), onPressed: () {}),
  );
  ```
- **Glows paint outside the child's bounds.** Ancestors that clip (`ClipRect`, `ListView` edges, `Card` with `clipBehavior`) can cut the glow — give the glow some padding.
- **Layout size never changes**, except `borderSweep`, which pads the child by `borderWidth`.

## Example app

The [example](https://github.com/dawateislami/easy_glow/tree/main/example) is an interactive dark-mode playground with live sliders for blur, spread, intensity and speed, color presets, four showcase tabs and a **Code** button that copies the exact snippet for the current settings.

```bash
cd example
flutter create . --project-name easy_glow_example   # first time only: generates platform folders
flutter run
```

<!-- SCREENSHOT: add a recording of the playground, e.g.
<p align="center"><img src="https://raw.githubusercontent.com/dawateislami/easy_glow/main/doc/images/playground.gif" alt="easy_glow playground" width="360"></p>
-->

## Contributing

Issues and pull requests are welcome on [GitHub](https://github.com/dawateislami/easy_glow). Before opening a PR, run:

```bash
dart format .
flutter analyze
flutter test
```

## License

[MIT](LICENSE)
