import { SearchX } from 'lucide-react';
import Link from 'next/link';
import { getTranslations } from 'next-intl/server';

import { buttonClasses } from '@/shared/ui/button';
import { EmptyState } from '@/shared/ui/empty-state';

export default async function NotFound() {
  const t = await getTranslations('notFound');

  return (
    <main className="mx-auto flex min-h-dvh max-w-md items-center px-4">
      <EmptyState
        className="w-full"
        icon={<SearchX className="size-7" />}
        title={t('title')}
        message={t('message')}
        action={
          <Link href="/" className={buttonClasses('primary', 'lg')}>
            {t('action')}
          </Link>
        }
      />
    </main>
  );
}
