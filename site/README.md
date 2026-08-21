# Mary Ann Ordinario — Author Portfolio

Astro 5 + Tailwind 4 static site. Two pages: `/` and `/books`.

## Develop

    npm install
    npm run dev

## Validate book data

    npm run validate        # or: node scripts/validate-books.mjs

The validator checks structure only — unique/valid ids, a valid `category`, a
title, that every referenced cover file exists, that no cover file in
`src/assets/covers/` is orphaned, and that `blurb`/`shopeeUrl` — both optional —
are non-empty and point at shopee.ph when present. It reports the counts it finds
rather than asserting fixed numbers, so adding a book or supplying a missing
cover does not break the build. `npm run build` runs it first.

## Add or edit a book
1. Drop the cover in `src/assets/covers/<slug>.jpg` (`.png` is fine too).
2. Add/edit its entry in `src/data/books.json` — one JSON object per line:
   `id`, `title`, `cover` (filename or `null`), `category`
   (`regular` | `award-winning` | `new-release`), `awards`, `translations`,
   optional `featured`, optional `blurb` (the synopsis shown in the /books
   dialog), optional `shopeeUrl` (renders the "Buy on Shopee" button — omit it
   and the button is hidden rather than dead), optional `note` for open client
   questions.
3. Run `npm run build` (the validator runs automatically).

Counts shown on the site are derived, not hardcoded: the stats band's "New
Releases in 2026" is computed from the `new-release` category, and the /books
filter tabs read `data-category` off each card. The other stats (75+ books,
20+ awards, 4+ languages) are client-supplied figures in
`src/components/StatsBand.astro`.

## Blurbs

Synopses come from the client's Aug 2026 spreadsheet. Her copy carried a number
of typos — mostly words missing a doubled letter (`ful`, `wal`, `skils`, `wil`),
plus a few run-together words — so it was lightly copyedited on the way in.
Every substantive change is listed in [`../docs/blurb-edits.md`](../docs/blurb-edits.md)
for her to review; style choices were left alone. Two things still need her:

- **Chatkak The Talkative Frog** has no spreadsheet row, so no blurb and no link.
- **Learning About The Philippines: Counting Book** was given a blurb that
  describes *Famous Wonders* instead — the two rows are near-identical. It is
  published as supplied; confirm whether the Counting Book needs its own.

## Deploy
- **Netlify:** connect the repo, base directory `site/` — `netlify.toml` handles the rest.
- **Vercel:** import the repo, set root directory to `site/`, framework preset Astro.
- Before going live, set the real domain in `astro.config.mjs` (`site:` field).

## Pending client content (see `note` fields in books.json)
- No covers pending — every book in books.json now has one. The last gap, Jesus
  Raises Lazarus From The Dead, was filled from the Aug 2026 "with new updates"
  delivery.
- Resolved Aug 2026 via the client's "ABC Books_with updates" delivery and
  follow-up replies: Ang Mabahong Prutas is the Filipino title of The Smelly
  Fruit (single entry now); "Learning About The Philippines" is only two books
  (Counting Book and Famous Wonders — the standalone third entry was removed);
  the low-res Famous Wonders cover is final per the client; contact email is
  abcedc@yahoo.com; languages count is 10; "Bakit Kumakain ng Bato si Loro"
  (by Anselmo S. Osores Jr.) is excluded per the client.
- Resolved Aug 2026 via the client's "with new updates" delivery (`Updates.docx`,
  Aug 17): "Somebody Is Eating The Chocolate Hills" is deleted outright — she
  asked for its removal and it appears in neither Book Titles.docx nor the
  66-book spreadsheet, so its cover was dropped too; "EL and EY: The Adventurous
  Shells" is award-winning (2nd Place, AFCC Samsung KidsTime Author's Award,
  Singapore 2016); the ten translation languages are now named in full in
  About.astro; Facebook, Instagram, and Shopee links are in the footer.
  "Okey Lang Maging Kalbo" (by Eric Ruiz Roxas) is excluded per the client.
- Three titles added from that same delivery, filed as `new-release` because the
  spreadsheet lists them below its "New Released Books" separator: A Mother's
  Love in Every Hop, Amihan's Colorful Coconut Leaf Slippers, Memories of Agila.
  Their covers arrived as Facebook exports with opaque numeric filenames — the
  mapping from each hash to its title is recorded in `scripts/copy-covers.sh`.
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
  Chatkak, Counting Book).
