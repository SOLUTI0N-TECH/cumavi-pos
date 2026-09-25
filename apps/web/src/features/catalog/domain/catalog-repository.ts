import type { Product, Store } from './entities';

/**
 * Read access to the stores' public catalogs. Implemented with mock data
 * while there is no backend; the API client will implement the same
 * contract, so pages and components stay untouched.
 */
export interface CatalogRepository {
  listStores(): Promise<Store[]>;
  getStore(slug: string): Promise<Store | undefined>;
  /** Products of a store, newest first. */
  listProducts(storeId: string): Promise<Product[]>;
  getProduct(storeId: string, productSlug: string): Promise<Product | undefined>;
}
