# Build Guide

Step-by-step for **Phase 1** (the manual wall board) with pointers to later
phases. Read [`DESIGN.md`](DESIGN.md) first for the "why."

## 0. Before you print

1. Install [OpenSCAD](https://openscad.org).
2. Open [`hardware/common.scad`](../hardware/common.scad) and set:
   - `square_size` (45 default; 55–60 for a statement piece),
   - `magnet_dia`/`magnet_thk` to the magnets you bought,
   - `sheet_thk` to the steel sheet you'll order,
   - `bearing_od`/`bearing_id` to your lazy-susan bearing.
3. From `hardware/`, render everything:
   ```
   make            # all STLs into hardware/stl/
   make FN=128     # smoother, for final parts
   ```
   Or render individually, e.g. `make pieces`, or
   `openscad -D 'PART="king"' -o king.stl pieces.scad`.

## 1. Prototype the mechanics (Phase 0 — do this first!)

Cheap insurance before printing 32 pieces.
1. `make gimbal` → print one **hub + cap**; press an 8×3 magnet into the hub.
2. Print **one king** (`make pieces` then just use `piece_king.stl`); **glue**
   two stacked **M3 nuts** (or a ~6 mm steel ball) into its base pocket —
   the pocket opens at the back face; a dab of super glue holds the weight —
   then slide the body onto the hub post and snap the cap on.
3. Stick it to any **steel** surface held vertically. It should **hold** and
   **stay upright** when you rotate the surface. Tune (all in
   `hardware/common.scad`):
   - swings sluggishly / won't turn → increase `axle_fit`, add PTFE lube;
   - won't self-right → heavier base weight, or raise `pivot_frac`;
   - falls off → bigger magnet (`magnet_dia`) or thinner felt disc.
4. *(Optional)* Print the **board test tile** (`make board_test`), glue any
   steel offcut on its face, and check the magnet holds & slides square to
   square nicely (a felt disc on the hub tames the drag), and (Phase 2) that
   a hall sensor in the rear bore trips under a piece.

## 2. Print the set

- **Pieces:** print `piece_*` in your two colors. Counts per side: 8 pawns,
  2 knights, 2 bishops, 2 rooks, 1 queen, 1 king (+ a spare queen for
  promotions is handy). Print a few extra hubs.
- **Board panel:** `board_panel.stl` whole if it fits your bed, else the four
  `board_panel_{bl,br,tl,tr}` quarters and join.
- **Frame:** four `frame_corner` pieces.
- **Rotation hub:** `hub_wall_plate`, `hub_turntable`, `hub_drive_pulley`
  (pulley only needed in Phase 2).

## 3. Assemble the board panel

1. Cut/order the **steel sheet**: `grid_size` square (360 mm at default),
   0.5–1 mm mild/galvanized steel. For Phase-2 sensing have the shop laser-cut
   the 64 sensing holes — `make sheet` exports the 1:1 DXF. A plain un-holed
   sheet is fine for Phase 1.
2. **Mark the squares on the sheet** (paint or vinyl, two tones; mask & spray
   works well). The printed border keeps the a–h / 1–8 labels.
3. **Glue the sheet** to the panel front (epoxy or strong VHB tape), sensing
   holes centered over the panel's bores. Clamp flat while it cures.
4. (Phase 2) slide a **hall sensor** into each bore from the back until its
   tip sits flush under the sheet hole; route leads through the open back
   cavity to the mux boards.
5. Press **heat-set inserts** (or tap) the four corner bosses.

## 4. Assemble pieces

For each piece: press a **magnet** into the hub (consistent polarity — mark a
face), stick a **felt disc** over the magnet (glide + paint protection), glue
the **steel weight** (two stacked M3 nuts or a ~6 mm ball) into the body's
base pocket, slide the body onto the **axle post**, and **snap the cap** on.
Spin-test: it should rotate freely and settle upright.

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
| Piece slowly droops off-vertical | more base weight; lower friction; check pivot centered |
| Piece spins past upright and oscillates | add light felt/O-ring damping at the pivot; heavier base |
| Board sags / won't stay level | balance about the axis; check bearing seated; heavier wall anchors |
| Magnet won't hold on the vertical face | bigger/stronger magnet, thinner felt disc, confirm the sheet is ferromagnetic steel (not stainless 304) |
| Piece drags/scratches when sliding | thicker felt disc on the hub; clear-coat the sheet's paint |
| Belt slips (Phase 2) | tension it; increase wrap; verify pulley grub screw tight |
