# easy_glow example

Interactive dark-mode playground for [easy_glow](https://pub.dev/packages/easy_glow).

- Live sliders for blur radius, spread scale, intensity and cycle speed
- Animate / enabled toggles and color presets
- Four showcase tabs: Contour, Ambient, Border sweep, Ripple
- **Code** button that copies the `.glow(...)` snippet for the current settings

```bash
flutter create . --project-name easy_glow_example   # first run only
flutter run
```

The core of every demo is a one-liner:

```dart
const Icon(Icons.bolt, size: 72).glow(color: Colors.cyanAccent, animate: true);
```
