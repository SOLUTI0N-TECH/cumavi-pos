# Categorías

## 0. Ficha

| | |
|---|---|
| Fase backend | B2 |
| Features móviles | F2 (hecha, se conecta) |
| Depende de | [auth y negocio](auth-y-negocio.md) |
| Estado | Planificado (contrato ya definido por la app) |

## 1. Objetivo

Que cada negocio organice su catálogo con sus propias categorías, ordenadas a
su gusto, sin perder historial al dejar de usarlas.

## 2. Alcance v1

- Crear, renombrar, reordenar, archivar y restaurar.
- Conteo de productos por categoría.
- Categorías iniciales desde el registro (según el tipo de negocio).
- Visibles en el catálogo web solo si tienen productos visibles en línea.

## 3. Fuera de alcance

- Subcategorías (un solo nivel en v1). Si hace falta, se agrega `parent_id`.
- Categorías globales del marketplace (taxonomía común) → fase 2; cada
  categoría del negocio se podrá mapear a una global.
- Imagen o ícono por categoría → posterior.

## 4. Reglas de negocio

- **CAT-R1** Nombre de 2–30 caracteres (`categoryNameInvalid`).
- **CAT-R2** Único en el negocio sin importar mayúsculas ni tildes, incluidas
  las archivadas (`categoryNameTaken`). Se compara `name_normalized`, generado
  con el mismo criterio que `TextNormalizer` de la app.
- **CAT-R3** No hay borrado definitivo: archivar la oculta de los selectores y
  del catálogo web, pero sus productos la conservan.
- **CAT-R4** Una categoría nueva va al final (`sort_order` = máximo + 1).
- **CAT-R5** Reordenar recibe la lista completa de ids no archivados; ids
  faltantes o ajenos → `categoryNotFound`.
- **CAT-R6** Todo producto tiene categoría (`categoryRequired`); no se puede
  asignar una archivada a un producto nuevo.

## 5. Estados

`activa ⇄ archivada`.

## 6. Tablas

`categories`. Ver [modelo de datos](../modelo-de-datos.md) §3.

## 7. Endpoints (contrato de F2)

| Método | Ruta | Permiso | Descripción |
|---|---|---|---|
| GET | `/v1/categories?includeArchived=` | `product.view` | `[{id, name, sortOrder, isArchived, productCount}]` |
| POST | `/v1/categories` | `category.manage` | `{name}` |
| PATCH | `/v1/categories/{id}` | `category.manage` | `{name?}` o `{isArchived}` |
| PUT | `/v1/categories/order` | `category.manage` | `{ids: [...]}` |

## 8. Errores

`categoryNameInvalid` (422), `categoryNameTaken` (409), `categoryNotFound`
(404), `categoryRequired` (422).

## 9. Permisos

`category.manage`, lectura con `product.view`.

## 10. Eventos

`category.updated` → invalida el cache del catálogo público.

## 11. Concurrencia

Reordenar actualiza todo en una transacción. La unicidad la garantiza el índice
único (`UQ_categories_business_name` → `categoryNameTaken`).

## 12. Impacto en la app POS

Cambiar `InMemoryProductDataSource` por la API en `getCategories`,
`createCategory`, `renameCategory`, `reorderCategories` y `setCategoryArchived`.
Sin cambios de pantalla.

## 13. Impacto en la web

`Store.categories` sale de la API (solo activas con productos en línea),
ordenadas por `sortOrder`.

## 14. Origen en LaCase

`src/product/products_categories/*` (era global, de superadmin). Pasa a ser por
negocio, con `sort_order`, `is_archived` y nombre normalizado.

## 15. Criterios de aceptación

- Dada "Calzado", cuando se crea "calzado" o "Cálzado", entonces responde 409
  `categoryNameTaken`.
- Cuando se archiva una categoría con 5 productos, entonces los productos
  conservan su categoría y la web deja de mostrarla.

## 16. Preguntas abiertas

Ninguna.
