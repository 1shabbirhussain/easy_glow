import 'package:easy_glow/easy_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const EasyGlowPlaygroundApp());

/// Playground background.
const Color kBackground = Color(0xFF0B0F19);

/// Card / panel surface.
const Color kSurface = Color(0xFF121829);

/// Named palette used by the color chips.
const Map<String, Color> kPalette = <String, Color>{
  'Cyber Cyan': Color(0xFF00E5FF),
  'Neon Emerald': Color(0xFF8BA888),
  'Sunset Coral': Color(0xFFDB4840),
  'Electric Purple': Color(0xFFB026FF),
  'Gold': Color(0xFFFFC94D),
};

class EasyGlowPlaygroundApp extends StatelessWidget {
  const EasyGlowPlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'easy_glow playground',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: kPalette['Cyber Cyan'],
        scaffoldBackgroundColor: kBackground,
      ),
      home: const PlaygroundPage(),
    );
  }
}

/// Values driven by the live control panel.
@immutable
class PlaygroundControls {
  const PlaygroundControls({
    this.blurRadius = 18,
    this.spreadScale = 1.05,
    this.intensity = 0.85,
    this.speedMs = 1600,
    this.animate = true,
    this.enabled = true,
    this.colorName = 'Cyber Cyan',
  });

  final double blurRadius;
  final double spreadScale;
  final double intensity;
  final double speedMs;
  final bool animate;
  final bool enabled;
  final String colorName;

  Color get color => kPalette[colorName]!;
  Duration get duration => Duration(milliseconds: speedMs.round());

  /// A seamless sweep gradient built around the selected color.
  List<Color> get sweepColors => <Color>[
    color,
    kPalette['Electric Purple']!,
    kPalette['Sunset Coral']!,
    color,
  ];

  /// Maps the 1.0–1.5 spread slider to a 1.2–2.2 ripple scale.
  double get rippleScale => 1.2 + (spreadScale - 1.0) * 2;

