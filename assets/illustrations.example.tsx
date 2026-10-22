import { Drawing, circ, ell, rect, type DrawingSpec } from "./sketch/Drawing";

// Coloured-pencil box, matched to the sketch.
const C = {
  cream: "#fbf5e8",
  paperShade: "#e6d7bd",
  cupShade: "#dfcdb0",
  foam: "#f3e3c8",
  latte: "#d7ae80",
  coffee: "#8a5634",
  choc: "#6b3c20",
  chocDark: "#4a2914",
  caramel: "#c98a4b",
  caramelDark: "#a8693a",
  orange: "#e39a4c",
  yellow: "#efc85c",
  green: "#9db86a",
  leaf: "#7ea04a",
  red: "#cf5a3a",
  cola: "#5a261a",
  glass: "#eef1e6",
  glassShade: "#c8cdbd",
  bun: "#e2a95f",
  bunShade: "#b9773a",
};

const iced: DrawingSpec = {
  viewBox: "0 0 100 150",
  shapes: [
    { d: "M20 34 L29 138 Q50 146 71 138 L80 34 Z", fill: C.glass, shade: C.glassShade, shadeWidth: 8 },
    { d: "M23 72 L29 136 Q50 143 71 136 L77 72 Q50 78 23 72 Z", fill: C.latte, shade: C.coffee, ink: 0 },
    { d: rect(33, 98, 15, 15, 2), fill: "#fdfbf5", shade: "#cfd3c4", shadeWidth: 4, ink: 1.6, transform: "rotate(-12 40 105)" },
    { d: rect(52, 104, 15, 15, 2), fill: "#fdfbf5", shade: "#cfd3c4", shadeWidth: 4, ink: 1.6, transform: "rotate(10 59 111)" },
    { d: rect(40, 118, 14, 13, 2), fill: "#fdfbf5", shade: "#cfd3c4", shadeWidth: 4, ink: 1.6, transform: "rotate(4 47 124)" },
    {
      d: "M20 34 L80 34 L79 46 Q77 56 75 46 L73 42 Q71 70 67 44 Q65 52 62 42 Q60 80 56 44 Q53 54 50 42 Q47 66 44 44 Q41 52 38 42 Q35 74 32 44 Q29 54 26 42 Q24 50 21 44 Z",
      fill: C.coffee,
      shade: C.chocDark,
      shadeWidth: 5,
    },
    { d: ell(50, 34, 30, 5), fill: "#ece6d6", ink: 2.2 },
    { d: "M28 86 L32 122", ink: 2.6, inkColor: "#ffffff" },
    { d: "M57 34 L69 5 L84 3", ink: 4.4 },
  ],
};

const latte: DrawingSpec = {
  viewBox: "0 0 220 140",
  shapes: [
    { d: ell(105, 114, 100, 20), fill: C.cream, shade: C.paperShade, shadeWidth: 10 },
    { d: ell(105, 110, 60, 9), fill: "#f1e6d2", ink: 1.8 },
    { d: "M170 48 Q211 44 205 70 Q200 97 158 92 L160 82 Q192 85 194 70 Q197 55 170 60 Z", fill: C.cream, shade: C.cupShade, shadeWidth: 6 },
    { d: "M32 40 Q34 104 105 108 Q176 104 178 40 Z", fill: C.cream, shade: C.cupShade, shadeWidth: 18 },
    { d: ell(105, 40, 73, 15), fill: C.cream, ink: 2.4 },
    { d: ell(105, 41, 64, 11), fill: C.latte, shade: C.coffee, shadeWidth: 7, ink: 1.6 },
    { d: "M105 50 C86 43 86 33 96 33 C100 33 104 36 105 40 C106 36 110 33 114 33 C124 33 124 43 105 50 Z", fill: "#f8ecd6", ink: 0 },
    { d: "M118 125 L162 113", ink: 1.8 },
    { d: ell(130, 118, 5, 2.4), fill: "#c9a05a", ink: 1.3, transform: "rotate(-40 130 118)" },
    { d: ell(141, 115, 5, 2.4), fill: "#c9a05a", ink: 1.3, transform: "rotate(-40 141 115)" },
    { d: ell(152, 112, 5, 2.4), fill: "#c9a05a", ink: 1.3, transform: "rotate(-40 152 112)" },
    { d: ell(135, 125, 5, 2.4), fill: "#c9a05a", ink: 1.3, transform: "rotate(40 135 125)" },
    { d: ell(146, 122, 5, 2.4), fill: "#c9a05a", ink: 1.3, transform: "rotate(40 146 122)" },
  ],
};

