# Sucursales y cajas

## 0. Ficha

| | |
|---|---|
| Fase backend | B1 (sucursales y cajas), B7 (datos para la tienda en línea) |
| Features móviles | F19 (selector), F22 (varias cajas) |
| Depende de | [auth y negocio](auth-y-negocio.md) |
| Estado | Planificado |

## 1. Objetivo

Que un negocio opere en varios locales, cada uno con su stock, sus cajas, sus
ventas y su horario, compartiendo un solo catálogo.

## 2. Alcance v1

- Crear, editar, activar y desactivar sucursales.
- Sucursal principal (la creada en el registro); se puede cambiar.
- Datos: nombre, código corto, departamento, ciudad, zona, dirección,
  coordenadas, teléfono, WhatsApp.
- Horario semanal (varios tramos por día).
- Flags para la tienda en línea: vende en línea, recojo, envío.
- **Cajas** por sucursal: crear, renombrar, desactivar.
- Ver qué sucursales puede usar el usuario actual.

## 3. Fuera de alcance

- Almacenes que no venden (bodegas) → posterior (se puede modelar como sucursal
  sin cajas).
- Mapa de sucursales en el marketplace → fase 2 (las coordenadas ya se guardan).
- Puntos de venta SIN por caja → con facturación.

## 4. Reglas de negocio

- **SUC-R1** Todo negocio tiene al menos una sucursal activa y exactamente una
  principal (`lastActiveBranch`, `defaultBranchRequired`).
- **SUC-R2** Nombre único en el negocio (`branchNameTaken`). Código corto de
  1–6 caracteres, único, autogenerado (`C1`, `C2`) y editable.
- **SUC-R3** Desactivar una sucursal exige que no tenga sesiones de caja
  abiertas ni pedidos en estado new/confirmed/ready
  (`cashSessionHasPendingWork`). Su stock y su historial se conservan.
- **SUC-R4** Una sucursal desactivada no aparece en el selector, no vende y no
  recibe pedidos ni transferencias.
- **SUC-R5** Horario: `closes > opens`, tramos del mismo día sin solaparse. Sin
  horario = cerrado para pedidos web, salvo que la tienda acepte pedidos fuera
  de horario.
- **CJA-R1** Cada sucursal nueva nace con "Caja 1". Nombre de caja único en la
  sucursal (`cashRegisterNameTaken`).
- **CJA-R2** No se puede desactivar una caja con sesión abierta.
- **SUC-R6** Al crear una sucursal, el stock de todas las variantes es 0 (no se
  crean filas: `branch_stock` es perezoso).

## 5. Estados

Sucursal y caja: `activa ⇄ inactiva` (sin borrado; `deleted_at` solo si nunca
tuvo movimientos).

## 6. Tablas

`branches`, `branch_opening_hours`, `cash_registers`. Ver
[modelo de datos](../modelo-de-datos.md) §2.

## 7. Endpoints

| Método | Ruta | Permiso | Descripción |
|---|---|---|---|
| GET | `/v1/branches` | miembro | Sucursales del negocio (las permitidas, o todas con `branch.manage`) |
| POST | `/v1/branches` | `branch.manage` | Crear (con "Caja 1") |
| GET | `/v1/branches/{id}` | miembro | Detalle con horario y cajas |
| PATCH | `/v1/branches/{id}` | `branch.manage` | Editar, activar o desactivar, marcar como principal |
| PUT | `/v1/branches/{id}/opening-hours` | `branch.manage` | Reemplaza el horario completo |
| GET | `/v1/branches/{id}/cash-registers` | miembro | Cajas, con su sesión abierta si existe |
| POST | `/v1/branches/{id}/cash-registers` | `cash_register.manage` | Crear caja |
| PATCH | `/v1/cash-registers/{id}` | `cash_register.manage` | Renombrar, activar o desactivar |

## 8. Errores

| code | HTTP |
|---|---|
| `branchNotFound`, `cashRegisterNotFound` | 404 |
| `branchNameTaken`, `cashRegisterNameTaken` | 409 |
| `lastActiveBranch`, `defaultBranchRequired`, `cashSessionHasPendingWork` | 409 |
| `branchForbidden` | 403 |

## 9. Permisos

`branch.manage` (negocio), `cash_register.manage` (sucursal).

## 10. Eventos

`branch.updated` (invalida cache de tienda pública y de permisos).

## 11. Concurrencia y auditoría

Cambiar la principal es una transacción (quita el flag de la anterior y lo pone
en la nueva; el índice único parcial lo garantiza). Auditoría:
`branch.deactivated`, `branch.default_changed`.

## 12. Impacto en la app POS

- **F19:** después del login, elegir negocio → sucursal → caja; mostrar la
  sucursal en el encabezado de Inicio; cambiarla desde "Más".
- Nueva pantalla "Sucursales" en Más → Negocio (lista, formulario, horario,
  cajas).
- Todas las llamadas envían `x-branch-id`.

## 13. Impacto en la web

La tienda muestra las sucursales que venden en línea: dirección, zona, horario
y abierto/cerrado (hoy `Store.openingHours` es del negocio; pasa a ser por
sucursal).

## 14. Origen en LaCase

`src/business/entities/branch.entity.ts` y `branches.service.ts` (se adaptan).
No se copian `branches_shifts` ni los turnos.

## 15. Criterios de aceptación

- Dado un negocio con una sucursal, cuando se intenta desactivarla, entonces
  responde 409 `lastActiveBranch`.
- Cuando se crea una sucursal, entonces tiene "Caja 1" y stock 0 en todo.
- Dado un cajero asignado solo a la sucursal A, cuando envía `x-branch-id` de B,
  entonces responde 403 `branchForbidden`.

## 16. Preguntas abiertas

- ¿Cobrar por sucursal adicional en los planes? (B11)
