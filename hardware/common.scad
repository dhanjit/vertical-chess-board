// =====================================================================
// common.scad — shared parameters for the Vertical Wall Chess Board
// =====================================================================
//
// Every other .scad file `include`s this so there is ONE place to change
// dimensions. Units are millimeters. Edit the values in the CONFIG block
// to re-size the whole system; the parts downstream adapt.
//
// Coordinate convention (matches the software engine):
//   The playing surface is a vertical plane (the XY plane here, +Z points
//   OUT of the wall toward the room). Squares are addressed file a..h (X)
//   and rank 1..8 (Y).
//
// The self-righting mechanic:
//   Each piece hangs on a horizontal axle (pivot along +Z, i.e. normal to
//   the board). The piece body's center of mass sits BELOW that axle, so
//   the piece behaves as a pendulum and always swings upright — no matter
//   how the board is rotated. See gravity_gimbal.scad.
// =====================================================================

// ---------------------------------------------------------------- CONFIG
// ---- THE TWO VARIANT SELECTORS ---------------------------------------
// The design is kept as SELECTABLE VARIANTS along two INDEPENDENT axes, so
// competing approaches can sit side by side and be compared rather than
// argued about. Any combination of the two is buildable; they do not know
// about each other.
//
// AXIS 1 — PIECE STYLE: the artwork, i.e. what the silhouette looks like.
//   One file per style in styles/, each exposing the same three-symbol
//   contract. Adding a style is one new file plus one entry in "THE ENUM"
//   block in pieces.scad.
//
//     "monolith"  One 1:4 taper, one stroke width, one convex and one
//                 concave radius, a shared foot; rank reads as height plus
//                 ONE terminal event. A coherent invented design language —
//                 but one you have to learn.
//     "familiar"  The online-chess / fridge-magnet vocabulary: ball-and-
//                 collar pawn, crenellated rook, horse knight, cleft mitre
//                 bishop, coronet queen, cross king. Nobody has to be taught
//                 what any of them is.
//
//   MEASURED off the exported meshes, pivot "pin", 55 mm squares, mu = 0.08.
//   Every piece: pivot exactly on the silhouette centre, single shell, inside
//   its square. (H x W in mm, lean in deg — lower lean is straighter.)
//        piece    familiar             monolith
//        pawn     40.0 x 30.0  1.16    31.8 x 20.7  1.49
//        rook     43.0 x 38.0  1.44    36.7 x 24.6  1.81
//        knight   44.5 x 40.5  1.13    39.1 x 26.4  1.40
//        bishop   47.5 x 36.0  0.94    42.8 x 30.0  1.16
//        queen    50.0 x 41.8  1.12    46.4 x 25.3  1.48
//        king     52.0 x 42.0  0.99    51.3 x 25.6  0.98
//   "familiar" is the default: it is both the look asked for AND the better
//   mechanism on five pieces of six — bigger pieces put more area further
//   below the pivot, which is the whole of `d`. The trade it makes is width:
//   its knight is 40.5 wide against the monolith's 26.4, and its pieces fill
//   the square instead of sitting in it.
piece_style      = "familiar";   // "monolith" | "familiar"

