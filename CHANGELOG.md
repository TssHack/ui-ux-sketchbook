# Changelog

All notable changes to this skill are listed here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions follow [Semantic Versioning](https://semver.org/).

## [1.1.0] - 2026-10-23

### Added
- **Flutter build**: a dependency-free Dart package (`assets/flutter/`) with `SketchBox`, `SketchDrawing` and `HandText`, for Android, iOS, web and desktop. It is generated from the same illustration data as the web builds and tested with unit and widget tests.
- Flutter café example app with widget tests at 360, 768 and 1280 px, published as a live demo at `/flutter/`.
- `references/flutter.md`: setup, widget API, layout, RTL and performance for Flutter.
- `tools/gen_flutter_art.js`: generates the Dart illustration library from `art-library.js`. CI fails if the two drift apart.
- Persian README (`README.fa.md`).

### Changed
- `SKILL.md` chooses between three builds (plain JS, React, Flutter).
- README rewritten: install paths for every agent, a comparison of the builds, how the primitives work, quality bar and FAQ.
- CI runs on every branch and covers Flutter analyze, test and web build.

## [1.0.0] - 2026-10-22

First public release.

### Added
- `ui-ux-sketchbook` skill: turns a photo of a hand-drawn website sketch, or a request for a hand-drawn look, into a real responsive site.
- Two builds of the sketch primitives: plain JavaScript (`data-sketch`, `data-hand`, `data-art`) for single-file pages, and React components for Next.js projects.
- 15 ready illustrations, a single-page starter, and a script that inlines a page into one HTML file.
- Responsive checklist and drawing guide built from real bugs, plus an overflow audit script.
- Page-weight budget (about 1,200 SVG elements) with a lite render for small icons.
- Install paths for Claude Code (plugin marketplace), any agent through `npx skills`, and an installer script for Claude Code, Codex, Cursor and Hermes Agent.
- CI (skill validation, Claude Code plugin validator, type-check, installer tests on Linux and Windows), automated releases from tags, and a live demo on GitHub Pages.

### Fixed
- Hand-lettered headings now carry a hidden plain-text copy, so screen readers always read them.

[1.1.0]: https://github.com/TssHack/ui-ux-sketchbook/releases/tag/v1.1.0
[1.0.0]: https://github.com/TssHack/ui-ux-sketchbook/releases/tag/v1.0.0
