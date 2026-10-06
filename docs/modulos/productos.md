# Productos y variantes

## 0. Ficha

| | |
|---|---|
| Fase backend | B2 |
| Features móviles | F6 (hecha, se conecta), F7, F20, F23 |
| Depende de | [categorías](categorias.md), [archivos](archivos-y-notificaciones.md) |
| Estado | Planificado |

## 1. Objetivo

Un **catálogo único por negocio** que sirva para cualquier rubro (ropa con
tallas y colores, ferretería con medidas, veterinaria con presentaciones), con
códigos propios (SKU), códigos de barras (UPC/EAN), varias fotos y precios por
variante y por sucursal. Es el contrato que comparten el POS, la web y el futuro
marketplace.

## 2. Alcance v1

- Producto: nombre, categoría, descripción, precio base, costo por defecto,
  fotos ordenadas, activo, visible en línea.
- **Opciones y valores** (ej. Color: Rojo, Azul; Talla: 38, 40), ordenados.
- **Variantes** = combinaciones de valores. Cada una con clave determinística
  (`rojo/40`), precio opcional (F7), costo, foto asociada, SKU y código de
  barras.
- **Variante por defecto** oculta para productos simples.
- Búsqueda por nombre, categoría, valor de variante, SKU o código de barras
  (3+ caracteres, sin importar tildes).
- Búsqueda por código exacto (escáner).
- Sugerir SKU (`CAL-013`, `CAL-013-ROJ-38`).
- Precio por sucursal (opcional) para el producto o una variante.
- Subir, ordenar y borrar fotos.
- Archivar productos (sin borrado definitivo si tiene historial).

## 3. Fuera de alcance

- Unidades de medida y cantidades fraccionarias (kg, m) → posterior.
- Combos y kits → posterior (existe en LaCase).
- Impuestos por producto → con facturación SIN.
- Importación masiva por Excel → posterior (muy pedido; candidato a B10).
- Marca, atributos de búsqueda o taxonomía del marketplace → fase 2.

## 4. Reglas de negocio

- **PRO-R1** Nombre ≥ 3 caracteres (`productNameTooShort`); categoría
  obligatoria y no archivada (`categoryRequired`).
- **PRO-R2** Precio de venta > 0 (`invalidSalePrice`); costo ≥ 0
  (`negativeCostPrice`). El costo puede ser mayor que el precio solo como
  advertencia: el backend lo acepta; la app avisa (`costAbovePrice` sigue
  siendo validación de la app).
- **PRO-R3** Opciones: nombres únicos sin importar mayúsculas, al menos un
  valor cada una, valores únicos (`incompleteVariantOptions`). Las variantes son
  todas las combinaciones; se pueden desactivar las que no existen.
- **PRO-R4** La clave de la variante es la lista de valores en minúsculas unida
  con `/`, en el orden de las opciones. Se mantiene estable al editar; renombrar
  un valor cambia el `label` pero no el `id` de la variante.
- **PRO-R5** Quitar una variante con stock en alguna sucursal genera un
  movimiento `adjustment` con motivo `variant_removed` por cada sucursal (cierra
  el hueco conocido de la app). La variante queda con `deleted_at`.
- **PRO-R6** Pasar de simple a con variantes: el stock de la variante por
  defecto se descuenta con `variant_removed`, salvo que el request indique a qué
  variante nueva moverlo. Al revés, se crea una nueva variante por defecto con
  stock 0.
- **PRO-R7 Códigos.** Se guardan sin espacios y en mayúsculas. SKU
  `^[A-Z0-9._-]{2,32}$` (`invalidSku`); código de barras `^[A-Z0-9./-]{4,32}$`
  (`invalidBarcode`). **Únicos en todo el negocio**: SKU y código de barras,
  de producto o de variante, comparten espacio de nombres
  (`productCodeTaken`); repetidos dentro del mismo request →
  `productCodeRepeated`. Los códigos de productos archivados siguen reservados.
- **PRO-R8** En un producto con variantes, los códigos van en las variantes; el
  SKU de producto es opcional y sirve como prefijo.
- **PRO-R9 Precio vigente**: sucursal + variante → sucursal + producto →
  precio de variante → precio base.
- **PRO-R10** Editar un producto **no cambia stock** (el stock tiene sus propios
  endpoints). Crear un producto puede incluir stock inicial por sucursal, que
  se registra como movimiento `initial`.
- **PRO-R11** Fotos: JPG, PNG o WebP de hasta 5 MB; máximo 10 por producto; la
  primera es la principal; una variante puede apuntar a una foto de su
  producto.
- **PRO-R12** El costo y el margen solo salen con `product.view_cost`, y nunca en
  la API pública.
- **PRO-R13** Archivar un producto lo oculta del POS y de la web; sus ventas y
  movimientos se mantienen. No se puede vender un producto archivado.

## 5. Estados

`activo ⇄ archivado`. `show_online` es independiente (un producto activo puede
no mostrarse en la web).

## 6. Tablas

`products`, `product_options`, `product_option_values`, `product_variants`,
`product_variant_values`, `product_codes`, `product_images`,
`branch_price_overrides`. Ver [modelo de datos](../modelo-de-datos.md) §3.

## 7. Endpoints

