# Build Guide

Step-by-step for **Phase 1** (the manual wall board) with pointers to later
phases. Read [`DESIGN.md`](DESIGN.md) first for the "why."

> **Read this before you trust a number below.** Nothing in this repo has been
> built or printed yet. Every dimension and every angle quoted here is measured
> off a computer model, not off an object. The whole point of Phase 0 (§1) is to
> turn the cheapest of those numbers into a real one before you commit to a set.

## 0. Before you print

1. Install [OpenSCAD](https://openscad.org).

2. **Pick your two variants.** The design is deliberately *not* narrowed to one
   answer — competing approaches sit side by side so they can be compared, and
   more are expected. Two independent selectors at the top of
   [`hardware/common.scad`](../hardware/common.scad) choose one:

   ```
   piece_style = "familiar";   // "monolith" | "familiar"   — what the pieces LOOK like
   pivot_type  = "pin";        // "pin"      | "magnet"     — how a piece HANGS and TURNS
   ```

   - **`piece_style`** is artwork only. `"familiar"` is the online-chess /
     fridge-magnet vocabulary — ball-and-collar pawn, crenellated rook, horse
     knight, cleft mitre bishop, coronet queen, cross king; nobody has to be
     taught what any of them is. `"monolith"` is an invented design language —
     one 1:4 taper, one stroke width, rank reading as height plus a single
     terminal event; coherent, but you have to learn it. **It changes nothing
     you buy** (see [`BOM.md`](BOM.md)).
   - **`pivot_type`** is mechanism, and it **does** change what you buy and how
     you assemble. `"pin"` puts the magnet on the **board** in a printed hub
     puck — **3 printed + 2 bought** parts per piece. `"magnet"` puts it **in
     the piece** and drops the hub, dowel and cap entirely — **1 printed +
     2 bought** — for about 0.4–0.6° more lean. (Three parts go, one arrives, so
     the net saving is two: the one that matters is 3 printed → 1.)

   **If you have no opinion yet, build the defaults: `familiar` + `pin`.** They
   are the defaults because `familiar` is both the look most people want *and*
   the better lever on five pieces of six, and `pin` is the architecture with no
   unproven claims in it.

   You can also build a combination without editing the file at all:

   ```
   cd hardware
   make variant STYLE=familiar PIVOT=pin      # -> stl/familiar_pin/
   make matrix                                # all four, side by side
   ```

3. The board size is **locked at `square_size = 55`** — this resolves decision
   **D1**. It is not a taste call: under `pivot_type = "pin"` the hub puck behind
   each piece is a fixed Ø11.5 disc, and the piece has to *hide* it or every
   piece wears a visible grey collar. Only the artwork scales with the square,
   not the mechanism, so a bigger square grows the piece until its natural waist
   swallows the puck. 55 mm is the smallest square where the *narrowest* style
   (`monolith`, waist Ø12.0) manages it — with 0.5 mm to spare. The panel ends up
   ~490 mm square.

   What you *should* still check against what you actually bought:
   - `magnet_dia` / `magnet_thk` — the hub magnets (`"pin"`, default Ø8 × 3), or
     `pivot_magnet_dia` / `pivot_magnet_thk` (`"magnet"`, default Ø4 × 5),
   - `retain_disc_dia` / `retain_disc_thk` (`"magnet"` only, default Ø9 × 0.8),
   - `sheet_thk` — the steel sheet you'll order,
   - `bearing_od` / `bearing_id` — your lazy-susan bearing.

4. **Buy, don't print, the metal.** Under `"pin"`: stock **Ø3 × 16 mm steel
   dowel pins**, one per piece plus spares. ("Dowel pin" is the hardware-shop
   name for a short ground steel rod, sold by the bag.) A printed post was tried
   and dropped — see the `axle_dia` note in
   [`common.scad`](../hardware/common.scad). Under `"magnet"`: **Ø4 × 5 magnets**
   and plain **Ø9 × 0.8 steel discs**.

5. From `hardware/`, render everything:
   ```
   make            # all STLs into hardware/stl/, using the variant in common.scad
   make FN=128     # smoother, for final parts
   ```
   Or render individually, e.g. `make pieces`, or
   `openscad -D 'PART="king"' -o king.stl pieces.scad`.

## 1. Prototype the mechanics (Phase 0 — do this first!)

Cheap insurance before printing 32 pieces. **Test the pawn** — it is the
smallest, quickest, cheapest print in the set, and what you are really measuring
is `mu`, the friction coefficient, which is a property of the *pivot*, not of the
piece. Measure the pawn's lean, divide by its modelled figure, and you have the
factor that scales every other piece's number.

Note the pawn is **not** the worst case: it is the shortest *piece*, but not the
one with the shortest *lever*. The squat **rook** carries the shortest lever and
therefore the largest modelled lean in every combination — see the tables in §2.
If you want the worst case on the bench as well, print a rook too; it is the
piece that runs out of margin first.

### What you are actually testing

A hanging piece does not park perfectly upright. It stops wherever friction in
its bore cancels the pull of gravity:

```
sin(lean) = mu * r / d

  mu = friction coefficient in the bore  (~0.08 assumed: greased steel on plastic)
  r  = bore radius   ("pin": 1.85 mm, a Ø3.70 bore on a Ø3 dowel)
                     ("magnet": 2.35 mm, a Ø4.70 bore on a Ø4 magnet)
  d  = how far the centre of mass sits BELOW the pivot  (4.7-9.0 mm across the set)
```

**Mass cancels out of that equation completely.** Adding weight to a piece does
nothing at all for how straight it hangs — which is why there is no ballast
anywhere in this design (see §4). Only geometry and friction move the number, and
geometry is already fixed. So `mu` is the one unknown, `mu = 0.08` is a textbook
figure nobody has measured on this hardware, and **one printed pawn plus one
pivot settles it.** That is the cheapest experiment in the project.

**The one exception to "mass cancels", and it is the whole argument between the
two pivot architectures:** mass added *at* the pivot still hurts. It contributes
no restoring torque, but it does drag the combined centre of mass toward the
axis, which shrinks `d`. `pivot_type = "magnet"` hangs the magnet *and* the
retaining disc on the piece at zero lever arm, which is exactly that case — and
it is why it measures worse.

A second consequence of the same physics: a piece hangs with its centre of mass
directly below the pivot, so an asymmetric silhouette has to be balanced
left-to-right or it hangs permanently rotated. In both styles only the knight is
asymmetric — see the warning in §2.

### Print the test parts

```
make gimbal board_test      # the pivot test print, and one board tile
make pieces                 # then print just the pawn: stl/piece_pawn.stl
```

`make gimbal` follows `pivot_type`, so it gives you the right thing:

- under **`"pin"`** → `gimbal_testpair.stl`, one **hub puck + press cap** side
  by side;
- under **`"magnet"`** → the **pivot test coupon**, a Ø16 × 6 disc carrying the
  bore and the disc seat and nothing else. There are no printed pivot parts in
  that architecture, so the coupon is what stands in for them — and it is
  deliberately the experiment that settles this architecture's two unproven
  claims. See "Also do this" below.

Print the pawn in whatever is cheapest. Because the piece is one single material
with no ballast in it, density cancels out of the settling equation and a cheap
PETG or PLA test print behaves *identically* to the final resin part. (That is
the whole reason the ballast was removed.)

### Assemble it — `pivot_type = "pin"`

Five steps, no glue except optionally on the magnet.

1. **Magnet into the hub's back.** The Ø8 × 3 magnet drops into the cavity on
   the hub's flat back face (the one that will face the wall). It is dimensioned
   as a press fit; add a drop of super glue if your printer runs loose. Keep the
   polarity consistent across every hub — mark one face.
2. **Dowel into the hub's front.** Press a **Ø3 × 16 steel dowel** into the bore
   on the other face until it **bottoms out on the back of the magnet**. That is
   deliberate: the two cavities meet in the middle of the 8 mm puck, so there is
   no thin printed web for the dowel to crack through and the dowel cannot creep
   deeper later. **11 mm should stand proud.**
3. **Felt disc** over the magnet on the back face. It sets the glide across the
   board and protects the sheet's paint.
4. **Grease the piece's bore.** A smear of **silicone damping grease** inside the
   Ø3.70 hole through the pawn. Viscous grease is doing two jobs — read the
   "rings for ages" row in [Troubleshooting](#troubleshooting) before you decide
   it needs *less* friction.
5. **Slide the piece on, press the cap on.** The pawn drops over the dowel and
   spins freely; the Ø6 cap grips the plain dowel by interference and stops it
   falling off. Push the cap on until it is snug, not until it clamps — the
   design leaves **1.5 mm of deliberate axial float** (11 mm of dowel against
   6 mm of piece plus 3.5 mm of cap grip) precisely so print tolerances can't
   squeeze the piece still.

Then stick the hub to a steel surface. The hub is what holds the board; the
piece hangs off it.

### Assemble it — `pivot_type = "magnet"`

Four steps, **no glue at all, and no printed parts but the piece**. Note the
order: unlike `"pin"`, this assembly happens **on the steel**, because the sheet
is what holds the magnet in place while you build the stack on it.

1. **Grease the piece's bore.** A smear of **silicone damping grease** inside the
   Ø4.70 hole through the pawn. Here the bore runs on the *magnet* itself, so
   this is the whole bearing surface.
2. **Stick the Ø4 × 5 magnet to the steel**, at the centre of a square. Keep
   polarity consistent and mark a face, same as before.
3. **Drop the piece over the magnet.** The Ø4.70 bore slides onto the Ø4 magnet
   and the piece's back face comes to rest on the sheet — the magnet is
   dimensioned to finish flush with that face, so there is no plastic in the
   magnetic gap. The magnet's front pole is now sitting at the floor of the
   counterbore in the piece's front face.
4. **Drop the Ø9 × 0.8 steel disc into the counterbore.** It snaps onto the
   magnet's front pole and sits 0.2 mm below flush. Being wider than the Ø4.70
   bore, it cannot pass through — and that is the *only* thing stopping the piece
   pulling off the magnet.

**Be aware of what this stack is not.** Take the piece off the board and it is
three loose parts (piece, magnet, disc) rather than one assembled unit — that
follows directly from the geometry, since nothing but the sheet holds the
sandwich together from behind. Under `"pin"` the hub, dowel, cap and piece stay
assembled when you lift them off.

**There is no ballast step in either architecture.** Nothing is glued into the
piece. Bottom-heaviness is shaped in: the piece is solid below the pivot and
hollow above it, and that cavity is modelled into the part.

### Measure it — the ten-flip test

This is the one number the design is not sure of, and it is the same test in
both architectures.

1. Stick the assembly to any **steel** surface held vertically — a fridge side,
   a filing cabinet, any steel offcut.
2. It should **hold**, **stay upright**, and still look **centred in its square**
   after you rotate the surface.
3. **Flip the surface 180° ten times.** After each flip, let the piece settle and
   note how far off vertical it parks. **Record the worst of the ten**, not the
   average — the worst is what a player sees.
4. Compare that worst lean against your variant's modelled pawn figure below.

| Variant | Modelled pawn lean | Worst piece in the set (rook) | Friction headroom before the set busts the 2.2° working limit | So the pawn may measure up to… |
|---|---:|---:|---:|---:|
| `familiar` + `pin` **(default)** | 1.16° | 1.44° | 1.53× | **~1.8°** |
| `monolith` + `pin` | 1.49° | 1.81° | 1.22× | **~1.8°** |
| `familiar` + `magnet` | 1.80° | 2.09° | 1.05× | **~1.9°** |
| `monolith` + `magnet` | 2.61° | 2.89° | — | **already over as modelled** |

Read the table like this: the measured/modelled *ratio* is your real `mu` divided
by the assumed 0.08, and it scales **every** piece equally. So the set survives as
long as `ratio × (worst piece's modelled lean) ≤ 2.2°`. That is where the last
column comes from — and note it lands at roughly the same 1.8–1.9° in all three
viable combinations, which makes it an easy number to remember on the bench.

- **Worst lean at or below your variant's modelled pawn figure** → the friction
  budget is real; the whole set is good.
- **Up to the last column** → still inside the working limit, but the rook has
  little or no margin left. Proceed, and watch the rook.
- **Above it** → real `mu` is higher than assumed. Fix it at the pivot, not with
  weight: more/better silicone grease first, then check the sliding pair is
  genuinely steel (a real dowel, or a real magnet — not a printed post) and that
  the bore isn't stringy or under-sized. **Adding mass will not help, ever.** If
  grease doesn't get you there, the honest move is to change variant: `pin` costs
  0.4–0.6° less than `magnet`, and `familiar` has a longer lever than `monolith`
  on five pieces of six.

### Also do this — `pivot_type = "magnet"` only

The lean number above is **not** the whole test for this architecture, because
two things about it are unproven and neither one is inside any lean figure:

1. **Does the Ø9 disc stay put on a Ø4 magnet through a board flip?** Nothing has
   verified it. If it walks off, the piece comes off with it. Flip the coupon
   twenty times, then flip it hard, then knock it. The disc should not move.
2. **Does the piece still turn once its back face is clamped to the sheet?** The
   disc bears on the counterbore floor, which presses the piece's *whole back
   face* onto the steel with the magnet's full pull. So rotation must overcome
   **face** friction out at silhouette radii, not just bore friction at
   r = 2.35 mm. **Every `"magnet"` lean figure in this repo models bore friction
   only and is therefore optimistic.** Turn the coupon with a fingertip; it
   should spin freely and coast to a stop, not creep and stick.

The coupon is a ~2 g print and it answers both. Do it before you order 40
magnets. (Under `"pin"` neither objection applies: the piece bears on the hub
puck's Ø11.5 face under its own weight only.)

### Optional

Print the **board test tile** (`make board_test`), glue any steel offcut on its
face, and check the magnet holds & slides square to square nicely, and (Phase 2)
that a hall sensor in the rear bore trips under a piece. Under `"magnet"` this is
worth more than optional: the sensing magnet is then a Ø4 × 5 rather than a
Ø8 × 3, and whether a hall sensor reads it reliably has **not** been checked.

**Exit criteria:** the pawn holds on vertical steel, stays upright when you
rotate the steel by hand, settles inside the ceiling in the table above, stops
swinging in a second or two, and still looks centred in its square afterwards.
Under `"magnet"`, add: the disc stayed on, and the coupon still spins freely.

## 2. Print the set

### The set as modelled — 55 mm squares, `pivot_type = "pin"`

`d` is the pendulum lever: how far the centre of mass sits below the pivot. It is
the only geometry term in `sin(lean) = mu · r / d`.

**`piece_style = "familiar"`** (the default)

| Piece | Height | Width | Lever `d` | Modelled lean | Mass |
|-------|-------:|------:|----------:|--------------:|-----:|
| Pawn   | 40.00 mm | 30.00 mm | 7.34 mm | 1.16° | 3.79 g |
| Rook   | 43.00 mm | 38.00 mm | 5.89 mm | **1.44°** | 6.11 g |
| Knight | 44.50 mm | 40.47 mm | 7.51 mm | 1.13° | 6.49 g |
| Bishop | 47.50 mm | 36.00 mm | 9.02 mm | 0.94° | 5.64 g |
| Queen  | 50.00 mm | 41.80 mm | 7.55 mm | 1.12° | 7.17 g |
| King   | 52.00 mm | 42.00 mm | 8.59 mm | 0.99° | 7.49 g |

**`piece_style = "monolith"`**

| Piece | Height | Width | Lever `d` | Modelled lean | Mass |
|-------|-------:|------:|----------:|--------------:|-----:|
| Pawn   | 31.77 mm | 20.74 mm | 5.71 mm | 1.49° | 2.24 g |
| Rook   | 36.66 mm | 24.61 mm | 4.68 mm | **1.81°** | 3.43 g |
| Knight | 39.10 mm | 26.44 mm | 6.05 mm | 1.40° | 3.75 g |
| Bishop | 42.77 mm | 29.98 mm | 7.29 mm | 1.16° | 4.52 g |
| Queen  | 46.44 mm | 25.34 mm | 5.72 mm | 1.48° | 4.23 g |
| King   | 51.32 mm | 25.59 mm | 8.68 mm | 0.98° | 4.24 g |

All twelve: single shell (every cavity drained), pivot exactly centred, balanced
left-to-right, standing inside the square.

### The same sets under `pivot_type = "magnet"`

Heights, widths and masses of the *printed piece* are unchanged — only the pivot
hardware differs — but every lean grows, because `r` goes from 1.85 to 2.35 mm
*and* the magnet plus disc now ride with the piece at zero lever arm:

| Piece | familiar: pin → magnet | monolith: pin → magnet |
|-------|---:|---:|
| Pawn   | 1.16° → 1.80° | 1.49° → **2.61°** |
| Rook   | 1.44° → **2.09°** | 1.81° → **2.89°** |
| Knight | 1.13° → 1.62° | 1.40° → 2.19° |
| Bishop | 0.94° → 1.37° | 1.16° → 1.75° |
| Queen  | 1.12° → 1.60° | 1.48° → **2.27°** |
| King   | 0.99° → 1.40° | 0.98° → 1.49° |

**`monolith` + `magnet` is the one combination of the four that busts the 2.2°
working limit** — on three pieces of six (rook 2.89°, pawn 2.61°, queen 2.27°),
with the knight a hundredth under it at 2.19°, so only the bishop and king have
any real margin left. The two axes are independent in the code
but not in the outcome: the monolith pieces are smaller, so `d` is smaller, and
the magnet architecture's penalty is roughly a fixed subtraction from `d`. If you
want the three-fewer-parts architecture, pair it with `familiar`.

**Read all of these numbers honestly:**

- **Nothing has been printed.** Every figure is measured off an exported mesh.
- **Lean assumes `mu = 0.08`** — textbook, not measured. Lean scales linearly
  with `mu`: if the real friction is double, so is every angle in every table
  above. Phase 0 (§1) is what settles this.
- **The `"magnet"` figures are optimistic on top of that**, because they model
  bore friction only and ignore the face friction from the disc clamping the
  piece to the sheet. See §1, "Also do this".
- **The rook has the least margin in every combination** — crenellation is by
  definition a lot of area high above the pivot. It is the piece that breaks
  first if real friction is higher than assumed.
- **Each style's knight is balanced by a tuned constant, not structurally.** Both
  hang plumb only because of a hand-solved `KDX` in their style file —
  [`styles/familiar.scad`](../hardware/styles/familiar.scad) and
  [`styles/monolith.scad`](../hardware/styles/monolith.scad). **Edit a knight's
  head and it will still render perfectly, still pass the shell check, still look
  right, and then hang permanently rotated.** If you touch that polygon you must
  re-measure and re-solve `KDX`.
- **The familiar knight is wider (40.5 mm) than the bishop (36) or the rook
  (38).** That one *is* structural, not a mistake: its symmetric foot has to
  out-reach the muzzle so the foot owns both bounding-box edges and the pivot
  stays on the centre.
- **"Inside the square" means standing upright.** A *turning* piece sweeps a
  circle of its longest corner, which is bigger, and **the familiar set sweeps
  past its square** — 32.85 mm from the pivot at the king, against a 27.5 mm
  half-square (the monolith king reaches 28.34 mm). It is still not a collision,
  because neighbours ride one rigid board and each stays upright in the room's
  frame, so adjacent pieces never move relative to each other. But if one piece
  *lags* while its neighbour is upright, the worst legal pair leaves **1.25 mm**
  of margin in `familiar` against **11.67 mm** in `monolith`. **Nothing has tested
  whether pieces stay in step through a flip.** If they don't, that is an
  argument for `monolith` — the one place the artwork choice is a mechanical
  choice. Full numbers in [`../hardware/README.md`](../hardware/README.md).
- **Unchecked:** print orientation, overhangs, and whether the magnet actually
  holds the heaviest piece (familiar king, 7.49 g, hanging 11 mm proud of the
  wall under `"pin"`). Phase 0 tests the pawn's *lean*; it does not test the
  king's *grip*.

### What to print

- **Pieces:** print `piece_*` in your two colors. Counts per side: 8 pawns,
  2 knights, 2 bishops, 2 rooks, 1 queen, 1 king (+ a spare queen for
  promotions is handy).
  - Under **`"pin"`**, every piece also needs one hub, one magnet, one felt disc,
    one Ø3 × 16 dowel and one cap — so 32 of each, plus spares. Print a few extra
    hubs and caps; they are small (all 64 together are only ~30 g).
  - Under **`"magnet"`**, every piece needs one Ø4 × 5 magnet and one Ø9 × 0.8
    steel disc, **both bought**. There is nothing else to print.
- **Board panel:** `board_panel.stl` whole if it fits your bed, else the four
  `board_panel_{bl,br,tl,tr}` quarters and join.
- **Frame:** four `frame_corner` pieces.
- **Rotation hub:** `hub_wall_plate`, `hub_turntable`, `hub_drive_pulley`
  (pulley only needed in Phase 2).

### Printing the pieces — FDM (filament)

- Print **flat, silhouette face down**, on the bed. No supports needed.
- **Print solid (100% infill).** The cavity above the pivot is modelled into the
  part, so it stays hollow whatever you set — but sparse infill lightens the
  *solid half below the pivot*, and that is the exact mass the piece self-rights
  with. Low infill shortens the lever `d` and directly increases lean.
- `hollow_wall` is 0.9 mm, which is two perimeters on a 0.4 mm nozzle. Don't go
  below two perimeters.

### Printing the pieces — resin (SLA/MSLA)

Resin prints the silhouettes beautifully and is the intended final material, but
it has three failure modes this design has to be laid out around.

- **Do NOT lay the flat plate directly on the build plate.** On a resin printer
  every layer is peeled off a film, and a large flat area printed straight onto
  the plate creates a vacuum — "suction" — on each peel. That force can tear the
  part, delaminate it, or rip it off the plate entirely.
- **Tilt the piece 20–30° off the plate** and lift it on supports. Tilting means
  each layer's cross-section is a narrow band instead of the whole silhouette,
  so the peel force stays small.
- **Support from the BACK face only.** Supports leave small nubs and scars where
  they touch. The front silhouette is the entire point of these pieces — it is
  what a player reads from across the room — and sanding scars out of a small
  corner radius will visibly ruin the outline. Every support goes on the back.
  (Under `"magnet"` the front face also carries the disc counterbore; keep
  supports out of it, or the disc will not seat flat.)
- **Every cavity has a drain hole, and it must not be blocked.** The drain is a
  Ø2 hole through the back face into the hollow above the pivot. Uncured resin
  trapped in a sealed void leaks out weeks later or bulges the wall as it cures.
  So: place supports **clear of the drain hole**, orient the tilt so the drain
  ends up **low** while the part drains and washes, and confirm resin actually
  runs out before you cure it.
- **Do not use your slicer's "hollow" tool.** The cavity is modelled
  deliberately — solid below the pivot, hollow above it. A slicer's hollow
  function scoops material out *evenly everywhere*, which produces no
  top-to-bottom mass gradient at all and destroys the self-righting behaviour
  while looking identical on screen.
- **Verify before you print 32 of them:** load the STL and check the model is
  **one shell** (one closed body). A cavity the drain hole failed to reach shows
  up as a second, inner shell — that is a sealed resin trap.

## 3. Assemble the board panel

Identical in both architectures — the sheet is the playing surface either way.

1. Cut/order the **steel sheet**: `grid_size` square (**440 mm** at the locked
   55 mm square), 0.5–1 mm mild/galvanized steel — **not** stainless 304, which
   is not magnetic enough. For Phase-2 sensing have the shop laser-cut the 64
   sensing holes — `make sheet` exports the 1:1 DXF. A plain un-holed sheet is
   fine for Phase 1.
2. **Mark the squares on the sheet** (paint or vinyl, two tones; mask & spray
   works well). The printed border keeps the a–h / 1–8 labels.
3. **Glue the sheet** to the panel front (epoxy or strong VHB tape), sensing
   holes centered over the panel's bores. Clamp flat while it cures.
4. (Phase 2) slide a **hall sensor** into each bore from the back until its
   tip sits flush under the sheet hole; route leads through the open back
   cavity to the mux boards.
5. Press **heat-set inserts** (or tap) the four corner bosses.

## 4. Assemble pieces

Same steps as the Phase-0 pawn in §1, once per piece — 32 times. Which steps
depends on `pivot_type`.

### `pivot_type = "pin"` — 5 steps per piece, done off the board

1. Press a **Ø8 × 3 magnet** into the hub's **back** (consistent polarity — mark
   a face; a drop of super glue if it is loose).
2. Press a **Ø3 × 16 steel dowel** into the hub's **front** bore until it
   **bottoms on the magnet**. 11 mm stands proud.
3. Stick a **felt disc** over the magnet (glide + paint protection).
4. Smear **silicone damping grease** in the *piece's* Ø3.70 bore.
5. **Slide the piece onto the dowel** and **press the cap on** — snug, not
   clamped. The 1.5 mm of axial float is intentional.

Each finished unit is a **single assembly** you then stick to any square.

### `pivot_type = "magnet"` — 4 steps per piece, done on the board

1. Smear **silicone damping grease** in the piece's Ø4.70 bore. That bore runs
   directly on the magnet, so it is the whole bearing surface.
2. Stick a **Ø4 × 5 magnet** to the sheet at the centre of the square
   (consistent polarity — mark a face).
3. **Drop the piece over the magnet.** Its back face lands on the sheet; the
   magnet is dimensioned flush with that face, so nothing sits in the magnetic
   gap.
4. **Drop a Ø9 × 0.8 steel disc** into the counterbore in the piece's front face.
   It snaps onto the magnet and sits 0.2 mm below flush. No glue — the magnet
   holds it, and it is the only thing retaining the piece.

There is **no hub, no dowel, no cap and no felt disc** in this architecture, and
no glue anywhere. In exchange, a piece lifted off the board separates into three
loose parts rather than staying assembled.

### Both architectures

**There is no ballast step and there is no weight pocket.** Older versions of
this guide had you glue lead or M3 nuts into a base pocket; that is gone.
Bottom-heaviness is now shaped into the part — solid below the pivot, hollow
above it — which removes a glue step, removes a part, and (because the piece is
then one single material) makes a cheap test print behave exactly like the final
one. It also would not have helped: mass cancels out of the settling equation.

Spin-test each piece: it should rotate freely, settle upright, and sit centred in
its square. The pivot is on the piece's own bounding-box centre, so however it
settles it **rotates in place** rather than drifting sideways — a piece that
looks off-centre means the *pivot* is off-centre, not the piece.

## 5. Frame + turntable

1. Bolt the **four frame corners** together around the panel; the front lip
   captures the panel face, electronics cavity faces the wall.
2. Bolt the **turntable** to the frame's back bosses (4× M3).
3. Seat the **lazy-susan bearing**: fixed race into the **wall plate**,
   rotating race into the **turntable**.
4. Bolt the **wall plate** to a **French cleat**. Confirm the whole thing
   **spins freely** and **balances** (center of mass on the axis) so a light
   push flips it 180°.

## 6. Hang & play

1. Mount the cleat to a **stud** (or heavy-duty anchors). Level it.
2. Set up the pieces; play. Flip the board by hand at each turn — pieces should
   stay upright the whole way. That's Phase 1 done. 🎉

## 7. Going powered (Phase 2 → 3)

- Add the **NEMA-17 + GT2 belt** to the turntable rim and the **hall home
  sensors**; see [`ELECTRONICS.md`](ELECTRONICS.md).
- Populate the **64 hall sensors** and wire through muxes to an **ESP32**;
  run the rules engine so the board follows and validates the game.
- Later, add the auto-mover (per **D6** in [`GOALS.md`](GOALS.md) — aspirational,
  out of initial scope: if pursued, the researched route is the **EPM matrix**
  (prototype-gated), reclined-gantry fallback — see
  [`AUTO_MOVER_DESIGN.md`](AUTO_MOVER_DESIGN.md)) and the **app**.

## Troubleshooting

### Both architectures

| Symptom | Fix |
|---|---|
| **Piece rings for ages after a board flip** | **Thicker grease — not less friction.** This is the counter-intuitive one, so read it twice: friction is what *stops* the swing, so a near-frictionless pivot rings longest. A piece on a ball bearing would swing for minutes. Silicone damping grease adds *viscous* drag (which kills the ringing) without adding the *static* friction that causes the row below. Dry PTFE lube is exactly the wrong move — it removes the damping you want and leaves the stiction you don't |
| Piece parks a few degrees off vertical | This is friction, not balance: `sin(lean) = mu · bore_radius / lever`. **Mass cancels out — adding weight does nothing**, which is why there is no ballast to adjust. In order: more/better silicone damping grease; confirm the sliding pair really is steel (a real dowel, or a real magnet — not a printed post); check the bore isn't stringy, over-cured or under-size. If grease can't get you there, changing variant can: `"pin"` costs 0.4–0.6° less than `"magnet"` |
| Piece hangs low or off-centre in its square | Confirm `pivot_frac` is 0.50 and that the **pivot** (hub puck, or magnet) is on the square's centre. A piece pivoted on its own centre cannot drift — if it looks like it did, one of those two is wrong |
| **The knight** hangs permanently rotated | Its balance is tuned by a `KDX` constant in its **style** file — [`styles/familiar.scad`](../hardware/styles/familiar.scad) or [`styles/monolith.scad`](../hardware/styles/monolith.scad) — not by structure. If anyone edited the head polygon, `KDX` must be re-solved. The piece renders and prints perfectly either way, so nothing else will warn you |
| Magnet won't hold on the vertical face | Bigger/stronger magnet, thinner felt disc (`"pin"`), confirm the sheet is ferromagnetic steel and not stainless 304. The heaviest piece is the familiar king at 7.49 g, and **this has not been tested** |
| Resin piece leaks or bulges weeks after printing | Uncured resin was trapped in the cavity. The drain hole was blocked by a support, or the part was cured before it drained. Check the STL is one shell and re-orient the supports (§2) |
| Board sags / won't stay level | Balance about the axis; check bearing seated; heavier wall anchors |
| Belt slips (Phase 2) | Tension it; increase wrap; verify pulley grub screw tight |

### `pivot_type = "pin"` only

| Symptom | Fix |
|---|---|
| Piece won't spin at all / stalls mid-swing | The piece is clamped between cap and hub. There should be **1.5 mm of axial float**: 11 mm of dowel proud, 6 mm of piece, 3.5 mm of cap grip. Check the dowel bottomed out on the magnet (11 mm proud, not 9), and back the cap off |
| Piece falls off the dowel | The cap grips by interference; tighten `cap_grip_fit` (more negative) or reprint the cap. On a *vertical* board gravity pulls the piece down the silhouette, not off the axle — a piece falling off means the cap is genuinely loose |
| A grey disc shows behind a piece | The Ø11.5 hub puck is peeking out from behind the silhouette. It is meant to be hidden by the piece's own waist. `familiar` clears it easily (its narrowest waist is the rook's 20 mm tower); `monolith` clears it by only 0.5 mm, so check `square_size` is 55 and that `MONO_SCALE` in [`styles/monolith.scad`](../hardware/styles/monolith.scad) is 1.222 — reducing either uncovers the puck |
| Piece drags/scratches when sliding | Thicker felt disc on the hub; clear-coat the sheet's paint |

### `pivot_type = "magnet"` only

| Symptom | Fix |
|---|---|
| **The steel disc walks off the magnet** | This is unproven behaviour, not a defect you introduced — nothing has ever verified the disc stays put through a flip. Check the disc is plain **solid** mild steel (not a washer with a hole, not stainless), and that the counterbore is clean and flat so the disc seats square. If it still walks, this architecture is answered: switch to `pivot_type = "pin"` |
| **Piece won't turn / creeps and sticks** | Likely the face friction this architecture's lean figures do **not** model: the disc presses the piece's whole back face onto the sheet under the magnet's full pull, so drag acts out at silhouette radii instead of at the 2.35 mm bore. Confirm on the coupon first (§1). Grease helps a little; if the coupon itself won't spin freely, the architecture is the problem, not your print |
| Piece drags/scratches the sheet when sliding | There is no felt disc here — the piece's own plastic back face slides on the paint. Clear-coat the sheet. How this wears is untested |
| Piece comes apart when lifted off the board | Expected. The sheet is what holds the sandwich together from behind; off the board it is three loose parts. Under `"pin"` the assembly stays together |
| Hall sensor (Phase 2) won't trip under a piece | The sensing magnet is a Ø4 × 5 here, not a Ø8 × 3. Whether that is enough has **not** been checked — test it on the board test tile before buying 64 sensors |
