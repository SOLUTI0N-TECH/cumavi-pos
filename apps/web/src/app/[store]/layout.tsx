import { notFound } from 'next/navigation';
import { getTranslations } from 'next-intl/server';

import { catalogRepository } from '@/features/catalog/data';
import { StoreProvider } from '@/features/catalog/presentation/store-context';
import { StoreHeader } from '@/features/catalog/presentation/store-header';

export async function generateStaticParams() {
  const stores = await catalogRepository().listStores();
  return stores.map((store) => ({ store: store.slug }));
}

/** Everything under `/<store>`: header, catalog data for the client, footer. */
export default async function StoreLayout({ children, params }: LayoutProps<'/[store]'>) {
  const { store: slug } = await params;
  const repository = catalogRepository();
  const store = await repository.getStore(slug);
  if (!store) notFound();
  const products = await repository.listProducts(store.id);
  const t = await getTranslations('store');

  return (
    <StoreProvider store={store} products={products}>
      <div className="flex min-h-dvh flex-col">
        <StoreHeader store={store} />
        <main className="mx-auto w-full max-w-[1400px] flex-1 px-4 pt-6 pb-16 sm:px-6 sm:pt-8">
          {children}
        </main>
        <footer className="border-t border-divider bg-surface">
          <div className="mx-auto flex max-w-[1400px] flex-wrap items-center justify-center gap-x-3 gap-y-1 px-4 py-5 text-[13px] text-secondary">
            <span>{t('footerNoAccount')}</span>
            <span aria-hidden>·</span>
            <span>{t('footerWhatsApp')}</span>
            <span aria-hidden>·</span>
            <span>{t('footerPayment')}</span>
            <span className="basis-full text-center text-placeholder">{t('poweredBy')}</span>
          </div>
        </footer>
      </div>
    </StoreProvider>
  );
}
