// =====================================================================
// pieces.scad — THE MECHANISM that turns any silhouette into a piece
// =====================================================================
//
// This file draws NOTHING. It takes a flat silhouette from a STYLE file and
// applies the same five mechanical operations to it, whichever style and
// whichever pivot architecture are selected in common.scad:
//
//   1) EXTRUDE the silhouette to piece_thk, positioned so the pivot sits at
//      the origin;
//   2) BORE the pivot (and, under pivot_type "magnet", counterbore the front
//      face for the retaining disc) — geometry owned by gravity_gimbal.scad;
//   3) HOLLOW everything ABOVE the pivot, inset hollow_wall on all six sides.
//      This is what puts the centre of mass below the pivot so the piece
//      self-rights. There is no weight pocket and nothing to glue in — see
//      the bottom-heaviness note in common.scad for why shaped-in beats
//      glued-in;
//   4) DRAIN that cavity through the BACK face, so uncured resin cannot be
//      trapped;
//   5) keep the whole thing ONE SHELL, which is how (3) and (4) are checked.
//
// FACE CONVENTION, stated once: z = 0 is the FRONT face (it faces the room),
// z = piece_thk is the BACK face (it faces the wall). Drains break out of the
// back so the front stays a clean silhouette; the magnet architecture's
// retaining disc recesses into the front, where it is the only thing on that
// face.
//
// Usage from the command line (renders one piece to STL):
//   openscad -D 'PART="king"' -o king.stl pieces.scad
//   openscad -D 'PART="king"' -D 'piece_style="monolith"' \
//            -D 'pivot_type="magnet"' -o king.stl pieces.scad
// PART can be: pawn knight bishop rook queen king  (or "all" for a tray)
// =====================================================================

include <common.scad>
use <gravity_gimbal.scad>

// ---------------------------------------------------------- THE ENUM --
// Every piece style is one file in styles/ exposing exactly three symbols:
//     <style>_silhouette2d(t)   <style>_pheight(t)   <style>_drains(t)
// There are TWO styles today. ADDING A THIRD IS: drop the file in styles/,
// then add its four lines to the block below (one `use`, one branch in each
// dispatcher) and its name to the piece_style comment in common.scad. Nothing
// else in the project changes — no mechanism here knows a style by name.
//
// Why the names are prefixed rather than literally identical across styles:
// OpenSCAD has no namespaces and no dynamic `include`, so every style file
// has to be `use`d at once and the three PUBLIC names must therefore be
// unique. Everything private inside a style file is safe — a used file's
// modules resolve helpers in their own file's scope, so two styles may both
// define `foot()` without interfering (verified by test, not assumed).
use <styles/monolith.scad>
use <styles/familiar.scad>

module style_silhouette2d(t) {
    if      (piece_style == "monolith") monolith_silhouette2d(t);
    else if (piece_style == "familiar") familiar_silhouette2d(t);
    else assert(false, str("pieces.scad: unknown piece_style \"", piece_style, "\""));
}
function style_pheight(t) =
      piece_style == "monolith" ? monolith_pheight(t)
    : piece_style == "familiar" ? familiar_pheight(t)
    : assert(false, str("pieces.scad: unknown piece_style \"", piece_style, "\"")) 0;
function style_drains(t) =
      piece_style == "monolith" ? monolith_drains(t)
    : piece_style == "familiar" ? familiar_drains(t)
    : assert(false, str("pieces.scad: unknown piece_style \"", piece_style, "\"")) 0;
// ------------------------------------------------------ END THE ENUM --

PART = "all";   // overridden with -D on the command line

// Real printed height of a piece. Public: other files and the docs use it.
function piece_height(t) = style_pheight(t);

// ---- The lightening cavity --------------------------------------------
// Everything ABOVE the pivot, inset by hollow_wall on all six sides.
// NOTE the order of operations: the inset offset is taken on the silhouette
// AT FINAL SIZE, so hollow_wall stays a real 0.9 mm however a style scales
// its artwork.
// The keep-out solid comes from gravity_gimbal.scad because it is pivot
// hardware, not artwork: under "pin" it is just the wall around the bore,
// under "magnet" it also floors the retaining disc's counterbore.
module hollow_cavity(t, H, py) {
    difference() {
        translate([0, -py, hollow_wall])
            linear_extrude(height = piece_thk - 2*hollow_wall)
                difference() {
                    intersection() {
                        offset(r = -hollow_wall) style_silhouette2d(t);
                        // keep only what is ABOVE the pivot
                        translate([-2*H, py]) square([4*H, 1.5*H]);
                    }
                    // never break into the pivot bore: leave a full wall round it
                    translate([0, py]) circle(d = pivot_bore_dia() + 2*hollow_wall);
                }
        pivot_cavity_keepout();
    }
}

module piece(t) {
    H  = piece_height(t);
    py = pivot_frac * H;   // pivot height from base == the piece's own centre
    difference() {
        // Body, translated so the pivot point sits at the origin.
        translate([0, -py, 0])
            linear_extrude(height = piece_thk) style_silhouette2d(t);

        // The pivot itself: bore, plus the disc counterbore under "magnet".
        body_pivot_cut();

        hollow_cavity(t, H, py);

        // Drains: BACK face only, so the front stays a clean silhouette. One
        // per connected cavity region — the style says where, because only
        // the style knows where its cavity is broad.
        for (g = style_drains(t))
            translate([g[0], -py + g[1], piece_thk - hollow_wall - 0.6])
                cylinder(d = drain_dia, h = hollow_wall + 0.7);
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
