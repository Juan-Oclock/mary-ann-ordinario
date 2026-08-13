# Mary Ann Ordinario Portfolio Site — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a two-page static author-portfolio site (Home + Books) for children's book author Mary Ann Ordinario, per the approved spec at `docs/superpowers/specs/2026-08-13-maryann-portfolio-design.md`.

**Architecture:** Astro 5 static site scaffolded in `site/`. All book data lives in one JSON-backed content collection; every section (new releases, award winners, teaser, full catalog) queries it. Covers are imported through Astro's asset pipeline for build-time WebP optimization. One client-side script island powers the Books page filter/search/modal; a tiny IntersectionObserver script powers scroll reveals.

**Tech Stack:** Astro 5, Tailwind CSS 4 (`@tailwindcss/vite`), `@astrojs/sitemap`, `@fontsource-variable/playfair-display`, `@fontsource-variable/inter`. Node 20+. No other runtime dependencies.

## Global Constraints

- Palette tokens: cream `#F5F0E8`, ivory `#FBF8F3`, sand `#EAE2D3`, terracotta `#C0623B`, terracotta-dark `#9E4E2E`, ink `#3E2F25`, ink-soft `#6B5B4E`.
- Fonts: Playfair Display (headings), Inter (body). Self-hosted via Fontsource — no external font requests.
- Contact email everywhere: `abcedcchildrensbooks@gmail.com`.
- Site URL placeholder: `https://maryannordinario.com` in `astro.config.mjs` — update at deploy time.
- The project lives in `site/` inside the repo root. Source asset folders (`Book Covers/`, etc.) are never modified — only copied from.
- All commands run from `site/` unless a step says otherwise.
- No animation libraries. No cookie banners, no analytics (not in spec).
- Copy rules: author name is "Mary Ann Ordinario"; tagline "Award-winning author of over 75 children's books"; publisher mention "ABC Educational Development Center Children's Books".
- Every page must build statically (`astro build` with zero errors) before each commit.

## Data Facts (derived from source docs — used by Task 3)

- 67 catalog entries total: 51 from `Book Titles.docx` main list, 12 from its "New Released Books 2026" list, 4 extras found in cover folders (*The Smelly Fruit*, *Somebody Is Eating the Chocolate Hills*, *Chatkak the Talkative Frog*, *Learning About The Philippines Counting Book*).
- 17 entries are `award-winning` (matches the 17 files in `Award Winning Books- Book Covers/`).
- 13 entries are `new-release` (12 docx titles + *Counting Book*).
- 63 cover files exist; 4 entries have `cover: null`: *Ang Mabahong Prutas*, *Jesus Raises Lazarus From The Dead*, *Learning About The Philippines*, *Learning About The Philippines Famous Wonders*.
- Client-confirmation flags live in each entry's `note` field (kingdom.png identity, Crying Trees "Grand Prize" vs "2nd Place" discrepancy, titles missing from docx list).

---

### Task 1: Scaffold Astro project with Tailwind, fonts, and sitemap

**Files:**
- Create: `site/` (via scaffolder), `site/astro.config.mjs`, `site/src/styles/global.css`
- Test: build passes

**Interfaces:**
- Produces: working `npm run dev` / `npm run build`; Tailwind theme tokens (`bg-cream`, `text-ink`, `text-terracotta`, `font-display`, `font-body`, etc.) and `.section-label` / `.reveal` utility classes used by every later task.

- [ ] **Step 1: Scaffold project** (run from repo root)

```bash
npm create astro@latest site -- --template minimal --no-git --install --typescript strict
cd site
npx astro add tailwind sitemap --yes
npm install @fontsource-variable/playfair-display @fontsource-variable/inter
```

- [ ] **Step 2: Configure `site/astro.config.mjs`**

```js
// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  // TODO-AT-DEPLOY: replace with the final domain before going live
  site: 'https://maryannordinario.com',
  integrations: [sitemap()],
  vite: { plugins: [tailwindcss()] },
});
```

(If `astro add tailwind` generated a different css entry, keep its import path but replace file contents in the next step.)

- [ ] **Step 3: Write `site/src/styles/global.css`**

```css
@import 'tailwindcss';

@theme {
  --color-cream: #f5f0e8;
  --color-ivory: #fbf8f3;
  --color-sand: #eae2d3;
  --color-terracotta: #c0623b;
  --color-terracotta-dark: #9e4e2e;
  --color-ink: #3e2f25;
  --color-ink-soft: #6b5b4e;
  --font-display: 'Playfair Display Variable', Georgia, serif;
  --font-body: 'Inter Variable', ui-sans-serif, system-ui, sans-serif;
}

html {
  scroll-behavior: smooth;
}

body {
  background-color: var(--color-cream);
  color: var(--color-ink);
  font-family: var(--font-body);
  -webkit-font-smoothing: antialiased;
}

.section-label {
  font-family: var(--font-body);
  font-size: 0.75rem;
  font-weight: 600;
  letter-spacing: 0.25em;
  text-transform: uppercase;
  color: var(--color-terracotta);
}

.reveal {
  opacity: 0;
  transform: translateY(16px);
  transition: opacity 0.6s ease, transform 0.6s ease;
}
.reveal.revealed {
  opacity: 1;
  transform: none;
}
@media (prefers-reduced-motion: reduce) {
  html { scroll-behavior: auto; }
  .reveal { opacity: 1; transform: none; transition: none; }
}
```

- [ ] **Step 4: Verify build**

Run: `npm run build`
Expected: `Complete!` with zero errors.

- [ ] **Step 5: Commit** (from repo root)

```bash
git add site
git commit -m "feat: scaffold Astro 5 + Tailwind 4 project with design tokens"
```

---

### Task 2: Copy and rename all image assets

**Files:**
- Create: `scripts/copy-covers.sh` (repo root), `site/src/assets/covers/*` (63 files), `site/src/assets/photos/*` (2 files), `site/public/images/mary-ann-portrait.png`

**Interfaces:**
- Produces: slugged cover filenames exactly matching the `cover` fields in Task 3's `books.json`; `../assets/photos/mary-ann-portrait.png` and `../assets/photos/mary-ann-nbdb.png` for Hero/About; `/images/mary-ann-portrait.png` public path for OG tags.

- [ ] **Step 1: Write `scripts/copy-covers.sh`** (repo root; note `Daniel in  the Lion_s Den.png` has a double space — copy exactly)

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
AW="Award Winning Books- Book Covers"
BK="Book Covers"
NW="Newly Released Books Covers"
DEST="site/src/assets/covers"
mkdir -p "$DEST" "site/src/assets/photos" "site/public/images"

# Award-winning (17)
cp "$AW/A Whale in Prison (3).png"                          "$DEST/a-whale-in-prison.png"
cp "$AW/BAREFOOT BULAYAN (COVER).jpg"                       "$DEST/barefoot-bulayan.jpg"
cp "$AW/BULUL (COVER).jpg"                                  "$DEST/bulul.jpg"
cp "$AW/DEAREST PAPA (COVER).jpg"                           "$DEST/dearest-papa.jpg"
cp "$AW/DIOLA - HEROINE IF PHILIPPINE EAGLE (COVER).jpg"    "$DEST/diola-heroine-of-philippine-eagles.jpg"
cp "$AW/I LOVE TNALAK (COVER).jpg"                          "$DEST/i-love-tnalak.jpg"
cp "$AW/MALONG THE MAGIC CLOTH (COVER).jpg"                 "$DEST/malong-the-magic-cloth.jpg"
cp "$AW/PENCIL WHO WOULD NOT WRITE (COVER).jpg"             "$DEST/the-pencil-who-would-not-write.jpg"
cp "$AW/Si Kamatis Inis (1).png"                            "$DEST/si-kamatis-inis.png"
cp "$AW/SOMEBODY IS EATING CHOCOLATE HILLS (COVER).jpg"     "$DEST/somebody-is-eating-the-chocolate-hills.jpg"
cp "$AW/The Brave Little Stump (1).png"                     "$DEST/the-brave-little-stump.png"
cp "$AW/THE CRYING TREES (COVER).jpg"                       "$DEST/the-crying-trees.jpg"
cp "$AW/THE LITTLE SEED (COVER).jpg"                        "$DEST/the-little-seed.jpg"
cp "$AW/THE OPPOSITE JARS (COVER).jpg"                      "$DEST/the-opposite-jars.jpg"
cp "$AW/THE SMELLY FRUIT (COVER).jpg"                       "$DEST/the-smelly-fruit.jpg"
cp "$AW/WAR MAKES ME SAD (COVER).jpg"                       "$DEST/war-makes-me-sad.jpg"
cp "$AW/WHY IS A PIG_S NOSE FLAT (COVER).jpg"               "$DEST/why-is-a-pigs-nose-flat.jpg"

