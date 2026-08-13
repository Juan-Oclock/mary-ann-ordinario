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
