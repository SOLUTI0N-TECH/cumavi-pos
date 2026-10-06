# Visión y alcance

## Qué es Cumavi Shop

Una plataforma para que **cualquier tipo de negocio** de Santa Cruz (Bolivia),
y luego del resto del país, gestione sus ventas e inventario y venda en línea:
tiendas de ropa, veterinarias, ferreterías, tiendas de barrio, tecnología,
belleza, comida.

La estrategia tiene dos etapas:

1. **Fase 1 (actual): sistema de gestión.** Ofrecer gratis o a bajo costo un
   POS móvil (ventas, caja, inventario, compras, clientes, equipo, sucursales)
   y un catálogo web por negocio para recibir pedidos. El objetivo es sumar
   negocios y que su catálogo viva en Cumavi.
2. **Fase 2 (futuro): marketplace social.** Con muchos negocios cargados, los
   consumidores descargan la app, buscan productos entre todos los negocios,
   entran a la página de un negocio (como una página de Facebook centrada en
   ecommerce), arman su carrito, siguen al negocio, chatean con él y comparten
   productos con amigos (como se comparte un video de TikTok), con su propio
   chat.

La fase 1 debe dejar listo el terreno para la fase 2: catálogo único por
negocio, cuentas de usuario globales, ubicación de sucursales y pedidos con
estados.

## Actores

| Actor | Fase 1 | Fase 2 |
|---|---|---|
| **Dueño del negocio** | Registra el negocio, configura sucursales, cajas, métodos de pago, equipo y roles; ve todo. | Además publica en el marketplace y responde chats. |
| **Empleado** (encargado, cajero, almacén) | Usa el POS según su rol y sus sucursales. | Igual, más atender chats o pedidos. |
| **Cliente sin cuenta** | Compra desde el link del catálogo web del negocio, sin registrarse. | Sigue existiendo (link compartido). |
| **Consumidor con cuenta** | Opcional: la cuenta existe pero no hay funciones sociales todavía. | Busca, sigue, chatea, comparte, compra con carrito. |
| **Superadmin de Cumavi** | Ve, activa y suspende negocios. | Planes, cobro de suscripción, moderación. |

## Alcance de la fase 1

Aplicaciones:

- **App POS** (Flutter, Android primero): toda la operación del negocio.
- **Catálogo web** (Next.js): un link público por negocio (`/<slug>`) para
  ver productos y hacer pedidos sin cuenta.
- **Backend** (NestJS + PostgreSQL): API para ambas, multi-negocio y
  multi-sucursal.

Módulos de la fase 1:

| Módulo | Qué cubre |
|---|---|
| Autenticación y negocio | Cuenta por celular (SMS) o Google; registro del negocio en 4 pasos; perfil del negocio. |
| Sucursales | Varias sucursales por negocio; horarios; cuáles venden en línea; cajas por sucursal. |
| Usuarios y roles | Invitar empleados, asignar rol y sucursales; permisos aplicados por el servidor. |
| Categorías | Categorías propias del negocio, ordenables y archivables. |
| Productos | Catálogo único por negocio con variantes, SKU, código de barras, varias fotos, precio por variante y por sucursal. |
| Inventario | Stock por sucursal y variante; ingresos, ajustes, transferencias; historial de movimientos. |
| Métodos de pago | Configurables por negocio (efectivo, QR, tarjeta, transferencia, otros). |
| Caja | Abrir caja, entradas y salidas de efectivo, cierre con arqueo. Sin turnos. |
| Ventas | Venta rápida con pago dividido, descuentos, comprobante, historial, anulación y devolución. |
| Clientes | Lista de clientes del negocio, asignarlos a ventas, historial. |
| Compras | Proveedores, órdenes de compra, recepción parcial, pagos a proveedores, actualización de costo. |
| Ecommerce | Configuración de la tienda en línea, API pública, bandeja de pedidos en el POS, convertir pedido en venta. |
| Plataforma | Superadmin básico. |

## Fuera de alcance de la fase 1

| Tema | Cuándo |
|---|---|
| Marketplace social (búsqueda global, seguir, chat, compartir) | Fase 2 (B11 en adelante) |
| Facturación electrónica SIN | Posterior; el modelo deja NIT y numeración por sucursal listos |
| Pagos en línea (pasarela, QR dinámico) | Posterior |
| Funcionamiento sin internet (offline) | Posterior; la API ya es idempotente para soportarlo |
| Planes y cobro de suscripción | B11 |
| Promociones y fiado (crédito a clientes) | B11 (F8, F10 del roadmap móvil) |
| Productos por peso o fracción (kg, metros) | Posterior; v1 usa cantidades enteras |
| Panel web de administración para el negocio | Posterior; v1 es solo la app móvil |
| Combos, fidelización por puntos | Posterior (existen en LaCase) |

## Principios

- **Un solo catálogo por negocio.** El producto se define una vez; cada
  sucursal tiene su stock y, si quiere, su precio.
- **Nada cambia sin registro.** Stock, caja y ventas dejan rastro (movimientos,
  historial de estados, auditoría).
- **El servidor decide.** Precios, totales, stock y permisos se validan en el
  backend; la app y la web solo proponen.
- **El costo es privado.** Nunca sale en la API pública ni a usuarios sin
  permiso.
- **Contratos estables.** Las interfaces de repositorio de la app y la web son
  el contrato; la API respeta sus nombres (camelCase) y sus códigos de error.
