# Codex prompt — build the frontend UI (copy-paste this)

---

Read `AGENTS.md` at the project root first, then follow it exactly.

Your job: build the **customer frontend UI** (Phase 1 in `roadmap.md`) — a Flutter app that is a 100% visual/behavioral port of the old `cp-pos/` system, backed by `FakeApiClient` (no real backend needed).

Work in the `` repo. Execute `plan.md` task-by-task, T0 → T10, using the loop in `AGENTS.md §0/§3`:

1. Pick the lowest-numbered ⬜ task in `PROGRESS.md`.
2. Switch the Codex model per `AGENTS.md §4.5` (frontend: T0-T3 luna, T4-T6/T8-T10 terra, T7 sol; review always sol).
3. For each plan step: write the failing test → confirm it fails → write minimal code → run test → pass. Fix-loop until green.
4. Self-review the diff (§3.2) + check `security.md §3` items that apply. Fix real findings.
5. `flutter test && flutter analyze` must be green. Never commit red.
6. Commit (Conventional Commit, no Co-Authored-By, from ``).
7. Tick the task ⬜→✅ in `PROGRESS.md`, commit that (in the repo). Do NOT touch `roadmap.md` (it's outside the repo — overview only).
8. Go to the next task. **Do not stop between tasks. Do not ask me.**

Hard rules (from `AGENTS.md §5`): TDD always; parity with `cp-pos/` (exact tokens from `front.md §2`, Thai UI strings verbatim); no scope creep; `FakeApiClient` only (no real network in tests); the plans are already written — **do NOT re-plan or redesign**, just execute.

Stop only when every Phase 1 task (T0-T10) is ✅, or you hit a genuine BLOCKER (`AGENTS.md §6`) — then tell me the task, step, what you tried, and the error.

**DO NOT stop to report progress mid-way.** Finishing a task, tests passing, "should I continue?", "here's my status" — none of these are stopping points. After a task commits + PROGRESS.md is ticked, immediately start the next task in the SAME run without saying anything to me. The only two reasons to hand control back are: (1) all of T0-T10 done, or (2) a real BLOCKER. A finished task is a reason to keep going, never to pause. If you're unsure whether something is a blocker — it isn't; keep working. Don't ask permission, don't summarize, don't wait — just proceed to the next task.

Start now, and keep going until Phase 1 is fully ✅.
