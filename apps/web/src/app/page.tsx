import { ArrowRight, MapPin } from 'lucide-react';
import Link from 'next/link';
import { getTranslations } from 'next-intl/server';

import { catalogRepository } from '@/features/catalog/data';
import { imageOf } from '@/features/catalog/domain/product-rules';
import { StoreStatusPill } from '@/features/catalog/presentation/store-status-pill';
import { ProductPhoto } from '@/shared/ui/product-photo';

/**
 * Store directory: the entry point that will grow into the city-wide
 * catalog of stores (search across stores, map by zone).
 */
export default async function DirectoryPage() {
  const t = await getTranslations('directory');
  const repository = catalogRepository();
  const stores = await repository.listStores();
  const catalogs = await Promise.all(
    stores.map(async (store) => ({ store, products: await repository.listProducts(store.id) })),
  );

  return (
    <main className="mx-auto flex max-w-[1400px] flex-col gap-8 px-4 py-10 sm:px-6 sm:py-14">
      <header className="flex max-w-2xl flex-col gap-3">
        <span className="text-[13px] font-semibold tracking-wide text-secondary uppercase">
          {t('eyebrow')}
        </span>
        <h1 className="text-4xl font-bold tracking-tight sm:text-5xl">{t('title')}</h1>
        <p className="text-lg text-secondary">{t('subtitle')}</p>
      </header>

      <ul className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {catalogs.map(({ store, products }) => (
          <li key={store.id}>
            <Link
              href={`/${store.slug}`}
              className="group flex h-full flex-col gap-5 rounded-3xl border border-divider bg-surface p-5 transition hover:border-ink"
            >
              <div className="grid grid-cols-3 gap-2">
                {products.slice(0, 3).map((product) => (
                  <ProductPhoto
                    key={product.id}
                    src={imageOf(product)}
                    alt={product.name}
                    sizes="(min-width: 1280px) 10vw, 30vw"
                  />
                ))}
              </div>
              <div className="flex flex-col gap-2">
                <div className="flex items-start justify-between gap-3">
                  <h2 className="text-2xl font-bold tracking-tight">{store.name}</h2>
                  <StoreStatusPill store={store} detailed={false} />
                </div>
                <p className="text-base text-ink-soft">{store.tagline}</p>
                <p className="flex items-center gap-1.5 text-[15px] text-secondary">
                  <MapPin className="size-4" />
                  {store.zone}, {store.city} · {t('productCount', { count: products.length })}
                </p>
              </div>
              <span className="mt-auto inline-flex items-center gap-2 text-base font-semibold">
                {t('viewCatalog')}
                <ArrowRight className="size-4 transition group-hover:translate-x-1" />
              </span>
            </Link>
          </li>
        ))}
      </ul>
    </main>
  );
}
