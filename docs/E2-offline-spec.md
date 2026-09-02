# E2 — Offline-first (customer) · spec

## Goal
Losing wifi mid-order keeps the menu usable and the cart intact; reconnecting
submits the queued order **exactly once**. Scope is the customer page only —
staff/admin stay online-only (they need live shared state).

## What can go offline
| Data | Behavior offline |
|---|---|
| Catalog (categories/menu/promotions) | Served from last cached copy; browsing + cart works |
| App/brand config | Served from cache |
| Cart | Already local (`shared_preferences`); unchanged |
| **Order submit** | Queued locally, sent on reconnect |
| Order status / call staff | Require the network; show the offline banner, no queue |

## Store
Reuse `shared_preferences` — no new DB. We already persist cart there; add:
- `phius-catalog-{token}` : last successful `getCustomerData` JSON + a timestamp.
- `phius-queued-order-{token}` : one pending submit (payload + idempotencyKey).

Rationale: the customer flow holds a single active order at a time, so a
one-slot queue is enough. Avoids pulling in drift/hive for a one-item queue.

## Flow
1. **Load**: try `getCustomerData` over network → on success, cache it. On
   failure, fall back to the cached copy (if any) and raise `offline = true`.
2. **Submit**:
   - Online → submit as today. On network failure mid-submit → write the payload
     to the queue, mark `offline`, keep the cart, tell the user "จะส่งเมื่อออนไลน์".
   - The `idempotencyKey` is generated **before** the first attempt and reused for
     every retry, so the server dedupes a double-send (Transactions sheet).
3. **Reconnect**: a connectivity signal (or the next successful poll/load) drains
   the queue: re-submit with the stored idempotencyKey. On success → clear queue,
   clear cart, start status polling. On `ORDER already exists` → treat as success.

## Conflict policy
Server totals always win; the local cart is advisory. If a queued order is
rejected for a real reason (item archived, price changed, promo expired), surface
the server error and drop the queue entry — do not silently retry forever.

## Connectivity detection
Use `connectivity_plus` for online/offline transitions on web + mobile, plus a
"reconnect on next successful request" safety net (don't trust the signal alone).

## Done when
- Kill the network on the menu screen → menu still renders from cache, cart edits
  persist.
- Submit while offline → order queues, banner shows "will send when online".
- Restore network → the order submits once (verify no duplicate on the Sheet).

## Out of scope
- Offline for staff/admin.
- Background sync when the tab is closed (customer is expected to keep it open).
- Multi-order queue (one active order per table).
