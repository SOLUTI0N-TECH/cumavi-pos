# CUMAVI POS — Roadmap of new features (mobile POS)

What is new or planned for the POS app (`apps/mobile`), phase by phase.
Status legend: **Planned** · **In progress** · **Done**.

Last update: 2026-10-10 (Phase 3 online orders done against B7-shaped mocks;
backend plan in [backend-roadmap.md](backend-roadmap.md), module scope docs
listed in the [docs index](README.md)).

## Ground rules

- **Mocked data for now.** Every feature adds domain entities and a
  repository interface with an in-memory mock. Those interfaces are the
  contract for the backend (Postgres + API, built separately): switching to
  the real API only changes `app/di/dependency_injection.dart`.
- **Three tabs stay** (Inicio / Ventas / Inventario). New areas live in a
  **"Más" hub** opened from the avatar on Inicio.
- **Same quality bar:** texts in `lib/l10n/app_es.arb`, unit and widget tests,
  every demo flow usable end to end (no dead buttons), and an APK at the end
  of each phase.
- **Web catalog** (`apps/web`) is unchanged unless a feature says otherwise.
- **Backend:** the API is specified module by module in `docs/modulos/*.md`
  (Spanish) and built in phases B0–B11 ([backend-roadmap.md](backend-roadmap.md)).
  From Phase 5 on, features are built against the API (with the mock kept as
  a `mock` flavor for demos); the "API contract" lines below are superseded by
  the module docs where they differ (listed in feature 23).

## Overview

| Phase | # | Feature | Size | Status |
|---|---|---|---|---|
| 1 · Daily operation | 1 | "Más" hub (account, business, sign out) | S | **Done** |
| | 2 | Categories management | S | **Done** |
| | 3 | Stock movements (receiving, adjustments, history) | M | **Done** |
| | 4 | Sales history | M | **Done** |
| | 5 | Cancel and return sales | M/L | **Done** |
| 2 · Sell better | 6 | Barcode and SKU | M | **Done** |
| | 7 | Price per variant | S | Planned |
| | 8 | Promotions | M | Planned |
| | 9 | Customers | M | Planned |
| | 10 | Fiado (credit sales) | L | Planned |
| 3 · Online orders | 11 | Online store settings + QR poster | M | **Done** (mock) |
| | 12 | Orders inbox | L | **Done** (mock) |
| | 13 | Order import by link (WhatsApp → POS) | M | **Done** (lite) |
| 4 · Team and insight | 14 | Users and roles | L | Planned |
| | 15 | Reports | L | Planned |
| | 16 | Stock alerts and reorder list | S | Planned |
| 5 · Ajustes para el backend | 17 | API foundation | M | Planned |
| | 18 | Real sign-in and registration | M | Planned |
| | 19 | Business, branch and cash register selector | M | Planned |
| | 20 | Swap mock repositories for the API | L | Planned |
| | 21 | Configurable payment methods + split payments | M | Planned |
| | 22 | Several cash registers + cash in/out | M | Planned |
| | 23 | Contract fixes | S | Planned |
| | 24 | Stock per branch + transfers | M | Planned |
| | 25 | Purchases and suppliers | L | Planned |
| | 26 | Push, realtime and orders inbox | M | In progress (inbox + in-app events; FCM pending) |

**Backend phase for each feature** (see [backend-roadmap.md](backend-roadmap.md)):

| Backend phase | Mobile features |
|---|---|
| B0–B1 Foundation, identity, business, branches | 1 (connect), 17, 18, 19 |
| B2 Catalog | 2, 6 (connect), 7, 20, 23 |
| B3 Inventory | 3 (connect), 20, 24 |
| B4 Cash register and payment methods | 19, 21, 22 |
| B5 Sales | 4, 5 (connect), 20, 21, 23 |
| B6 Customers | 9 |
| B7 Ecommerce and orders | 11, 12, 26 (13 superseded) |
| B8 Team and roles | 14 |
| B9 Purchases | 25 |
| B10 Reports and alerts | 15, 16 |
| B11 Later | 8, 10 |

