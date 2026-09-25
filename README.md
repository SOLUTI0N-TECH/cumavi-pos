# CUMAVI POS

Un solo repositorio para el punto de venta y el catálogo de pedidos:

| Carpeta | Qué es | Tecnología |
|---|---|---|
| `apps/mobile` | App POS del dueño de la tienda: ventas, caja, inventario con variantes | Flutter 3.47.4 (fvm) |
| `apps/web` | Catálogo público de cada tienda: el cliente arma su pedido sin cuenta | Next.js 16 + TypeScript |
| `packages/mock-catalog` | Tiendas y productos de demo (los mismos del POS) + fotos | JSON |
| `packages/design-tokens` | Colores y radios del POS para la web | CSS |

Todavía no hay backend: las dos apps usan datos simulados detrás de
interfaces (repositorios), así conectar la API solo cambia la capa de datos.

## Requisitos

- Node 22 (`.nvmrc`) y pnpm 10. Una sola vez, en una terminal como
  administrador: `corepack enable` (Turborepo necesita `pnpm` en el PATH).
- Flutter con [fvm](https://fvm.app): `apps/mobile/.fvmrc` fija la versión.

## Comandos

```bash
pnpm install            # dependencias de la web y los paquetes
pnpm dev                # catálogo en http://localhost:3000
pnpm build              # build de producción de la web
pnpm lint               # ESLint
pnpm typecheck          # TypeScript
pnpm test               # pruebas (Vitest)

cd apps/mobile
fvm flutter pub get
fvm flutter run         # POS en el celular o emulador
fvm flutter test
```

La tienda de demo está en `/illimani-store`. La raíz `/` lista las tiendas.

## Catálogo web (`apps/web`)

Recorrido del cliente, basado en el diseño de "pedido sin registro":

1. **Catálogo** `/<tienda>`: buscador (nombre, categoría, color o talla, sin
   importar tildes), categorías con conteo, vista en cuadrícula o lista.
   Los productos simples se agregan desde la tarjeta; los que tienen
   variantes abren el selector ("Elegir").
2. **Producto** `/<tienda>/p/<producto>`: galería, un valor por tipo de
   variante (color + talla), stock de esa combinación y cantidad. El link
   compartido por WhatsApp muestra foto, nombre y precio.
3. **Pedido** `/<tienda>/pedido`: líneas con la foto y la variante, resumen y
   "Finalizar pedido": nombre, celular boliviano, recojo o envío, nota y
   forma de pago.
4. **Confirmación** `/<tienda>/pedido/confirmado?n=<n°>`: resumen y botón que envía el
   pedido completo por WhatsApp a la tienda.

El carrito se guarda en el navegador (uno por tienda), así no se pierde al
recargar. Mientras no haya backend, la tienda se entera del pedido por
WhatsApp; con la API, el pedido llegará también a la app POS.

### Arquitectura

La misma organización que el POS: `src/features/<feature>/{domain,data,presentation}`.

- `domain`: entidades y reglas puras (stock, variantes, carrito, horario,
  mensaje de WhatsApp) — probadas con Vitest.
- `data`: implementaciones de los repositorios. `catalogRepository()` y
  `orderRepository()` son los únicos puntos a cambiar por la API.
- `presentation`: componentes. Las páginas (`src/app`) son del servidor y
  pasan el catálogo a los componentes cliente con `StoreProvider`.
- Textos en `apps/web/messages/es.json` (next-intl), con claves verificadas por
  TypeScript. El catálogo público nunca incluye precios de costo.
- Estilo: tokens del POS (`packages/design-tokens`) como utilidades de
  Tailwind (`bg-ink`, `text-secondary`, `rounded-xl`) y tipografía Outfit.

### Varias tiendas desde el inicio

Cada URL incluye la tienda y cada tienda tiene zona y coordenadas. Es la base
del catálogo de toda la ciudad: primero un link por tienda (esto), después
un directorio con búsqueda entre tiendas y, al final, el mapa.

## Publicar el catálogo

En línea en **https://cumavi-pos-catalogo.netlify.app** (Netlify, sitio
`cumavi-pos-catalogo`). La web se exporta estática (`output: 'export'`), así
que se sube ya compilada:

```bash
cd apps/web
NEXT_PUBLIC_SITE_URL=https://cumavi-pos-catalogo.netlify.app pnpm build
netlify deploy --prod --no-build --dir out --site 61028f07-9377-48bd-894c-a0cca39a5538
```

Cuando exista el backend (pedidos que lleguen al POS) se quita la exportación
estática para tener rutas de servidor.

## App POS (`apps/mobile`)

Ver `apps/mobile/README.md`: arquitectura limpia por feature, Cubits,
go_router, get_it, textos en ARB y servicios del celular (cámara, impresora
Bluetooth, WhatsApp).

## Datos simulados compartidos

`packages/mock-catalog/catalog.json` replica el seed del POS
(`apps/mobile/lib/features/catalog/data/datasources/catalog_seed_data.dart`).
Hasta que exista la API, si cambias uno, cambia el otro. Las fotos viven en
`packages/mock-catalog/images` y se copian a `apps/web/public/mock-catalog`
antes de `dev` y `build`.

## CI

`.github/workflows/web.yml` y `mobile.yml` corren solo cuando cambia su parte
del repositorio (lint, tipos, pruebas y build; format, analyze y pruebas en
Flutter).
