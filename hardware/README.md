# Hardware — parametric 3-D models

All parts are **OpenSCAD**, driven by one shared config so the whole board
resizes from a few numbers. These files (or the rendered STLs) are the input
to whoever runs the printer — your own printer, a print service, or a makerspace.

## Files

| File | What it makes | Render options |
|------|---------------|----------------|
| **`common.scad`** | Shared parameters + helpers — **every dimension the whole system is built from.** Edit this to resize everything; it is `include`d by all the parts below. The pivot physics is written out at the top. Not a part: it renders nothing on its own. | — |
| **`gravity_gimbal.scad`** | The self-righting pivot: hub puck **Ø11.5 × 8** (a Ø8 magnet press-fits in its back, the front is bored for the axle) + a **Ø6** press cap. The axle itself is a bought **Ø3 × 16 steel dowel** — not printed. Also exports `body_bore()`, which `pieces.scad` subtracts, so the bore arithmetic lives in exactly one place. | none — always renders the hub + cap test pair |
| **`pieces.scad`** | The six pieces as flat self-righting silhouettes: pivot bore, a **modelled cavity above the pivot**, and a back-face drain hole. **No weight pocket, nothing glued in** — bottom-heaviness is shaped in. Also holds the "Tapered Monolith" drawing language the six shapes obey. | `-D 'PART="pawn"'` … `"king"`, or `"all"` for a six-piece tray |
| **`board_panel.scad`** | The 8×8 playing surface: printed tray + border labels, with a hall-sensor bore behind every square. A **steel sheet** glues onto the front and the piece magnets grip it directly. | `-D 'QUARTER="all"'`, a quarter `"bl"`/`"br"`/`"tl"`/`"tr"`, the 1×2 Phase-0 tile `"test"`, or the sheet's laser-cutting outline `"sheet_dxf"` |
| **`frame.scad`** | Bezel that captures the panel and mounts the turntable. Prints as four L-shaped corners. | `-D 'PART="corner"'` (default: the whole bezel, for preview) |
| **`rotation_hub.scad`** | Wall plate + turntable (lazy-susan bearing) + GT2 drive pulley. | `-D 'PART="wall"'` / `"turntable"` / `"pulley"` (default: assembly preview) |
| **`Makefile`** | Renders every part to `stl/`. | see below |

## Render

