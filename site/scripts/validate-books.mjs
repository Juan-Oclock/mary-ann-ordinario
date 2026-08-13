import { readFileSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const books = JSON.parse(readFileSync(join(root, 'src/data/books.json'), 'utf8'));
const coverFiles = new Set(
  readdirSync(join(root, 'src/assets/covers')).filter((f) => !f.startsWith('.'))
);
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

if (errors.length) {
  console.error(errors.join('\n'));
  process.exit(1);
}

// Counts are reported, never asserted. Fixed expectations here used to make the
// README's own "add a book" recipe fail the validator, and supplying a cover for
// one of the pending books tripped it too.
const count = (c) => books.filter((b) => b.category === c).length;
console.log(`OK: ${books.length} books validated`);
console.log(
  `  counts: ${count('award-winning')} award-winning, ` +
    `${count('new-release')} new-release, ${count('regular')} regular`
);
console.log(
  `  covers: ${books.filter((b) => b.cover !== null).length} present, ` +
    `${books.filter((b) => b.cover === null).length} pending`
);
