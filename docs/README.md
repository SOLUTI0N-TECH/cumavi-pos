# Documentación de Cumavi Shop

Alcance funcional y técnico para arrancar el backend del POS de Cumavi Shop y
conectar la app POS (`apps/mobile`) y el catálogo web (`apps/web`).

Última actualización: 2026-10-05.

## Cómo leer estos documentos

1. [Visión y alcance](vision-y-alcance.md): qué es Cumavi Shop, actores y qué
   entra en la fase 1.
2. [Arquitectura del backend](arquitectura-backend.md): stack, convenciones,
   autenticación, multi-negocio, errores, idempotencia.
3. [Modelo de datos](modelo-de-datos.md): todas las tablas por dominio.
4. Documentos por módulo (abajo), cada uno con la misma plantilla.
5. [Roadmap del backend](backend-roadmap.md): fases B0–B11.
6. [Roadmap de la app POS](roadmap.md) (en inglés): features F1–F26, incluida
   la fase 5 "Ajustes para el backend".
7. [Reutilización de LaCase](reutilizacion-lacase.md) y
   [Decisiones y riesgos](decisiones-y-riesgos.md).

## Módulos

| Módulo | Documento | Fase backend |
|---|---|---|
| Autenticación y negocio | [modulos/auth-y-negocio.md](modulos/auth-y-negocio.md) | B1 |
| Sucursales y cajas | [modulos/sucursales.md](modulos/sucursales.md) | B1 |
| Usuarios (equipo) | [modulos/usuarios.md](modulos/usuarios.md) | B1 / B8 |
| Roles y permisos | [modulos/roles.md](modulos/roles.md) | B1 / B8 |
| Categorías | [modulos/categorias.md](modulos/categorias.md) | B2 |
| Productos y variantes | [modulos/productos.md](modulos/productos.md) | B2 |
| Inventario | [modulos/inventario.md](modulos/inventario.md) | B3 |
| Métodos de pago | [modulos/metodos-de-pago.md](modulos/metodos-de-pago.md) | B4 |
| Caja | [modulos/caja.md](modulos/caja.md) | B4 |
| Ventas | [modulos/ventas.md](modulos/ventas.md) | B5 |
| Clientes | [modulos/clientes.md](modulos/clientes.md) | B6 |
| Ecommerce y pedidos | [modulos/ecommerce.md](modulos/ecommerce.md) | B7 |
| Compras y proveedores | [modulos/compras.md](modulos/compras.md) | B9 |
| Archivos y notificaciones | [modulos/archivos-y-notificaciones.md](modulos/archivos-y-notificaciones.md) | B0 / B7 |
| Plataforma (superadmin) | [modulos/plataforma.md](modulos/plataforma.md) | B1 / B11 |
| Reportes | [modulos/reportes.md](modulos/reportes.md) | B10 |

### Plantilla de cada módulo

0. Ficha · 1. Objetivo · 2. Alcance v1 · 3. Fuera de alcance · 4. Reglas de
negocio (numeradas, ej. `VEN-R3`) · 5. Estados y transiciones · 6. Tablas ·
7. Endpoints · 8. Errores · 9. Permisos · 10. Eventos y notificaciones ·
11. Concurrencia, idempotencia y auditoría · 12. Impacto en la app POS ·
13. Impacto en la web · 14. Origen en LaCase · 15. Criterios de aceptación ·
16. Preguntas abiertas.

Las reglas numeradas existen para poder citarlas en PRs, tests y tickets
("cumple `CAJ-R4`").

## Glosario

| Término | Significado |
|---|---|
| **Negocio** (`business`) | El cliente del SaaS (tienda, ferretería, veterinaria…). Es el *tenant*: todo dato de gestión pertenece a un negocio. |
| **Sucursal** (`branch`) | Local físico de un negocio. Tiene stock, cajas, ventas y horarios propios. Todo negocio tiene al menos una (la principal). |
| **Caja** (`cash_register`) | Punto de cobro dentro de una sucursal ("Caja 1"). Una sucursal puede tener varias. |
| **Sesión de caja** (`cash_session`) | Periodo entre abrir y cerrar una caja: monto inicial, ventas, entradas/salidas de efectivo y arqueo. No hay turnos. |
| **Usuario** (`user`) | Persona con cuenta en Cumavi. La misma cuenta sirve para comprar (consumidor) y para trabajar en negocios. |
| **Membresía** (`membership`) | Relación usuario × negocio con un rol y las sucursales permitidas. Un usuario puede tener varias. |
| **Dueño** | Membresía con `is_owner`: todos los permisos y sucursales; no se puede quitar. |
| **Rol / permiso** | Un rol agrupa permisos `recurso.acción` (ej. `sale.cancel`). Los roles son por negocio y se crean desde plantillas. |
| **Producto** | Ficha del catálogo del negocio: nombre, categoría, descripción, fotos, precio base. |
| **Opción / valor** | Tipo de variante y sus valores (Color: Rojo, Azul; Talla: 38, 40). |
| **Variante** | Combinación concreta de valores (Rojo / 40). Es lo que tiene stock, SKU y código de barras. |
| **Variante por defecto** | Variante oculta que tiene todo producto simple (sin opciones), para que stock y ventas siempre apunten a una variante. |
| **SKU / código de barras** | Códigos del negocio (SKU interno, UPC/EAN de barras). Únicos en todo el negocio. |
| **Movimiento de stock** | Registro inmutable de cada cambio de stock (ingreso, ajuste, venta, devolución, transferencia). |
| **Pedido** (`order`) | Compra hecha por un cliente desde el catálogo web; llega a una sucursal y se convierte en venta al cobrarse. |
| **Bs** | Bolivianos. Montos con 2 decimales. Zona horaria `America/La_Paz` (UTC−4). |

## Fuentes

- App POS: `apps/mobile/lib/features/*/domain` (entidades y repositorios que
  son el contrato con el backend), `apps/mobile/lib/core/error/failure_code.dart`.
- Catálogo web: `apps/web/src/features/catalog/domain/entities.ts`,
  `apps/web/src/features/ordering/domain/order.ts`.
- Backend: `cumavi-shop-backend` (a reconstruir) y `lacase-backend` (base a
  reciclar, no se modifica).
