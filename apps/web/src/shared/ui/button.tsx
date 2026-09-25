import { type ComponentProps, forwardRef } from 'react';

import { cn } from '@/shared/lib/cn';

type Variant = 'primary' | 'secondary' | 'ghost' | 'success';
type Size = 'md' | 'lg';

const variants: Record<Variant, string> = {
  primary: 'bg-ink text-white hover:bg-ink-strong disabled:bg-divider disabled:text-placeholder',
  secondary:
    'border border-border-soft bg-surface text-primary hover:border-ink hover:bg-ink hover:text-white disabled:opacity-50',
  ghost: 'bg-transparent text-secondary hover:bg-surface-muted hover:text-primary',
  success: 'bg-success text-white hover:bg-success-text',
};

const sizes: Record<Size, string> = {
  md: 'h-11 px-5 text-[15px]',
  lg: 'h-14 px-6 text-base',
};

export interface ButtonProps extends ComponentProps<'button'> {
  variant?: Variant;
  size?: Size;
}

/** Class names of a button, for links that look like one. */
export function buttonClasses(variant: Variant = 'primary', size: Size = 'md'): string {
  return cn(
    'inline-flex items-center justify-center gap-2 rounded-full font-semibold transition-colors',
    'disabled:cursor-not-allowed',
    variants[variant],
    sizes[size],
  );
}

/** Pill button in the POS style: charcoal primary, outlined secondary. */
export const Button = forwardRef<HTMLButtonElement, ButtonProps>(function Button(
  { variant = 'primary', size = 'md', className, type = 'button', ...props },
  ref,
) {
  return (
    <button
      ref={ref}
      type={type}
      className={cn(buttonClasses(variant, size), className)}
      {...props}
    />
  );
});
