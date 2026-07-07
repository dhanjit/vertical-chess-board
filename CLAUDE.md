# CLAUDE.md — context for AI sessions

Read this first. It orients you to what this repo is and how to work in it.

## What this is

The **single source of truth for building a physical Vertical Wall Chess
Board** — a real object that hangs on a living-room wall. **It is not a
website or a screen app.** The two signature mechanics:

1. **Rotate by turn** — the board turns 180° so the player to move sees it
   from their side (turntable + stepper).
2. **Gravity-upright pieces** — each piece hangs on a pivot normal to the
   board and is bottom-weighted, so it self-levels like a pendulum as the
   board rotates. Pieces are **magnetic** and grip a steel-backed surface.

Future scope: the board **plays you** (auto-mover) and is **app-controlled**.

## Owner context

- The board will be **3-D printed** (the user has a friend who prints).
- The user wants this repo to hold **designs, models, plan, goals, CLAUDE.md** —
  everything needed to make the physical board real.

## Repo layout

- `hardware/` — parametric **OpenSCAD** models. `common.scad` holds ALL shared
  dimensions; change geometry there and everything downstream follows. Never
  hardcode a dimension in a part that belongs in `common.scad`.
- `software/engine/` — the **brain**: `chess.js` (rules, perft-verified) and
  `ai.js` (negamax opponent). Plain JS, no deps. Shared by firmware + app.
- `docs/` — `DESIGN.md` (how it works), `GOALS.md` (roadmap/phases/decisions),
  `BOM.md`, `BUILD_GUIDE.md`, `ELECTRONICS.md`.
- `app/` — future control-app spec.

## How to work here

- **Keep it physical-first.** Deliverables are printable parts, real BOM items,
  buildable steps — not UI. If tempted to build a screen app, stop: a digital
  *twin/simulator* is only worth it if the user asks.
- **Parametric discipline.** Add new dimensions to `common.scad`; reference
  them. Keep parts renderable (this environment has no OpenSCAD — write clean,
  standard OpenSCAD; verify syntax carefully, don't rely on rendering here).
- **Engine correctness.** If you touch `chess.js`, re-run the perft check
  (start position: depth 1/2/3 = 20/400/8902) with Node before committing.
- **Phasing.** Respect the phases in `GOALS.md`: Phase 1 must stay a complete
  manual board with no electronics. Don't let later-phase complexity leak into
  Phase 1 parts.
- **Decisions.** Open decisions live in `GOALS.md` (D1–D6) and `DESIGN.md §8`.
  If a task depends on one, either use the documented default or ask the user;
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
