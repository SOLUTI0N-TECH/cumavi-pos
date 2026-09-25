// Copies the shared mock catalog photos into public/ so next/image can serve
// them. Runs before `dev` and `build`; the copy is git-ignored.
import { cpSync, mkdirSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const catalogDir = dirname(require.resolve('@cumavi-pos/mock-catalog/catalog.json'));
const target = join(dirname(fileURLToPath(import.meta.url)), '..', 'public', 'mock-catalog');

mkdirSync(target, { recursive: true });
cpSync(join(catalogDir, 'images'), target, { recursive: true });
console.log(`mock catalog photos copied to ${target}`);
