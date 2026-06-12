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

export function pathFor(lang: Lang, page = ''): string {
  const base = `/${lang}`;
  return page ? `${base}/${page}/` : `${base}/`;
}

export function alternateLang(lang: Lang): Lang {
  return lang === 'en' ? 'zh' : 'en';
}

export function switchPath(lang: Lang, currentPath: string): string {
  const other = alternateLang(lang);
  return currentPath.replace(`/${lang}/`, `/${other}/`).replace(`/${lang}`, `/${other}`);
}
