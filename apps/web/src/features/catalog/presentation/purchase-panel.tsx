'use client';

import { useTranslations } from 'next-intl';
import { useState } from 'react';
import { toast } from 'sonner';

import { lineKey } from '@/features/cart/domain/cart';
import { useCartHydration, useCartItems, useCartStore } from '@/features/cart/state/cart-store';
import { formatMoney } from '@/shared/lib/money';
import { Button } from '@/shared/ui/button';
import { Chip } from '@/shared/ui/chip';
import { QuantityStepper } from '@/shared/ui/quantity-stepper';
import { StatusPill } from '@/shared/ui/status-pill';
import type { Product } from '../domain/entities';
import { LOW_STOCK_THRESHOLD, hasVariants, variantLabel } from '../domain/product-rules';
import {
  initialSelection,
  missingOption,
  type Selection,
  selectValue,
  selectedVariant,
  selectionImageId,
  valueState,
} from '../domain/variant-selection';
import { useStore } from './store-context';

export interface PurchasePanelProps {
  product: Product;
  /** Photo matching the current selection, so the page can show it. */
  onImageChange?: (imageId: string | undefined) => void;
  onAdded?: () => void;
}

/**
 * Options, stock and quantity of a product, and the button that adds it to
 * the order. Works for simple products too (no options to pick).
 */
export function PurchasePanel({ product, onImageChange, onAdded }: PurchasePanelProps) {
  const t = useTranslations('product');
  const store = useStore();
  const hydrated = useCartHydration();
  const items = useCartItems(store.slug);
  const add = useCartStore((state) => state.add);

  const [selection, setSelection] = useState<Selection>(() => initialSelection(product));
  const [quantity, setQuantity] = useState(1);

  const variant = selectedVariant(product, selection);
  const missing = missingOption(product, selection);
  const complete = missing === undefined;
  const stock = hasVariants(product) ? (variant?.stock ?? 0) : product.stock;
  const key = lineKey(product.id, variant?.id);
  const inCart = hydrated ? (items.find((item) => lineKey(item.productId, item.variantId) === key)?.quantity ?? 0) : 0;
  const remaining = Math.max(stock - inCart, 0);
  const effectiveQuantity = Math.min(Math.max(quantity, 1), Math.max(remaining, 1));
  const canAdd = complete && remaining > 0;

  function choose(optionName: string, value: string) {
    const next = selectValue(product, selection, optionName, value);
    setSelection(next);
    setQuantity(1);
    onImageChange?.(selectionImageId(product, next));
  }

  function addToOrder() {
    if (!canAdd) return;
    const added = add(store.slug, product, variant, effectiveQuantity);
    if (!added) return;
    const name = variant ? `${product.name} (${variantLabel(variant)})` : product.name;
    toast.success(t('added', { name }));
    setQuantity(1);
    onAdded?.();
  }

  return (
    <div className="flex flex-col gap-5">
      {product.options.map((option) => (
        <fieldset key={option.name} className="flex flex-col gap-2.5">
          <legend className="mb-2.5 text-[15px] font-semibold">
            {option.name}
            {selection[option.name] && (
              <span className="font-normal text-secondary"> · {selection[option.name]}</span>
            )}
          </legend>
          <div className="flex flex-wrap gap-2">
            {option.values.map((value) => {
              const state = valueState(product, selection, option.name, value);
              return (
                <Chip
                  key={value}
                  selected={selection[option.name] === value}
                  crossed={state === 'unavailableWithSelection'}
                  disabled={state === 'soldOut'}
                  onClick={() => choose(option.name, value)}
                  title={
                    state === 'soldOut'
                      ? t('valueSoldOut', { value })
                      : state === 'unavailableWithSelection'
                        ? t('valueUnavailable', { value })
                        : undefined
                  }
                  className="min-w-12 justify-center"
                >
                  {value}
                </Chip>
              );
            })}
          </div>
        </fieldset>
      ))}

      <div className="flex min-h-7 flex-wrap items-center gap-2" aria-live="polite">
        {missing !== undefined ? (
          <span className="text-[15px] text-secondary">
            {t('missingOption', { option: missing.toLowerCase() })}
          </span>
        ) : stock <= 0 ? (
          <StatusPill tone="error">{t('soldOut')}</StatusPill>
        ) : remaining <= 0 ? (
          <span className="text-[15px] text-warning-text">{t('allInCart')}</span>
        ) : remaining <= LOW_STOCK_THRESHOLD ? (
          <StatusPill tone="warning" dot>
            {t('lastUnits', { count: remaining })}
          </StatusPill>
        ) : (
          <StatusPill tone="success" dot>
            {t('inStock')}
          </StatusPill>
        )}
        {complete && inCart > 0 && (
          <StatusPill tone="info">{t('inCart', { count: inCart })}</StatusPill>
        )}
      </div>

      <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
        <div className="flex items-center justify-between gap-3 sm:justify-start">
          <span className="text-[15px] font-semibold sm:sr-only">{t('quantity')}</span>
          <QuantityStepper
            quantity={effectiveQuantity}
            size="lg"
            onDecrement={() => setQuantity(effectiveQuantity - 1)}
            onIncrement={() => setQuantity(effectiveQuantity + 1)}
            canDecrement={canAdd && effectiveQuantity > 1}
            canIncrement={canAdd && effectiveQuantity < remaining}
          />
        </div>
        <Button size="lg" className="flex-1" disabled={!canAdd} onClick={addToOrder}>
          {t('add', { total: formatMoney(product.price * effectiveQuantity) })}
        </Button>
      </div>
    </div>
  );
}
