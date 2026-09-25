import { describe, expect, it } from 'vitest';

import type { Product } from '@/features/catalog/domain/entities';
import { addToCart, cartTotals, lineKey, resolveLines, setQuantity } from './cart';

function build(overrides: Partial<Product> = {}): Product {
  return {
    id: 'p-1',
    storeId: 's-1',
    slug: 'polera',
    name: 'Polera básica',
    categoryId: 'clothing',
    price: 75,
    description: '',
    images: [{ id: 'img-1', src: '/negra.jpg' }],
    createdAt: '2026-09-01T00:00:00Z',
    options: [],
    variants: [],
    stock: 3,
    ...overrides,
  };
}

const tee = build({
  options: [
    { name: 'Color', values: ['Negra', 'Gris'] },
    { name: 'Talla', values: ['M'] },
  ],
  variants: [
    { id: 'negra/m', optionValues: { Color: 'Negra', Talla: 'M' }, stock: 2 },
    { id: 'gris/m', optionValues: { Color: 'Gris', Talla: 'M' }, stock: 1 },
  ],
});

describe('cart', () => {
  it('groups units of a simple product and caps them at its stock', () => {
    const product = build();
    let items = addToCart([], product, undefined);
    items = addToCart(items, product, undefined, 5);

    expect(items).toEqual([{ productId: 'p-1', variantId: undefined, quantity: 3 }]);
  });

  it('needs a variant for products that have them', () => {
    expect(addToCart([], tee, undefined)).toEqual([]);
  });

  it('keeps each variant in its own line with its own stock', () => {
    let items = addToCart([], tee, tee.variants[0], 2);
    items = addToCart(items, tee, tee.variants[1], 4);
    const lines = resolveLines(items, [tee]);

    expect(lines.map((line) => [line.key, line.quantity])).toEqual([
      ['p-1#negra/m', 2],
      ['p-1#gris/m', 1],
    ]);
    expect(cartTotals(lines)).toEqual({ units: 3, total: 225 });
  });

  it('removes a line when its quantity reaches zero', () => {
    const items = addToCart([], tee, tee.variants[0]);

    expect(setQuantity(items, lineKey('p-1', 'negra/m'), 0)).toEqual([]);
  });

  it('drops lines whose product disappeared and caps to current stock', () => {
    const items = [
      { productId: 'p-1', variantId: 'negra/m', quantity: 5 },
      { productId: 'p-9', quantity: 1 },
    ];

    const lines = resolveLines(items, [tee]);
    expect(lines).toHaveLength(1);
    expect(lines[0].quantity).toBe(2);
  });
});
