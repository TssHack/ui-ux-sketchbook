# ui-ux-sketchbook

An agent skill for building real, responsive websites that look hand-drawn: shaky fine-liner outlines, coloured-pencil shading gathered at the edges, hand-lettered titles and ink-and-pencil illustrations. RTL Persian/Arabic sites are first-class.

Give it a photo of a website sketched on paper, or ask for a "hand-drawn / sketchbook / doodle" look, and it builds the site the sketch represents: working navigation on phones, clear calls to action, forms that validate, and layouts that hold from 320px to desktop.

## What's inside

```
SKILL.md                      instructions the agent follows
assets/
  sketch.css                  tokens + primitive styles (shared by both builds)
  vanilla/
    sketchbook.js             primitives as HTML attributes: data-sketch, data-hand, data-art
    art-library.js            15 ready illustrations
    starter.html              single-page starter (header, hero, cards, form, footer)
  components/                 React / Next.js build of the same primitives
    rough.ts                  seeded wobbly geometry
    SketchBox.tsx             element with a hand-drawn outline and pencil shading
    Drawing.tsx               illustration renderer
    HandText.tsx              hand-lettered Latin text
    SketchDefs.tsx            shared hatch pattern
  illustrations.example.tsx   the 15 illustrations as React specs
references/
  responsive.md               layout patterns and every bug this style has produced
  drawing.md                  how to draw new illustrations
scripts/
  inline_assets.py            inline local CSS/JS into one HTML file
  audit-overflow.js           find elements that overflow at a given width
evals/evals.json              test prompts used to check the skill
```

## Two builds

- **Plain JS:** for single-file pages or sites without a framework. Copy `starter.html`, `sketchbook.js`, `art-library.js` and `sketch.css`, then build on the starter and inline everything with `python scripts/inline_assets.py page.html index.html`.
- **React / Next.js:** for projects that will keep growing. Copy `assets/components/` into `components/sketch/`, add `sketch.css` to the global styles, and render `<SketchDefs />` once in the root layout.

```html
<section data-sketch="bottom" data-tint="#8fa45c">…</section>     <!-- band with one rough edge -->
<a class="card" data-sketch data-tint="#d08a45">…</a>               <!-- framed, pencil-shaded card -->
<h2><span data-hand>Special menu</span></h2>                        <!-- hand lettering (Latin only) -->
<span data-art="latte" data-label="Latte" data-draw-in></span>     <!-- illustration that traces itself in -->
```

## Design rules it enforces

- **No SVG filters.** The wobble is in the geometry and the grain is a hatch pattern, so pages stay fast on phones.
- **About 1,200 SVG elements per page at most.** Small icons use a lite render.
- **Mobile-first:** breakpoints at 600 / 900 / 1200, checked at 320–1280px.
- **RTL done properly:** hand lettering stays LTR, the drawn order of rows is kept, and Persian digits are accepted in forms.

## Install

Put the `ui-ux-sketchbook` folder in your agent's skills directory, or install the packaged `.skill` file.
