/// Glow effects for any Flutter widget.
///
/// `easy_glow` adds neon contour, ambient backlight, rotating gradient
/// border, ripple pulse and box glows to icons, text, images, buttons and
/// containers — with a wrapper widget ([EasyGlow]) or one-line extensions
/// (`.glow()`, `.neonGlow()`, `.ambientGlow()`, `.borderGlow()`,
/// `.rippleGlow()`, `.boxGlow()`).
///
/// ```dart
/// import 'package:easy_glow/easy_glow.dart';
///
/// const Icon(Icons.bolt, size: 64).glow(color: Colors.cyanAccent);
/// ```
library;

export 'src/enums/glow_type.dart';
export 'src/extensions/easy_glow_extensions.dart';
export 'src/models/glow_config.dart';
export 'src/painters/box_glow_painter.dart';
export 'src/painters/neon_border_painter.dart';
export 'src/painters/ripple_wave_painter.dart';
export 'src/widgets/easy_glow_widget.dart';
export 'src/widgets/silhouette_glow_layer.dart';