# General catalog (34)
cp "$BK/A BASKET IN WAR (COVER).jpg"                        "$DEST/a-basket-in-war.jpg"
cp "$BK/A great miracle.png"                                "$DEST/a-great-miracle.png"
cp "$BK/Ako ay Pilipino.jpg"                                "$DEST/ako-ay-pilipino.jpg"
cp "$BK/Bakit ang Manok ay Walang Ngipin.jpeg"              "$DEST/bakit-walang-ngipin-ang-mga-manok.jpeg"
cp "$BK/BAKIT MALINIS ANG NGIPIN NG BUWAYA (1).png"         "$DEST/bakit-malinis-ang-ngipin-ng-buwaya.png"
cp "$BK/CHATKAK THE TALKATIVE FROG(COVER).jpg"              "$DEST/chatkak-the-talkative-frog.jpg"
cp "$BK/Cindys 365.png"                                     "$DEST/cindys-365-bags-and-more.png"
cp "$BK/Crossing the Red Sea.png"                           "$DEST/crossing-the-red-sea.png"
cp "$BK/Daniel in  the Lion_s Den.png"                      "$DEST/daniel-in-the-lions-den.png"
cp "$BK/Dessert Town is melting.jpg"                        "$DEST/dessert-town-is-melting.jpg"
cp "$BK/Don_t Take My Colors Away.jpg"                      "$DEST/dont-take-my-colors-away.jpg"
cp "$BK/EL AND EY (COVER).jpg"                              "$DEST/el-and-ey.jpg"
cp "$BK/Fluffy_s Misadventure Week It_s All Gone.jpeg"      "$DEST/fluffys-misadventure-week.jpeg"
cp "$BK/FLYING TRASH (COVER).jpg"                           "$DEST/flying-trash.jpg"
cp "$BK/Grandma_s Baked Goodies.jpeg"                       "$DEST/grandmas-baked-goodies.jpeg"
cp "$BK/HOME IS WHERE THE HEART LIVES (COVER).jpg"          "$DEST/home-is-where-the-heart-lives.jpg"
cp "$BK/Jesus Feeds 5000 People.png"                        "$DEST/jesus-feeds-5000-people.png"
cp "$BK/Jesus Heals The Blind (1).png"                      "$DEST/jesus-heals-the-blind.png"
cp "$BK/Jesus Walks on Water (1).png"                       "$DEST/jesus-walks-on-water.png"
cp "$BK/kingdom.png"                                        "$DEST/the-kingdom-with-no-stories.png"
cp "$BK/May Aswang sa School.jpg"                           "$DEST/may-aswang-sa-iskul.jpg"
cp "$BK/MEANINGFUL VALUES FOR GOD_S CHILDREN (COVER).jpg"   "$DEST/meaningful-values-for-gods-children.jpg"
cp "$BK/Mom_s Best Pladough_Dinasaurs_300dpi.png"           "$DEST/moms-best-playdough-dinosaurs.png"
cp "$BK/Mom_s Best Playdough Activities-Philippine National Symbols.png" "$DEST/moms-best-playdough-philippine-national-symbols.png"
cp "$BK/MOM_S BEST PLAYDOUGH BREAD & PASTRIES (COVER).jpg"  "$DEST/moms-best-playdough-bread-pastries.jpg"
cp "$BK/Mom_s Best Playdough Community Helpers.jpg"         "$DEST/moms-best-playdough-community-helpers.jpg"
cp "$BK/MOM_S BEST PLAYDOUGH FARM ANIMALS (COVER).jpg"      "$DEST/moms-best-playdough-farm-animals.jpg"
cp "$BK/MOM_S BEST PLAYDOUGH WILD ANIMALS (COVER).jpg"      "$DEST/moms-best-playdough-wild-animals.jpg"
cp "$BK/MY MUSLIM FRIEND (COVER OLD).jpg"                   "$DEST/my-muslim-friend.jpg"
cp "$BK/My Pink Spot.jpg"                                   "$DEST/my-pink-spot.jpg"
cp "$BK/THE HAIRY FRUIT (COVER).jpg"                        "$DEST/the-hairy-fruit.jpg"
cp "$BK/Tuna Festival.jpeg"                                 "$DEST/tuna-festival.jpeg"
cp "$BK/Two Hats, One Heart_300dpi.png"                     "$DEST/two-hats-one-heart.png"
cp "$BK/Where Shall We Build Our Nest (1).png"              "$DEST/where-shall-we-build-our-nest.png"

# New releases 2026 (12)
cp "$NW/A Crumpled Piece of Paper.png"                      "$DEST/a-crumpled-piece-of-paper.png"
cp "$NW/BALLOONS FLY ANIMALS CRY.jpg"                       "$DEST/balloons-fly-animals-cry.jpg"
cp "$NW/BE YOURSELF, BE BRAVE.jpg"                          "$DEST/be-yourself-be-brave.jpg"
cp "$NW/DON_T TOUCH THE STARFISH (1).jpg"                   "$DEST/dont-touch-the-starfish.jpg"
cp "$NW/Learning About The Philippines Counting Book.jpeg"  "$DEST/learning-about-the-philippines-counting-book.jpeg"
cp "$NW/MGA KILALANG YAMAN NG PILIPINAS.jpg"                "$DEST/mga-kilalang-yaman-ng-pilipinas.jpg"
cp "$NW/MOTHER TURTLE_S NEST.jpg"                           "$DEST/mother-turtles-nest.jpg"
cp "$NW/My Father, The Honest Mayor (3).png"                "$DEST/my-father-the-honest-mayor.png"
cp "$NW/PURPLE HANDS LOVING HANDS.jpg"                      "$DEST/purple-hands-loving-hands.jpg"
cp "$NW/Si Karla feeling Prinsesa (4).png"                  "$DEST/si-karla-feeling-prinsesa.png"
cp "$NW/The Flood Took Lyka Away.jpg"                       "$DEST/the-flood-took-lyka-away.jpg"
cp "$NW/THE LOG OF HOPE.jpg"                                "$DEST/the-log-of-hope.jpg"

# Author photos
cp "$AW/Mary Ann Ordinario/Ms Mary Ann.png"                 "site/src/assets/photos/mary-ann-portrait.png"
cp "$AW/Mary Ann Ordinario/m.png"                           "site/src/assets/photos/mary-ann-nbdb.png"
cp "$AW/Mary Ann Ordinario/Ms Mary Ann.png"                 "site/public/images/mary-ann-portrait.png"

