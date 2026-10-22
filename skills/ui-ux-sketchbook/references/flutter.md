# Flutter build

`assets/flutter/` is a Dart package named `sketchbook` with the same primitives as the web builds. It depends only on the Flutter SDK (3.27+), so it works on Android, iOS, web, Windows, macOS and Linux.

## Set up

Copy the folder into the app (for example to `packages/sketchbook/`) and depend on it by path:

```yaml
dependencies:
  sketchbook:
    path: packages/sketchbook
```

Fonts: add a handwriting face for `HandText` (Gochi Hand) and a Persian face if the app is RTL (Vazirmatn), as font assets in `pubspec.yaml` or through the `google_fonts` package. On web, CanvasKit falls back to Noto for Persian when no font is bundled; ship one anyway so phones without network still render correctly.

## The widgets

| Widget | Web equivalent | Use |
|---|---|---|
| `SketchBox(tint:, seed:, child:)` | `data-sketch` / `<SketchBox>` | Rough rounded frame (two pen passes) with coloured-pencil shading along the inside edges |
| `SketchBox(edges: {SketchEdge.bottom}, ...)` | `data-sketch="bottom"` | Bands: header, hero, footer |
| `SketchBox(radius: 999, ...)` | `data-radius="999"` | Round badge |
| `SketchDrawing.named('latte', label: 'Latte', drawIn: true)` | `data-art` / `<Drawing>` | Ready illustration; the pen traces it in |
| `SketchDrawing(spec)` | spec objects | Your own illustration (see drawing.md; same SVG path strings) |
| `HandText('Special menu', style: ...)` | `data-hand` / `<HandText>` | Hand-lettered Latin text, read once by screen readers |
| `SketchColors.*` | `sketch.css` tokens | Palette; retune to the sketch |

`SketchBox` options: `edgeReach: Offset(x, y)` sets how far the shading reaches in, as fractions (cards 0.2, panels 0.1, bands and buttons 0.5). `tintStrength` sets the opacity. `background` adds a fill under the shading, and `padding` adds space inside.

`sketchArt` is generated from `assets/vanilla/art-library.js` by `tools/gen_flutter_art.js` in the skill's repository. To add a drawing for Flutter only, build a `DrawingSpec` in the app instead of editing the generated file.

## Layout

- Use the same breakpoints as the web builds (600 / 900 / 1200) with `LayoutBuilder` or `MediaQuery.sizeOf`.
- Header: under 900 show a small badge, cart and menu button that opens an `endDrawer`; from 900 show the sketch's band with links on both sides of a large badge.
- Hero: stacked on phones, with the scene capped at about 540 wide on tablets and placed side by side on desktop.
- Card rows that must keep the drawn order (Food · Cake · Special) go in a `Directionality(textDirection: TextDirection.ltr)`. Everything else follows the app's RTL direction.
- Horizontal card scrollers: `ListView` with `scrollDirection: Axis.horizontal` and cards about `min(240, 72% of width)` wide, so the next card peeks.
- Test with `tester.view.physicalSize` at 360, 768 and 1280 and assert `tester.takeException()` is null. Overflow errors fail the test.

## RTL / Persian

- Wrap the app in `Directionality(textDirection: TextDirection.rtl)` (or set `locale: Locale('fa')` with localization delegates).
- `HandText` forces LTR internally, so it is safe inside RTL layouts. Never use it for Persian text.
- Format prices with Persian digits and `٬` as the thousands separator. Accept Persian digits in inputs and convert them before validating.

## Performance

- Every `SketchDrawing` has its own `RepaintBoundary`, and the parsed paths are cached by their path data, so scrolling lists doesn't re-parse.
- `SketchBox` outline paths are cached by size and seed, and the shading uses two `saveLayer` calls per box. Keep the count of shaded boxes visible at once reasonable (dozens, not hundreds). For long lists, prefer `background` with no `tint` on the list items.
- Use `lite: true` for drawings under about 64 logical pixels.
- `drawIn` respects the platform's reduce-motion setting (`MediaQuery.disableAnimations`).