Suggested build order once the backend starts: 17 → 18 → 19 → 20/23 (catalog,
inventory) → 21/22 → 20/23 (sales) → 24 → 9 → 11/12/26 → 14 → 25 → 15/16.

Gaps in the current app that Phase 1 closes: there is no sales history, a
sale can't be cancelled or returned, categories are fixed (Ropa, Calzado,
Accesorios), stock only changes through sales or product edits with no record
of why, and there is no sign out or settings area.

---

## Phase 1 — Daily operation

Implementation order: **1 → 2 → 3 → 4 → 5**. Returns need the sales history
(to find the sale) and stock movements (to put units back), so they go last.

### 1. "Más" hub — S · Done (2026-09-25)

**Goal:** a home for everything outside the three tabs, and sign out.

**Screens**
- The avatar on Inicio opens **"Más"**:
  - **Cuenta:** name, phone or email, sign-in method, "Cerrar sesión".
  - **Negocio:** edit name, type, department, logo and NIT (reuses the
    registration form widgets).
  - **Operación:** Historial de ventas, Movimientos de stock, Categorías — each
    item appears once its feature exists.
  - App version.
- **Cerrar sesión:** confirmation; if the cash drawer is open it warns
  "La caja queda abierta". Clears the session and the cart, back to sign in.

**Code:** new `lib/features/account` (presentation), `AppRoutes.more`,
`SignOut` use case (`AuthRepository.signOut()`, then `CartCubit.clear()`),
`UpdateBusinessProfile` reusing `saveBusinessProfile`.

**API contract:** `POST /auth/sign-out`, `PATCH /business`.

**Tests:** sign out clears session and cart; the hub renders at phone size.

### 2. Categories management — S · Done (2026-09-25)

**Goal:** the seller manages their own categories.

**Screens**
- **Categorías** (from Más and a "Gestionar" shortcut in the inventory
  filters): product count per category, drag to reorder, rename in a sheet,
  archive; archived ones in their own section, restorable.
- "+ Nueva categoría" inside the product form's category picker.

**Rules**
- Name 2–30 characters, unique ignoring case and accents.
- No hard delete, only archive: an archived category disappears from pickers
  but its products keep it (history and backend stay consistent).
- Fixes a gap: the categories chosen in registration step 4 are created in
  the catalog.

**Code:** `ProductCategory` gains `sortOrder` and `isArchived`;
`ProductRepository` gains `createCategory`, `renameCategory`,
`reorderCategories` and `setCategoryArchived(id, archived:)` (archive and
restore in one call) (+ use cases). `getCategories(includeArchived:)`.
Renaming updates the category on its products; search and name checks share
`TextNormalizer`.
New failure codes: `categoryNameInvalid`, `categoryNameTaken`.

**API contract:** `GET/POST /categories`, `PATCH /categories/{id}`,
`PUT /categories/order`.

**Tests:** name rules, reordering, archiving hides from pickers, registration
categories are created.

### 3. Stock movements — M · Done (2026-09-25)

**Goal:** every stock change leaves a record with its reason.

**Screens**
- **Ingreso de mercadería** (Inventario header button, and "Agregar stock"
  on the product detail): search product → variant → quantity → optional
  unit cost; several lines per entry; optional supplier or note.
- **Ajustar stock** (product detail, per variant): add/remove units or type
  the counted quantity (the app computes the difference); reason required —
  count, damage, loss, other — plus a note.
- **Movements history:** last 5 on the product detail with "Ver todos";
  global screen in Más with filters by type and date. Each row: date, type,
  variant, quantity, resulting stock, who did it.

**Decision:** when **editing** a product, stock is read-only with an
"Ajustar stock" button, so no stock change goes unrecorded. Creating a
product records its initial stock as an "Inventario inicial" movement.

**Code:** new `lib/features/inventory`. `StockMovement` becomes an entity:
`id, productId, variantId?, delta, type (initial | purchase | adjustment |
sale | cancellation | return), reason?, note?, unitCost?, saleId?, userName,
createdAt`. `InventoryRepository.recordMovements(drafts)` (all-or-nothing)
and `getMovements(filters)`. `RegisterSale` records `sale` movements instead
of calling `reduceStock`. The mock seeds some past movements.

