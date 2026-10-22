import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'colors.dart';
import 'rough.dart';

/// Which edges of a [SketchBox] get an ink line. Leave `edges` null for a closed frame.
enum SketchEdge { top, right, bottom, left }

/// A box with a hand-drawn outline (two passes of the pen) and optional
/// coloured-pencil shading that gathers along the inside of its edges.
///
/// ```dart
/// SketchBox(tint: SketchColors.caramel, seed: 21, child: ...)              // framed card
/// SketchBox(edges: {SketchEdge.bottom}, tint: SketchColors.sage, ...)      // band with one rough edge
/// ```
class SketchBox extends StatelessWidget {
  const SketchBox({
    super.key,
    this.child,
    this.seed = 1,
    this.radius = 16,
    this.edges,
    this.tint,
    this.edgeReach = const Offset(0.2, 0.26),
    this.tintStrength = 0.8,
    this.background,
    this.padding,
    this.inkColor = SketchColors.ink,
    this.strokeWidth = 2.2,
  });

  final Widget? child;

  /// Varies the wobble; give neighbouring boxes different seeds.
  final int seed;
  final double radius;

  /// Null for a closed rounded frame, or the edges to draw (bands, dividers).
  final Set<SketchEdge>? edges;

  /// Pencil colour for the edge shading; null for none.
  final Color? tint;

  /// How far the shading reaches in, as a fraction of width (dx) and height (dy).
  /// Cards ~0.2, large panels ~0.1, bands and buttons 0.5 (shaded all over).
  final Offset edgeReach;
  final double tintStrength;
  final Color? background;
  final EdgeInsetsGeometry? padding;
  final Color inkColor;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final r = edges == null ? radius : 0.0;
    return CustomPaint(
      painter: _ShadePainter(tint: tint, background: background, radius: r, reach: edgeReach, strength: tintStrength),
      foregroundPainter: _InkPainter(seed: seed, radius: radius, edges: edges, color: inkColor, width: strokeWidth),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
  }
}

class _ShadePainter extends CustomPainter {
  _ShadePainter({this.tint, this.background, required this.radius, required this.reach, required this.strength});
  final Color? tint;
  final Color? background;
  final double radius;
  final Offset reach;
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect.deflate(2), Radius.circular(radius));
    if (background != null) canvas.drawRRect(rr, Paint()..color = background!);
    final tint = this.tint;
    if (tint == null || size.isEmpty) return;

    canvas.save();
    canvas.clipRRect(rr);
    // Layer 1: wash + diagonal pencil strokes, at the overall strength.
    canvas.saveLayer(rect, Paint()..color = Color.fromRGBO(0, 0, 0, strength));
    canvas.drawRect(rect, Paint()..color = tint.withValues(alpha: 0.55));
    final hatch = Paint()
      ..color = tint
      ..strokeWidth = 1.2;
    final d = size.longestSide;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(112 * math.pi / 180);
    for (var x = -d; x <= d; x += 3.4) {
      canvas.drawLine(Offset(x, -d), Offset(x, d), hatch);
    }
    canvas.restore();

    // Layer 2: keep it only near the edges (four gradients added together).
    canvas.saveLayer(rect, Paint()..blendMode = BlendMode.dstIn);
    final rx = size.width * reach.dx, ry = size.height * reach.dy;
    void band(Rect r, Alignment from, Alignment to) {
      canvas.drawRect(
        r,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = LinearGradient(begin: from, end: to, colors: const [Color(0xFF000000), Color(0x00000000)]).createShader(r),
      );
    }

    band(Rect.fromLTWH(0, 0, rx, size.height), Alignment.centerLeft, Alignment.centerRight);
    band(Rect.fromLTWH(size.width - rx, 0, rx, size.height), Alignment.centerRight, Alignment.centerLeft);
    band(Rect.fromLTWH(0, 0, size.width, ry), Alignment.topCenter, Alignment.bottomCenter);
    band(Rect.fromLTWH(0, size.height - ry, size.width, ry), Alignment.bottomCenter, Alignment.topCenter);
    canvas.restore();
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShadePainter old) =>
      old.tint != tint || old.background != background || old.radius != radius || old.reach != reach || old.strength != strength;
}

class _InkPainter extends CustomPainter {
  _InkPainter({required this.seed, required this.radius, required this.edges, required this.color, required this.width});
  final int seed;
  final double radius;
  final Set<SketchEdge>? edges;
  final Color color;
  final double width;

  static final Map<String, List<Path>> _cache = {};

  List<Path> _paths(Size s) {
    final key = '${s.width.round()}x${s.height.round()}|$seed|$radius|${edges?.map((e) => e.index).join(',')}';
    return _cache.putIfAbsent(key, () {
      if (_cache.length > 400) _cache.clear();
      final edges = this.edges;
      if (edges == null) {
        return [
          roughRoundRect(s, radius: radius, seed: seed, amp: 1.5),
          roughRoundRect(s, radius: radius + 2, seed: seed + 97, amp: 2, inset: 3),
        ];
      }
      final w = s.width, h = s.height;
      Path line(SketchEdge e, int sd, double amp) => switch (e) {
            SketchEdge.top => roughLine(Offset(-4, 1.5), Offset(w + 4, 1.5), seed: sd, amp: amp),
            SketchEdge.bottom => roughLine(Offset(-4, h - 1.5), Offset(w + 4, h - 1.5), seed: sd, amp: amp),
            SketchEdge.left => roughLine(Offset(1.5, -4), Offset(1.5, h + 4), seed: sd, amp: amp),
            SketchEdge.right => roughLine(Offset(w - 1.5, -4), Offset(w - 1.5, h + 4), seed: sd, amp: amp),
          };
      var i = 0;
      return [
        for (final e in edges) ...[line(e, seed + i * 13, 1.3), line(e, seed + (i++) * 13 + 50, 1.8)],
      ];
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final paths = _paths(size);
    final main = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final ghost = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.4);
    for (var i = 0; i < paths.length; i++) {
      canvas.drawPath(paths[i], i.isEven ? main : ghost);
    }
  }

  @override
  bool shouldRepaint(_InkPainter old) =>
      old.seed != seed || old.radius != radius || old.color != color || old.width != width || old.edges != edges;
}
