/*!
 * sketchbook.js: the ui-ux-sketchbook primitives without React.
 * For single-file HTML pages, or any site without a framework.
 *
 * Markup API (call nothing; it runs on DOMContentLoaded and watches for new nodes):
 *   <div data-sketch>                         rough rounded frame (double pen pass)
 *   <div data-sketch="bottom">                 only some edges: top,right,bottom,left (comma-separated)
 *        data-seed="12" data-radius="16"       vary the wobble / corner radius
 *        data-tint="#c98a4b"                   coloured-pencil shading along the inside edges
 *   <h2 data-hand data-seed="4">Special menu</h2>   hand-lettered Latin text (never Persian/Arabic)
 *   <span data-art="latte" data-label="لاته"></span> illustration from Sketchbook.art (art-library.js)
 *        data-lite                             cheaper render for small icons (no hatch, no ghost line)
 *        data-draw-in                          pen traces the drawing when it appears
 *
 * JS API: Sketchbook.drawing(spec, opts) -> SVGElement, Sketchbook.refresh(root),
 *         Sketchbook.art (registry), helpers ell / circ / rect, rough* geometry.
 *
 * No SVG filters anywhere: the wobble is in the geometry, the grain is a hatch pattern.
 */
(function () {
  "use strict";
  const NS = "http://www.w3.org/2000/svg";

  /* ---------- seeded geometry ---------- */
  function rng(seed) {
    let s = (seed * 2654435761) >>> 0 || 1;
    return () => (s = (Math.imul(s, 1664525) + 1013904223) >>> 0) / 4294967296;
  }
  function smoothNoise(seed) {
    const r = rng(seed);
    const waves = [0, 1, 2].map((i) => ({ f: (0.7 + r() * 1.1) * (i + 1), p: r() * Math.PI * 2, a: 1 / (i + 1) }));
    return (t) => waves.reduce((sum, w) => sum + w.a * Math.sin(t * w.f + w.p), 0) / 1.83;
  }
  const f1 = (n) => Math.round(n * 10) / 10;
  function smoothPath(pts) {
    if (pts.length < 2) return "";
    let d = `M${f1(pts[0][0])} ${f1(pts[0][1])}`;
    for (let i = 1; i < pts.length - 1; i++) {
      const [x, y] = pts[i];
      d += ` Q${f1(x)} ${f1(y)} ${f1((x + pts[i + 1][0]) / 2)} ${f1((y + pts[i + 1][1]) / 2)}`;
    }
    const last = pts[pts.length - 1];
    return d + ` L${f1(last[0])} ${f1(last[1])}`;
  }
  function jitter(pts, seed, amp, wavelength) {
    const nz = smoothNoise(seed);
    let s = 0;
    return pts.map((p, i) => {
      const a = pts[Math.max(0, i - 1)], b = pts[Math.min(pts.length - 1, i + 1)];
      if (i > 0) s += Math.hypot(p[0] - pts[i - 1][0], p[1] - pts[i - 1][1]);
      const tx = b[0] - a[0], ty = b[1] - a[1], len = Math.hypot(tx, ty) || 1;
      const off = amp * nz(s / (wavelength || 70));
      return [p[0] + (-ty / len) * off, p[1] + (tx / len) * off];
    });
  }
  // Sample spacing grows with size, so big frames don't turn into thousands of path commands.
  const stepFor = (len) => Math.max(5, Math.min(14, len / 40));
  function sampleLine(a, b, step) {
    const n = Math.max(2, Math.ceil(Math.hypot(b[0] - a[0], b[1] - a[1]) / step));
    return Array.from({ length: n }, (_, i) => [a[0] + ((b[0] - a[0]) * i) / n, a[1] + ((b[1] - a[1]) * i) / n]);
  }
  function sampleArc(cx, cy, r, a0, a1, step) {
    const n = Math.max(2, Math.ceil((Math.abs(a1 - a0) * r) / step));
    return Array.from({ length: n }, (_, i) => {
      const a = a0 + ((a1 - a0) * i) / n;
      return [cx + Math.cos(a) * r, cy + Math.sin(a) * r];
    });
  }
  function roughRoundRect(w, h, o) {
    o = o || {};
    const inset = o.inset ?? 2, seed = o.seed ?? 1, amp = o.amp ?? 1.6;
    const x = inset, y = inset, W = w - inset * 2, H = h - inset * 2;
    const r = Math.min(o.r ?? 14, W / 2, H / 2);
    const st = stepFor(Math.max(W, H)), H2 = Math.PI / 2;
    const pts = [
      ...sampleLine([x + r, y], [x + W - r, y], st),
      ...sampleArc(x + W - r, y + r, r, -H2, 0, 5),
      ...sampleLine([x + W, y + r], [x + W, y + H - r], st),
      ...sampleArc(x + W - r, y + H - r, r, 0, H2, 5),
      ...sampleLine([x + W - r, y + H], [x + r, y + H], st),
      ...sampleArc(x + r, y + H - r, r, H2, Math.PI, 5),
      ...sampleLine([x, y + H - r], [x, y + r], st),
      ...sampleArc(x + r, y + r, r, Math.PI, Math.PI * 1.5, 5),
    ];
    const over = pts.slice(0, 4).map((p, i) => [p[0] + i * 0.2, p[1] - 0.5 - i * 0.35]);
    return smoothPath(jitter([...pts, ...over], seed, amp));
  }
  function roughLine(x1, y1, x2, y2, o) {
    o = o || {};
    const pts = sampleLine([x1, y1], [x2, y2], stepFor(Math.hypot(x2 - x1, y2 - y1)));
    pts.push([x2, y2]);
    return smoothPath(jitter(pts, o.seed ?? 1, o.amp ?? 1.4, 90));
  }
  function roughEllipse(cx, cy, rx, ry, o) {
    o = o || {};
    const seed = o.seed ?? 1, start = rng(seed)() * Math.PI * 2;
    const n = Math.max(16, Math.ceil(((rx + ry) * Math.PI) / 6));
    const pts = [];
    for (let i = 0; i <= n * 1.06; i++) {
      const a = start + (i / n) * Math.PI * 2, g = 1 + (i / n) * 0.015;
      pts.push([cx + Math.cos(a) * rx * g, cy + Math.sin(a) * ry * g]);
    }
    return smoothPath(jitter(pts, seed, o.amp ?? 1.4, 50));
  }

  /* ---------- shape helpers for illustration specs ---------- */
  const ell = (cx, cy, rx, ry) => `M${cx - rx} ${cy} a${rx} ${ry} 0 1 0 ${rx * 2} 0 a${rx} ${ry} 0 1 0 ${-rx * 2} 0 Z`;
  const circ = (cx, cy, r) => ell(cx, cy, r, r);
  const rect = (x, y, w, h, r) =>
    r
      ? `M${x + r} ${y} H${x + w - r} Q${x + w} ${y} ${x + w} ${y + r} V${y + h - r} Q${x + w} ${y + h} ${x + w - r} ${y + h} H${x + r} Q${x} ${y + h} ${x} ${y + h - r} V${y + r} Q${x} ${y} ${x + r} ${y} Z`
      : `M${x} ${y} H${x + w} V${y + h} H${x} Z`;

  /* ---------- shared paint servers ---------- */
  function ensureDefs() {
    if (document.getElementById("hatch")) return;
    const svg = document.createElementNS(NS, "svg");
    svg.setAttribute("aria-hidden", "true");
    svg.setAttribute("class", "sketch-defs");
    svg.innerHTML =
      '<defs><pattern id="hatch" width="5" height="5" patternUnits="userSpaceOnUse" patternTransform="rotate(32)">' +
      '<line x1="0" y1="0" x2="0" y2="5" stroke="#2f241b" stroke-opacity="0.13" stroke-width="1.3"/></pattern></defs>';
    document.body.prepend(svg);
  }

  /* ---------- illustrations ---------- */
  let uid = 0;
  const esc = (s) => String(s).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);

  /**
   * Render a spec: [{ d, fill?, shade?, shadeWidth?, ink?, inkColor?, transform? }], drawn in order.
   * lite: drop the hatch, the edge shading and the ghost ink pass (for icons under ~64px).
   */
  function drawing(spec, opts) {
    opts = opts || {};
    const lite = !!opts.lite;
    const id = "sk" + (uid++).toString(36);
    let body = "";
    spec.shapes.forEach((s, i) => {
      const ink = s.ink ?? 2.3;
      let g = "";
      if (s.fill) {
        g += `<path d="${s.d}" fill="${s.fill}" class="pencil-fill"/>`;
        if (!lite) g += `<path d="${s.d}" fill="url(#hatch)" class="pencil-fill"/>`;
      }
      if (s.shade && !lite) {
        g += `<clipPath id="${id}c${i}"><path d="${s.d}"/></clipPath>`;
        g += `<path d="${s.d}" fill="none" stroke="${s.shade}" stroke-width="${s.shadeWidth ?? 9}" stroke-opacity="0.55" clip-path="url(#${id}c${i})" class="pencil-fill"/>`;
      }
      if (ink > 0) {
        const col = s.inkColor ? ` stroke="${s.inkColor}"` : "";
        g += `<path d="${s.d}" class="pen"${col} stroke-width="${ink}" pathLength="1"/>`;
        if (!lite && ink >= 1.6) g += `<path d="${s.d}" class="pen pen--ghost"${col} stroke-width="${f1(ink * 0.45)}" transform="translate(0.8 0.6)"/>`;
      }
      body += s.transform ? `<g transform="${s.transform}">${g}</g>` : g;
    });
    if (spec.extra) body += spec.extra;
    const svg = document.createElementNS(NS, "svg");
    svg.setAttribute("viewBox", spec.viewBox);
    svg.setAttribute("class", "drawing" + (opts.className ? " " + opts.className : ""));
    if (opts.label) {
      svg.setAttribute("role", "img");
      svg.setAttribute("aria-label", opts.label);
    } else svg.setAttribute("aria-hidden", "true");
    svg.innerHTML = body;
    return svg;
  }

  function mountArt(el) {
    const spec = Sketchbook.art[el.dataset.art];
    if (!spec) return console.warn("sketchbook: unknown art", el.dataset.art);
    const svg = drawing(spec, { label: el.dataset.label, lite: el.hasAttribute("data-lite"), className: el.hasAttribute("data-draw-in") ? "draw-in" : "" });
    el.replaceChildren(svg);
    el.dataset.sketched = "1";
  }

  /* ---------- hand lettering ---------- */
  function handText(el) {
    const text = el.textContent.trim();
    const r = rng(Number(el.dataset.seed) || text.length);
    el.classList.add("hand-text");
    // Screen readers get one plain copy of the words: aria-label on a span is not read reliably.
    el.innerHTML = `<span class="visually-hidden">${esc(text)}</span>` + text
      .split(/\s+/)
      .map(
        (w) =>
          `<span class="hand-text__word" aria-hidden="true">` +
          [...w]
            .map((ch) => `<span style="transform:translateY(${f1((r() - 0.5) * 0.12 * 100) / 100}em) rotate(${f1((r() - 0.5) * 9)}deg) scale(${f1((0.92 + r() * 0.16) * 100) / 100})">${esc(ch)}</span>`)
            .join("") +
          `</span>`
      )
      .join("");
    el.dataset.sketched = "1";
  }

  /* ---------- sketch boxes ---------- */
  function drawBox(el) {
    const w = el.offsetWidth, h = el.offsetHeight;
    if (!w || !h || (el.__skW === w && el.__skH === h)) return;
    el.__skW = w;
    el.__skH = h;
    const seed = Number(el.dataset.seed) || 1;
    const mode = el.dataset.sketch || "box";
    let paths;
    if (mode === "box" || mode === "") {
      const r = Number(el.dataset.radius) || 16;
      paths = [
        [roughRoundRect(w, h, { r, seed, amp: 1.5 }), "ink-line"],
        [roughRoundRect(w, h, { r: r + 2, seed: seed + 97, amp: 2, inset: 3 }), "ink-line ink-line--ghost"],
      ];
    } else {
      const line = (side, s, amp) =>
        side === "top" ? roughLine(-4, 1.5, w + 4, 1.5, { seed: s, amp })
        : side === "bottom" ? roughLine(-4, h - 1.5, w + 4, h - 1.5, { seed: s, amp })
        : side === "left" ? roughLine(1.5, -4, 1.5, h + 4, { seed: s, amp })
        : roughLine(w - 1.5, -4, w - 1.5, h + 4, { seed: s, amp });
      paths = mode.split(",").map((s) => s.trim()).flatMap((side, i) => [
        [line(side, seed + i * 13, 1.3), "ink-line"],
        [line(side, seed + i * 13 + 50, 1.8), "ink-line ink-line--ghost"],
      ]);
    }
    let svg = el.__skSvg;
    if (!svg) {
      svg = document.createElementNS(NS, "svg");
      svg.setAttribute("class", "sketch-box__ink");
      svg.setAttribute("aria-hidden", "true");
      el.prepend(svg);
      el.__skSvg = svg;
    }
    svg.setAttribute("width", w);
    svg.setAttribute("height", h);
    svg.innerHTML = paths.map(([d, c]) => `<path d="${d}" class="${c}"/>`).join("");
  }

  const ro = typeof ResizeObserver !== "undefined" ? new ResizeObserver((es) => es.forEach((e) => drawBox(e.target))) : null;

  function setupBox(el) {
    if (el.__sk) return;
    el.__sk = true;
    el.classList.add("sketch-box");
    if (el.dataset.tint) {
      el.classList.add("pencil");
      el.style.setProperty("--tint", el.dataset.tint);
    }
    drawBox(el);
    if (ro) ro.observe(el);
  }

  /** Process everything under root (defaults to the document). Safe to call repeatedly. */
  function refresh(root) {
    root = root || document;
    ensureDefs();
    root.querySelectorAll("[data-hand]:not([data-sketched])").forEach(handText);
    root.querySelectorAll("[data-art]:not([data-sketched])").forEach(mountArt);
    root.querySelectorAll("[data-sketch]").forEach(setupBox);
  }

  // Pick up nodes added later (rendered lists, dialogs) without the page having to call refresh.
  let queued = false;
  const mo = new MutationObserver(() => {
    if (queued) return;
    queued = true;
    requestAnimationFrame(() => {
      queued = false;
      refresh();
    });
  });

  function init() {
    refresh();
    mo.observe(document.body, { childList: true, subtree: true });
    // Fonts change text widths; redraw frames once they are in.
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(() => document.querySelectorAll("[data-sketch]").forEach((el) => { el.__skW = 0; drawBox(el); }));
  }

  const Sketchbook = (window.Sketchbook = window.Sketchbook || {});
  Object.assign(Sketchbook, { rng, roughRoundRect, roughLine, roughEllipse, ell, circ, rect, drawing, handText, refresh });
  Sketchbook.art = Sketchbook.art || {};
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();
