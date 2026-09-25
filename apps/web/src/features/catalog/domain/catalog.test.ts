import { describe, expect, it } from 'vitest';

import { MockCatalogRepository } from '../data/mock-catalog-repository';
import type { Product, Store } from './entities';
import { imageOf, totalStock, variantLabel } from './product-rules';
import { storeStatus } from './store-hours';
import {
  initialSelection,
  missingOption,
  selectValue,
  selectedVariant,
  selectionImageId,
  valueState,
} from './variant-selection';

const repository = new MockCatalogRepository(Date.parse('2026-09-24T12:00:00Z'));

async function product(slug: string): Promise<Product> {
  const store = (await repository.getStore('illimani-store'))!;
  return (await repository.getProduct(store.id, slug))!;
}

describe('MockCatalogRepository', () => {
  it('serves the same catalog as the POS seed, without cost prices', async () => {
    const store = (await repository.getStore('illimani-store'))!;
    const products = await repository.listProducts(store.id);

    expect(products).toHaveLength(14);
    expect(products[0].name).toBe('Gorra trucker blanca'); // newest first
    expect(JSON.stringify(products)).not.toContain('cost');
  });

  it('adds up the stock of the variants', async () => {
    const sneakers = await product('zapatillas-urbanas');

    expect(sneakers.variants).toHaveLength(15);
    expect(totalStock(sneakers)).toBe(12);
    expect(imageOf(sneakers)).toBe('/mock-catalog/sneakers_red.jpg');
  });

  it('returns nothing for unknown stores and products', async () => {
    expect(await repository.getStore('no-existe')).toBeUndefined();
    expect(await repository.getProduct('store-illimani', 'no-existe')).toBeUndefined();
  });
});

describe('variant selection', () => {
  it('starts with the options that have a single value', async () => {
    const bag = await product('cartera-de-cuero');

    expect(initialSelection(bag)).toEqual({});
    expect(missingOption(bag, {})).toBe('Color');
  });

  it('picks Azul + 40 and shows the blue photo', async () => {
    const sneakers = await product('zapatillas-urbanas');
    let selection = selectValue(sneakers, {}, 'Color', 'Azul');

    expect(selectionImageId(sneakers, selection)).toBe('p-001-img-2');
    expect(valueState(sneakers, selection, 'Talla', '38')).toBe('unavailableWithSelection');
    expect(valueState(sneakers, selection, 'Talla', '42')).toBe('soldOut');

    selection = selectValue(sneakers, selection, 'Talla', '40');
    const variant = selectedVariant(sneakers, selection)!;

    expect(variantLabel(variant)).toBe('Azul · 40');
    expect(variant.stock).toBe(2);
  });

  it('drops a previous pick that has no stock with the new value', async () => {
    const sneakers = await product('zapatillas-urbanas');
    const selection = selectValue(
      sneakers,
      { Color: 'Rojo', Talla: '41' },
      'Color',
      'Negro',
    );

    // Negro only comes in 40.
    expect(selection).toEqual({ Color: 'Negro' });
  });
});

describe('storeStatus', () => {
  const store = {
    timeZone: 'America/La_Paz',
    openingHours: [1, 2, 3, 4, 5, 6].map((day) => ({ day, opens: '09:00', closes: '20:00' })),
  } as Store;

  it('is open on a weekday afternoon in La Paz', () => {
    // Wednesday 15:00 in La Paz (UTC−4).
    expect(storeStatus(store, new Date('2026-09-23T19:00:00Z'))).toEqual({
      open: true,
      closes: '20:00',
    });
  });

  it('is closed on Sunday and opens on Monday', () => {
    expect(storeStatus(store, new Date('2026-09-27T16:00:00Z'))).toEqual({
      open: false,
      opensAt: { day: 1, time: '09:00' },
    });
  });

  it('opens later the same day before opening time', () => {
    expect(storeStatus(store, new Date('2026-09-23T11:30:00Z'))).toEqual({
      open: false,
      opensAt: { day: 3, time: '09:00' },
    });
  });
});
