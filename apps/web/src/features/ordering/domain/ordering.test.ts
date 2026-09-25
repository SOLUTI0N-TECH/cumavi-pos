import { describe, expect, it } from 'vitest';

import type { Store } from '@/features/catalog/domain/entities';
import { formatMoney } from '@/shared/lib/money';
import { formatPhone, isValidMobile, normalizePhone } from './bolivian-phone';
import { checkoutSchema } from './checkout-schema';
import type { Order } from './order';
import { buildWhatsAppMessage, whatsAppLink } from './whatsapp-message';

describe('formatMoney', () => {
  it('uses the POS format', () => {
    expect(formatMoney(1229)).toBe('Bs 1.229,00');
    expect(formatMoney(6.5)).toBe('Bs 6,50');
    expect(formatMoney(1234567.891)).toBe('Bs 1.234.567,89');
  });
});

describe('Bolivian phone', () => {
  it('accepts 8-digit mobiles starting with 6 or 7', () => {
    expect(isValidMobile('7654 3210')).toBe(true);
    expect(isValidMobile('+591 61234567')).toBe(true);
    expect(isValidMobile('33456789')).toBe(false);
    expect(isValidMobile('7654321')).toBe(false);
  });

  it('normalizes and formats', () => {
    expect(normalizePhone('+591 7654-3210')).toBe('76543210');
    expect(formatPhone('76543210')).toBe('7654 3210');
  });
});

describe('checkoutSchema', () => {
  const valid = {
    name: 'Juan Pérez',
    phone: '7654 3210',
    fulfillment: 'pickup' as const,
    address: '',
    note: '',
    paymentMethod: 'qr' as const,
  };

  it('accepts a pickup order without address and normalizes the phone', () => {
    const result = checkoutSchema.safeParse(valid);

    expect(result.success).toBe(true);
    expect(result.data?.phone).toBe('76543210');
  });

  it('asks for the address when the order is delivered', () => {
    const result = checkoutSchema.safeParse({ ...valid, fulfillment: 'delivery' });

    expect(result.success).toBe(false);
    expect(result.error?.issues[0]).toMatchObject({
      path: ['address'],
      message: 'addressRequired',
    });
  });

  it('rejects invalid phones with a translation key', () => {
    const result = checkoutSchema.safeParse({ ...valid, phone: '123' });

    expect(result.error?.issues[0].message).toBe('phoneInvalid');
  });
});

describe('WhatsApp message', () => {
  const store = { name: 'Illimani Store', whatsapp: '59176543210' } as Store;
  const order: Order = {
    number: 1001,
    storeSlug: 'illimani-store',
    createdAt: '2026-09-24T12:00:00Z',
    customer: {
      name: 'Juan Pérez',
      phone: '71234567',
      fulfillment: 'delivery',
      address: 'Calle 21 #850',
      note: 'Llamar antes',
      paymentMethod: 'qr',
    },
    lines: [
      {
        productId: 'p-001',
        productName: 'Zapatillas urbanas',
        variantId: 'azul/40',
        variantLabel: 'Azul · 40',
        unitPrice: 450,
        quantity: 2,
      },
      { productId: 'p-008', productName: 'Gorra trucker blanca', unitPrice: 65, quantity: 1 },
    ],
    total: 965,
  };

  it('lists the whole order with its variants', () => {
    const message = buildWhatsAppMessage(order, store, {
      title: ({ number, store }) => `Nuevo pedido #${number} · ${store}`,
      customer: ({ name, phone }) => `Cliente: ${name} · ${phone}`,
      pickup: 'Entrega: recojo en tienda',
      delivery: ({ address }) => `Entrega: envío a ${address}`,
      payment: ({ method }) => `Pago: ${method}`,
      total: ({ total }) => `Total: ${total}`,
      note: ({ note }) => `Nota: ${note}`,
      paymentMethod: (method) => (method === 'qr' ? 'QR' : method),
    });

    expect(message).toBe(
      [
        '*Nuevo pedido #1001 · Illimani Store*',
        'Cliente: Juan Pérez · +591 7123 4567',
        'Entrega: envío a Calle 21 #850',
        'Pago: QR',
        '',
        '2 x Zapatillas urbanas (Azul · 40) — Bs 900,00',
        '1 x Gorra trucker blanca — Bs 65,00',
        '',
        '*Total: Bs 965,00*',
        'Nota: Llamar antes',
      ].join('\n'),
    );
    expect(whatsAppLink(store.whatsapp, 'Hola *mundo*')).toBe(
      'https://wa.me/59176543210?text=Hola%20*mundo*',
    );
  });
});
