'use client';

import { ArrowLeft, ShoppingBag, Trash2 } from 'lucide-react';
import Link from 'next/link';
import { useTranslations } from 'next-intl';
import { useState } from 'react';

import { imageOf, variantLabel } from '@/features/catalog/domain/product-rules';
import { useStore, useStoreProducts } from '@/features/catalog/presentation/store-context';
import { CheckoutDialog } from '@/features/ordering/presentation/checkout-dialog';
import { formatMoney } from '@/shared/lib/money';
import { Button, buttonClasses } from '@/shared/ui/button';
import { EmptyState } from '@/shared/ui/empty-state';
import { ProductPhoto } from '@/shared/ui/product-photo';
import { QuantityStepper } from '@/shared/ui/quantity-stepper';
import { type CartLine, cartTotals, itemKey, resolveLines } from '../domain/cart';
import { useCartHydration, useCartItems, useCartStore } from '../state/cart-store';

/** "Tu pedido": the lines, the summary and the way to checkout. */
export function CartView() {
  const t = useTranslations('cart');
  const store = useStore();
  const products = useStoreProducts();
  const hydrated = useCartHydration();
  const items = useCartItems(store.slug);
  const [checkingOut, setCheckingOut] = useState(false);

  const lines = resolveLines(items, products);
  const { units, total } = cartTotals(lines);
  const adjusted = lines.some(
    (line) => items.find((item) => itemKey(item) === line.key)?.quantity !== line.quantity,
  );

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <h1 className="text-3xl font-bold tracking-tight">{t('title')}</h1>
        <Link href={`/${store.slug}`} className={buttonClasses('secondary')}>
          <ArrowLeft className="size-4" />
          {t('continueShopping')}
        </Link>
      </div>

      {!hydrated ? (
        <div className="h-64 animate-pulse rounded-3xl bg-surface" aria-hidden />
      ) : lines.length === 0 ? (
        <EmptyState
          icon={<ShoppingBag className="size-7" strokeWidth={1.8} />}
          title={t('emptyTitle')}
          message={t('emptyMessage')}
          action={
            <Link href={`/${store.slug}`} className={buttonClasses('primary', 'lg')}>
              {t('emptyAction')}
            </Link>
          }
        />
      ) : (
        <div className="grid items-start gap-5 lg:grid-cols-[minmax(0,1fr)_400px]">
          <ul className="flex flex-col gap-3">
            {adjusted && (
              <li className="rounded-xl bg-warning-surface px-4 py-3 text-[15px] text-warning-text">
                {t('stockAdjusted')}
              </li>
            )}
            {lines.map((line) => (
              <CartLineRow key={line.key} line={line} />
            ))}
          </ul>

          <aside className="flex flex-col gap-4 rounded-3xl border border-divider bg-surface p-5 sm:p-6 lg:sticky lg:top-24">
            <h2 className="text-lg font-bold">{t('summary')}</h2>
            <dl className="flex flex-col gap-2.5 text-[15px] text-secondary">
              <div className="flex justify-between gap-3">
                <dt>{t('items', { count: units })}</dt>
                <dd className="font-semibold text-primary tabular-nums">{formatMoney(total)}</dd>
              </div>
              <div className="flex justify-between gap-3">
                <dt>{t('delivery')}</dt>
                <dd className="font-semibold text-success-text">{t('deliveryValue')}</dd>
              </div>
            </dl>
            <div className="h-px bg-divider" />
            <div className="flex items-baseline justify-between gap-3">
              <span className="text-sm font-semibold tracking-wide text-secondary uppercase">
                {t('total')}
              </span>
              <span className="text-3xl font-bold tracking-tight tabular-nums">
                {formatMoney(total)}
              </span>
            </div>
            <Button size="lg" onClick={() => setCheckingOut(true)}>
              {t('checkout')}
            </Button>
            <p className="text-sm leading-relaxed text-secondary">
              {t('note', { store: store.name })}
            </p>
          </aside>
        </div>
      )}

      <CheckoutDialog
        open={checkingOut}
        onOpenChange={setCheckingOut}
        lines={lines}
        total={total}
      />
    </div>
  );
}

function CartLineRow({ line }: { line: CartLine }) {
  const t = useTranslations('cart');
  const catalog = useTranslations('catalog');
  const store = useStore();
  const setQuantity = useCartStore((state) => state.setQuantity);
  const name = line.product.name;
  const label = line.variant ? variantLabel(line.variant) : undefined;

  return (
    <li className="flex flex-wrap items-center gap-4 rounded-2xl border border-divider bg-surface p-3 sm:flex-nowrap">
      <Link href={`/${store.slug}/p/${line.product.slug}`} className="w-20 shrink-0">
        <ProductPhoto src={imageOf(line.product, line.variant)} alt={name} sizes="80px" />
      </Link>
      <div className="flex min-w-0 flex-1 basis-40 flex-col gap-1">
        <span className="text-base font-semibold leading-snug">{name}</span>
        {label && (
          <span className="w-fit rounded-md bg-background px-2 py-0.5 text-[13px] font-semibold text-ink-soft">
            {label}
          </span>
        )}
        <span className="text-[13px] text-secondary">
          {t('unitPrice', { price: formatMoney(line.product.price) })}
        </span>
      </div>
      <QuantityStepper
        quantity={line.quantity}
        onDecrement={() => setQuantity(store.slug, line.key, line.quantity - 1)}
        onIncrement={() => setQuantity(store.slug, line.key, line.quantity + 1)}
        canIncrement={line.quantity < line.available}
        decrementLabel={catalog('decrease', { name })}
        incrementLabel={catalog('increase', { name })}
      />
      <span className="min-w-24 text-right text-lg font-bold tabular-nums">
        {formatMoney(line.total)}
      </span>
      <button
        type="button"
        onClick={() => setQuantity(store.slug, line.key, 0)}
        aria-label={t('remove', { name })}
        className="flex size-10 shrink-0 items-center justify-center rounded-md border border-divider text-error-text transition hover:border-error hover:bg-error-surface"
      >
        <Trash2 className="size-[18px]" />
      </button>
    </li>
  );
}
