# Hardware — parametric 3-D models

All parts are **OpenSCAD**, driven by one shared config so the whole board
resizes from a few numbers. These files (or the rendered STLs) are the input
to whoever runs the printer — your own printer, a print service, or a makerspace.

## Files

| File | What it makes | Render options |
|------|---------------|----------------|
| **`common.scad`** | Shared parameters + helpers — **every dimension the whole system is built from.** Edit this to resize everything; it is `include`d by all the parts below. The two **variant selectors** and the pivot physics are written out at the top. Not a part: it renders nothing on its own. | — |
| **`gravity_gimbal.scad`** | The self-righting pivot, **both architectures**. Under `pivot_type = "pin"`: hub puck **Ø11.5 × 8** (a Ø8 magnet press-fits in its back, the front is bored for the axle) + a **Ø6** press cap, turning on a bought **Ø3 × 16 steel dowel**. Under `"magnet"`: nothing printed at all — a bought **Ø4 × 5** magnet in the piece's own bore and a bought **Ø9 × 0.8** retaining disc — so it renders the pivot test coupon instead. Also exports the bore + counterbore geometry `pieces.scad` subtracts, so that arithmetic lives in exactly one place. | none — follows `pivot_type` |
| **`pieces.scad`** | **The mechanism, and no artwork.** Takes a silhouette from a style file and applies the same operations to it: extrude, bore the pivot, **model a cavity above the pivot**, drain it through the back face. **No weight pocket, nothing glued in** — bottom-heaviness is shaped in. | `-D 'PART="pawn"'` … `"king"`, or `"all"` for a six-piece tray |
| **`styles/*.scad`** | **The artwork, and no mechanism.** One file per piece style — `monolith.scad` and `familiar.scad` today — each drawing six flat silhouettes and nothing else. A style file knows nothing about bores, magnets, hollowing or plate thickness. See **Adding a style** below. | selected by `piece_style` |
| **`board_panel.scad`** | The 8×8 playing surface: printed tray + border labels, with a hall-sensor bore behind every square. A **steel sheet** glues onto the front and the piece magnets grip it directly. | `-D 'QUARTER="all"'`, a quarter `"bl"`/`"br"`/`"tl"`/`"tr"`, the 1×2 Phase-0 tile `"test"`, or the sheet's laser-cutting outline `"sheet_dxf"` |
| **`frame.scad`** | Bezel that captures the panel and mounts the turntable. Prints as four L-shaped corners. | `-D 'PART="corner"'` (default: the whole bezel, for preview) |
| **`rotation_hub.scad`** | Wall plate + turntable (lazy-susan bearing) + GT2 drive pulley. | `-D 'PART="wall"'` / `"turntable"` / `"pulley"` (default: assembly preview) |
| **`build.ps1`** | Renders every part to `stl/` on **Windows**. Needs neither `make` nor OpenSCAD on PATH. | see below |
| **`Makefile`** | The same, on **macOS / Linux**. | see below |

## Render

