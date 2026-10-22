import 'package:flutter/material.dart';
import 'package:flutter_cafe/main.dart';
import 'package:flutter_test/flutter_test.dart';

/// The page is a lazily built CustomScrollView, so lower sections exist only once scrolled to.
Future<void> scrollTo(WidgetTester tester, Finder target) async {
  await tester.dragUntilVisible(target, find.byType(CustomScrollView), const Offset(0, -250));
  await tester.pumpAndSettle();
}

void main() {
  for (final size in const [Size(360, 800), Size(768, 1024), Size(1280, 900)]) {
    testWidgets('home page lays out without overflow at ${size.width.toInt()}px', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const CafeApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Every section on the way down must lay out cleanly too.
      await scrollTo(tester, find.text('پیشنهادهای این هفته'));
      expect(tester.takeException(), isNull);
      await scrollTo(tester, find.text('ساخته‌شده با پکیج فلاتر ui-ux-sketchbook'));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('adding a dish shows a confirmation and counts it in the cart', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CafeApp());
    await tester.pumpAndSettle();
    // `.first` throws while nothing matches, so scroll by the section heading first.
    await scrollTo(tester, find.text('پیشنهادهای این هفته'));
    await tester.ensureVisible(find.text('+ افزودن').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ افزودن').first);
    await tester.pump();
    expect(find.textContaining('به سبد اضافه شد'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget); // cart badge in the header
  });
}