const choco: DrawingSpec = {
  viewBox: "0 0 110 150",
  shapes: [
    { d: rect(24, 6, 58, 60, 4), fill: C.choc, shade: C.chocDark, shadeWidth: 6, transform: "rotate(-8 55 40)" },
    { d: "M43 6v60 M63 6v60 M24 26h58 M24 46h58", ink: 1.8, inkColor: "#2e180b", transform: "rotate(-8 55 40)" },
    {
      d: "M28 11h11 M47 11h12 M67 11h11 M28 31h11 M47 31h12 M67 31h11",
      ink: 2,
      inkColor: "#c8956a",
      transform: "rotate(-8 55 40)",
    },
    { d: "M16 58 L88 50 L94 138 L22 146 Z", fill: C.cream, shade: "#ddd0ba", shadeWidth: 12 },
    {
      d: "M17 70 Q26 79 34 69 Q42 61 50 71 Q58 79 66 67 Q74 58 82 66 Q87 70 89 63 L88 50 L16 58 Z",
      fill: C.choc,
      shade: C.chocDark,
      shadeWidth: 5,
    },
    { d: ell(60, 128, 7, 4.5), fill: C.coffee, ink: 1.6, transform: "rotate(-20 60 128)" },
    { d: "M54 129 Q60 125 66 127", ink: 1.3, transform: "rotate(-20 60 128)" },
  ],
  extra: (
    <text
      x="56"
      y="108"
      textAnchor="middle"
      transform="rotate(-6 56 104)"
      style={{ fontFamily: "var(--font-hand), cursive" }}
      fontSize="25"
      fill="#3a2a1f"
    >
      Lotus
    </text>
  ),
};

const fries: DrawingSpec = {
  viewBox: "0 0 60 80",
  shapes: [
    ...[
      [12, 10, -10, 15, 30],
      [21, 4, -4, 24, 26],
      [30, 2, 0, 33, 25],
      [38, 6, 6, 41, 27],
      [45, 12, 12, 48, 31],
    ].map(([x, y, a, cx, cy]) => ({
      d: rect(x, y, 6, 44 - y / 2),
      fill: C.yellow,
      shade: "#d39d3b",
      shadeWidth: 2.5,
      ink: 1.6,
      transform: `rotate(${a} ${cx} ${cy})`,
    })),
    { d: "M7 36 L53 36 L46 77 L14 77 Z", fill: C.orange, shade: "#bd6a34", shadeWidth: 6, ink: 2 },
    { d: "M7 36 Q30 46 53 36 M18 44 L20 74 M30 46 L30 76 M42 44 L40 74", ink: 1.3 },
  ],
};

const pizza: DrawingSpec = {
  viewBox: "0 0 90 80",
  shapes: [
    { d: "M40 44 L71.5 38.4 A32 32 0 1 1 56 16.3 Z", fill: "#e6ad5c", shade: "#c07c36", shadeWidth: 6, ink: 2 },
    { d: "M40 44 L66 39.5 A26.5 26.5 0 1 1 53 21 Z", fill: "#f6d88a", ink: 0 },
    ...[
      [28, 52, 4.5],
      [45, 60, 4.5],
      [24, 34, 4.5],
      [40, 28, 4],
      [56, 50, 4],
    ].map(([x, y, r]) => ({ d: circ(x, y, r), fill: C.red, shade: "#9b3a24", shadeWidth: 2, ink: 1.4 })),
    { d: "M48 36 L79.5 30.4 A32 32 0 0 0 64 8.3 Z", fill: "#f0c472", shade: "#c07c36", shadeWidth: 5, ink: 2 },
    { d: circ(66, 22, 3.5), fill: C.red, ink: 1.3 },
  ],
};

