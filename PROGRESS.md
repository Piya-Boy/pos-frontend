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
| T5 | CustomerPage shell (header, guide, hero) | terra | ⬜ |
| T6 | Menu (promotions, toolbar, grid, food card) | terra | ⬜ |
| T7 | Item detail modal (options/addons/note/qty/price) | **sol** | ⬜ |
| T8 | Cart bar + cart modal + submit | terra | ⬜ |
| T9 | Order tracking + bill banner + status meta + polling | terra | ⬜ |
| T10 | Responsive + parity pass | terra | ⬜ |

**Gate (Phase 1 done)**: `flutter test` green + `flutter analyze` clean + parity checklist (`test.md §4`) + frontend security (`security.md §3`).
