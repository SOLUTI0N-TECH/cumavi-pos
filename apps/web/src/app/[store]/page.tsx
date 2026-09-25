import type { Metadata } from 'next';
import { getTranslations } from 'next-intl/server';

import { catalogRepository } from '@/features/catalog/data';
import { imageOf } from '@/features/catalog/domain/product-rules';
import { CatalogView } from '@/features/catalog/presentation/catalog-view';

export async function generateMetadata({ params }: PageProps<'/[store]'>): Promise<Metadata> {
  const { store: slug } = await params;
  const repository = catalogRepository();
  const store = await repository.getStore(slug);
  if (!store) return {};
  const [first] = await repository.listProducts(store.id);
  const t = await getTranslations('metadata');
  const title = t('storeTitle', { store: store.name });
  const description = t('storeDescription', { store: store.name, tagline: store.tagline });

  return {
    title,
    description,
    openGraph: {
      title,
      description,
      type: 'website',
      images: first ? [imageOf(first)] : undefined,
    },
  };
}

/** The store's catalog: search, categories and products. */
export default function StoreCatalogPage() {
  return <CatalogView />;
}
