# Clientes

## 0. Ficha

| | |
|---|---|
| Fase backend | B6 (creación automática desde pedidos en B7) |
| Features móviles | F9 |
| Depende de | [ventas](ventas.md) |
| Estado | Planificado |

## 1. Objetivo

Que el negocio conozca a sus clientes: quién compra, cuánto y qué, y pueda
contactarlos por WhatsApp. Es la base para el fiado, las promociones y, en la
fase 2, para enlazar al cliente con su cuenta de consumidor.

## 2. Alcance v1

- Lista de clientes del negocio (compartida por todas las sucursales).
- Datos: nombre, celular, email, CI o NIT, razón social para factura,
  dirección, nota.
- Buscar por nombre, celular o documento.
- Asignar un cliente a una venta (opcional) y crearlo al vuelo.
- Historial de compras y pedidos del cliente, total gastado, última compra.
- Los pedidos web crean o reutilizan el cliente por celular.

## 3. Fuera de alcance

- Fiado y saldo del cliente → F10, B11.
- Niveles y puntos de fidelización → posterior (existe en LaCase).
- Etiquetas y segmentos, envíos masivos por WhatsApp → posterior.
- Enlace con la cuenta del consumidor → fase 2 (columna `user_id` ya existe).

## 4. Reglas de negocio

- **CLI-R1** Nombre obligatorio (≥ 2 caracteres). Celular boliviano opcional
  pero único en el negocio (`customerPhoneTaken`).
- **CLI-R2** Un pedido web busca el cliente por celular; si no existe lo crea
  con `source = online_order`. **Nunca sobrescribe** datos de un cliente
  existente con lo que escribió un cliente anónimo.
- **CLI-R3** Borrar es lógico (`deleted_at`); las ventas conservan el
  `customer_id` y se muestran con el nombre guardado.
- **CLI-R4** Los totales (gastado, cantidad de compras, última compra) se
  calculan con las ventas no anuladas, netas de devoluciones.

## 5. Estados

`activo → borrado (lógico)`.

## 6. Tablas

`customers`; `sales.customer_id`; `orders.customer_id`. Ver
[modelo de datos](../modelo-de-datos.md) §8.

## 7. Endpoints

| Método | Ruta | Permiso | Descripción |
|---|---|---|---|
| GET | `/v1/customers?q&page` | `customer.view` | Lista con totales |
| POST | `/v1/customers` | `customer.manage` | Crear (id del cliente, idempotente) |
| GET | `/v1/customers/{id}` | `customer.view` | Detalle con totales |
| PATCH | `/v1/customers/{id}` | `customer.manage` | Editar |
| DELETE | `/v1/customers/{id}` | `customer.manage` | Borrado lógico |
| GET | `/v1/customers/{id}/sales` | `customer.view` + `sale.view_all` | Historial |
| GET | `/v1/customers/{id}/orders` | `customer.view` + `order.view` | Pedidos web |

## 8. Errores

`customerNotFound` (404), `customerPhoneTaken` (409), `invalidMobileNumber`
(422).

## 9. Permisos

`customer.view`, `customer.manage`.

## 10. Eventos

Ninguno en v1.

## 11. Auditoría

Borrado de clientes.

## 12. Impacto en la app POS

- F9: pantalla de clientes en Más; selector de cliente en el checkout (buscar o
  crear rápido); el comprobante muestra el nombre y el NIT del cliente;
  "Enviar por WhatsApp" usa su celular.

## 13. Impacto en la web

Ninguno visible: el pedido crea el cliente en el backend.

## 14. Origen en LaCase

`src/partner/entities/partner.entity.ts` y `partner/partners/*` (datos del
cliente). Se quitan niveles y puntos.

## 15. Criterios de aceptación

- Cuando dos pedidos web llegan con el mismo celular y nombres distintos,
  entonces existe un solo cliente con el nombre del primero.
- El total gastado de un cliente no incluye ventas anuladas y descuenta lo
  devuelto.

## 16. Preguntas abiertas

- ¿Clientes por sucursal o por negocio? Decidido: por negocio.
