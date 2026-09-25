import type { NextConfig } from 'next';
import createNextIntlPlugin from 'next-intl/plugin';

const withNextIntl = createNextIntlPlugin('./src/i18n/request.ts');

/**
 * Static export: every page is prebuilt into `out/`, so the catalog can be
 * hosted anywhere (Netlify today). The orders live in the browser, so no
 * server is needed until the backend exists.
 */
const nextConfig: NextConfig = {
  output: 'export',
  trailingSlash: true,
  // No image server in a static site: photos are served as they are.
  images: { unoptimized: true },
  reactStrictMode: true,
};

export default withNextIntl(nextConfig);
