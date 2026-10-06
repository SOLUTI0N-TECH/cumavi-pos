# Roles y permisos

## 0. Ficha

| | |
|---|---|
| Fase backend | B1 (catálogo, plantillas, guards), B8 (CRUD de roles) |
| Features móviles | F14 |
| Depende de | [usuarios](usuarios.md) |
| Estado | Planificado |

## 1. Objetivo

Controlar qué puede hacer cada miembro, **aplicado en el servidor** (en LaCase
los permisos de negocio solo ocultaban botones en la app).

## 2. Alcance v1

- Catálogo global de permisos `recurso.acción`, sembrado por migración o seeder.
- 4 plantillas de rol que se copian a cada negocio nuevo y se pueden editar.
- Crear, editar y borrar roles propios del negocio.
- `@RequirePermission(...)` en cada endpoint.

## 3. Fuera de alcance

- Permisos por registro individual (ej. "solo esta categoría") → no previsto.
- Aprobación con PIN del encargado para acciones sensibles → posterior.

## 4. Reglas de negocio

- **ROL-R1** Los permisos son globales; los roles son por negocio.
- **ROL-R2** Cada permiso tiene alcance **negocio** o **sucursal**. Uno de
  sucursal solo vale en las sucursales permitidas al miembro.
- **ROL-R3** El dueño no depende de su rol: tiene todo.
- **ROL-R4** No se puede borrar un rol con miembros asignados; primero hay que
  reasignarlos.
- **ROL-R5** Las plantillas `is_system` se pueden editar pero no borrar.
- **ROL-R6** Cambiar los permisos de un rol aplica en menos de 60 s (cache
  invalidado por evento).

## 5. Estados

Sin estados (un rol existe o se borra).

## 6. Tablas

`roles`, `permissions`, `role_permissions`. Ver
[modelo de datos](../modelo-de-datos.md) §2.

### Catálogo de permisos

Alcance: **N** = negocio, **S** = sucursal; * = sensible (va a auditoría).

| Módulo | Permisos |
|---|---|
| Negocio | `business.update` N, `business.settings` N |
| Sucursales | `branch.manage` N, `cash_register.manage` S |
| Equipo | `member.view` N, `member.invite` N, `member.update` N, `member.remove` N, `role.manage` N |
| Categorías | `category.manage` N |
| Productos | `product.view` N, `product.create` N, `product.update` N, `product.archive` N, `product.view_cost`* N, `product.branch_price` S |
| Inventario | `stock.view_all_branches` N, `stock.receive` S, `stock.adjust`* S, `stock.transfer_send` S, `stock.transfer_receive` S, `stock.movements_view` S, `stock.count` S (B10), `stock.count_apply`* S (B10) |
| Métodos de pago | `payment_method.manage` N |
| Caja | `cash.open` S, `cash.close` S, `cash.movement` S, `cash.view_expected` S, `cash.view_all_sessions` S |
| Ventas | `sale.create` S, `sale.discount` S, `sale.view_own` S, `sale.view_all` S, `sale.cancel`* S, `sale.return`* S |
| Clientes | `customer.view` N, `customer.manage` N |
| Compras | `supplier.manage` N, `purchase.view` N, `purchase.create` N, `purchase.confirm` N, `purchase.receive` S, `purchase.pay` N, `purchase.cancel` N |
| Ecommerce | `store.settings` N, `order.view` S, `order.manage` S, `order.convert` S |
| Reportes (B10) | `report.sales` N, `report.financial`* N |

### Plantillas