const cupcake: DrawingSpec = {
  viewBox: "0 0 60 90",
  shapes: [
    { d: "M12 52 L48 52 L42 86 L18 86 Z", fill: C.caramel, shade: C.caramelDark, shadeWidth: 6, ink: 2 },
    { d: "M22 52 L24 86 M30 52 L30 86 M38 52 L36 86", ink: 1.4 },
    {
      d: "M9 52 Q7 42 17 42 Q11 32 23 30 Q19 20 29 18 Q29 9 33 4 Q40 13 38 20 Q47 22 41 30 Q51 32 45 42 Q55 44 51 52 Z",
      fill: C.foam,
      shade: "#dcbf92",
      shadeWidth: 6,
      ink: 2,
    },
    { d: "M17 42 Q30 46 45 42 M23 30 Q31 33 41 30", ink: 1.4 },
  ],
};

const cake: DrawingSpec = {
  viewBox: "0 0 80 60",
  shapes: [
    { d: ell(40, 50, 37, 8), fill: C.cream, shade: C.paperShade, shadeWidth: 5, ink: 1.8 },
    { d: "M10 34 L58 20 L70 28 L22 42 Z", fill: "#f6e2c4", ink: 1.8 },
    { d: "M22 42 L70 28 L70 40 L22 54 Z", fill: C.caramel, shade: C.caramelDark, shadeWidth: 4, ink: 1.8 },
    { d: "M10 34 L22 42 L22 54 L10 46 Z", fill: "#b67b45", ink: 1.8 },
    { d: "M22 48 L70 34", ink: 2.2, inkColor: "#f8ecd6" },
  ],
};

const steam: DrawingSpec = {
  viewBox: "0 0 80 80",
  shapes: [
    { d: "M32 27 Q25 20 32 14 Q38 8 33 2 M44 27 Q37 20 44 14 Q50 8 45 2", ink: 1.8 },
    { d: ell(38, 69, 33, 7), fill: C.cream, shade: C.paperShade, shadeWidth: 5, ink: 1.8 },
    { d: "M60 38 Q77 38 74 50 Q72 63 56 60 L57 55 Q68 56 69 50 Q70 43 60 44 Z", fill: C.cream, ink: 1.8 },
    { d: "M14 34 Q16 65 38 67 Q60 65 62 34 Z", fill: C.cream, shade: C.cupShade, shadeWidth: 10, ink: 2 },
    { d: ell(38, 34, 24, 5), fill: C.caramel, shade: C.coffee, shadeWidth: 3, ink: 1.8 },
  ],
};

const croissant: DrawingSpec = {
  viewBox: "0 0 140 110",
  shapes: [
    { d: ell(24, 92, 20, 5), fill: C.cream, shade: C.paperShade, shadeWidth: 4, ink: 1.8 },
    { d: "M34 67 Q48 67 45 76 Q43 86 33 83 L34 79 Q40 80 41 76 Q42 71 34 71 Z", fill: C.cream, ink: 1.8 },
    { d: "M9 64 L37 64 L35 87 Q23 92 11 87 Z", fill: C.cream, shade: C.cupShade, shadeWidth: 7, ink: 2 },
    { d: ell(23, 64, 14, 3.6), fill: C.coffee, ink: 1.8 },
    // Overlapping rolls laid along a shallow crescent (arc around 68,20), tips first so the middle sits on top.
    // Each roll is stretched along the radius, the way a croissant's layers run across it.
    ...[
      [110, 13, 11],
      [10, 13, 11],
      [85, 21, 18],
      [35, 21, 18],
      [60, 28, 22],
    ].map(([deg, rx, ry]) => {
      const x = 68 + 60 * Math.cos((deg * Math.PI) / 180);
      const y = 20 + 60 * Math.sin((deg * Math.PI) / 180);
      const middle = deg === 60;
      return {
        d: ell(x, y, rx, ry),
        fill: middle ? "#ebbd70" : "#e7b465",
        shade: "#b06f32",
        shadeWidth: middle ? 10 : 7,
        ink: 2.1,
        transform: `rotate(${deg} ${x} ${y})`,
      };
    }),
    { d: "M88 66 Q98 70 101 82 M98 58 Q108 62 111 74", ink: 1.4 },
  ],
};

