# Reportes y alertas

## 0. Ficha

| | |
|---|---|
| Fase backend | B10 |
| Features móviles | F15, F16 |
| Depende de | [ventas](ventas.md), [caja](caja.md), [inventario](inventario.md), [compras](compras.md) |
| Estado | Planificado (alcance preliminar) |

## 1. Objetivo

Que el dueño entienda su negocio: cuánto vende, qué se vende más, cuánto gana,
cómo cierran sus cajas y qué tiene que reponer.

## 2. Alcance preliminar

- Ventas por periodo (día, semana, mes), por sucursal, por método de pago y por
  vendedor.
- Productos y variantes más vendidos (unidades y monto).
- Margen bruto (precio − `unit_cost` guardado en la venta).
- Historial de cierres de caja con diferencias.
- Valor del inventario por sucursal (stock × costo).
- Cuentas por pagar a proveedores.
- Stock mínimo por variante y sucursal; lista de reposición (sugerir OC o
  enviar por WhatsApp al proveedor).
- Conteos de inventario con documento (`inventory_counts`, CI-0001).
- Exportar a CSV y Excel.

## 3. Fuera de alcance

Dashboards web, reportes programados por email, comparación entre negocios.

## 4. Reglas

- **REP-R1** Los días se calculan en la zona horaria del negocio con `sold_at`.
- **REP-R2** Las ventas anuladas no cuentan; las devoluciones se restan en el
  periodo en que ocurren.
- **REP-R3** El margen y el valor del inventario requieren `report.financial`.
- **REP-R4** Las consultas usan índices sobre (`business_id`, `branch_id`,
  `sold_at`); si hace falta, tablas resumen diarias.

## 6–16

Se completan al iniciar B10. Origen en LaCase: `src/reports/shared/helpers/*`
(rangos de fecha, zona horaria, agrupaciones) y `src/reports/{sales,inventory,purchases}`
como referencia.
