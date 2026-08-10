# CLAUDE.md — context for AI sessions

Read this first. It orients you to what this repo is and how to work in it.

## What this is

The **single source of truth for building a physical Vertical Wall Chess
Board** — a real object that hangs on a living-room wall. **It is not a
website or a screen app.** The two signature mechanics:

1. **Rotate by turn** — the board turns 180° so the player to move sees it
   from their side (turntable + stepper).
2. **Gravity-upright pieces** — each piece hangs on a pivot normal to the
   board and is bottom-heavy **by shape** (solid below the pivot, hollow above
   it — no ballast, nothing glued in), so it self-levels like a pendulum as the
   board rotates. A magnet grips a steel-sheet playing face directly; **where
   that magnet lives is a selectable variant** — in a printed hub puck on the
   board (`pivot_type = "pin"`, the default) or in the piece's own bore
   (`"magnet"`).

**The piece design is carried as a VARIANT SYSTEM, not one settled answer**
(decision **D12**). Two independent selectors at the top of
`hardware/common.scad`:

- `piece_style` — `"monolith"` | `"familiar"` (default) — the **artwork**, one
  file per style in `hardware/styles/`.
- `pivot_type` — `"pin"` (default) | `"magnet"` — **how a piece hangs**, both
  built in `hardware/gravity_gimbal.scad`.

The axes are independent: no style file mentions a pivot, no pivot code mentions
a style, and all four combinations build. **Never write a doc claiming the set
*is* one style or one pivot** — say which is the default and that it is
selectable. `docs/PIECE_DESIGNS.md` is the side-by-side comparison and the page
to keep in sync when either axis changes.

Aspirational (further-out) scope: the board **plays you** (auto-mover) and is
**app-controlled** — deliberately *not* the current focus; the near-term goal
is the hand-played manual board.

## Project context

- Parts are **3-D printed** from parametric OpenSCAD models; whoever runs the
  printer should start at `hardware/README.md`.
- Assume readers may be **new to 3-D printing / electronics / making**. Keep
  guidance beginner-friendly and plain-language; explain jargon; lead
  newcomers to `docs/OVERVIEW.md` (one-page what/why/how + plan) and
  `docs/START_HERE.md`. Phase 1 (manual board, no electronics) is the realistic
  near-term target; keep later phases clearly labeled optional/advanced, and the
  auto-mover (Phase 3) + app (Phase 4) labeled **aspirational**.
- **This repo is shared.** Keep committed content impersonal: no personal
  names, emails, private context, or references to specific people. Write
  docs for "the builder" / "whoever prints", not for a named individual.

## Repo layout

- `hardware/` — parametric **OpenSCAD** models. `common.scad` holds ALL shared
  dimensions *and the two variant selectors*; change geometry there and
  everything downstream follows. Never hardcode a dimension in a part that
  belongs in `common.scad`. `pieces.scad` is the **mechanism** (extrude, bore,
  hollow, drain) and draws no artwork; `hardware/styles/*.scad` is the
  **artwork** and knows nothing about bores or magnets. Each style file exposes
  exactly three public symbols — `<style>_silhouette2d/_pheight/_drains` — and
  its own *drawing* constants stay in that file, not in `common.scad`.
- `software/engine/` — the **brain**: `chess.js` (rules, perft-verified) and
  `ai.js` (negamax opponent). Plain JS, no deps. Shared by firmware + app.
- `docs/` — `OVERVIEW.md` (one-page what/why/how + plan — the entry point to
  share), `DESIGN.md` (how it works), `PIECE_DESIGNS.md` (the piece variants
  side by side, with measured costs), `GOALS.md` (roadmap/phases/decisions),
  `BOM.md`, `BUILD_GUIDE.md`, `ELECTRONICS.md`.
- `app/` — future control-app spec.

## How to work here

- **Keep it physical-first.** Deliverables are printable parts, real BOM items,
  buildable steps — not UI. If tempted to build a screen app, stop: a digital
  *twin/simulator* is only worth it if explicitly requested.
- **Parametric discipline.** Add new dimensions to `common.scad`; reference
  them. If OpenSCAD is on PATH, actually render touched parts (`cd hardware &&
  make FN=32` for a quick pass) and check the log for `non-manifold`/`WARNING`;
  otherwise write clean, standard OpenSCAD and verify syntax by careful reading.
  A clean render still doesn't prove connectivity — count shells in the STL if
  a change could disconnect geometry (thin silhouettes, added bosses).
- **Engine correctness.** If you touch `chess.js`, re-run the perft check
  (start position: depth 1/2/3 = 20/400/8902) with Node before committing.
- **Phasing.** Respect the phases in `GOALS.md`: Phase 1 must stay a complete
  manual board with no electronics. Don't let later-phase complexity leak into
  Phase 1 parts.
- **Decisions.** Decisions live in `GOALS.md` (D1–D12) and `DESIGN.md §8`.
  D3–D6 are still open; D1, D2, D7–D11 and D12 are locked on physical grounds —
  do not silently re-open them. **D12 is locked on the *system* (variants are
  kept side by side) and still open on the *choice* (which combination gets
  printed 32 times); D11 is scoped to `"monolith"` only, not repo-wide.**
  If a task depends on one, either use the documented default or ask;
  then record the choice in `GOALS.md`.

## Conventions

- Units: **millimeters** in all hardware.
- Board coordinates match the engine: index `0=a8 … 63=h1`, files a→h. The
  hall-sensor grid uses the same indexing so firmware and engine agree.
- Verify Node snippets actually run; verify SCAD compiles mentally (balanced
  modules, no undefined vars). Don't claim a part renders unless you've
  reasoned through it.

## Quick commands

```
cd hardware && make                 # render all STLs (needs OpenSCAD)
node -e 'require("./software/engine/chess.js")'   # smoke-load the engine
```

## Current status

Engine + AI implemented and verified; all core parts and docs drafted; nothing
physically built yet. Next real-world step is **Phase 0** in
`docs/BUILD_GUIDE.md` (prove the gravity-magnet piece before printing a set).
