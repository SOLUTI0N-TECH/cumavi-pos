'use client';

import { useTranslations } from 'next-intl';
import { useEffect, useState } from 'react';

import { StatusPill } from '@/shared/ui/status-pill';
import type { Store } from '../domain/entities';
import { storeStatus, type StoreStatus } from '../domain/store-hours';

type Weekday = '1' | '2' | '3' | '4' | '5' | '6' | '7';

/**
 * "Abierto · cierra 20:00" / "Cerrado · abre lun 09:00", computed in the
 * browser (the page itself is static) and refreshed every minute.
 */
export function StoreStatusPill({ store, detailed = true }: { store: Store; detailed?: boolean }) {
  const t = useTranslations('store');
  const weekdays = useTranslations('weekdays');
  const [status, setStatus] = useState<StoreStatus | null>(null);

  useEffect(() => {
    const update = () => setStatus(storeStatus(store));
    update();
    const timer = window.setInterval(update, 60_000);
    return () => window.clearInterval(timer);
  }, [store]);

  if (!status) return <span className="h-7 w-24" aria-hidden />;

  if (status.open) {
    return (
      <StatusPill tone="success" dot>
        {detailed ? t('openUntil', { time: status.closes }) : t('open')}
      </StatusPill>
    );
  }
  const opensAt = status.opensAt;
  return (
    <StatusPill tone="neutral" dot>
      {detailed && opensAt
        ? t('closedUntil', {
            day: weekdays(String(opensAt.day) as Weekday),
            time: opensAt.time,
          })
        : t('closed')}
    </StatusPill>
  );
}
