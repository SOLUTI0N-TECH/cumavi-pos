# Reutilización de LaCase

`lacase-backend` (`D:\developer\lacase\lacase-backend`) es la base técnica:
NestJS 11 + Fastify + TypeORM + Postgres, el mismo autor y las mismas
convenciones. **No se modifica**; se copian archivos a `cumavi-shop-backend` y
se adaptan.

## Reglas

1. **Copiar desde LaCase HEAD**, no desde lo que hoy tiene
   `cumavi-shop-backend`: este último es un clon viejo de LaCase (sin compras,
   reportes, superadmin ni varias correcciones) con un refactor a medias que no
   compila.
2. Lo específico de billar y restaurante no se copia.
3. Todo lo copiado pasa a `timestamptz`, dinero en centavos para cálculos,
   respuestas con DTOs en camelCase y permisos aplicados con
   `@RequirePermission`.
4. El `CLAUDE.md` de LaCase (trampas de DI, transacciones, envelope) se adapta
   como `CLAUDE.md` del nuevo backend.

## Estado actual de `cumavi-shop-backend` (qué hacer en B0)

| Hallazgo | Acción |
|---|---|
| No es repositorio git | `git init` con remote nuevo de Cumavi |
| `src/store/`, `src/profile/` a medias (Store, Profile, ProfileAddress) | Se reemplazan por `businesses` + `memberships`; guardar una copia aparte antes de borrar |
| Seeders importan módulos borrados (`business`, `pos`) | Borrar y reescribir |
| `ProfilesService` usa `branch` que ya no existe; DI rota en Profile, Firebase, Websocket y Product | Se reescriben con el nuevo modelo |
| Migraciones = esquema viejo de LaCase (mesas, turnos, partners) | Borrar todas; una migración inicial nueva |
| `package.json` "lacase-backend", docker `lacase-*`, `.env.template` con `JWT_SECRET=lacase` y `NODE_ENV=dev` inválido | Renombrar y corregir |
| `google-services.json` en la raíz (proyecto Firebase de LaCase) | Sacar del repo; crear un proyecto Firebase de Cumavi |
| `dist/` viejo | Borrar |

## Copiar tal cual

| Archivo de LaCase | Uso |
|---|---|
| `src/common/response/response.interceptor.ts` | Envelope `{ok, statusCode, message, data}` |
| `src/common/decorators/response-message.decorator.ts` | |
| `src/common/dtos/pagination.dto.ts` | Se agrega paginación por cursor aparte |
| `src/common/interceptors/fastify-multipart.interceptor.ts` | Subidas |
| `src/logging/*` | pino + correlation id |
| `src/auth/decorators/get-user.decorator.ts`, `raw-headers.decorator.ts` | |
| `src/superadmin/*` | Entidades, guards, decoradores, constantes |
| `src/database/seeders/seeder.ts`, `seeder.interface.ts`, seeders de superadmin | Runner de seeders |
| Inicialización de `typeorm-transactional` en `main.ts` y `app.module.ts` | |

## Adaptar

