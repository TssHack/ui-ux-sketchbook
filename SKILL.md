---
name: ui-ux-sketchbook
description: Build real, responsive websites and web apps that look hand-drawn, like a page from a sketchbook — shaky fine-liner ink outlines, coloured-pencil shading gathered at the edges, hand-lettered titles, ink-and-pencil illustrations — including RTL Persian/Arabic sites. Use this skill whenever the user shares a photo or scan of a hand-drawn website/app sketch or wireframe and wants it built ("implement this drawing", "پیاده‌اش کن", "این طرح دستی رو بساز"), or asks for a hand-drawn, sketchy, doodle, notebook, crayon, coloured-pencil, paper or "illustrated" look for a site, landing page, café/restaurant/shop menu, portfolio or app UI — even if they don't say "sketchbook". Ships the primitives in two builds, a plain-JS single-file starter and React/Next.js components (rough outlines, pencil shading, 15 illustrations, hand lettering), plus responsive and performance rules learned the hard way.
---

# ui-ux-sketchbook

A working site that wears the sketch's clothes. The drawing sets the look and the section order; the site still has to behave like a real product: navigation that works on a phone, clear calls to action, flows people can finish (order, book, contact), and layouts that hold from 320px to desktop.

The most common failure is building a *picture of the sketch*: one static page that copies the drawing pixel by pixel, with nothing to do on it and a layout that only works at one width. Users who hand you a sketch want the site it represents. Read the sketch for intent, not just shapes.

## 1. Read the sketch

Before writing code, make an inventory (write it in your head or a scratch note, not in chat):

- **Sections in order** and what each is for (nav band, hero, category cards, special-menu carousel…).
- **Brand marks**: logo shape (round badge overlapping the nav band is common), wordmark spelling — keep the user's spelling of names, fix only obvious typos in body words and say so.
- **Colour per region**: which pencil colour shades which band or card, and whether it's concentrated at edges (it usually is).
- **Implied behaviour**: dots under a hero = carousel; a card cut off at the edge = horizontal scroller (in RTL it scrolls toward the left); a row of small coloured ovals = tabs/filters; nav words = pages.
- **Decorations** that make it *this* sketch: scattered beans, leaves, doodled food. Keep them, as `aria-hidden` art.
- **Language/direction**: Persian/Arabic text means an RTL site. Latin titles in the drawing stay as hand-lettered accents.

Then plan the real site around it: which pages the nav implies, what the primary action is (order, book, buy, contact), and what demo data you need. Mark demo content (addresses, phones, prices, events) as placeholders in code comments and tell the user.

## 2. Set up the primitives

The `assets/` folder holds code that already works, in two builds. Copy, don't rewrite or port by hand.

**Pick the build from what the user asked for:**
- A single HTML file, a static page, "no framework", or anything that must open straight from disk → **plain-JS build** (`assets/vanilla/`), below.
- A React / Next.js project, or a multi-page app the user will keep developing → **React build** (`assets/components/`), further down.

### Plain-JS build (single-file pages)

| Asset | What it does |
|---|---|
| `assets/vanilla/starter.html` | A working page to start from: sticky header (band + badge on desktop, burger → native `<dialog>` side sheet on phones), hero with carousel dots, three category cards, card scroller, validated form with success state, footer with credit line. RTL Persian by default. |
| `assets/vanilla/sketchbook.js` | The primitives as markup attributes (no code to call): `data-sketch` frames, `data-hand` lettering, `data-art` drawings. Watches the DOM, so dialogs and rendered lists get sketched too. |
| `assets/vanilla/art-library.js` | The 15 illustrations as `Sketchbook.art.*` (iced, latte, choco, fries, pizza, cupcake, cake, steam, croissant, cheesecake, burger, pasta, hotchoc, leaves, bean). Add your own with `Sketchbook.art.name = { viewBox, shapes }`. The set is café/food; for any other subject (books, plants, tools…) draw a new set following `references/drawing.md` rather than forcing food drawings onto it. |
| `assets/sketch.css` | Shared tokens and primitive styles (same file both builds use). |
| `scripts/inline_assets.py` | `python scripts/inline_assets.py page.html out.html` inlines the local CSS/JS into one self-contained file. |

