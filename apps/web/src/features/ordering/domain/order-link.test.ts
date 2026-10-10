import { describe, expect, it } from 'vitest';

import type { Store } from '@/features/catalog/domain/entities';
import type { Order } from './order';
import {
  decodeOrderLink,
  encodeOrderLink,
  orderImportUrl,
  posIntentUrl,
} from './order-link';
import { buildWhatsAppMessage } from './whatsapp-message';

/**
 * The same link is decoded by the POS test
 * (apps/mobile/test/features/orders/import_and_store_test.dart): if this
 * changes, update both.
 */
const FIXTURE = 'eyJ2IjoxLCJzIjoiaWxsaW1hbmktc3RvcmUiLCJpZCI6ImYxZTJkM2M0LTAwMDAtNDAwMC04MDAwLTAwMDAwMDAwMDAwMSIsIm4iOjEwMDMsInQiOiIyMDI2LTEwLTEwVDE5OjIwOjAwLjAwMFoiLCJmIjoiZGVsaXZlcnkiLCJtIjoicXIiLCJjIjp7Im4iOiJBbmEgUMOpcmV6IiwicCI6Ijc2NTQzMjEwIiwiYSI6IkF2LiBBcmNlICMxMCIsIm8iOiIifSwibCI6W1sicC0wMTEiLCJuZWdyYS9tIiwyLDc1LCJQb2xlcmEgYsOhc2ljYSIsIk5lZ3JhIMK3IE0iXSxbInAtMDA4IiwiIiwxLDY1LCJHb3JyYSB0cnVja2VyIGJsYW5jYSIsIiJdXX0';

const order: Order = {
  id: 'f1e2d3c4-0000-4000-8000-000000000001',
  number: 1003,
  storeSlug: 'illimani-store',
  createdAt: '2026-10-10T19:20:00.000Z',
  customer: {
    name: 'Ana Pérez',
    phone: '76543210',
    fulfillment: 'delivery',
    address: 'Av. Arce #10',
    note: '',
    paymentMethod: 'qr',
  },
  lines: [
    {
      productId: 'p-011',
      productName: 'Polera básica',
      variantId: 'negra/m',
      variantLabel: 'Negra · M',
      unitPrice: 75,
      quantity: 2,
    },
    { productId: 'p-008', productName: 'Gorra trucker blanca', unitPrice: 65, quantity: 1 },
  ],
  total: 215,
};

describe('order link', () => {
  it('writes the format the POS reads', () => {
    expect(encodeOrderLink(order)).toBe(FIXTURE);
  });

  it('reads it back', () => {
    expect(decodeOrderLink(FIXTURE)).toEqual({ storeSlug: 'illimani-store', order });
  });

  it('ignores anything that is not an order', () => {
    expect(decodeOrderLink('no-es-un-pedido')).toBeUndefined();
    expect(decodeOrderLink('')).toBeUndefined();
  });

  it('builds the import page and the Android intent', () => {
    expect(orderImportUrl('https://cumavi.test/', order)).toBe(
      `https://cumavi.test/illimani-store/pedido/importar/?d=${FIXTURE}`,
    );
    expect(posIntentUrl('abc')).toBe(
      'intent://pos/orders/import?d=abc#Intent;scheme=cumavipos;package=bo.solutiontech.cumavi_pos_mobile;end',
    );
  });

  it('ends the WhatsApp message with the link for the POS', () => {
    const message = buildWhatsAppMessage(
      order,
      { name: 'Illimani Store' } as Store,
      {
        title: ({ number, store }) => `Pedido #${number} · ${store}`,
        customer: ({ name }) => name,
        pickup: 'Recojo',
        delivery: ({ address }) => address,
        payment: ({ method }) => method,
        total: ({ total }) => total,
        note: ({ note }) => note,
        paymentMethod: (method) => method,
        posLink: ({ url }) => `POS: ${url}`,
      },
      'https://cumavi.test/x',
    );

    expect(message.split('\n').at(-1)).toBe('POS: https://cumavi.test/x');
  });
});
