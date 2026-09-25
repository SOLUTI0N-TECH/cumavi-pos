import type { Metadata } from 'next';
import { getTranslations } from 'next-intl/server';

import { CartView } from '@/features/cart/presentation/cart-view';

export async function generateMetadata(): Promise<Metadata> {
  const t = await getTranslations('cart');
  // The order is private to the customer's browser: keep it out of search.
  return { title: t('title'), robots: { index: false } };
}

export default function OrderPage() {
  return <CartView />;
}
