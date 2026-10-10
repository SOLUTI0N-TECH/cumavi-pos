'use client';

import { Check, MessageCircle, SearchX } from 'lucide-react';
import Link from 'next/link';
import { useSearchParams } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { useEffect, useState } from 'react';

import { useStore } from '@/features/catalog/presentation/store-context';
import { formatMoney } from '@/shared/lib/money';
import { buttonClasses } from '@/shared/ui/button';
import { EmptyState } from '@/shared/ui/empty-state';
import { orderRepository } from '../data/local-order-repository';
import type { Order } from '../domain/order';
import { orderImportUrl } from '../domain/order-link';
import { buildWhatsAppMessage, whatsAppLink } from '../domain/whatsapp-message';

/**
 * After ordering: the summary and the WhatsApp button that sends the whole
 * order to the store (the store's inbox until the backend exists).
 */
export function OrderConfirmation() {
  const orderNumber = Number(useSearchParams().get('n'));
  const t = useTranslations('confirmation');
  const whatsapp = useTranslations('whatsapp');
  const payment = useTranslations('payment');
  const store = useStore();
  const isValidNumber = Number.isInteger(orderNumber) && orderNumber > 0;
  const orderKey = `${store.slug}#${orderNumber}`;
  const [loaded, setLoaded] = useState<{ key: string; order: Order | null }>();

  useEffect(() => {
    if (!isValidNumber) return;
    let active = true;
    orderRepository()
      .find(store.slug, orderNumber)
      .then((found) => {
        if (active) setLoaded({ key: orderKey, order: found ?? null });
      });
    return () => {
      active = false;
    };
  }, [isValidNumber, orderKey, store.slug, orderNumber]);

  // `undefined` while loading, `null` when there is no such order here.
  const order = !isValidNumber ? null : loaded?.key === orderKey ? loaded.order : undefined;

  if (order === undefined) {
    return <div className="mx-auto h-96 w-full max-w-md animate-pulse rounded-3xl bg-surface" aria-hidden />;
  }

  if (order === null) {
    return (
      <EmptyState
        className="mx-auto w-full max-w-md"
        icon={<SearchX className="size-7" />}
        title={t('notFoundTitle')}
        message={t('notFoundMessage')}
        action={
          <Link href={`/${store.slug}`} className={buttonClasses('primary', 'lg')}>
            {t('backToCatalog')}
          </Link>
        }
      />
    );
  }

  const message = buildWhatsAppMessage(
    order,
    store,
    {
      title: (values) => whatsapp('title', values),
      customer: (values) => whatsapp('customer', values),
      pickup: whatsapp('pickup'),
      delivery: (values) => whatsapp('delivery', values),
      payment: (values) => whatsapp('payment', values),
      total: (values) => whatsapp('total', values),
      note: (values) => whatsapp('note', values),
      paymentMethod: (method) => payment(method),
      posLink: (values) => whatsapp('posLink', values),
    },
    // Orders saved before links existed have no id: they go without it.
    order.id ? orderImportUrl(window.location.origin, order) : undefined,
  );

  const rows: [string, string][] = [
    [t('number'), `#${order.number}`],
    [t('customer'), order.customer.name],
    [t('fulfillment'), t(order.customer.fulfillment)],
    [t('total'), formatMoney(order.total)],
  ];

  return (
    <div className="mx-auto flex w-full max-w-md animate-pop-in flex-col items-center gap-6 rounded-3xl border border-divider bg-surface px-6 py-9 text-center">
      <div className="flex size-16 items-center justify-center rounded-full bg-success text-white">
        <Check className="size-8" strokeWidth={2.8} />
      </div>
      <div className="flex flex-col gap-2">
        <h1 className="text-2xl font-bold tracking-tight">{t('title')}</h1>
        <p className="text-base leading-relaxed text-secondary">
          {t('message', { store: store.name })}
        </p>
      </div>
      <dl className="flex w-full flex-col gap-2.5 rounded-xl bg-background p-4 text-[15px]">
        {rows.map(([label, value]) => (
          <div key={label} className="flex justify-between gap-3">
            <dt className="text-secondary">{label}</dt>
            <dd className="font-semibold tabular-nums">{value}</dd>
          </div>
        ))}
      </dl>
      <div className="flex w-full flex-col gap-2.5">
        <a
          href={whatsAppLink(store.whatsapp, message)}
          target="_blank"
          rel="noopener noreferrer"
          className={buttonClasses('success', 'lg')}
        >
          <MessageCircle className="size-5" />
          {t('sendWhatsApp')}
        </a>
        <Link href={`/${store.slug}`} className={buttonClasses('secondary', 'lg')}>
          {t('backToCatalog')}
        </Link>
      </div>
    </div>
  );
}
