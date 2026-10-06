# Plataforma (superadmin)

## 0. Ficha

| | |
|---|---|
| Fase backend | B1 (superadmin básico), B11 (planes y suscripción) |
| Features móviles | — (sin app propia en v1) |
| Depende de | [auth y negocio](auth-y-negocio.md) |
| Estado | Planificado |

## 1. Objetivo

Que el equipo de Cumavi administre la plataforma: ver los negocios registrados,
activarlos o suspenderlos, y más adelante cobrar planes.

## 2. Alcance v1

- Superadmins con roles y permisos propios (separados de los del negocio).
- Listar negocios con datos básicos y métricas (sucursales, miembros,
  productos, ventas de los últimos 30 días, último acceso).
- Suspender (con motivo) y reactivar negocios.
- Ver usuarios y desactivar una cuenta.
- Uso por API (Swagger o un panel mínimo posterior); sin pantallas en la app.

## 3. Fuera de alcance (B11)

- Planes con límites (sucursales, usuarios, productos), periodo de prueba,
  facturación y cobro de suscripción.
- Panel web de superadmin.
- Moderación de contenido del marketplace.
- Impersonar a un negocio para dar soporte.

## 4. Reglas de negocio

- **PLA-R1** Un superadmin no tiene acceso a los datos de un negocio por ser
  superadmin; solo a los endpoints `/v1/admin/*`.
- **PLA-R2** Suspender un negocio corta el acceso de todos sus miembros y
  oculta su tienda en línea; no borra datos.
- **PLA-R3** Toda acción de superadmin se audita.

## 5. Estados

Ver estados del negocio en [auth y negocio](auth-y-negocio.md).

## 6. Tablas

`super_admins`, `super_admin_roles`, `super_admin_permissions`,
`super_admin_role_permissions`, `audit_logs`. Futuras: `plans`,
`subscriptions`, `subscription_invoices`.

## 7. Endpoints

| Método | Ruta | Permiso |
|---|---|---|
| GET | `/v1/admin/businesses?q&status` | `platform.businesses.view` |
| GET | `/v1/admin/businesses/{id}` | `platform.businesses.view` |
| POST | `/v1/admin/businesses/{id}/suspend` | `platform.businesses.manage` |
| POST | `/v1/admin/businesses/{id}/reactivate` | `platform.businesses.manage` |
| GET | `/v1/admin/users?q` | `platform.users.view` |
| PATCH | `/v1/admin/users/{id}` | `platform.users.manage` |

## 8. Errores

`permissionDenied`, `businessNotFound`.

## 9. Permisos

`platform.businesses.view`, `platform.businesses.manage`,
`platform.users.view`, `platform.users.manage`, `platform.superadmins.manage`.

## 10. Eventos

`business.suspended` → invalida caches y desconecta sockets del negocio.

## 11. Auditoría

Todas las acciones.

## 12. Impacto en la app POS

Mostrar una pantalla "Negocio suspendido" cuando la API responde
`businessSuspended`.

## 13. Impacto en la web

El link de un negocio suspendido muestra "Tienda no disponible".

## 14. Origen en LaCase

`src/superadmin/*` completo (entidades, `SuperAdminGuard`,
`SuperAdminPermissionGuard`, `@RequireSuperAdminPermission`) y sus seeders;
`businesses-admin.controller.ts` se mueve aquí.

## 15. Criterios de aceptación

- Cuando un superadmin suspende un negocio, entonces sus miembros reciben 403
  `businessSuspended` y la tienda pública responde 404.

## 16. Preguntas abiertas

- Modelo de precios del SaaS (gratis hasta N ventas, por sucursal, por
  usuario): decidir antes de B11.