// AXIS 2 — PIVOT ARCHITECTURE: how the piece hangs and turns. Built in
//   gravity_gimbal.scad, which documents both in full.
//
//     "pin"     A separate printed HUB PUCK (Ø11.5 x 8) holds the magnet and
//               sticks to the steel board; a bought Ø3 x 16 steel dowel
//               presses into it; the piece turns on that dowel; a Ø6 printed
//               press cap retains it. The magnet is on the BOARD side, so its
//               mass never enters the pendulum.
//               PER PIECE: 3 PRINTED (body, hub puck, press cap) + 2 BOUGHT
//               (Ø8 x 3 magnet, Ø3 x 16 dowel) = 5 components, plus a felt disc.
//     "magnet"  No hub, no dowel, no cap. A Ø4 x 5 magnet sits in the piece's
//               own bore and the piece turns ON THE MAGNET; a Ø9 x 0.8 steel
//               disc, held by that same magnet with no glue, recesses into a
//               1.0 mm counterbore in the FRONT face and stops the piece
//               pulling off.
//               PER PIECE: 1 PRINTED (the body) + 2 BOUGHT (Ø4 x 5 magnet,
//               Ø9 x 0.8 disc) = 3 components. Three named parts go away (hub,
//               dowel, cap) and one arrives (the disc), so the NET saving is
//               TWO components -- and, the part that matters, PRINTED parts
//               per piece go 3 -> 1.
//
//   MEASURED, style "familiar": pin -> magnet costs
//        pawn  1.16 -> 1.80 deg      king  0.99 -> 1.40 deg
//   i.e. ~0.4-0.6 deg of extra lean to drop two of the five components per
//   piece -- and two of the three PRINTED ones. It costs
//   on two fronts and both are in that number: r in sin(lean) = mu*r/d
//   becomes the Ø4.70 bore's radius instead of the Ø3.70 bore's, AND the
//   magnet + disc now ride WITH the piece at zero lever arm, dragging the
//   combined centre of mass toward the axis. (A Ø5 magnet was measured too
//   and is worse on both counts: pawn 2.27, king 1.73. Ø4 is the choice.)
//   Two things about "magnet" are UNPROVEN and are NOT in those numbers —
//   whether the disc stays put through a board flip, and the face friction
//   from the piece being clamped to the sheet. See gravity_gimbal.scad.
//
//     "bearing" The "pin" architecture with the piece's plain bore replaced
//               by a bought MR63ZZ ball bearing (Ø3 x Ø6 x 2.5) pressed into
//               the piece from the back; hub puck, dowel, magnet, felt and
//               cap are IDENTICAL to "pin". Rolling friction makes the
//               parking error effectively zero REGARDLESS of mu -- this is
//               the fallback if Phase 0 measures friction far above the
//               assumed 0.08. What it does NOT solve is damping: the greased
//               pin's grease was the damper, and a near-frictionless pivot
//               lets a piece ring after every board flip. That cost is real,
//               unmeasured, and documented in gravity_gimbal.scad.
//               PER PIECE: 3 PRINTED (body, hub puck, press cap) + 3 BOUGHT
//               (Ø8 x 3 magnet, Ø3 x 16 dowel, MR63ZZ bearing) = 6 components,
//               plus a felt disc.
pivot_type       = "pin";        // "pin" | "magnet" | "bearing"

// ---- Board geometry ----
square_size      = 55;      // edge length of one playing square. RESOLVES D1.
                            //   Why 55 and not 45: under pivot_type "pin" the hub
                            //   puck is a fixed Ø11.5 disc sitting behind the
                            //   piece, and the piece has to HIDE it or every
                            //   piece wears a grey collar. At 45 mm squares the
                            //   narrowest piece only covered a Ø9.8 waist, so the
                            //   puck showed. The mechanical parts do not scale
                            //   with the square -- only the ARTWORK does -- so
                            //   growing the square grows the silhouette until it
                            //   outruns the puck. 55 is the SMALLEST square at
                            //   which the narrowest waist in the "monolith" style
                            //   (Ø12.0) covers Ø11.5 with nothing added: no skirt,
                            //   no collar, no fake boss. 0.5 mm to spare. The
                            //   "familiar" style is far clear of it -- its
                            //   narrowest waist is the rook's 20 mm tower.
                            //   Panel goes ~410 -> ~490 mm square as a result.
board_margin     = 25;      // border around the 8x8 grid (holds frame + labels)
board_thickness  = 10;      // thickness of the printed panel (back cavity +
                            //   sensor bores; the steel sheet glues onto its
                            //   front face -- see board_panel.scad)

// ---- Piece holding + sensing (steel-sheet face) ----
// The playing surface is a thin steel sheet glued onto the printed panel's
// front. Piece magnets grip the sheet DIRECTLY -- the proven attachment every
// commercial magnetic wall set uses. A small felt disc stuck over each hub
// magnet sets the glide and protects the sheet's paint. For Phase-2 sensing
// the sheet gets a small laser-cut hole per square center; a hall sensor in
// a bore from the back reads the piece magnet through that hole, so the
// sheet never shields it.
front_wall       = 2.5;     // printed wall behind the sheet (structure; the
                            //   sensor bore runs through it -- no longer a
                            //   magnetic gap, the magnet touches steel)
