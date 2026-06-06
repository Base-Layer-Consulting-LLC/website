// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

import { siteConfig } from './src/config/site';

export default defineConfig({
  vite: {
    plugins: [tailwindcss()]
  },

  site: siteConfig.url,
  trailingSlash: "never",
  output: "static",
});