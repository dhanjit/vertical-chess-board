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
board_thickness  = 10;      // thickness of the printed playing panel
                            //   = front_wall + washer_thk + sensor_h + margin,
                            //   so a washer + hall sensor stack fits behind
                            //   each square (see board_panel.scad)
tile_engrave     = 1.2;     // depth of the engraved square grid / dark squares

// ---- Piece holding + sensing (per-square steel washers) ----
// A steel washer sits behind each square, near the front face. The piece
// magnet grips it (holding the piece to the vertical board) AND snaps to its
// center, so pieces self-center on the square. A hall sensor lives in the
// washer's center hole and reads the piece magnet through the thin front wall
// -- the washer's HOLE is why the sensor isn't magnetically shielded.
front_wall       = 2.5;     // plastic between piece magnet and washer/sensor
washer_od        = 16;      // steel washer outer dia (e.g. M8 fender washer)
washer_id        = 8.4;     // washer center hole (sensor pokes up into it)
washer_thk       = 1.6;     // washer thickness
washer_fit       = 0.3;     // pocket clearance around the washer
sensor_dia       = 4;       // hall sensor body (e.g. 49E / A3144 in TO-92, trimmed)
sensor_h         = 5;       // depth of the sensor pocket

// ---- Magnets (neodymium discs) ----
magnet_dia       = 8;       // magnet diameter  (8 mm N52 discs work well)
magnet_thk       = 3;       // magnet thickness
magnet_fit       = 0.15;    // radial press-fit clearance (per side)

// ---- Gravity gimbal / pivot ----
axle_dia         = 4;       // diameter of the pivot post
axle_len         = 9;       // how far the post projects from the hub
axle_fit         = 0.35;    // clearance so the body spins freely on the post
hub_dia          = 22;      // diameter of the magnetic hub puck
hub_thk          = 6;       // thickness of the hub puck
cap_dia          = 8;       // retaining cap that keeps the body on the axle
weight_pocket    = 7;       // dia of pocket at piece bottom for a steel weight
weight_pocket_h  = 6;       // depth of that pocket

// ---- Piece bodies (flat silhouettes, read from across the room) ----
piece_thk        = 6;       // extrusion thickness of the silhouette plate
piece_scale      = 1.0;     // global scale multiplier for all pieces
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
ring_gear_teeth  = 120;     // ring gear on the board (6:1 reduction)

// ---- Print tolerances ----
slop             = 0.2;     // general clearance for mating printed parts
$fn              = 64;      // curve smoothness (bump to 128 for final render)
// ------------------------------------------------------------ END CONFIG

// Derived values -------------------------------------------------------
grid_size   = 8 * square_size;                 // playing area edge
panel_size  = grid_size + 2 * board_margin;    // full panel edge

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
