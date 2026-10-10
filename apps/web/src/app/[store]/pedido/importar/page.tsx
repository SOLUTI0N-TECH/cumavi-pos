import type { Metadata } from 'next';
import { getTranslations } from 'next-intl/server';
import { Suspense } from 'react';

import { OrderImportView } from '@/features/ordering/presentation/order-import-view';

export async function generateMetadata(): Promise<Metadata> {
  const t = await getTranslations('orderImport');
  return { title: t('title'), robots: { index: false } };
}

/**
 * `/<store>/pedido/importar?d=…`: the link of a WhatsApp order, opened by
 * the store to load it into Cumavi POS. The order travels in `d`, so the
 * page is prebuilt once and reads it on the client.
 */
export default function OrderImportPage() {
  return (
    <Suspense>
      <OrderImportView />
    </Suspense>
  );
}