const cheesecake: DrawingSpec = {
  viewBox: "0 0 140 110",
  shapes: [
    { d: "M14 26 L20 100 L46 100 L52 26 Z", fill: C.glass, shade: C.glassShade, shadeWidth: 6 },
    { d: "M16.5 50 L20.5 98 L45.5 98 L49.5 50 Z", fill: "#9b6a43", shade: C.chocDark, shadeWidth: 4, ink: 0 },
    { d: rect(23, 70, 10, 10, 1.5), fill: "#fdfbf5", ink: 1.4, transform: "rotate(-10 28 75)" },
    { d: ell(33, 26, 19, 3.5), fill: "#ece6d6", ink: 2 },
    { d: "M37 26 L46 3 L59 3", ink: 3.6 },
    { d: ell(98, 92, 40, 10), fill: C.cream, shade: C.paperShade, shadeWidth: 6, ink: 2 },
    { d: "M62 76 L84 88 L84 100 L62 88 Z", fill: "#e9d3a8", ink: 2 },
    { d: "M84 88 L130 70 L130 82 L84 100 Z", fill: "#f3e1bd", shade: "#d9bd8a", shadeWidth: 4, ink: 2 },
    { d: "M84 95 L130 77 L130 82 L84 100 Z", fill: "#b07a45", ink: 1.6 },
    { d: "M62 76 L110 58 L130 70 L84 88 Z", fill: "#f7ecd2", ink: 2 },
    { d: "M70 77 Q80 70 90 75 Q100 69 112 64 Q118 62 124 68", ink: 3, inkColor: "#a86a35" },
    { d: rect(94, 60, 16, 10, 2), fill: C.caramel, ink: 1.5, transform: "rotate(-18 102 65)" },
  ],
};

const burger: DrawingSpec = {
  viewBox: "0 0 140 110",
  shapes: [
    { d: rect(121, 8, 10, 7, 1.5), fill: C.red, ink: 1.8 },
    {
      d: "M122 15 L130 15 L130 27 Q138 37 136 51 L136 98 Q126 103 116 98 L116 51 Q114 37 122 27 Z",
      fill: C.cola,
      shade: "#2f120a",
      shadeWidth: 5,
    },
    { d: rect(116, 58, 20, 14), fill: C.cream, ink: 1.6 },
    { d: "M120 66 Q126 61 132 66", ink: 1.6, inkColor: C.red },
    { d: "M12 78 L106 78 Q106 96 59 96 Q12 96 12 78 Z", fill: C.bun, shade: C.bunShade, shadeWidth: 7 },
    { d: rect(10, 62, 98, 15, 7), fill: "#6e3f22", shade: "#3f220f", shadeWidth: 5 },
    { d: "M12 58 L106 58 L100 67 L93 60 L30 60 L23 68 Z", fill: "#f2cc4f", ink: 1.8 },
    {
      d: "M8 54 Q16 62 24 54 Q32 62 40 54 Q48 62 56 54 Q64 62 72 54 Q80 62 88 54 Q96 62 110 54 L106 50 L12 50 Z",
      fill: C.green,
      shade: "#6c8d3c",
      shadeWidth: 4,
    },
    { d: "M12 51 Q14 18 59 18 Q104 18 106 51 Z", fill: C.bun, shade: C.bunShade, shadeWidth: 10 },
    ...[
      [44, 32, -20],
      [60, 27, 0],
      [76, 33, 20],
      [52, 41, 0],
      [70, 42, 10],
      [34, 43, 0],
      [86, 43, 0],
    ].map(([x, y, a]) => ({ d: ell(x, y, 3, 1.6), fill: "#fdf8ec", ink: 1.1, transform: `rotate(${a} ${x} ${y})` })),
  ],
};

const pasta: DrawingSpec = {
  viewBox: "0 0 140 110",
  shapes: [
    { d: "M12 56 Q14 98 64 100 Q114 98 116 56 Z", fill: C.cream, shade: C.cupShade, shadeWidth: 14 },
    { d: ell(64, 56, 52, 10), fill: "#f6e6c0", shade: "#e2c890", shadeWidth: 5, ink: 2.2 },
    { d: "M26 54 Q34 38 44 48 Q54 32 64 44 Q74 32 84 44 Q94 36 102 54 Q64 62 26 54 Z", fill: "#f1d38a", shade: "#d4a94e", shadeWidth: 5, ink: 2 },
    { d: "M34 52 Q40 44 48 50 Q56 42 62 50 M68 50 Q76 42 82 50 Q90 44 96 52", ink: 1.4 },
    { d: ell(54, 44, 6, 2.6), fill: C.leaf, ink: 1.3, transform: "rotate(-25 54 44)" },
    { d: circ(66, 36, 7), fill: C.red, shade: "#9b3a24", shadeWidth: 3, ink: 2 },
    { d: "M66 29 L69 25", ink: 2, inkColor: "#5c7d2f" },
    { d: "M128 102 L128 42 M120 14 L120 32 Q120 42 128 42 Q136 42 136 32 L136 14 M128 14 L128 32", ink: 2.2 },
  ],
};

