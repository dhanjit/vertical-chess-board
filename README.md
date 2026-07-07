# Vertical Wall Chess Board

A chess board that **hangs on the living-room wall** like art and plays
vertically — with two signature mechanics:

- 🔄 **Rotates 180° based on whose turn it is**, so the player to move always
  sees the board from their own side.
- 🌍 **Pieces stay upright by gravity** — each piece hangs on a pivot and is
  bottom-weighted, so as the board turns, every piece self-levels and is never
  upside-down.
- 🧲 **Magnetic pieces** grip a steel-backed vertical surface.
- 🖨️ **3-D printable** — parametric models, ready for your friend's printer.
- 🤖 **Future:** the board plays against you, controllable from a phone app.

This repo is the **single source of truth** for building it: designs, models,
electronics, the game brain, and the plan.

## Repo map

```
README.md              ← you are here
CLAUDE.md              ← context for AI sessions working on this repo
docs/
  DESIGN.md            ← how it works (the two mechanics, magnets, sensing)
  GOALS.md             ← vision, phases, roadmap, decisions to lock
  BOM.md               ← shopping list per phase
  BUILD_GUIDE.md       ← step-by-step assembly (start at Phase 0!)
  ELECTRONICS.md       ← powered rotation, sensing, auto-mover, firmware plan
hardware/              ← parametric OpenSCAD models (+ Makefile → STLs)
  common.scad          ← ⭐ edit this to resize the whole board
  gravity_gimbal.scad  ← the self-righting pivot
  pieces.scad          ← the six pieces (flat self-righting silhouettes)
  board_panel.scad     ← 8×8 surface: steel pocket + hall-sensor pockets
  frame.scad           ← bezel
  rotation_hub.scad    ← wall plate + turntable + drive
software/engine/       ← the brain (plain JS, no deps)
  chess.js             ← full rules engine (perft-verified)
  ai.js                ← negamax + alpha-beta opponent
app/                   ← control-app spec (future)
```

## Start here

**New to 3D printing / electronics? Read [`docs/START_HERE.md`](docs/START_HERE.md)
first** — a plain-language guide (no experience needed) with a copy-paste
message for your printer friend and a simple shopping list.

Then, when you want the deeper detail:
1. [`docs/DESIGN.md`](docs/DESIGN.md) — the concept and mechanics.
2. [`docs/GOALS.md`](docs/GOALS.md) — phases and the decisions to lock.
3. **Phase 0** in [`docs/BUILD_GUIDE.md`](docs/BUILD_GUIDE.md): print one
   gravity gimbal + one piece and prove the self-righting magnet mechanic
   before committing to a full set.

## Status

| Area | State |
|------|-------|
| Rules engine + AI | ✅ implemented, perft-verified (20 / 400 / 8902) |
| Parametric models (pieces, gimbal, panel, frame, hub) | ✅ drafted, ready to render/tune |
| Docs (design, goals, BOM, build, electronics) | ✅ drafted |
| Anything physically built | ⬜ over to Phase 0 |

Phased so **Phase 1 alone is a complete, beautiful manual board** you can hang
and play; later phases add powered rotation, sensing, an auto-mover, and the
app without a rebuild.

## Building the STLs

```
cd hardware && make          # needs OpenSCAD; outputs to hardware/stl/
```

## Using the brain

```
node -e 'const {Chess}=require("./software/engine/chess.js"); \
         const g=new Chess(); console.log(g.legalMoves().length)'   # 20
```
