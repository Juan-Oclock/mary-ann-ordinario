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
    /** Client's own synopsis, lightly copyedited. Absent for titles she has
     *  not supplied one for, so every consumer must handle it being missing. */
    blurb: z.string().optional(),
    /** Shopee product page. Absent for the titles not yet listed there. */
    shopeeUrl: z.string().url().optional(),
    note: z.string().optional(),
  }),
});

export const collections = { books };
