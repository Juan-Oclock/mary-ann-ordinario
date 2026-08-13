# Storybook Throughout — Landing Page UI Elevation

**Date:** 2026-08-13
**Status:** Approved (Direction A of two options)

## Goal

The hero's paper-craft storybook language (sticker-cut portrait, scalloped cloud,
hand-drawn doodles from her books, dotted story-trail) appears once and then the
page falls back to generic template patterns. Carry that language through every
section so the whole page feels like one of Mary Ann's picture books.

## Design decisions (per section)

1. **Section seams** — replace hard color-band edges with scalloped SVG dividers
   (construction-paper edge), reusable component. Applied where cream/ivory/
   terracotta/ink sections meet.
2. **Stats band** — keep terracotta ground but scallop its top and bottom edges;
   each stat gets a small hand-drawn doodle icon (book, medal, globe, sparkle)
   and a hand-drawn wobbly underline/circle accent. Slight playful rotation.
3. **Fresh Off The Press** — hide the scrollbar, add prev/next arrow buttons,
   tilt covers alternately (±2°) like books laid on a table, add a "NEW"
   sticker badge, and a drawn shelf line under the row.
4. **About** — reframe the (clashing, purple) conference photo as a taped-down
   polaroid: ivory frame, tape corners, slight rotation. Doodle accents nearby.
5. **Award-Winning Books** — Tnalak highlight gets a drawn laurel/medal motif and
   a slightly rotated, sticker-edged cover. Grid cards swap the 🏅 emoji for a
   drawn medal SVG marker. Hover adds a small tilt with the lift.
6. **Full Library teaser** — covers get alternating slight tilts so the row reads
   as a hand-arranged stack, not a grid.
7. **News** — cards become a milestone timeline connected by the hero's dotted
   story-trail line with star markers at each entry.
8. **Footer** — scalloped top edge into the ink footer; star/moon doodles echoing
   the hero.
9. **Motion** — existing `.reveal` observer stays; add per-child stagger delays
   inside grids. All decoration respects `prefers-reduced-motion`.

## Constraints

- No palette or typography changes — cream/terracotta/ink and Playfair/Inter stay.
- All doodles are inline SVG grounded in her actual books (whale, pencil, stars,
  tnalak patterns), consistent with the hero's established set.
- Decorative SVGs are `aria-hidden`; no new focusable dead elements.
- No JS beyond the small arrow-scroll handler for the releases row.
- Works without JS (noscript reveal opt-out already handled in Layout).

## Out of scope

The /books catalogue page (separate iteration).
