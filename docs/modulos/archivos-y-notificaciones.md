# Archivos y notificaciones

## 0. Ficha

| | |
|---|---|
| Fase backend | B0 (archivos), B1 (dispositivos), B7 (push y tiempo real de pedidos) |
| Features móviles | F20 (subida de fotos), F26 |
| Depende de | [auth y negocio](auth-y-negocio.md) |
| Estado | Planificado |

## 1. Objetivo

Guardar imágenes (productos, logos, banners, QR de pago, comprobantes de caja)
de forma que se pueda migrar a un almacenamiento en la nube sin tocar los
módulos, y avisar a las personas correctas en tiempo real.

## 2. Alcance v1

**Archivos**

- Interfaz `StorageProvider` con implementación en disco local (como LaCase).
- Tabla `files` con metadatos; las entidades guardan `file_id`.
- Subida multipart (máx. 5 MB, solo imágenes JPG, PNG o WebP); se genera una
  versión redimensionada de hasta 1280 px de lado y una miniatura de 320 px
  (con `sharp`).
- Archivos públicos (catálogo) y privados (comprobantes de caja, servidos con
  verificación de permisos).

**Notificaciones**

- Registro de dispositivos y tokens FCM.
- Push para: pedido nuevo, transferencia por recibir, cierre de caja con
  diferencia, invitación al equipo.
- Tabla `notifications` (bandeja dentro de la app, marcar como leída).
- Websocket con salas `user:{id}`, `business:{id}`, `branch:{id}`.

## 3. Fuera de alcance

- Cloudflare R2 / S3 y CDN → B11 (solo se agrega el proveedor).
- Videos → fase 2.
- Notificaciones por email o SMS → posterior.
- Preferencias de notificación por usuario → posterior.

## 4. Reglas de negocio

- **ARC-R1** Se valida el tipo real del archivo (magic bytes), no solo la
  extensión; se rechazan archivos truncados (como `FilesService` de LaCase).
- **ARC-R2** Nombres de archivo generados (`<uuid>.<ext>`) dentro de
  `uploads/<businessId>/<propósito>/`.
- **ARC-R3** Borrar un archivo es lógico; un job elimina del disco los que no
  están referenciados después de 7 días.
- **ARC-R4** Las URLs públicas se arman con `PUBLIC_BASE_URL` + `storage_key`;
  al pasar a R2 solo cambia la base.
- **NOT-R1** Un push va a todos los dispositivos activos de los usuarios
  destino; los tokens inválidos que devuelve FCM se desactivan.
- **NOT-R2** El destino se calcula por permiso y sucursal (ej. pedido nuevo →
  miembros con `order.view` en la sucursal del pedido).
- **NOT-R3** El socket solo se une a salas de sucursales permitidas; al cambiar
  la membresía se desconecta.

## 5. Estados

Notificación: `no leída → leída`.

## 6. Tablas

`files`, `notifications`, `user_devices`. Ver
[modelo de datos](../modelo-de-datos.md) §1 y §11.

## 7. Endpoints

| Método | Ruta | Permiso | Descripción |
|---|---|---|---|
| POST | `/v1/files?purpose=` | según propósito | Subida genérica → `{id, url, thumbnailUrl}` |
| GET | `/v1/files/{id}` | permiso del recurso | Archivos privados |
| GET | `/v1/notifications?unread&cursor` | sesión + negocio | Bandeja |
| POST | `/v1/notifications/{id}/read` | sesión | |
| POST | `/v1/notifications/read-all` | sesión | |
| WS | `/v1/ws` | token + `businessId` | Eventos `order.created`, `order.updated`, `notification.created` |

## 8. Errores

`fileTooLarge` (413), `unsupportedFileType` (415), `fileNotFound` (404).

## 9. Permisos

Los del recurso dueño del archivo (ej. `product.update` para fotos de producto).

## 10. Eventos

Este módulo escucha eventos de otros (`order.created`,
`stock_transfer.sent`, `cash_session.closed`, `invitation.created`) y los
convierte en notificaciones.

## 11. Concurrencia

El envío de push va a una cola (Bull) para no demorar la respuesta de la API.

## 12. Impacto en la app POS

Subir fotos al guardar el producto (hoy quedan en el celular); registrar el
token FCM; bandeja de notificaciones; socket conectado mientras la app está
abierta.

## 13. Impacto en la web

Las imágenes salen de URLs del backend; se quita la copia de
`packages/mock-catalog/images`.

## 14. Origen en LaCase

`src/files/files.service.ts` (→ `LocalStorageProvider`),
`src/common/interceptors/fastify-multipart.interceptor.ts`, `src/firebase/*`,
`src/notification/*` (patrón strategy), `src/websocket/*` (cambian las salas),
`src/user/devices/*`.

## 15. Criterios de aceptación

- Un `.exe` renombrado a `.jpg` responde 415.
- Un comprobante de caja no se puede descargar sin permiso de caja en esa
  sucursal.
- Un pedido nuevo llega como push a los cajeros de la sucursal y no a los de
  otra.

## 16. Preguntas abiertas

- ¿Cuándo pasar a R2? Propuesta: antes de abrir el marketplace o al superar
  ~20 GB.
