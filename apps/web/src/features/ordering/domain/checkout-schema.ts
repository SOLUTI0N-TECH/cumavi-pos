import { z } from 'zod';

import { isValidMobile, normalizePhone } from './bolivian-phone';

/**
 * Checkout rules. Messages are translation keys under `checkout.errors`, so
 * the form shows them in the user's language.
 */
export const checkoutSchema = z
  .object({
    name: z.string().trim().min(3, { error: 'nameRequired' }),
    phone: z
      .string()
      .refine(isValidMobile, { error: 'phoneInvalid' })
      .transform(normalizePhone),
    fulfillment: z.enum(['pickup', 'delivery']),
    address: z.string().trim(),
    note: z.string().trim().max(200, { error: 'noteTooLong' }),
    paymentMethod: z.enum(['cash', 'qr', 'bankTransfer']),
  })
  .refine(
    (details) => details.fulfillment === 'pickup' || details.address.length >= 5,
    { error: 'addressRequired', path: ['address'] },
  );

export type CheckoutInput = z.input<typeof checkoutSchema>;
export type CheckoutValues = z.output<typeof checkoutSchema>;
