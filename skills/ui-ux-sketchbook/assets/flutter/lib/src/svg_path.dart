import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

/// Parses SVG path data (M L H V C S Q T A Z, absolute and relative) into a [Path],
/// so illustration specs can be shared with the web builds unchanged.
Path parseSvgPath(String d) {
  final path = Path();
  final tokens = _tokenize(d);
  var i = 0;
  var cmd = '';
  var cur = Offset.zero, start = Offset.zero;
  Offset? lastCtrl; // for S / T reflection
  var lastCmd = '';

  bool isCmd(String t) => RegExp(r'^[MmLlHhVvCcSsQqTtAaZz]$').hasMatch(t);
  double next() => double.parse(tokens[i++]);
  Offset pt(bool rel) {
    final x = next(), y = next();
    return rel ? cur + Offset(x, y) : Offset(x, y);
  }

  while (i < tokens.length) {
    if (isCmd(tokens[i])) {
      cmd = tokens[i++];
    } else if (cmd.isEmpty) {
      throw FormatException('Path data must start with a command', d);
    }
    final rel = cmd == cmd.toLowerCase();
    switch (cmd.toUpperCase()) {
      case 'M':
        cur = pt(rel);
        start = cur;
        path.moveTo(cur.dx, cur.dy);
        // Further coordinate pairs after M are implicit L / l.
        cmd = rel ? 'l' : 'L';
        lastCtrl = null;
      case 'L':
        cur = pt(rel);
        path.lineTo(cur.dx, cur.dy);
        lastCtrl = null;
      case 'H':
        final x = next();
        cur = Offset(rel ? cur.dx + x : x, cur.dy);
        path.lineTo(cur.dx, cur.dy);
        lastCtrl = null;
      case 'V':
        final y = next();
        cur = Offset(cur.dx, rel ? cur.dy + y : y);
        path.lineTo(cur.dx, cur.dy);
        lastCtrl = null;
      case 'C':
        final c1 = pt(rel), c2 = pt(rel), end = pt(rel);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        lastCtrl = c2;
        cur = end;
      case 'S':
        final c1 = ('CS'.contains(lastCmd.toUpperCase()) && lastCtrl != null) ? cur * 2 - lastCtrl : cur;
        final c2 = pt(rel), end = pt(rel);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        lastCtrl = c2;
        cur = end;
      case 'Q':
        final c = pt(rel), end = pt(rel);
        path.quadraticBezierTo(c.dx, c.dy, end.dx, end.dy);
        lastCtrl = c;
        cur = end;
      case 'T':
        final c = ('QT'.contains(lastCmd.toUpperCase()) && lastCtrl != null) ? cur * 2 - lastCtrl : cur;
        final end = pt(rel);
        path.quadraticBezierTo(c.dx, c.dy, end.dx, end.dy);
        lastCtrl = c;
        cur = end;
      case 'A':
        final rx = next(), ry = next(), rot = next();
        final large = next() != 0, sweep = next() != 0;
        final end = pt(rel);
        path.arcToPoint(end, radius: Radius.elliptical(rx, ry), rotation: rot, largeArc: large, clockwise: sweep);
        cur = end;
        lastCtrl = null;
      case 'Z':
        path.close();
        cur = start;
        lastCtrl = null;
    }
    lastCmd = cmd;
  }
  return path;
}

List<String> _tokenize(String d) {
  // Commands, and numbers like "-1.5", ".5", "1e-3"; "1.5.5" splits into 1.5 and .5.
  final re = RegExp(r'[MmLlHhVvCcSsQqTtAaZz]|[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?');
  return re.allMatches(d).map((m) => m.group(0)!).toList();
}

/// Parses an SVG transform list ("translate(70 8) rotate(24 25 25) scale(2)") into a matrix.
Float64List? parseSvgTransform(String? t) {
  if (t == null || t.trim().isEmpty) return null;
  var m = _Affine.identity();
  for (final match in RegExp(r'(\w+)\s*\(([^)]*)\)').allMatches(t)) {
    final args = RegExp(r'[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?')
        .allMatches(match.group(2)!)
        .map((x) => double.parse(x.group(0)!))
        .toList();
    switch (match.group(1)) {
      case 'translate':
        m = m.multiply(_Affine.translate(args[0], args.length > 1 ? args[1] : 0));
      case 'scale':
        m = m.multiply(_Affine.scale(args[0], args.length > 1 ? args[1] : args[0]));
      case 'rotate':
        final a = args[0] * math.pi / 180;
        if (args.length >= 3) {
          m = m
              .multiply(_Affine.translate(args[1], args[2]))
              .multiply(_Affine.rotate(a))
              .multiply(_Affine.translate(-args[1], -args[2]));
        } else {
          m = m.multiply(_Affine.rotate(a));
        }
    }
  }
  return m.toMatrix4();
}

/// 2-D affine transform [a c e; b d f; 0 0 1].
class _Affine {
  const _Affine(this.a, this.b, this.c, this.d, this.e, this.f);
  factory _Affine.identity() => const _Affine(1, 0, 0, 1, 0, 0);
  factory _Affine.translate(double x, double y) => _Affine(1, 0, 0, 1, x, y);
  factory _Affine.scale(double x, double y) => _Affine(x, 0, 0, y, 0, 0);
  factory _Affine.rotate(double r) => _Affine(math.cos(r), math.sin(r), -math.sin(r), math.cos(r), 0, 0);
  final double a, b, c, d, e, f;

  _Affine multiply(_Affine o) => _Affine(
        a * o.a + c * o.b,
        b * o.a + d * o.b,
        a * o.c + c * o.d,
        b * o.c + d * o.d,
        a * o.e + c * o.f + e,
        b * o.e + d * o.f + f,
      );

  Float64List toMatrix4() => Float64List.fromList([a, b, 0, 0, c, d, 0, 0, 0, 0, 1, 0, e, f, 0, 1]);
}
