import type { CatalogRepository } from '../domain/catalog-repository';
import { MockCatalogRepository } from './mock-catalog-repository';

let repository: CatalogRepository | undefined;

/**
 * The catalog source for server components. The only line to change when
 * the backend arrives: return the API implementation instead.
 */
export function catalogRepository(): CatalogRepository {
  repository ??= new MockCatalogRepository();
  return repository;
}
