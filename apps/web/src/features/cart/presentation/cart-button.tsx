'use client';

import { ShoppingBag } from 'lucide-react';
import Link from 'next/link';
import { useTranslations } from 'next-intl';

import { useStore, useStoreProducts } from '@/features/catalog/presentation/store-context';
import { cartTotals, resolveLines } from '../domain/cart';
import { useCartHydration, useCartItems } from '../state/cart-store';

/** Header button to the order, with the number of units in it. */
export function CartButton() {
  const t = useTranslations('store');
  const store = useStore();
  const products = useStoreProducts();
  const hydrated = useCartHydration();
  const items = useCartItems(store.slug);
  const units = hydrated ? cartTotals(resolveLines(items, products)).units : 0;

  return (
    <Link
      href={`/${store.slug}/pedido`}
      aria-label={`${t('cart')}. ${t('cartCount', { count: units })}`}
      className="relative flex size-12 items-center justify-center rounded-lg border border-divider bg-surface text-primary transition hover:border-ink hover:bg-ink hover:text-white"
    >
      <ShoppingBag className="size-[22px]" strokeWidth={1.8} />
      {units > 0 && (
        <span className="absolute -top-1.5 -right-1.5 flex h-6 min-w-6 items-center justify-center rounded-full border-2 border-surface bg-success px-1.5 text-xs font-bold text-white tabular-nums">
          {units}
        </span>
      )}
    </Link>
  );
}