echo "Copied $(ls "$DEST" | wc -l | tr -d ' ') covers"
```

- [ ] **Step 2: Run it and verify the count**

Run (repo root): `bash scripts/copy-covers.sh`
Expected: `Copied 63 covers` and no `cp` errors. Then `ls site/src/assets/photos | wc -l` → `2`.

- [ ] **Step 3: Commit**

```bash
git add scripts site/src/assets site/public/images
git commit -m "feat: copy and slug-rename all 63 covers and author photos"
```

---

### Task 3: Book data — validation script first, then `books.json` + content collection

**Files:**
- Create: `site/scripts/validate-books.mjs`, `site/src/data/books.json`, `site/src/content.config.ts`, `site/src/lib/covers.ts`

**Interfaces:**
- Produces: content collection `books` — entries with `id` (slug), `data: { title, cover, category, awards[], translations[], featured, note? }`; helper `getCover(file: string | null): ImageMetadata | null` from `src/lib/covers.ts`. Later tasks call `getCollection('books')` and `getCover(book.data.cover)`.

- [ ] **Step 1: Write the failing validation script `site/scripts/validate-books.mjs`**

```js
import { readFileSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const books = JSON.parse(readFileSync(join(root, 'src/data/books.json'), 'utf8'));
const coverFiles = new Set(readdirSync(join(root, 'src/assets/covers')));
const errors = [];

const ids = new Set();
for (const b of books) {
  if (!/^[a-z0-9-]+$/.test(b.id)) errors.push(`bad id: ${b.id}`);
  if (ids.has(b.id)) errors.push(`duplicate id: ${b.id}`);
  ids.add(b.id);
  if (!b.title) errors.push(`missing title: ${b.id}`);
  if (!['regular', 'award-winning', 'new-release'].includes(b.category))
    errors.push(`bad category on ${b.id}: ${b.category}`);
  if (b.cover !== null && !coverFiles.has(b.cover))
    errors.push(`cover file not found for ${b.id}: ${b.cover}`);
}
const referenced = new Set(books.map((b) => b.cover).filter(Boolean));
for (const f of coverFiles) if (!referenced.has(f)) errors.push(`orphan cover file: ${f}`);

const count = (c) => books.filter((b) => b.category === c).length;
if (books.length !== 67) errors.push(`expected 67 books, got ${books.length}`);
if (count('award-winning') !== 17) errors.push(`expected 17 award-winning, got ${count('award-winning')}`);
if (count('new-release') !== 13) errors.push(`expected 13 new-release, got ${count('new-release')}`);
if (books.filter((b) => b.cover === null).length !== 4)
  errors.push(`expected 4 books without covers`);

if (errors.length) {
  console.error(errors.join('\n'));
  process.exit(1);
}
console.log(`OK: ${books.length} books validated`);
```

- [ ] **Step 2: Run to verify it fails**

Run: `node scripts/validate-books.mjs`
Expected: FAIL — `ENOENT ... books.json`

- [ ] **Step 3: Write `site/src/data/books.json`** — all 67 entries exactly as below

```json
[
  {"id":"the-crying-trees","title":"The Crying Trees","cover":"the-crying-trees.jpg","category":"award-winning","awards":["Samsung KidsTime Author's Award Grand Prize — AFCC Singapore (2016)"],"translations":[],"featured":true,"note":"Bio says Grand Prize; awards list says 2nd Place — confirm with client"},
  {"id":"malong-the-magic-cloth","title":"Malong The Magic Cloth","cover":"malong-the-magic-cloth.jpg","category":"award-winning","awards":["Best ASEAN Children's Book Illustration","Best in Fiction — International Children's Content Rights Fair, Chiang Mai, Thailand"],"translations":["Malay","Thai","Chinese"],"featured":true},
  {"id":"the-pencil-who-would-not-write","title":"The Pencil Who Would Not Write","cover":"the-pencil-who-would-not-write.jpg","category":"award-winning","awards":["First Prize — International Indie Children's Book Cover Award, Los Angeles (2021)"],"translations":[],"featured":true},
  {"id":"a-whale-in-prison","title":"A Whale In Prison","cover":"a-whale-in-prison.png","category":"award-winning","awards":["Best Children's Book — 18th Cardinal Sin Catholic Book Awards (2024)","Severino Reyes Medal Best Picture Book Honor List (2025)"],"translations":[],"featured":true},
  {"id":"i-love-tnalak","title":"I Love Tnalak","cover":"i-love-tnalak.jpg","category":"award-winning","awards":["UNESCO–IBBY Remarkable Book for Young Readers in Indigenous and Endangered Languages (2026)","Launched at the 40th IBBY World Congress, Ottawa, Canada"],"translations":["T'boli"],"featured":true},
  {"id":"bulul","title":"Bulul","cover":"bulul.jpg","category":"award-winning","awards":["Best Reads — 7th National Children's Book Awards (2020–2021)"],"translations":[]},
  {"id":"the-brave-little-stump","title":"The Brave Little Stump","cover":"the-brave-little-stump.png","category":"award-winning","awards":["Special Citation — Catholic Mass Media Awards (2025)"],"translations":[]},
  {"id":"si-kamatis-inis","title":"Si Kamatis Inis","cover":"si-kamatis-inis.png","category":"award-winning","awards":["Severino Reyes Medal Best Picture Book Honor List (2025)"],"translations":[]},
  {"id":"barefoot-bulayan","title":"Barefoot Bulayan","cover":"barefoot-bulayan.jpg","category":"award-winning","awards":["CNN Children's Books Best Reads","Shortlisted Best Reads — National Children's Book Awards (2021)"],"translations":[]},
  {"id":"dearest-papa","title":"Dearest Papa","cover":"dearest-papa.jpg","category":"award-winning","awards":["Best Children's Short Story — Catholic Mass Media Awards (2018)","Shortlisted Best Reads — National Children's Book Awards (2021)"],"translations":["Malay","Chinese"]},
  {"id":"war-makes-me-sad","title":"War Makes Me Sad!","cover":"war-makes-me-sad.jpg","category":"award-winning","awards":["Best Short Story for Children — Catholic Mass Media Awards (2003)","2nd Place — AFCC Samsung KidsTime Author's Award, Singapore (2016)"],"translations":["Bahasa Indonesia"]},
  {"id":"the-opposite-jars","title":"The Opposite Jars: Posi and Nega","cover":"the-opposite-jars.jpg","category":"award-winning","awards":["Best Short Story — Catholic Mass Media Awards (2017)"],"translations":[]},
  {"id":"the-smelly-fruit","title":"The Smelly Fruit","cover":"the-smelly-fruit.jpg","category":"award-winning","awards":["2nd Place — AFCC Samsung KidsTime Author's Award, Singapore (2016)"],"translations":[],"note":"Not in Book Titles.docx list (English ed. of Ang Mabahong Prutas?) — confirm with client"},
  {"id":"why-is-a-pigs-nose-flat","title":"Why Is A Pig's Nose Flat?","cover":"why-is-a-pigs-nose-flat.jpg","category":"award-winning","awards":["2nd Place — AFCC Samsung KidsTime Author's Award, Singapore (2016)"],"translations":[]},
  {"id":"somebody-is-eating-the-chocolate-hills","title":"Somebody Is Eating The Chocolate Hills","cover":"somebody-is-eating-the-chocolate-hills.jpg","category":"award-winning","awards":["Finalist — RCBC 8th Kuwentong Kalikasan: Katha ng Kabataan"],"translations":[],"note":"Not in Book Titles.docx list — confirm with client"},
  {"id":"the-little-seed","title":"The Little Seed","cover":"the-little-seed.jpg","category":"award-winning","awards":["2nd Place — AFCC Samsung KidsTime Author's Award, Singapore (2016)"],"translations":[]},
  {"id":"diola-heroine-of-philippine-eagles","title":"Diola: Heroine of Philippine Eagles","cover":"diola-heroine-of-philippine-eagles.jpg","category":"award-winning","awards":["2nd Place — AFCC Samsung KidsTime Author's Award, Singapore (2016)"],"translations":[]},
  {"id":"a-crumpled-piece-of-paper","title":"A Crumpled Piece of Paper","cover":"a-crumpled-piece-of-paper.png","category":"new-release","awards":[],"translations":[]},
  {"id":"balloons-fly-animals-cry","title":"Balloons Fly, Animals Cry","cover":"balloons-fly-animals-cry.jpg","category":"new-release","awards":[],"translations":[]},
  {"id":"be-yourself-be-brave","title":"Be Yourself, Be Brave","cover":"be-yourself-be-brave.jpg","category":"new-release","awards":[],"translations":[]},
  {"id":"dont-touch-the-starfish","title":"Don't Touch The Starfish","cover":"dont-touch-the-starfish.jpg","category":"new-release","awards":[],"translations":[]},
  {"id":"learning-about-the-philippines-counting-book","title":"Learning About The Philippines: Counting Book","cover":"learning-about-the-philippines-counting-book.jpeg","category":"new-release","awards":[],"translations":[],"note":"Cover exists but title not in docx lists — confirm with client"},
  {"id":"learning-about-the-philippines-famous-wonders","title":"Learning About The Philippines: Famous Wonders","cover":null,"category":"new-release","awards":[],"translations":[],"note":"Cover image needed from client"},
  {"id":"mga-kilalang-yaman-ng-pilipinas","title":"Mga Kilalang Yaman ng Pilipinas","cover":"mga-kilalang-yaman-ng-pilipinas.jpg","category":"new-release","awards":[],"translations":[]},
  {"id":"mother-turtles-nest","title":"Mother Turtle's Nest","cover":"mother-turtles-nest.jpg","category":"new-release","awards":[],"translations":[]},
  {"id":"my-father-the-honest-mayor","title":"My Father, The Honest Mayor","cover":"my-father-the-honest-mayor.png","category":"new-release","awards":[],"translations":[]},
  {"id":"purple-hands-loving-hands","title":"Purple Hands, Loving Hands","cover":"purple-hands-loving-hands.jpg","category":"new-release","awards":[],"translations":[]},
  {"id":"si-karla-feeling-prinsesa","title":"Si Karla Feeling Prinsesa","cover":"si-karla-feeling-prinsesa.png","category":"new-release","awards":[],"translations":[]},
  {"id":"the-flood-took-lyka-away","title":"The Flood Took Lyka Away","cover":"the-flood-took-lyka-away.jpg","category":"new-release","awards":[],"translations":[]},
  {"id":"the-log-of-hope","title":"The Log of Hope","cover":"the-log-of-hope.jpg","category":"new-release","awards":[],"translations":[]},
  {"id":"a-basket-in-war","title":"A Basket In War","cover":"a-basket-in-war.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"a-great-miracle","title":"A Great Miracle","cover":"a-great-miracle.png","category":"regular","awards":[],"translations":[]},
  {"id":"ako-ay-pilipino","title":"Ako Ay Pilipino: Mahahalagang Kaugaliang Pilipino","cover":"ako-ay-pilipino.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"ang-mabahong-prutas","title":"Ang Mabahong Prutas","cover":null,"category":"regular","awards":[],"translations":[],"note":"Cover image needed from client (Filipino ed. of The Smelly Fruit?)"},
  {"id":"bakit-malinis-ang-ngipin-ng-buwaya","title":"Bakit Malinis ang Ngipin ng Buwaya?","cover":"bakit-malinis-ang-ngipin-ng-buwaya.png","category":"regular","awards":[],"translations":[]},
  {"id":"bakit-walang-ngipin-ang-mga-manok","title":"Bakit Walang Ngipin Ang Mga Manok?","cover":"bakit-walang-ngipin-ang-mga-manok.jpeg","category":"regular","awards":[],"translations":[]},
  {"id":"chatkak-the-talkative-frog","title":"Chatkak The Talkative Frog","cover":"chatkak-the-talkative-frog.jpg","category":"regular","awards":[],"translations":[],"note":"Not in Book Titles.docx list — confirm with client"},
  {"id":"cindys-365-bags-and-more","title":"Cindy's 365 Bags and More","cover":"cindys-365-bags-and-more.png","category":"regular","awards":[],"translations":[]},
  {"id":"crossing-the-red-sea","title":"Crossing The Red Sea","cover":"crossing-the-red-sea.png","category":"regular","awards":[],"translations":[]},
  {"id":"daniel-in-the-lions-den","title":"Daniel In The Lion's Den","cover":"daniel-in-the-lions-den.png","category":"regular","awards":[],"translations":[]},
  {"id":"dessert-town-is-melting","title":"Dessert Town Is Melting!","cover":"dessert-town-is-melting.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"dont-take-my-colors-away","title":"Don't Take My Colors Away!","cover":"dont-take-my-colors-away.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"el-and-ey","title":"EL and EY: The Adventurous Shells","cover":"el-and-ey.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"fluffys-misadventure-week","title":"Fluffy's Misadventure Week! It's All Gone","cover":"fluffys-misadventure-week.jpeg","category":"regular","awards":[],"translations":[]},
  {"id":"flying-trash","title":"Flying Trash","cover":"flying-trash.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"grandmas-baked-goodies","title":"Grandma's Baked Goodies","cover":"grandmas-baked-goodies.jpeg","category":"regular","awards":[],"translations":[]},
  {"id":"home-is-where-the-heart-lives","title":"Home Is Where The Heart Lives","cover":"home-is-where-the-heart-lives.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"jesus-feeds-5000-people","title":"Jesus Feeds 5000 People","cover":"jesus-feeds-5000-people.png","category":"regular","awards":[],"translations":[]},
  {"id":"jesus-heals-the-blind","title":"Jesus Heals The Blind","cover":"jesus-heals-the-blind.png","category":"regular","awards":[],"translations":[]},
  {"id":"jesus-raises-lazarus-from-the-dead","title":"Jesus Raises Lazarus From The Dead","cover":null,"category":"regular","awards":[],"translations":[],"note":"Cover image needed from client"},
  {"id":"jesus-walks-on-water","title":"Jesus Walks On Water","cover":"jesus-walks-on-water.png","category":"regular","awards":[],"translations":[]},
  {"id":"learning-about-the-philippines","title":"Learning About The Philippines","cover":null,"category":"regular","awards":[],"translations":[],"note":"Cover image needed from client"},
  {"id":"may-aswang-sa-iskul","title":"May Aswang Sa Iskul?","cover":"may-aswang-sa-iskul.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"meaningful-values-for-gods-children","title":"Meaningful Values For God's Children","cover":"meaningful-values-for-gods-children.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"moms-best-playdough-bread-pastries","title":"Mom's Best Playdough Activities: Bread & Pastries","cover":"moms-best-playdough-bread-pastries.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"moms-best-playdough-community-helpers","title":"Mom's Best Playdough Activities: Community Helpers","cover":"moms-best-playdough-community-helpers.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"moms-best-playdough-dinosaurs","title":"Mom's Best Playdough Activities: Dinosaurs","cover":"moms-best-playdough-dinosaurs.png","category":"regular","awards":[],"translations":[]},
  {"id":"moms-best-playdough-farm-animals","title":"Mom's Best Playdough Activities: Farm Animals","cover":"moms-best-playdough-farm-animals.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"moms-best-playdough-philippine-national-symbols","title":"Mom's Best Playdough Activities: Philippine National Symbols","cover":"moms-best-playdough-philippine-national-symbols.png","category":"regular","awards":[],"translations":[]},
  {"id":"moms-best-playdough-wild-animals","title":"Mom's Best Playdough Activities: Wild Animals","cover":"moms-best-playdough-wild-animals.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"my-muslim-friend","title":"My Muslim Friend","cover":"my-muslim-friend.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"my-pink-spot","title":"My Pink Spot","cover":"my-pink-spot.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"the-hairy-fruit","title":"The Hairy Fruit","cover":"the-hairy-fruit.jpg","category":"regular","awards":[],"translations":[]},
  {"id":"the-kingdom-with-no-stories","title":"The Kingdom With No Stories","cover":"the-kingdom-with-no-stories.png","category":"regular","awards":[],"translations":[],"note":"Cover mapped from kingdom.png — verify with client"},
  {"id":"tuna-festival","title":"Tuna Festival","cover":"tuna-festival.jpeg","category":"regular","awards":[],"translations":[]},
  {"id":"two-hats-one-heart","title":"Two Hats, One Heart","cover":"two-hats-one-heart.png","category":"regular","awards":[],"translations":[]},
  {"id":"where-shall-we-build-our-nest","title":"Where Shall We Build Our Nest?","cover":"where-shall-we-build-our-nest.png","category":"regular","awards":[],"translations":[]}
]
```

- [ ] **Step 4: Run validation to verify it passes**

Run: `node scripts/validate-books.mjs`
Expected: `OK: 67 books validated`

- [ ] **Step 5: Write `site/src/content.config.ts`**

```ts
import { defineCollection, z } from 'astro:content';
import { file } from 'astro/loaders';

const books = defineCollection({
  loader: file('src/data/books.json'),
  schema: z.object({
    title: z.string(),
    cover: z.string().nullable(),
    category: z.enum(['regular', 'award-winning', 'new-release']),
    awards: z.array(z.string()).default([]),
    translations: z.array(z.string()).default([]),
    featured: z.boolean().default(false),
    note: z.string().optional(),
  }),
});

export const collections = { books };
```

- [ ] **Step 6: Write `site/src/lib/covers.ts`**

```ts
import type { ImageMetadata } from 'astro';

const covers = import.meta.glob<{ default: ImageMetadata }>(
  '../assets/covers/*.{jpg,jpeg,png}',
  { eager: true }
);

/** Resolve a cover filename from books.json to its imported image, or null. */
export function getCover(file: string | null): ImageMetadata | null {
  if (!file) return null;
  const hit = Object.entries(covers).find(([path]) => path.endsWith(`/${file}`));
  return hit ? hit[1].default : null;
}
```

- [ ] **Step 7: Verify the collection loads at build**

Run: `npm run build`
Expected: build completes; no schema errors.

- [ ] **Step 8: Commit**

```bash
git add site/scripts site/src/data site/src/content.config.ts site/src/lib
git commit -m "feat: books content collection with 67 validated entries"
```

---

### Task 4: Base layout — nav (with hamburger), footer, SEO, reveal script

**Files:**
- Create: `site/src/layouts/Layout.astro`
- Delete: scaffolder's default `site/src/pages/index.astro` content (replaced in Task 5; for now make it a stub using the layout)

**Interfaces:**
- Consumes: `global.css` tokens (Task 1).
- Produces: `Layout.astro` with props `{ title: string; description: string }` — renders full HTML shell, nav, footer, contact section anchor, OG/meta tags, reveal script. All pages wrap content in `<Layout>`. Footer/contact include `id="contact"`.

- [ ] **Step 1: Write `site/src/layouts/Layout.astro`**

```astro
---
import '../styles/global.css';
import '@fontsource-variable/playfair-display';
import '@fontsource-variable/inter';

interface Props {
  title: string;
  description: string;
}
const { title, description } = Astro.props;
const nav = [
  { href: '/#about', label: 'About' },
  { href: '/books', label: 'Books' },
  { href: '/#awards', label: 'Awards' },
  { href: '/#news', label: 'News' },
  { href: '/#contact', label: 'Contact' },
];
const ogImage = new URL('/images/mary-ann-portrait.png', Astro.site);
---

<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>{title}</title>
    <meta name="description" content={description} />
    <link rel="canonical" href={new URL(Astro.url.pathname, Astro.site)} />
    <meta property="og:title" content={title} />
    <meta property="og:description" content={description} />
    <meta property="og:type" content="website" />
    <meta property="og:image" content={ogImage} />
    <link rel="icon" href="/favicon.svg" type="image/svg+xml" />
    <link rel="sitemap" href="/sitemap-index.xml" />
  </head>
  <body>
    <header class="sticky top-0 z-40 border-b border-sand bg-cream/90 backdrop-blur">
      <div class="mx-auto flex max-w-6xl items-center justify-between px-5 py-4">
        <a href="/" class="font-display text-xl tracking-wide">Mary Ann Ordinario</a>
        <nav class="hidden gap-8 text-sm md:flex" aria-label="Main">
          {nav.map((l) => (
            <a href={l.href} class="text-ink-soft transition hover:text-terracotta">{l.label}</a>
          ))}
        </nav>
        <button
          id="menu-btn"
          class="md:hidden"
          aria-expanded="false"
          aria-controls="mobile-menu"
          aria-label="Open menu"
        >
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M4 7h16M4 12h16M4 17h16" />
          </svg>
        </button>
      </div>
      <nav id="mobile-menu" class="hidden flex-col gap-4 border-t border-sand px-5 py-4 md:hidden" aria-label="Mobile">
        {nav.map((l) => (
          <a href={l.href} class="text-ink-soft">{l.label}</a>
        ))}
      </nav>
    </header>

    <main>
      <slot />
    </main>

    <footer id="contact" class="bg-ink text-cream">
      <div class="mx-auto max-w-6xl px-5 py-16 text-center">
        <p class="section-label">Get In Touch</p>
        <h2 class="font-display mt-3 text-3xl md:text-4xl">Let's tell a story together</h2>
        <p class="mx-auto mt-4 max-w-xl text-cream/80">
          For speaking engagements, school visits, publishing, and translation inquiries.
        </p>
        <a
          href="mailto:abcedcchildrensbooks@gmail.com"
          class="mt-8 inline-block rounded-full bg-terracotta px-8 py-3 font-semibold text-cream transition hover:bg-terracotta-dark"
        >abcedcchildrensbooks@gmail.com</a>
        <p class="mt-12 text-sm text-cream/60">
          © {new Date().getFullYear()} Mary Ann Ordinario · ABC Educational Development Center Children's Books
        </p>
      </div>
    </footer>

    <script>
      const btn = document.getElementById('menu-btn');
      const menu = document.getElementById('mobile-menu');
      btn?.addEventListener('click', () => {
        const open = menu?.classList.toggle('hidden') === false;
        btn.setAttribute('aria-expanded', String(open));
        menu?.classList.toggle('flex', open);
      });
      menu?.addEventListener('click', (e) => {
        if ((e.target as HTMLElement).tagName === 'A') {
          menu.classList.add('hidden');
          menu.classList.remove('flex');
          btn?.setAttribute('aria-expanded', 'false');
        }
      });

      const io = new IntersectionObserver(
        (entries) => {
          for (const e of entries) {
            if (e.isIntersecting) {
              e.target.classList.add('revealed');
              io.unobserve(e.target);
            }
          }
        },
        { threshold: 0.12 }
      );
      document.querySelectorAll('.reveal').forEach((el) => io.observe(el));
    </script>
  </body>
</html>
```

- [ ] **Step 2: Stub `site/src/pages/index.astro`**

```astro
---
import Layout from '../layouts/Layout.astro';
---

<Layout
  title="Mary Ann Ordinario — Award-Winning Children's Book Author"
  description="Mary Ann Ordinario is an award-winning Filipino author of over 75 children's books celebrating culture, peace, diversity, and the environment."
>
  <section class="mx-auto max-w-6xl px-5 py-24" id="about">
    <h1 class="font-display text-5xl">Mary Ann Ordinario</h1>
  </section>
</Layout>
```

- [ ] **Step 3: Verify**

Run: `npm run build && npm run dev` (visit http://localhost:4321 — nav, footer, and hamburger at <768px work).
Expected: build passes; menu toggles.

- [ ] **Step 4: Commit**

```bash
git add site/src
git commit -m "feat: base layout with nav, footer, SEO meta, and reveal script"
```

---

### Task 5: Shared BookCard component + home Hero and Stats band

**Files:**
- Create: `site/src/components/BookCard.astro`, `site/src/components/Hero.astro`, `site/src/components/StatsBand.astro`
- Modify: `site/src/pages/index.astro`

**Interfaces:**
- Consumes: `getCover` (Task 3), Layout (Task 4).
- Produces: `BookCard.astro` with props `{ title: string; cover: ImageMetadata | null; awards?: string[]; translations?: string[]; category: string; widths?: number[] }` — renders a `<article class="book-card">` with `data-title`, `data-category`, `data-awards` (joined with `|`), `data-translations` attributes (used by Task 8's script). Books without a cover render a sand-colored placeholder panel with the title, never a broken image.

- [ ] **Step 1: Write `site/src/components/BookCard.astro`**

```astro
---
import { Image } from 'astro:assets';
import type { ImageMetadata } from 'astro';

interface Props {
  title: string;
  cover: ImageMetadata | null;
  awards?: string[];
  translations?: string[];
  category: string;
  widths?: number[];
}
const { title, cover, awards = [], translations = [], category, widths = [200, 320, 480] } = Astro.props;
---

<article
  class="book-card group cursor-pointer"
  data-title={title}
  data-category={category}
  data-awards={awards.join('|')}
  data-translations={translations.join('|')}
  tabindex="0"
  role="button"
  aria-label={`${title} — details`}
>
  <div class="overflow-hidden rounded-xl bg-sand shadow-sm ring-1 ring-ink/5 transition group-hover:-translate-y-1 group-hover:shadow-lg">
    {cover ? (
      <Image
        src={cover}
        alt={`Cover of ${title}`}
        widths={widths}
        sizes="(min-width: 1024px) 220px, (min-width: 640px) 30vw, 45vw"
        class="aspect-[4/5] w-full object-cover"
      />
    ) : (
      <div class="flex aspect-[4/5] items-center justify-center p-4 text-center">
        <span class="font-display text-lg text-ink-soft">{title}</span>
      </div>
    )}
  </div>
  <h3 class="mt-3 line-clamp-2 text-sm font-semibold" title={title}>{title}</h3>
  {awards.length > 0 && (
    <p class="mt-1 line-clamp-2 text-xs text-terracotta">🏅 {awards[0]}</p>
  )}
</article>
```

- [ ] **Step 2: Write `site/src/components/Hero.astro`**

```astro
---
import { Image } from 'astro:assets';
import portrait from '../assets/photos/mary-ann-portrait.png';
---

<section class="relative overflow-hidden">
  <div class="mx-auto grid max-w-6xl items-center gap-10 px-5 py-16 md:grid-cols-[1.2fr_1fr] md:py-24">
    <div>
      <p class="section-label">Children's Book Author · Mindanao, Philippines</p>
      <h1 class="font-display mt-4 text-4xl leading-tight md:text-6xl">Mary Ann Ordinario</h1>
      <p class="font-display mt-3 text-xl italic text-terracotta md:text-2xl">
        Award-winning author of over 75 children's books
      </p>
      <p class="mt-6 max-w-xl leading-relaxed text-ink-soft">
        Stories that inspire children to appreciate culture, peace, diversity, environmental
        conservation, and Filipino values — read in many languages around the world.
      </p>
      <div class="mt-8 flex flex-wrap gap-4">
        <a href="/books" class="rounded-full bg-terracotta px-7 py-3 font-semibold text-cream transition hover:bg-terracotta-dark">Explore Books</a>
        <a href="#contact" class="rounded-full border border-ink/20 px-7 py-3 font-semibold transition hover:border-terracotta hover:text-terracotta">Get in Touch</a>
      </div>
    </div>
    <div class="relative mx-auto w-64 md:w-full md:max-w-sm">
      <div class="absolute inset-x-4 bottom-0 top-10 rounded-t-full bg-sand" aria-hidden="true"></div>
      <Image src={portrait} alt="Portrait of Mary Ann Ordinario" widths={[320, 480, 640]} sizes="(min-width: 768px) 24rem, 16rem" class="relative" />
    </div>
  </div>
</section>
```

- [ ] **Step 3: Write `site/src/components/StatsBand.astro`**

```astro
---
const stats = [
  { value: '75+', label: 'Books Published' },
  { value: '20+', label: 'Awards & Citations' },
  { value: '5+', label: 'Languages Translated' },
  { value: '12', label: 'New Releases in 2026' },
];
---

<section class="bg-terracotta text-cream">
  <div class="mx-auto grid max-w-6xl grid-cols-2 gap-8 px-5 py-10 text-center md:grid-cols-4">
    {stats.map((s) => (
      <div>
        <p class="font-display text-4xl">{s.value}</p>
        <p class="mt-1 text-sm uppercase tracking-widest text-cream/80">{s.label}</p>
      </div>
    ))}
  </div>
</section>
```

- [ ] **Step 4: Update `site/src/pages/index.astro`** (replace stub `<section>` with)

```astro
---
import Layout from '../layouts/Layout.astro';
import Hero from '../components/Hero.astro';
import StatsBand from '../components/StatsBand.astro';
---

<Layout
  title="Mary Ann Ordinario — Award-Winning Children's Book Author"
  description="Mary Ann Ordinario is an award-winning Filipino author of over 75 children's books celebrating culture, peace, diversity, and the environment."
>
  <Hero />
  <StatsBand />
</Layout>
```

- [ ] **Step 5: Verify**

Run: `npm run build` then `npm run dev`; check hero renders with portrait and both CTAs, stats band shows 4 stats, at 375px everything stacks.
Expected: build passes, no layout overflow.

- [ ] **Step 6: Commit**

```bash
git add site/src
git commit -m "feat: hero, stats band, and shared BookCard component"
```

---

### Task 6: Home middle sections — New Releases, About, Award-Winning Books, Books teaser

**Files:**
- Create: `site/src/components/NewReleases.astro`, `site/src/components/About.astro`, `site/src/components/AwardBooks.astro`, `site/src/components/BooksTeaser.astro`
- Modify: `site/src/pages/index.astro`

**Interfaces:**
- Consumes: `getCollection('books')`, `getCover`, `BookCard`.
- Produces: home sections with anchor ids `about` and `awards` (nav targets).

- [ ] **Step 1: Write `site/src/components/NewReleases.astro`**

```astro
---
import { getCollection } from 'astro:content';
import { getCover } from '../lib/covers';
import BookCard from './BookCard.astro';

const books = (await getCollection('books'))
  .filter((b) => b.data.category === 'new-release' && b.data.cover);
---

<section class="bg-ivory py-16 md:py-20">
  <div class="mx-auto max-w-6xl px-5">
    <div class="reveal text-center">
      <p class="section-label">Newly Released · 2026</p>
      <h2 class="font-display mt-3 text-3xl md:text-4xl">Fresh Off The Press</h2>
    </div>
    <div class="reveal mt-10 flex snap-x gap-6 overflow-x-auto pb-4">
      {books.map((b) => (
        <div class="w-40 flex-none snap-start md:w-48">
          <BookCard
            title={b.data.title}
            cover={getCover(b.data.cover)}
            category={b.data.category}
            awards={b.data.awards}
            translations={b.data.translations}
          />
        </div>
      ))}
    </div>
  </div>
</section>
```

- [ ] **Step 2: Write `site/src/components/About.astro`**

```astro
---
import { Image } from 'astro:assets';
import nbdbPhoto from '../assets/photos/mary-ann-nbdb.png';
---

<section id="about" class="py-16 md:py-24">
  <div class="mx-auto grid max-w-6xl items-center gap-12 px-5 md:grid-cols-[1fr_1.3fr]">
    <div class="reveal">
      <Image src={nbdbPhoto} alt="Mary Ann Ordinario, Member of the NBDB Governing Board" widths={[360, 560, 760]} sizes="(min-width: 768px) 26rem, 90vw" class="rounded-2xl shadow-md" />
    </div>
    <div class="reveal">
      <p class="section-label">About The Author</p>
      <h2 class="font-display mt-3 text-3xl md:text-4xl">One of Mindanao's leading children's authors</h2>
      <p class="mt-6 leading-relaxed text-ink-soft">
        Mary Ann Ordinario, author of over 75 children's books, has received numerous awards in the
        Philippines and abroad. She has dedicated her career to creating stories that inspire
        children to appreciate culture, peace, diversity, environmental conservation, and Filipino
        values.
      </p>
      <p class="mt-4 leading-relaxed text-ink-soft">
        Her books have won honors from Singapore to Los Angeles — including the AFCC KidsTime
        Author's Award, the International Indie Children's Book Cover Award, and a 2026 UNESCO–IBBY
        selection — and have been translated and published in multiple countries worldwide.
      </p>
      <p class="mt-4 leading-relaxed text-ink-soft">
        She is the founder of <strong>ABC Educational Development Center Children's Books</strong>
        and serves as a member of the Governing Board of the National Book Development Board.
      </p>
    </div>
  </div>
</section>
```

- [ ] **Step 3: Write `site/src/components/AwardBooks.astro`**

```astro
---
import { getCollection } from 'astro:content';
import { Image } from 'astro:assets';
import { getCover } from '../lib/covers';
import BookCard from './BookCard.astro';

const award = (await getCollection('books')).filter((b) => b.data.category === 'award-winning');
const tnalak = award.find((b) => b.id === 'i-love-tnalak')!;
const rest = award.filter((b) => b.id !== 'i-love-tnalak');
const tnalakCover = getCover(tnalak.data.cover);
---

<section id="awards" class="bg-ivory py-16 md:py-24">
  <div class="mx-auto max-w-6xl px-5">
    <div class="reveal text-center">
      <p class="section-label">Recognition</p>
      <h2 class="font-display mt-3 text-3xl md:text-4xl">Award-Winning Books</h2>
    </div>

    <div class="reveal mt-12 grid items-center gap-8 rounded-2xl bg-cream p-8 ring-1 ring-sand md:grid-cols-[220px_1fr]">
      {tnalakCover && (
        <Image src={tnalakCover} alt={`Cover of ${tnalak.data.title}`} widths={[220, 440]} sizes="220px" class="mx-auto w-44 rounded-lg shadow-md md:w-full" />
      )}
      <div>
        <p class="section-label">2026 Highlight</p>
        <h3 class="font-display mt-2 text-2xl md:text-3xl">{tnalak.data.title}</h3>
        <p class="mt-4 leading-relaxed text-ink-soft">
          Selected by UNESCO and the International Board on Books for Young People (IBBY) as a
          Remarkable Book for Young Readers in Indigenous and Endangered Languages — launched at
          the 40th IBBY World Congress in Ottawa, Canada, and exhibited in the official Congress
          program.
        </p>
      </div>
    </div>

    <div class="reveal mt-12 grid grid-cols-2 gap-x-6 gap-y-10 sm:grid-cols-3 lg:grid-cols-4">
      {rest.map((b) => (
        <BookCard
          title={b.data.title}
          cover={getCover(b.data.cover)}
          category={b.data.category}
          awards={b.data.awards}
          translations={b.data.translations}
        />
      ))}
    </div>
  </div>
</section>
```

- [ ] **Step 4: Write `site/src/components/BooksTeaser.astro`**

```astro
---
import { getCollection } from 'astro:content';
import { getCover } from '../lib/covers';
import BookCard from './BookCard.astro';

const teaser = (await getCollection('books'))
  .filter((b) => b.data.category === 'regular' && b.data.cover)
  .slice(0, 6);
---

<section class="py-16 md:py-20">
  <div class="mx-auto max-w-6xl px-5 text-center">
    <p class="section-label reveal">The Full Library</p>
    <h2 class="font-display reveal mt-3 text-3xl md:text-4xl">Over 60 stories and counting</h2>
    <div class="reveal mt-10 grid grid-cols-3 gap-4 md:grid-cols-6">
      {teaser.map((b) => (
        <BookCard title={b.data.title} cover={getCover(b.data.cover)} category={b.data.category} />
      ))}
    </div>
    <a href="/books" class="reveal mt-10 inline-block rounded-full bg-terracotta px-8 py-3 font-semibold text-cream transition hover:bg-terracotta-dark">View All Books</a>
  </div>
</section>
```

- [ ] **Step 5: Add all four to `site/src/pages/index.astro`** (order: Hero, StatsBand, NewReleases, About, AwardBooks, BooksTeaser — imports plus tags)

- [ ] **Step 6: Verify**

Run: `npm run build` then dev-server check: new releases scroll row shows 12 covers, about shows NBDB photo + 3 paragraphs, awards section shows Tnalak highlight + 16-cover grid with award captions, teaser shows 6 covers + button.
Expected: build passes.

- [ ] **Step 7: Commit**

```bash
git add site/src
git commit -m "feat: new releases, about, award-winning, and teaser sections"
```

---

### Task 7: News & Press section

**Files:**
- Create: `site/src/components/News.astro`
- Modify: `site/src/pages/index.astro`

**Interfaces:**
- Consumes: Layout tokens.
- Produces: `id="news"` anchor. News items are a plain array in the component — adding a card later is one object.

- [ ] **Step 1: Write `site/src/components/News.astro`**

```astro
---
const items = [
  {
    date: 'August 2026',
    title: 'I Love Tnalak launches at the 40th IBBY World Congress',
    body: 'Selected by UNESCO and IBBY as a Remarkable Book for Young Readers in Indigenous and Endangered Languages, officially launched in Ottawa, Canada.',
  },
  {
    date: 'November 2025',
    title: 'CMMA Special Citation for The Brave Little Stump',
    body: 'Honored at the Catholic Mass Media Awards.',
  },
  {
    date: '2025',
    title: 'Two books on the Severino Reyes Honor List',
    body: 'Si Kamatis Inis and A Whale in Prison named to the Best Picture Book Honor List of the Severino Reyes Medal.',
  },
  {
    date: '2024',
    title: 'Cardinal Sin Best Children\'s Book',
    body: 'A Whale in Prison won Best Book in the Children\'s Category at the 18th Cardinal Sin Catholic Book Awards.',
  },
];
---

<section id="news" class="bg-sand/50 py-16 md:py-20">
  <div class="mx-auto max-w-6xl px-5">
    <div class="reveal text-center">
      <p class="section-label">News & Press</p>
      <h2 class="font-display mt-3 text-3xl md:text-4xl">Latest Milestones</h2>
    </div>
    <div class="reveal mt-10 grid gap-6 md:grid-cols-2">
      {items.map((n) => (
        <article class="rounded-2xl bg-ivory p-6 ring-1 ring-ink/5">
          <p class="text-xs uppercase tracking-widest text-terracotta">{n.date}</p>
          <h3 class="font-display mt-2 text-xl">{n.title}</h3>
          <p class="mt-2 text-sm leading-relaxed text-ink-soft">{n.body}</p>
        </article>
      ))}
    </div>
  </div>
</section>
```

- [ ] **Step 2: Add `<News />` to `index.astro`** after `<BooksTeaser />`.

- [ ] **Step 3: Verify**

Run: `npm run build`; dev check: 4 cards, `#news` nav link scrolls to it.
Expected: build passes.

- [ ] **Step 4: Commit**

```bash
git add site/src
git commit -m "feat: news and press section"
```

---

### Task 8: Books page with filters, search, and detail modal

**Files:**
- Create: `site/src/pages/books.astro`

**Interfaces:**
- Consumes: `getCollection('books')`, `getCover`, `BookCard` (reads its `data-*` attributes), Layout.
- Produces: `/books` route. Client behavior contract: clicking/Enter on a `.book-card` opens the `<dialog id="book-dialog">`; tab buttons carry `data-filter` (`all` | `award-winning` | `new-release`); `#book-search` input filters by title substring.

- [ ] **Step 1: Write `site/src/pages/books.astro`**

```astro
---
import Layout from '../layouts/Layout.astro';
import BookCard from '../components/BookCard.astro';
import { getCollection } from 'astro:content';
import { getCover } from '../lib/covers';

const books = (await getCollection('books')).sort((a, b) =>
  a.data.title.localeCompare(b.data.title)
);
const tabs = [
  { key: 'all', label: 'All Books' },
  { key: 'award-winning', label: 'Award Winners' },
  { key: 'new-release', label: 'New Releases 2026' },
];
---

<Layout
  title="Books — Mary Ann Ordinario"
  description="Browse the full catalog of Mary Ann Ordinario's children's books — stories celebrating Filipino culture, values, and the environment."
>
  <section class="mx-auto max-w-6xl px-5 py-14 md:py-20">
    <p class="section-label">The Library</p>
    <h1 class="font-display mt-3 text-4xl md:text-5xl">Books</h1>
    <p class="mt-4 max-w-2xl text-ink-soft">
      Stories celebrating Filipino culture, values, and the environment.
    </p>

    <div class="mt-10 flex flex-wrap items-center gap-3">
      {tabs.map((t, i) => (
        <button
          class:list={[
            'filter-tab rounded-full border px-5 py-2 text-sm font-semibold transition',
            i === 0
              ? 'border-terracotta bg-terracotta text-cream'
              : 'border-ink/20 text-ink-soft hover:border-terracotta hover:text-terracotta',
          ]}
          data-filter={t.key}
          aria-pressed={i === 0 ? 'true' : 'false'}
        >{t.label}</button>
      ))}
      <input
        id="book-search"
        type="search"
        placeholder="Search titles…"
        aria-label="Search books by title"
        class="ml-auto w-full rounded-full border border-ink/20 bg-ivory px-5 py-2 text-sm outline-none focus:border-terracotta sm:w-64"
      />
    </div>

    <div id="books-grid" class="mt-10 grid grid-cols-2 gap-x-6 gap-y-10 sm:grid-cols-3 lg:grid-cols-5">
      {books.map((b) => (
        <BookCard
          title={b.data.title}
          cover={getCover(b.data.cover)}
          category={b.data.category}
          awards={b.data.awards}
          translations={b.data.translations}
        />
      ))}
    </div>
    <p id="no-results" class="mt-16 hidden text-center text-ink-soft">
      No books match your search.
    </p>
  </section>

  <dialog id="book-dialog" class="m-auto w-[min(92vw,40rem)] rounded-2xl bg-ivory p-0 backdrop:bg-ink/50">
    <div class="grid gap-6 p-6 sm:grid-cols-[200px_1fr] sm:p-8">
      <img id="dialog-cover" src="" alt="" class="mx-auto w-44 rounded-lg shadow-md sm:w-full" />
      <div>
        <h2 id="dialog-title" class="font-display text-2xl"></h2>
        <ul id="dialog-awards" class="mt-4 space-y-2 text-sm text-terracotta"></ul>
        <p id="dialog-translations" class="mt-4 text-sm text-ink-soft"></p>
        <form method="dialog" class="mt-8">
          <button class="rounded-full border border-ink/20 px-6 py-2 text-sm font-semibold transition hover:border-terracotta hover:text-terracotta">Close</button>
        </form>
      </div>
    </div>
  </dialog>

  <script>
    const grid = document.getElementById('books-grid')!;
    const cards = [...grid.querySelectorAll<HTMLElement>('.book-card')];
    const tabs = [...document.querySelectorAll<HTMLButtonElement>('.filter-tab')];
    const search = document.getElementById('book-search') as HTMLInputElement;
    const noResults = document.getElementById('no-results')!;
    let activeFilter = 'all';

    function apply() {
      const q = search.value.trim().toLowerCase();
      let visible = 0;
      for (const card of cards) {
        const matchesFilter =
          activeFilter === 'all' || card.dataset.category === activeFilter;
        const matchesSearch = (card.dataset.title ?? '').toLowerCase().includes(q);
        const show = matchesFilter && matchesSearch;
        card.style.display = show ? '' : 'none';
        if (show) visible++;
      }
      noResults.classList.toggle('hidden', visible > 0);
    }

    for (const tab of tabs) {
      tab.addEventListener('click', () => {
        activeFilter = tab.dataset.filter ?? 'all';
        for (const t of tabs) {
          const active = t === tab;
          t.setAttribute('aria-pressed', String(active));
          t.classList.toggle('bg-terracotta', active);
          t.classList.toggle('text-cream', active);
          t.classList.toggle('border-terracotta', active);
          t.classList.toggle('text-ink-soft', !active);
          t.classList.toggle('border-ink/20', !active);
        }
        apply();
      });
    }
    search.addEventListener('input', apply);

    const dialog = document.getElementById('book-dialog') as HTMLDialogElement;
    const dCover = document.getElementById('dialog-cover') as HTMLImageElement;
    const dTitle = document.getElementById('dialog-title')!;
    const dAwards = document.getElementById('dialog-awards')!;
    const dTrans = document.getElementById('dialog-translations')!;

    function openCard(card: HTMLElement) {
      const img = card.querySelector('img');
      dCover.src = img?.currentSrc || img?.src || '';
      dCover.alt = img ? `Cover of ${card.dataset.title}` : '';
      dCover.style.display = img ? '' : 'none';
      dTitle.textContent = card.dataset.title ?? '';
      dAwards.innerHTML = '';
      for (const a of (card.dataset.awards ?? '').split('|').filter(Boolean)) {
        const li = document.createElement('li');
        li.textContent = `🏅 ${a}`;
        dAwards.appendChild(li);
      }
      const trans = (card.dataset.translations ?? '').split('|').filter(Boolean);
      dTrans.textContent = trans.length ? `Also translated into: ${trans.join(', ')}` : '';
      dialog.showModal();
    }

    for (const card of cards) {
      card.addEventListener('click', () => openCard(card));
      card.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          openCard(card);
        }
      });
    }
    dialog.addEventListener('click', (e) => {
      if (e.target === dialog) dialog.close();
    });
  </script>
</Layout>
```

- [ ] **Step 2: Verify behavior in dev**

Run: `npm run dev`; on `/books` check: 67 cards render (4 as title-only placeholders); "Award Winners" tab shows 17; "New Releases 2026" shows 13; searching "whale" shows 1; nonsense query shows the empty state; clicking a card opens the dialog with awards/translations; Esc and Close both work; keyboard: Tab to a card, Enter opens.
Expected: all behaviors pass.

- [ ] **Step 3: Verify build**

Run: `npm run build`
Expected: passes; `dist/books/index.html` exists.

- [ ] **Step 4: Commit**

```bash
git add site/src/pages/books.astro
git commit -m "feat: books catalog page with filters, search, and detail modal"
```

---

### Task 9: Final QA — favicon, Lighthouse, reconciliation, README, deploy config

**Files:**
- Create: `site/public/favicon.svg` (replace scaffold default), `site/netlify.toml`, `site/README.md`

**Interfaces:**
- Consumes: everything.
- Produces: deploy-ready repo.

- [ ] **Step 1: Write `site/public/favicon.svg`** (simple terracotta monogram)

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <rect width="64" height="64" rx="14" fill="#C0623B"/>
  <text x="32" y="43" text-anchor="middle" font-family="Georgia, serif" font-size="32" fill="#F5F0E8">M</text>
</svg>
```

- [ ] **Step 2: Write `site/netlify.toml`**

```toml
[build]
  command = "npm run build"
  publish = "dist"
```

- [ ] **Step 3: Write `site/README.md`**

```markdown
# Mary Ann Ordinario — Author Portfolio

Astro 5 + Tailwind 4 static site. Two pages: `/` and `/books`.

## Develop
    npm install
    npm run dev

## Validate book data
    node scripts/validate-books.mjs

## Add or edit a book
1. Drop the cover in `src/assets/covers/<slug>.jpg`.
2. Add/edit its entry in `src/data/books.json` (`id`, `title`, `cover`, `category`, `awards`, `translations`).
3. Run the validator, then `npm run build`.

## Deploy
- **Netlify:** connect the repo, base directory `site/` — `netlify.toml` handles the rest.
- **Vercel:** import the repo, set root directory to `site/`, framework preset Astro.
- Before going live, set the real domain in `astro.config.mjs` (`site:` field).

## Pending client content (see `note` fields in books.json)
- Covers: Ang Mabahong Prutas, Jesus Raises Lazarus From The Dead, Learning About The
  Philippines, Learning About The Philippines Famous Wonders.
- Confirm: kingdom.png identity, Crying Trees award wording (Grand Prize vs 2nd Place),
  titles found in cover folders but not the title list (Smelly Fruit, Chocolate Hills,
  Chatkak, Counting Book), "30+ years" stat.
```

- [ ] **Step 4: Full verification pass**

Run (in `site/`):
```bash
node scripts/validate-books.mjs
npm run build
npx astro preview &
sleep 2
npx lighthouse http://localhost:4321 --only-categories=performance,accessibility,best-practices,seo --chrome-flags="--headless" --quiet
npx lighthouse http://localhost:4321/books --only-categories=performance,accessibility,best-practices,seo --chrome-flags="--headless" --quiet
kill %1
```
Expected: validator OK; build clean; Lighthouse ≥ 90 in all four categories on both pages. If a category is below 90, fix the flagged items (most likely: image `sizes`, contrast, or missing aria labels) and re-run.

- [ ] **Step 5: Manual reconciliation checklist**

- [ ] All 51 main-list titles from `Book Titles.docx` appear on `/books`.
- [ ] All 12 "New Released Books 2026" titles appear under the New Releases filter.
- [ ] All 17 award-winning covers show award captions matching `Mary Ann Ordinario.docx`.
- [ ] Responsive check at 375px, 768px, 1440px on both pages (no horizontal scroll).

- [ ] **Step 6: Commit**

```bash
git add site
git commit -m "chore: favicon, deploy config, README, and final QA"
```

---

## Deviations from spec (intentional, minor)

- `awards` entries are display strings rather than `{name, org, year}` objects — the site only ever renders them as captions (YAGNI).
- The spec's "17 award books carry captions" renders as the Tnalak highlight card + 16-card grid on home; all 17 carry captions on `/books`.
- Stats band fourth stat is "12 New Releases in 2026" (data-backed) instead of the unverified "30+ Years"; swap once the client confirms the figure.