| Permiso / grupo | Administrador | Encargado de sucursal | Cajero / Vendedor | Almacén |
|---|---|---|---|---|
| Sucursales por defecto | todas | asignadas | asignadas | asignadas |
| `business.*`, `role.manage`, `payment_method.manage`, `branch.manage` | ✔ | — | — | — |
| `member.view` | ✔ | ✔ | — | — |
| `member.invite/update/remove` | ✔ | — | — | — |
| `category.manage`, `product.create/update` | ✔ | ✔ | — | ✔ |
| `product.view` | ✔ | ✔ | ✔ | ✔ |
| `product.archive` | ✔ | — | — | — |
| `product.view_cost` | ✔ | ✔ | — | — |
| `product.branch_price` | ✔ | ✔ | — | — |
| `stock.receive/adjust/transfer_*/movements_view` | ✔ | ✔ | — | ✔ |
| `stock.view_all_branches` | ✔ | ✔ | — | ✔ |
| `cash.open/close/movement` | ✔ | ✔ | ✔ | — |
| `cash.view_expected`, `cash.view_all_sessions` | ✔ | ✔ | — (cierre ciego) | — |
| `cash_register.manage` | ✔ | ✔ | — | — |
| `sale.create/discount/view_own` | ✔ | ✔ | ✔ | — |
| `sale.view_all`, `sale.cancel`, `sale.return` | ✔ | ✔ | — | — |
| `customer.view/manage` | ✔ | ✔ | ✔ | — |
| `supplier.manage`, `purchase.view/create/receive` | ✔ | ✔ | — | ✔ (sin create) |
| `purchase.confirm/pay/cancel` | ✔ | — | — | — |
| `store.settings` | ✔ | — | — | — |
| `order.view/manage/convert` | ✔ | ✔ | ✔ | — |
| `report.sales` | ✔ | ✔ | — | — |
| `report.financial` | ✔ | — | — | — |

## 7. Endpoints

| Método | Ruta | Permiso |
|---|---|---|
| GET | `/v1/permissions` | miembro (catálogo agrupado por módulo) |
| GET | `/v1/roles` | `member.view` |
| POST | `/v1/roles` | `role.manage` |
| PATCH | `/v1/roles/{id}` | `role.manage` (nombre, descripción, `permissionKeys[]`) |
| DELETE | `/v1/roles/{id}` | `role.manage` |

## 8. Errores

`permissionDenied` (403, `details.permission`), `roleInUse` (409),
`roleNameTaken` (409), `systemRoleCannotBeDeleted` (409).

## 9. Permisos

`role.manage`, `member.view`.

## 10. Eventos

`role.updated` → invalida el cache de `TenantContext` de los miembros con ese
rol.

## 11. Concurrencia, idempotencia y auditoría

Cambios de rol y de permisos se auditan (`role.updated`). Implementación:

- `PermissionGuard` lee la metadata de `@RequirePermission` y compara con
  `ctx.permissions` (un `Set` cargado por `TenantGuard`).
- Los permisos de sucursal se validan junto con `BranchGuard`.
- Los mappers de respuesta consultan `ctx.can('product.view_cost')` para incluir
  o quitar costo y margen.

## 12. Impacto en la app POS

- F14: pantalla de roles (lista de permisos agrupados con switches).
- La app usa los permisos de `/me/memberships` para ocultar botones (anular,
  ver costo, cierre con esperado).

## 13. Impacto en la web

Ninguno.

## 14. Origen en LaCase

`src/role/entities/*` (role, permission, role_permission) y
`database/seeders/permission.seeder.ts` (nombres `recurso.acción`). Se agregan
`scope`, `module`, `is_sensitive` y el guard. Del módulo `src/superadmin/*` se
copia el patrón `@RequireSuperAdminPermission` → `@RequirePermission`.

## 15. Criterios de aceptación

- Dado un cajero sin `sale.cancel`, cuando llama a `POST /sales/{id}/cancel`,
  entonces responde 403 `permissionDenied`.
- Dado un usuario sin `product.view_cost`, cuando pide `/products`, entonces la
  respuesta no contiene `costPrice`.
- Cuando se quita un permiso a un rol, entonces en menos de 60 s los miembros
  con ese rol reciben 403 en esa acción.

## 16. Preguntas abiertas

- ¿Se permite que el cajero anule con PIN del encargado en el momento?
  (posterior)
