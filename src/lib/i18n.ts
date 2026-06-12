import type { Lang, SiteContent } from './types';
import { en } from '../data/en';
import { zh } from '../data/zh';

const content: Record<Lang, SiteContent> = { en, zh };

export function getLang(param: string | undefined): Lang {
  return param === 'zh' ? 'zh' : 'en';
}

export function t(lang: Lang): SiteContent {
  return content[lang];
}

function siteBase(): string {
  return import.meta.env.BASE_URL || '/';
}

/** Public asset URL (logo, images) — respects GitHub Pages base path */
export function assetUrl(path: string): string {
  const clean = path.replace(/^\//, '');
  return `${siteBase()}${clean}`;
}

export function pathFor(lang: Lang, page = ''): string {
  const langPath = page ? `${lang}/${page}/` : `${lang}/`;
  return `${siteBase()}${langPath}`;
}

export function alternateLang(lang: Lang): Lang {
  return lang === 'en' ? 'zh' : 'en';
}

export function switchPath(lang: Lang, currentPath: string): string {
  const other = alternateLang(lang);
  return currentPath.replace(`/${lang}/`, `/${other}/`).replace(`/${lang}`, `/${other}`);
}
