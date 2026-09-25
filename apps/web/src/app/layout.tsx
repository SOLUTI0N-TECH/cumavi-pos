import type { Metadata, Viewport } from 'next';
import { Outfit } from 'next/font/google';
import { NextIntlClientProvider } from 'next-intl';
import { getLocale, getTranslations } from 'next-intl/server';
import type { ReactNode } from 'react';
import { Toaster } from 'sonner';

import './globals.css';

/** Same typeface as the POS app. */
const outfit = Outfit({
  subsets: ['latin'],
  variable: '--font-outfit',
  display: 'swap',
});

export async function generateMetadata(): Promise<Metadata> {
  const t = await getTranslations('metadata');
  return {
    metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL ?? 'http://localhost:3000'),
    title: { default: t('directoryTitle'), template: `%s` },
    description: t('directoryDescription'),
    applicationName: t('siteName'),
  };
}

export const viewport: Viewport = {
  themeColor: '#292526',
};

export default async function RootLayout({ children }: { children: ReactNode }) {
  const locale = await getLocale();

  return (
    <html lang={locale} className={outfit.variable}>
      <body className="min-h-dvh">
        <NextIntlClientProvider>
          {children}
          <Toaster
            position="top-center"
            toastOptions={{
              className: '!rounded-xl !font-sans !text-[15px]',
            }}
          />
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