| Archivo de LaCase | Cambio |
|---|---|
| `src/config/envs.config.ts` | TTL de tokens, superadmin por correo, Firebase (solo push), `STORAGE_DRIVER`, `PUBLIC_BASE_URL`, `CORS_ORIGINS` |
| `src/main.ts`, `src/app.module.ts` | Prefijo `/v1`, guards globales, Swagger, throttler global |
| `src/common/http-exception/http-exception.filter.ts` | Agregar `code`, `details` y mapeo de errores de Postgres por constraint |
| `src/database/datasource.config.ts` | Igual, con migración inicial nueva |
| `src/database/seeders/permission.seeder.ts`, `role.seeder.ts`, `role-permission.seeder.ts` | Catálogo de [roles](modulos/roles.md) y plantillas |
| `src/auth/auth.service.ts`, `strategies/jwt.strategy.ts`, `guards/jwt.guard.ts` | Se conserva la idea del login con correo y contraseña; bcrypt → scrypt de `node:crypto`, bloqueo por intentos, refresh rotativo (patrón de `auth_sso_codes`), guard global con `@Public` |
| `src/user/entities/user.entity.ts`, `src/user/devices/*` | Correo único + `password_hash`; celular de contacto |
| `src/firebase/firebase.service.ts` | Solo push (B7); credenciales por variable de entorno |
| `src/notification/*`, `src/websocket/*` | Salas `user:` / `business:` / `branch:`; handshake con membresía |
| `src/files/files.service.ts` | Pasa a `LocalStorageProvider` detrás de `StorageProvider` + tabla `files` |
| `src/business/entities/business.entity.ts`, `branch.entity.ts`, servicios | slug, estado, tipo, NIT; flags de tienda en línea; horarios |
| `src/business/businesses/controllers/businesses-admin.controller.ts` | Al módulo de plataforma |
| `src/role/entities/*`, `src/role/services/*` | Roles por negocio, permisos con `scope` y `module`; `PermissionGuard` nuevo |
| `src/user/profiles/guards/profile.guard.ts` | Inspira `TenantGuard` y `BranchGuard` (headers `x-business-id` y `x-branch-id`) |
| `src/product/products_categories/*` | Por negocio, `sort_order`, archivar, nombre normalizado |
| `src/product/products_branches/services/products-branches.service.ts` | `applyStockDelta` y `adjustStock` (UPDATE atómico) → `StockService`; `receivePurchaseStock` y modos de costo → `CostService` |
| `src/pos/entities/pos-session.entity.ts`, `src/pos/pos_sessions/*` | `cash_sessions` por caja, sin turnos ni `closing_control` |
| `src/pos/entities/pos-cash-movements.entity.ts`, `src/pos/pos_cash_movements/*` | Sin `shift_id` ni `reservation_id`; con `reason` |
| `src/pos/entities/pos-payment-method.entity.ts`, `src/pos/pos_payment_methods/*` | Por negocio, con `type` |
| `src/pos/entities/pos-order*.entity.ts`, `src/pos/pos_orders/services/pos-orders.service.ts` | → `sales`, `sale_lines`, `sale_payments`. Reutilizar `createQuickOrder` y `parseAndValidatePayments` |
| `src/pos/helpers/order-totals.helper.ts` | Puro, sin cargo por servicio ni tiempo; prorrateo en centavos |
| `src/pos/entities/pos-setting.entity.ts`, `src/pos/enums/product-cost-mode.enum.ts` | Solo `cost_update_mode` pasa a `business_settings` |
| `src/partner/entities/partner.entity.ts`, `src/partner/partners/*` | → `customers` |
| `src/purchase/*` | Líneas por variante, recepciones parciales, pagos con métodos del negocio, `document_sequences` |
| `src/purchase/constants/purchase-order-number.constant.ts` | Formateador genérico de números |
| `src/inventory/adjustments/*` | → `inventory_counts` (B10) |
| `src/reports/shared/helpers/*`, `src/reports/{sales,inventory,purchases}` | Referencia para B10 |

## Excluir

| LaCase | Motivo |
|---|---|
| `src/table/*`, `src/pos/pos_table_status/*` | Mesas, zonas, QR de mesa, IoT |
| `src/pos/reservations/*`, `reservations.entity.ts` | Reservas de billar |
| `src/pos/pos_shifts/*`, `pos-shift.entity.ts`, `business/branches_shifts` | Sin turnos |
| `pos-time-tracking.entity.ts`, `time-rounding.helper.ts` | Tiempo de mesa |
| `service-charge-type.enum.ts`, `pos-order-service-type.enum.ts` | Cargo por servicio |
| `pos-stock.service.ts`, `stock-deduction-mode.enum.ts` | Cumavi descuenta stock en el momento |
| `product/combo_groups` | Combos (posterior) |
| `pos-promotion.entity.ts`, `pos_promotions/*` | Promociones (F8, B11; se retomará como base) |
| Niveles y puntos de `partner` | Fidelización (posterior) |
| `business/guards/business-owner.guard.ts` | Reemplazado por `TenantGuard` + `is_owner` |
| `geography/*` | Basta con un enum de departamentos y la ciudad como texto |
| `auth-sso-code` | Solo si aparece un panel web |
| `reports/tables`, `reports/employees` | Específicos o posteriores |
| Todas las migraciones y los seeders de demo de LaCase | Esquema distinto |

## Mejoras respecto a LaCase

| LaCase | Cumavi |
|---|---|
| `timestamp` sin zona | `timestamptz` |
| Números con `MAX()+1` | `document_sequences` sin repetidos |
| Permisos de negocio solo en la app | `PermissionGuard` en el servidor |
| Entidades devueltas tal cual (snake_case) | DTOs en camelCase, campos sensibles filtrados |
| Error sin `code` | `code` = `FailureCode` de la app |
| Sin tests | Tests de invariantes (stock, caja, pagos, devoluciones, numeración) |
| Sin Swagger | Swagger fuera de producción |
| Sin idempotencia | UUID del cliente + `Idempotency-Key` |
