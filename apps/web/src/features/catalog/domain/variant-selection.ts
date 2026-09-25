import type { Product, ProductVariant } from './entities';

/** What the customer picked so far: one value per option. */
export type Selection = Record<string, string>;

export type ValueState =
  /** Has stock with the rest of the selection. */
  | 'available'
  /** Has stock, but not with the other values already picked. */
  | 'unavailableWithSelection'
  /** No stock in any combination. */
  | 'soldOut';

/**
 * Starts with the options that have a single value already picked, so a
 * product that only varies in size asks for the size alone.
 */
export function initialSelection(product: Product): Selection {
  const selection: Selection = {};
  for (const option of product.options) {
    if (option.values.length === 1) selection[option.name] = option.values[0];
  }
  return selection;
}

function matches(variant: ProductVariant, selection: Selection): boolean {
  return Object.entries(selection).every(
    ([name, value]) => variant.optionValues[name] === value,
  );
}

export function valueState(
  product: Product,
  selection: Selection,
  optionName: string,
  value: string,
): ValueState {
  const withValue = product.variants.filter(
    (variant) => variant.optionValues[optionName] === value && variant.stock > 0,
  );
  if (withValue.length === 0) return 'soldOut';
  const others: Selection = { ...selection };
  delete others[optionName];
  return withValue.some((variant) => matches(variant, others))
    ? 'available'
    : 'unavailableWithSelection';
}

/**
 * Picks [value] for [optionName]. Values picked for other options stay only
 * if a variant with stock still has them, so the customer never gets stuck.
 */
export function selectValue(
  product: Product,
  selection: Selection,
  optionName: string,
  value: string,
): Selection {
  const next: Selection = { [optionName]: value };
  for (const option of product.options) {
    const picked = selection[option.name];
    if (option.name === optionName || picked === undefined) continue;
    const candidate = { ...next, [option.name]: picked };
    const stillSellable = product.variants.some(
      (variant) => variant.stock > 0 && matches(variant, candidate),
    );
    if (stillSellable) next[option.name] = picked;
  }
  return next;
}

/** The variant of a complete selection, or `undefined` while incomplete. */
export function selectedVariant(
  product: Product,
  selection: Selection,
): ProductVariant | undefined {
  if (product.options.some((option) => selection[option.name] === undefined)) {
    return undefined;
  }
  return product.variants.find((variant) => matches(variant, selection));
}

/** First option still missing a value, to prompt for it. */
export function missingOption(
  product: Product,
  selection: Selection,
): string | undefined {
  return product.options.find((option) => selection[option.name] === undefined)
    ?.name;
}

/**
 * Photo for a partial selection: the one every matching variant shares
 * (picking `Azul` shows the blue shoe before the size is chosen).
 */
export function selectionImageId(
  product: Product,
  selection: Selection,
): string | undefined {
  const matching = product.variants.filter((variant) =>
    matches(variant, selection),
  );
  const ids = new Set(matching.map((variant) => variant.imageId));
  return ids.size === 1 ? [...ids][0] : undefined;
}
