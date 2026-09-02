# PROGRESS — pos-frontend (Customer UI, Phase 1)

> Task tracker for THIS repo. Tick ⬜→✅ + commit here after each task (this file lives inside the repo, so committing works).
> Plan = `plan.md`. Spec = `front.md`. Ops manual = `AGENTS.md`. Overall picture = `roadmap.md` (read-only, not per-task ticked).

Branch: `feature/customer-frontend`. Models per `AGENTS.md §4.5`.

| Task | งาน | Model | สถานะ |
|---|---|---|---|
| T0 | git branch + baseline commit | luna | ✅ (b48a84d) |
| T1 | Setup: deps, tokens, theme, Prompt font | luna | ✅ |
| T2 | Models + ApiClient interface + FakeApiClient (seed) | luna | ✅ |
| T3 | Shared widgets (brand, buttons, modal, toast, banner) | luna | ✅ |
| T4 | Router + CustomerController + persistence | terra | ✅ |
| T5 | CustomerPage shell (header, guide, hero) | terra | ✅ |
| T6 | Menu (promotions, toolbar, grid, food card) | terra | ✅ |
| T7 | Item detail modal (options/addons/note/qty/price) | **sol** | ✅ |
| T8 | Cart bar + cart modal + submit | terra | ✅ |
| T9 | Order tracking + bill banner + status meta + polling | terra | ✅ |
| T10 | Responsive + parity pass | terra | ✅ |

**Gate (Phase 1 done)**: `flutter test` green + `flutter analyze` clean + parity checklist (`test.md §4`) + frontend security (`security.md §3`).

---

## Phase 3 — Integration (frontend side) · plan `plan-integ.md`
| Task | งาน | Model | สถานะ |
|---|---|---|---|
| P3-T1 | HttpApiClient (over Laravel) | terra | ✅ |
| P3-T2 | switch Http vs Fake by config | terra | ✅ |
| P3-T4 | E2E smoke (needs backend running) | terra | ✅ full flow verified in Chrome vs live Sheets (order → kitchen → cashier close+receipt) |

## Phase 4 — Staff & Admin UI · plan `plan-staff.md`
| Task | งาน | Model | สถานะ |
|---|---|---|---|
| P4-T1 | Extend ApiClient + FakeApiClient (auth/ops/admin) | terra | ✅ |
| P4-T2 | Login + token store + AuthController | **sol** | ✅ |
| P4-T3 | Ops shell + summary + tabs + polling | terra | ✅ |
| P4-T4 | Kitchen board (kanban) | terra | ✅ |
| P4-T5 | Staff queue (calls + ready) | terra | ✅ |
| P4-T6 | Cashier bills + payment + receipt | **sol** | ✅ |
| P4-T7 | Admin shell + nav + overview | terra | ✅ |
| P4-T8 | Admin tables/catalog/promotions/staff CRUD | terra | ✅ |
| P4-T9 | Admin settings + brand preview | terra | ✅ |
| P4-T10 | Staff/Admin routing + parity pass | terra | ✅ |

## Phase 5 — Enhancements (opt-in) · plan `plan-enhance.md`
| Epic | งาน | สถานะ |
|---|---|---|
| E4 | PDF receipt (client-side, `printing`/`pdf`) | ✅ buildReceiptPdf() + "สร้าง PDF" (sharePdf → download) + "พิมพ์ใบเสร็จ" on receipt modal |
| E3 | Drive image upload (picker) | ✅ file_picker + "อัปโหลด" button on imageUrl fields → adminUploadImage → sets ImageURL; FakeApiClient stub for offline |
| E1 | Reverb realtime (subscribe) | ✅ RealtimeClient (raw pusher-protocol WS via web_socket_channel, web+mobile); ops+customer controllers subscribe, refresh on event, slow-poll (30s) while live, auto-reconnect + poll fallback on drop; E2E verified |

**Build order**: finish Phase 1 → (Phase 2 backend by the other repo) → Phase 3 → Phase 4 → Phase 5 epics as requested.
