'use client';

import { Minus, Plus } from 'lucide-react';
import { useTranslations } from 'next-intl';

import { cn } from '@/shared/lib/cn';

export interface QuantityStepperProps {
  quantity: number;
  onDecrement: () => void;
  onIncrement: () => void;
  canIncrement?: boolean;
  canDecrement?: boolean;
  /** Accessible names of the buttons, e.g. mentioning the product. */
  decrementLabel?: string;
  incrementLabel?: string;
  size?: 'md' | 'lg';
  className?: string;
}

/** `− 2 +` in the POS style: light pill, charcoal plus. */
export function QuantityStepper({
  quantity,
  onDecrement,
  onIncrement,
  canIncrement = true,
  canDecrement = true,
  decrementLabel,
  incrementLabel,
  size = 'md',
  className,
}: QuantityStepperProps) {
  const t = useTranslations('quantity');
  const button = size === 'lg' ? 'size-11' : 'size-9';

  return (
    <div
      className={cn(
        'inline-flex items-center gap-2 rounded-full bg-background p-1',
        className,
      )}
    >
      <button
        type="button"
        onClick={onDecrement}
        disabled={!canDecrement}
        aria-label={decrementLabel ?? t('decrease')}
        className={cn(
          button,
          'flex items-center justify-center rounded-full bg-surface text-primary shadow-sm transition hover:bg-surface-muted disabled:opacity-40',
        )}
      >
        <Minus className="size-4" strokeWidth={2.4} />
      </button>
      <span
        className="min-w-8 flex-1 text-center text-base font-bold tabular-nums"
        aria-live="polite"
      >
        {quantity}
      </span>
      <button
        type="button"
        onClick={onIncrement}
        disabled={!canIncrement}
        aria-label={incrementLabel ?? t('increase')}
        className={cn(
          button,
          'flex items-center justify-center rounded-full bg-ink text-white transition hover:bg-ink-strong disabled:bg-divider disabled:text-placeholder',
        )}
      >
        <Plus className="size-4" strokeWidth={2.4} />
      </button>
    </div>
  );
}
