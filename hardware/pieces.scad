// =====================================================================
// pieces.scad — the 6 chess pieces as self-righting flat silhouettes
// =====================================================================
//
// Each piece is a flat SILHOUETTE plate (a bas-relief profile) so it reads
// cleanly from across the living room and prints flat with no supports.
// It carries:
//   * a central PIVOT BORE (rides on the hub's axle — see gravity_gimbal.scad)
//   * a WEIGHT POCKET at the base (drop in a steel nut / M6 grub / magnet)
//     to push the center of mass below the pivot => it self-rights.
//
// The pivot is placed ABOVE the geometric middle; combined with the base
// weight this gives a clear "down" so the pendulum settles fast and upright.
//
// Usage from the command line (renders one piece to STL):
//   openscad -D 'PART="king"'  -o king.stl  pieces.scad
//   openscad -D 'PART="queen"' -o queen.stl pieces.scad
// PART can be: pawn knight bishop rook queen king  (or "all" for a tray)
// =====================================================================

include <common.scad>
use <gravity_gimbal.scad>

PART = "all";   // overridden with -D on the command line

pivot_frac = 0.60;   // pivot height as a fraction of piece height (above middle)

// ---- 2D silhouette profiles (base sits on y=0, symmetric about x=0) ---

module base2d(w, h) {
    hull() {
        translate([-w/2 + h/2, h/2]) circle(d = h);
        translate([ w/2 - h/2, h/2]) circle(d = h);
    }
}

module pawn2d(H) {
    w = H * 0.62;
    base2d(w, H*0.14);
    // collar
    translate([0, H*0.14]) base2d(w*0.55, H*0.06);
    // stem
    hull() {
        translate([0, H*0.20]) square([w*0.30, 0.1], center = true);
        translate([0, H*0.55]) square([w*0.22, 0.1], center = true);
    }
    // head
    translate([0, H*0.72]) circle(d = H*0.34);
}

module rook2d(H) {
    w = H * 0.66;
    base2d(w, H*0.16);
    translate([0, H*0.16]) base2d(w*0.6, H*0.06);
    // body
    hull() {
        translate([0, H*0.22]) square([w*0.42, 0.1], center = true);
        translate([0, H*0.70]) square([w*0.50, 0.1], center = true);
    }
    // (crenellated top is added by rook_top2d in silhouette2d)
}

// centered crenellated top for the rook (replaces the difference above)
module rook_top2d(H) {
    w = H * 0.66;
    tw = w*0.64;
    th = H*0.24;
    y0 = H*0.70;
    difference() {
        translate([-tw/2, y0]) square([tw, th]);
        for (i = [-1, 1])
            translate([i*tw*0.22 - tw*0.08, y0 + th*0.45])
                square([tw*0.16, th*0.7]);
        translate([-tw*0.08, y0 + th*0.45]) square([tw*0.16, th*0.7]);
    }
}

module bishop2d(H) {
    w = H * 0.58;
    base2d(w, H*0.14);
    translate([0, H*0.14]) base2d(w*0.55, H*0.05);
    // body (tapered)
    hull() {
        translate([0, H*0.19]) square([w*0.44, 0.1], center = true);
        translate([0, H*0.62]) circle(d = w*0.34);
    }
    // mitre
    translate([0, H*0.74]) circle(d = w*0.42);
    translate([0, H*0.86]) circle(d = H*0.10);
    // slit
    // (left as a visual break via the finial ball above)
}

module queen2d(H) {
    w = H * 0.60;
    base2d(w, H*0.13);
    translate([0, H*0.13]) base2d(w*0.55, H*0.05);
    hull() {
        translate([0, H*0.18]) square([w*0.42, 0.1], center = true);
        translate([0, H*0.58]) circle(d = w*0.40);
    }
    // crown band
    translate([0, H*0.66]) square([w*0.62, H*0.05], center = true);
    // crown points with balls
    np = 5;
    for (i = [0 : np-1]) {
        x = (i/(np-1) - 0.5) * w*0.62;
        translate([x, H*0.70]) circle(d = H*0.075);
        hull() {
            translate([x, H*0.68]) circle(d = H*0.03);
            translate([x, H*0.62]) circle(d = w*0.08);
        }
    }
}

module king2d(H) {
    w = H * 0.60;
    base2d(w, H*0.12);
    translate([0, H*0.12]) base2d(w*0.55, H*0.05);
    hull() {
        translate([0, H*0.17]) square([w*0.42, 0.1], center = true);
        translate([0, H*0.56]) circle(d = w*0.42);
    }
    // crown band
    translate([0, H*0.64]) square([w*0.60, H*0.06], center = true);
    // cross
    translate([0, H*0.80]) square([w*0.10, H*0.22], center = true);
    translate([0, H*0.84]) square([w*0.26, H*0.09], center = true);
}

module knight2d(H) {
    w = H * 0.66;
    base2d(w, H*0.16);
    translate([0, H*0.16]) base2d(w*0.6, H*0.05);
    // stylized horse head as a polygon (points scaled by H)
    s = H;
    translate([-w*0.05, H*0.20])
    polygon(points = [
        [-0.22*s, 0.00*s],
        [-0.26*s, 0.30*s],
        [-0.30*s, 0.44*s],
        [-0.10*s, 0.52*s],
        [-0.18*s, 0.60*s],
        [-0.10*s, 0.66*s],
        [ 0.02*s, 0.60*s],
        [ 0.14*s, 0.64*s],
        [ 0.30*s, 0.52*s],
        [ 0.30*s, 0.40*s],
        [ 0.10*s, 0.24*s],
        [ 0.16*s, 0.06*s],
        [ 0.22*s, 0.00*s],
    ]);
}

// Dispatch to the right silhouette + its nominal height.
function piece_height(t) =
    t == "pawn"   ? h_pawn   * piece_scale :
    t == "knight" ? h_knight * piece_scale :
    t == "bishop" ? h_bishop * piece_scale :
    t == "rook"   ? h_rook   * piece_scale :
    t == "queen"  ? h_queen  * piece_scale :
    t == "king"   ? h_king   * piece_scale : h_pawn * piece_scale;

module silhouette2d(t, H) {
    if (t == "pawn")   pawn2d(H);
    else if (t == "rook")  { rook2d(H); rook_top2d(H); }
    else if (t == "bishop") bishop2d(H);
    else if (t == "queen")  queen2d(H);
    else if (t == "king")   king2d(H);
    else if (t == "knight") knight2d(H);
}

// ---- 3D piece: extruded silhouette + pivot bore + base weight pocket --
module piece(t) {
    H = piece_height(t);
    py = pivot_frac * H;   // pivot height from base
    difference() {
        // Body, translated so the pivot point sits at the origin.
        translate([0, -py, 0])
            linear_extrude(height = piece_thk)
                silhouette2d(t, H);

        // Pivot bore at origin (through the plate).
        translate([0, 0, -0.5])
            cylinder(d = axle_dia + 2*axle_fit, h = piece_thk + 1);

        // Weight pocket near the base (open at the back face).
        translate([0, -py + H*0.09, piece_thk - weight_pocket_h])
            cylinder(d = weight_pocket, h = weight_pocket_h + 0.5);
    }
}

// A print tray of all six pieces (one of each) for a quick full set proof.
module tray() {
    types = ["pawn", "knight", "bishop", "rook", "queen", "king"];
    for (i = [0 : len(types)-1])
        translate([i * (square_size*0.9), 0, 0])
            piece(types[i]);
}

// ---- Render dispatch --------------------------------------------------
if (PART == "all") tray();
else piece(PART);
