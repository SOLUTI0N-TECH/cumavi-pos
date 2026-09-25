'use client';

import Link from 'next/link';
import { useTranslations } from 'next-intl';
import { useState } from 'react';

import { formatMoney } from '@/shared/lib/money';
import { Dialog } from '@/shared/ui/dialog';
import { ProductPhoto } from '@/shared/ui/product-photo';
import type { Product } from '../domain/entities';
import { imageOf } from '../domain/product-rules';
import { PurchasePanel } from './purchase-panel';
import { useStore } from './store-context';

/**
 * Picks the variant (color, size…) of a product without leaving the
 * catalog. The photo follows the choice: picking `Azul` shows the blue one.
 */
export function QuickPickDialog({
  product,
  open,
  onOpenChange,
}: {
  product: Product;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}) {
  const t = useTranslations('product');
  const store = useStore();
  const [imageId, setImageId] = useState<string | undefined>();
  const photo =
    product.images.find((image) => image.id === imageId)?.src ?? imageOf(product);

  return (
    <Dialog
      open={open}
      onOpenChange={onOpenChange}
      title={product.name}
      description={formatMoney(product.price)}
      closeLabel={t('close')}
    >
      <div className="flex gap-4">
        <ProductPhoto
          src={photo}
          alt={product.name}
          sizes="112px"
          className="w-28 shrink-0"
        />
        <div className="flex flex-col justify-center gap-2">
          <p className="line-clamp-3 text-[15px] text-secondary">{product.description}</p>
          <Link
            href={`/${store.slug}/p/${product.slug}`}
            className="text-[15px] font-semibold text-info-text underline-offset-4 hover:underline"
          >
            {t('viewDetails')}
          </Link>
        </div>
      </div>
      <PurchasePanel
        key={open ? 'open' : 'closed'}
        product={product}
        onImageChange={setImageId}
        onAdded={() => onOpenChange(false)}
      />
    </Dialog>
  );
}
