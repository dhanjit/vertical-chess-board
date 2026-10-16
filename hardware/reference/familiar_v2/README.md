# familiar v2 — plain STEP reference pieces

Six flat chess pieces (pawn, rook, knight, bishop, queen, king) in the "online
chess" look, as editable STEP solids.

**Plain on purpose:** no pivot bore, no bearing seat, no magnet pocket, no
hollowing — just the shape. These are **reference artwork, not board-ready
pieces**, and not a selectable `piece_style` (yet). The SCAD pipeline does not
read them.

**Status (2026-10-16): adopted as the base design for the pieces** (decision
D12 in [`docs/GOALS.md`](../../../docs/GOALS.md)). Next it becomes a
`piece_style`; the blockers below still apply. A first bearing prototype (queen)
and its balance numbers are in
[`docs/PIECE_DESIGNS.md`](../../../docs/PIECE_DESIGNS.md#first-bearing-prototype-queen-2026-10-15).

## Where it's from

[Thingiverse thing:7152789](https://www.thingiverse.com/thing:7152789) —
"Pièces d'échecs pour échiquier mural // Chess Pieces for Wall Chessboards",
released as **public domain (CC0 1.0)**. The licence was checked on the listing
on 2026-10-11. The original download is six STL files: Pion, Tour, Cavalier,
Fou, Dame, Roi.

The repo's `familiar` style (v1, [`../../styles/familiar.scad`](../../styles/familiar.scad))
was drawn in this set's style on 2026-08-10 *without* copying it, because the
licence was unknown then and this repo is public. With CC0 confirmed, the
originals themselves can ship — that is what this folder is.

## What was done

1. Took the six original STL files (flat plates, 2 mm thick — two z-levels only,
   so the outline carries every detail).
2. Projected each outline to 2D (OpenSCAD `projection()`).
3. Rebuilt each outline as real CAD geometry in FreeCAD: straight lines plus
   smooth B-spline curves. Real corners (a turn sharper than 15°) and long
   straight segments (over 1.5 mm) break the outline; the faceted arcs between
   are fitted with splines of at most 24 points each, to 0.005 mm tolerance.
4. Extruded back to the original 2 mm thickness, at the original size (not scaled).
5. Re-centred each piece: base on y = 0, centred on x = 0, thickness z = 0 to 2.
6. Renamed to English: Pion → pawn, Tour → rook, Cavalier → knight,
   Fou → bishop, Dame → queen, Roi → king.

Nothing else changed. The bishop's cross cut-out and the knight's eye hole are
part of the original artwork and are kept.

**Checked:** every file re-reads as one valid solid; every outline vertex of the
source lies within 0.005 mm of the rebuilt curves; areas match the source
polygon to within 0.07 % (the residue is the splines restoring the arcs the
source had cut into chords).

## Sizes (mm, width × height × thickness)

| Piece  | Size               |
|--------|--------------------|
| pawn   | 20.2 × 25.7 × 2.0  |
| rook   | 22.8 × 25.1 × 2.0  |
| knight | 27.7 × 26.9 × 2.0  |
| bishop | 27.8 × 28.1 × 2.0  |
| queen  | 31.0 × 28.5 × 2.0  |
| king   | 28.0 × 30.1 × 2.0  |

## Before these can hang on the board

Found when the originals were first measured (2026-08-10), still true of these
files:

- **Scale:** for 55 mm squares, about 1.5–1.75× (the king is the tallest at 30.1 mm).
- **No material at the pivot:** a disc under Ø4 centred on the bishop or knight
  already pokes outside the shape — the centre lands in the bishop's cleft and
  the knight's neck notch. A pivot needs solid material added there first.
- **Slightly off-centre:** the artwork is not exactly mirror-symmetric, by a
  fraction of a millimetre — enough to hang crooked. Mirror one half before
  using a symmetric piece as a pendulum.

See [`docs/PIECE_DESIGNS.md`](../../../docs/PIECE_DESIGNS.md) for how the
`familiar` style solved both.
