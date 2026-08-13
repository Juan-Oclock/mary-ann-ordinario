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
