import type { Metadata } from 'next';
import { getTranslations } from 'next-intl/server';
import { Suspense } from 'react';

import { OrderConfirmation } from '@/features/ordering/presentation/order-confirmation';

export async function generateMetadata(): Promise<Metadata> {
  const t = await getTranslations('confirmation');
  return { title: t('title'), robots: { index: false } };
}

/**
 * `/<store>/pedido/confirmado?n=1001`. The number comes in the query string
 * because orders only exist in the customer's browser, so this page is
 * prebuilt once and reads the order on the client.
 */
export default function OrderConfirmationPage() {
  return (
    <Suspense>
      <OrderConfirmation />
    </Suspense>
  );
}