**API contract:** `POST /stock-movements`,
`GET /stock-movements?productId&variantId&type&from&to`.

**Tests:** receiving and counts compute the right difference; no adjustment
leaves stock below zero; sales produce movements tied to `saleId`; product
editing no longer changes stock.

**As built:**
- Entry points: "Ingreso" and "Ajustar" on the product detail's stock card,
  with its last 5 movements and "Ver todos"; the receiving button in the
  Inventario header; "Movimientos de stock" in Más → Operación.
- Receiving: pick products by search or scan (a variant asks which), units,
  optional cost per unit, supplier or note. Adjusting: Contar / Agregar /
  Quitar with a live "3 → 4 (+1)" preview; reasons Conteo, Dañado, Pérdida,
  Otro (a count suggests "Conteo").
- History filters: Todos, Ingresos, Ajustes, Ventas, Inventario inicial;
  7 days, 30 days or everything.
- Editing a product keeps its stock; new variants added while editing start
  at 0 and get their units with an "Ingreso". Removing a variant while
  editing drops its units without a movement (known gap, backend should
  record it).
- `RegisterSale` no longer uses `ProductRepository.reduceStock` (removed);
  it records sale movements with the sale id after storing the sale.
- The mock ledger applies changes through
  `InMemoryProductDataSource.applyStockChanges` (all or nothing); with the
  backend, `POST /stock-movements` updates the stock server-side.

### 4. Sales history — M · Done (2026-09-25)

**Goal:** find any past sale, not only the last one.

**Screens**
- **Historial de ventas** (from Más, from "Ventas de hoy" on Inicio, and from
  the cash close screen): grouped by day; each row shows number, time, item
  summary, payment method, total and status. Filters: Hoy, Ayer, Últimos 7
  días or a custom range, payment method; search by sale number.
- **Detalle de venta:** lines with variants, discount, total, payment and
  change, cashier, time. Actions: view/print/share the receipt (existing),
  and "Anular" / "Devolver" once feature 5 exists.

**Code:** `SalesRepository.getSales(SaleQuery)` (`from`, `to` exclusive,
`paymentMethod`, `number`; `status` arrives with feature 5), `GetSales` and
`GetSale` use cases, `SalesHistoryCubit`, `SaleDetailCubit`, `SalesDay`
grouping. Searching by number looks through every date. The mock gains 103
sales over the last 14 days, numbered before today's 18, which still drive
Inicio and the cash close. Entry points: Más → Operación, "Ver historial" on
Inicio's sales card, and "Ver las ventas del día" on the cash close.

**API contract:** `GET /sales?from&to&paymentMethod&status&number`,
`GET /sales/{id}`.

**Tests:** date and method filters, grouping by day, detail and receipt
actions.

### 5. Cancel and return sales — M/L · Done (2026-09-25)

**Goal:** fix mistakes and handle returns without breaking stock or cash.

**Rules**

| | Anular (whole sale) | Devolver (some units) |
|---|---|---|
| When | Only while that sale's cash session is open | Up to 30 days after the sale |
| Scope | The whole sale | Chosen lines and quantities, never more than sold minus already returned |
| Stock | Everything goes back | Per-line "vuelve al stock" switch (off for damaged items) |
| Money | Leaves the totals and the expected cash | Refund by the same method or in cash; the global discount is prorated per line |
| Required | Reason | Reason |
| Receipt | Original marked "ANULADA" | Printable/shareable return receipt; original marked "Devolución parcial" |

**Effects:** Inicio and the cash close show net sales (sales − returns);
refunds reduce the expected cash of the session where they happen
(`DailySalesSummary` and `CashCloseSummary` gain refunds by method). Stock
goes back through `cancellation` / `return` movements (feature 3).

**Code:** `Sale` gains `status` (completed | cancelled | partiallyReturned |
returned) and `cancellation {reason, at, by}`. New `SaleReturn {id, number,
saleId, lines [{productId, variantId?, quantity, amount, restock}],
refundMethod, amount, reason, createdAt, cashierName}`. `SalesRepository`
gains `cancelSale(saleId, reason)`, `registerReturn(draft)`,
`getReturns({from, to})`; use cases `CancelSale` and `RegisterReturn`.
New failure codes: `saleAlreadyCancelled`, `saleCancelWindowClosed`,
`returnWindowClosed`, `returnQuantityExceeded`.

