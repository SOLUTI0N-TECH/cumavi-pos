import type { ReactNode } from 'react';

import { cn } from '@/shared/lib/cn';

/** Centered icon, title, message and optional action. */
export function EmptyState({
  icon,
  title,
  message,
  action,
  dashed = false,
  className,
}: {
  icon?: ReactNode;
  title: string;
  message: string;
  action?: ReactNode;
  dashed?: boolean;
  className?: string;
}) {
  return (
    <div
      className={cn(
        'flex flex-col items-center gap-4 rounded-3xl bg-surface px-6 py-16 text-center',
        dashed ? 'border border-dashed border-border' : 'border border-divider',
        className,
      )}
    >
      {icon && (
        <div className="flex size-16 items-center justify-center rounded-full bg-background text-secondary">
          {icon}
        </div>
      )}
      <div className="flex flex-col gap-1.5">
        <p className="text-lg font-bold">{title}</p>
        <p className="max-w-sm text-[15px] text-secondary">{message}</p>
      </div>
      {action}
    </div>
  );
}
