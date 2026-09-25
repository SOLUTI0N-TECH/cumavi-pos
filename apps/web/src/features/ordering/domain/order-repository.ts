import type { CustomerDetails, Order, OrderLine } from './order';

export interface NewOrder {
  storeSlug: string;
  customer: CustomerDetails;
  lines: OrderLine[];
}

/**
 * Where orders go. Mocked in the browser until the backend exists; then the
 * API implementation will also notify the store's POS app.
 */
export interface OrderRepository {
  place(order: NewOrder): Promise<Order>;
  find(storeSlug: string, number: number): Promise<Order | undefined>;
}
