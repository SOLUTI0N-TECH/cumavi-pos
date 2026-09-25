'use client';

import { useEffect, useSyncExternalStore } from 'react';
import { create } from 'zustand';
import { createJSONStorage, persist } from 'zustand/middleware';

import type { Product, ProductVariant } from '@/features/catalog/domain/entities';
import { addToCart, type CartItem, setQuantity } from '../domain/cart';

interface CartState {
  /** One cart per store, keyed by store slug. */
  carts: Record<string, CartItem[]>;
  add: (
    storeSlug: string,
    product: Product,
    variant?: ProductVariant,
    quantity?: number,
  ) => boolean;
  setQuantity: (storeSlug: string, key: string, quantity: number) => void;
  clear: (storeSlug: string) => void;
}

const EMPTY: CartItem[] = [];

/**
 * Carts survive reloads (localStorage), so a customer who closes the tab
 * keeps the order in progress.
 */
export const useCartStore = create<CartState>()(
  persist(
    (set, get) => ({
      carts: {},
      add: (storeSlug, product, variant, quantity = 1) => {
        const current = get().carts[storeSlug] ?? EMPTY;
        const next = addToCart(current, product, variant, quantity);
        if (next === current) return false;
        set({ carts: { ...get().carts, [storeSlug]: next } });
        return true;
      },
      setQuantity: (storeSlug, key, quantity) =>
        set({
          carts: {
            ...get().carts,
            [storeSlug]: setQuantity(get().carts[storeSlug] ?? EMPTY, key, quantity),
          },
        }),
      clear: (storeSlug) => set({ carts: { ...get().carts, [storeSlug]: [] } }),
    }),
    {
      name: 'cumavi.catalog.cart.v1',
      storage: createJSONStorage(() => localStorage),
      skipHydration: true,
    },
  ),
);

/** Items of a store's cart. */
export function useCartItems(storeSlug: string): CartItem[] {
  return useCartStore((state) => state.carts[storeSlug] ?? EMPTY);
}

/**
 * Loads the saved cart after the first render. Until then the page shows an
 * empty cart, which matches the server HTML and avoids hydration errors.
 */
export function useCartHydration(): boolean {
  const hydrated = useSyncExternalStore(
    (onChange) => useCartStore.persist.onFinishHydration(onChange),
    () => useCartStore.persist.hasHydrated(),
    // Always `false` on the server: there is no localStorage while prerendering.
    () => false,
  );
  useEffect(() => {
    if (!useCartStore.persist.hasHydrated()) void useCartStore.persist.rehydrate();
  }, []);
  return hydrated;
}
