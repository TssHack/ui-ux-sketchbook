import { useId, type ReactNode } from "react";

export type Shape = {
  d: string;
  /** Coloured-pencil fill. */
  fill?: string;
  /** Darker pencil worked in along the inside of the outline. */
  shade?: string;
  shadeWidth?: number;
  /** Ink width; 0 for colour only. */
  ink?: number;
  inkColor?: string;
  transform?: string;
};

export type DrawingSpec = {
  viewBox: string;
  shapes: Shape[];
  /** Anything drawn on top (lettering on a wrapper, etc.). */
  extra?: ReactNode;
};

/**
 * Renders shapes in order: flat colour, pencil hatching, darker edge shading,
 * then two slightly offset passes of ink so lines look hand-drawn.
 * No SVG filters: they are far too slow when a page holds dozens of drawings.
 */
export function Drawing({ spec, label, className, lite = false }: { spec: DrawingSpec; label?: string; className?: string; /** Icons under ~64px: no hatch, no edge shading, no ghost line. */ lite?: boolean }) {
  const uid = useId().replace(/:/g, "");
  return (
    <svg
      viewBox={spec.viewBox}
      className={`drawing ${className ?? ""}`}
      role={label ? "img" : undefined}
      aria-label={label}
      aria-hidden={label ? undefined : true}
    >
      {spec.shapes.map((s, i) => {
        const ink = s.ink ?? 2.3;
        const clip = `${uid}-c${i}`;
        return (
          <g key={i} transform={s.transform}>
            {s.fill && (
              <g className="pencil-fill">
                <path d={s.d} fill={s.fill} />
                {!lite && <path d={s.d} fill="url(#hatch)" />}
              </g>
            )}
            {s.shade && !lite && (
              <>
                <clipPath id={clip}>
                  <path d={s.d} />
                </clipPath>
                <path
                  d={s.d}
                  fill="none"
                  stroke={s.shade}
                  strokeWidth={s.shadeWidth ?? 9}
                  strokeOpacity={0.55}
                  clipPath={`url(#${clip})`}
                  className="pencil-fill"
                />
              </>
            )}
            {ink > 0 && (
              <>
                <path d={s.d} className="pen" stroke={s.inkColor} strokeWidth={ink} pathLength={1} />
                {/* Thin detail lines don't need the second pass; it only adds paths */}
                {!lite && ink >= 1.6 && (
                  <path d={s.d} className="pen pen--ghost" stroke={s.inkColor} strokeWidth={ink * 0.45} transform="translate(0.8 0.6)" />
                )}
              </>
            )}
          </g>
        );
      })}
      {spec.extra}
    </svg>
  );
}

// Small helpers so specs read like drawing instructions.
export const ell = (cx: number, cy: number, rx: number, ry: number) =>
  `M${cx - rx} ${cy} a${rx} ${ry} 0 1 0 ${rx * 2} 0 a${rx} ${ry} 0 1 0 ${-rx * 2} 0 Z`;
export const circ = (cx: number, cy: number, r: number) => ell(cx, cy, r, r);
export const rect = (x: number, y: number, w: number, h: number, r = 0) =>
  r
    ? `M${x + r} ${y} H${x + w - r} Q${x + w} ${y} ${x + w} ${y + r} V${y + h - r} Q${x + w} ${y + h} ${x + w - r} ${y + h} H${x + r} Q${x} ${y + h} ${x} ${y + h - r} V${y + r} Q${x} ${y} ${x + r} ${y} Z`
    : `M${x} ${y} H${x + w} V${y + h} H${x} Z`;
