import Image from 'next/image';

import { cn } from '@/shared/lib/cn';

/** Square product photo on the light background the POS uses. */
export function ProductPhoto({
  src,
  alt,
  sizes,
  priority = false,
  className,
}: {
  src: string;
  alt: string;
  /** `sizes` hint for next/image, e.g. `(min-width: 1024px) 25vw, 50vw`. */
  sizes: string;
  priority?: boolean;
  className?: string;
}) {
  return (
    <div
      className={cn(
        'relative aspect-square overflow-hidden rounded-xl bg-surface-muted',
        className,
      )}
    >
      <Image
        src={src}
        alt={alt}
        fill
        sizes={sizes}
        priority={priority}
        className="object-cover"
      />
    </div>
  );
}
