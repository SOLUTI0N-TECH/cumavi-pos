# Cumavi POS

Punto de venta móvil para los vendedores de Cumavi Shop (Bolivia). Replica las
pantallas del prototipo de diseño con datos simulados mientras no existe el
backend.

- **Flutter** 3.47.4 (fijado con `fvm`, ver `.fvmrc`)
- **Estado:** `flutter_bloc` (Cubits)
- **Navegación:** `go_router` (`StatefulShellRoute` para las 3 pestañas)
- **Inyección de dependencias:** `get_it`
- **Tipografía:** Outfit, la misma de Cumavi Shop, incluida como asset para
  que la app se vea bien sin conexión
- **Textos:** `flutter gen-l10n` con archivos ARB (`lib/l10n/`)
- **Dispositivo:** `image_picker` + `image_background_remover` (quitar fondo en
  el celular), `print_bluetooth_thermal` + `esc_pos_utils_plus` (impresoras
  térmicas), `pdf`/`printing` (comprobante en PDF e imagen), `share_plus`,
  `url_launcher` (WhatsApp y correo) y `gal` (guardar en la galería)

## Cómo correrlo

```bash
fvm install        # instala 3.47.4 si falta
fvm flutter pub get  # también genera AppLocalizations
fvm flutter run
fvm flutter test
fvm flutter analyze
```

La app arranca en *Iniciar sesión*. Cualquier correo válido con una contraseña
de 8+ caracteres entra, igual que "Continuar con Google". Con teléfono (para
ingresar o registrarse) no se envían SMS: cualquier celular boliviano sirve y
el código es siempre **123456**. La pantalla lo muestra en un aviso de modo demo
con el botón *Usar*, que lo completa.

## Textos y traducciones

Ningún texto de la interfaz está escrito en los widgets: todos viven en
`lib/l10n/app_es.arb` y se usan con `context.l10n.<clave>`
(`import 'core/l10n/l10n.dart'`). Las claves llevan el prefijo de su feature
(`salesCheckout…`, `catalogProductForm…`); `common…` es lo compartido.

- Cambiar un texto: editarlo en `app_es.arb` y correr `fvm flutter pub get`
  (o `fvm flutter gen-l10n`).
- Agregar un idioma: crear `app_<idioma>.arb` con las mismas claves; queda
  disponible en `AppLocalizations.supportedLocales`.
- **Errores:** el dominio no devuelve textos. Cada `Failure` lleva un
  `FailureCode` y `failure.localizedMessage(l10n)` lo traduce
  (`core/l10n/failure_messages.dart`). El `switch` es exhaustivo: un código
  nuevo no compila hasta tener su mensaje.
- Los comprobantes que se imprimen o comparten se arman fuera del árbol de
  widgets, así que reciben `AppLocalizations` por inyección de dependencias.

## Pruebas

- `test/features/**`: reglas de negocio (carrito, registrar venta, imprimir y
  compartir comprobante) y formato de moneda y celulares.
- `test/screens_render_test.dart`: dibuja cada pantalla a 390×844 con la
  fuente real; si algo se desborda, la prueba falla.
- `test/app/app_smoke_test.dart`: la app arranca en *Iniciar sesión*.

## Arquitectura

Clean Architecture organizada por *feature*. Cada feature tiene tres capas y
las dependencias apuntan siempre hacia el dominio:

```
presentation  →  domain  ←  data
(Cubits,          (entidades,     (data sources,
 pantallas,        contratos de    implementaciones
 widgets)          repositorio,    de repositorio)
                   casos de uso)
```

```
lib/
├── app/                    # composición: DI, router, MaterialApp
│   ├── di/dependency_injection.dart
│   └── router/{app_router,app_routes}.dart
├── core/                   # código compartido sin lógica de negocio
│   ├── constants/          # rutas de assets
│   ├── domain/             # entidades usadas por varias features (PaymentMethod)
│   ├── error/              # Failure + FailureCode (dominio) y DataSourceException (datos)
│   ├── l10n/               # context.l10n y traducción de errores y métodos de pago
│   ├── theme/              # colores, tipografía, espaciado, radios, ThemeData
│   ├── usecases/           # contrato UseCase<Output, Input>
│   ├── utils/              # Result<T>, formato de moneda es-BO y fechas
│   └── widgets/            # kit de UI reutilizable
├── l10n/                   # app_es.arb (+ código generado en l10n/generated)
└── features/
    ├── auth/               # login, registro en 4 pasos, sesión
    ├── cash_register/      # apertura y cierre de caja (sin turnos)
    ├── catalog/            # productos, categorías, inventario, quitar fondo
    ├── dashboard/          # pantalla de Inicio
    ├── sales/              # carrito, catálogo de venta, cobro, comprobante
    └── shell/              # barra de navegación flotante
```

### Reglas que sigue el código

- **El dominio no conoce Flutter ni el idioma.** Entidades y casos de uso son
  Dart puro y sin textos; los íconos y colores viven en
  `presentation/view_data/` y los textos en `lib/l10n/`.
- **Un caso de uso = una acción** (`RegisterSale`, `OpenCashSession`,
  `CreateProduct`…) con un único `call` que devuelve `Result<T>`. Las
  validaciones de negocio están ahí, no en la UI.
