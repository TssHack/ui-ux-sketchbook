# Drawing illustrations as specs

Illustrations are data (`{ viewBox, shapes }`), rendered by `Drawing.tsx` (React) or `Sketchbook.drawing()` / `data-art` (plain JS; register new ones on `Sketchbook.art`). See `assets/illustrations.example.tsx` or `assets/vanilla/art-library.js` for 15 finished ones (iced coffee, latte, chocolate bar, fries, pizza, cupcake, cake slice, steaming cup, croissant, cheesecake, burger, pasta, hot chocolate, autumn leaves, coffee bean, plus a logo badge in the café build).

## How a spec draws

Each `Shape` is rendered in order, so later shapes sit on top:
1. flat `fill` + the `#hatch` pattern over it (pencil grain),
2. optional `shade`: a wide stroke of a darker colour clipped inside the shape, so colour gathers along the inside edge like real pencil,
3. two ink passes: the main stroke and a thin ghost stroke offset by ~0.8 units, which reads as a hand-drawn double line.

Helpers: `ell(cx, cy, rx, ry)`, `circ(cx, cy, r)`, `rect(x, y, w, h, r)`. Use `transform` for rotation (`rotate(a cx cy)`).

## Recipe

- Pick a viewBox near the size it will be shown (≈ 60–220 units). Ink width is in viewBox units, so a tiny viewBox shown large gets fat lines.
- Draw back to front: saucer, handle, body, rim, contents, highlights, straw.
- Every coloured shape gets a `shade` one or two steps darker; `shadeWidth` ≈ 10–20% of the shape's size.
- Ink 2–2.6 for outlines, 1.2–1.8 for interior detail (creases, segments, veins).
- White highlight lines (`inkColor: "#fff"`) sell glass and gloss.
- Repeated parts (fries, seeds, pepperoni, croissant rolls) come from small arrays mapped to shapes.
- Composite scenes (cup + croissant, burger + cola) go in one 140×110 spec so product cards share an aspect ratio.

## Lessons

- A croissant drawn as rolls in a straight line reads as a caterpillar. Lay rolls along an arc (compute centres with cos/sin), make them overlap by ~20%, stretch each along the radius, middle roll biggest and drawn last.
- Check every new drawing at the size it will actually appear; things that read at 300px often turn to mush at 60px.
- Use `lite` / `data-lite` below ~64px; at that size the hatch and ghost line are invisible but still cost elements.
- Don't add SVG `filter` to drawings. The look comes from the hatch, the clipped shading and the double ink line.