**API contract:** `POST /sales/{id}/cancel`, `POST /sales/{id}/returns`,
`GET /returns?from&to`.

**Tests:** discount proration; no cancellation after the cash close; returned
quantity never exceeds sold across several returns; cash and card refunds
change the right totals; stock goes back only when chosen.

**As built:**
- The sale carries its `cancellation` and its `returns`; `status`,
  returned and returnable quantities and the prorated refund
  (`Sale.refundFor`, the last units refund exactly what is left) are
  derived from them. Lines are referenced by index (`lineIndex`).
- Anular: from the sale detail, with a reason, only for sales made since the
  open cash session started and with no returns (`saleHasReturns`). Devolver:
  units per line, "Vuelve al stock" switch, refund by the sale's method or
  cash, quick reasons or a typed one; needs an open cash session.
- Totals are net: `DailySalesSummary.totalsByMethod` leaves out cancelled
  sales and subtracts refunds made in the period (`refundCount`,
  `refundsByMethod`); the cash close shows a "Devoluciones" line.
- Receipts: stamped ANULADA / CON DEVOLUCIÓN PARCIAL / DEVUELTA; a return
  prints and shares as "Comprobante de devolución" D-0001 with "De la venta
  #0083", "TOTAL DEVUELTO" (`Receipt.refund`).
- History rows show "Anulada" (struck total) or the return status. Demo
  data: yesterday's #0100 cancelled, a partial return on #0083.
- `getReturns` was not needed by the app (summaries read the returns from
  the sales); the backend can still expose `GET /returns?from&to`.
- Extra failure codes: `saleHasReturns`, `invalidRefundMethod`,
  `emptyReturn`, `reasonRequired`.

---

## Phase 2 — Sell better

| # | Feature | What it does | Size |
|---|---|---|---|
| 6 | **Barcode and SKU** | SKU/barcode per product or variant; camera scanner in the sales search and in inventory (the scan button already exists) | M |
| 7 | **Price per variant** | Optional price override (e.g. XL costs more); cart and receipts use it | S |
| 8 | **Promotions** | Percent or amount discount per product or category, with dates; shown in the sale and on the receipt | M |
| 9 | **Customers** | Customer list; attach a customer at checkout; purchase history; contact by WhatsApp | M |
| 10 | **Fiado (credit)** | Sell on credit, track each customer's balance, record payments, WhatsApp reminders; payments count in the cash register | L |

### 6. Barcode and SKU — M · Done (2026-09-25)

**What the seller gets**
- **SKU and barcode** (both optional) on the product and on each variant.
  "Generar" proposes the next SKU of the category (`CAL-013`) and codes the
  variants without one (`CAL-013-ROJ-38`). Tap a variant's name in the form
  to edit its codes.
- **Scanner screen** (`/scan`, camera via `mobile_scanner`: EAN/UPC,
  Code 128/39, QR, with a flashlight button). The code can also be typed,
  which is how Bluetooth scanners work too. While the catalog is mocked it
  shows **demo codes** (Gorra, Polera Negra M, Mochila, and a new code).
- **Ventas:** the scan button in the search bar and in the catalog adds the
  product to the sale. A variant's code adds that exact variant; a product's
  code asks for the variant; an unknown code says so.
- **Inventario:** scanning opens the product. An unknown code offers
  **"Crear producto con este código"**, which opens the form with the barcode
  filled in.
- Search also finds products by part of a SKU or barcode (3+ characters).
- The product detail shows a **Códigos** card; variant rows show their codes.

**Rules:** codes are stored trimmed, in capitals and without spaces. SKU:
2–32 letters (no accents), digits, `-`, `_` and `.`. Barcode: 4–32
letters, digits, `-`, `.` or `/`. Every code is unique in the whole store
(products and variants, SKU and barcode together), so a scan never has two
answers. New failure codes: `invalidSku`, `invalidBarcode`,
`productCodeRepeated`, `productCodeTaken`, `productCodeNotFound`.

