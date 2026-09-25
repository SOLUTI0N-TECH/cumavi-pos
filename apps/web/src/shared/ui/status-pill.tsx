import type { ReactNode } from 'react';

import { cn } from '@/shared/lib/cn';

type Tone = 'success' | 'warning' | 'error' | 'neutral' | 'info';

const tones: Record<Tone, string> = {
  success: 'bg-success-surface text-success-text',
  warning: 'bg-warning-surface text-warning-text',
  error: 'bg-error-surface text-error-text',
  neutral: 'bg-surface-muted text-secondary',
  info: 'bg-info-surface text-info-text',
};

const dots: Record<Tone, string> = {
  success: 'bg-success',
  warning: 'bg-warning',
  error: 'bg-error',
  neutral: 'bg-placeholder',
  info: 'bg-info',
};

/** Small tinted label, optionally with a status dot. */
export function StatusPill({
  tone,
  dot = false,
  children,
  className,
}: {
  tone: Tone;
  dot?: boolean;
  children: ReactNode;
  className?: string;
}) {
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-[13px] font-semibold',
        tones[tone],
        className,
      )}
    >
      {dot && <span className={cn('size-2 rounded-full', dots[tone])} aria-hidden />}
      {children}
    </span>
  );
}
