/**
 * Catalog as a customer sees it. Mirrors the POS entities
 * (apps/mobile/lib/features/catalog/domain) without the owner-only data:
 * there are no cost prices here.
 */

export type PaymentMethod = 'cash' | 'qr' | 'bankTransfer';

/** How the customer gets the order. */
export type Fulfillment = 'pickup' | 'delivery';

export interface OpeningHours {
  /** ISO weekday: 1 = Monday … 7 = Sunday. */
  day: number;
  /** `HH:mm` in the store's time zone. */
  opens: string;
  closes: string;
}

export interface Category {
  id: string;
  name: string;
}

export interface Store {
  id: string;
  /** Used in every URL: `/illimani-store`. */
  slug: string;
  name: string;
  tagline: string;
  department: string;
  city: string;
  zone: string;
  address: string;
  /** For the future map of stores. */
  location: { lat: number; lng: number };
  /** International number without `+`, for wa.me links. */
  whatsapp: string;
  timeZone: string;
  openingHours: OpeningHours[];
  paymentMethods: PaymentMethod[];
  fulfillment: Fulfillment[];
  categories: Category[];
}

export interface ProductImage {
  id: string;
  /** Public URL of the photo. */
  src: string;
}

/** A way a product varies and its values: `Talla: S, M, L`. */
export interface VariantOption {
  name: string;
  values: string[];
}

/** One sellable combination (`Rojo` + `40`) with its own stock and photo. */
export interface ProductVariant {
  id: string;
  /** Value per option name, in the product's option order. */
  optionValues: Record<string, string>;
  stock: number;
  /** One of the product's images; missing = main photo. */
  imageId?: string;
}

export interface Product {
  id: string;
  storeId: string;
  /** Used in the product URL: `/illimani-store/p/zapatillas-urbanas`. */
  slug: string;
  name: string;
  categoryId: string;
  /** Bolivianos. */
  price: number;
  description: string;
  /** Gallery; the first one is the main photo. */
  images: ProductImage[];
  createdAt: string;
  options: VariantOption[];
  variants: ProductVariant[];
  /** Stock of a product without variants. */
  stock: number;
}