**API contract:** `sku`/`barcode` on product and variant in
`GET/POST/PUT /products`; `GET /products/lookup?code=` returns the product
and, when the code is a variant's, `variantId` (404 when unknown); 409 when
a code is taken. The mock seeds EAN-13 codes with Bolivia's GS1 prefix 777.

**Android:** ML Kit comes from Google Play services
(`dev.steenbakker.mobile_scanner.useUnbundled=true`), so the APK doesn't
bundle the model.

**Data:** `sku` and `barcode` on product and variant; `price` on variant;
`Promotion`; `Customer`; `CreditSale`; `CreditPayment`.
**Web impact:** price per variant and promotions need the same fields in the
web catalog later.

## Phase 3 — Online orders (link with the web catalog)

| # | Feature | What it does | Size |
|---|---|---|---|
| 11 | **Online store settings** | Catalog link and printable QR poster ("Escanea y pide"); opening hours, pickup/delivery, payment methods, WhatsApp number; per-product "show online" switch | M |
| 12 | **Orders inbox** | Incoming orders (mocked) with states new → confirmed → ready → delivered / cancelled; confirm by WhatsApp; convert an order into a sale, discounting stock | L |
| 13 | **Order import by link** | The web's WhatsApp message carries a link that opens the order in the POS — works without a backend; the API later replaces it with real delivery | M |

**Data:** `StoreSettings`; `Order` (its shape already exists in the web:
`apps/web/src/features/ordering/domain/order.ts`).
**Web impact:** feature 13 adds the import link to the WhatsApp message.

**Update (2026-10-05):** these features are built against the API (backend
phase B7, scope in [modulos/ecommerce.md](modulos/ecommerce.md)): settings
per business with online branches, orders delivered to the branch's inbox in
real time, and "Cobrar pedido" creating the sale. **Feature 13 is superseded
by B7** and only makes sense if the API is delayed.

**Build (2026-10-10):** the backend only has B0–B1, so 11 and 12 are built
against in-memory mocks shaped like B7 (entities, states, rules ECO-R8..R10
and error codes as in [modulos/ecommerce.md](modulos/ecommerce.md)). A
light version of 13 is built too, so web orders reach the POS before the API
exists. No design existed: screens follow the app's current style.

### 12. Orders inbox — L · Done (2026-10-10, mock)

**What the seller gets**
- **Pedidos en línea** from a card on Inicio (badge with new orders) and from
  Más → Operación. Tabs **Nuevos / En curso / Entregados / Cancelados**.
- A new order shows a snackbar anywhere in the app ("Nuevo pedido #1006 ·
  Bs …" → Ver). In demo mode a banner offers **"Simular pedido"**.
- **Order detail:** status, customer (Llamar / WhatsApp), lines and totals
  with delivery fee, history with who did each step.
- **Actions by state:** new → *Confirmar* (a delivery asks the fee) or
  *Cancelar*; confirmed → *Marcar como listo*; ready → **Cobrar pedido**.
  *Editar* (quantities, remove lines, fee) while new or confirmed; cancelling
  asks a reason (quick reasons offered). After each step, **"Avisar"** opens
  WhatsApp with a message for that state.
- **Cobrar pedido** opens the normal checkout with the order's cart (order
  prices, fee included); paying creates the sale (`channel: onlineOrder`,
  `orderNumber`), discounts stock with movements and marks the order
  delivered. Receipts and sale detail show "Envío" and "Pedido en línea #N".

**Rules:** transitions new → confirmed | cancelled, confirmed → ready |
cancelled, ready → cancelled; *delivered* only through Cobrar pedido (ECO-R8,
R9). Edits only while new/confirmed and leave a history entry (ECO-R10).
Fee ≥ 0. Stock is checked when charging, not when the order arrives. New
failure codes: `orderNotFound`, `invalidOrderTransition`, `orderNotEditable`,
`orderEmpty`, `invalidDeliveryFee`, `storeDisabled`, `phoneAppUnavailable`,
`linkUnavailable`.

