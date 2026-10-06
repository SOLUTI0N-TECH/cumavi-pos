# Decisiones y riesgos

## Decisiones tomadas

| # | Tema | Decisión | Por qué |
|---|---|---|---|
| D1 | Catálogo y stock | Catálogo único por negocio; stock por sucursal y variante; precio opcional por sucursal; transferencias | Un solo SKU por producto; base del marketplace |
| D2 | Usuarios | Tabla `users` global + `memberships` (rol, sucursales) | La misma cuenta sirve para consumidor y empleado |
| D3 | Autenticación | Correo + contraseña propios (scrypt) → JWT propio + refresh rotativo. Sin proveedores de identidad de terceros (2026-10-06) | Pedido del negocio: login básico sin depender de terceros ni pagar SMS. Firebase queda solo para push |
| D4 | Offline | Online en v1; UUID del cliente + `Idempotency-Key` | Agregar una cola offline después sin cambiar la API |
| D5 | Pagos | Métodos configurables por negocio + pago dividido | Bolivia usa QR, Tigo Money, transferencias, mezclas |
| D6 | Compras | Orden de compra completa con recepción parcial y pagos | Pedido del negocio |
| D7 | Ecommerce | Un link por negocio; sucursal de retiro o de despacho | Un negocio = una página en el marketplace |
| D8 | Archivos | Disco local detrás de `StorageProvider` | Arranque rápido; R2 después |
| D9 | Caja | Varias cajas por sucursal; sesión por caja; sin turnos | Negocios con 2+ puntos de cobro |
| D10 | SaaS | Superadmin básico; planes en B11 | Primero adopción |
| D11 | Variantes | Todo producto tiene ≥ 1 variante (variante por defecto oculta) | Un solo `variant_id NOT NULL` en stock, ventas, pedidos y compras |
| D12 | Contexto | Negocio y sucursal en headers, no en el token | Cambio instantáneo; un token para varios negocios |
| D13 | Permisos | Aplicados en el servidor | En LaCase solo se ocultaban botones |
| D14 | Numeración | Ventas y devoluciones por sucursal; el resto por negocio; sin `MAX()+1` | Facturación SIN por sucursal; sin números repetidos |
| D15 | Tipos | `timestamptz`, `numeric(12,2)`, cálculos en centavos | Evitar errores de zona horaria y de redondeo |
| D16 | API | DTOs en camelCase; errores con `code` = `FailureCode` | Respetar los contratos existentes de la app y la web |
| D17 | Costo | Por variante, único en el negocio | Simplicidad; el margen se calcula igual en todas las sucursales |
| D18 | Pedidos | Sin reserva de stock; "entregado" solo al cobrar (crea venta) | Simple y sin stock fantasma |
| D19 | Transferencias | En dos pasos (enviar, recibir) | Lo que está en camino no se puede vender en ninguna sucursal |
| D20 | Cajero | Cierre ciego; no anula ni devuelve | Control de efectivo |
| D21 | Dueño | Uno por negocio en v1 | Simplicidad |
| D22 | Documentación | En español; `roadmap.md` de la app sigue en inglés | Respeta el archivo existente |

## Decisiones abiertas

| Tema | Propuesta | Cuándo decidir |
|---|---|---|
| Cantidades fraccionarias (kg, metros) | Enteras en v1; luego `numeric(12,3)` + unidad de medida | Antes de sumar ferreterías y comida a granel |
| Importar productos desde Excel | Útil para la adopción; candidato a B2 o B10 | Al iniciar B2 |
| Precio libre en la venta | Posterior, con permiso `sale.price_override` | B5 |
| Aprobación con PIN del encargado (anular, descuento alto) | Posterior | B8 |
| Reserva de stock para pedidos | No en v1; medir | Después del piloto de B7 |
| OTP al comprador web | Solo si hay abuso | B7 |
| RLS en Postgres | Posterior, como defensa extra | Antes del marketplace |
| Momento de pasar a R2/S3 | Antes del marketplace o al pasar ~20 GB | B11 |
| Modelo de precios del SaaS | Por definir | Antes de B11 |
| Hosting de la web sin exportación estática | Netlify con Next runtime o servidor Node | B7 |
| Política de stock negativo en ventas offline | Aceptar y dejar alerta, o rechazar | Al diseñar offline |

## Riesgos

| # | Riesgo | Mitigación |
|---|---|---|
| R1 | Credenciales y configuración de LaCase en el nuevo backend (`google-services.json`, secretos `lacase`) | B0: secretos fuera del repo, `git init` limpio; proyecto Firebase propio solo cuando llegue el push (B7) |
| R2 | Sobreventa por pedidos web sin reserva | Validar stock al crear y al cobrar; mostrar el stock de la sucursal |
| R3 | Pedidos falsos (spam) | Rate limit por IP y celular, Turnstile, OTP si hace falta |
| R4 | Errores de redondeo con dinero | Helpers puros en centavos con tests; el mismo prorrateo que la app |
| R5 | "Hoy" mal calculado | `timestamptz` y `AT TIME ZONE` del negocio; tests con ventas cerca de medianoche |
| R6 | Contraseña olvidada sin recuperación por correo | Contraseña temporal del dueño (personal) o del superadmin (dueño); recuperación por correo con SMTP propio si hace falta |
| R7 | Adivinar contraseñas por fuerza bruta | Rate limit por IP (10/min en login), bloqueo de 15 min tras 5 fallos, mismo error para correo inexistente |
| R8 | Permisos cacheados desactualizados | TTL de 60 s + invalidación por evento |
| R9 | Bloqueo de la secuencia de ventas en horas pico | Secuencia por sucursal; transacciones cortas |
| R10 | Disco local sin respaldo | Backups diarios de `uploads/` y de Postgres; plan de migración a R2 |
| R11 | Sin tests (herencia de LaCase) | Tests de integración obligatorios para stock, caja, pagos, devoluciones y numeración |
| R12 | La app asume datos locales (filtros, resúmenes, número de venta) | F20 y F23 mueven esa lógica al servidor de forma gradual |
| R13 | El mock de la web y el seed del backend divergen | El seeder de demo del backend se alimenta de `packages/mock-catalog/catalog.json` |
