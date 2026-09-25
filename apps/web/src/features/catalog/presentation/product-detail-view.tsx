'use client';

import { ArrowLeft } from 'lucide-react';
import Link from 'next/link';
import { useTranslations } from 'next-intl';
import { useState } from 'react';

import { cn } from '@/shared/lib/cn';
import { formatMoney } from '@/shared/lib/money';
import { ProductPhoto } from '@/shared/ui/product-photo';
import type { Product } from '../domain/entities';
import { PurchasePanel } from './purchase-panel';
import { useStore } from './store-context';

/** Product page: gallery, price, options and description. */
export function ProductDetailView({
  product,
  categoryName,
}: {
  product: Product;
  categoryName: string;
}) {
  const t = useTranslations('product');
  const store = useStore();
  const [activeId, setActiveId] = useState(product.images[0]?.id);
  const activeIndex = Math.max(
    product.images.findIndex((image) => image.id === activeId),
    0,
  );
  const active = product.images[activeIndex];

  return (
    <div className="flex flex-col gap-6">
      <Link
        href={`/${store.slug}`}
        className="inline-flex w-fit items-center gap-2 rounded-full border border-divider bg-surface px-4 py-2.5 text-[15px] font-semibold transition hover:border-ink hover:bg-ink hover:text-white"
      >
        <ArrowLeft className="size-4" />
        {t('back')}
      </Link>

      <div className="grid gap-6 lg:grid-cols-[minmax(0,1.1fr)_minmax(0,1fr)] lg:gap-10">
        <section className="flex flex-col gap-3">
          {active && (
            <ProductPhoto
              src={active.src}
              alt={t('photo', {
                current: activeIndex + 1,
                total: product.images.length,
                name: product.name,
              })}
              sizes="(min-width: 1024px) 50vw, 100vw"
              priority
              className="rounded-3xl"
            />
          )}
          {product.images.length > 1 && (
            <div className="flex gap-2">
              {product.images.map((image, index) => (
                <button
                  key={image.id}
                  type="button"
                  onClick={() => setActiveId(image.id)}
                  aria-label={t('showPhoto', { current: index + 1 })}
                  aria-pressed={image.id === active?.id}
                  className={cn(
                    'w-20 rounded-xl border-2 p-0.5 transition',
                    image.id === active?.id ? 'border-ink' : 'border-transparent hover:border-border',
                  )}
                >
                  <ProductPhoto src={image.src} alt="" sizes="80px" className="rounded-lg" />
                </button>
              ))}
            </div>
          )}
        </section>

        <section className="flex flex-col gap-6 rounded-3xl border border-divider bg-surface p-5 sm:p-7">
          <div className="flex flex-col gap-2">
            <span className="text-[13px] font-semibold tracking-wide text-secondary uppercase">
              {categoryName}
            </span>
            <h1 className="text-3xl font-bold tracking-tight text-balance sm:text-4xl">
              {product.name}
            </h1>
            <span className="text-3xl font-bold tracking-tight tabular-nums">
              {formatMoney(product.price)}
            </span>
          </div>

          <PurchasePanel
            product={product}
            onImageChange={(imageId) => imageId && setActiveId(imageId)}
          />

          {product.description && (
            <div className="flex flex-col gap-2 border-t border-divider pt-5">
              <h2 className="text-base font-semibold">{t('description')}</h2>
              <p className="text-base leading-relaxed text-ink-soft">{product.description}</p>
            </div>
          )}
        </section>
      </div>
    </div>
  );
}