const hotchoc: DrawingSpec = {
  viewBox: "0 0 140 110",
  shapes: [
    { d: "M54 30 Q46 22 54 14 Q60 8 55 2 M70 30 Q62 22 70 14 Q76 8 71 2", ink: 1.8 },
    { d: "M98 48 Q120 48 117 64 Q115 82 94 80 L95 73 Q109 74 110 64 Q111 55 98 56 Z", fill: C.cream, ink: 2 },
    { d: "M30 38 L100 38 L94 98 Q65 106 36 98 Z", fill: C.cream, shade: C.cupShade, shadeWidth: 12 },
    { d: "M31.5 56 L98.5 56 L97.6 66 L32.4 66 Z", fill: C.caramel, ink: 1.6 },
    { d: ell(65, 38, 35, 6), fill: "#6e3f22", ink: 2 },
    { d: ell(58, 35, 9, 4), fill: "#fbf3e6", ink: 1.4 },
    { d: ell(74, 37, 7, 3.4), fill: "#fbf3e6", ink: 1.4 },
    { d: rect(8, 78, 28, 22, 2), fill: C.choc, shade: C.chocDark, shadeWidth: 4, transform: "rotate(-14 22 92)" },
    { d: "M22 78v22 M8 89h28", ink: 1.6, inkColor: "#2e180b", transform: "rotate(-14 22 92)" },
  ],
};

const leaves: DrawingSpec = {
  viewBox: "0 0 130 100",
  shapes: [
    { d: "M34 94 L36 62", ink: 2 },
    {
      d: "M36 66 L18 70 L22 56 L4 46 L20 42 L12 24 L30 32 L32 10 L42 28 L56 16 L54 36 L70 36 L58 48 L68 62 L48 58 Z",
      fill: "#e0782f",
      shade: "#b8462a",
      shadeWidth: 8,
      ink: 2,
    },
    { d: "M36 66 L36 30 M36 52 L20 44 M36 50 L56 38", ink: 1.2 },
    {
      d: "M26 42 L14 44 L16 34 L4 28 L15 25 L10 12 L22 18 L24 2 L31 15 L40 7 L39 21 L50 21 L41 30 L48 40 L34 38 Z",
      fill: "#eba843",
      shade: "#c77a2a",
      shadeWidth: 6,
      ink: 2,
      transform: "translate(70 8) rotate(24 25 25)",
    },
    { d: "M26 52 L26 40", ink: 1.8, transform: "translate(70 8) rotate(24 25 25)" },
    { d: "M10 22 Q-2 10 10 0 Q22 10 10 22 Z", fill: "#d97f36", shade: "#a8521f", shadeWidth: 4, ink: 1.8, transform: "translate(66 60) rotate(-30 10 10)" },
    { d: "M10 22 L10 4", ink: 1.1, transform: "translate(66 60) rotate(-30 10 10)" },
  ],
};

const bean: DrawingSpec = {
  viewBox: "0 0 80 56",
  shapes: [
    { d: ell(40, 28, 32, 22), fill: C.coffee, shade: C.chocDark, shadeWidth: 10, ink: 4.5 },
    { d: "M12 32 Q40 12 68 24", ink: 4.5 },
  ],
};

export const art = { iced, latte, choco, fries, pizza, cupcake, cake, steam, croissant, cheesecake, burger, pasta, hotchoc, leaves, bean };
export type ArtName = keyof typeof art;

export function Art({ name, label, className }: { name: ArtName; label?: string; className?: string }) {
  return <Drawing spec={art[name]} label={label} className={className} />;
}
