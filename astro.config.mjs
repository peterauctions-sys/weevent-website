import { defineConfig } from 'astro/config';

const base = process.env.BASE_PATH || '/';

export default defineConfig({
  site: process.env.SITE_URL || 'https://www.we-events.co.nz',
  base,
  output: 'static',
  build: {
    format: 'directory',
  },
});