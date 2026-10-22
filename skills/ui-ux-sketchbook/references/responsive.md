# Responsive checklist for sketchbook pages

Every item here is a bug that actually shipped once in this style. Check them before calling a page done.

## Widths to test

320, 375, 550 (narrow desktop pane / split screen), 768, 900–1000 (where the desktop header first appears), 1280.
At each width: run `scripts/audit-overflow.js`, then look at every section, not just the top of the page. An empty audit only proves nothing leaves the viewport; cramped, lopsided or badly wrapped sections still need eyes.

## Bugs specific to this style

1. **Generic `svg` selectors hit the ink overlay.** `SketchBox` renders an absolutely positioned `<svg class="sketch-box__ink">` inside the element. A rule like `.search svg { width: 20px }` shrinks the outline too, and the frame is drawn in the wrong place. Always give icons their own class (`.search__icon`), never style `.component svg`.
2. **HandText reverses in RTL.** It is an inline-flex row of letters; in an RTL page the flex row runs right-to-left and "Food" becomes "dooF". `direction: ltr` on `.hand-text` (already in `sketch.css`).
3. **HandText breaks mid-word.** Letters are separate boxes, so a wrapping flex row splits "week" into "We / ek". Words are grouped in `.hand-text__word` with `white-space: nowrap`; keep that structure if you edit the component.
4. **Drawn order flips in RTL.** A row drawn left-to-right in the sketch (Food · Cake · Special) comes out reversed in an RTL grid. Put `direction: ltr` on that grid only when the visual order is part of the design; leave content lists RTL.
5. **Sketch lines overshoot by a few px on purpose.** Keep `overflow-x: clip` on `html, body` so a band's line never causes sideways scroll.
6. **Inline-flex time ranges wrap.** "۸:۰۰ – ۲۳:۰۰" splits across lines in narrow columns. `white-space: nowrap` on the time, and a container query that stacks day above time when the column is under ~240px.
7. **Drawers and menus flash before CSS loads.** Hide closed overlays with an inline `style={{ visibility: "hidden" }}` as well as the class, so first paint can't show them.

## Layout patterns that held up

- **Header**: phone = small badge logo + cart + burger, side sheet menu. From ~900px = the sketch's band with links on both sides of a large badge that overlaps the band; shrink the badge on scroll. Link font `clamp(1.15rem, 1.7vw, 1.45rem)`, `white-space: nowrap`.
- **Hero**: phone = stacked, copy first. Tablet (600–899) = copy centred, scene capped at ~540px and centred (otherwise there's a huge empty band). Desktop = two columns.
- **Section heads with a "see all" link**: stack and centre on phones; row with space-between from 600px. Links get `white-space: nowrap` or the arrow ends up alone on a line.
- **Carousels**: card `flex: 0 0 min(240px, 74%)` on phones so the next card peeks; cap illustration width inside the card. Arrows only from 900px; touch scroll below.
- **Product grids**: phone = rows (96px picture beside text) so several items fit per screen; 2 / 3 / 4 columns at 600 / 900 / 1200 with stacked cards.
- **Three-step explainers**: list on phones, three columns from 600px.
- **Filter pills**: horizontal scroll with a mask fade on the scrolling end so people see there is more.
- **Footer**: phone = brand and contact full width, two short columns side by side; 3 columns at 600; 4 at 900. Credit line in a dashed-top bottom bar.
- **Forms**: inputs 16px font (no iOS zoom), 46px min height, errors under the field, focus the first invalid field on submit.

## Verifying in a throttled preview pane

Some embedded preview browsers stop repainting after the first frame. If a screenshot doesn't change after a click or scroll, check state through the DOM (`getBoundingClientRect`, class names) and get fresh screenshots by navigating, using `#anchor` URLs (give sections ids) to look at lower parts of the page. Don't read the frame rate there: a blank page measures the same.
