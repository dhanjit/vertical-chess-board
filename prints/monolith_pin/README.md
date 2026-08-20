# monolith + pin — the austere set

The **`monolith`** artwork on the default **`pin`** pivot. Monolith is an
invented design language rather than the familiar chess vocabulary: every piece
is one straight-sided 1:4 taper on a shared foot, and rank reads as height plus
a single terminal event (dome, crenel, cleft, coronet…). Coherent and quiet on
a wall — but a guest has to learn it. The pieces are markedly smaller than the
familiar set (king 51.3 × 25.6 vs 52 × 42), which also means shorter pendulum
levers and a little more lean everywhere.

The pivot hardware is identical to [`../familiar_pin/`](../familiar_pin/):
magnet in a printed hub puck on the board, piece turning on a bought Ø3 steel
dowel, retained by a printed press cap — **3 printed parts per piece**.

## Files in this folder

| File | What it is | For a full set (2 colors) |
|---|---|---|
| `piece_pawn.stl` | pawn, 31.8 × 20.7 × 6 mm | print 16 (8 per color) |
| `piece_rook.stl` | rook, 36.7 × 24.6 | print 4 |
| `piece_knight.stl` | knight, 39.1 × 26.4 | print 4 |
| `piece_bishop.stl` | bishop, 42.8 × 30.0 | print 4 |
| `piece_queen.stl` | queen, 46.4 × 25.3 | print 2 |
| `piece_king.stl` | king, 51.3 × 25.6 | print 2 |
| `gimbal_pin.stl` | **hub puck + press cap** test pair | print 32 pairs (duplicate in the slicer) |

## Also buy (full set)

Same shopping list as `familiar_pin`:

| Item | Per piece | Per set |
|---|---:|---:|
| Ø8 × 3 mm neodymium disc magnet (N52) | 1 | 32 |
| Ø3 × 16 mm steel dowel pin (h8, ground) | 1 | 32 |
| Felt disc, ~Ø11 mm self-adhesive | 1 | 32 |
| Silicone damping grease | — | 1 small tube |

## Print & assemble

Identical to [`../familiar_pin/README.md`](../familiar_pin/README.md) — flat,
face down, no supports; PETG test print is valid; resin needs the back-face
drains open and one shell per piece; assembly is magnet → dowel → felt →
grease → piece → cap, with the 1.5 mm axial float left alone.

One thing specific to this artwork: the monolith waist is the **narrowest
thing that ever has to hide the Ø11.5 hub puck — Ø12.0, so 0.5 mm to spare**.
It is the style that set the 55 mm square size; print one piece and check the
puck actually disappears behind it before committing to a set.

## Before printing 32 of anything: the ten-flip test

One hub pair + one pawn, ten flips, worst lean ≤ ~2.2°. The rook is the canary
at a modelled **1.81°** — noticeably less margin than the familiar set's 1.44°,
because crenellation-over-a-short-taper is the worst lever in the style. If
real μ runs ~20% over the assumed 0.08, this set's rook is at the limit while
the familiar set still clears it. Fixes, in order: more/thicker grease, polish
the bore, `hollow_wall` 0.9 → 0.7. Full procedure:
[`docs/BUILD_GUIDE.md`](../../docs/BUILD_GUIDE.md).

## Modelled numbers (μ = 0.08 — nothing printed yet)

| Piece | H × W (mm) | Lean | Mass (resin) |
|---|---|---:|---:|
| Pawn | 31.8 × 20.7 | 1.49° | 2.24 g |
| Rook | 36.7 × 24.6 | **1.81°** | 3.43 g |
| Knight | 39.1 × 26.4 | 1.40° | 3.75 g |
| Bishop | 42.8 × 30.0 | 1.16° | 4.52 g |
| Queen | 46.4 × 25.3 | 1.48° | 4.23 g |
| King | 51.3 × 25.6 | 0.98° | 4.24 g |

Where this set is *safer* than familiar: sweep clearance. Small silhouettes
swing well inside their squares — worst legal neighbour pairing leaves
**11.67 mm** of margin against familiar's 1.25 mm (see the sweep table in
[`hardware/README.md`](../../hardware/README.md)). If Phase 0 shows pieces
lagging out of step during a flip, this is the set that shrugs it off.
