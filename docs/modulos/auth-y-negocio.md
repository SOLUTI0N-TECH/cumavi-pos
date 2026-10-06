# Autenticación y negocio

## 0. Ficha

| | |
|---|---|
| Fase backend | B1 |
| Features móviles | F1 (hecha, se conecta), F17, F18 |
| Depende de | B0 (fundación), [roles](roles.md), [sucursales](sucursales.md) |
| Estado | Planificado |

## 1. Objetivo

Que una persona cree su cuenta con el celular (SMS) o Google, registre su
negocio en 4 pasos y quede lista para vender; y que pueda entrar, cambiar de
negocio o sucursal y cerrar sesión de forma segura.

## 2. Alcance v1

- Login y registro con **Firebase Auth** (SMS OTP, Google; email con
  contraseña opcional). El backend verifica el ID token y emite sus propios
  tokens.
- Refresh token rotativo con detección de reuso; cierre de sesión.
- `/me`: datos del usuario y sus membresías (negocios, rol, permisos,
  sucursales permitidas).
- Registro del negocio (pasos 3 y 4 del mockup) en **una sola transacción**.
- Editar perfil del negocio (nombre, tipo, departamento, logo, NIT).
- Ajustes del negocio (`business_settings`).
- Registro de dispositivos para push.

## 3. Fuera de alcance

- Varios dueños por negocio (v1: uno). Transferir la propiedad → B8.
- Login por contraseña propia del backend (no se usa).
- SSO a un panel web → cuando exista el panel.
- Verificación de identidad del negocio (NIT real con el SIN) → posterior.

## 4. Reglas de negocio

- **AUT-R1** Un celular o email identifica a un solo `user`. Si Firebase entrega
  un uid nuevo con un celular o email que ya existe, se vincula al usuario
  existente (nueva fila en `auth_identities`).
- **AUT-R2** Nombre completo: al menos 2 palabras (`fullNameRequired`). Celular
  boliviano: 8 dígitos empezando en 6 o 7, se guarda en E.164 `+591…`
  (`invalidMobileNumber`).
- **AUT-R3** El access token dura 15 min; el refresh 60 días. Cada refresh
  invalida el anterior; reusar uno ya usado revoca toda la familia
  (`refreshTokenReused`).
- **AUT-R4** Un usuario desactivado (`is_active = false`) no puede refrescar ni
  usar la API.
- **NEG-R1** Nombre del negocio ≥ 3 caracteres (`businessNameTooShort`). NIT
  opcional, 5–15 dígitos (`invalidTaxId`).
- **NEG-R2** El slug se genera del nombre (`illimani-store`), único en la
  plataforma; si existe se agrega sufijo. Se puede editar (`slugTaken`).
- **NEG-R3** El registro crea en una transacción: negocio, `business_settings`,
  sucursal principal (con departamento y ciudad del negocio), "Caja 1", los
  métodos de pago elegidos (al menos uno, `paymentMethodRequired`), las
  categorías elegidas (al menos una, `salesCategoryRequired`), los 4 roles desde
  plantillas, la membresía del dueño (`is_owner`, rol Administrador, todas las
  sucursales) y la tienda en línea deshabilitada.
- **NEG-R4** Las categorías sugeridas dependen del tipo de negocio (igual que
  `BusinessType.suggestedCategories` en la app).
- **NEG-R5** Un negocio suspendido no puede usar rutas de negocio
  (`businessSuspended`) y su tienda pública devuelve 404.

## 5. Estados

```mermaid
stateDiagram-v2
  [*] --> active : registro
  active --> suspended : superadmin
  suspended --> active : superadmin
  active --> closed : dueño cierra (posterior)
```

## 6. Tablas

`users`, `auth_identities`, `refresh_tokens`, `user_devices`, `businesses`,
`business_settings`, `memberships`. Ver [modelo de datos](../modelo-de-datos.md) §1–§2.

## 7. Endpoints

| Método | Ruta | Permiso | Idempotente | Descripción |
|---|---|---|---|---|
| POST | `/v1/auth/firebase` | público | sí | `{idToken, device{installationId, platform, appVersion, fcmToken?}}` → tokens + `user` + `memberships` |
| POST | `/v1/auth/refresh` | público | — | `{refreshToken}` → nuevo par |
| POST | `/v1/auth/sign-out` | sesión | — | Revoca la familia, desactiva el dispositivo |
| GET | `/v1/me` | sesión | — | Usuario |
| PATCH | `/v1/me` | sesión | — | Nombre, avatar |
| GET | `/v1/me/memberships` | sesión | — | `[{business, role, permissions[], branches[], isOwner}]` |
| PUT | `/v1/me/devices/{installationId}` | sesión | sí | Token FCM |
| POST | `/v1/businesses` | sesión | sí | Registro completo (pasos 3 y 4) |
| GET | `/v1/business` | miembro | — | Perfil del negocio activo |
| PATCH | `/v1/business` | `business.update` | — | Nombre, tipo, departamento, logo, NIT, slug |
| GET/PATCH | `/v1/business/settings` | `business.settings` | — | Ajustes |