  PlaygroundControls copyWith({
    double? blurRadius,
    double? spreadScale,
    double? intensity,
    double? speedMs,
    bool? animate,
    bool? enabled,
    String? colorName,
  }) {
    return PlaygroundControls(
      blurRadius: blurRadius ?? this.blurRadius,
      spreadScale: spreadScale ?? this.spreadScale,
      intensity: intensity ?? this.intensity,
      speedMs: speedMs ?? this.speedMs,
      animate: animate ?? this.animate,
      enabled: enabled ?? this.enabled,
      colorName: colorName ?? this.colorName,
    );
  }
}

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this)
    ..addListener(() => setState(() {}));
  PlaygroundControls _c = const PlaygroundControls();

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String _hex(Color c) =>
      'Color(0x${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()})';

  String _snippet() {
    final PlaygroundControls c = _c;
    final String blur = c.blurRadius.toStringAsFixed(1);
    final String spread = c.spreadScale.toStringAsFixed(2);
    final String intensity = c.intensity.toStringAsFixed(2);
    final String ms = c.speedMs.round().toString();
    switch (_tabs.index) {
      case 0:
        return 'Icon(Icons.bolt, size: 72).glow(\n'
            '  color: ${_hex(c.color)},\n'
            '  blurRadius: $blur,\n'
            '  spreadScale: $spread,\n'
            '  intensity: $intensity,\n'
            '  animate: ${c.animate},\n'
            '  duration: const Duration(milliseconds: $ms),\n'
            '  enabled: ${c.enabled},\n'
            ')';
      case 1:
        return 'Image.asset(\'assets/album.png\').ambientGlow(\n'
            '  blurRadius: $blur,\n'
            '  spreadScale: $spread,\n'
            '  intensity: $intensity,\n'
            '  saturationBoost: 1.3,\n'
            '  animate: ${c.animate},\n'
            '  duration: const Duration(milliseconds: $ms),\n'
            '  enabled: ${c.enabled},\n'
            ')';
      case 2:
        return 'FilledButton(onPressed: () {}, child: Text(\'Ask AI\'))\n'
            '    .borderGlow(\n'
            '  colors: [${c.sweepColors.map(_hex).join(', ')}],\n'
            '  borderRadius: 28,\n'
            '  blurRadius: $blur,\n'
            '  intensity: $intensity,\n'
            '  animate: ${c.animate},\n'
            '  duration: const Duration(milliseconds: $ms),\n'
            '  enabled: ${c.enabled},\n'
            ')';
      default:
        return 'CircleAvatar(radius: 36).rippleGlow(\n'
            '  color: ${_hex(c.color)},\n'
            '  maxScale: ${c.rippleScale.toStringAsFixed(2)},\n'
            '  intensity: $intensity,\n'
            '  duration: const Duration(milliseconds: $ms),\n'
            '  enabled: ${c.enabled},\n'
            ')';
    }
  }

  void _showCode() {
    final String code = _snippet();
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Copy-paste snippet'),
        content: SingleChildScrollView(
          child: SelectableText(
            code,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                this.context,
              ).showSnackBar(const SnackBar(content: Text('Snippet copied')));
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget showcase = TabBarView(
      controller: _tabs,
      children: <Widget>[
        ContourTab(c: _c),
        AmbientTab(c: _c),
        BorderTab(c: _c),
        RippleTab(c: _c),
      ],
    );
    final Widget panel = ControlPanel(
      controls: _c,
      onChanged: (PlaygroundControls value) => setState(() => _c = value),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackground,
        title: Text(
          'easy_glow',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ).neonGlow(color: _c.color, blurRadius: 10),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonalIcon(
              onPressed: _showCode,
              icon: const Icon(Icons.code_rounded),
              label: const Text('Code'),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: const <Widget>[
            Tab(icon: Icon(Icons.auto_awesome), text: 'Contour'),
            Tab(icon: Icon(Icons.album_rounded), text: 'Ambient'),
            Tab(icon: Icon(Icons.rotate_right_rounded), text: 'Border'),
            Tab(icon: Icon(Icons.radar_rounded), text: 'Ripple'),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth >= 900) {
            return Row(
              children: <Widget>[
                Expanded(child: showcase),
                SizedBox(width: 360, child: panel),
              ],
            );
          }
          return Column(
            children: <Widget>[
              Expanded(child: showcase),
              panel,
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Control panel
// ---------------------------------------------------------------------------

class ControlPanel extends StatelessWidget {
  const ControlPanel({
    super.key,
    required this.controls,
    required this.onChanged,
  });

  final PlaygroundControls controls;
  final ValueChanged<PlaygroundControls> onChanged;

  @override
  Widget build(BuildContext context) {
    final PlaygroundControls c = controls;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      constraints: const BoxConstraints(maxHeight: 360),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _LabeledSlider(
              label: 'Blur radius',
              value: c.blurRadius,
              min: 0,
              max: 60,
              display: c.blurRadius.toStringAsFixed(0),
              onChanged: (double v) => onChanged(c.copyWith(blurRadius: v)),
            ),
            _LabeledSlider(
              label: 'Spread scale',
              value: c.spreadScale,
              min: 1,
              max: 1.5,
              display: c.spreadScale.toStringAsFixed(2),
              onChanged: (double v) => onChanged(c.copyWith(spreadScale: v)),
            ),
            _LabeledSlider(
              label: 'Intensity',
              value: c.intensity,
              min: 0,
              max: 1,
              display: c.intensity.toStringAsFixed(2),
              onChanged: (double v) => onChanged(c.copyWith(intensity: v)),
            ),
            _LabeledSlider(
              label: 'Cycle (ms)',
              value: c.speedMs,
              min: 400,
              max: 5000,
              display: c.speedMs.round().toString(),
              onChanged: (double v) => onChanged(c.copyWith(speedMs: v)),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Animate'),
                    value: c.animate,
                    onChanged: (bool v) => onChanged(c.copyWith(animate: v)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enabled'),
                    value: c.enabled,
                    onChanged: (bool v) => onChanged(c.copyWith(enabled: v)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final MapEntry<String, Color> e in kPalette.entries)
                  ChoiceChip(
                    selected: c.colorName == e.key,
                    onSelected: (_) => onChanged(c.copyWith(colorName: e.key)),
                    avatar: CircleAvatar(backgroundColor: e.value, radius: 8),
                    label: Text(e.key),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(width: 96, child: Text(label)),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        SizedBox(
          width: 44,
          child: Text(
            display,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared layout helpers
// ---------------------------------------------------------------------------

class _ShowcaseGrid extends StatelessWidget {
  const _ShowcaseGrid({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      children: <Widget>[
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white60),
        ),
        const SizedBox(height: 40),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 56,
          runSpacing: 64,
          children: children,
        ),
      ],
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled(this.label, this.child);

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 150, child: Center(child: child)),
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1 – contour
// ---------------------------------------------------------------------------

class ContourTab extends StatelessWidget {
  const ContourTab({super.key, required this.c});

  final PlaygroundControls c;

  Widget _glow(Widget child, {GlowQuality quality = GlowQuality.high}) {
    return child.glow(
      color: c.color,
      blurRadius: c.blurRadius,
      spreadScale: c.spreadScale,
      intensity: c.intensity,
      quality: quality,
      animate: c.animate,
      duration: c.duration,
      enabled: c.enabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ShowcaseGrid(
      title:
          'GlowType.contour follows the alpha channel of icons, text and '
          'transparent images — no rectangular box.',
      children: <Widget>[
        _Labeled(
          'Icon',
          _glow(const Icon(Icons.bolt_rounded, size: 88, color: Colors.white)),
        ),
        _Labeled('Transparent vector logo', _glow(const FlutterLogo(size: 96))),
        _Labeled(
          'Typography',
          _glow(
            const Text(
              'NEON',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                color: Colors.white,
              ),
            ),
          ),
        ),
        _Labeled(
          'Badge (standard quality)',
          _glow(
            const Icon(Icons.verified_rounded, size: 80, color: Colors.white),
            quality: GlowQuality.standard,
          ),
        ),
        _Labeled(
          'Flicker mode',
          const Icon(
            Icons.local_bar_rounded,
            size: 80,
            color: Colors.white,
          ).neonGlow(
            color: c.color,
            blurRadius: c.blurRadius,
            animate: true,
            animationMode: GlowAnimationMode.flicker,
            duration: const Duration(seconds: 3),
            enabled: c.enabled,
          ),
        ),
        _Labeled(
          'Hover / press trigger',
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.touch_app_rounded),
            label: const Text('Hover or press me'),
          ).boxGlow(
            color: c.color,
            borderRadius: 24,
            blurRadius: c.blurRadius,
            intensity: c.intensity,
            trigger: GlowTrigger.hoverOrPress,
            enabled: c.enabled,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2 – ambient
// ---------------------------------------------------------------------------

class AmbientTab extends StatelessWidget {
  const AmbientTab({super.key, required this.c});

  final PlaygroundControls c;

  Widget _ambient(Widget child) => child.ambientGlow(
    blurRadius: c.blurRadius + 10,
    spreadScale: c.spreadScale + 0.03,
    intensity: c.intensity,
    saturationBoost: 1.3,
    animate: c.animate,
    duration: c.duration,
    enabled: c.enabled,
  );

  @override
  Widget build(BuildContext context) {
    return _ShowcaseGrid(
      title:
          'GlowType.ambient bleeds the child\'s own colors outward like a '
          'TV backlight — perfect for album art and product shots.',
      children: <Widget>[
        _Labeled('Album art', _ambient(const _AlbumArt())),
        _Labeled(
          'Transparent product',
          _ambient(
            ShaderMask(
              shaderCallback: (Rect r) => const LinearGradient(
                colors: <Color>[Color(0xFFFF4081), Color(0xFFFFC94D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(r),
              child: const Icon(
                Icons.headphones_rounded,
                size: 120,
                color: Colors.white,
              ),
            ),
          ),
        ),
        _Labeled(
          'Media card',
          _ambient(
            Container(
              width: 200,
              height: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFF00C6FF), Color(0xFF0072FF)],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(Icons.play_circle_fill_rounded, color: Colors.white),
                  SizedBox(height: 6),
                  Text(
                    'Ocean Drive',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AlbumArt extends StatelessWidget {
  const _AlbumArt();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const SweepGradient(
          colors: <Color>[
            Color(0xFFB026FF),
            Color(0xFFFF4081),
            Color(0xFFFFC94D),
            Color(0xFF00E5FF),
            Color(0xFFB026FF),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.graphic_eq_rounded, size: 56, color: Colors.white),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 3 – border sweep
// ---------------------------------------------------------------------------

class BorderTab extends StatelessWidget {
  const BorderTab({super.key, required this.c});

  final PlaygroundControls c;

  @override
  Widget build(BuildContext context) {
    final Duration rotation = Duration(milliseconds: (c.speedMs * 2).round());
    return _ShowcaseGrid(
      title:
          'GlowType.borderSweep rotates a gradient border around any widget. '
          'It never duplicates the child, so it is safe on text fields.',
      children: <Widget>[
        _Labeled(
          'CTA button',
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: kSurface,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            ),
            onPressed: () {},
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Ask AI'),
          ).borderGlow(
            colors: c.sweepColors,
            borderRadius: 30,
            blurRadius: c.blurRadius,
            intensity: c.intensity,
            animate: c.animate,
            duration: rotation,
            enabled: c.enabled,
          ),
        ),
        _Labeled(
          'Search bar',
          SizedBox(
            width: 280,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search anything…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: kSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ).borderGlow(
            colors: c.sweepColors,
            borderRadius: 16,
            blurRadius: c.blurRadius,
            intensity: c.intensity,
            animate: c.animate,
            duration: rotation,
            enabled: c.enabled,
          ),
        ),
        _Labeled(
          'Pricing card',
          const _PricingCard().borderGlow(
            colors: c.sweepColors,
            borderRadius: 22,
            borderWidth: 2.5,
            blurRadius: c.blurRadius,
            intensity: c.intensity,
            animate: c.animate,
            duration: rotation,
            enabled: c.enabled,
          ),
        ),
        _Labeled(
          'Box glow + inner glow',
          const SizedBox(
            width: 180,
            height: 110,
            child: Center(
              child: Text(
                'PRO',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
            ),
          ).boxGlow(
            color: c.color,
            borderRadius: 18,
            blurRadius: c.blurRadius,
            intensity: c.intensity,
            innerGlow: true,
            animate: c.animate,
            duration: c.duration,
            enabled: c.enabled,
          ),
        ),
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Pro', style: TextStyle(color: Colors.white70)),
          SizedBox(height: 4),
          Text(
            '\$9 / mo',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Text(
            'Unlimited glows',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 4 – ripple
// ---------------------------------------------------------------------------

class RippleTab extends StatelessWidget {
  const RippleTab({super.key, required this.c});

  final PlaygroundControls c;

  @override
  Widget build(BuildContext context) {
    return _ShowcaseGrid(
      title:
          'GlowType.ripple emits staggered rings — great for live avatars, '
          'recording indicators and call-to-action buttons.',
      children: <Widget>[
        _Labeled(
          'Live avatar',
          CircleAvatar(
            radius: 36,
            backgroundColor: c.color,
            child: const Text(
              'MA',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ).rippleGlow(
            color: c.color,
            maxScale: c.rippleScale,
            blurRadius: c.blurRadius / 3,
            intensity: c.intensity,
            duration: c.duration,
            enabled: c.enabled,
          ),
        ),
        _Labeled(
          'Radar rings',
          Icon(
            Icons.wifi_tethering_rounded,
            size: 48,
            color: c.color,
          ).rippleGlow(
            color: c.color,
            waveCount: 4,
            ringWidth: 2,
            blurRadius: 1,
            maxScale: c.rippleScale + 0.6,
            intensity: c.intensity,
            duration: c.duration * 1.5,
            enabled: c.enabled,
          ),
        ),
        _Labeled(
          'Mic button',
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: kPalette['Sunset Coral'],
            child: const Icon(Icons.mic_rounded, color: Colors.white),
          ).rippleGlow(
            color: kPalette['Sunset Coral'],
            maxScale: c.rippleScale,
            blurRadius: c.blurRadius / 3,
            intensity: c.intensity,
            circle: false,
            borderRadius: 16,
            duration: c.duration,
            enabled: c.enabled,
          ),
        ),
      ],
    );
  }
}
