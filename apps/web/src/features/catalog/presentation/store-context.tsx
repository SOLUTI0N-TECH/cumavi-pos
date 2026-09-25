'use client';

import { createContext, type ReactNode, useContext } from 'react';

import type { Product, Store } from '../domain/entities';

interface StoreContextValue {
  store: Store;
  products: Product[];
}

const StoreContext = createContext<StoreContextValue | null>(null);

/**
 * Hands the current store and its catalog (loaded on the server by the
 * store layout) to the client components: cart, picker, checkout.
 */
export function StoreProvider({
  store,
  products,
  children,
}: StoreContextValue & { children: ReactNode }) {
  return (
    <StoreContext.Provider value={{ store, products }}>{children}</StoreContext.Provider>
  );
}

function useStoreContext(): StoreContextValue {
  const value = useContext(StoreContext);
  if (!value) throw new Error('StoreProvider is missing above this component.');
  return value;
}

export function useStore(): Store {
  return useStoreContext().store;
}

export function useStoreProducts(): Product[] {
  return useStoreContext().products;
}
