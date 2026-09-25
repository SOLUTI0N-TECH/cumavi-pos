import type { Fulfillment, PaymentMethod } from '@/features/catalog/domain/entities';

/** What the customer fills in at checkout. No account is needed. */
export interface CustomerDetails {
  name: string;
  /** National mobile number, 8 digits. */
  phone: string;
  fulfillment: Fulfillment;
  /** Required for delivery. */
  address: string;
  note: string;
  paymentMethod: PaymentMethod;
}

/**
 * Snapshot of an ordered line: names and prices are copied so the order
 * never changes if the catalog does.
 */
export interface OrderLine {
  productId: string;
  productName: string;
  variantId?: string;
  variantLabel?: string;
  unitPrice: number;
  quantity: number;
}

export interface Order {
  /** Per store: 1001, 1002… */
  number: number;
  storeSlug: string;
  createdAt: string;
  customer: CustomerDetails;
  lines: OrderLine[];
  total: number;
}

export function orderUnits(order: Order): number {
  return order.lines.reduce((total, line) => total + line.quantity, 0);
}
