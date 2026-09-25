import Link from 'next/link';
import { getTranslations } from 'next-intl/server';

import { CartButton } from '@/features/cart/presentation/cart-button';
import type { Store } from '../domain/entities';
import { StoreStatusPill } from './store-status-pill';

/** `Illimani Store` → `IS` */
function initialsOf(name: string): string {
  return name
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((word) => word[0]?.toUpperCase())
    .join('');
}

/** Sticky header: store identity, open status and the order button. */
export async function StoreHeader({ store }: { store: Store }) {
  const t = await getTranslations('store');

  return (
    <header className="sticky top-0 z-40 border-b border-divider bg-surface/95 backdrop-blur">
      <div className="mx-auto flex max-w-[1400px] items-center justify-between gap-4 px-4 py-3 sm:px-6">
        <Link href={`/${store.slug}`} className="flex min-w-0 items-center gap-3">
          <span className="flex size-12 shrink-0 items-center justify-center rounded-lg bg-ink text-lg font-bold text-white">
            {initialsOf(store.name)}
          </span>
          <span className="flex min-w-0 flex-col">
            <span className="truncate text-lg font-bold tracking-tight">{store.name}</span>
            <span className="truncate text-[13px] text-secondary">
              {t('noSignup')} · {store.zone}, {store.city}
            </span>
          </span>
        </Link>
        <div className="flex shrink-0 items-center gap-3">
          <span className="hidden sm:inline-flex">
            <StoreStatusPill store={store} />
          </span>
          <span className="sm:hidden">
            <StoreStatusPill store={store} detailed={false} />
          </span>
          <CartButton />
        </div>
      </div>
    </header>
  );
}