Requires [OpenSCAD](https://openscad.org) on your PATH — it is free, and it is
what turns these text files into the STL meshes a printer or print service
wants.

```
cd hardware
make                # everything -> hardware/stl/   (default $fn = 96)
make FN=128         # smoother curves, for final prints
make clean          # delete stl/
```

Individual targets:

| Target | Renders |
|--------|---------|
| `make pieces` | one STL per type, `stl/piece_<type>.stl` |
| `make gimbal` | `stl/gimbal_testpair.stl` — hub + cap side by side |
| `make board` | the whole panel plus all four quarters |
| `make board_test` | `stl/board_test.stl` — the 1×2 Phase-0 tile |
| `make sheet` | `stl/steel_sheet.dxf` — the cutting outline for a laser shop |
| `make mech` | wall plate, turntable, drive pulley, frame corner |

**Phase-0 test batch** — print this first, before committing to a set (see
[`../docs/BUILD_GUIDE.md`](../docs/BUILD_GUIDE.md)):

```
make gimbal board_test                                         # hub + cap, and one board tile
openscad -D '$fn=96' -D 'PART="pawn"' -o stl/piece_pawn.stl pieces.scad
```

One pawn and one hub is the whole test. It is the cheapest experiment in the
project and it is the one that settles the friction assumption everything else
rests on — see the honesty notes above.

Render any single part directly:

```
openscad -D 'PART="king"'        -o king.stl   pieces.scad
openscad -D 'PART="all"'         -o tray.stl   pieces.scad
openscad                         -o gimbal.stl gravity_gimbal.scad
openscad -D 'QUARTER="bl"'       -o panel.stl  board_panel.scad
openscad -D 'QUARTER="test"'     -o tile.stl   board_panel.scad
openscad -D 'QUARTER="sheet_dxf"' -o sheet.dxf board_panel.scad
openscad -D 'PART="turntable"'   -o tt.stl     rotation_hub.scad
openscad -D 'PART="corner"'      -o corner.stl frame.scad
```

Add `-D '$fn=96'` (or higher) to any of these — on its own, OpenSCAD uses the
`$fn = 64` in `common.scad`, which is fine for preview but coarse on the curved
heads.

**Check the render, don't assume it.** OpenSCAD prints a summary when it
exports; read it rather than trusting that no news is good news:

- `Simple: yes` and no `WARNING` / `non-manifold` lines — the geometry is sound.
- `Volumes: 2` on a single piece means *outer space + one solid*, i.e. **one
  shell**. This is how you confirm the drain hole actually broke into the
  cavity: a **sealed** cavity reports `Volumes: 3` (outer space, the solid, and
  the trapped void). The six-piece tray reports `Volumes: 7` — outer space plus
  six separate solids.
- **`Simple: yes` does not catch a trapped void** — a sealed cavity reports
  `Simple: yes` quite happily. The volume count is the check that matters, and
  in resin it is the difference between a clean piece and one that leaks later.

## The set as modelled (55 mm squares, `piece_scale` 1.222)

| Piece | Height | Width | Aspect | Lever `d` | Modelled lean | Mass (resin) |
|-------|-------:|------:|-------:|----------:|--------------:|-------------:|
| Pawn   | 31.77 | 20.74 | 0.653 | 5.71 | 1.49° | 2.24 g |
| Rook   | 36.66 | 24.61 | 0.671 | 4.68 | **1.81°** | 3.43 g |
| Knight | 39.10 | 26.44 | 0.676 | 6.05 | 1.40° | 3.75 g |
| Bishop | 42.77 | 29.98 | 0.701 | 7.29 | 1.16° | 4.52 g |
| Queen  | 46.44 | 25.34 | 0.546 | 5.72 | 1.48° | 4.23 g |
| King   | 51.32 | 25.59 | 0.499 | 8.68 | 0.98° | 4.24 g |

All six: single shell (so every cavity drained), pivot exactly centred,
balanced in x, standing inside their square.

`d` is the lever — how far the centre of mass sits below the pivot — and it is
the only geometry term in `sin(lean) = mu · r / d`, with `r` = 1.85 mm (the
Ø3.70 bore). Mass does not appear: it cancels. See
[`../docs/DESIGN.md` §3.1](../docs/DESIGN.md).

**Read these numbers honestly:**

- **Nothing here has been printed.** Every figure above is measured off the
  exported mesh, not off an object.
- **Lean assumes mu = 0.08** (greased steel on plastic) — a textbook figure,
  not a measured one. Lean scales linearly with mu, so if the real number is
  double, so is every angle in the table. **One printed pawn plus one hub
  settles this, and it is the cheapest test in the project.**
- **The rook has the least margin**: 1.81° against a 2.2° working limit. It is
  the piece to watch once real friction is known.
- **The knight's balance is tuned, not structural.** Its head uses free
  angles — the set's one deliberate language exception — and hangs plumb only
  because of the `KDX` constant in `pieces.scad`. Edit the head polygon and
  the piece will still render perfectly and then hang permanently rotated.
  Re-solve `KDX` if you touch it.
- **Unchecked:** print orientation, overhangs, and whether the Ø8 magnet holds
  the heaviest piece (bishop, 4.52 g, hanging 11 mm proud of the wall).
- **"Inside the square" means standing upright.** A turning piece sweeps a
  circle of its longest corner, which is larger. Five pieces stay inside their
  own square at any angle; the **king's foot corners sweep 28.34 mm** against a
  27.5 mm half-square, crossing the square line by 0.84 mm mid-flip. No legal
  position collides — neighbours rotate together, and the worst adjacent pair is
  king + queen at 28.34 + 26.10 = 54.44 mm against the 55 mm pitch. Two kings
  would exceed it, and chess forbids kings on adjacent squares.

## Print notes

- **Pieces** print flat (silhouette down) — no supports. Two filament colors
  for White/Black. Nothing is glued into a piece: the cavity above the pivot
  is what makes it bottom-heavy, so the piece is one solid part. Drop it over
  the dowel and push the press cap on.
- **Print a piece in cheap PETG before printing the set in resin.** That test
  is *valid* here in a way it would not be with a ballast slug: because the
  piece is one material, density cancels out of the settling equation, so the
  test print hangs the same way the final one will.
- **Drain holes are mandatory in resin.** Each piece has one through its back
  face; do not orient the print so it seals. Count shells in your slicer — a
  piece should be one. (Check it at render time too: see the volume count under
  **Render**.)
- **Hub** — magnet press-fits in the back, Ø3 × 16 dowel presses into the
  front until it bottoms on the magnet, felt disc over the magnet face.
- **The 1.5 mm axial float is deliberate**, not slop: dowel 11 mm proud against
  a 6 mm piece plus 3.5 mm of cap grip. Do not "tighten it up" by seating the
  cap harder — clamping the piece between cap and hub stalls the rotation the
  whole mechanism exists for. The piece needs **no countersink**: the hub's bore
  chamfer is cut *into* the hub face, so nothing protrudes for it to clear.
- **Board panel** — print whole on a big bed, or the four quarters. The
  squares live on the **steel sheet** (paint/vinyl) that glues onto the
  front; `make sheet` exports its cutting DXF for a laser shop.
- **Tolerances** live in `common.scad` (`slop`, `axle_fit`, `magnet_fit`,
  `axle_press_fit`, `cap_grip_fit`). Do the Phase-0 test print first and tune
  before committing to a full set.

See [`../docs/BUILD_GUIDE.md`](../docs/BUILD_GUIDE.md) for assembly and
[`../docs/DESIGN.md`](../docs/DESIGN.md) for how the mechanics work.
