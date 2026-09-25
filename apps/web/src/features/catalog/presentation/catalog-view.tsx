'use client';

import { LayoutGrid, List, Search, SearchX } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { useMemo, useState } from 'react';

import { cn } from '@/shared/lib/cn';
import { Chip } from '@/shared/ui/chip';
import { EmptyState } from '@/shared/ui/empty-state';
import type { Product } from '../domain/entities';
import { variantLabel } from '../domain/product-rules';
import { type CatalogLayout, ProductCard } from './product-card';
import { useStore, useStoreProducts } from './store-context';

/** Lowercase without accents: `Café` matches `cafe`. */
function normalize(text: string): string {
  return text
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '')
    .toLowerCase();
}

function matchesQuery(product: Product, categoryName: string, query: string): boolean {
  if (!query) return true;
  const haystack = [
    product.name,
    categoryName,
    ...product.variants.map(variantLabel),
  ].map(normalize);
  return query
    .split(/\s+/)
    .every((word) => haystack.some((text) => text.includes(word)));
}

/** Search, categories and the product grid of a store. */
export function CatalogView() {
  const t = useTranslations('catalog');
  const store = useStore();
  const products = useStoreProducts();
  const [query, setQuery] = useState('');
  const [categoryId, setCategoryId] = useState<string | null>(null);
  const [layout, setLayout] = useState<CatalogLayout>('grid');

  const categoryNames = useMemo(
    () => new Map(store.categories.map((category) => [category.id, category.name])),
    [store.categories],
  );
  const normalizedQuery = normalize(query.trim());

  const searched = products.filter((product) =>
    matchesQuery(product, categoryNames.get(product.categoryId) ?? '', normalizedQuery),
  );
  const shown = searched.filter(
    (product) => categoryId === null || product.categoryId === categoryId,
  );
  const countIn = (id: string | null) =>
    id === null
      ? searched.length
      : searched.filter((product) => product.categoryId === id).length;

  return (
    <div className="flex flex-col gap-7">
      <section className="flex flex-col gap-5 rounded-3xl border border-divider bg-surface p-4 sm:p-5">
        <label className="flex h-14 items-center gap-3 rounded-xl bg-background px-4">
          <Search className="size-5 shrink-0 text-secondary" />
          <span className="sr-only">{t('searchLabel')}</span>
          <input
            type="search"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder={t('searchPlaceholder')}
            className="min-w-0 flex-1 bg-transparent text-base font-medium outline-none"
          />
          {query && (
            <button
              type="button"
              onClick={() => setQuery('')}
              className="rounded-full bg-divider px-3 py-1 text-[13px] font-semibold text-ink-soft hover:bg-border-soft"
            >
              {t('clearSearch')}
            </button>
          )}
        </label>
        <div className="flex flex-col gap-2.5">
          <span className="text-[13px] font-semibold tracking-wide text-secondary uppercase">
            {t('categories')}
          </span>
          <div className="scroll-row -mx-1 flex gap-2 overflow-x-auto px-1 pb-1">
            {[null, ...store.categories.map((category) => category.id)].map((id) => (
              <Chip
                key={id ?? 'all'}
                selected={categoryId === id}
                onClick={() => setCategoryId(id)}
                trailing={
                  <span className="font-medium opacity-60 tabular-nums">{countIn(id)}</span>
                }
              >
                {id === null ? t('allCategories') : categoryNames.get(id)}
              </Chip>
            ))}
          </div>
        </div>
      </section>

      <section className="flex flex-col gap-4" aria-live="polite">
        <div className="flex items-end justify-between gap-4">
          <div className="flex flex-col gap-0.5">
            <h1 className="text-2xl font-bold tracking-tight sm:text-3xl">{t('title')}</h1>
            <span className="text-[15px] text-secondary">
              {t('productCount', { count: shown.length })}
            </span>
          </div>
          <div className="flex gap-1 rounded-full bg-surface p-1 shadow-sm">
            {(['grid', 'list'] as const).map((option) => {
              const Icon = option === 'grid' ? LayoutGrid : List;
              return (
                <button
                  key={option}
                  type="button"
                  onClick={() => setLayout(option)}
                  aria-pressed={layout === option}
                  aria-label={option === 'grid' ? t('gridView') : t('listView')}
                  className={cn(
                    'flex size-10 items-center justify-center rounded-full transition',
                    layout === option ? 'bg-ink text-white' : 'text-secondary hover:text-primary',
                  )}
                >
                  <Icon className="size-[18px]" />
                </button>
              );
            })}
          </div>
        </div>

        {shown.length === 0 ? (
          <EmptyState
            dashed
            icon={<SearchX className="size-7" />}
            title={t('emptyTitle')}
            message={t('emptyMessage')}
          />
        ) : (
          <div
            className={cn(
              'grid gap-3 sm:gap-4',
              layout === 'grid'
                ? 'grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5'
                : 'grid-cols-1 lg:grid-cols-2',
            )}
          >
            {shown.map((product, index) => (
              <ProductCard
                key={product.id}
                product={product}
                layout={layout}
                priority={index < 4}
              />
            ))}
          </div>
        )}
      </section>
    </div>
  );
}
