'use client';

import { Layers, Plus } from 'lucide-react';
import Link from 'next/link';
import { useTranslations } from 'next-intl';
import { useState } from 'react';
import { toast } from 'sonner';

import { lineKey, quantityOfProduct } from '@/features/cart/domain/cart';
import { useCartHydration, useCartItems, useCartStore } from '@/features/cart/state/cart-store';
import { cn } from '@/shared/lib/cn';
import { formatMoney } from '@/shared/lib/money';
import { Button } from '@/shared/ui/button';
import { ProductPhoto } from '@/shared/ui/product-photo';
import { QuantityStepper } from '@/shared/ui/quantity-stepper';
import { StatusPill } from '@/shared/ui/status-pill';
import type { Product } from '../domain/entities';
import {
  LOW_STOCK_THRESHOLD,
  hasVariants,
  imageOf,
  totalStock,
} from '../domain/product-rules';
import { QuickPickDialog } from './quick-pick-dialog';
import { useStore } from './store-context';

export type CatalogLayout = 'grid' | 'list';

/**
 * Catalog card. Simple products are added right here and turn into a
 * stepper; products with variants open the picker ("Elegir").
 */
export function ProductCard({
  product,
  layout,
  priority = false,
}: {
  product: Product;
  layout: CatalogLayout;
  priority?: boolean;
}) {
  const t = useTranslations('catalog');
  const productText = useTranslations('product');
  const store = useStore();
  const hydrated = useCartHydration();
  const items = useCartItems(store.slug);
  const add = useCartStore((state) => state.add);
  const setQuantity = useCartStore((state) => state.setQuantity);
  const [picking, setPicking] = useState(false);

  const stock = totalStock(product);
  const soldOut = stock <= 0;
  const withVariants = hasVariants(product);
  const inCart = hydrated ? quantityOfProduct(items, product.id) : 0;
  const href = `/${store.slug}/p/${product.slug}`;
  const isList = layout === 'list';

  function addOne() {
    if (add(store.slug, product)) {
      toast.success(t('added', { name: product.name }));
    } else {
      toast.error(t('stockLimit', { name: product.name }));
    }
  }

  const action = soldOut ? (
    <Button variant="secondary" disabled className="w-full">
      {t('soldOut')}
    </Button>
  ) : withVariants ? (
    <Button className="w-full" onClick={() => setPicking(true)}>
      {t('choose')}
    </Button>
  ) : inCart > 0 ? (
    <QuantityStepper
      className="w-full"
      quantity={inCart}
      onDecrement={() => setQuantity(store.slug, lineKey(product.id), inCart - 1)}
      onIncrement={addOne}
      canIncrement={inCart < stock}
      decrementLabel={t('decrease', { name: product.name })}
      incrementLabel={t('increase', { name: product.name })}
    />
  ) : (
    <Button className="w-full" onClick={addOne}>
      <Plus className="size-4" strokeWidth={2.6} />
      {t('add')}
    </Button>
  );

  return (
    <article
      className={cn(
        'flex gap-3 rounded-2xl border border-divider bg-surface p-3 transition-colors hover:border-border',
        isList ? 'flex-row items-center' : 'flex-col',
      )}
    >
      <Link
        href={href}
        className={cn('relative block shrink-0', isList ? 'w-28 sm:w-36' : 'w-full')}
      >
        <ProductPhoto
          src={imageOf(product)}
          alt={product.name}
          priority={priority}
          sizes={isList ? '144px' : '(min-width: 1280px) 20vw, (min-width: 768px) 30vw, 50vw'}
        />
        <span className="absolute top-2 left-2 flex flex-col items-start gap-1">
          {soldOut ? (
            <StatusPill tone="error">{t('soldOut')}</StatusPill>
          ) : stock <= LOW_STOCK_THRESHOLD ? (
            <StatusPill tone="warning">{t('lastUnits', { count: stock })}</StatusPill>
          ) : null}
        </span>
        {withVariants && !isList && (
          <span className="absolute bottom-2 left-2 inline-flex items-center gap-1 rounded-full bg-surface/95 px-2.5 py-1 text-xs font-semibold text-ink-soft shadow-sm">
            <Layers className="size-3.5" />
            {t('optionCount', { count: product.variants.length })}
          </span>
        )}
      </Link>

      <div className="flex min-w-0 flex-1 flex-col gap-3">
        <Link href={href} className="flex flex-col gap-1">
          <h3 className="line-clamp-2 text-base font-semibold leading-snug">{product.name}</h3>
          <span className="text-xl font-bold tracking-tight tabular-nums">
            {formatMoney(product.price)}
          </span>
          {withVariants && isList && (
            <span className="text-[13px] text-secondary">
              {t('optionCount', { count: product.variants.length })}
            </span>
          )}
        </Link>
        <div className="mt-auto flex flex-col gap-2">
          {withVariants && inCart > 0 && (
            <StatusPill tone="info" className="self-start">
              {productText('inCart', { count: inCart })}
            </StatusPill>
          )}
          {action}
        </div>
      </div>

      {withVariants && (
        <QuickPickDialog product={product} open={picking} onOpenChange={setPicking} />
      )}
    </article>
  );
}
