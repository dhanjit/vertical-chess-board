# monolith + magnet — ruled out by the modelling; kept for comparison

> ⚠ **Do not print a set from this folder.** This is the one combination of
> the four that **busts the 2.2° working limit on paper**: rook **2.89°**,
> pawn **2.61°**, queen **2.27°**, with the knight a hair under at 2.19°
> (μ = 0.08). The monolith pieces are small, so their pendulum levers are
> short, and the magnet architecture's penalty — a bigger bore plus magnet and
> disc mass riding at the pivot — is close to a fixed subtraction from the
> lever, which hurts a short lever most. The two variant axes are independent
> in the code; **they are not independent in the outcome.**

The folder exists because the repo keeps competing approaches side by side and
compares them on numbers instead of arguing (D12). It earns its place two ways:

- **Honest comparison** — print one pawn from here next to one from another
  folder and *see* the difference the tables claim.
- **A comeback path** — every lean figure scales linearly with μ. The 0.08
  assumption has never been measured on this hardware; if the Phase-0 ten-flip
  test measures real friction at, say, μ ≈ 0.06, this combination's rook drops
  to ~2.17° and it re-enters the running. The numbers rule it out; a
  measurement could rule it back in.

## Files in this folder

| File | What it is |
|---|---|
| `piece_pawn.stl` … `piece_king.stl` | the six monolith pieces with the magnet-pivot bore + Ø9.6 front disc seat (31.8 → 51.3 mm tall) |
| `gimbal_magnet.stl` | the ~2 g **pivot test coupon** (bore + disc seat, nothing else) |

## If printing for comparison

Hardware per piece: one **Ø4 × 5 magnet** (drops into the bore from the back,
clearance fit — the piece turns on it) and one **Ø9 × 0.8 steel disc** (sets
onto the magnet's front pole into the face recess, no glue). Grease the bore.
Print flat, face down, no supports; in resin keep the back-face drain open and
check each piece slices as one shell.

Everything else — the coupon test for this architecture's two unproven claims,
the ten-flip procedure, print settings — is in
[`../familiar_magnet/README.md`](../familiar_magnet/README.md) and
[`docs/BUILD_GUIDE.md`](../../docs/BUILD_GUIDE.md).

## Modelled numbers (μ = 0.08, bore friction only — the reason for the banner)

| Piece | H × W (mm) | Lean |
|---|---|---:|
| Pawn | 31.8 × 20.7 | **2.61°** |
| Rook | 36.7 × 24.6 | **2.89°** |
| Knight | 39.1 × 26.4 | 2.19° |
| Bishop | 42.8 × 30.0 | 1.75° |
| Queen | 46.4 × 25.3 | **2.27°** |
| King | 51.3 × 25.6 | 1.49° |

**Bold = past the 2.2° working limit.** Full side-by-side of all six
combinations: [`docs/PIECE_DESIGNS.md`](../../docs/PIECE_DESIGNS.md).
