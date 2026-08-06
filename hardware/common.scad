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
// ---- Board geometry ----
square_size      = 55;      // edge length of one playing square. RESOLVES D1.
                            //   Why 55 and not 45: the hub puck is a fixed Ø11.5
                            //   disc sitting behind the piece, and the piece has
                            //   to HIDE it or every piece wears a grey collar. At
                            //   45 mm squares the narrowest piece only covered a
                            //   Ø9.8 waist, so the puck showed. The mechanical
                            //   parts do not scale with the square -- only the
                            //   ARTWORK does -- so growing the square grows the
                            //   taper until it outruns the puck. 55 is the
                            //   SMALLEST square at which the natural waist
                            //   (Ø12.0) covers Ø11.5 with nothing added: no
                            //   skirt, no collar, no fake boss. 0.5 mm to spare.
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
// MASS CANCELS OUT of that equation entirely. Adding weight to a piece does
// NOTHING for how straight it hangs; only geometry and friction move the
// number. (Second consequence: a piece hangs with its CoM directly below the
// pivot, so an asymmetric silhouette must be balanced in x or it hangs
// permanently rotated -- see KDX in pieces.scad.)
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
                            //   the cavity. Measured on the pawn:
                            //     1.2 mm wall -> lever 3.41 mm -> +/-3.16 deg
                            //     0.9 mm wall -> lever 4.07 mm -> +/-2.65 deg
                            //     0.7 mm wall -> lever 4.65 mm -> +/-2.32 deg
                            //   0.9 is the floor for a 0.4 mm FDM nozzle
                            //   (2 perimeters) and is comfortable in resin.
drain_dia        = 2;       // resin drain hole through the BACK face into the
                            //   cavity. MANDATORY for resin -- a sealed void
                            //   traps uncured resin, which later leaks or
                            //   bulges the wall. Harmless on FDM. Every cavity
                            //   in the set has one; verify by counting shells
                            //   in the exported STL (a cavity the drain missed
                            //   shows up as a second shell).

// ---- Piece bodies (flat silhouettes, read from across the room) ----
piece_thk        = 6;       // extrusion thickness of the silhouette plate
piece_scale      = 1.222;   // global scale on the ARTWORK only -- the hub, the
                            //   dowel and the cap keep their own millimetres.
                            //   That asymmetry is the whole point: growing the
                            //   artwork against a fixed puck is what finally
                            //   let the taper's waist swallow the puck (see
                            //   square_size). 1.222 is the smallest scale at
                            //   which the narrowest waist reaches Ø12.0 > the
                            //   Ø11.5 puck.
                            //   Bounded above by the square: a piece hangs
                            //   pivot_frac * H below the axle and the axle is
                            //   the square centre, so we need
                            //     pivot_frac * h_king * scale <= square_size/2
                            //   -> scale <= 27.5 / (0.5*42) = 1.310.
                            //   At 1.222 the king hangs 25.66 down into a
                            //   27.5 half-square: 1.84 mm of headroom.
                            //   NOTE: the profiles in pieces.scad are drawn in
                            //   ABSOLUTE mm, so this must be applied as a
                            //   scale() around the profile -- passing a bigger
                            //   H would stretch the body while leaving the
                            //   fixed-size heads (crown, cross, mitre) behind.
pivot_frac       = 0.50;    // pivot height as a fraction of piece height.
                            //   0.50 puts the pivot on the silhouette's
                            //   bounding-box CENTRE. Two things follow:
                            //   the piece reads centred in its square, AND it
                            //   turns about its own centre, so whatever small
                            //   error it settles at merely ROTATES it in place
                            //   instead of swinging the body sideways. It
                            //   therefore stays centred through a board flip.
                            //   The cost is pendulum lever: the centre of mass
                            //   ends up nearer the pivot (d = 4.7-8.7 mm across
                            //   the set), so the settling error grows unless
                            //   friction drops to match. That is what the steel
                            //   dowel and the damping grease are paying for.
// Nominal silhouette heights per type (mm), multiplied by piece_scale to give
// the real printed height. These are the numbers the ARTWORK is drawn to in
// pieces.scad; ratio 42/26 = 1.62, inside the 1.6-2.0 band that makes rank
// read at across-the-room distance. ~3 mm steps, opening to 4 at the top so
// the king still pulls away from the queen.
h_pawn   = 26;              // -> 31.77 mm printed
h_rook   = 30;              // -> 36.66
h_knight = 32;              // -> 39.10
h_bishop = 35;              // -> 42.77
h_queen  = 38;              // -> 46.44
h_king   = 42;              // -> 51.32

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
