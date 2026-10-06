# Métodos de pago

## 0. Ficha

| | |
|---|---|
| Fase backend | B4 (creación inicial en B1 con el registro) |
| Features móviles | F21 |
| Depende de | [auth y negocio](auth-y-negocio.md) |
| Estado | Planificado |

## 1. Objetivo

Que cada negocio defina cómo le pagan (efectivo, QR de su banco, tarjeta,
transferencia, u otros como "Tigo Money"), y que esos métodos se usen igual en
el POS, en la caja y en la tienda en línea.

## 2. Alcance v1

- Métodos por negocio con un **tipo base**: `cash`, `qr`, `card`,
  `bank_transfer`, `other`.
- Nombre visible, orden, activo, visible en la web, pide referencia (n° de
  transacción).
- Datos para el cliente web: texto (ej. cuenta bancaria) e imagen de QR fijo.
- Se crean en el registro según lo elegido en el paso 4.

## 3. Fuera de alcance

- Cobro en línea con pasarela, QR dinámico o conciliación bancaria → posterior.
- Comisiones por método → posterior.
- Métodos distintos por sucursal → no previsto (se ocultan con `is_active`).

## 4. Reglas de negocio

- **PAG-R1** Solo los métodos de tipo `cash` tienen `is_cash = true`, y solo
  esos afectan el efectivo esperado de la caja.
- **PAG-R2** Debe haber siempre al menos un método activo
  (`paymentMethodRequired`) y exactamente un método de tipo `cash` (puede
  estar inactivo).
- **PAG-R3** Nombre único en el negocio (`paymentMethodNameTaken`).
- **PAG-R4** No hay borrado definitivo si tiene ventas: se desactiva. Las ventas
  guardan copia del nombre y el tipo.
- **PAG-R5** Si `requires_reference`, la venta debe traer `reference` en ese
  pago (`paymentReferenceRequired`).

## 5. Estados

`activo ⇄ inactivo`.

## 6. Tablas

`payment_methods`. Ver [modelo de datos](../modelo-de-datos.md) §6.

## 7. Endpoints

| Método | Ruta | Permiso | Descripción |
|---|---|---|---|
| GET | `/v1/payment-methods?includeInactive=` | miembro | Lista ordenada |
| POST | `/v1/payment-methods` | `payment_method.manage` | Crear |
| PATCH | `/v1/payment-methods/{id}` | `payment_method.manage` | Editar, activar o desactivar |
| PUT | `/v1/payment-methods/order` | `payment_method.manage` | Reordenar |
| POST | `/v1/payment-methods/{id}/qr` | `payment_method.manage` | Subir imagen del QR (multipart) |

## 8. Errores

`paymentMethodNotFound` (404), `paymentMethodNameTaken` (409),
`paymentMethodRequired` (409), `paymentReferenceRequired` (422).

## 9. Permisos

`payment_method.manage`.

## 10. Eventos

`payment_method.updated` → invalida el cache de la tienda pública.

## 11. Auditoría

Cambios de datos bancarios o QR se auditan (riesgo de fraude interno).

## 12. Impacto en la app POS

- F21: el enum `PaymentMethod {cash, qr, card, bankTransfer}` pasa a ser una
  entidad cargada del negocio (`id`, `name`, `type`, `isCash`). Los íconos se
  eligen por `type`.
- Pantalla "Métodos de pago" en Más → Negocio.
- `DailySalesSummary.totalsByMethod` se agrupa por id de método.

## 13. Impacto en la web

`Store.paymentMethods` pasa de una lista fija a `[{id, name, type, details, qrUrl}]`,
solo los `show_online`. El checkout muestra los datos o el QR para pagar.

## 14. Origen en LaCase

`src/pos/entities/pos-payment-method.entity.ts` y `pos_payment_methods/*`
(con `is_cash` e imagen). Pasa de sucursal a negocio y gana `type`.

## 15. Criterios de aceptación

- Cuando se intenta desactivar el único método activo, entonces responde 409
  `paymentMethodRequired`.
- Dado un método "Tigo Money" (`other`), cuando se usa en una venta, entonces
  no suma al efectivo esperado de la caja.

## 16. Preguntas abiertas

Ninguna.