sheet_thk        = 0.8;     // steel sheet thickness (source 0.5-1.0 mm mild/
                            //   galvanized steel -- NOT stainless 304)
sheet_hole       = 8;       // dia of the per-square sensing hole in the sheet
                            //   (laser-cut; Phase 2 only -- a plain un-holed
                            //   sheet is fine for the manual board)
sensor_dia       = 4;       // hall sensor body (e.g. 49E / A3144 in TO-92, trimmed)

// ---- Magnets (neodymium discs) ----
magnet_dia       = 8;       // magnet diameter  (8 mm N52 discs work well)
magnet_thk       = 3;       // magnet thickness
magnet_fit       = 0.15;    // radial press-fit clearance (per side)

// ---- Gravity gimbal / pivot ----
// THE PHYSICS, STATED ONCE (every number below answers to this equation).
// A hanging piece does not park perfectly upright: it parks wherever bore
// friction cancels the gravity torque, at
//     sin(lean) = mu * r / d
//       mu = friction coefficient in the bore (~0.08, greased steel on plastic)
//       r  = bore RADIUS  -> a thinner axle is a straighter piece
//       d  = how far the centre of mass sits BELOW the pivot
// MASS CANCELS OUT of that equation for a single rigid piece. Adding weight
// to a piece does NOTHING for how straight it hangs; only geometry and
// friction move the number.
// THE ONE EXCEPTION, and it is the whole argument between the two pivot
// architectures above: mass added AT THE PIVOT still hurts. It contributes no
// restoring torque but it does move the COMBINED centre of mass toward the
// axis, which shrinks `d`. That is why pivot_type "magnet" -- which hangs the
// magnet and the retaining disc on the piece at zero lever arm -- measures
// worse than "pin", which leaves the magnet on the board.
// (Second consequence of the same equation: a piece hangs with its CoM
// directly BELOW the pivot, so an asymmetric silhouette must be balanced in x
// or it hangs permanently rotated -- see KDX in styles/familiar.scad and in
// styles/monolith.scad, the two knights.)
//
// The axle is a STOCK Ø3 x 16 mm STEEL DOWEL PIN pressed into the hub -- it
// is NOT printed. Ground steel against a plastic bore is mu ~0.2 (~0.08 with
// damping grease) versus ~0.3-0.4 for a printed post in a printed bore, so
// the sliding pair alone roughly halves the settling error.
//
// HONESTY: mu = 0.08 is a TEXTBOOK figure for greased steel on plastic. It has
// not been measured on this hardware, and NOTHING in this repo has been
// printed yet -- every lean figure quoted anywhere is a model, not a
// measurement. One printed pawn plus one hub settles it, and that is the
// cheapest test available; do it before printing a set. If the real mu comes
// out higher, the lean numbers scale with it linearly.
axle_dia         = 3;       // dowel pin diameter (stock Ø3 h8 x 16 mm).
                            //   Was Ø4 -- and Ø3 is STRONGER, not weaker,
                            //   because what changed with it is that the axle
                            //   is bought steel instead of a printed post: a
                            //   Ø4 PRINTED post carried only 1.29x margin
                            //   against a 20 N sideways knock (it snaps at the
                            //   layer-line root), while a Ø3 steel dowel
                            //   carries 3.0x. Shrinking it also cuts mu*r,
                            //   which is the entire numerator of the settling
                            //   equation above: Ø4 -> Ø3 is ~19% less lean for
                            //   free.
axle_len         = 11;      // how far the dowel stands proud of the hub face.
                            //   11 proud + 5 embedded = a stock 16 mm dowel,
                            //   so nothing has to be cut to length.
                            //   Body (6) + cap grip (3.5) = 9.5, leaving
                            //   1.5 mm axial float so print tolerance can't
                            //   clamp the body against the hub and stall it.