| Método | Ruta | Permiso | Descripción |
|---|---|---|---|
| GET | `/v1/products?q&categoryId&stockLevel&includeArchived&page&limit` | `product.view` | Lista con stock de la sucursal actual y precio vigente |
| GET | `/v1/products/{id}` | `product.view` | Detalle con opciones, variantes, códigos, fotos, stock por sucursal (si `stock.view_all_branches`) |
| POST | `/v1/products` | `product.create` | Producto completo con opciones, variantes, códigos y stock inicial |
| PUT | `/v1/products/{id}` | `product.update` | Reemplaza datos, opciones, variantes y códigos (no stock) |
| PATCH | `/v1/products/{id}` | `product.update` / `product.archive` | `isActive`, `showOnline`, `categoryId` |
| GET | `/v1/products/lookup?code=` | `product.view` | `{product, variantId?}`; 404 `productCodeNotFound` |
| GET | `/v1/products/suggest-sku?categoryId=` | `product.create` | `{sku}` |
| GET | `/v1/products/low-stock` | `product.view` | Variantes con stock ≤ umbral en la sucursal |
| POST | `/v1/products/{id}/images` | `product.update` | Multipart, devuelve `{id, url}` |
| PUT | `/v1/products/{id}/images/order` | `product.update` | `{ids: []}` |
| DELETE | `/v1/products/{id}/images/{imageId}` | `product.update` | |
| PUT | `/v1/branches/{branchId}/prices` | `product.branch_price` | `[{productId, variantId?, price \| null}]` (null quita el precio de sucursal) |

Producto en la respuesta (resumen):

```json
{ "id": "…", "name": "Zapatillas urbanas", "categoryId": "…", "description": "…",
  "salePrice": 450, "costPrice": 280, "hasVariants": true, "isActive": true, "showOnline": true,
  "sku": "CAL-001", "barcode": null,
  "images": [{"id": "…", "url": "https://…"}],
  "options": [{"name": "Color", "values": ["Rojo", "Azul"]}, {"name": "Talla", "values": ["38", "40"]}],
  "variants": [{"id": "uuid", "key": "rojo/38", "optionValues": {"Color": "Rojo", "Talla": "38"},
                "price": 450, "costPrice": 280, "stock": 3, "imageId": "…",
                "sku": "CAL-001-ROJ-38", "barcode": "7771234567890"}],
  "stock": 12, "createdAt": "2026-10-05T14:00:00Z" }
```

`stock` es el de la sucursal del header. `price` de la variante ya es el precio
vigente. `costPrice` desaparece sin permiso.

## 8. Errores

`productNotFound`, `variantNotFound`, `productCodeNotFound` (404);
`productNameTooShort`, `categoryRequired`, `invalidSalePrice`,
`negativeCostPrice`, `incompleteVariantOptions`, `invalidSku`, `invalidBarcode`,
`productCodeRepeated` (422); `productCodeTaken` (409).

## 9. Permisos

`product.view`, `product.create`, `product.update`, `product.archive`,
`product.view_cost`, `product.branch_price`.

## 10. Eventos

`product.updated` → invalida el cache del catálogo público. (Fase 2: indexar en
el buscador del marketplace.)

## 11. Concurrencia y auditoría

- `PUT /products/{id}` es una transacción: opciones, variantes y códigos se
  reemplazan juntos; las variantes se emparejan por `key`.
- Unicidad de códigos garantizada por `UQ_product_codes_business_code`.
- Auditoría: `product.price_changed`, `product.cost_changed`,
  `product.archived`.

## 12. Impacto en la app POS

- F20: `ProductDataSource` → API. La búsqueda y los filtros pasan al servidor
  (paginado).
- F23: la app deja de calcular el id de la variante; usa el `id` (uuid) del
  servidor y la `key` para mostrar. Productos simples: ocultar la variante por
  defecto.
- F7: precio por variante en el formulario.
- Subida de fotos: la app sube la imagen ya recortada o con fondo blanco (el
  quitado de fondo sigue siendo en el celular).
- Nueva opción "Precio en esta sucursal" en el detalle (con permiso).

## 13. Impacto en la web

`Product.variants[]` gana `price` (precio por variante); `images[].src` pasa a
URL del servidor; `ProductVariant.id` pasa a uuid (la URL del producto usa el
`slug`). Nunca `costPrice`.

## 14. Origen en LaCase

`src/product/*` tiene un modelo distinto (producto global + `products_branches`
con precio y stock por sucursal, sin variantes). Se reutiliza la estructura del
módulo, el multipart de imágenes y los filtros de listado
(`products-branches.service.ts`). El modelo de variantes y códigos es nuevo.

## 15. Criterios de aceptación

- Dado el código `7771234567890` en una variante, cuando otro producto intenta
  usarlo como SKU, entonces responde 409 `productCodeTaken`.
- `GET /products/lookup?code=CAL-001-ROJ-38` devuelve el producto y el
  `variantId` de Rojo/38.
- Dada una variante con 3 unidades en la sucursal A, cuando se quita al editar,
  entonces queda un movimiento `-3 variant_removed` en A.
- Dado un precio de sucursal para Talla 40 en B, cuando se pide el producto con
  `x-branch-id: B`, entonces esa variante muestra el precio de sucursal y las
  demás el general.
- Un usuario sin `product.view_cost` nunca recibe `costPrice`.

## 16. Preguntas abiertas

- ¿Se necesita en v1 importar productos desde Excel? (afecta B2 o B10)
- ¿Unidades fraccionarias para ferreterías (metros de cable)? Se deja para
  después; documentar en la venta piloto.
