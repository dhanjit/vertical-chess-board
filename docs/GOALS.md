# Goals & Roadmap

**Vision:** a chess board that hangs on the living-room wall like art, plays
vertically, rotates to face whoever's turn it is, keeps its pieces upright by
gravity, and — aspirationally, further out — could play against you and be
controllable from a phone.

This repo is the **single source of truth** for making that real: designs,
printable models, electronics, firmware, the game brain, and the plan.

> **New here?** [`OVERVIEW.md`](OVERVIEW.md) is the one-page summary — what it
> is, why, and the plan at a glance. This doc is the full technical roadmap
> that summary expands on.

> **First-time builder?** Read [`PROJECT_REVIEW.md`](PROJECT_REVIEW.md) — an
> honest review of the idea, a difficulty/risk read of each feature, and a
> **re-scoped staged plan (A–E)** that maps onto the phases below. Bengaluru
> sourcing is in [`SOURCING_BANGALORE.md`](SOURCING_BANGALORE.md). The phases
> below are the full technical roadmap; the review tells you which parts a
> beginner should actually take on first (short version: nail the **manual
> board**, treat electronics as later, optional projects).
>
> **Reuse before you build:** the electronic phases mostly already exist as
> open-source projects (sensing, opponent engine, self-moving gantry, online
> play). See [`OPEN_SOURCE.md`](OPEN_SOURCE.md) — fork **Open-Chess** for
> sensing, **Imperium**+**FluidNC** for the auto-mover, run **Stockfish** for
> the opponent. Only our mechanical design is genuinely new.

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
- [ ] *(Optional)* Print one **board test tile** (`make board_test`), glue a
      steel offcut on its face, and confirm a magnet slides + holds nicely.
      (Phase-2 lookahead: a hall sensor in the rear bore trips under a piece —
      no electronics needed here.)
- [ ] Tune `axle_fit`, `magnet_dia`, weight pocket until swing is crisp.
- **Exit criteria:** a piece sticks to a vertical steel scrap and stays upright
  when you rotate the scrap by hand.

### Phase 1 — Manual magnetic wall board (no electronics) ⬜
A complete, beautiful board you can hang and play today.
- [ ] Full **32-piece set** (2 finishes) + spares.
- [ ] Full **board panel** (whole or quartered) + labels, faced with the
      painted **steel sheet**.
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

### Phase 3 — The board plays you (auto-mover) — 🌠 aspirational ⬜
> **Not a current focus.** Parked as a *someday* goal (see the scope note in
> [`OVERVIEW.md`](OVERVIEW.md)). Captured here and in the AUTO_MOVER docs so it
> can be picked up deliberately later — it does **not** drive near-term work,
> and nothing in Phases 0–1 depends on it.
- [ ] Auto-mover per decision **D6** (below): if pursued, **EPM matrix** (the
      switchable magnets hold *and* move); fallback **reclined gantry** —
      how-to in [AUTO_MOVER_DESIGN.md](AUTO_MOVER_DESIGN.md), why in
      [AUTO_MOVER_ANALYSIS.md](AUTO_MOVER_ANALYSIS.md).
- [ ] Opponent: **Stockfish** at selectable strength (see
      [OPEN_SOURCE.md](OPEN_SOURCE.md)); [`ai.js`](../software/engine/ai.js)
      is the built-in zero-dependency fallback.
- [ ] Captures routed to an off-board "graveyard" lane.
- **Exit criteria:** pick a difficulty, the board makes its own legal moves,
  including captures and castling.

### Phase 4 — App & polish — 🌠 aspirational ⬜
- [ ] Phone **app** (BLE/Wi-Fi): difficulty, hints, takeback, clock, PGN export.
- [ ] Online play / puzzles / "play a friend remotely, board mirrors it."
- [ ] Sound, LED move hints, ambient "attract" mode.
- See [`app/README.md`](../app/README.md).

---

## Milestone checklist (top level)

- [ ] **M0** mechanics proven (Phase 0)
- [ ] **M1** hangable manual board (Phase 1)
- [ ] **M2** self-tracking powered board (Phase 2)
- [ ] **M3** plays against you (Phase 3) — 🌠 aspirational
- [ ] **M4** app-controlled (Phase 4) — 🌠 aspirational

---

## Decisions to lock

These gate the build. D1–D5 are discussed in
[`DESIGN.md` §8](DESIGN.md#8-open-design-questions); D6 (auto-mover) in
[`AUTO_MOVER_ANALYSIS.md`](AUTO_MOVER_ANALYSIS.md) (why) and
[`AUTO_MOVER_DESIGN.md`](AUTO_MOVER_DESIGN.md) (how).

| # | Decision | Options | Status |
|---|----------|---------|--------|
| D1 | Board size | 45 / 55 / 60 mm squares | ⬜ open (default 45) |
| D2 | Piece style | flat silhouette / 3-D relief | ✅ **locked: flat silhouette, minimal** — exterior detailing is explicitly not a requirement; keep pieces as clean minimal silhouettes |
| D3 | Finish | two-tone print / paint / veneer | ⬜ open |
| D4 | Rotate policy | every move / button / 2-player only | ⬜ open |
| D5 | Brain location | phone / Pi / ESP32 | ⬜ open |
| D6 | Auto-mover in scope + route | never / **EPM matrix** / reclined gantry (~45–63°) | ⬜ open — **aspirational, out of initial scope**; if ever pursued, the researched route is the EPM matrix (prototype-gated), reclined-gantry fallback — why in [AUTO_MOVER_ANALYSIS.md](AUTO_MOVER_ANALYSIS.md), how in [AUTO_MOVER_DESIGN.md](AUTO_MOVER_DESIGN.md) |
| D7 | Piece attachment | buried washers (grip through 2.5 mm wall) / **steel-sheet face (direct magnet contact)** | ✅ **locked: steel-sheet face** — the attachment every commercial magnetic wall set uses, so the grip is proven rather than hoped-for. Felt disc on the hub sets the glide; Phase-2 sensing reads through a small laser-cut hole per square. The washer design is retired. |

When a decision is locked, record it here and propagate the values into
`hardware/common.scad` and the affected parts/docs.

---

## What exists in this repo right now

- ✅ **Rules engine** — full legal move gen, check/mate/stalemate, castling,
  en passant, promotion, SAN, draws. Verified with perft (20 / 400 / 8902).
- ✅ **AI opponent** — negamax + alpha-beta + piece-square eval (the built-in
  fallback opponent; the Phase-3 default is Stockfish, see
  [OPEN_SOURCE.md](OPEN_SOURCE.md)).
- ✅ **Parametric hardware** — pieces, gravity gimbal, board panel, frame,
  rotation hub, drive pulley; `Makefile` renders all STLs.
- ✅ **Docs** — this roadmap, the design, electronics plan, BOM, build guide.
- ⬜ Everything physical (that's the fun part — over to Phase 0).
