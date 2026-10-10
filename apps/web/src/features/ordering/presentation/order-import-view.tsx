'use client';

import { Copy, LinkIcon, Smartphone } from 'lucide-react';
import { useSearchParams } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { useState } from 'react';

import { useStore } from '@/features/catalog/presentation/store-context';
import { formatMoney } from '@/shared/lib/money';
import { buttonClasses } from '@/shared/ui/button';
import { EmptyState } from '@/shared/ui/empty-state';
import { decodeOrderLink, posIntentUrl } from '../domain/order-link';

/**
 * What the store sees when it opens the link of a WhatsApp order: a
 * summary and the button that loads it into Cumavi POS. Only the store's
 * own orders open here.
 */
export function OrderImportView() {
  const data = useSearchParams().get('d') ?? '';
  const t = useTranslations('orderImport');
  const store = useStore();
  const [copied, setCopied] = useState(false);
  const decoded = data ? decodeOrderLink(data) : undefined;

  if (!decoded || decoded.storeSlug !== store.slug) {
    return (
      <EmptyState
        className="mx-auto w-full max-w-md"
        icon={<LinkIcon className="size-7" />}
        title={t('invalidTitle')}
        message={t('invalidMessage')}
      />
    );
  }

  const { order } = decoded;
  const rows: [string, string][] = [
    [t('number'), `#${order.number}`],
    [t('customer'), order.customer.name],
    [t('fulfillment'), t(order.customer.fulfillment)],
    [t('total'), formatMoney(order.total)],
  ];

  async function copyLink() {
    try {
      await navigator.clipboard.writeText(window.location.href);
      setCopied(true);
    } catch {
      setCopied(false);
    }
  }

  return (
    <div className="mx-auto flex w-full max-w-md flex-col items-center gap-6 rounded-3xl border border-divider bg-surface px-6 py-9 text-center">
      <div className="flex size-16 items-center justify-center rounded-full bg-ink text-white">
        <Smartphone className="size-8" />
      </div>
      <div className="flex flex-col gap-2">
        <h1 className="text-2xl font-bold tracking-tight">{t('title')}</h1>
        <p className="text-base leading-relaxed text-secondary">{t('message')}</p>
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
        <a href={posIntentUrl(data)} className={buttonClasses('primary', 'lg')}>
          <Smartphone className="size-5" />
          {t('open')}
        </a>
        <button type="button" onClick={copyLink} className={buttonClasses('secondary', 'lg')}>
          <Copy className="size-5" />
          {t('copy')}
        </button>
        {copied && <p className="text-sm text-secondary">{t('copied')}</p>}
      </div>
    </div>
  );
}
