// Seeded "hand-drawn" geometry: outlines that wobble like a fine-liner pen
// and never quite close where they started.

type Pt = [number, number];

export function rng(seed: number) {
  let s = (seed * 2654435761) >>> 0 || 1;
  return () => (s = (Math.imul(s, 1664525) + 1013904223) >>> 0) / 4294967296;
}

/** Smooth 1-D noise in roughly [-1, 1], built from a few random sine waves. */
export function smoothNoise(seed: number) {
  const r = rng(seed);
  const waves = [0, 1, 2].map((i) => ({
    f: (0.7 + r() * 1.1) * (i + 1),
    p: r() * Math.PI * 2,
    a: 1 / (i + 1),
  }));
  return (t: number) => waves.reduce((sum, w) => sum + w.a * Math.sin(t * w.f + w.p), 0) / 1.83;
}

function smoothPath(pts: Pt[]) {
  if (pts.length < 2) return "";
  let d = `M${pts[0][0].toFixed(1)} ${pts[0][1].toFixed(1)}`;
  for (let i = 1; i < pts.length - 1; i++) {
    const [x, y] = pts[i];
    const mx = (x + pts[i + 1][0]) / 2;
    const my = (y + pts[i + 1][1]) / 2;
    d += ` Q${x.toFixed(1)} ${y.toFixed(1)} ${mx.toFixed(1)} ${my.toFixed(1)}`;
  }
  const last = pts[pts.length - 1];
  return d + ` L${last[0].toFixed(1)} ${last[1].toFixed(1)}`;
}

/** Push every sample along its normal by a smooth, seeded amount. */
function jitter(pts: Pt[], seed: number, amp: number, wavelength = 70) {
  const nz = smoothNoise(seed);
  let s = 0;
  return pts.map((p, i) => {
    const a = pts[Math.max(0, i - 1)];
    const b = pts[Math.min(pts.length - 1, i + 1)];
    if (i > 0) s += Math.hypot(p[0] - pts[i - 1][0], p[1] - pts[i - 1][1]);
    const tx = b[0] - a[0];
    const ty = b[1] - a[1];
    const len = Math.hypot(tx, ty) || 1;
    const off = amp * nz(s / wavelength);
    return [p[0] + (-ty / len) * off, p[1] + (tx / len) * off] as Pt;
  });
}

function sampleLine(a: Pt, b: Pt, step: number): Pt[] {
  const n = Math.max(2, Math.ceil(Math.hypot(b[0] - a[0], b[1] - a[1]) / step));
  return Array.from({ length: n }, (_, i) => [a[0] + ((b[0] - a[0]) * i) / n, a[1] + ((b[1] - a[1]) * i) / n] as Pt);
}

function sampleArc(cx: number, cy: number, r: number, a0: number, a1: number, step: number): Pt[] {
  const n = Math.max(2, Math.ceil((Math.abs(a1 - a0) * r) / step));
  return Array.from({ length: n }, (_, i) => {
    const a = a0 + ((a1 - a0) * i) / n;
    return [cx + Math.cos(a) * r, cy + Math.sin(a) * r] as Pt;
  });
}

/** A rounded rectangle drawn in one stroke, overshooting a little past its start. */
export function roughRoundRect(w: number, h: number, opts: { r?: number; inset?: number; seed?: number; amp?: number } = {}) {
  const { r: rIn = 14, inset = 2, seed = 1, amp = 1.6 } = opts;
  const x = inset, y = inset, W = w - inset * 2, H = h - inset * 2;
  const r = Math.min(rIn, W / 2, H / 2);
  // Sample spacing grows with size, so big frames don't become thousands of path commands
  const st = Math.max(5, Math.min(14, Math.max(W, H) / 40));
  const H2 = Math.PI / 2;
  const pts: Pt[] = [
    ...sampleLine([x + r, y], [x + W - r, y], st),
    ...sampleArc(x + W - r, y + r, r, -H2, 0, 5),
    ...sampleLine([x + W, y + r], [x + W, y + H - r], st),
    ...sampleArc(x + W - r, y + H - r, r, 0, H2, 5),
    ...sampleLine([x + W - r, y + H], [x + r, y + H], st),
    ...sampleArc(x + r, y + H - r, r, H2, Math.PI, 5),
    ...sampleLine([x, y + H - r], [x, y + r], st),
    ...sampleArc(x + r, y + r, r, Math.PI, Math.PI * 1.5, 5),
  ];
  // Overshoot: run on past the start for a few samples, drifting outward.
  const over = pts.slice(0, 5).map((p, i) => [p[0] + i * 0.2, p[1] - 0.5 - i * 0.35] as Pt);
  return smoothPath(jitter([...pts, ...over], seed, amp));
}

/** A straight-ish line with a wavering hand and slightly loose ends. */
export function roughLine(x1: number, y1: number, x2: number, y2: number, opts: { seed?: number; amp?: number } = {}) {
  const { seed = 1, amp = 1.4 } = opts;
  const pts = sampleLine([x1, y1], [x2, y2], Math.max(6, Math.min(14, Math.hypot(x2 - x1, y2 - y1) / 40)));
  pts.push([x2, y2]);
  return smoothPath(jitter(pts, seed, amp, 90));
}

/** An ellipse drawn in one stroke that overlaps itself where the pen lifted. */
export function roughEllipse(cx: number, cy: number, rx: number, ry: number, opts: { seed?: number; amp?: number } = {}) {
  const { seed = 1, amp = 1.4 } = opts;
  const start = rng(seed)() * Math.PI * 2;
  const n = Math.ceil(((rx + ry) * Math.PI) / 4);
  const pts: Pt[] = [];
  for (let i = 0; i <= n * 1.06; i++) {
    const a = start + (i / n) * Math.PI * 2;
    const grow = 1 + (i / n) * 0.015;
    pts.push([cx + Math.cos(a) * rx * grow, cy + Math.sin(a) * ry * grow]);
  }
  return smoothPath(jitter(pts, seed, amp, 50));
}