axle_embed       = 5;       // how deep the dowel presses into the hub. Bottoms
                            //   out ON the magnet, so there is no thin printed
                            //   web to crack and the dowel cannot creep deeper.
axle_press_fit   = -0.10;   // hub bore = axle_dia + this. NEGATIVE = a real
                            //   interference fit; add a drop of CA if a given
                            //   printer runs loose.
axle_fit         = 0.35;    // clearance so the body spins freely on the dowel.
                            //   Bore = axle_dia + 2*axle_fit = 3.70, so
                            //   r = 1.85 in the settling equation above.
axle_root_fillet = 1.2;     // chamfer at the mouth of the hub's dowel bore, so
                            //   the dowel starts square when it is pressed in.
                            //   It is cut INTO the hub face -- nothing sticks
                            //   out -- so the piece needs no matching
                            //   countersink, and it no longer has one.
hub_dia          = 11.5;    // diameter of the magnetic hub puck. Was 22, which
                            //   was never a requirement: the puck only ever had
                            //   to hold one Ø8 magnet, so 11.5 leaves a 1.75 mm
                            //   wall all round it. Checked against TIPPING
                            //   rather than against area -- a 3 g piece hanging
                            //   11 mm proud of the wall tips the puck with
                            //   ~0.0003 N.m, and the magnet on steel resists
                            //   with ~0.03 N.m: ~90x margin, so this is not a
                            //   marginal number. What it buys is that the piece
                            //   HIDES it: the silhouettes conceal Ø12.0 at the
                            //   waist, so 11.5 disappears with 0.5 mm to spare.
hub_thk          = 8;       // thickness of the hub puck. Set by the stack-up:
                            //   magnet_thk (3, from the back) + axle_embed (5,
                            //   from the front) = 8, meeting in the middle.
cap_dia          = 6;       // retaining cap that keeps the body on the axle.
                            //   Was 8. The cap is the one part of the mechanism
                            //   that faces the ROOM, sitting in the middle of
                            //   the piece: at Ø8 it read as a deliberate
                            //   button, at Ø6 it vanishes into the waist.
cap_grip_fit     = -0.15;   // cap bore = axle_dia + this. The cap grips the
                            //   plain dowel by interference (the old cap
                            //   snapped over a lip printed on the post; a
                            //   steel dowel has no lip).

// ---- Gravity gimbal, pivot_type "magnet" only -------------------------
// The whole of this architecture is two BOUGHT parts and a counterbore; there
// is nothing printed but the piece. Unused when pivot_type is "pin".
pivot_magnet_dia = 4;       // the magnet the piece turns ON. Ø4 not Ø5: it is
                            //   the `r` in sin(lean) = mu*r/d, so it sets the
                            //   lean directly. Measured, style "familiar":
                            //   Ø4 -> pawn 1.80 / king 1.40 deg,
                            //   Ø5 -> pawn 2.27 / king 1.73 deg.
pivot_magnet_thk = 5;       // = piece_thk - disc_seat_depth, so the magnet
                            //   drops in from the BACK and finishes flush with
                            //   the back face, touching the steel sheet with
                            //   no plastic in the gap.
retain_disc_dia  = 9;       // steel disc on the magnet's front pole, held by
                            //   the magnet itself -- NO GLUE. Wider than the
                            //   Ø4.70 bore, so it cannot pass through it, and
                            //   that is the only thing stopping the piece
                            //   pulling off the magnet.
                            //   UNPROVEN: nothing has verified that it stays
                            //   put through a board flip. Print
                            //   pivot_test_coupon() and find out.
retain_disc_thk  = 0.8;     // stock shim thickness
disc_seat_depth  = 1.0;     // counterbore in the piece's FRONT face. 1.0 for a
                            //   0.8 disc, so the disc sits 0.2 below flush.
disc_seat_slop   = 0.3;     // RADIAL clearance per side, so the seat is Ø9.6.
                            //   Loose on purpose -- the disc is placed by a
                            //   magnet, by hand, and does not locate anything;
                            //   the bore locates the piece. Kept modest all the
                            //   same: at Ø9.6 the seat plus its 0.9 wall is a
                            //   Ø11.4 collar, and the narrowest waist the two
                            //   styles put at the pivot is the monolith king's
                            //   12.1 mm. Any wider and that piece runs out of
                            //   silhouette to put the seat in.
