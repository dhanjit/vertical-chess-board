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
Prove the ideas cheaply before committing to a full board. **This is the phase
that turns modelled numbers into measured ones.** Nothing in this repo has been
printed — see [What exists in this repo right
now](#what-exists-in-this-repo-right-now) — so every figure quoted below is
still a prediction.

- [ ] Print one **gravity gimbal** pair (`make gimbal` → the Ø11.5 hub puck and
      the Ø6 press cap), buy one **Ø3 × 16 mm steel dowel pin** and one **Ø8 × 3
      neodymium disc**, and print one **pawn**
      (`openscad -D 'PART="pawn"' -o pawn.stl pieces.scad`, or `make pieces` for
      all six). Confirm the piece **self-rights** smoothly on the dowel and the
      magnet **holds on steel**.
- [ ] *(Optional)* Print one **board test tile** (`make board_test`), glue a
      steel offcut on its face, and confirm a magnet slides + holds nicely.
      (Phase-2 lookahead: a hall sensor in the rear bore trips under a piece —
      no electronics needed here.)
- [ ] Tune `axle_fit` and the **silicone damping grease** until the swing is
      crisp — it should settle in a second or two without ringing. Note there is
      **no weight pocket to tune any more**: bottom-heaviness is shaped into the
      body (**D10**), so nothing is glued in and a cheap PETG test print hangs
      the same as the final resin part.
- [ ] **Measure where a piece actually parks — the ten-flip test. This is the
      one test the whole design rests on.** Flip the scrap ten times and note
      the *worst* lean off vertical each time.
      Why it matters: a hanging piece parks where bore friction cancels gravity,
      at `sin(lean) = μ · bore_radius / lever`. Geometry gives us
      `bore_radius = 1.85` and the levers in the table below, and those are
      solid. **μ is not.** Every lean figure in this repo assumes **μ ≈ 0.08**
      for greased steel on plastic — a textbook value, never measured on this
      hardware. Lean scales **linearly** with μ, so if the real figure is double
      the assumption, so is every number in the table. One hub plus one pawn
      settles it, and it is the cheapest test available.
      - **Pass:** worst lean stays under ~2.2°, the working limit the set was
        designed against. The rook is the piece to watch — modelled at 1.81° it
        has the least margin of the six.
      - **Worse than ~2.2°?** μ is the only free variable left, so go at
        friction first: more grease, then a smoother bore (ream/polish it).
        Failing that, lengthen the lever by dropping `hollow_wall` from 0.9 to
        0.7 mm — a deeper cavity puts the centre of mass further below the
        pivot, at the cost of a wall thinner than a 0.4 mm nozzle likes.
      - **Rings for ages before settling?** → thicker grease, not less of it.
        Viscous drag damps the swing without adding the *static* friction that
        causes the parking error in the first place.
- [ ] Check the three things the models cannot tell us: **print orientation and
      overhangs** for the silhouettes, and whether an Ø8 magnet really holds the
      **heaviest piece** (the bishop, ~4.5 g, hanging 11 mm proud of the wall).
- **Exit criteria:** a piece sticks to a vertical steel scrap; it stays upright
  when you rotate the scrap by hand; it still looks centred in its square after
  the flip; **and the ten-flip worst-case lean has been written down** and comes
  in at or under the ~2.2° working limit. Record the measured μ back into
  `hardware/common.scad` either way — a *disproved* assumption logged is still a
  pass for this phase.

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
[`AUTO_MOVER_DESIGN.md`](AUTO_MOVER_DESIGN.md) (how). D7–D11 came out of the
hardware models and their reasoning is written into the code comments in
[`hardware/common.scad`](../hardware/common.scad),
[`pieces.scad`](../hardware/pieces.scad) and
[`gravity_gimbal.scad`](../hardware/gravity_gimbal.scad).

| # | Decision | Options | Status |
|---|----------|---------|--------|
| D1 | Board size | 45 / 55 / 60 mm squares | ✅ **locked: 55 mm** (`square_size = 55`) — settled on physical grounds, not taste. The hub puck is a fixed Ø11.5 disc sitting *behind* the piece, and the piece has to hide it or every piece wears a visible grey collar. The mechanical parts do not scale with the square — only the **artwork** does — so growing the square grows the taper until it outruns the puck. At 45 mm the narrowest piece covered only a Ø9.8 waist and the puck showed. 55 mm is the **smallest** square at which the natural waist reaches Ø12.0 and covers Ø11.5 with nothing added: no skirt, no collar, no fake boss — 0.5 mm to spare. Cost: the panel grows from ~410 mm to **~490 mm square** (8 × 55 + 2 × 25 margin). |
| D2 | Piece style | flat silhouette / 3-D relief | ✅ **locked: flat silhouette, minimal** — exterior detailing is explicitly not a requirement; keep pieces as clean minimal silhouettes. The rules the silhouettes are drawn to are **D11**. |
| D3 | Finish | two-tone print / paint / veneer | ⬜ open |
| D4 | Rotate policy | every move / button / 2-player only | ⬜ open |
| D5 | Brain location | phone / Pi / ESP32 | ⬜ open |
| D6 | Auto-mover in scope + route | never / **EPM matrix** / reclined gantry (~45–63°) | ⬜ open — **aspirational, out of initial scope**; if ever pursued, the researched route is the EPM matrix (prototype-gated), reclined-gantry fallback — why in [AUTO_MOVER_ANALYSIS.md](AUTO_MOVER_ANALYSIS.md), how in [AUTO_MOVER_DESIGN.md](AUTO_MOVER_DESIGN.md) |
| D7 | Piece attachment | buried washers (grip through 2.5 mm wall) / **steel-sheet face (direct magnet contact)** | ✅ **locked: steel-sheet face** — the attachment every commercial magnetic wall set uses, so the grip is proven rather than hoped-for. Felt disc on the hub sets the glide; Phase-2 sensing reads through a small laser-cut hole per square. The washer design is retired. |
| D8 | Piece pivot placement | above centre (fast settle) / **at the silhouette's centre** | ✅ **locked: at the centre** (`pivot_frac = 0.50`) — a piece must read *centred in its square*, and it must stay centred through a board flip. Pivoting on the bounding-box centre means a settling error merely **rotates the piece in place** instead of swinging it sideways, so the sideways offset is zero at any angle. The cost is pendulum lever: putting the pivot at the middle brings the centre of mass close to it (`d` = 4.7–8.7 mm across the set), and a short lever means a bigger settling error unless friction drops to match. That is exactly what D9 pays for. Placement also bounds how large the artwork can go — a piece hangs `pivot_frac × height` below the axle and the axle is the square's centre, so `piece_scale` ≤ 27.5 / (0.5 × 42) = 1.310; the set runs at **1.222**, leaving the king 1.84 mm of headroom inside its square. |
| D9 | Piece pivot hardware | printed post / **Ø3 steel dowel** / ball bearing | ✅ **locked: a bought Ø3 × 16 mm steel dowel pin + silicone damping grease** (`axle_dia = 3`). Friction sets how straight a piece parks: `sin(lean) = μ · bore_radius / lever`. Ground steel roughly halves μ against a printed post, and grease roughly halves it again. **Ø3 is stronger than the Ø4 it replaced, not weaker** — what changed is that the axle is now *bought steel* rather than a *printed post*: a Ø4 printed post carried only **1.29×** margin against a 20 N sideways knock (it snaps at the layer-line root), while a Ø3 steel dowel carries **3.0×**. Shrinking it also cuts `μ · r`, the entire numerator above — Ø4 → Ø3 is **~19 % less lean for free**. It bottoms out on the magnet (`axle_embed = 5`) so there is no thin printed web, and 11 mm stands proud against a 6 mm piece + 3.5 mm cap grip, leaving **1.5 mm of deliberate axial float** so tolerance stacking cannot clamp the piece and stall it. A ball bearing was **rejected**: it needs the pivot boss at Ø9 (wider than the pawn's head) and, being nearly frictionless, leaves nothing to damp the swing — pieces would ring for minutes after each flip. Grease is the right answer because *viscous* drag damps without adding *static* friction. |
| D10 | Bottom-heaviness | ballast slug in a pocket / **shaped into the body** | ✅ **locked: shaped in** — the piece is solid below the pivot and **hollow above it** (`hollow_wall = 0.9`, `piece_thk = 6`). There is **no weight pocket and no lead** anywhere in the set. The reason is material independence: with a glued slug the lever depends on the *ratio* of slug density to body density, so tuning done in one material does not transfer and a cheap PETG test print would prove nothing about the final resin part. With one material, **density cancels out** of the settling equation entirely and the test print hangs identically to the real thing. It is also one fewer part and no glue step. Two constraints come with it: the cavity must be **modelled, not left to the slicer** (a slicer's "hollow" tool removes material evenly and produces no top-to-bottom gradient at all — exactly the wrong thing), and every cavity needs a `drain_dia = 2` **drain hole through the back face** or resin is trapped. Verify by counting shells in the exported STL: a cavity the drain missed shows up as a second shell. |
| D11 | Piece design language | free-form per piece / **one shared rule set ("Tapered Monolith")** | ✅ **locked: one rule set, applied to all six.** Every piece is a single straight-sided taper standing on the same foot flare (same `FOOT_H`, same `FLARE`, one 1:4 slope = 14.04° off vertical). The taper runs up, stops, and **one** terminal event sits on top of it; that event is always narrower than the foot, so the foot is the widest point of every piece and the flare is said exactly once. Rank reads twice over — as height (26/30/32/35/38/42 nominal) and as how far the taper ran before the event began. Crowns are counted with a shared vocabulary (one stroke width, one slot, one tip, one pitch) rather than drawn by hand, and the whole set uses one convex corner radius and one concave fillet. **The knight's head is the single deliberate exception** and it is a priced trade, not an oversight — see the honesty note below. |

When a decision is locked, record it here and propagate the values into
`hardware/common.scad` and the affected parts/docs.

### The set as modelled (55 mm squares)

These are the numbers the docs should quote. **They are measured off the
exported meshes, not off an object — nothing has been printed.** Mass assumes
resin; it is listed for the magnet-grip check only and has **no effect on lean**
(mass cancels out of the settling equation).

| Piece | Height | Width | Aspect | Lever `d` | Lean @ μ=0.08 | Mass (resin) |
|-------|-------:|------:|-------:|----------:|--------------:|-------------:|
| Pawn   | 31.77 | 20.74 | 0.653 | 5.71 | 1.49° | 2.24 g |
| Rook   | 36.66 | 24.61 | 0.671 | 4.68 | **1.81°** | 3.43 g |
| Knight | 39.10 | 26.44 | 0.676 | 6.05 | 1.40° | 3.75 g |
| Bishop | 42.77 | 29.98 | 0.701 | 7.29 | 1.16° | 4.52 g |
| Queen  | 46.44 | 25.34 | 0.546 | 5.72 | 1.48° | 4.23 g |
| King   | 51.32 | 25.59 | 0.499 | 8.68 | 0.98° | 4.24 g |

All six verified in software: single shell (every cavity drained), pivot exactly
centred, balanced about x, and inside the 55 mm square. **Lean scales linearly
with μ** — the ten-flip test in Phase 0 is what turns this column into fact.

---

## What exists in this repo right now

**Short version: designed and verified in software. Nothing built.**

- ✅ **Rules engine** — full legal move gen, check/mate/stalemate, castling,
  en passant, promotion, SAN, draws. Verified with perft (20 / 400 / 8902).
- ✅ **AI opponent** — negamax + alpha-beta + piece-square eval (the built-in
  fallback opponent; the Phase-3 default is Stockfish, see
  [OPEN_SOURCE.md](OPEN_SOURCE.md)).
- ✅ **Parametric hardware** — pieces, gravity gimbal, board panel, frame,
  rotation hub, drive pulley; `Makefile` renders all STLs. All six pieces and
  the gimbal render clean at 55 mm squares, each piece exports as a single
  shell, and the table above is measured off those meshes.
- ✅ **Docs** — this roadmap, the design, electronics plan, BOM, build guide.
- ⬜ **Everything physical.** Nothing has been printed, nothing bought, nothing
  assembled, nothing hung on a wall. That's the fun part — over to Phase 0.

### What is assumed rather than known

Stated plainly so no one mistakes a model for a measurement:

- **Every dimension and every lean figure in these docs is a model.** They come
  from geometry and from exported meshes, never from a caliper on a real part.
- **μ = 0.08 is a textbook value, not a measurement.** Greased steel on plastic,
  never checked on this hardware. It is the single assumption the whole piece
  design rests on, and lean scales linearly with it. The **ten-flip test in
  Phase 0** validates or kills it, and it costs one hub and one pawn.
- **The rook has the least margin** — 1.81° modelled against a 2.2° working
  limit. It is the piece that breaks first if real friction runs high.
- **The knight is fragile to edits.** Its head is the set's one deliberate
  departure from the D11 language (free angles), and its balance is **tuned**
  via a single constant, `KDX`, rather than being structural. Any edit to the
  head polygon still renders perfectly and still *looks* right — and then the
  piece hangs permanently rotated. Re-measure the centre of mass and re-solve
  `KDX` if you touch it. Flagged in `pieces.scad` at both the constant and the
  knight branch.
- **Unchecked entirely:** print orientation, overhangs, and whether an Ø8 magnet
  actually holds the heaviest piece (the bishop, ~4.5 g, hanging 11 mm proud of
  the wall). All three are Phase-0 questions.
