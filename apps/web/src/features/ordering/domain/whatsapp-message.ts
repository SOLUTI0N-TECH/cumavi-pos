import type { Store } from '@/features/catalog/domain/entities';
import { formatMoney } from '@/shared/lib/money';
import { BOLIVIA_COUNTRY_CODE, formatPhone } from './bolivian-phone';
import type { Order, OrderLine } from './order';

/** Texts of the message, from the `whatsapp` translation namespace. */
export interface WhatsAppTexts {
  title: (values: { number: number; store: string }) => string;
  customer: (values: { name: string; phone: string }) => string;
  pickup: string;
  delivery: (values: { address: string }) => string;
  payment: (values: { method: string }) => string;
  total: (values: { total: string }) => string;
  note: (values: { note: string }) => string;
  paymentMethod: (method: Order['customer']['paymentMethod']) => string;
  /** Line with the link that opens the order in the store's POS app. */
  posLink?: (values: { url: string }) => string;
}

function lineText(line: OrderLine): string {
  const name = line.variantLabel
    ? `${line.productName} (${line.variantLabel})`
    : line.productName;
  return `${line.quantity} x ${name} — ${formatMoney(line.unitPrice * line.quantity)}`;
}

/**
 * The order as a WhatsApp message for the store, in the same format as the
 * POS receipts (`*text*` renders bold). With [importUrl] it ends with the
 * link that loads the order into the store's POS app.
 */
export function buildWhatsAppMessage(
  order: Order,
  store: Store,
  texts: WhatsAppTexts,
  importUrl?: string,
): string {
  const { customer } = order;
  const lines = [
    `*${texts.title({ number: order.number, store: store.name })}*`,
    texts.customer({
      name: customer.name,
      phone: `+${BOLIVIA_COUNTRY_CODE} ${formatPhone(customer.phone)}`,
    }),
    customer.fulfillment === 'delivery'
      ? texts.delivery({ address: customer.address })
      : texts.pickup,
    texts.payment({ method: texts.paymentMethod(customer.paymentMethod) }),
    '',
    ...order.lines.map(lineText),
    '',
    `*${texts.total({ total: formatMoney(order.total) })}*`,
  ];
  if (customer.note) lines.push(texts.note({ note: customer.note }));
  if (importUrl && texts.posLink) lines.push('', texts.posLink({ url: importUrl }));
  return lines.join('\n');
}

/** `https://wa.me/59176543210?text=…` */
export function whatsAppLink(phone: string, message: string): string {
  return `https://wa.me/${phone.replace(/\D/g, '')}?text=${encodeURIComponent(message)}`;
}
