# Goals & Roadmap

**Vision:** a chess board that hangs on the living-room wall like art, plays
vertically, rotates to face whoever's turn it is, keeps its pieces upright by
gravity, and — eventually — plays against you and is controllable from a phone.

This repo is the **single source of truth** for making that real: designs,
printable models, electronics, firmware, the game brain, and the plan.

> **First-time builder?** Read [`PROJECT_REVIEW.md`](PROJECT_REVIEW.md) — an
> honest review of the idea, a difficulty/risk read of each feature, and a
> **re-scoped staged plan (A–E)** that maps onto the phases below. Bengaluru
> sourcing is in [`SOURCING_BANGALORE.md`](SOURCING_BANGALORE.md). The phases
> below are the full technical roadmap; the review tells you which parts a
> beginner should actually take on first (short version: nail the **manual
> board**, treat electronics as later, optional projects).

---

## Guiding principles

- **Working thing at every phase.** Phase 1 alone is a gorgeous, usable board.
  Each later phase adds capability without a rebuild.
- **Parametric first.** All geometry flows from
  [`hardware/common.scad`](../hardware/common.scad). Resize by editing numbers.
- **Buy the boring parts.** Bearings, steppers, magnets, MCUs are off-the-shelf
  (see [`BOM.md`](BOM.md)). We print the clever bits.
- **The brain is portable.** The rules engine + AI are plain JS so they can run
  in a phone app, on a Raspberry Pi, or (trimmed) on an ESP32.

---

## Phases

### Phase 0 — Prototype the two hard mechanics ⬜
Prove the ideas cheaply before committing to a full board.
- [ ] Print one **gravity gimbal** pair (`gravity_gimbal.scad`) + one piece;
      confirm it **self-rights** smoothly and a magnet **holds on steel**.
- [ ] Print one **board tile** section; confirm magnet slide + hold through the
      front wall, and hall sensor trips under a piece.
- [ ] Tune `axle_fit`, `magnet_dia`, weight pocket until swing is crisp.
- **Exit criteria:** a piece sticks to a vertical steel scrap and stays upright
  when you rotate the scrap by hand.

### Phase 1 — Manual magnetic wall board (no electronics) ⬜
A complete, beautiful board you can hang and play today.
- [ ] Full **32-piece set** (2 finishes) + spares.
- [ ] Full **board panel** (whole or quartered) with steel sheet + labels.
- [ ] **Frame** + **turntable on the lazy-susan bearing**, hand-rotated.
- [ ] Wall mount (French cleat) and balance so it flips with a light push.
- **Exit criteria:** hangs level, holds all pieces, spins 180° by hand, pieces
  stay upright throughout a full game.

### Phase 2 — Powered rotation + board sensing ⬜
The board turns itself and follows the game.
- [ ] **NEMA-17 + GT2** drive, **hall home sensors**, rotates 180° on command.
- [ ] **8×8 hall-sensor grid** read by the MCU → live occupancy.
- [ ] Firmware runs [`chess.js`](../software/engine/chess.js): tracks state,
      **validates moves**, signals illegal moves (LED/buzzer/app).
- [ ] Auto-rotate when a legal move completes; manual "flip" button too.
- **Exit criteria:** play a full legal game; board follows every move and
  flips itself; illegal moves are flagged.

### Phase 3 — The board plays you (auto-mover) ⬜
- [ ] Behind-panel **Core-XY gantry + electromagnet** moves the board's pieces.
- [ ] [`ai.js`](../software/engine/ai.js) picks moves at selectable strength.
- [ ] Captures routed to an off-board "graveyard" lane.
- **Exit criteria:** pick a difficulty, the board makes its own legal moves,
  including captures and castling.

### Phase 4 — App & polish ⬜
- [ ] Phone **app** (BLE/Wi-Fi): difficulty, hints, takeback, clock, PGN export.
- [ ] Online play / puzzles / "play a friend remotely, board mirrors it."
- [ ] Sound, LED move hints, ambient "attract" mode.
- See [`app/README.md`](../app/README.md).

---

## Milestone checklist (top level)

- [ ] **M0** mechanics proven (Phase 0)
- [ ] **M1** hangable manual board (Phase 1)
- [ ] **M2** self-tracking powered board (Phase 2)
- [ ] **M3** plays against you (Phase 3)
- [ ] **M4** app-controlled (Phase 4)

---

## Decisions to lock (owner: you)

These gate the build. See discussion in [`DESIGN.md` §8](DESIGN.md#8-open-design-questions).

| # | Decision | Options | Status |
|---|----------|---------|--------|
| D1 | Board size | 45 / 55 / 60 mm squares | ⬜ open (default 45) |
| D2 | Piece style | flat silhouette / 3-D relief | ⬜ open (default flat) |
| D3 | Finish | two-tone print / paint / veneer | ⬜ open |
| D4 | Rotate policy | every move / button / 2-player only | ⬜ open |
| D5 | Brain location | phone / Pi / ESP32 | ⬜ open |
| D6 | Auto-mover in scope + path | never / later Path B (recline) / Path C (vertical) | ⬜ open (default: later, Path B) — see [DESIGN §6](DESIGN.md#6-phase-3--the-board-plays-you-auto-mover-future-scope) |

When you pick, note it here and I'll propagate the parameters and parts.

---

## What exists in this repo right now

- ✅ **Rules engine** — full legal move gen, check/mate/stalemate, castling,
  en passant, promotion, SAN, draws. Verified with perft (20 / 400 / 8902).
- ✅ **AI opponent** — negamax + alpha-beta + piece-square eval (Phase 3 brain).
- ✅ **Parametric hardware** — pieces, gravity gimbal, board panel, frame,
  rotation hub, drive pulley; `Makefile` renders all STLs.
- ✅ **Docs** — this roadmap, the design, electronics plan, BOM, build guide.
- ⬜ Everything physical (that's the fun part — over to Phase 0).
