# familiar + magnet — same artwork, minimal parts

The **`familiar`** artwork on the **`magnet`** pivot: no hub, no dowel, no cap.
A **Ø4 × 5 magnet sits in the piece's own bore** and the piece turns *on the
magnet*; a **Ø9 × 0.8 steel disc**, held by that same magnet with no glue,
recesses into the piece's front face and stops it pulling off. **1 printed part
per piece** instead of 3 — over a full set that is 64 fewer printed parts and
32 fewer dowels — bought with ~0.4–0.6° more lean and a visible steel disc on
every piece's face.

> **Two claims of this architecture are unproven, and neither is inside the
> lean numbers below:** (1) that the Ø9 disc actually stays put on a Ø4 magnet
> through a board flip, and (2) that the piece still turns freely once the disc
> clamps its whole back face against the steel sheet — the lean figures model
> *bore* friction only, so they are **optimistic** here. `gimbal_magnet.stl` in
> this folder is the ~2 g coupon that settles both. **Print it first, before
> any piece.**

## Files in this folder

| File | What it is | For a full set (2 colors) |
|---|---|---|
| `piece_pawn.stl` | pawn, 40.0 × 30.0 × 6 mm | print 16 (8 per color) |
| `piece_rook.stl` | rook, 43.0 × 38.0 | print 4 |
| `piece_knight.stl` | knight, 44.5 × 40.5 | print 4 |
| `piece_bishop.stl` | bishop, 47.5 × 36.0 | print 4 |
| `piece_queen.stl` | queen, 50.0 × 41.8 | print 2 |
| `piece_king.stl` | king, 52.0 × 42.0 | print 2 |
| `gimbal_magnet.stl` | **pivot test coupon** — Ø16 disc carrying just the bore + disc seat | print 1, first |

There are no other printed parts in this architecture.

## Also buy (full set)

| Item | Per piece | Per set |
|---|---:|---:|
| Ø4 × 5 mm neodymium disc magnet | 1 | 32 |
| Ø9 × 0.8 mm steel disc (shim) | 1 | 32 |
| Silicone damping grease | — | 1 small tube |

Board-side materials: [`../common/README.md`](../common/README.md); priced
list: [`docs/BOM.md`](../../docs/BOM.md).

## Print

- Pieces print **flat, silhouette face down — no supports**. The Ø9.6 disc
  seat is a 1 mm recess in the front face; face-down it prints cleanly.
- **Test in cheap PETG first** — valid because bottom-heaviness is shaped in,
  so density cancels and a PETG piece hangs like the resin one.
- **Resin:** the drain hole through each piece's **back** face must stay open;
  every piece must slice as **one shell**.
- Two body colors for White/Black; finish decision D3 still open.

## Assemble (per piece)

1. Drop the **Ø4 × 5 magnet** into the bore from the **back**, flush with the
   back face. It is a clearance fit on purpose — the piece must turn on it.
2. Light smear of **silicone damping grease** in the bore.
3. Set the **Ø9 steel disc** onto the magnet's front pole through the front
   face; it self-seats in the recess, 0.2 mm below flush. No glue.
4. Stick the piece to the steel sheet. The magnet grips the sheet directly;
   the disc is the only thing keeping the piece on the magnet.

## Before printing 32 of anything

1. **The coupon test:** press a magnet into `gimbal_magnet.stl`, add the disc,
   stick it to steel, flip the sheet, and try to spin it with a fingertip. If
   the disc walks off, or the coupon won't turn because its back face is
   clamped to the sheet, this architecture is answered for 2 g of plastic.
2. **The ten-flip test:** one pawn, ten flips, worst lean ≤ ~2.2°. The rook is
   the canary at a modelled **2.09°** — the closest-to-limit piece of any
   viable combination, so this variant has the least room for μ running high.

Full procedure: [`docs/BUILD_GUIDE.md`](../../docs/BUILD_GUIDE.md).

## Modelled numbers (μ = 0.08, bore friction only — nothing printed yet)

| Piece | H × W (mm) | Lean | Body mass (resin)* |
|---|---|---:|---:|
| Pawn | 40.0 × 30.0 | 1.80° | 3.79 g |
| Rook | 43.0 × 38.0 | **2.09°** | 6.11 g |
| Knight | 44.5 × 40.5 | 1.62° | 6.49 g |
| Bishop | 47.5 × 36.0 | 1.37° | 5.64 g |
| Queen | 50.0 × 41.8 | 1.60° | 7.17 g |
| King | 52.0 × 42.0 | 1.40° | 7.49 g |

\* Mass figures are the repo's per-style figures (measured off the `pin`-variant
meshes); this variant's bodies differ only by the larger bore and seat. Add
~0.9 g per piece for the magnet (~0.5 g) + steel disc (~0.4 g) riding along. Note the Ø4 magnet is
carrying both the piece **and** the disc — whether it holds the 7.5 g king on a
vertical wall is one of the Phase-0 checks.
