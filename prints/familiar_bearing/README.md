# familiar + bearing — parks perfectly, rings freely

The **`familiar`** artwork on the **`bearing`** pivot: the `pin` architecture
with the piece's greased sliding bore replaced by a bought **MR63ZZ ball
bearing** (Ø3 × Ø6 × 2.5 mm) pressed into the piece's back face. Hub puck,
dowel, Ø8 magnet, felt and press cap are **identical to `familiar_pin`** — the
only change is what the piece turns on.

**Why it exists:** rolling friction takes μ — the one unmeasured input every
lean figure depends on — out of the parking equation entirely. Every piece
parks within a few hundredths of a degree *whatever* Phase 0 measures. This is
the **fallback architecture if the greased pin's ten-flip test fails**.

> **The open question is ringing, not parking.** On the greased pin, the
> grease is also the damper. A near-frictionless pivot has nothing to stop a
> piece swinging after a board flip except the bearing shields' light factory
> grease — and while a piece swings, this artwork's 1.25 mm worst-pair sweep
> margin does not hold. **Ring-down time is unmeasured and is this variant's
> first Phase-0 question.** If it rings too long: a smear of damping grease
> between piece back and hub face is the tunable retrofit. Full costing:
> [`docs/PIECE_DESIGNS.md`](../../docs/PIECE_DESIGNS.md).

## Files in this folder

| File | What it is | For a full set (2 colors) |
|---|---|---|
| `piece_pawn.stl` … `piece_king.stl` | the six familiar pieces (40.0 → 52.0 mm tall) with a Ø6.1 bearing seat in the back face and a loose Ø5 bore in front — the plate never touches the dowel | 16 / 4 / 4 / 4 / 2 / 2 |
| `gimbal_bearing.stl` | **hub puck + press cap** — the identical pair `familiar_pin` uses | 32 pairs |

## Also buy (full set)

Everything `familiar_pin` buys, **plus the bearings**:

| Item | Per piece | Per set |
|---|---:|---:|
| Ø8 × 3 mm neodymium disc magnet (N52) | 1 | 32 |
| Ø3 × 16 mm steel dowel pin (h8, ground) | 1 | 32 |
| **MR63ZZ bearing, Ø3 × Ø6 × 2.5 (metal shields, not 2RS)** | 1 | 32 |
| Felt disc, ~Ø11 mm self-adhesive | 1 | 32 |

**Do not degrease the bearings** — the factory fill inside the shields is the
only damping this pivot has. No damping grease on the dowel: the bearing's
inner ring rides it as a slip fit.

## Print & assemble

Print settings as [`../familiar_pin/README.md`](../familiar_pin/README.md)
(flat, face down, no supports; one shell per piece in the slicer). Assembly is
the `pin` sequence with one inserted step:

1. Magnet into hub, dowel into hub (bottoms on the magnet), felt over the
   magnet — exactly as `familiar_pin`.
2. **Press the MR63ZZ into the piece's back-face seat**, shields out, flush.
   The seat (`pivot_bearing_seat_fit` in `common.scad`) should grip the outer
   race firmly without splitting — tune on the first print.
3. Slide the piece's bearing onto the dowel (no grease), push the press cap on,
   leave the axial float alone, stick to the sheet.

## Before printing 32 of anything: the flip test, timed

One hub pair + one pawn + **one** bearing. Stick to steel, flip, and **time how
long the pawn swings**. Settles in a second or two → this architecture
graduates from fallback to contender. Rings for tens of seconds → try a smear
of damping grease between piece back and hub face and re-time; that interface
carries near-zero normal force, so it damps viscously without re-adding
parking error. Parking itself should measure ≈0° — if it doesn't, the seat is
pinching the outer race.

## Modelled numbers

Same bodies as `familiar_pin` (H × W and mass per its table). Parking lean:
**≈0° on every piece at any μ** — an order-of-magnitude estimate from rolling
friction (~0.002), not a mesh measurement, and deliberately not quoted to two
decimals anywhere. Add ~0.5 g per piece for the bearing riding at the pivot
(costs settle *time*, not parking *angle*).
