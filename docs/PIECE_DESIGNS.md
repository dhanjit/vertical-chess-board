# Piece designs — the approaches, side by side

**This is the page to open when choosing what to print.** The piece design is
kept in the repo as **selectable variants**, not as one settled answer, so
competing approaches can be compared on measured numbers instead of argued
about. More approaches are expected to arrive; adding one is a new file and one
enum value, not a rewrite (see [Adding a new approach](#adding-a-new-approach)).

> ### ⚠ Nothing here has been printed
>
> Every number on this page is **measured off an exported mesh** — a model, not
> an object. The one input that decides how straight a piece hangs, the friction
> coefficient **μ**, is a *textbook* figure (0.08, greased steel on plastic) that
> has never been measured on this hardware. Lean scales **linearly** with μ: if
> the real value is double, so is every angle below. **One printed pawn plus one
> hub settles it** — Phase 0 in [`BUILD_GUIDE.md`](BUILD_GUIDE.md), and the
> cheapest experiment in the project.
>
> This page is a decision aid, not a recommendation. Each option is written with
> its costs attached.

---

## The two axes

The design varies along **two independent choices**. They do not know about each
other: no style file mentions a pivot, and no pivot code mentions a style. Any
combination builds.

```
   AXIS 1 = the rows (the artwork)      AXIS 2 = the columns (how it hangs)

                        "pin"                      "magnet"
                        magnet on the BOARD        magnet IN the piece
                        5 parts/piece              3 parts/piece
                      ┌──────────────────────────┬──────────────────────────┐
   "familiar"         │  THE DEFAULT TODAY       │  2 fewer parts/piece     │
   the look most      │  worst lean 1.44° (rook) │  worst lean 2.09° (rook) │
   people know        │  ✔ inside the 2.2° limit │  ✔ inside the 2.2° limit │
                      ├──────────────────────────┼──────────────────────────┤
   "monolith"         │  committed first         │  2 fewer parts/piece     │
   an invented        │  worst lean 1.81° (rook) │  worst lean 2.89° (rook) │
   design language    │  ✔ inside the 2.2° limit │  ✘ busts it on 3 of 6    │
                      └──────────────────────────┴──────────────────────────┘

    "lean" = how far off vertical a piece parks once friction stops it turning.
    2.2° is the working limit this repo designs to — see the caveat under
    "Read these numbers honestly".
```

**Axis 1 — piece style** is *artwork only*: what the silhouette looks like. One
file per style in [`hardware/styles/`](../hardware/styles/), each exposing the
same three symbols. A style file knows nothing about bores, magnets, hollowing
or thickness.

**Axis 2 — pivot architecture** is *mechanism only*: how the piece hangs and
turns. Built in
[`hardware/gravity_gimbal.scad`](../hardware/gravity_gimbal.scad), which owns
every dimension of the pivot, including what the piece body subtracts.

---

## How to switch

Two lines at the top of
[`hardware/common.scad`](../hardware/common.scad):

```scad
piece_style = "familiar";   // "monolith" | "familiar"   — the artwork
pivot_type  = "pin";        // "pin"      | "magnet"     — how it hangs
```

Change either, re-render, done. Everything downstream follows — the piece
bodies, the bore diameter, which pivot parts exist at all, and which STLs the
Makefile produces.

To build a combination **without editing the file** (useful for comparing):

```
cd hardware
make variant STYLE=familiar PIVOT=pin      # -> stl/familiar_pin/
make variant STYLE=monolith PIVOT=magnet   # -> stl/monolith_magnet/
make matrix                                # all four, side by side
```

Or one part at a time:

```
openscad -D 'PART="king"' -D 'piece_style="monolith"' -D 'pivot_type="magnet"' \
         -o king.stl pieces.scad
```

A typo fails loudly rather than rendering an empty part — an unknown
`piece_style` or `pivot_type` trips an assertion naming the bad value.

---

# Axis 1 — piece style (the artwork)

Both styles are **flat silhouettes**: a plate `piece_thk` = 6 mm thick,
extruded from a 2-D outline. That is a format shared by both, chosen because it
reads across a room, prints face-down with no supports, and keeps the swinging
mass low. What differs is the drawing.

Both are also **hollow above the pivot and solid below it**, with a 2 mm drain
hole through the back face — that is the mechanism in
[`pieces.scad`](../hardware/pieces.scad), applied identically to every style.
Neither style has a weight pocket and nothing is glued into either.

## "monolith" — an invented design language

*Lives in [`hardware/styles/monolith.scad`](../hardware/styles/monolith.scad).
This is what the repo committed first.*

**What it looks like.** One rule set, obeyed by all six pieces:

- **one slope** — every piece is a single straight-sided taper at 1 : 4
  (14.04° off vertical). No piece has its own angle.
- **one stroke width** — 4.4 mm is every deliberate line in the set: the pawn's
  crown radius, the king's cross limb and arm, the bishop's cleft.
- **one convex and one concave radius** — 0.8 mm rounds every outside corner,
  0.5 mm every inside one, applied globally. No corner is radiused by hand.
- **one shared foot** — the same 3.6 mm kick and 1.6 mm flare per side on all
  six; the flare is said exactly once, at the bottom.
- **rank reads twice** — as height, and as how far the taper ran before its one
  terminal event started.

| Piece | The one terminal event |
|---|---|
| **Pawn** | *None.* The taper runs into a dome that is tangent to it, so the outline never breaks. Identified by absence. |
| **Rook** | Three **square merlons** — a parapet, counted in the set's own units. |
| **Knight** | A head that **faces left** — the only broken mirror in the set. |
| **Bishop** | A **mitre**: a dome with one stroke-wide cleft driven through it, leaving two horns. |
| **Queen** | A **coronet** — four points, each finished with a rounded pearl. |
| **King** | A **cross**: one limb, one arm, both exactly one stroke wide. |

Queen and rook are separated by shape *and* by count: three square merlons
against four round pearls. Queen and king are separated structurally — both run
the taper down to the same narrow waist and jump out sideways, and the coronet
*is* the king's crossbar, only divided.

**Where it came from.** Designed for this board rather than borrowed: a
vocabulary small enough to be reverse-engineered from the finished set. The
artwork is drawn at *nominal* size and scaled by `MONO_SCALE` = 1.222 on the way
out — that scale factor is what let the taper's waist grow wide enough to hide
the Ø11.5 hub puck behind it, which is the reason the board settled on 55 mm
squares.

**Measured** (off the exported mesh, 55 mm squares, pivot architecture `"pin"`):

| Piece | Height | Width | Aspect | Lever `d` | Lean | Mass (resin) |
|---|---:|---:|---:|---:|---:|---:|
| Pawn | 31.77 | 20.74 | 0.653 | 5.71 | 1.49° | 2.24 g |
| Rook | 36.66 | 24.61 | 0.671 | 4.68 | **1.81°** | 3.43 g |
| Knight | 39.10 | 26.44 | 0.676 | 6.05 | 1.40° | 3.75 g |
| Bishop | 42.77 | 29.98 | 0.701 | 7.29 | 1.16° | 4.52 g |
| Queen | 46.44 | 25.34 | 0.546 | 5.72 | 1.48° | 4.23 g |
| King | 51.32 | 25.59 | 0.499 | 8.68 | 0.98° | 4.24 g |

All six: **one shell** (so every internal cavity is drained), pivot exactly on
the silhouette centre, standing inside its square.

**Good at**

- **Narrow.** Widest piece is the bishop at 29.98 mm in a 55 mm square. Pieces
  sit *in* their square with room around them, which is also what gives the set
  its clearance margin during a board flip (see [Sweep](#sweep-during-a-flip)).
- **Light.** 4.24 g for the king against the familiar king's 7.49 g — less mass
  hanging off the Ø8 magnet, less swinging inertia.
- **Coherent.** Nothing in the set is chosen by taste; every quantity is derived
  from the same handful of constants, so edits stay consistent.
- **The foot is the widest point of every piece** — verified on all six meshes —
  so nothing overhangs its own base.

**Bad at**

- **You have to learn it.** A player who has never seen the set has to work out
  which piece is which. Three square merlons vs four round pearls is a real
  distinction, but it is a *taught* one.
- **Higher lean on five pieces of six.** Smaller pieces put less area far below
  the pivot, which is exactly the lever `d`. Under `"pin"` it still clears the
  working limit everywhere; under `"magnet"` it does not (see
  [Where the two axes interact](#where-the-two-axes-interact)).
- **Its knight breaks its own rules.** The head uses free angles, outside the
  family's restricted set — a priced trade (the allowed angles contain no
  diagonal, so a jaw line is literally unbuildable inside a 32 mm piece), but a
  break nonetheless.
- **Its knight does not hang quite plumb.** As drawn it lands at **+0.06°**, not
  0.00 — the balance constant `KDX` = 1.67 was never re-solved to the last
  decimal. Small, and visible only if you look for it, but it is there and it is
  recorded in the file.

## "familiar" — the look most people already know

*Lives in [`hardware/styles/familiar.scad`](../hardware/styles/familiar.scad).
This is the `piece_style` default today.*

**What it looks like.** The vocabulary of an online chess board or a fridge
magnet set:

| Piece | The shape |
|---|---|
| **Pawn** | Plinth, collar, **ball body**, collar, ball head. |
| **Rook** | Plinth, waisted tower, corbel, **three equal crenellations**. |
| **Knight** | A **horse head**, facing left: muzzle jutting low and clear of the neck, jaw undercut over an open throat, eye set high and back, two rounded ears. |
| **Bishop** | Plinth, bulb, fat **mitre egg with a cross cut into it**, finial ball. |
| **Queen** | Plinth, vase, flared **coronet of five ball-tipped points**, graded tallest in the centre. |
| **King** | Plinth, vase, flared crown with two lobes, and a **cross** rising between them. |

**Where it came from.** This is the look asked for: nobody has to be taught what
any of these is. Unlike "monolith" it is drawn **at final size** — there is no
scale factor, what is written in the file is what gets printed.

Internally it uses two drawing languages on purpose. Five pieces are hulls of
circles, half-drawn and mirror-unioned, so they are *exactly* symmetric by
construction and hang plumb with no tuning. The knight is a polygon softened by
a global rounding pass; it is the one asymmetric piece.

**Measured** (same conditions — exported mesh, 55 mm squares, pivot `"pin"`):

| Piece | Height | Width | Lever `d` | Lean | Mass (resin) |
|---|---:|---:|---:|---:|---:|
| Pawn | 40.00 | 30.00 | 7.34 | 1.16° | 3.79 g |
| Rook | 43.00 | 38.00 | 5.89 | **1.44°** | 6.11 g |
| Knight | 44.50 | 40.47 | 7.51 | 1.13° | 6.49 g |
| Bishop | 47.50 | 36.00 | 9.02 | 0.94° | 5.64 g |
| Queen | 50.00 | 41.80 | 7.55 | 1.12° | 7.17 g |
| King | 52.00 | 42.00 | 8.59 | 0.99° | 7.49 g |

All six: one shell, pivot exactly centred, inside its square. (The knight is
drawn to 40.5 mm wide and measures 40.47 on the mesh.)

**Good at**

- **Instantly readable.** No learning curve, for anyone.
- **Straighter hang on five pieces of six.** Bigger pieces put more area further
  below the pivot, and that *is* `d`. Best in the set is the bishop at 0.94°.
- **More margin against friction being worse than assumed.** Its worst piece
  (rook, 1.44°) sits further under the 2.2° limit than monolith's worst
  (1.81°), so it tolerates a higher real μ before anything breaks.
- **Buries the hub puck easily.** The rook's 20 mm waist — its narrowest
  feature at the pivot — hides the Ø11.5 puck twice over, where monolith clears
  it by 0.5 mm.

**Bad at**

- **Wide.** The pieces fill their square rather than sitting in it. The **knight
  (40.47 mm) is wider than the bishop (36) and the rook (38)** — that one is
  structural, not taste: its symmetric foot has to out-reach the muzzle so the
  pivot stays on the bounding-box centre, which is what keeps the piece centred
  through a flip.
- **Sweeps well past its square.** See [Sweep](#sweep-during-a-flip) — this is
  the most consequential cost of the choice.
- **Heavier.** King 7.49 g against monolith's 4.24 g, hanging 11 mm proud of the
  wall. Whether the Ø8 magnet holds that is **unchecked**.
- **Its knight's balance is tuned, not structural** — same fragility as
  monolith's (below), though as drawn it does hang at 0.00°.

## Both knights are fragile in the same way

Five pieces in each set are mirror-symmetric, so their centre of mass is on the
centreline for free. Each knight is not. Each hangs plumb only because a
constant — `KDX` in its own style file — slides the head sideways until the
moment about the centreline cancels. That balance is **solved numerically, not
guaranteed structurally**.

> **Edit either knight's head and the piece will still render perfectly, still
> pass the single-shell check, still look right — and hang permanently
> rotated.** No amount of friction tuning fixes it, because it is not a lean; it
> is where "down" now is for that shape. If you touch a head polygon, re-measure
> the centre of mass and re-solve `KDX`.

## Sweep during a flip

"Fits in its square" means *standing upright*. A piece that is still turning
sweeps a **circle** of its longest corner, which is bigger. Measured radius from
the pivot to the furthest point of the silhouette, against a **27.5 mm**
half-square:

| | pawn | rook | knight | bishop | queen | king |
|---|---:|---:|---:|---:|---:|---:|
| **familiar** | 24.44 | 28.12 | 29.42 | 29.24 | 31.45 | **32.85** |
| **monolith** | 18.60 | 21.70 | 23.22 | 25.73 | 26.10 | **28.34** |

Crossing the square line is **not by itself a collision**, and it is worth being
precise about why, because the reasoning is what carries the familiar set:

| Case | The bound | familiar | monolith |
|---|---|---|---|
| Both pieces upright, or turning **in step** | none needed — neighbours ride one rigid board and each stays upright in the room's frame, so they never move relative to each other | safe | safe |
| One piece **lags**, its neighbour upright | that piece's sweep + the neighbour's half-width ≤ 55 mm | worst legal pair king + queen = 32.85 + 20.90 = **53.75** → 1.25 mm margin | worst legal pair king + bishop = 28.34 + 14.99 = **43.33** → 11.67 mm margin |
| **Both** lag at once | sweep + sweep ≤ 55 mm | 32.85 + 31.45 = **64.30** → ✘ fails | 28.34 + 26.10 = **54.44** → 0.56 mm margin |

**Nothing has tested whether pieces stay in step through a flip.** If they do
not, that is a concrete argument for the monolith set — and it is the one place
where the artwork choice is also a mechanical choice.

---

# Axis 2 — pivot architecture (how the piece hangs)

Both architectures do the same job: hold the piece on a vertical steel face and
let it rotate freely about an axis pointing out of the wall. They differ in
**where the magnet lives**, and that single choice decides everything else.

> **Jargon, plainly.** A **dowel pin** is a plain ground-steel rod, sold by the
> hundred in any fastener shop. A **press fit** means the hole is cut slightly
> *undersize*, so the pin is held by friction alone — no glue, no thread. A
> **counterbore** is a shallow flat-bottomed recess cut around a hole, so
> something can sit down inside the surface instead of proud of it.

## The physics, so the costs below mean something

A hanging piece does **not** park perfectly upright. It parks where friction
cancels gravity:

```
        sin(lean)  =  μ · r / d

          μ   friction coefficient in the bore      assumed 0.08
          r   bore RADIUS                           1.85 mm ("pin") | 2.35 mm ("magnet")
          d   how far the centre of mass sits
              BELOW the pivot                       4.7 – 9.0 mm across both styles
```

Two consequences drive the whole comparison:

1. **Mass cancels out.** Weight appears on both sides of the torque balance and
   divides away. Adding ballast to a piece does *nothing* for how straight it
   hangs. This is the least intuitive fact in the project.
2. **Except mass added *at* the pivot.** It contributes no restoring torque, but
   it does drag the combined centre of mass toward the axis and shrink `d`.
   That is exactly the `"magnet"` architecture's second cost, and it is why the
   two architectures do not measure the same.

## `pivot_type = "pin"` — the magnet stays on the board

```
   FRONT — faces the room
     ┌──────────────┐
     │  press cap   │  Ø6 × 4.7 mm    PRINTED   grips the dowel tip on three
     └──────┬───────┘                           slit fingers; stops the piece
            │                                   falling off, still lets it spin
     ┌──────┴───────┐
     │  PIECE BODY  │  6.0 mm thick   PRINTED   Ø3.70 bore — THIS is what turns
     └──────┬───────┘
     ┌──────┴───────┐
     │   hub puck   │  Ø11.5 × 8 mm   PRINTED   sticks to a square, turns WITH
     ├──────────────┤                           the board, slides square to
     │    magnet    │  Ø8 × 3 mm      bought    square
     └──────────────┘
   ═══════════ steel sheet, 0.8 mm ═══════════   (+ a felt disc over the magnet
   BACK — the wall                                face, to set the glide)

   the axle:  Ø3 × 16 mm STEEL DOWEL PIN, bought — 5 mm pressed into the hub
              (bottoming out on the magnet, so there is no thin printed web to
              crack), 11 mm standing proud through body 6.0 + cap grip 3.5
              →  1.5 mm of DELIBERATE axial float, so print tolerance cannot
                 clamp the piece between cap and hub and stall the rotation
```

**Parts per piece**

| | Printed | Bought |
|---|---|---|
| **"pin"** | hub puck, piece body, press cap — **3** | Ø8 × 3 magnet, Ø3 × 16 steel dowel — **2** (+ felt disc) |

**For a full 32-piece set: 96 printed parts and 64 bought ones**, plus felt.

**What it costs and what it buys**

- The magnet's mass is on the **board**, so it never enters the pendulum at all.
  `d` is purely the piece's own geometry.
- `r` is small: a Ø3 dowel in a Ø3.70 bore, so `r` = 1.85 mm. Because `r` is the
  entire numerator of the lean equation, the Ø4 → Ø3 change alone was worth ~19%
  less lean for free.
- The dowel is **bought steel, not printed**. Ground steel on plastic is roughly
  half the friction of printed-on-printed, and it is *stronger*: a Ø3 steel
  dowel takes a 20 N sideways knock with 3.0× margin where the Ø4 printed post it
  replaced had 1.29× — it snapped at the layer line.
- **Worst lean: 1.44°** (familiar rook) / **1.81°** (monolith rook).

**What is unproven**

- **μ itself** — the same open question either way, and the reason for Phase 0.
- **Print orientation and overhangs** on the cap's three fingers.
- Whether the Ø8 magnet holds the heaviest piece (familiar king, 7.49 g,
  hanging 11 mm proud of the wall).
- The cap is the one part of the mechanism that **faces the room**, sitting
  mid-piece. Ø6 is chosen so it disappears into the waist; nobody has looked at
  a printed one.

## `pivot_type = "magnet"` — the magnet rides in the piece

```
   FRONT — faces the room
     ┌──────────────────┐
     │  retaining disc  │  Ø9 × 0.8 mm   bought   held by the magnet, NO GLUE,
     ├──────────────────┤                         sunk in a 1.0 mm counterbore
     │   PIECE BODY     │  6.0 mm        PRINTED  Ø4.70 bore — the piece turns
     │        ┌──────┐  │                         ON THE MAGNET; the magnet is
     │        │magnet│  │  Ø4 × 5 mm     bought   the journal. Drops in from the
     └────────┴──────┴──┘                         BACK, finishes flush
   ═══════════ steel sheet, 0.8 mm ═══════════
   BACK — the wall

   NO hub puck.  NO dowel.  NO press cap.  Nothing printed but the piece.
   The disc is wider than the bore, so it cannot pass through it — that, and
   only that, is what stops the piece pulling off the magnet.
```

**Parts per piece**

| | Printed | Bought |
|---|---|---|
| **"magnet"** | piece body — **1** | Ø4 × 5 magnet, Ø9 × 0.8 steel disc — **2** |

**For a full 32-piece set: 32 printed parts and 64 bought ones.**

> **A note on the headline count.** Count components, not headlines: `"pin"` is
> **5** per piece (3 printed + 2 bought) and `"magnet"` is **3** (1 printed +
> 2 bought). The architecture removes three named parts (hub, dowel, cap) and
> adds one (the retaining disc), so the net saving is **two**, not three — a
> "three fewer parts" claim anywhere is counting the removals and forgetting the
> arrival. Where the saving really lands is printing: **printed parts per piece
> go 3 → 1**, i.e. 96 → 32 across a 32-piece set, and the whole hub-and-cap
> assembly step disappears. `common.scad` and `gravity_gimbal.scad` state the
> same breakdown at each `pivot_type`.

**What it costs, measured**

It costs on two fronts, and both are in the numbers:

- **`r` grows.** The bore is now Ø4.70 around the magnet instead of Ø3.70 around
  the pin, so `r` goes 1.85 → 2.35 mm.
- **`d` shrinks.** The magnet (~0.47 g) and the disc (~0.40 g) ride **with** the
  piece at exactly zero lever arm, dragging the combined centre of mass toward
  the axis. On the lightest piece in either set (monolith pawn, 2.24 g) that
  0.87 g is **28% of the assembled mass**, sitting exactly where it does no good
  at all. On the familiar king (7.49 g) it is 10%, which is why the penalty
  lands harder on the smaller style.

| Style | pawn | rook | knight | bishop | queen | king |
|---|---:|---:|---:|---:|---:|---:|
| familiar, `"pin"` | 1.16° | 1.44° | 1.13° | 0.94° | 1.12° | 0.99° |
| familiar, `"magnet"` | 1.80° | **2.09°** | 1.62° | 1.37° | 1.60° | 1.40° |
| monolith, `"pin"` | 1.49° | 1.81° | 1.40° | 1.16° | 1.48° | 0.98° |
| monolith, `"magnet"` | **2.61°** | **2.89°** | 2.19° | 1.75° | **2.27°** | 1.49° |

Roughly **+0.4 to +0.6°** on the familiar set; **+0.5 to +1.1°** on the smaller
monolith set, where there was less `d` to lose in the first place.

(A Ø5 magnet was modelled too and is worse on both counts — familiar pawn 2.27°,
king 1.73°. **Ø4 is the choice.**)

**What is unproven** — and none of it is in the numbers above:

1. **Does the disc stay on?** Nothing has verified that a Ø9 steel disc stays
   put on a Ø4 magnet through a board flip. If it walks off, the piece comes off
   the board.
2. **Does the piece still turn?** The disc bears on the counterbore floor and
   therefore presses the piece's **whole back face** onto the steel sheet with
   the magnet's full pull. Rotation then has to overcome **face** friction out
   at silhouette radii, not just bore friction at r = 2.35 mm. **Every lean
   figure for `"magnet"` models bore friction only and is therefore
   optimistic.** How much is unquantified — no number has been invented for it.
   Under `"pin"` the piece bears on the hub puck's Ø11.5 face under its own
   weight only, so the objection does not apply there.
3. **The counterbore eats into a thin piece.** The seat plus its wall is a Ø11.4
   collar in a 6 mm plate. The narrowest thing either style puts at the pivot is
   the monolith king's 12.1 mm waist — 0.7 mm to spare. A future style with a
   narrower waist at the pivot cannot use this architecture as drawn.

**The cheap test that settles 1 and 2.** Under `pivot_type = "magnet"` there are
no printed pivot parts, so `make gimbal` renders a **pivot test coupon**
instead: a Ø16 × 6 disc carrying exactly the bore and the disc seat and nothing
else. Press a magnet in, stick the disc on, put it on a steel sheet, flip it,
and try to turn it with a fingertip. About 2 g of plastic answers both
questions.

---

## Where the two axes interact

They are independent **in the code** — you can build any of the four. They are
not independent **in the outcome**:

> **`monolith` + `magnet` is the one combination of four that busts the 2.2°
> working limit** — on three pieces of six (rook 2.89°, pawn 2.61°, queen
> 2.27°), with the knight 0.01° under it at 2.19°. Four of the six are at or
> within a hundredth of the limit; only the bishop and king have real margin.

The reason is structural, not incidental. The monolith pieces are smaller, so
`d` is smaller; the `"magnet"` architecture's penalty is roughly a fixed
subtraction from `d`; a fixed subtraction hurts a small number more. If a future
style is *smaller* than monolith, expect the same result, and check it before
printing rather than after.

---

## Read these numbers honestly

- **Nothing has been printed.** Every figure on this page is measured off an
  exported mesh.
- **Lean assumes μ = 0.08**, a textbook figure for greased steel on plastic,
  never measured on this hardware. It scales the whole table linearly.
- **The 2.2° "working limit" is a threshold this repo adopted, not a derived or
  measured one.** It is the number the Phase-0 test in
  [`BUILD_GUIDE.md`](BUILD_GUIDE.md) checks against; treat it as a convention
  everyone is being honest about, not as physics.
- **The rook is the piece to watch in both styles.** Crenellation is by
  definition a lot of area high above the pivot, so it has the shortest lever
  and the highest lean in each set. If real friction comes in worse than
  assumed, the rook breaks first.
- **Both knights' balance is tuned via a constant, not structural.**
- **`"magnet"` has two unproven claims** (disc retention, face friction), and
  its lean figures are optimistic because they model bore friction only.
- **Unchecked in every combination:** print orientation, overhangs, and whether
  the Ø8 hub magnet holds the heaviest piece.
- **Internal consistency was checked.** All 24 lean figures reproduce from
  `sin(lean) = μ · r / d` with a single set of constants, and the `"magnet"`
  rows additionally reproduce from the `"pin"` rows under the mass-shift model
  (`d′ = d · m / (m + 0.87 g)`), to within 0.01°. That confirms the tables are
  coherent — it does **not** confirm they describe reality.

---

## Adding a new approach

The whole point of this structure is that the next idea is a new file and one
enum value — there are two styles and two pivot architectures today, and nothing
in the code caps either number.

### A new piece style

**Two edits.**

1. **Drop one file in `hardware/styles/`**, e.g. `artdeco.scad`, exposing
   exactly three public symbols:

   ```scad
   // styles/artdeco.scad
   module   artdeco_silhouette2d(t) { ... }   // 2D artwork at FINAL SIZE,
                                              //   base on y = 0, apex at y = pheight
   function artdeco_pheight(t)      = ...;    // that height, in real printed mm
   function artdeco_drains(t)       = [...];  // back-face drain points [[x, y], ...],
                                              //   one per connected cavity region
   ```

2. **Add four lines to the `THE ENUM` block in
   [`pieces.scad`](../hardware/pieces.scad)** — one `use <styles/artdeco.scad>`
   and one branch in each of the three dispatchers — and the style's name to the
   `piece_style` comment in `common.scad`.

Nothing else in the project changes. No mechanism knows a style by name, and no
style knows anything about bores, magnets, hollowing or thickness.

**Two things to know before you draw:**

- **The public names are prefixed on purpose.** OpenSCAD has no namespaces and
  no dynamic `include`, so `pieces.scad` has to `use` every style file at once —
  identically-named modules would silently override each other. Only the three
  *public* names must be unique. Everything private is safe: a used file's
  modules resolve helpers in their own file's scope, so two styles can both
  define `foot()` with different values and neither interferes. (Verified by
  test, not assumed.) A new style's internal vocabulary is completely
  unconstrained.
- **The one size rule the mechanism imposes:** a piece hangs `pivot_frac × H`
  below the axle and the axle is the square centre, so every style must keep
  `pivot_frac × H ≤ square_size / 2`, i.e. **H ≤ 55 mm** with a little to spare
  for the swing.

**Then check four things** before believing it (this is what the existing tables
mean):

1. **One shell** per piece in the exported STL — OpenSCAD reports `Volumes: 2`
   for a single piece (outer space + one solid). A cavity the drain missed shows
   up as `Volumes: 3`, and `Simple: yes` will *not* catch it.
2. **Pivot on the silhouette centre** on both axes, or the piece drifts
   off-square during a flip.
3. **Hang offset 0.00°** — the centre of mass directly below the pivot. Free for
   a mirror-symmetric piece; solved numerically otherwise, and fragile
   thereafter.
4. **Sweep radius** from the pivot, against the 27.5 mm half-square and against
   the neighbour cases in [Sweep](#sweep-during-a-flip).

### A new pivot architecture

Same shape of change, in
[`gravity_gimbal.scad`](../hardware/gravity_gimbal.scad), which owns *all* pivot
geometry so `pieces.scad` never repeats the arithmetic. Add a branch to each of:

| Function / module | What it must return or cut |
|---|---|
| `pivot_bore_dia()` | the bore the piece turns in — this is `2r` in the lean equation |
| `body_pivot_cut()` | everything subtracted from the piece body at the pivot |
| `pivot_cavity_keepout()` | solid the lightening cavity must not eat into (empty is a valid answer — it is, under `"pin"`) |
| the render dispatch at the bottom | whatever this architecture actually has to print (`"magnet"` has no pivot parts at all, so it renders a test coupon) |

Then add the name to the `pivot_type` comment in `common.scad` and to `PIVOTS`
in the [`Makefile`](../hardware/Makefile) so `make matrix` picks it up.

**Quote its cost the same way**: the bore radius `r`, the mass it adds *at* the
pivot (which shrinks `d`), the part count printed and bought, and — separately
and explicitly — whatever it has **not** proven.

---

## What would settle this

The choice does not have to be made from this page. Three cheap experiments
would move it from modelling to measurement:

| Test | Cost | What it settles |
|---|---|---|
| **One pawn + one hub** (`pivot_type = "pin"`) — stick to any steel, hold vertical, flip ten times, note the worst lean | ~1 evening | **μ**, which scales every number on this page. This is Phase 0 and it comes first. |
| **The pivot coupon** (`pivot_type = "magnet"`, `make gimbal`) — magnet in, disc on, flip, then try to turn it | ~2 g of plastic | Both of the `"magnet"` unknowns: does the disc stay on, and does the piece still turn once its back face is clamped to the sheet. |
| **One king in each style**, held at arm's length across a room | 2 prints | The readability question, which is the *only* part of the axis-1 choice that numbers cannot answer. |

Record what comes back in [`GOALS.md`](GOALS.md), including the measured μ.

---

## See also

- [`../hardware/README.md`](../hardware/README.md) — how to render these to STL,
  print notes, and the same tables from the printer's point of view.
- [`DESIGN.md`](DESIGN.md) — how the two board mechanics work, the physics in
  context, and the sensing/rotation design around the pieces.
- [`BUILD_GUIDE.md`](BUILD_GUIDE.md) — Phase 0, the test that settles μ.
- [`GOALS.md`](GOALS.md) — the roadmap and the decision log (D1–D11).
- [`../hardware/common.scad`](../hardware/common.scad) — the two selector lines
  and every dimension either axis depends on.
