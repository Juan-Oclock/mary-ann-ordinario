# Mary Ann Ordinario — Author Portfolio

Astro 5 + Tailwind 4 static site. Two pages: `/` and `/books`.

## Develop

    npm install
    npm run dev

## Validate book data

    npm run validate        # or: node scripts/validate-books.mjs

The validator checks structure only — unique/valid ids, a valid `category`, a
title, that every referenced cover file exists, and that no cover file in
`src/assets/covers/` is orphaned. It reports the catalogue counts it finds
rather than asserting fixed numbers, so adding a book or supplying a missing
cover does not break the build. `npm run build` runs it first.

## Add or edit a book
1. Drop the cover in `src/assets/covers/<slug>.jpg` (`.png` is fine too).
2. Add/edit its entry in `src/data/books.json` — one JSON object per line:
   `id`, `title`, `cover` (filename or `null`), `category`
   (`regular` | `award-winning` | `new-release`), `awards`, `translations`,
   optional `featured`, optional `note` for open client questions.
3. Run `npm run build` (the validator runs automatically).

Counts shown on the site are derived, not hardcoded: the stats band's "New
Releases in 2026" is computed from the `new-release` category, and the /books
filter tabs read `data-category` off each card. The other stats (75+ books,
20+ awards, 4+ languages) are client-supplied figures in
`src/components/StatsBand.astro`.

## Deploy
- **Netlify:** connect the repo, base directory `site/` — `netlify.toml` handles the rest.
- **Vercel:** import the repo, set root directory to `site/`, framework preset Astro.
- Before going live, set the real domain in `astro.config.mjs` (`site:` field).

## Pending client content (see `note` fields in books.json)
- Covers still missing: Ang Mabahong Prutas, Jesus Raises Lazarus From The Dead,
  Learning About The Philippines, Learning About The Philippines Famous Wonders.
- **The Crying Trees award placement.** The client's bio prose says "Grand Prize"
  while the itemised award list in the same document says "2nd Place — 2016 AFCC
  Singapore Samsung KidsTime Authors Award". The site currently states the award
  with no placement ("Samsung KidsTime Author's Award — AFCC Singapore (2016)"),
  which is true under either reading. Confirm before stating a placement.
- **I Love Tnalak — T'boli translation unconfirmed.** A T'boli edition was
  previously listed but is supported by neither source document; it had been
  inferred from the IBBY "Indigenous and Endangered Languages" honour, which
  describes the award, not a translation. Removed pending confirmation.
- Confirm: `kingdom.png` identity (mapped to "The Kingdom With No Stories"),
  and titles found in the cover folders but not the title list (Smelly Fruit,
  Chocolate Hills, Chatkak, Counting Book).
