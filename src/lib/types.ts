export type Lang = 'en' | 'zh';

export interface NavItem {
  href: string;
  label: string;
}

export interface Stat {
  value: string;
  label: string;
}

export interface Service {
  title: string;
  description: string;
  icon: string;
}

export interface CaseStudy {
  title: string;
  location: string;
  summary: string;
  tags: string[];
  featured?: boolean;
  image?: string;
}

export interface TeamMember {
  name: string;
  role: string;
  bio: string;
  email?: string;
  phone?: string;
}

export interface Solution {
  size: string;
  title: string;
  points: string[];
}

export interface SiteContent {
  lang: Lang;
  locale: string;
  dir: 'ltr';
  siteName: string;
  tagline: string;
  nav: NavItem[];
  footer: {
    brand: string;
    tagline: string;
    rights: string;
    regions: string;
  };
  home: {
    metaTitle: string;
    metaDescription: string;
    heroTitle: string;
    heroHighlight: string;
    heroSubtitle: string;
    heroCta: string;
    heroSecondary: string;
    stats: Stat[];
    servicesTitle: string;
    servicesSubtitle: string;
    services: Service[];
    whyTitle: string;
    whyItems: string[];
    ctaTitle: string;
    ctaText: string;
    ctaButton: string;
  };
  about: {
    metaTitle: string;
    title: string;
    intro: string;
    networkTitle: string;
    network: string;
    pillarsTitle: string;
    pillars: Stat[];
    teamTitle: string;
    team: TeamMember[];
  };
  services: {
    metaTitle: string;
    title: string;
    intro: string;
    list: { title: string; body: string; bullets: string[] }[];
    modularTitle: string;
    modularIntro: string;
    modularBenefits: { title: string; text: string }[];
  };
  portfolio: {
    metaTitle: string;
    title: string;
    intro: string;
    viewGallery: string;
    cases: CaseStudy[];
  };
  gallery: {
    metaTitle: string;
    title: string;
    intro: string;
    note: string;
    imageAlt: string;
    empty: string;
  };
  solutions: {
    metaTitle: string;
    title: string;
    intro: string;
    solutions: Solution[];
    benefitsTitle: string;
    benefits: string[];
  };
  contact: {
    metaTitle: string;
    title: string;
    intro: string;
    website: string;
    people: { name: string; role: string; email: string; phone: string }[];
  };
  langSwitch: { label: string; other: string };
}
