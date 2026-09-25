import type { Order } from '../domain/order';
import type { NewOrder, OrderRepository } from '../domain/order-repository';

const STORAGE_KEY = 'cumavi.catalog.orders.v1';
const FIRST_NUMBER = 1001;

interface SavedOrders {
  orders: Order[];
}

/**
 * Keeps the customer's orders in this browser. Stand-in for the backend:
 * the store only learns about an order through the WhatsApp message.
 */
export class LocalOrderRepository implements OrderRepository {
  constructor(private readonly storage: Storage = window.localStorage) {}

  async place(newOrder: NewOrder): Promise<Order> {
    const saved = this.read();
    const numbers = saved.orders
      .filter((order) => order.storeSlug === newOrder.storeSlug)
      .map((order) => order.number);
    const order: Order = {
      ...newOrder,
      number: numbers.length === 0 ? FIRST_NUMBER : Math.max(...numbers) + 1,
      createdAt: new Date().toISOString(),
      total: newOrder.lines.reduce(
        (total, line) => total + line.unitPrice * line.quantity,
        0,
      ),
    };
    this.write({ orders: [...saved.orders, order] });
    return order;
  }

  async find(storeSlug: string, number: number): Promise<Order | undefined> {
    return this.read().orders.find(
      (order) => order.storeSlug === storeSlug && order.number === number,
    );
  }

  private read(): SavedOrders {
    try {
      const raw = this.storage.getItem(STORAGE_KEY);
      return raw ? (JSON.parse(raw) as SavedOrders) : { orders: [] };
    } catch {
      return { orders: [] };
    }
  }

  private write(saved: SavedOrders): void {
    try {
      this.storage.setItem(STORAGE_KEY, JSON.stringify(saved));
    } catch {
      // Private mode or full storage: the order still goes out by WhatsApp.
    }
  }
}

let repository: OrderRepository | undefined;

/** The order destination for client components. */
export function orderRepository(): OrderRepository {
  repository ??= new LocalOrderRepository();
  return repository;
}
