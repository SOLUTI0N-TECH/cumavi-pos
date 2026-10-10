import type { Fulfillment, PaymentMethod } from '@/features/catalog/domain/entities';
import type { Order, OrderLine } from './order';

/**
 * An order packed into a link, so it can reach the store's POS app through
 * the WhatsApp message while there is no backend (POS roadmap, feature 13).
 * The POS reads it with `OrderLinkCodec` in
 * `apps/mobile/lib/features/orders/domain/usecases/import_order.dart`:
 * keep both in sync.
 *
 * Version 1 is compact JSON in base64url:
 * `{"v":1,"s":store,"id":…,"n":number,"t":iso,"f":fulfillment,"m":method,
 *   "c":{"n":name,"p":phone,"a":address,"o":note},
 *   "l":[[productId, variantId|"", quantity, unitPrice, productName, variantLabel|""]]}`
 */
const VERSION = 1;

/** Android package of the POS app. */
export const POS_PACKAGE = 'bo.solutiontech.cumavi_pos_mobile';

interface LinkPayload {
  v: number;
  s: string;
  id: string;
  n: number;
  t: string;
  f: Fulfillment;
  m: PaymentMethod;
  c: { n: string; p: string; a: string; o: string };
  l: [string, string, number, number, string, string][];
}

export interface DecodedOrderLink {
  storeSlug: string;
  order: Order;
}

function toBase64Url(text: string): string {
  const bytes = new TextEncoder().encode(text);
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function fromBase64Url(data: string): string {
  const base64 = data.replace(/-/g, '+').replace(/_/g, '/');
  const padded = base64 + '='.repeat((4 - (base64.length % 4)) % 4);
  const binary = atob(padded);
  return new TextDecoder().decode(Uint8Array.from(binary, (char) => char.charCodeAt(0)));
}

/** The `d` value of the import link. */
export function encodeOrderLink(order: Order): string {
  const payload: LinkPayload = {
    v: VERSION,
    s: order.storeSlug,
    id: order.id,
    n: order.number,
    t: order.createdAt,
    f: order.customer.fulfillment,
    m: order.customer.paymentMethod,
    c: {
      n: order.customer.name,
      p: order.customer.phone,
      a: order.customer.address,
      o: order.customer.note,
    },
    l: order.lines.map((line) => [
      line.productId,
      line.variantId ?? '',
      line.quantity,
      line.unitPrice,
      line.productName,
      line.variantLabel ?? '',
    ]),
  };
  return toBase64Url(JSON.stringify(payload));
}

/** Reads a `d` value back; `undefined` when it is not an order link. */
export function decodeOrderLink(data: string): DecodedOrderLink | undefined {
  try {
    const payload = JSON.parse(fromBase64Url(data)) as LinkPayload;
    if (payload.v !== VERSION || !Array.isArray(payload.l) || payload.l.length === 0) {
      return undefined;
    }
    const lines: OrderLine[] = payload.l.map(
      ([productId, variantId, quantity, unitPrice, productName, variantLabel]) => ({
        productId,
        productName,
        unitPrice,
        quantity,
        ...(variantId ? { variantId } : {}),
        ...(variantLabel ? { variantLabel } : {}),
      }),
    );
    return {
      storeSlug: payload.s,
      order: {
        id: payload.id,
        number: payload.n,
        storeSlug: payload.s,
        createdAt: payload.t,
        customer: {
          name: payload.c.n,
          phone: payload.c.p,
          fulfillment: payload.f,
          address: payload.c.a,
          note: payload.c.o,
          paymentMethod: payload.m,
        },
        lines,
        total: lines.reduce((total, line) => total + line.unitPrice * line.quantity, 0),
      },
    };
  } catch {
    return undefined;
  }
}

/** `https://…/illimani-store/pedido/importar/?d=…`: opened by the store. */
export function orderImportUrl(siteUrl: string, order: Order): string {
  const base = siteUrl.replace(/\/+$/, '');
  return `${base}/${order.storeSlug}/pedido/importar/?d=${encodeOrderLink(order)}`;
}

/**
 * Android intent that opens the POS app on the import screen
 * (`cumavipos://pos/orders/import?d=…`). Chrome follows it from a tap.
 */
export function posIntentUrl(data: string): string {
  return `intent://pos/orders/import?d=${data}#Intent;scheme=cumavipos;package=${POS_PACKAGE};end`;
}