- **Nada de excepciones fuera de la capa de datos.** Los data sources lanzan
  `DataSourceException`; los repositorios las convierten en `Failure`.
- **Los repositorios son interfaces** en `domain/repositories`; la UI nunca
  conoce la implementación.
- **Los Cubits sólo orquestan** casos de uso y exponen un estado inmutable
  (`Equatable` + `status`).
- **La navegación la decide la app, no las pantallas.** Cada pantalla recibe
  callbacks (`onBack`, `onCompleted`…) y `app_router.dart` los conecta.

### Estado entre pantallas

| Cubit | Alcance | Por qué |
|---|---|---|
| `SessionCubit`, `CartCubit`, `CashRegisterCubit`, `DashboardCubit` | App completa | El carrito y la caja deben sobrevivir a la navegación |
| `RegistrationCubit`, `ProductFormCubit` | Un flujo (`ShellRoute`) | Un solo estado para varios pasos |
| El resto | Una pantalla | Se crea y se descarta con la ruta |

## Datos simulados y cómo conectar el backend

Todo lo simulado vive en `data/` y está registrado en
`app/di/dependency_injection.dart`:

| Contrato | Implementación actual |
|---|---|
| `ProductDataSource` | `InMemoryProductDataSource` (14 productos de ejemplo, la mayoría con variantes) |
| `SalesDataSource` | `InMemorySalesDataSource` (18 ventas del día) |
| `CashRegisterDataSource` | `InMemoryCashRegisterDataSource` (caja abierta 08:30, Bs 200) |
| `AuthRepository` | `MockAuthRepository` |
| `SessionRepository` | `InMemorySessionStore` (Illimani Store / Carla Mamani) |

Los mocks simulan latencia y guardan estado en memoria: una venta descuenta
stock y se refleja en Inicio y en el cierre de caja, igual que lo haría el
backend.

Para integrar el backend basta con escribir otra implementación de cada
contrato (por ejemplo `RemoteProductDataSource` con `dio`) y cambiar el
registro en `dependency_injection.dart`. Dominio y presentación no cambian.

## Servicios del celular

Cámara, impresora y envíos son reales en Android e iOS. En escritorio, web y
en las pruebas se usan versiones demo, elegidas en `main.dart` con
`configureDependencies(deviceServices: ...)`:

| Contrato | Celular (`DeviceServices.native`) | Demo (`DeviceServices.demo`) |
|---|---|---|
| `PhotoCapturer` | `ImagePickerPhotoCapturer` (cámara o galería) | `DemoPhotoCapturer` (foto de ejemplo) |
| `ImageBackgroundRemover` | `OnDeviceBackgroundRemover` (modelo ONNX en el celular, sin internet) | `MockImageBackgroundRemover` |
| `ReceiptPrinter` | `BluetoothReceiptPrinter` (ESC/POS, 58/80 mm, impresoras vinculadas) | `DemoReceiptPrinter` |
| `ReceiptSharer` | `DeviceReceiptSharer` | `DemoReceiptSharer` |

- **Impresión:** la impresora térmica se vincula primero en los ajustes de
  Bluetooth del celular; la app lista las vinculadas y recuerda la conexión.
- **WhatsApp:** abre el chat del cliente (`wa.me/591…`) con el comprobante
  como mensaje de texto; los enlaces de WhatsApp no pueden adjuntar archivos.
- **Imagen/PDF:** *Guardar* deja la imagen en la galería (el PDF va por el
  menú de compartir); *Otras apps* comparte el archivo.

## Productos y variantes

Un producto tiene una galería de fotos (la primera es la principal) y puede
variar en uno o más tipos, por ejemplo *Color: Rojo, Azul · Talla: S, M, L*.
Cada combinación (*Rojo · M*) es una variante con **su propio stock** y una foto
elegida de la galería; el stock del producto es la suma de sus variantes.

- Al vender, un producto con variantes abre un selector: se elige un valor por
  tipo y la cantidad, sin pasar el stock de esa variante.
- El carrito, el descuento de stock y los comprobantes guardan la variante
  (`SaleLine.variantLabel`), así una edición posterior no cambia ventas pasadas.
- Reglas: `ProductDraftRules` (tipos con nombre y valores sin repetir, fotos
  existentes, stock no negativo), compartidas por crear y editar.

## Pantallas

| Flujo | Pantallas |
|---|---|
| Acceso | Iniciar sesión · Crear cuenta · Verificación SMS · Tu negocio · Cómo vendes · Negocio listo |
| Inicio | Resumen del día, métodos de pago, alerta de stock bajo |
| Ventas | Apertura de caja · Venta (carrito vacío / con productos) · Buscador y catálogo · Elegir variante · Cobro · Venta registrada · Cierre de caja |
| Comprobante | Ver · Imprimir · Compartir |
| Inventario | Lista · Detalle del producto · Crear y editar producto (fotos y variantes) · Quitar fondo |

## Pendiente para producción

- Backend real (autenticación, catálogo, ventas, caja).
- Probar la impresión con las impresoras térmicas que usarán los vendedores.
- Subir las fotos de productos al backend (hoy quedan en el celular).
