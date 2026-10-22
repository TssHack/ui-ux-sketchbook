import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'art_library.dart';
import 'colors.dart';
import 'svg_path.dart';

/// One shape of an illustration, drawn in order: pencil fill + hatching,
/// darker shading along the inside edge, then a double pass of ink.
class DrawingShape {
  const DrawingShape(
    this.d, {
    this.fill,
    this.shade,
    this.shadeWidth = 9,
    this.ink = 2.3,
    this.inkColor,
    this.transform,
  });

  /// SVG path data in viewBox units (same strings as the web builds).
  final String d;
  final Color? fill;
  final Color? shade;
  final double shadeWidth;

  /// Ink width; 0 for colour only.
  final double ink;
  final Color? inkColor;

  /// SVG transform list, e.g. "rotate(-8 55 40)".
  final String? transform;
}

/// Lettering drawn on top of an illustration (the label on a wrapper, etc.).
class SketchLabel {
  const SketchLabel(this.text, {required this.x, required this.y, this.size = 16, this.rotate = 0, this.fontFamily, this.color});
  final String text;

  /// Centre of the text baseline, in viewBox units.
  final double x, y;
  final double size, rotate;
  final String? fontFamily;
  final Color? color;
}

/// An illustration as data: a viewBox and shapes in viewBox units.
class DrawingSpec {
  const DrawingSpec({required this.viewBox, required this.shapes, this.labels = const []});
  final Rect viewBox;
  final List<DrawingShape> shapes;
  final List<SketchLabel> labels;
}

/// Renders a [DrawingSpec]. Use [lite] for icons under ~64 logical pixels
/// (no hatching, edge shading or ghost line) and [drawIn] to let the pen trace it.
class SketchDrawing extends StatefulWidget {
  const SketchDrawing(
    this.spec, {
    super.key,
    this.label,
    this.lite = false,
    this.drawIn = false,
    this.duration = const Duration(milliseconds: 1400),
    this.inkColor = SketchColors.ink,
    this.width,
    this.height,
  });

  /// One of the ready illustrations in [sketchArt], by name.
  factory SketchDrawing.named(
    String name, {
    Key? key,
    String? label,
    bool lite = false,
    bool drawIn = false,
    double? width,
    double? height,
  }) {
    final spec = sketchArt[name];
    if (spec == null) throw ArgumentError.value(name, 'name', 'Unknown illustration. Known: ${sketchArt.keys.join(', ')}');
    return SketchDrawing(spec, key: key, label: label, lite: lite, drawIn: drawIn, width: width, height: height);
  }

  final DrawingSpec spec;

  /// Accessible description. Without it the drawing is decorative and hidden from screen readers.
  final String? label;
  final bool lite;
  final bool drawIn;
  final Duration duration;
  final Color inkColor;
  final double? width, height;

  @override
  State<SketchDrawing> createState() => _SketchDrawingState();
}

class _SketchDrawingState extends State<SketchDrawing> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.drawIn && !reduceMotion && _controller == null) {
      _controller = AnimationController(vsync: this, duration: widget.duration)..forward();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vb = widget.spec.viewBox;
    Widget child = AspectRatio(
      aspectRatio: vb.width / vb.height,
      child: CustomPaint(
        painter: _DrawingPainter(widget.spec, widget.lite, widget.inkColor, _controller),
      ),
    );
    if (widget.width != null || widget.height != null) {
      child = SizedBox(width: widget.width, height: widget.height, child: child);
    }
    child = RepaintBoundary(child: child);
    return widget.label == null
        ? ExcludeSemantics(child: child)
        : Semantics(label: widget.label, image: true, child: ExcludeSemantics(child: child));
  }
}

class _DrawingPainter extends CustomPainter {
  _DrawingPainter(this.spec, this.lite, this.inkColor, this.progress) : super(repaint: progress);

  final DrawingSpec spec;
  final bool lite;
  final Color inkColor;
  final Animation<double>? progress;

  static final Map<String, Path> _cache = {};

  static Path _pathFor(DrawingShape s) {
    final key = '${s.transform}|${s.d}';
    return _cache.putIfAbsent(key, () {
      final p = parseSvgPath(s.d);
      final m = parseSvgTransform(s.transform);
      return m == null ? p : p.transform(m);
    });
  }

  static Path _partial(Path path, double t) {
    final out = Path();
    for (final metric in path.computeMetrics()) {
      out.addPath(metric.extractPath(0, metric.length * t), Offset.zero);
    }
    return out;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final vb = spec.viewBox;
    final scale = math.min(size.width / vb.width, size.height / vb.height);
    canvas.save();
    canvas.translate((size.width - vb.width * scale) / 2, (size.height - vb.height * scale) / 2);
    canvas.scale(scale);
    canvas.translate(-vb.left, -vb.top);

    // Ink traces first, colour arrives a little later, like the CSS draw-in.
    final t = progress?.value ?? 1.0;
    final inkT = (t / 0.75).clamp(0.0, 1.0);
    final fillT = ((t - 0.45) / 0.55).clamp(0.0, 1.0);

    for (final s in spec.shapes) {
      final path = _pathFor(s);
      if (s.fill != null && fillT > 0) {
        canvas.drawPath(path, Paint()..color = s.fill!.withValues(alpha: s.fill!.a * fillT));
        if (!lite) _hatch(canvas, path, fillT);
      }
      if (s.shade != null && !lite && fillT > 0) {
        canvas.save();
        canvas.clipPath(path);
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = s.shadeWidth
            ..color = s.shade!.withValues(alpha: 0.55 * fillT),
        );
        canvas.restore();
      }
      if (s.ink > 0 && inkT > 0) {
        final color = s.inkColor ?? inkColor;
        final pen = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s.ink
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color;
        canvas.drawPath(inkT < 1 ? _partial(path, inkT) : path, pen);
        // Second, lighter pass of the pen that doesn't sit exactly on the first.
        if (!lite && s.ink >= 1.6 && fillT > 0) {
          canvas.save();
          canvas.translate(0.8, 0.6);
          canvas.drawPath(
            path,
            pen
              ..strokeWidth = s.ink * 0.45
              ..color = color.withValues(alpha: 0.35 * fillT),
          );
          canvas.restore();
        }
      }
    }

    for (final l in spec.labels) {
      final tp = TextPainter(
        text: TextSpan(
          text: l.text,
          style: TextStyle(fontSize: l.size, fontFamily: l.fontFamily, color: (l.color ?? inkColor).withValues(alpha: fillT)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(l.x, l.y);
      canvas.rotate(l.rotate * math.pi / 180);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.computeDistanceToActualBaseline(TextBaseline.alphabetic)));
      canvas.restore();
    }
    canvas.restore();
  }

  /// Coloured-pencil strokes laid over a fill, clipped to the shape.
  void _hatch(Canvas canvas, Path path, double opacity) {
    final b = path.getBounds();
    final r = b.longestSide;
    final paint = Paint()
      ..strokeWidth = 1.3
      ..color = inkColor.withValues(alpha: 0.13 * opacity);
    canvas.save();
    canvas.clipPath(path);
    canvas.translate(b.center.dx, b.center.dy);
    canvas.rotate(32 * math.pi / 180);
    for (var x = -r; x <= r; x += 5) {
      canvas.drawLine(Offset(x, -r), Offset(x, r), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DrawingPainter old) =>
      old.spec != spec || old.lite != lite || old.inkColor != inkColor || old.progress != progress;
}
