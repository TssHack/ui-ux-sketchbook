import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sketchbook/sketchbook.dart';

Widget _host(Widget child, {TextDirection dir = TextDirection.rtl}) => MaterialApp(
      home: Directionality(
        textDirection: dir,
        child: Scaffold(body: Center(child: SizedBox(width: 320, child: child))),
      ),
    );

void main() {
  group('svg path parser', () {
    test('reads absolute and relative commands, arcs and curves', () {
      final p = parseSvgPath('M10 20 L30 20 l0 10 H5 v-5 Q5 5 10 5 C12 2 14 2 16 5 Z');
      final b = p.getBounds();
      expect(b.left, closeTo(5, 0.01));
      expect(b.right, closeTo(30, 0.01));
      expect(b.bottom, closeTo(30, 0.01));
    });

    test('ellipse from two arcs has the expected bounds', () {
      final b = parseSvgPath('M20 30 a20 10 0 1 0 40 0 a20 10 0 1 0 -40 0 Z').getBounds();
      expect(b.width, closeTo(40, 0.5));
      expect(b.height, closeTo(20, 0.5));
    });

    test('transform list applies right to left like SVG', () {
      final m = parseSvgTransform('translate(10 0) rotate(90 0 0)')!;
      final p = parseSvgPath('M0 0 L10 0').transform(m);
      final b = p.getBounds();
      expect(b.left, closeTo(10, 0.01));
      expect(b.bottom, closeTo(10, 0.01));
    });
  });

  test('rough geometry is deterministic per seed', () {
    final a = roughRoundRect(const Size(200, 100), seed: 4).getBounds();
    final b = roughRoundRect(const Size(200, 100), seed: 4).getBounds();
    final c = roughRoundRect(const Size(200, 100), seed: 5).getBounds();
    expect(a, b);
    expect(a == c, isFalse);
  });

  test('every ready illustration parses', () {
    expect(sketchArt.length, 15);
    for (final entry in sketchArt.entries) {
      for (final s in entry.value.shapes) {
        expect(() => parseSvgPath(s.d), returnsNormally, reason: '${entry.key}: ${s.d}');
      }
    }
  });

  testWidgets('SketchBox renders framed, banded and shaded boxes', (tester) async {
    await tester.pumpWidget(_host(const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SketchBox(tint: SketchColors.caramel, seed: 21, padding: EdgeInsets.all(16), child: Text('کارت')),
        SketchBox(edges: {SketchEdge.bottom}, tint: SketchColors.sage, child: SizedBox(height: 40)),
        SketchBox(radius: 999, child: SizedBox(width: 56, height: 56)),
      ],
    )));
    expect(tester.takeException(), isNull);
    expect(find.text('کارت'), findsOneWidget);
  });

  testWidgets('every illustration paints, full and lite', (tester) async {
    await tester.pumpWidget(_host(Wrap(children: [
      for (final name in sketchArt.keys) ...[
        SketchDrawing.named(name, width: 60),
        SketchDrawing.named(name, width: 30, lite: true),
      ],
    ])));
    expect(tester.takeException(), isNull);
    expect(find.byType(SketchDrawing), findsNWidgets(30));
  });

  testWidgets('draw-in animation runs to completion', (tester) async {
    await tester.pumpWidget(_host(SketchDrawing.named('latte', label: 'Latte', drawIn: true)));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('labelled drawings and hand lettering are read once by screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(const Column(children: [
      HandText('Special menu', style: TextStyle(fontSize: 32)),
    ])));
    await tester.pumpWidget(_host(Column(children: [
      const HandText('Special menu', style: TextStyle(fontSize: 32)),
      SketchDrawing.named('croissant', label: 'Chocolate croissant'),
      SketchDrawing.named('bean'),
    ])));
    expect(find.bySemanticsLabel('Special menu'), findsOneWidget);
    expect(find.bySemanticsLabel('Chocolate croissant'), findsOneWidget);
    handle.dispose();
  });

  test('unknown illustration names fail clearly', () {
    expect(() => SketchDrawing.named('unicorn'), throwsArgumentError);
  });
}
