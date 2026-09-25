import type { Product, ProductVariant } from './entities';

/** Same threshold as the POS (`StockRules.lowStockThreshold`). */
export const LOW_STOCK_THRESHOLD = 5;

export type StockLevel = 'healthy' | 'low' | 'outOfStock';

export function stockLevelOf(quantity: number): StockLevel {
  if (quantity <= 0) return 'outOfStock';
  if (quantity <= LOW_STOCK_THRESHOLD) return 'low';
  return 'healthy';
}

export function hasVariants(product: Product): boolean {
  return product.variants.length > 0;
}

/** Units available: the sum of the variants when the product has them. */
export function totalStock(product: Product): number {
  return hasVariants(product)
    ? product.variants.reduce((total, variant) => total + variant.stock, 0)
    : product.stock;
}

export function isAvailable(product: Product): boolean {
  return totalStock(product) > 0;
}

/** `Rojo · 40` */
export function variantLabel(variant: ProductVariant): string {
  return Object.values(variant.optionValues).join(' · ');
}

export function findVariant(
  product: Product,
  variantId: string | undefined,
): ProductVariant | undefined {
  return variantId === undefined
    ? undefined
    : product.variants.find((variant) => variant.id === variantId);
}

/** Photo of [variant], falling back to the main one. */
export function imageOf(product: Product, variant?: ProductVariant): string {
  const own = variant?.imageId
    ? product.images.find((image) => image.id === variant.imageId)
    : undefined;
  return (own ?? product.images[0])?.src ?? '';
}
