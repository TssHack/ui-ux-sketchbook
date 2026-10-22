"use client";

import { useLayoutEffect, useMemo, useRef, useState, type CSSProperties, type ElementType, type ReactNode } from "react";
import { roughLine, roughRoundRect } from "./rough";

type Side = "top" | "right" | "bottom" | "left";

type Props = {
  as?: ElementType;
  seed?: number;
  radius?: number;
  /** "box" draws a closed rounded frame; a list of sides draws only those edges. */
  edges?: "box" | Side[];
  /** Coloured-pencil shading that gathers along the inside of the edges. */
  tint?: string;
  className?: string;
  style?: CSSProperties;
  children?: ReactNode;
  [key: string]: unknown;
};

export function SketchBox({ as: Tag = "div", seed = 1, radius = 16, edges = "box", tint, className = "", style, children, ...rest }: Props) {
  const ref = useRef<HTMLElement>(null);
  const [size, setSize] = useState<{ w: number; h: number } | null>(null);

  useLayoutEffect(() => {
    const el = ref.current;
    if (!el) return;
    const ro = new ResizeObserver(([entry]) => {
      const { width, height } = entry.contentRect;
      const w = Math.round(el.offsetWidth || width);
      const h = Math.round(el.offsetHeight || height);
      setSize((prev) => (prev && prev.w === w && prev.h === h ? prev : { w, h }));
    });
    ro.observe(el);
    return () => ro.disconnect();
  }, []);

  const paths = useMemo(() => {
    if (!size) return [];
    const { w, h } = size;
    if (edges === "box") {
      return [
        { d: roughRoundRect(w, h, { r: radius, seed, amp: 1.5 }), main: true },
        { d: roughRoundRect(w, h, { r: radius + 2, seed: seed + 97, amp: 2, inset: 3 }), main: false },
      ];
    }
    const line = (side: Side, s: number, amp: number) => {
      if (side === "top") return roughLine(-4, 1.5, w + 4, 1.5, { seed: s, amp });
      if (side === "bottom") return roughLine(-4, h - 1.5, w + 4, h - 1.5, { seed: s, amp });
      if (side === "left") return roughLine(1.5, -4, 1.5, h + 4, { seed: s, amp });
      return roughLine(w - 1.5, -4, w - 1.5, h + 4, { seed: s, amp });
    };
    return edges.flatMap((side, i) => [
      { d: line(side, seed + i * 13, 1.3), main: true },
      { d: line(side, seed + i * 13 + 50, 1.8), main: false },
    ]);
  }, [size, edges, radius, seed]);

  const cls = ["sketch-box", tint ? "pencil" : "", edges === "box" ? "sketch-box--framed" : "", className].filter(Boolean).join(" ");
  const tintStyle = tint ? ({ "--tint": tint } as CSSProperties) : undefined;

  return (
    <Tag ref={ref} className={cls} style={{ ...tintStyle, ...style }} {...rest}>
      {size && (
        <svg className="sketch-box__ink" width={size.w} height={size.h} aria-hidden="true">
          {paths.map((p, i) => (
            <path key={i} d={p.d} className={p.main ? "ink-line" : "ink-line ink-line--ghost"} />
          ))}
        </svg>
      )}
      {children}
    </Tag>
  );
}
