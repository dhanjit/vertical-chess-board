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
square_size      = 45;      // edge length of one playing square
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
axle_dia         = 4;       // diameter of the pivot post
axle_len         = 10.5;    // how far the post projects from the hub. Gives
                            //   ~0.7 mm axial float between body and cap so
                            //   print tolerance can't clamp the body flat
                            //   against the hub (which would stop rotation).
axle_fit         = 0.35;    // clearance so the body spins freely on the post
axle_root_fillet = 1.2;     // 45-deg reinforcing cone at the post root (the
                            //   post's weakest point under a sideways knock);
                            //   the body bore gets a matching countersink so
                            //   the body still seats flush.
hub_dia          = 22;      // diameter of the magnetic hub puck
hub_thk          = 6;       // thickness of the hub puck
cap_dia          = 8;       // retaining cap that keeps the body on the axle
weight_pocket    = 7;       // dia of the base weight pocket. Fits two stacked
                            //   M3 nuts (2 x 2.4 = 4.8 mm, flush) or a steel
                            //   ball/disc kept flush-or-below with glue.
                            //   (An M6 nut is ~11 mm across corners - too big.)
weight_pocket_h  = 5;       // pocket depth. BLIND: less than piece_thk so a
                            //   1 mm floor remains at the front face; the
                            //   weight goes in from the back, glued, and must
                            //   sit flush so it can't rub the hub puck.

// ---- Piece bodies (flat silhouettes, read from across the room) ----
piece_thk        = 6;       // extrusion thickness of the silhouette plate
piece_scale      = 1.0;     // global scale multiplier for all pieces
pivot_frac       = 0.60;    // pivot height as a fraction of piece height
                            //   (above the middle => clear "down" + fast settle)
// Nominal silhouette heights per type (mm), scaled by piece_scale.
h_pawn   = 26;
h_knight = 30;
h_bishop = 33;
h_rook   = 30;
h_queen  = 37;
h_king   = 40;

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