**Contract (mock → B7):** `OrderRepository` with `getOrders`, `getOrder`,
`watch()` (event stream, the socket later), `changeStatus`, `editOrder`,
`markDelivered`, `importOrder`. `Sale` gains `deliveryFee`, `channel`,
`orderId`, `orderNumber` — **to confirm with the backend** (B5/B7 docs don't
list `deliveryFee`/`orderNumber` on the sale yet).

**Simplifications until the API:** one branch; no customer record (CLI-R2
comes with feature 9); payment methods are the enum and one payment per
order (feature 21); no FCM push (feature 26).

### 11. Online store settings + QR poster — M · Done (2026-10-10, mock)

- Más → Negocio → **Tienda en línea**: store on/off, link (Copiar /
  Compartir / Abrir) and "Abierta ahora / Cerrada ahora", tagline, WhatsApp
  for orders, pickup and delivery (with a note), opening hours per day with
  several ranges, "recibir pedidos fuera de horario", show out-of-stock
  products, online payment methods. Save in the bottom bar, only with
  changes.
- **Póster QR** "Escanea y pide": on screen, printed (A5 PDF) or shared.
- Per-product **"Mostrar en la tienda en línea"** switch in the product form;
  the settings show how many products are online.
- **Rules:** valid Bolivian mobile for WhatsApp, at least one fulfillment
  and one payment method, ranges close after they open and don't overlap
  (SUC-R5). Codes `invalidOpeningHours`, `onlineFulfillmentRequired`,
  `onlinePaymentMethodRequired`. A disabled store receives no orders.
- The web catalog still reads its own demo data; it reads these settings
  when B7 exists.

### 13. Order import by link — M · Done (2026-10-10, lite)

- The web's WhatsApp message now ends with "Ábrelo en Cumavi POS: <link>".
  The link (`/<store>/pedido/importar/?d=…`) carries the order as compact
  base64url JSON (v1) and opens a page with a summary and **"Abrir en Cumavi
  POS"** (Android intent `cumavipos://pos/orders/import`).
- In the POS: the link opens **Importar pedido**, or the seller pastes the
  whole message (Pedidos → import button). The order joins the inbox as new.
- Importing twice doesn't duplicate; orders of another store, unknown
  products and broken links are refused (`invalidOrderLink`,
  `orderFromAnotherStore`, `productNotFound`).
- Goes away with B7, when orders arrive through the API.

## Phase 4 — Team and insight

| # | Feature | What it does | Size |
|---|---|---|---|
| 14 | **Users and roles** | Owner and cashiers, quick PIN switch, permissions (see costs, cancel sales, edit inventory); every sale and cash session records its cashier | L |
| 15 | **Reports** | Sales by period, top products and variants, margin, by payment method and cashier, past cash closes; export to Excel/CSV | L |
| 16 | **Stock alerts and reorder list** | Low-stock list turned into a supplier order sent by WhatsApp | S |

**Data:** `User` with role and permissions; report queries (good candidates
to compute on the server).

**Update (2026-10-05):** feature 14 follows [modulos/usuarios.md](modulos/usuarios.md)
and [modulos/roles.md](modulos/roles.md): one global account per person,
memberships per business with a role and allowed branches, the owner creates
staff accounts (email + temporary password; an existing email just gets the
membership) and resets their passwords, editable roles from 4 templates. **Permissions are enforced by the
server**; the app only hides actions using the permissions from
`/me/memberships`.

---

## Phase 5 — Ajustes para el backend

**Goal:** turn the mocked app into a client of the real API, and close the
gaps the backend design introduces (branches, several cash registers, split
payments, purchases). Runs alongside backend phases B0–B9.

