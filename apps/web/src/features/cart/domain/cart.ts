import type { Product, ProductVariant } from '@/features/catalog/domain/entities';
import {
  findVariant,
  hasVariants,
  totalStock,
} from '@/features/catalog/domain/product-rules';

/**
 * What the cart stores: references and quantities only. Names, prices and
 * photos are read from the catalog when showing it, so they are never stale.
 */
export interface CartItem {
  productId: string;
  variantId?: string;
  quantity: number;
}

/** A cart item joined with its catalog data, ready to show. */
export interface CartLine {
  key: string;
  product: Product;
  variant?: ProductVariant;
  quantity: number;
  /** Units the customer can have: the variant's stock when there is one. */
  available: number;
  total: number;
}

/** Same key as the POS cart: `p-001` or `p-001#azul/40`. */
export function lineKey(productId: string, variantId?: string): string {
  return variantId === undefined ? productId : `${productId}#${variantId}`;
}

export function itemKey(item: CartItem): string {
  return lineKey(item.productId, item.variantId);
}

export function availableStock(product: Product, variant?: ProductVariant): number {
  return variant ? variant.stock : totalStock(product);
}

/**
 * Adds [quantity] units, never beyond the stock. A product with variants
 * needs one: its stock lives in each variant.
 */
export function addToCart(
  items: CartItem[],
  product: Product,
  variant: ProductVariant | undefined,
  quantity = 1,
): CartItem[] {
  if (hasVariants(product) && !variant) return items;
  const key = lineKey(product.id, variant?.id);
  const current = items.find((item) => itemKey(item) === key);
  const target = Math.min(
    (current?.quantity ?? 0) + quantity,
    availableStock(product, variant),
  );
  if (target <= (current?.quantity ?? 0)) return items;
  if (!current) {
    return [...items, { productId: product.id, variantId: variant?.id, quantity: target }];
  }
  return items.map((item) =>
    itemKey(item) === key ? { ...item, quantity: target } : item,
  );
}

/** Sets the quantity of a line; 0 or less removes it. */
export function setQuantity(
  items: CartItem[],
  key: string,
  quantity: number,
): CartItem[] {
  if (quantity <= 0) return items.filter((item) => itemKey(item) !== key);
  return items.map((item) =>
    itemKey(item) === key ? { ...item, quantity } : item,
  );
}

/**
 * Joins the items with the catalog. Items whose product or variant no
 * longer exists are dropped, and quantities are capped to today's stock.
 */
export function resolveLines(items: CartItem[], products: Product[]): CartLine[] {
  const byId = new Map(products.map((product) => [product.id, product]));
  const lines: CartLine[] = [];
  for (const item of items) {
    const product = byId.get(item.productId);
    if (!product) continue;
    const variant = findVariant(product, item.variantId);
    if (item.variantId !== undefined && !variant) continue;
    const available = availableStock(product, variant);
    const quantity = Math.min(item.quantity, available);
    if (quantity <= 0) continue;
    lines.push({
      key: itemKey(item),
      product,
      variant,
      quantity,
      available,
      total: product.price * quantity,
    });
  }
  return lines;
}

export function cartTotals(lines: CartLine[]): { units: number; total: number } {
  return lines.reduce(
    (totals, line) => ({
      units: totals.units + line.quantity,
      total: totals.total + line.total,
    }),
    { units: 0, total: 0 },
  );
}

/** Units of a product in the cart, all its variants together. */
export function quantityOfProduct(items: CartItem[], productId: string): number {
  return items
    .filter((item) => item.productId === productId)
    .reduce((total, item) => total + item.quantity, 0);
}
