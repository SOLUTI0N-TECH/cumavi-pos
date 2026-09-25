import rawCatalog from '@cumavi-pos/mock-catalog/catalog.json';

import type { CatalogRepository } from '../domain/catalog-repository';
import type {
  Fulfillment,
  PaymentMethod,
  Product,
  ProductVariant,
  Store,
  VariantOption,
} from '../domain/entities';

/** Shape of packages/mock-catalog/catalog.json (the POS seed). */
interface RawProduct {
  id: string;
  slug: string;
  name: string;
  categoryId: string;
  price: number;
  description: string;
  images: { id: string; file: string }[];
  createdDaysAgo: number;
  options: VariantOption[];
  variants: ProductVariant[];
  stock?: number;
}

type RawStore = Omit<
  Store,
  'timeZone' | 'paymentMethods' | 'fulfillment'
> & {
  timezone: string;
  paymentMethods: string[];
  fulfillment: string[];
  products: RawProduct[];
};

/** Photos are copied to /public/mock-catalog by scripts/sync-mock-assets. */
const IMAGE_BASE = '/mock-catalog';
const DAY_MS = 24 * 60 * 60 * 1000;

function toStore(raw: RawStore): Store {
  return {
    id: raw.id,
    slug: raw.slug,
    name: raw.name,
    tagline: raw.tagline,
    department: raw.department,
    city: raw.city,
    zone: raw.zone,
    address: raw.address,
    location: raw.location,
    whatsapp: raw.whatsapp,
    timeZone: raw.timezone,
    openingHours: raw.openingHours,
    paymentMethods: raw.paymentMethods as PaymentMethod[],
    fulfillment: raw.fulfillment as Fulfillment[],
    categories: raw.categories,
  };
}

function toProduct(storeId: string, raw: RawProduct, now: number): Product {
  return {
    id: raw.id,
    storeId,
    slug: raw.slug,
    name: raw.name,
    categoryId: raw.categoryId,
    price: raw.price,
    description: raw.description,
    images: raw.images.map((image) => ({
      id: image.id,
      src: `${IMAGE_BASE}/${image.file}`,
    })),
    createdAt: new Date(now - raw.createdDaysAgo * DAY_MS).toISOString(),
    options: raw.options,
    variants: raw.variants,
    stock: raw.stock ?? 0,
  };
}

/**
 * Catalog read from the shared mock JSON, the same data the POS app seeds.
 * Stock is a snapshot: sales made in the app don't reach the web until the
 * backend connects both.
 */
export class MockCatalogRepository implements CatalogRepository {
  private readonly stores: Store[];
  private readonly products: Map<string, Product[]>;

  constructor(now: number = Date.now()) {
    const raws = (rawCatalog as unknown as { stores: RawStore[] }).stores;
    this.stores = raws.map(toStore);
    this.products = new Map(
      raws.map((raw) => [
        raw.id,
        raw.products
          .map((product) => toProduct(raw.id, product, now))
          .sort((a, b) => b.createdAt.localeCompare(a.createdAt)),
      ]),
    );
  }

  async listStores(): Promise<Store[]> {
    return this.stores;
  }

  async getStore(slug: string): Promise<Store | undefined> {
    return this.stores.find((store) => store.slug === slug);
  }

  async listProducts(storeId: string): Promise<Product[]> {
    return this.products.get(storeId) ?? [];
  }

  async getProduct(
    storeId: string,
    productSlug: string,
  ): Promise<Product | undefined> {
    return this.products
      .get(storeId)
      ?.find((product) => product.slug === productSlug);
  }
}