Requires [OpenSCAD](https://openscad.org) — free, and it is what turns these
text files into the STL meshes a printer or print service wants.

**On Windows, use `build.ps1`.** It does everything the Makefile does and needs
neither `make` nor OpenSCAD on your PATH, because a normal Windows box has
neither: `make` is not shipped with Git Bash, and the OpenSCAD installer does
not add itself to PATH. It finds OpenSCAD itself.

```powershell
cd hardware
.\build.ps1                 # everything -> hardware\stl\   (default $fn = 96)
.\build.ps1 pieces -Fn 128  # smoother curves, for final prints
.\build.ps1 clean           # delete stl\
```

If PowerShell refuses to run it ("running scripts is disabled"), either unblock
it once with `Unblock-File .\build.ps1`, or run it for this session only with
`powershell -ExecutionPolicy Bypass -File .\build.ps1`.

**On macOS / Linux, use the Makefile.** Same targets, same output.

```
cd hardware
make                # everything -> hardware/stl/
make FN=128         # smoother curves, for final prints
make clean
```

Individual targets — the two are equivalent:

| Renders | PowerShell | make |
|---------|-----------|------|
| one STL per piece type, `stl/piece_<type>.stl` | `.\build.ps1 pieces` | `make pieces` |
| `gimbal_testpair.stl` — hub + cap side by side (or, under `pivot_type = "magnet"`, the pivot test coupon) | `.\build.ps1 gimbal` | `make gimbal` |
| one combination into its own folder, without editing `common.scad` | `.\build.ps1 variant -Style familiar -Pivot pin` | `make variant STYLE=familiar PIVOT=pin` |
| all four combinations, for comparing them | `.\build.ps1 matrix` | `make matrix` |
| the whole panel plus all four quarters | `.\build.ps1 board` | `make board` |
| `board_test.stl` — the 1×2 Phase-0 tile | `.\build.ps1 board_test` | `make board_test` |
| `steel_sheet.dxf` — the cutting outline for a laser shop | `.\build.ps1 sheet` | `make sheet` |
| wall plate, turntable, drive pulley, frame corner | `.\build.ps1 mech` | `make mech` |

> **Known defect, Phase 2 part.** `mech` renders `hub_drive_pulley.stl` as **18
> separate solids** — one body plus 17 loose teeth — so it would print as a
> pulley and a pile of little blocks. The toothed rim in `rotation_hub.scad` is
> a GT2 *approximation* (its own header says so) and the teeth are not fused to
> the body. Nothing in Phase 0 or Phase 1 touches this part. Anything you print
> should be **one** shell unless it is a deliberate multi-part tray like
> `gimbal_testpair`; check that in your slicer before printing.

**Phase-0 test batch** — print this first, before committing to a set (see
[`../docs/BUILD_GUIDE.md`](../docs/BUILD_GUIDE.md)):

```
make gimbal board_test                                         # hub + cap, and one board tile
openscad -D '$fn=96' -D 'PART="pawn"' -o stl/piece_pawn.stl pieces.scad
```

One pawn and one hub is the whole test. It is the cheapest experiment in the
project and it is the one that settles the friction assumption everything else
rests on — see the honesty notes below.

Under `pivot_type = "magnet"` the same two commands give you the other Phase-0
test instead: `make gimbal` renders the **pivot test coupon** (a Ø16 × 6 disc
carrying the bore and the disc seat and nothing else). Press a Ø4 × 5 magnet in,
drop the Ø9 × 0.8 steel disc on, stick it to a steel sheet and flip it — that
~2 g print is what settles both of that architecture's unproven claims.

Render any single part directly:

```
openscad -D 'PART="king"'        -o king.stl   pieces.scad
openscad -D 'PART="all"'         -o tray.stl   pieces.scad

# ...or a specific variant, overriding common.scad from the command line:
openscad -D 'PART="king"' -D 'piece_style="monolith"' -D 'pivot_type="magnet"' \
         -o king_monolith_magnet.stl pieces.scad

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

## Two variants, kept side by side

The design is deliberately **not** narrowed to one answer. **Two independent
selectors** at the top of `common.scad` choose it, and more approaches are
expected to arrive:

```
piece_style = "familiar";   // "monolith" | "familiar"   — the ARTWORK
pivot_type  = "pin";        // "pin"      | "magnet"     — how it HANGS
```

Any of the four combinations builds. The two axes never touch: **no style file
mentions a pivot, and no pivot code mentions a style.** A bad value fails loudly
rather than rendering an empty file — `piece_style = "art-deco"` stops with
`ERROR: Assertion 'false' failed: "pieces.scad: unknown piece_style ..."`.

- **`piece_style`** — `"familiar"` is the online-chess / fridge-magnet
  vocabulary (ball-and-collar pawn, crenellated rook, horse knight, cleft mitre
  bishop, coronet queen, cross king): nobody has to be taught what any of them
  is. `"monolith"` is an invented language — one 1:4 taper, one stroke width,
  one convex and one concave radius, rank reading as height plus one terminal
  event — coherent, but you have to learn it.
- **`pivot_type`** — `"pin"` puts the magnet on the **board** in a printed hub
  puck, so its mass never enters the pendulum: **3 printed parts per piece**
  (body, hub, cap) plus a bought dowel and magnet. `"magnet"` puts a Ø4 × 5
  magnet in the **piece's own bore** and retains it with a Ø9 × 0.8 steel disc:
  **1 printed part per piece**, and about 0.4–0.6° more lean for it. Over a full
  32-piece set that is 64 fewer printed parts and 32 fewer dowels.

### Rendering a variant

Three ways, in increasing permanence:

```
# 1. one part, one-off — nothing on disk changes
openscad -D 'PART="rook"' -D 'piece_style="monolith"' -D 'pivot_type="magnet"' \
         -o rook.stl pieces.scad

# 2. a whole variant into its own folder — still no edit to common.scad
make variant STYLE=familiar PIVOT=pin        # -> stl/familiar_pin/
make matrix                                  # -> all four, side by side

# 3. change the default for everything (plain `make`, and anyone reading later)
#    edit the two selectors at the top of common.scad
```

`make variant` writes the six pieces **plus whatever that pivot architecture
actually has printed parts for** — under `PIVOT=pin` the hub + cap test pair,
under `PIVOT=magnet` the pivot test coupon, because there the hub and cap do not
exist.

### Adding a style

**One new file plus one enum entry. Nothing else in the project changes.**

1. Drop a file in `styles/`, e.g. `artdeco.scad`, exposing exactly **three
   public symbols** — the whole contract:

   | Symbol | Returns |
   |--------|---------|
   | `artdeco_silhouette2d(t)` | the 2D artwork **at final size**, base on `y = 0`, apex exactly at `y = artdeco_pheight(t)` |
   | `artdeco_pheight(t)` | that height, in real printed mm |
   | `artdeco_drains(t)` | back-face drain points `[[x, y], …]`, one per connected cavity region, in the same coordinates |

   `t` is `"pawn"`/`"knight"`/`"bishop"`/`"rook"`/`"queen"`/`"king"`. Everything
   else in the file is private artwork — helper modules and constants resolve in
   their own file's scope, so two styles can both define `foot()` with different
   values without colliding.
2. In `pieces.scad`, in the single block marked **`THE ENUM`**, add one `use
   <styles/artdeco.scad>` and one branch to each of the three dispatchers. Add
   the name to the `piece_style` comment in `common.scad` while you are there.

Two constraints the mechanism imposes on any new artwork, and they are the only
two: the piece hangs `pivot_frac × H` below the axle, so **`H ≤ 55 mm`** (the
square size) with a little to spare for the swing; and under
`pivot_type = "magnet"` the silhouette must be at least **Ø11.4 wide at the
pivot** to floor the retaining disc's seat.

> **Why the public names are prefixed** rather than identical across styles:
> OpenSCAD has no namespaces and no dynamic `include`, so `pieces.scad` has to
> `use` every style file at once. Identically-named modules would silently
> override each other with no way to pick between them at render time.

## The set as modelled (55 mm squares)

**Style `"familiar"`** (the default):

| Piece | Height | Width | Lever `d` | Lean, `"pin"` | Lean, `"magnet"` | Mass |
|-------|-------:|------:|----------:|--------------:|-----------------:|-----:|
| Pawn   | 40.00 | 30.00 | 7.34 | 1.16° | 1.80° | 3.79 g |
| Rook   | 43.00 | 38.00 | 5.89 | **1.44°** | **2.09°** | 6.11 g |
| Knight | 44.50 | 40.47 | 7.51 | 1.13° | 1.62° | 6.49 g |
| Bishop | 47.50 | 36.00 | 9.02 | 0.94° | 1.37° | 5.64 g |
| Queen  | 50.00 | 41.80 | 7.55 | 1.12° | 1.60° | 7.17 g |
| King   | 52.00 | 42.00 | 8.59 | 0.99° | 1.40° | 7.49 g |

**Style `"monolith"`:**

| Piece | Height | Width | Lever `d` | Lean, `"pin"` | Lean, `"magnet"` | Mass |
|-------|-------:|------:|----------:|--------------:|-----------------:|-----:|
| Pawn   | 31.77 | 20.74 | 5.71 | 1.49° | **2.61°** | 2.24 g |
| Rook   | 36.66 | 24.61 | 4.68 | **1.81°** | **2.89°** | 3.43 g |
| Knight | 39.10 | 26.44 | 6.05 | 1.40° | 2.19° | 3.75 g |
| Bishop | 42.77 | 29.98 | 7.29 | 1.16° | 1.75° | 4.52 g |
| Queen  | 46.44 | 25.34 | 5.72 | 1.48° | **2.27°** | 4.23 g |
| King   | 51.32 | 25.59 | 8.68 | 0.98° | 1.49° | 4.24 g |

All 24 combinations: single shell (so every cavity drained), pivot exactly
centred, standing inside their square. `d`, height, width and mass are the
`"pin"` figures; under `"magnet"` `d` is smaller on every piece, which is what
the last lean column shows. **Bold = at or past the 2.2° working limit, or the
worst in its column.**

**`monolith` + `magnet` is the one combination of the four that busts the 2.2°
limit** — on three pieces of six (rook 2.89°, pawn 2.61°, queen 2.27°), with the
knight a hair under at 2.19°. The monolith pieces are small, so `d` is small,
and the magnet architecture's penalty is close to a fixed subtraction from `d`,
which hurts a short lever far more than a long one. The two axes are independent
in the code; they are **not** independent in the outcome.

`d` is the lever — how far the centre of mass sits below the pivot — and it is
the only geometry term in `sin(lean) = mu · r / d`, with `r` = 1.85 mm under
`"pin"` (the Ø3.70 bore) and 2.35 mm under `"magnet"` (the Ø4.70 bore). Mass
does not appear: it cancels — **except** for mass added *at* the pivot, which
adds no restoring torque but does drag the combined centre of mass toward the
axis and shrink `d`. That is the whole of why `"magnet"` costs what it costs.
See [`../docs/DESIGN.md` §3.1](../docs/DESIGN.md).

**Read these numbers honestly:**

- **Nothing here has been printed.** Every figure above is measured off the
  exported mesh, not off an object.
- **Lean assumes mu = 0.08** (greased steel on plastic) — a textbook figure,
  not a measured one. Lean scales linearly with mu, so if the real number is
  double, so is every angle in the table. **One printed pawn plus one hub
  settles this, and it is the cheapest test in the project.**
- **The rook has the least margin in both styles**: 1.44° familiar, 1.81°
  monolith, against a 2.2° working limit. Crenellation is by definition a lot
  of area high above the pivot. It is the piece to watch once real friction is
  known.
- **Each style's knight is balanced by a tuned constant, not structurally.**
  Both hang plumb only because of a `KDX` in their style file. Edit the head
  polygon and the piece will still render perfectly, still pass the shell
  check, and then hang permanently rotated. Re-solve `KDX` if you touch it.
  (The familiar knight is also **wider — 40.5 mm — than the bishop at 36 or
  the rook at 38**. That one is structural: its symmetric foot has to
  out-reach the muzzle to keep the pivot on the bounding-box centre.)
- **`pivot_type = "magnet"` has two unproven claims**, and neither is in the
  lean numbers: that a Ø9 steel disc stays put on a Ø4 magnet through a board
  flip, and that the piece turns at all once the disc clamps its whole back
  face to the steel sheet under the magnet's full pull — the lean figures
  model **bore** friction only, so they are optimistic for that architecture.
  `make gimbal` under `"magnet"` prints the coupon that settles both.
- **Unchecked:** print orientation, overhangs, and whether the magnet holds the
  heaviest piece — the familiar king at 7.49 g, hanging 11 mm proud of the wall,
  two-thirds heavier than the monolith set's heaviest (bishop, 4.52 g). That is
  the Ø8 hub magnet under `"pin"`, and the **Ø4** magnet under `"magnet"`, which
  is also carrying the retaining disc's weight.
- **"Inside the square" means standing upright.** A turning piece sweeps a
  circle of its longest corner, which is larger, and **the familiar set sweeps
  well past its square** — measured radius from the pivot:

  | | pawn | rook | knight | bishop | queen | king |
  |---|---:|---:|---:|---:|---:|---:|
  | familiar | 24.44 | 28.12 | 29.42 | 29.24 | 31.45 | **32.85** |
  | monolith | 18.60 | 21.70 | 23.22 | 25.73 | 26.10 | **28.34** |

  against a 27.5 mm half-square. That is a crossing of 5.35 mm for the familiar
  king where the monolith king crossed by 0.84 mm. **It is still not a
  collision, but the reason is now the only thing holding it up:** neighbours
  are carried on one rigid board and each stays upright in the room's frame, so
  two adjacent pieces never move relative to each other at all. If one piece
  *lags* while its neighbour is upright, the bound is that piece's sweep plus
  the neighbour's half-width. Worst legal pair:

  | | worst pair | bound | margin on the 55 mm pitch |
  |---|---|---:|---:|
  | familiar | king + queen | 32.85 + 20.90 = 53.75 | **1.25 mm** |
  | monolith | king + bishop | 28.34 + 14.99 = 43.33 | 11.67 mm |

  **Two adjacent royals lagging at once is not covered** for familiar
  (32.85 + 31.45 = 64.30 mm), and nothing has tested whether pieces stay in step
  through a flip. If they do not, that is an argument for the monolith set, and
  it is the one place where the artwork choice is a mechanical choice.

## Print notes

- **Pieces** print flat (silhouette down) — no supports. Two filament colors
  for White/Black. Nothing is glued into a piece: the cavity above the pivot
  is what makes it bottom-heavy, so the piece is one solid part. Under
  `pivot_type = "pin"` you then drop it over the dowel and push the press cap
  on; under `"magnet"` you push a Ø4 × 5 magnet into its bore from the back
  and drop the Ø9 × 0.8 steel disc onto the magnet through the front.
- **Print a piece in cheap PETG before printing the set in resin.** That test
  is *valid* here in a way it would not be with a ballast slug: because the
  piece is one material, density cancels out of the settling equation, so the
  test print hangs the same way the final one will.
- **Drain holes are mandatory in resin.** Each piece has one through its back
  face; do not orient the print so it seals. Count shells in your slicer — a
  piece should be one. (Check it at render time too: see the volume count under
  **Render**.)
- **Hub** (`pivot_type = "pin"` only) — magnet press-fits in the back, Ø3 × 16
  dowel presses into the front until it bottoms on the magnet, felt disc over
  the magnet face. Under `"magnet"` there is no hub, no dowel and no cap, and
  the next two notes do not apply.
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
