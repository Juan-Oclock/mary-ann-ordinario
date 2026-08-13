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