Workflow: copy `starter.html`, `sketchbook.js`, `art-library.js` and `sketch.css` into the output folder; reshape the starter to the sketch; then run `inline_assets.py` and ship the inlined file (delete the loose copies if the user asked for one file).

```html
<section class="hero" data-sketch="bottom" data-tint="#8fa45c" data-seed="9">…</section>   <!-- band, one rough edge -->
<a class="card" href="#menu" data-sketch data-tint="#d08a45" data-seed="21">…</a>          <!-- framed, pencil-shaded card -->
<a class="btn btn--primary" data-sketch data-radius="14" data-tint="#a8693a">سفارش</a>
<a class="badge" data-sketch data-radius="999">…</a>                                        <!-- round badge -->
<span data-art="latte" data-label="لاته" data-draw-in></span>                               <!-- drawing, traces itself in -->
<span data-art="bean" data-lite></span>                                                     <!-- small icon: cheap render -->
<h2 class="section-head"><span class="section-head__hand" data-hand data-seed="17">Special menu</span><span class="section-head__fa">پیشنهادها</span></h2>
```

Don't put `data-hand` and `data-sketch` on the same element (lettering replaces the element's content; frames insert an SVG into it). Wrap one in the other.

### React build (Next.js projects)

| Asset | Put it in | What it does |
|---|---|---|
| `assets/components/rough.ts` | `components/sketch/` | Seeded wobbly geometry: `roughRoundRect`, `roughLine`, `roughEllipse` |
| `assets/components/SketchBox.tsx` | `components/sketch/` | Any element (`as=` div/button/Link/section/li…) with a measured hand-drawn outline (double pen pass) and optional pencil edge shading (`tint=`) |
| `assets/components/Drawing.tsx` | `components/sketch/` | Renders an illustration spec: pencil fill + hatch, clipped edge shading, double ink line. Helpers `ell`, `circ`, `rect` |
| `assets/components/HandText.tsx` | `components/sketch/` | Hand-lettered Latin text, each letter jittered, wraps only between words |
| `assets/components/SketchDefs.tsx` | `components/sketch/` | The shared `#hatch` patterns. Render once in the root layout |
| `assets/sketch.css` | global CSS | Tokens + the CSS those components need + buttons, pills, fields, chips, section heads, scribble highlight |
| `assets/illustrations.example.tsx` | read / adapt | 15 finished illustration specs and an `Art` component |

Fonts (Google, via `next/font/google` in Next.js): **Gochi Hand** for hand lettering (`--font-hand`), **Vazirmatn** for Persian/Latin body (`--font-body`), **Aref Ruqaa** for handwritten-feeling Persian product names (`--font-body-hand`). For Latin-only sites swap Vazirmatn for a humanist sans.

Next.js App Router is what this was built and tested on; `SketchBox` is a client component, the rest are server-safe. In a single HTML file the same fonts load from a Google Fonts `<link>` (see the starter).

#### Using them

```tsx
<SketchBox as="section" className="hero" edges={["bottom"]} tint="#8fa45c" seed={9}>…</SketchBox>   // band with one rough edge
<SketchBox as={Link} href="/menu" className="cat" tint="#d08a45" seed={21}>…</SketchBox>              // framed card
<SketchBox as="button" type="button" className="btn btn--primary" tint="#a8693a" radius={14}>سفارش</SketchBox>
<Drawing spec={latte} label="لاته" className="draw-in" />                                             // illustration that draws itself in
<Drawing spec={bean} lite />                                                                            // small icon: cheap render
<h2 className="section-head"><HandText text="Special menu" seed={17} className="section-head__hand" /><span className="section-head__fa">پیشنهادهای این هفته</span></h2>
```

- Give every SketchBox a different `seed` so outlines don't repeat.
- Tune shading per component with CSS vars: `--edge-x`, `--edge-y` (how far the pencil reaches in), `--tint-strength`. Bands use 50%/50% (shaded all over), cards ~20%, big panels ~10%.
- Use one tint family per region, taken from the sketch.
- New illustrations: read `references/drawing.md`.

