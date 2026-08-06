# Build Guide

Step-by-step for **Phase 1** (the manual wall board) with pointers to later
phases. Read [`DESIGN.md`](DESIGN.md) first for the "why."

> **Read this before you trust a number below.** Nothing in this repo has been
> built or printed yet. Every dimension and every angle quoted here is measured
> off a computer model, not off an object. The whole point of Phase 0 (§1) is to
> turn the cheapest of those numbers into a real one before you commit to a set.

## 0. Before you print

1. Install [OpenSCAD](https://openscad.org).
2. Open [`hardware/common.scad`](../hardware/common.scad). The board size is now
   **locked at `square_size = 55`** — this resolves decision **D1**. It is not a
   taste call: the hub puck behind each piece is a fixed Ø11.5 disc, and the
   piece has to *hide* it or every piece wears a visible grey collar. Only the
   artwork scales with the square, not the mechanism, so a bigger square grows
   the piece's taper until its natural waist (Ø12.0) swallows the puck. 55 mm is
   the smallest square where that happens — with 0.5 mm to spare. The panel ends
   up ~490 mm square.
   What you *should* still check against what you actually bought:
   - `magnet_dia` / `magnet_thk` — the magnets you ordered (default Ø8 × 3),
   - `sheet_thk` — the steel sheet you'll order,
   - `bearing_od` / `bearing_id` — your lazy-susan bearing.
3. Buy, don't print, the axles: **stock Ø3 × 16 mm steel dowel pins**, one per
   piece plus spares. ("Dowel pin" is the hardware-shop name for a short ground
   steel rod, sold by the bag.) A printed post was tried and dropped — see the
   `axle_dia` note in [`common.scad`](../hardware/common.scad) for the numbers.
4. From `hardware/`, render everything:
   ```
   make            # all STLs into hardware/stl/
   make FN=128     # smoother, for final parts
   ```
   Or render individually, e.g. `make pieces`, or
   `openscad -D 'PART="king"' -o king.stl pieces.scad`.

## 1. Prototype the mechanics (Phase 0 — do this first!)

Cheap insurance before printing 32 pieces. **Test the pawn** — it is the
smallest, quickest, cheapest print in the set, and what you are really measuring
is `mu`, which is a property of the *pivot*, not of the piece. Measure the
pawn's lean, divide out its modelled 1.49°, and you have the factor that scales
every other piece's number.

Note the pawn is **not** the worst case: it is the shortest *piece*, but not the
one with the shortest *lever*. The squat **rook** carries the shortest lever
(`d` = 4.68 mm) and therefore the largest modelled lean (1.81°) — see the table
in §2. If you want the worst case on the bench as well, print a rook too; it is
the piece that runs out of margin first.

### What you are actually testing

A hanging piece does not park perfectly upright. It stops wherever friction in
its bore cancels the pull of gravity:

```
sin(lean) = mu * r / d

  mu = friction coefficient in the bore  (~0.08 assumed: greased steel on plastic)
  r  = bore radius                       (1.85 mm — a Ø3.70 bore on a Ø3 dowel)
  d  = how far the centre of mass sits BELOW the pivot  (4.7-8.7 mm across the set)
```

**Mass cancels out of that equation completely.** Adding weight to a piece does
nothing at all for how straight it hangs — which is why there is no ballast
anywhere in this design any more (see §4). Only geometry and friction move the
number, and geometry is already fixed. So `mu` is the one unknown, `mu = 0.08`
is a textbook figure nobody has measured on this hardware, and **one printed
pawn plus one hub settles it.** That is the cheapest experiment in the project.

A second consequence of the same physics: a piece hangs with its centre of mass
directly below the pivot, so an asymmetric silhouette has to be balanced
left-to-right or it hangs permanently rotated. Only the knight is asymmetric —
see the warning in §2.

### Do it

1. `make gimbal` → prints one **hub puck + press cap** side by side
   (`gimbal_testpair.stl`).
2. `make pieces` → print **one pawn** (`stl/piece_pawn.stl`). Print it in
   whatever is cheapest. Because the piece is one single material with no
   ballast in it, density cancels out of the settling equation and a cheap PETG
   or PLA test print behaves *identically* to the final resin part. (That is the
   whole reason the ballast was removed.)
3. Assemble it — five steps, no glue except optionally on the magnet:
   1. **Magnet into the hub's back.** The Ø8 × 3 magnet drops into the cavity
      on the hub's flat back face (the one that will face the wall). It is
      dimensioned as a press fit; add a drop of super glue if your printer runs
      loose. Keep the polarity consistent across every hub — mark one face.
   2. **Dowel into the hub's front.** Press a **Ø3 × 16 steel dowel** into the
      bore on the other face until it **bottoms out on the back of the magnet**.
      That is deliberate: the two cavities meet in the middle of the 8 mm puck,
      so there is no thin printed web for the dowel to crack through and the
      dowel cannot creep deeper later. **11 mm should stand proud.**
   3. **Felt disc** over the magnet on the back face. It sets the glide across
      the board and protects the sheet's paint.
   4. **Grease the piece's bore.** A smear of **silicone damping grease** inside
      the hole through the pawn. Viscous grease is doing two jobs — read the
      "rings for ages" row in [Troubleshooting](#troubleshooting) before you
      decide it needs *less* friction.
   5. **Slide the piece on, press the cap on.** The pawn drops over the dowel
      and spins freely; the Ø6 cap grips the plain dowel by interference and
      stops it falling off. Push the cap on until it is snug, not until it
      clamps — the design leaves **1.5 mm of deliberate axial float** (11 mm of
      dowel against 6 mm of piece plus 3.5 mm of cap grip) precisely so print
      tolerances can't squeeze the piece still.

   **There is no ballast step.** Nothing is glued into the piece. Bottom-
   heaviness is shaped in: the piece is solid below the pivot and hollow above
   it, and that cavity is modelled into the part.
4. Stick the hub to any **steel** surface held vertically. It should **hold**,
   **stay upright**, and still look **centred in its square** after you rotate
   the surface. Flip it ten times and note the worst lean off vertical. **This
   is the one number the design is not sure of.** Compare it against the 1.49°
   modelled for the pawn:
   - roughly 1.5° → the friction budget is real; the whole set is good.
   - up to ~2.2° → still inside the working limit the set was designed to, but
     the rook has no margin left (see §2). Proceed, watch the rook.
   - much worse → real `mu` is higher than assumed. Fix it at the pivot, not
     with weight: more/better grease first, then check the dowel is genuinely
     steel and the bore isn't stringy or under-sized. Adding mass will not help,
     ever.
5. *(Optional)* Print the **board test tile** (`make board_test`), glue any
   steel offcut on its face, and check the magnet holds & slides square to
   square nicely (the felt disc tames the drag), and (Phase 2) that a hall
   sensor in the rear bore trips under a piece.

**Exit criteria:** the pawn holds on vertical steel, stays upright when you
rotate the steel by hand, settles within a couple of degrees, stops swinging in
a second or two, and still looks centred in its square afterwards.

## 2. Print the set

### The set as modelled (55 mm squares, `piece_scale` 1.222)

| Piece | Height | Width | Aspect | Modelled lean | Mass (resin) |
|-------|-------:|------:|-------:|--------------:|-------------:|
| Pawn   | 31.77 mm | 20.74 mm | 0.653 | 1.49° | 2.24 g |
| Rook   | 36.66 mm | 24.61 mm | 0.671 | **1.81°** | 3.43 g |
| Knight | 39.10 mm | 26.44 mm | 0.676 | 1.40° | 3.75 g |
| Bishop | 42.77 mm | 29.98 mm | 0.701 | 1.16° | 4.52 g |
| Queen  | 46.44 mm | 25.34 mm | 0.546 | 1.48° | 4.23 g |
| King   | 51.32 mm | 25.59 mm | 0.499 | 0.98° | 4.24 g |

All six: single shell (every cavity drained), pivot exactly centred, balanced
left-to-right, inside the square.

**Read those numbers honestly:**

- **Nothing has been printed.** Every figure is measured off an exported mesh.
- **Lean assumes `mu = 0.08`** — textbook, not measured. Lean scales linearly
  with `mu`: if the real friction is double, so is every angle in the table.
  Phase 0 (§1) is what settles this.
- **The rook has the least margin** — 1.81° against the 2.2° working limit the
  set is designed to. It is the piece that breaks first if real friction is
  higher than assumed.
- **The knight's balance is tuned, not structural.** Its head is the set's one
  deliberate exception to the shared angle language, and it hangs plumb only
  because of a hand-solved constant (`KDX`) in
  [`pieces.scad`](../hardware/pieces.scad) that slides the head sideways until
  the piece balances. **Edit the knight's head and it will still render
  perfectly, still look right, and then hang permanently rotated.** If you touch
  that polygon you must re-measure and re-solve `KDX`.
- **Unchecked:** print orientation, overhangs, and whether the Ø8 magnet
  actually holds the heaviest piece (bishop, 4.52 g, hanging 11 mm proud of the
  wall). Phase 0 tests the pawn's *lean*; it does not test the bishop's *grip*.

### What to print

- **Pieces:** print `piece_*` in your two colors. Counts per side: 8 pawns,
  2 knights, 2 bishops, 2 rooks, 1 queen, 1 king (+ a spare queen for
  promotions is handy). Every piece also needs one hub, one magnet, one felt
  disc, one Ø3 × 16 dowel and one cap — so 32 of each, plus spares. Print a few
  extra hubs and caps; they are small.
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
  what a player reads from across the room — and sanding scars out of a 0.8 mm
  corner radius will visibly ruin the outline. Every support goes on the back.
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

Same five steps as the Phase-0 pawn in §1, once per piece — 32 times.

1. Press a **magnet** into the hub's **back** (consistent polarity — mark a
   face; a drop of super glue if it is loose).
2. Press a **Ø3 × 16 steel dowel** into the hub's **front** bore until it
   **bottoms on the magnet**. 11 mm stands proud.
3. Stick a **felt disc** over the magnet (glide + paint protection).
4. Smear **silicone damping grease** in the *piece's* bore.
5. **Slide the piece onto the dowel** and **press the cap on** — snug, not
   clamped. The 1.5 mm of axial float is intentional.

**There is no ballast step and there is no weight pocket.** Older versions of
this guide had you glue lead or M3 nuts into a base pocket; that is gone.
Bottom-heaviness is now shaped into the part — solid below the pivot, hollow
above it — which removes a glue step, removes a part, and (because the piece is
then one single material) makes a cheap test print behave exactly like the final
one. It also would not have helped: mass cancels out of the settling equation.

Spin-test each piece: it should rotate freely, settle upright, and sit centred
in its square. The pivot is on the piece's own bounding-box centre, so however
it settles it **rotates in place** rather than drifting sideways — a piece that
looks off-centre means the hub is off-centre, not the piece.

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

| Symptom | Fix |
|---|---|
| **Piece rings for ages after a board flip** | **Thicker grease — not less friction.** This is the counter-intuitive one, so read it twice: friction is what *stops* the swing, so a near-frictionless pivot rings longest. A piece on a ball bearing would swing for minutes. Silicone damping grease adds *viscous* drag (which kills the ringing) without adding the *static* friction that causes the row below. Dry PTFE lube is exactly the wrong move — it removes the damping you want and leaves the stiction you don't |
| Piece parks a few degrees off vertical | This is friction, not balance: `sin(lean) = mu · bore_radius / lever`. **Mass cancels out — adding weight does nothing**, which is why there is no ballast to adjust. In order: more/better silicone damping grease; confirm the axle really is a Ø3 **steel** dowel and not a printed post; check the bore isn't stringy, over-cured or under-size (it should be Ø3.70); check the cap isn't clamping the piece against the hub |
| Piece won't spin at all / stalls mid-swing | The piece is clamped between cap and hub. There should be **1.5 mm of axial float**: 11 mm of dowel proud, 6 mm of piece, 3.5 mm of cap grip. Check the dowel bottomed out on the magnet (11 mm proud, not 9), and back the cap off |
| Piece hangs low or off-centre in its square | Confirm `pivot_frac` is 0.50 and that the **hub** is on the square's centre. A piece pivoted on its own centre cannot drift — if it looks like it did, one of those two is wrong |
| **The knight** hangs permanently rotated | Its balance is tuned by the `KDX` constant in [`pieces.scad`](../hardware/pieces.scad), not by structure. If anyone edited the knight's head polygon, `KDX` must be re-solved — the piece renders and prints perfectly either way, so nothing else will warn you |
| A grey disc shows behind a piece | The Ø11.5 hub puck is peeking out. It is meant to be hidden by the piece's own waist with 0.5 mm to spare, so check `square_size` is 55 and `piece_scale` is 1.222 — reducing either uncovers the puck |
| Piece falls off the dowel | The cap grips by interference; tighten `cap_grip_fit` (more negative) or reprint the cap. Note that on a *vertical* board gravity pulls the piece down the silhouette, not off the axle — a piece falling off means the cap is genuinely loose |
| Magnet won't hold on the vertical face | Bigger/stronger magnet, thinner felt disc, confirm the sheet is ferromagnetic steel (not stainless 304). The heaviest piece is the bishop at 4.52 g, and **this has not been tested** |
| Piece drags/scratches when sliding | Thicker felt disc on the hub; clear-coat the sheet's paint |
| Resin piece leaks or bulges weeks after printing | Uncured resin was trapped in the cavity. The drain hole was blocked by a support, or the part was cured before it drained. Check the STL is one shell and re-orient the supports (§2) |
| Board sags / won't stay level | Balance about the axis; check bearing seated; heavier wall anchors |
| Belt slips (Phase 2) | Tension it; increase wrap; verify pulley grub screw tight |