| # | Feature | What it does | Size | Backend |
|---|---|---|---|---|
| 17 | **API foundation** | HTTP client (dio) with auth interceptor and refresh rotation; `x-business-id` / `x-branch-id` headers; error `code` → `FailureCode` (new codes added); UUID v7 ids and `Idempotency-Key` on every write; `mock` / `api` flavors in `dependency_injection.dart`; retry policy for network errors | M | B0–B1 |
| 18 | **Real sign-in and registration** | Email + password, no third parties: sign-in screen calls `POST /auth/login`; registration step 1 asks name, email, password and optional phone and calls `POST /auth/register`; the SMS code step and the Google button are removed; steps 3–4 call `POST /businesses` (payment methods from step 4 are now saved); forced "change password" screen when `user.mustChangePassword` (`PUT /me/password`); new codes `invalidCredentials`, `accountLocked`, `emailTaken`, `weakPassword`, `currentPasswordInvalid`; session restore from secure storage; sign out revokes the session | M | B1 |
| 19 | **Business / branch / cash register selector** | After sign-in: no membership → register a business; several → pick one; then pick branch and cash register. Branch shown on Inicio; switch from "Más". Every request carries the context headers | M | B1, B4 |
| 20 | **Swap mock repositories for the API** | One module at a time (categories, products, inventory, cash, sales): `Remote*DataSource` classes; search, filters, summaries and pagination move to the server; product photos are uploaded | L | B2–B5 |
| 21 | **Configurable payment methods + split payments** | `PaymentMethod` enum → entity loaded from the business (`id`, `name`, `type`, `isCash`); settings screen; checkout with several payments ("Agregar otro pago"), change only in cash; receipts and summaries grouped by method id | M | B4–B5 |
| 22 | **Several cash registers + cash in/out** | Pick the register when opening; cash in/out with reason, amount and receipt photo; close shows the server's expected amount, or a blind close without `cash.view_expected`; closing history | M | B4 |
| 23 | **Contract fixes** | `SaleReturnLine.lineIndex` → `saleLineId`; `Sale.cashSessionId`; `SaleLine.unitCost`; variants use the server uuid (`key` like `rojo/40` for display); simple products hide the default variant; removing a variant records a `variant_removed` movement (server side); sale number comes from the server; handle `priceChanged` | S | B2–B5 |
| 24 | **Stock per branch + transfers** | Stock shown for the active branch; "Otras sucursales" on the product detail; transfers: create, send, receive (with shortages), list in/out | M | B3 |
| 25 | **Purchases and suppliers** | Más → Compras: suppliers, purchase orders (draft → confirmed → partial / received), receive by line, supplier payments (optionally from the cash drawer), share the order by WhatsApp. "Ingreso de mercadería" stays for quick receipts, with a supplier picker | L | B9 |
| 26 | **Push, realtime and orders inbox** | FCM token registration, socket connection while the app is open, orders inbox badge on Inicio, notifications screen | M | B7 |

**Rules for this phase**
- The mock flavor keeps working for demos and widget tests; repository
  interfaces stay the contract, extended where the backend needs it.
- Server errors map to `FailureCode` by name; new codes are listed in
  [arquitectura-backend.md](arquitectura-backend.md) §5.
- Writes are safe to retry (same UUID + `Idempotency-Key`), which prepares a
  future offline queue.

**Tests:** repository tests against recorded API responses; flavor switch;
refresh-token rotation; split-payment totals and change; blind close hides
the expected amount.

---

## Later (needs the backend or external providers)

- Electronic invoicing (SIN).
- Push notifications for new orders. → now feature 26 (B7).
- Sync between several devices of the same store. → solved by the API
  (features 17–20).
- Online payments.
- Offline sales queue (the API is already idempotent for it).

## Open decisions

| Decision | Proposal | Status |
|---|---|---|
| Where new areas live | "Más" hub from the avatar on Inicio (keeps 3 tabs) | Adopted |
| Stock when editing a product | Read-only; changes through "Ingreso" / "Ajustar" | Adopted |
| Cancel vs return window | Cancel while the cash session is open; return up to 30 days | Adopted |
| Mockups first? | Straight to code; Design canvas only for complex screens | Proposed |
| Catalog and stock with branches | One catalog per business; stock per branch and variant; optional price per branch | Adopted |
| Payments | Configurable methods per business; split payments | Adopted |
| Cash register | Several registers per branch; one open session per register; no shifts | Adopted |
| Business/branch context | `x-business-id` / `x-branch-id` headers, not in the token | Adopted |

All backend decisions: [decisiones-y-riesgos.md](decisiones-y-riesgos.md).
