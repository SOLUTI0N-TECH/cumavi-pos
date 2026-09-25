'use client';

import { zodResolver } from '@hookform/resolvers/zod';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { type ReactNode, useState } from 'react';
import { Controller, useForm, useWatch } from 'react-hook-form';
import { toast } from 'sonner';

import type { CartLine } from '@/features/cart/domain/cart';
import { useCartStore } from '@/features/cart/state/cart-store';
import { variantLabel } from '@/features/catalog/domain/product-rules';
import { useStore } from '@/features/catalog/presentation/store-context';
import { cn } from '@/shared/lib/cn';
import { formatMoney } from '@/shared/lib/money';
import { Button } from '@/shared/ui/button';
import { Chip } from '@/shared/ui/chip';
import { Dialog } from '@/shared/ui/dialog';
import { orderRepository } from '../data/local-order-repository';
import { BOLIVIA_COUNTRY_CODE } from '../domain/bolivian-phone';
import {
  type CheckoutInput,
  type CheckoutValues,
  checkoutSchema,
} from '../domain/checkout-schema';
import type { OrderLine } from '../domain/order';

type ErrorKey = 'nameRequired' | 'phoneInvalid' | 'addressRequired' | 'noteTooLong';

const inputClass =
  'h-13 w-full rounded-lg border border-border bg-surface px-4 text-base font-medium outline-none transition focus:border-ink';

function toOrderLine(line: CartLine): OrderLine {
  return {
    productId: line.product.id,
    productName: line.product.name,
    variantId: line.variant?.id,
    variantLabel: line.variant ? variantLabel(line.variant) : undefined,
    unitPrice: line.product.price,
    quantity: line.quantity,
  };
}

/** "Tus datos": who orders, how it is delivered and how it is paid. */
export function CheckoutDialog({
  open,
  onOpenChange,
  lines,
  total,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  lines: CartLine[];
  total: number;
}) {
  const t = useTranslations('checkout');
  const payment = useTranslations('payment');
  const confirmation = useTranslations('confirmation');
  const router = useRouter();
  const store = useStore();
  const clearCart = useCartStore((state) => state.clear);
  const [failed, setFailed] = useState(false);

  const {
    register,
    control,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<CheckoutInput, unknown, CheckoutValues>({
    resolver: zodResolver(checkoutSchema),
    defaultValues: {
      name: '',
      phone: '',
      fulfillment: store.fulfillment[0] ?? 'pickup',
      address: '',
      note: '',
      paymentMethod: store.paymentMethods[0] ?? 'cash',
    },
  });
  const fulfillment = useWatch({ control, name: 'fulfillment' });

  const errorText = (key: string | undefined) =>
    key ? t(`errors.${key as ErrorKey}`) : undefined;

  async function placeOrder(values: CheckoutValues) {
    setFailed(false);
    try {
      const order = await orderRepository().place({
        storeSlug: store.slug,
        customer: values,
        lines: lines.map(toOrderLine),
      });
      clearCart(store.slug);
      toast.success(confirmation('placed', { number: order.number }));
      router.push(`/${store.slug}/pedido/confirmado?n=${order.number}`);
    } catch {
      setFailed(true);
    }
  }

  return (
    <Dialog
      open={open}
      onOpenChange={onOpenChange}
      title={t('title')}
      description={t('subtitle')}
      closeLabel={t('close')}
    >
      <form onSubmit={handleSubmit(placeOrder)} className="flex flex-col gap-4" noValidate>
        <Field label={t('name')} required error={errorText(errors.name?.message)}>
          <input
            {...register('name')}
            autoComplete="name"
            placeholder={t('namePlaceholder')}
            className={inputClass}
          />
        </Field>

        <Field label={t('phone')} required error={errorText(errors.phone?.message)}>
          <div className="flex gap-2">
            <span className="flex h-13 items-center rounded-lg border border-border bg-background px-3 text-base font-semibold text-ink-soft">
              +{BOLIVIA_COUNTRY_CODE}
            </span>
            <input
              {...register('phone')}
              type="tel"
              inputMode="numeric"
              autoComplete="tel-national"
              placeholder={t('phonePlaceholder')}
              className={cn(inputClass, 'tabular-nums')}
            />
          </div>
        </Field>

        {store.fulfillment.length > 1 && (
          <Field label={t('fulfillment')}>
            <Controller
              control={control}
              name="fulfillment"
              render={({ field }) => (
                <div className="grid grid-cols-2 gap-2">
                  {store.fulfillment.map((option) => (
                    <Chip
                      key={option}
                      selected={field.value === option}
                      onClick={() => field.onChange(option)}
                      className="justify-center"
                    >
                      {t(option)}
                    </Chip>
                  ))}
                </div>
              )}
            />
          </Field>
        )}

        {fulfillment === 'delivery' ? (
          <Field label={t('address')} required error={errorText(errors.address?.message)}>
            <input
              {...register('address')}
              autoComplete="street-address"
              placeholder={t('addressPlaceholder')}
              className={inputClass}
            />
          </Field>
        ) : (
          <p className="rounded-lg bg-background px-4 py-3 text-[15px] text-ink-soft">
            {t('pickupAt', { address: store.address })}
          </p>
        )}

        <Field label={t('note')} error={errorText(errors.note?.message)}>
          <textarea
            {...register('note')}
            rows={2}
            placeholder={t('notePlaceholder')}
            className="w-full resize-y rounded-lg border border-border bg-surface px-4 py-3 text-base outline-none transition focus:border-ink"
          />
        </Field>

        <Field label={t('payment')}>
          <Controller
            control={control}
            name="paymentMethod"
            render={({ field }) => (
              <div className="flex flex-wrap gap-2">
                {store.paymentMethods.map((method) => (
                  <Chip
                    key={method}
                    selected={field.value === method}
                    onClick={() => field.onChange(method)}
                    className="flex-1 basis-24 justify-center"
                  >
                    {payment(method)}
                  </Chip>
                ))}
              </div>
            )}
          />
        </Field>

        {failed && (
          <p className="rounded-lg bg-error-surface px-4 py-3 text-[15px] font-semibold text-error-text">
            {t('failed')}
          </p>
        )}

        <div className="flex items-baseline justify-between gap-3 rounded-lg bg-background px-4 py-3">
          <span className="text-[15px] text-secondary">{t('orderTotal')}</span>
          <span className="text-2xl font-bold tabular-nums">{formatMoney(total)}</span>
        </div>

        <div className="flex flex-col gap-2">
          <Button type="submit" size="lg" disabled={isSubmitting || lines.length === 0}>
            {t('confirm')}
          </Button>
          <Button variant="ghost" onClick={() => onOpenChange(false)}>
            {t('review')}
          </Button>
        </div>
      </form>
    </Dialog>
  );
}

function Field({
  label,
  required = false,
  error,
  children,
}: {
  label: string;
  required?: boolean;
  error?: string;
  children: ReactNode;
}) {
  return (
    <label className="flex flex-col gap-2">
      <span className="text-[15px] font-semibold text-ink-soft">
        {label}
        {required && <span aria-hidden> *</span>}
      </span>
      {children}
      {error && (
        <span role="alert" className="text-sm font-medium text-error-text">
          {error}
        </span>
      )}
    </label>
  );
}
