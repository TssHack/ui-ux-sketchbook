import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'rough.dart';

/// Hand-lettered Latin text: every letter sits a little differently, and lines
/// break only between words. Screen readers get the plain text once.
///
/// Not for Persian or Arabic: splitting into letters breaks the joins.
/// Give it a handwriting font, e.g. `TextStyle(fontFamily: 'GochiHand')`.
class HandText extends StatelessWidget {
  const HandText(this.text, {super.key, this.seed = 1, this.style, this.alignment = WrapAlignment.center});

  final String text;
  final int seed;
  final TextStyle? style;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final r = sketchRng(seed);
    final base = DefaultTextStyle.of(context).style.merge(style);
    final size = base.fontSize ?? 14;
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);

    return Semantics(
      label: text,
      excludeSemantics: true,
      // Latin lettering stays left-to-right inside RTL layouts.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Wrap(
          alignment: alignment,
          spacing: size * 0.32,
          children: [
            // A single word wider than the space scales down instead of overflowing.
            for (final word in words)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nested transforms rather than Matrix4.translate/scale, which newer SDKs deprecate.
                  for (final ch in word.characters)
                    Transform.translate(
                      offset: Offset(0, (r() - 0.5) * 0.12 * size),
                      child: Transform.rotate(
                        angle: (r() - 0.5) * 9 * math.pi / 180,
                        child: Transform.scale(scale: 0.92 + r() * 0.16, child: Text(ch, style: base)),
                      ),
                    ),
                ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
