import { getRequestConfig } from 'next-intl/server';

/**
 * Spanish (Bolivia) only for now. Adding a language means adding
 * `messages/<locale>.json` and resolving the locale here.
 */
export const defaultLocale = 'es';
export const timeZone = 'America/La_Paz';

export default getRequestConfig(async () => ({
  locale: defaultLocale,
  timeZone,
  messages: (await import(`../../messages/${defaultLocale}.json`)).default,
}));
