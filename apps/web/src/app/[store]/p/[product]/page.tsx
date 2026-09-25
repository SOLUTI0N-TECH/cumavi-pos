import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { getTranslations } from 'next-intl/server';

import { catalogRepository } from '@/features/catalog/data';
import { imageOf } from '@/features/catalog/domain/product-rules';
import { ProductDetailView } from '@/features/catalog/presentation/product-detail-view';
import { formatMoney } from '@/shared/lib/money';

export async function generateStaticParams() {
  const repository = catalogRepository();
  const stores = await repository.listStores();
  const params = await Promise.all(
    stores.map(async (store) =>
      (await repository.listProducts(store.id)).map((product) => ({
        store: store.slug,
        product: product.slug,
      })),
    ),
  );
  return params.flat();
}

async function load(params: PageProps<'/[store]/p/[product]'>['params']) {
  const { store: storeSlug, product: productSlug } = await params;
  const repository = catalogRepository();
  const store = await repository.getStore(storeSlug);
  const product = store && (await repository.getProduct(store.id, productSlug));
  return store && product ? { store, product } : undefined;
}

/** Link previews (WhatsApp, Facebook) show the product photo and price. */
export async function generateMetadata({
  params,
}: PageProps<'/[store]/p/[product]'>): Promise<Metadata> {
  const found = await load(params);
  if (!found) return {};
  const { store, product } = found;
  const t = await getTranslations('metadata');
  const title = `${product.name} · ${store.name}`;
  const description = t('productDescription', {
    price: formatMoney(product.price),
    store: store.name,
    description: product.description,
  });

  return {
    title,
    description,
    openGraph: { title, description, type: 'website', images: [imageOf(product)] },
  };
}

export default async function ProductPage({ params }: PageProps<'/[store]/p/[product]'>) {
  const found = await load(params);
  if (!found) notFound();
  const { store, product } = found;
  const categoryName =
    store.categories.find((category) => category.id === product.categoryId)?.name ?? '';

  return <ProductDetailView product={product} categoryName={categoryName} />;
}