// ---- Gravity gimbal, pivot_type "bearing" only -------------------------
// A bought MR63ZZ deep-groove bearing (bore 3 = axle_dia, so the SAME hub
// and dowel as "pin") pressed into the piece from the BACK face. The piece
// then turns on rolling balls instead of a greased sliding bore, which takes
// mu -- the one unmeasured input in the settling equation -- out of the
// parking error entirely. The trade, stated in gravity_gimbal.scad: ~0.5 g
// of steel riding exactly at the pivot, a bearing to buy per piece, and
// NOTHING LEFT TO DAMP THE SWING. Unused when pivot_type is "pin"/"magnet".
pivot_bearing_od = 6;       // MR63ZZ outer diameter. The smallest stock size
                            //   on a Ø3 shaft; its seat + hollow_wall needs
                            //   only Ø7.9 of silhouette at the pivot, so every
                            //   current piece clears it (narrowest waist: 12).
pivot_bearing_w  = 2.5;     // MR63ZZ width. Seated from the back face, the
                            //   remaining 3.5 mm of plate in front of it is a
                            //   solid wall with a loose clearance bore.
pivot_bearing_seat_fit = 0.05;    // radial clearance per side for the outer-race
                            //   seat (Ø6.10). Printed holes come out snug, so
                            //   this lands as a light press in practice --
                            //   tune like magnet_fit on the Phase-0 print.
pivot_bearing_clear_dia = 5;      // loose through-bore in FRONT of the seat, so the
                            //   plate never touches the dowel -- only the
                            //   bearing does. Any plain contact would put the
                            //   greased-bore friction right back.

// ---- Bottom-heaviness: shaped in, not glued in ----------------------
// A piece self-rights because its centre of mass sits BELOW the pivot -- that
// is `d` in the settling equation above. There are two ways to arrange it, and
// only one survives a change of material:
//   (a) glue a dense slug into a pocket low down, or
//   (b) make the piece solid at the bottom and HOLLOW above the pivot.
// (b) wins, and it is what this set does -- there is NO weight pocket and
// nothing to glue in. Under (a) the lever depends on the RATIO of slug density
// to body density, so tuning done in one material does not transfer: a PETG
// test print would settle differently from the resin final part and would
// prove nothing. Under (b) the piece is ONE material, density cancels out of
// the settling equation completely, and a cheap PETG test print behaves
// IDENTICALLY to the final part. It is also one fewer part and no glue step.
// NOTE: this cavity is MODELLED, not left to the slicer. A resin slicer's
// "hollow" tool removes material evenly everywhere, which produces no
// top-to-bottom mass gradient at all -- exactly the wrong thing.
hollow_wall      = 0.9;     // solid wall kept all round the cavity: 0.9 mm at
                            //   the front and back faces, and 0.9 mm in from
                            //   every silhouette edge.
                            //   This number matters more than it looks. The
                            //   wall is subtracted from BOTH sides of every
                            //   dimension, so on a small piece it eats most of
                            //   the cavity -- a thicker wall leaves less void
                            //   above the pivot, which raises the centre of
                            //   mass, shortens `d`, and (straight out of the
                            //   equation above) increases the lean. A thinner
                            //   one does the reverse.
                            //   0.9 is the floor for a 0.4 mm FDM nozzle
                            //   (2 perimeters) and is comfortable in resin, so
                            //   it is where that trade stops being safe. If
                            //   Phase 0 measures mu higher than assumed, 0.7 is
                            //   the one lever left in the artwork -- at the
                            //   cost of a wall thinner than the nozzle likes.
                            //   (The per-wall lever figures that used to sit
                            //   here were measured on the superseded Ø4 printed
                            //   post and no longer describe any current piece;
                            //   re-measure against the exported mesh if the
                            //   number is ever changed.)
