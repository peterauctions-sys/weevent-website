import { readdirSync } from 'node:fs';
import { join } from 'node:path';

const GALLERY_DIR = join(process.cwd(), 'public', 'images', 'gallery');
const IMAGE_RE = /\.(jpe?g|png|webp)$/i;

/** All images from 过往照片 — paths ready for <img src> */
export function getGalleryImages(): string[] {
  try {
    return readdirSync(GALLERY_DIR)
      .filter((name) => IMAGE_RE.test(name))
      .sort((a, b) => a.localeCompare(b, undefined, { numeric: true }))
      .map((name) => `/images/gallery/${encodeURI(name)}`);
  } catch {
    return [];
  }
}
