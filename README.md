# WE Events × WE Displays — Website

Bilingual (EN / 中文) static site built with [Astro](https://astro.build).

## Commands

```bash
npm install
npm run dev      # http://localhost:4321 → redirects to /en/
npm run build    # output in dist/
npm run preview  # preview production build
```

## Structure

- `src/data/en.ts` / `zh.ts` — all page copy
- `src/pages/[lang]/` — localized routes (`/en/`, `/zh/`)
- `public/logo.svg` — brand logo

## Deploy

Upload `dist/` to any static host (Netlify, Vercel, Cloudflare Pages, or your NZ hosting for www.we-events.co.nz).

## Gallery photos

Project photos live in `public/images/gallery/` (copied from client `过往照片` folder).

- **Gallery page**: `/en/gallery/` · `/zh/gallery/`
- Add or replace images in `public/images/gallery/` — the page picks them up on rebuild
- To label a photo with a project name, edit `src/data/en.ts` / `zh.ts` case `image` paths or add captions later

Hero banner: `public/images/hero-banner.jpg`
