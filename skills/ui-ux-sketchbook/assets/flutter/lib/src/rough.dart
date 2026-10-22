import 'dart:math' as math;
import 'dart:ui';

/// Seeded "hand-drawn" geometry, the same algorithm as rough.ts / sketchbook.js:
/// outlines that wobble like a fine-liner and overshoot where the pen lifts.

/// Deterministic pseudo-random numbers in [0, 1).
double Function() sketchRng(int seed) {
  var s = (seed * 2654435761) & 0xFFFFFFFF;
  if (s == 0) s = 1;
  return () {
    s = (s * 1664525 + 1013904223) & 0xFFFFFFFF;
    return s / 4294967296;
  };
}

/// Smooth 1-D noise in roughly [-1, 1], built from three seeded sine waves.
double Function(double) smoothNoise(int seed) {
  final r = sketchRng(seed);
  final waves = List.generate(3, (i) => (f: (0.7 + r() * 1.1) * (i + 1), p: r() * math.pi * 2, a: 1 / (i + 1)));
  return (t) {
    var sum = 0.0;
    for (final w in waves) {
      sum += w.a * math.sin(t * w.f + w.p);
    }
    return sum / 1.83;
  };
}

Path _smoothPath(List<Offset> pts) {
  final path = Path();
  if (pts.length < 2) return path;
  path.moveTo(pts[0].dx, pts[0].dy);
  for (var i = 1; i < pts.length - 1; i++) {
    final p = pts[i], n = pts[i + 1];
    path.quadraticBezierTo(p.dx, p.dy, (p.dx + n.dx) / 2, (p.dy + n.dy) / 2);
  }
  path.lineTo(pts.last.dx, pts.last.dy);
  return path;
}

List<Offset> _jitter(List<Offset> pts, int seed, double amp, [double wavelength = 70]) {
  final nz = smoothNoise(seed);
  var s = 0.0;
  final out = <Offset>[];
  for (var i = 0; i < pts.length; i++) {
    final a = pts[math.max(0, i - 1)], b = pts[math.min(pts.length - 1, i + 1)];
    if (i > 0) s += (pts[i] - pts[i - 1]).distance;
    final t = b - a;
    final len = t.distance == 0 ? 1.0 : t.distance;
    final off = amp * nz(s / wavelength);
    out.add(pts[i] + Offset(-t.dy / len * off, t.dx / len * off));
  }
  return out;
}

/// Sample spacing grows with size, so big frames stay cheap.
double _stepFor(double len) => (len / 40).clamp(5.0, 14.0);

List<Offset> _line(Offset a, Offset b, double step) {
  final n = math.max(2, ((b - a).distance / step).ceil());
  return List.generate(n, (i) => Offset.lerp(a, b, i / n)!);
}

List<Offset> _arc(Offset c, double r, double a0, double a1, double step) {
  final n = math.max(2, ((a1 - a0).abs() * r / step).ceil());
  return List.generate(n, (i) {
    final a = a0 + (a1 - a0) * i / n;
    return c + Offset(math.cos(a) * r, math.sin(a) * r);
  });
}

/// A rounded rectangle drawn in one stroke, overshooting a little past its start.
Path roughRoundRect(Size size, {double radius = 14, double inset = 2, int seed = 1, double amp = 1.6}) {
  final x = inset, y = inset, w = size.width - inset * 2, h = size.height - inset * 2;
  final r = math.min(radius, math.min(w / 2, h / 2));
  final st = _stepFor(math.max(w, h));
  const h2 = math.pi / 2;
  final pts = <Offset>[
    ..._line(Offset(x + r, y), Offset(x + w - r, y), st),
    ..._arc(Offset(x + w - r, y + r), r, -h2, 0, 5),
    ..._line(Offset(x + w, y + r), Offset(x + w, y + h - r), st),
    ..._arc(Offset(x + w - r, y + h - r), r, 0, h2, 5),
    ..._line(Offset(x + w - r, y + h), Offset(x + r, y + h), st),
    ..._arc(Offset(x + r, y + h - r), r, h2, math.pi, 5),
    ..._line(Offset(x, y + h - r), Offset(x, y + r), st),
    ..._arc(Offset(x + r, y + r), r, math.pi, math.pi * 1.5, 5),
  ];
  final over = List.generate(4, (i) => pts[i] + Offset(i * 0.2, -0.5 - i * 0.35));
  return _smoothPath(_jitter([...pts, ...over], seed, amp));
}

/// A straight-ish line with a wavering hand.
Path roughLine(Offset a, Offset b, {int seed = 1, double amp = 1.4}) {
  final pts = _line(a, b, _stepFor((b - a).distance))..add(b);
  return _smoothPath(_jitter(pts, seed, amp, 90));
}

/// An ellipse drawn in one stroke that overlaps itself where the pen lifted.
Path roughEllipse(Offset center, double rx, double ry, {int seed = 1, double amp = 1.4}) {
  final start = sketchRng(seed)() * math.pi * 2;
  final n = math.max(16, ((rx + ry) * math.pi / 6).ceil());
  final pts = <Offset>[];
  for (var i = 0; i <= n * 1.06; i++) {
    final a = start + i / n * math.pi * 2, g = 1 + i / n * 0.015;
    pts.add(center + Offset(math.cos(a) * rx * g, math.sin(a) * ry * g));
  }
  return _smoothPath(_jitter(pts, seed, amp, 50));
}
