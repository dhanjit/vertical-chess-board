# familiar + pin — the default combination

The **`familiar`** artwork (ball-and-collar pawn, crenellated rook, horse
knight, cleft mitre bishop, coronet queen, cross king — nobody has to be taught
what any piece is) on the **`pin`** pivot (the magnet lives in a printed hub
puck on the board; the piece turns on a bought Ø3 steel dowel). This is the
repo's documented default: the look asked for, and the only pivot architecture
with no unproven claims in it. It pays for that with parts count — **3 printed
parts per piece** plus two bought ones.

## Files in this folder

| File | What it is | For a full set (2 colors) |
|---|---|---|
| `piece_pawn.stl` | pawn, 40.0 × 30.0 × 6 mm | print 16 (8 per color) |
| `piece_rook.stl` | rook, 43.0 × 38.0 | print 4 |
| `piece_knight.stl` | knight, 44.5 × 40.5 | print 4 |
| `piece_bishop.stl` | bishop, 47.5 × 36.0 | print 4 |
| `piece_queen.stl` | queen, 50.0 × 41.8 | print 2 |
| `piece_king.stl` | king, 52.0 × 42.0 | print 2 |
| `gimbal_pin.stl` | **hub puck + press cap**, side by side as one test-pair tray | print 32 pairs (duplicate in the slicer) |

Print a few spares of everything — the pieces are cheap and the knights are
the fiddliest to reprint later.

## Also buy (full set)

| Item | Per piece | Per set |
|---|---:|---:|
| Ø8 × 3 mm neodymium disc magnet (N52) | 1 | 32 |
| Ø3 × 16 mm steel dowel pin (h8, ground) | 1 | 32 |
| Felt disc, ~Ø11 mm self-adhesive | 1 | 32 |
| Silicone damping grease | — | 1 small tube |

Board-side materials (steel sheet, bearing, cleat) are in
[`../common/README.md`](../common/README.md); the full priced list is
[`docs/BOM.md`](../../docs/BOM.md).

## Print

- Pieces and hub/cap print **flat, silhouette face down — no supports**.
- **Test in cheap PETG first.** The test is valid here: bottom-heaviness is
  shaped into the body (no ballast), so density cancels and a PETG piece hangs
  exactly like the final resin one.
- **Resin:** every piece has a drain hole through its **back** face — do not
  orient or hollow so it seals. Each piece must slice as **one shell**; a
  second shell means a sealed cavity that will trap resin.
- Two body colors for White/Black; the finish decision (two-tone print vs
  paint vs veneer) is still open — D3 in [`docs/GOALS.md`](../../docs/GOALS.md).
- Fit tolerances (`axle_fit`, `magnet_fit`, `axle_press_fit`, `cap_grip_fit`)
  live in [`hardware/common.scad`](../../hardware/common.scad) — tune after the
  Phase-0 print if your printer runs tight or loose.

## Assemble (per piece)

1. Press the **Ø8 × 3 magnet** into the cavity in the hub puck's back, flush.
2. Press the **Ø3 × 16 dowel** into the bore in the puck's front until it
   bottoms out on the magnet (the chamfered mouth starts it square; a drop of
   CA if your print runs loose).
3. Stick the **felt disc** over the magnet face — it protects the board's
   paint and sets the glide.
4. Light smear of **silicone damping grease** on the dowel.
5. Hang the **piece** on the dowel through its bore.
6. Push the **press cap** onto the dowel tip until the piece is retained but
   loose. **Do not seat it hard** — the 1.5 mm of axial float is deliberate;
   clamping the piece between cap and hub stalls the rotation.
7. Stick the whole stack to the steel sheet. It slides to any square and
   lifts off as one unit.

## Before printing 32 of anything: the ten-flip test

Print **one hub pair + one pawn**, assemble, stick to any steel scrap, and flip
the scrap ten times. Note the worst lean off vertical.

- **Pass:** worst lean ≤ ~2.2°. The rook is this combination's canary at a
  modelled **1.44°** — the least margin in the set.
- **Worse?** Friction is the only free variable: more/thicker grease, then
  polish the bore, then (last resort) drop `hollow_wall` 0.9 → 0.7 mm in
  `common.scad` to lengthen the pendulum lever.
- **Rings before settling?** Thicker grease, not less — viscous drag damps
  without adding the static friction that causes parking error.

Record the measured μ back into `common.scad` either way. Full procedure:
[`docs/BUILD_GUIDE.md`](../../docs/BUILD_GUIDE.md).

## Modelled numbers (μ = 0.08 — nothing printed yet)

| Piece | H × W (mm) | Lean | Mass (resin) |
|---|---|---:|---:|
| Pawn | 40.0 × 30.0 | 1.16° | 3.79 g |
| Rook | 43.0 × 38.0 | **1.44°** | 6.11 g |
| Knight | 44.5 × 40.5 | 1.13° | 6.49 g |
| Bishop | 47.5 × 36.0 | 0.94° | 5.64 g |
| Queen | 50.0 × 41.8 | 1.12° | 7.17 g |
| King | 52.0 × 42.0 | 0.99° | 7.49 g |

One caveat specific to this artwork: the pieces fill their squares, so a piece
that *lags* during a board flip while its neighbour hangs upright has only
**1.25 mm** of clearance in the worst legal pairing (king next to queen). See
the sweep analysis in [`hardware/README.md`](../../hardware/README.md) — it is
the one place the artwork choice is also a mechanical choice.