## 3. Rules that keep it fast

- **No SVG filters** (`feTurbulence`, `feDisplacementMap`) on shapes, outlines or text, and no CSS `filter: url(#…)` on page elements. They are the obvious way to fake ink and pencil, and with dozens of drawings on a page they become hundreds of filters re-run on every repaint. The wobble lives in the geometry (`rough.ts`), the grain in the `#hatch` pattern, the pencil edge in clipped strokes and CSS masks. The one exception is the paper-texture background tile in `sketch.css`, which is rasterised once.
- **Keep the page under ~1,200 SVG elements** (check with `document.querySelectorAll("svg *").length`). Every full drawing costs about 4–6 elements per shape, and in tests pages that drew everything at full detail reached 2,000+ paths. The levers, in order:
  - `lite` (React) / `data-lite` (plain JS) on anything under ~64px: beans, perks, footer doodles, cart thumbnails. It drops the hatch, the edge shading and the ghost ink line.
  - Don't repeat the same full drawing many times on one screen; repeat one and keep the rest lite or use a smaller set.
  - Leave the outline geometry alone: `rough.ts` / `sketchbook.js` already space their samples by size, so big frames stay cheap.
- No `backdrop-filter` on sticky bars; use a solid paper background.
- Animate sparingly: the pen-trace `draw-in` on hero art and dialogs, a slow float on a few decorative beans. Respect `prefers-reduced-motion` (already in `sketch.css`).

## 4. RTL / Persian

- `<html lang="fa" dir="rtl">`. Keep the header `dir="ltr"` only if the sketch's nav order is left-to-right and you want it identical.
- `HandText` is for Latin only. Splitting Persian into letters breaks the joins.
- Rows whose order is part of the drawing (three category cards) get `direction: ltr`; content lists stay RTL.
- Carousels: `dir="rtl"` track; "next" scrolls toward negative `scrollLeft`.
- Prices and times: `toLocaleString("fa-IR")` and Persian digits. Accept Persian digits in phone inputs and normalise them before validating.
- Mixed-direction values (`V60، کمکس`) shouldn't sit inside `dir="ltr"`; let the bidi algorithm handle them.

## 5. Build it as a real site

A typical set for a café/restaurant/shop sketch (scale it to what the user asked for):

- **Header**: sticky; phone = badge logo, cart, burger → side sheet with links and contact; ≥900px = the sketch's band with the overlapping badge, shrinking on scroll; active-page underline drawn as a wavy SVG stroke.
- **Hero**: hand-lettered headline + plain-language line, two CTAs (primary action, secondary action), an open-now or status chip if it applies, the sketch's scene as a carousel with dots.
- **The sketch's sections** in the sketch's order, then supporting sections that make it complete (featured item, how-it-works, events, about/visit).
- **Interactive parts**: menu/catalogue with filter pills + search; item dialog with add-to-cart and suggested pairings; cart drawer; checkout or booking form with inline validation; success state with a reference code. Demo backends can be in-memory API routes; say so.
- **Footer**: brand, links, hours, contact, small signup, and a bottom bar with © and any credit the user asks for ("توسعه یافته توسط …").
- **404** in the same style.

Mobile-first CSS with breakpoints at 600 / 900 / 1200. Read `references/responsive.md` before styling; it lists the layout patterns that held up and every bug this style has produced.

## 6. Verify before handing over

1. Type-check / build (React), or `node --check` the inline scripts (plain JS).
2. Open it in a browser at 320, 375, 768, ~920 and 1280. At each width run `scripts/audit-overflow.js` in the page and look at **every section** (use `#anchor` URLs to jump down if the preview doesn't repaint on scroll).
3. Count SVG elements against the budget above.
4. Walk the main flow end to end (add to cart → checkout → success; booking → confirmation), including one invalid submit.
5. If no browser is available, say so plainly and list which of these checks were skipped; don't imply the page was seen.
6. Tell the user what you checked, what you couldn't, and what is demo data.