drain_dia        = 2;       // resin drain hole through the BACK face into the
                            //   cavity. MANDATORY for resin -- a sealed void
                            //   traps uncured resin, which later leaks or
                            //   bulges the wall. Harmless on FDM. Every cavity
                            //   in the set has one; verify by counting shells
                            //   in the exported STL (a cavity the drain missed
                            //   shows up as a second shell).

// ---- Piece bodies (flat silhouettes, read from across the room) ----
// SIZE IS NOT HERE. How tall each piece is, and whether the artwork carries a
// scale factor at all, belongs to the STYLE -- "monolith" is drawn at nominal
// size and scaled up by 1.222, "familiar" is drawn at final size and has no
// scale factor. Putting either style's heights in this file would make it look
// as though the board depended on them. The mechanism only ever asks a style
// for piece_height(t) and gets real printed millimetres back.
// The one size rule the MECHANISM does impose: a piece hangs pivot_frac * H
// below the axle, and the axle is the square centre, so every style must keep
//     pivot_frac * H <= square_size / 2      i.e.  H <= 55 mm
// with a little to spare for the swing. Both styles clear it (tallest pieces
// 51.3 and 52.0 mm).
piece_thk        = 6;       // extrusion thickness of the silhouette plate
pivot_frac       = 0.50;    // pivot height as a fraction of piece height.
                            //   0.50 puts the pivot on the silhouette's
                            //   bounding-box CENTRE. Two things follow:
                            //   the piece reads centred in its square, AND it
                            //   turns about its own centre, so whatever small
                            //   error it settles at merely ROTATES it in place
                            //   instead of swinging the body sideways. It
                            //   therefore stays centred through a board flip.
                            //   The cost is pendulum lever: the centre of mass
                            //   ends up nearer the pivot (d = 4.7-9.0 mm across
                            //   BOTH styles -- monolith rook 4.68 at the low
                            //   end, familiar bishop 9.02 at the high one), so
                            //   the settling error grows unless
                            //   friction drops to match. That is what the steel
                            //   dowel and the damping grease are paying for.

// ---- Rotation hub (the turntable that flips the board 180 deg) ----
bearing_od       = 90;      // outer dia of the turntable bearing seat
bearing_id       = 60;      // inner bore
motor_gear_teeth = 20;      // drive pinion on the NEMA-17
ring_gear_teeth  = 200;     // GT2 ring on the turntable (10:1 reduction).
                            //   Must be large enough that the toothed rim
                            //   clears the turntable disc: pitch dia =
                            //   teeth*2/PI must exceed bearing_od + 28 + 6.

// ---- Fasteners (M3 throughout) ----
m3_clear         = 3.2;     // clearance hole an M3 bolt/screw passes through
m3_tap           = 2.9;     // thread-forming hole an M3 screw cuts its thread into

// ---- Print tolerances ----
slop             = 0.2;     // general clearance for mating printed parts
$fn              = 64;      // curve smoothness (bump to 128 for final render)
// ------------------------------------------------------------ END CONFIG

// Derived values -------------------------------------------------------
grid_size   = 8 * square_size;                 // playing area edge
panel_size  = grid_size + 2 * board_margin;    // full panel edge
hub_bolt_r  = bearing_od/2 + 9;                // frame <-> turntable bolt circle;
                                               //   outside the bearing OD so the
                                               //   bolts clear the bearing race.
                                               //   Shared by frame.scad and
                                               //   rotation_hub.scad.

// Center coordinate of square (file f 0..7, rank r 0..7) on the panel,
// measured from the panel's own corner.
function sq_center(f, r) = [
    board_margin + square_size * (f + 0.5),
    board_margin + square_size * (r + 0.5)
];

// A dark square? (a1 is dark => (f+r) even is light in this indexing;
// standard board has a1 dark, so dark when (f+r) is even with a1 at f0,r0).
function is_dark(f, r) = ((f + r) % 2) == 0;

// Convenience: a rounded 2D square used by several parts.
module rrect(w, h, r) {
    minkowski() {
        square([w - 2*r, h - 2*r], center = true);
        circle(r);
    }
}
