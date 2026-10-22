/**
 * Shared SVG paint servers, rendered once in the layout.
 * Patterns only: a page full of drawings ends up with hundreds of shapes, and
 * per-shape SVG filters (turbulence/displacement) re-run on every repaint, which
 * is very heavy on phones. A hatch pattern gives the pencil texture almost free.
 */
export function SketchDefs() {
  return (
    <svg className="sketch-defs" aria-hidden="true" focusable="false">
      <defs>
        {/* Coloured-pencil strokes laid over every fill */}
        <pattern id="hatch" width="5" height="5" patternUnits="userSpaceOnUse" patternTransform="rotate(32)">
          <line x1="0" y1="0" x2="0" y2="5" stroke="#2f241b" strokeOpacity="0.13" strokeWidth="1.3" />
        </pattern>
        <pattern id="hatch-light" width="4" height="4" patternUnits="userSpaceOnUse" patternTransform="rotate(-24)">
          <line x1="0" y1="0" x2="0" y2="4" stroke="#ffffff" strokeOpacity="0.28" strokeWidth="1" />
        </pattern>
      </defs>
    </svg>
  );
}
