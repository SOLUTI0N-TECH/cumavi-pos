import type { ComponentProps, ReactNode } from 'react';

import { cn } from '@/shared/lib/cn';

export interface ChipProps extends Omit<ComponentProps<'button'>, 'children'> {
  selected?: boolean;
  /** Struck through: has stock, but not with the rest of the selection. */
  crossed?: boolean;
  children: ReactNode;
  trailing?: ReactNode;
}

/** Selectable pill: categories, variant values, payment methods. */
export function Chip({
  selected = false,
  crossed = false,
  className,
  children,
  trailing,
  type = 'button',
  ...props
}: ChipProps) {
  return (
    <button
      type={type}
      aria-pressed={selected}
      className={cn(
        'inline-flex h-11 shrink-0 items-center gap-2 whitespace-nowrap rounded-full border px-4 text-[15px] font-semibold transition-colors',
        selected
          ? 'border-ink bg-ink text-white'
          : 'border-border-soft bg-surface text-ink-soft hover:border-ink hover:text-primary',
        crossed && !selected && 'text-placeholder line-through decoration-2',
        'disabled:cursor-not-allowed disabled:border-divider disabled:bg-surface-muted disabled:text-placeholder disabled:line-through',
        className,
      )}
      {...props}
    >
      {children}
      {trailing}
    </button>
  );
}
