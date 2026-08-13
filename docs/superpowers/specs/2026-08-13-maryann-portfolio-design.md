# Mary Ann Ordinario — Author Portfolio Site: Design Spec

**Date:** 2026-08-13
**Status:** Approved pending user review
**Client:** Mary Ann Ordinario — award-winning children's book author (75+ books), founder of ABC Educational Development Center, NBDB Governing Board member.

## 1. Goal

An author portfolio site whose primary purpose is **brand and credibility**: presenting Mary Ann as one of Mindanao's leading, internationally awarded children's authors. Audience: publishers, event organizers, schools, media, and readers who look her up.

Out of scope (explicit decisions): school promotion section, e-commerce/purchase links per book, CMS. The site mentions the school and NBDB role in the bio as credibility only.

## 2. Structure

Two pages, static:

- **`/` Home** — hero, stats band, new releases 2026, about, award-winning books, books teaser, news & press, contact/footer.
- **`/books` Books** — full catalog of all 62 titles with filters and search.

Sticky top nav: Home · About · Books · Awards · News · Contact (anchor links on home; Books routes to `/books`).

### Homepage sections (in order)

1. **Hero** — cream background; cut-out portrait (`Ms Mary Ann.png`) right; left: name in large serif, tagline "Award-winning author of over 75 children's books", short intro, CTAs "Explore Books" → `/books` and "Get in Touch" → contact anchor. Terracotta accents.
2. **Stats band** — full-width terracotta strip: `75+ Books · 20+ Awards · 5+ Languages · [30+ Years — verify with client, fallback: "Translated Worldwide"]`.
3. **New Releases 2026** — horizontal scroll row / subtle carousel of the 12 new covers.
4. **About** — two-column: second photo + condensed bio from `Mary Ann Ordinario.docx`; mentions founding ABC Educational Development Center and NBDB board membership.
5. **Award-Winning Books** — grid of 17 award-winning covers, each captioned with its award (e.g., *The Crying Trees — AFCC KidsTime Grand Prize, Singapore*). Highlight card on top for the 2026 UNESCO/IBBY selection of *I Love Tnalak* (launched at 40th IBBY World Congress, Ottawa).
6. **Books teaser** — one row of covers + "View All 62 Books" button → `/books`.
7. **News & Press** — 3–4 cards, built to grow: IBBY World Congress launch (Ottawa, Aug 2026), CMMA Special Citation for *The Brave Little Stump* (Nov 2025), Severino Reyes Honor List 2025 (*Kamatis Inis*, *A Whale in Prison*), Cardinal Sin Best Children's Book 2024.
8. **Contact / Footer** — email CTA (abcedcchildrensbooks@gmail.com), footer nav + credit.

### Books page

- Header: "Books" + one-liner ("62 stories celebrating Filipino culture, values, and the environment").
- **Filter tabs:** All · Award Winners · New Releases 2026, plus instant client-side text search.
- **Grid:** responsive, 2 cols mobile → 4–5 desktop. Card = optimized cover, title, award badge chip when applicable.
- **Detail view:** clicking a card opens a modal/expanding panel — full cover, awards, translations. No per-book pages (no synopses available yet); data model supports upgrading cards to detail pages later without restructuring.

## 3. Content Architecture

- Single Astro content collection: `src/content/books/` backed by `books.json`.
- Fields per book: `title`, `slug`, `cover`, `category` (`regular` | `award-winning` | `new-release`), `awards[]` ({name, year, org}), `translations[]`, `featured` (bool).
- Data sourced from `Book Titles.docx` (62 titles, incl. 12 new for 2026) and `Mary Ann Ordinario.docx` (award mapping per book).
- All home sections and the books page query this one collection — single source of truth. Adding a book later = one JSON entry + one image file.
- Covers copied to `src/assets/covers/`, renamed to clean slugs (e.g., `the-crying-trees.jpg`). Source folders remain untouched.

### Known content gaps (collect from client; site does not block on these)

- Covers to verify/obtain: *Jesus Raises Lazarus From The Dead*, *Learning About The Philippines Famous Wonders*; confirm `kingdom.png` = *The Kingdom With No Stories*; reconcile any title-to-file mismatches during data entry.
- "30+ Years" stat figure.
- Press photos for News cards (text-only cards until then).
- Book synopses (future enhancement: per-book detail pages).

## 4. Visual Design System

Direction: warm cream + terracotta, editorial and elegant (inspirations `Designs/2.png`, `Designs/5.png`). The colorful covers provide the playfulness; the frame stays sophisticated.

- **Palette:** warm cream base (≈`#F5F0E8`), ivory section alternates, terracotta accent (≈`#C0623B`) for stats band/buttons/accents, deep warm brown (≈`#3E2F25`) text. Final values tuned against actual covers and contrast-checked (WCAG AA).
- **Typography:** serif display for headings (Playfair Display or Cormorant Garamond), humanist sans for body (Inter or Source Sans 3). Letter-spaced small-caps section labels.
- **Details:** subtle neutral watercolor/organic corner motifs, rounded-top image masks for photos, thin rules, generous whitespace.
- **Motion:** gentle fade/rise on scroll (IntersectionObserver + CSS), hover lift on book cards. No animation libraries.

## 5. Technical Design

- **Stack:** Astro 5 + Tailwind CSS 4. Static output. Project scaffolded at `site/` inside this folder.
- **Client-side JS:** one small script island for books filtering/search + detail modal. Everything else zero-JS.
- **Images:** Astro `<Image>`/`getImage` → responsive WebP/AVIF at build time (source covers are 1–15MB; target ~50–150KB served).
- **SEO:** meta/OG tags (portrait as OG image), semantic headings, `sitemap.xml`, descriptive title/description per page.
- **Accessibility:** alt text per cover (from titles), keyboard-navigable tabs/search/modal, focus states, AA contrast.
- **Responsive:** mobile-first; nav collapses to hamburger.
- **Deploy:** Vercel or Netlify (choose at ship time), free tier.

## 6. Error Handling & Edge Cases

- Book entry with missing cover file → build-time warning, card omitted from grids (never a broken image).
- Search with no matches → friendly empty state.
- Long titles → clamped with full title in detail view/`title` attr.
- JS disabled → full catalog renders; filters/search degrade gracefully (all books shown).

## 7. Verification

- `astro build` passes clean.
- Manual pass: all 62 entries in `books.json` reconciled against both .docx lists; 17 award books carry correct award captions.
- Lighthouse: 90+ across Performance/Accessibility/Best Practices/SEO on both pages.
- Manual responsive check at 375px / 768px / 1440px.