`POST /v1/businesses` (cuerpo):

```json
{ "id": "uuid", "name": "Illimani Store", "type": "clothing_and_footwear",
  "department": "santa_cruz", "city": "Santa Cruz de la Sierra", "logoFileId": null,
  "taxId": "1020304050", "categoryNames": ["Ropa", "Calzado"],
  "paymentMethods": ["cash", "qr"] }
```

## 8. Errores

| code | HTTP | Cuándo |
|---|---|---|
| `verificationCodeInvalid` | 401 | Firebase rechaza el token |
| `refreshTokenInvalid` / `refreshTokenReused` | 401 | AUT-R3 |
| `fullNameRequired`, `invalidMobileNumber`, `invalidEmail` | 422 | AUT-R2 |
| `businessNameTooShort`, `invalidTaxId`, `salesCategoryRequired`, `paymentMethodRequired` | 422 | NEG-R1, NEG-R3 |
| `slugTaken` | 409 | NEG-R2 |
| `businessSuspended` | 403 | NEG-R5 |

## 9. Permisos

`business.update`, `business.settings`. El registro no necesita permiso (crea
el negocio y al usuario como dueño).

## 10. Eventos

`business.created` (seeder de secuencias, tienda en línea), `user.signed_in`
(último acceso). Sin push.

## 11. Concurrencia, idempotencia y auditoría

- `POST /businesses` con id del cliente: reintentar no crea dos negocios.
- El consumo del refresh es un único `UPDATE … WHERE used_at IS NULL AND revoked_at IS NULL RETURNING`.
- Auditoría: `business.updated` (cambio de NIT o slug), `auth.refresh_reused`.

## 12. Impacto en la app POS

- **F18:** `MockAuthRepository` → Firebase Auth real + `POST /auth/firebase`.
  El paso 2 (código SMS) lo maneja Firebase.
- El paso 4 debe **persistir los métodos de pago** (hoy se validan pero no se
  guardan).
- `SessionRepository` guarda tokens en almacenamiento seguro; restaura sesión
  al abrir la app.
- Después del login: si hay 0 membresías → registro de negocio; si hay 1 →
  entra; si hay varias → selector (F19).
- "Cerrar sesión" (F1) llama a `POST /auth/sign-out`.
- `PATCH /business` reemplaza a `saveBusinessProfile`.

## 13. Impacto en la web

Ninguno en v1 (el cliente web compra sin cuenta). El slug del negocio es la URL
del catálogo.

## 14. Origen en LaCase

- `src/auth/*`: estructura de módulo, `JwtStrategy`, decoradores. Se quita el
  login con bcrypt; se reutiliza el patrón de `auth_sso_codes` (hash + consumo
  atómico) para los refresh tokens.
- `src/firebase/firebase.service.ts`: se agrega `auth().verifyIdToken`.
- `src/business/entities/business.entity.ts`, `businesses.service.ts`: se
  adaptan (slug, estado, tipo, NIT).
- `src/user/devices/*`: se adapta.

## 15. Criterios de aceptación

- Dado un celular nuevo, cuando la app envía un ID token válido, entonces se
  crea un usuario y la respuesta trae 0 membresías.
- Dado un usuario que entró con SMS, cuando entra con Google usando el mismo
  email verificado, entonces se usa el mismo `user`.
- Dado un refresh token ya usado, cuando se vuelve a enviar, entonces responde
  401 `refreshTokenReused` y ningún token de esa familia sigue sirviendo.
- Cuando se registra un negocio, entonces existen sucursal principal, "Caja 1",
  métodos de pago, categorías, 4 roles y la membresía del dueño; si algo falla,
  no queda nada creado.
- Dado un negocio suspendido, cuando un miembro llama a `/v1/products`, entonces
  responde 403 `businessSuspended`.

## 16. Preguntas abiertas

- ¿Se exige celular verificado a quien entra solo con Google? (Las invitaciones
  de equipo se hacen por celular.) Propuesta: sí, al aceptar una invitación.
- Costo de SMS de Firebase en Bolivia: medir en piloto.
