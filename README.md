# Mary Ann Ordinario — Author Portfolio

Portfolio site for [Mary Ann Ordinario](mailto:abcedcchildrensbooks@gmail.com),
award-winning Filipino children's book author of 75+ titles and founder of ABC
Educational Development Center Children's Books.

Static site built with **Astro 5 + Tailwind 4**. Two pages: the landing page
(`/`) and the full catalogue (`/books`), styled with a "storybook paper-craft"
visual language — scalloped paper edges, hand-drawn doodles from her own books,
and tilted covers.

## Quick start

```sh
cd site
npm install
npm run dev      # http://localhost:4321
npm run build    # validates book data, then builds to site/dist/
```

## Repository layout

| Path | What it is |
| --- | --- |
| `site/` | The Astro site — see [`site/README.md`](site/README.md) for the content workflow (adding books, validation, deploy) |
| `site/src/data/books.json` | The book catalogue — one JSON object per line, validated on every build |
| `docs/superpowers/specs/` | Approved design specs (site design, storybook UI treatment) |
| `docs/superpowers/plans/` | Implementation plans |
| `scripts/` | One-off asset preparation: cover copying/downscaling and portrait background removal (Apple Vision, macOS) |

Client-supplied source material (cover scans, Word documents) lives in
untracked folders at the repo root and is intentionally not committed.

## Deploying

Netlify: connect the repo with base directory `site/` — `site/netlify.toml`
handles the build. Before going live, set the production domain in
`site/astro.config.mjs` (`site:` field). Details and a Vercel alternative are
in [`site/README.md`](site/README.md).

## Editing content

All book data flows from `site/src/data/books.json`; counts shown on the site
are derived from it, not hardcoded. The full add-a-book checklist, the data
validator's guarantees, and open client questions (missing covers, unconfirmed
award placements) are documented in [`site/README.md`](site/README.md).
