import 'package:easy_glow/easy_glow.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

const Widget _label = Text('glow', textDirection: TextDirection.ltr);

void main() {
  group('EasyGlow contour', () {
    testWidgets('renders the child plus one blurred copy', (tester) async {
      await tester.pumpWidget(_host(const EasyGlow(child: _label)));

      expect(find.text('glow'), findsNWidgets(2));
      expect(find.byType(SilhouetteGlowLayer), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SilhouetteGlowLayer),
          matching: find.byType(ImageFiltered),
        ),
        findsOneWidget,
      );
    });

    testWidgets('high quality stacks a core and a halo layer', (tester) async {
      await tester.pumpWidget(_host(EasyGlow.neon(child: _label)));

      expect(find.text('glow'), findsNWidgets(3));
      expect(
        find.descendant(
          of: find.byType(SilhouetteGlowLayer),
          matching: find.byType(ImageFiltered),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('does not change the layout size of the child', (tester) async {
      const Key key = Key('box');
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 100,
            height: 50,
            key: key,
          ).glow(blurRadius: 30, spreadScale: 1.4),
        ),
      );

      expect(tester.getSize(find.byType(EasyGlow)), const Size(100, 50));
    });

    testWidgets('silhouette is used for the copy when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const EasyGlow(
            silhouette: Text('stand-in', textDirection: TextDirection.ltr),
            child: _label,
          ),
        ),
      );

      expect(find.text('glow'), findsOneWidget);
      expect(find.text('stand-in'), findsOneWidget);
    });

    testWidgets('asserts when the child has a GlobalKey', (tester) async {
      await tester.pumpWidget(
        _host(EasyGlow(child: SizedBox(key: GlobalKey(), width: 10))),
      );

      expect(tester.takeException(), isA<AssertionError>());
    });
  });

  group('enabled', () {
    testWidgets('enabled: false renders only the child', (tester) async {
      await tester.pumpWidget(
        _host(
          const EasyGlow(config: GlowConfig(enabled: false), child: _label),
        ),
      );

      expect(find.text('glow'), findsOneWidget);
      expect(find.byType(SilhouetteGlowLayer), findsNothing);
    });

    testWidgets('toggling enabled fades out and removes the glow', (
      tester,
    ) async {
      Widget build(bool enabled) => _host(
        EasyGlow(
          config: GlowConfig(enabled: enabled),
          child: _label,
        ),
      );

      await tester.pumpWidget(build(true));
      expect(find.byType(SilhouetteGlowLayer), findsOneWidget);

      await tester.pumpWidget(build(false));
      // Still fading out.
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(SilhouetteGlowLayer), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(SilhouetteGlowLayer), findsNothing);
      expect(find.text('glow'), findsOneWidget);

      await tester.pumpWidget(build(true));
      await tester.pumpAndSettle();
      expect(find.byType(SilhouetteGlowLayer), findsOneWidget);
    });

    testWidgets('keeps the child state when the glow is toggled', (
      tester,
    ) async {
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);

      Widget build(bool enabled) => _host(
        SizedBox(
          width: 200,
          child: TextField(controller: controller),
        ).borderGlow(enabled: enabled, animate: false),
      );

      await tester.pumpWidget(build(true));
      await tester.enterText(find.byType(TextField), 'hello');
      final State before = tester.state(find.byType(EditableText));

      await tester.pumpWidget(build(false));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(tester.state(find.byType(EditableText)), same(before));
      expect(controller.text, 'hello');
    });
  });

  group('interaction', () {
    testWidgets('taps reach the real child exactly once', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          ElevatedButton(
            onPressed: () => taps++,
            child: const Text('tap'),
          ).glow(blurRadius: 20),
        ),
      );

      // The copy is rendered too, but ignores pointers.
      expect(find.text('tap'), findsNWidgets(2));
      await tester.tap(find.byType(ElevatedButton).last, warnIfMissed: false);
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('glow copy is excluded from semantics', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const EasyGlow(child: _label)));

      expect(find.bySemanticsLabel('glow'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('hover trigger shows the glow only while hovered', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 80,
            height: 40,
          ).boxGlow(trigger: GlowTrigger.hover),
        ),
      );
      expect(_boxGlowPainters(tester), isEmpty);

      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(EasyGlow)));
      await tester.pumpAndSettle();
      expect(_boxGlowPainters(tester), hasLength(1));

      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(_boxGlowPainters(tester), isEmpty);
    });

    testWidgets('press trigger shows the glow while pressed', (tester) async {
      await tester.pumpWidget(
        _host(
          const ColoredBox(
            color: Colors.black,
            child: SizedBox(width: 80, height: 40),
          ).boxGlow(trigger: GlowTrigger.press),
        ),
      );
      expect(_boxGlowPainters(tester), isEmpty);

      final TestGesture press = await tester.startGesture(
        tester.getCenter(find.byType(EasyGlow)),
      );
      await tester.pumpAndSettle();
      expect(_boxGlowPainters(tester), hasLength(1));

      await press.up();
      await tester.pumpAndSettle();
      expect(_boxGlowPainters(tester), isEmpty);
    });
  });

  group('animation lifecycle', () {
    for (final GlowType type in GlowType.values) {
      testWidgets('$type animates and disposes without ticker leaks', (
        tester,
      ) async {
        await tester.pumpWidget(
          _host(
            EasyGlow(
              config: GlowConfig(
                type: type,
                animate: true,
                duration: const Duration(milliseconds: 500),
              ),
              child: const SizedBox(width: 60, height: 60),
            ),
          ),
        );
        // A repeating animation keeps an active ticker.
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.binding.transientCallbackCount, greaterThan(0));
        await tester.pump(const Duration(milliseconds: 700));

        // Removing the widget must dispose every ticker cleanly.
        await tester.pumpWidget(const SizedBox());
        expect(tester.takeException(), isNull);
        expect(tester.binding.transientCallbackCount, 0);
      });
    }

    testWidgets('static glow does not schedule frames', (tester) async {
      await tester.pumpWidget(_host(const EasyGlow(child: _label)));
      await tester.pump();

      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('disabling an animated glow stops its ticker', (tester) async {
      Widget build(bool enabled) => _host(
        const SizedBox(width: 40, height: 40).rippleGlow(enabled: enabled),
      );

      await tester.pumpWidget(build(true));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.transientCallbackCount, greaterThan(0));

      await tester.pumpWidget(build(false));
      await tester.pumpAndSettle();
      expect(tester.binding.transientCallbackCount, 0);
      expect(_painters<RipplePainter>(tester), isEmpty);
    });

    for (final GlowAnimationMode mode in GlowAnimationMode.values) {
      testWidgets('$mode keeps opacity within min/max intensity', (
        tester,
      ) async {
        await tester.pumpWidget(
          _host(
            EasyGlow(
              config: GlowConfig(
                animate: true,
                animationMode: mode,
                minIntensity: 0.3,
                maxIntensity: 0.9,
                duration: const Duration(milliseconds: 400),
              ),
              child: _label,
            ),
          ),
        );
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 37));
          // Opacity = animated intensity × visibility (fully visible here).
          final SilhouetteGlowLayer layer = tester.widget<SilhouetteGlowLayer>(
            find.byType(SilhouetteGlowLayer),
          );
          expect(layer.opacity!.value, inInclusiveRange(0.3, 0.9));
        }
      });
    }
  });

  group('rendering', () {
    for (final GlowType type in GlowType.values) {
      testWidgets('$type does not use opacity widgets (Impeller-safe)', (
        tester,
      ) async {
        await tester.pumpWidget(
          _host(
            EasyGlow(
              config: GlowConfig(type: type, animate: true, innerGlow: true),
              child: const SizedBox(width: 60, height: 60),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        final Finder inGlow = find.descendant(
          of: find.byType(EasyGlow),
          matching: find.byWidgetPredicate(
            (Widget w) => w is FadeTransition || w is Opacity,
          ),
        );
        expect(inGlow, findsNothing);
      });
    }
  });

  group('border sweep', () {
    testWidgets('pads the child by the border width', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 100,
            height: 50,
          ).borderGlow(borderWidth: 3, animate: false),
        ),
      );

      expect(tester.getSize(find.byType(EasyGlow)), const Size(106, 56));
      expect(_painters<NeonBorderPainter>(tester), hasLength(1));
    });

    testWidgets('does not duplicate the child', (tester) async {
      await tester.pumpWidget(_host(_label.borderGlow()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.text('glow'), findsOneWidget);
    });
  });

  group('box glow', () {
    testWidgets('inner glow adds a foreground painter', (tester) async {
      await tester.pumpWidget(
        _host(const SizedBox(width: 80, height: 40).boxGlow(innerGlow: true)),
      );

      final List<BoxGlowPainter> painters = _boxGlowPainters(tester);
      expect(painters, hasLength(2));
      expect(painters.where((BoxGlowPainter p) => p.inner), hasLength(1));
    });
  });

  group('extensions', () {
    test('glow() builds a contour EasyGlow by default', () {
      final Widget w = _label.glow(color: Colors.red, blurRadius: 12);

      expect(w, isA<EasyGlow>());
      final GlowConfig c = (w as EasyGlow).config;
      expect(c.type, GlowType.contour);
      expect(c.color, Colors.red);
      expect(c.blurRadius, 12);
    });

    test('each extension maps to the matching glow type', () {
      GlowType typeOf(Widget w) => (w as EasyGlow).config.type;

      expect(typeOf(_label.neonGlow()), GlowType.contour);
      expect(typeOf(_label.ambientGlow()), GlowType.ambient);
      expect(typeOf(_label.borderGlow()), GlowType.borderSweep);
      expect(typeOf(_label.rippleGlow()), GlowType.ripple);
      expect(typeOf(_label.boxGlow()), GlowType.box);
      expect(
        typeOf(_label.withGlow(const GlowConfig(type: GlowType.box))),
        GlowType.box,
      );
    });

    test('borderGlow forwards radius, circle and timing', () {
      final GlowConfig c =
          (_label.borderGlow(
                    borderRadius: 24,
                    circle: true,
                    duration: const Duration(seconds: 5),
                  )
                  as EasyGlow)
              .config;

      expect(c.borderRadius, BorderRadius.circular(24));
      expect(c.shape, BoxShape.circle);
      expect(c.duration, const Duration(seconds: 5));
      expect(c.animate, isTrue);
    });

    test('rippleGlow always animates', () {
      final GlowConfig c = (_label.rippleGlow() as EasyGlow).config;
      expect(c.animate, isTrue);
      expect(c.needsTicker, isTrue);
    });
  });

  group('GlowConfig', () {
    test('supports value equality', () {
      const GlowConfig a = GlowConfig(colors: <Color>[Colors.red, Colors.blue]);
      final GlowConfig b = GlowConfig(colors: <Color>[Colors.red, Colors.blue]);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == a.copyWith(blurRadius: 3), isFalse);
    });

    test('copyWith replaces only the given fields', () {
      const GlowConfig base = GlowConfig(color: Colors.green, intensity: 0.5);
      final GlowConfig next = base.copyWith(type: GlowType.box, spread: 4);

      expect(next.type, GlowType.box);
      expect(next.spread, 4);
      expect(next.color, Colors.green);
      expect(next.intensity, 0.5);
    });

    test('needsTicker only when animating or rippling', () {
      expect(const GlowConfig().needsTicker, isFalse);
      expect(const GlowConfig(animate: true).needsTicker, isTrue);
      expect(const GlowConfig(type: GlowType.ripple).needsTicker, isTrue);
    });

    test('rejects invalid intensity ranges', () {
      expect(
        () => GlowConfig(minIntensity: 0.9, maxIntensity: 0.1),
        throwsAssertionError,
      );
    });
  });
}

List<T> _painters<T extends CustomPainter>(WidgetTester tester) {
  final List<T> result = <T>[];
  for (final CustomPaint paint in tester.widgetList<CustomPaint>(
    find.byType(CustomPaint),
  )) {
    final CustomPainter? p = paint.painter;
    if (p is T) result.add(p);
  }
  return result;
}

List<BoxGlowPainter> _boxGlowPainters(WidgetTester tester) =>
    _painters<BoxGlowPainter>(tester);
