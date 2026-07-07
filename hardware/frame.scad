// =====================================================================
// frame.scad — bezel that holds the board panel and mounts the turntable
// =====================================================================
//
// A picture-frame bezel that:
//   * captures the board_panel front edge (a rabbet/lip),
//   * gives the whole assembly rigidity so it stays flat while rotating,
//   * carries four bolt bosses on its back that mate the turntable
//     (rotation_hub.scad) at the center of mass,
//   * hides the steel sheet, sensor PCB and wiring behind the panel.
//
// Print as four L-shaped corners (default) that bolt together with the
// splices, or as full edges on a large bed.
//
//   openscad -D 'PART="corner"' -o frame_corner.stl frame.scad   // x4
// =====================================================================

include <common.scad>

frame_w       = board_margin + 12;   // how far the bezel oversails the panel
frame_h       = board_thickness + 14; // total depth (front lip + cavity)
lip           = 6;                     // front lip that overlaps the panel face
back_cavity   = 10;                    // depth behind panel for electronics
wall          = 4;

outer = panel_size + 2*12;             // outer edge of the bezel

module frame_full() {
    difference() {
        // Outer block.
        rrect3(outer, outer, frame_h, 6);
        // Panel pocket (panel drops in from the back).
        translate([0, 0, lip])
            rrect3(panel_size + 2*slop, panel_size + 2*slop, frame_h, 2);
        // Front opening (see the board through the lip).
        translate([0, 0, -1])
            rrect3(grid_size + 2*board_margin - 2*4, grid_size + 2*board_margin - 2*4,
                   lip + 2, 4);
    }
    // Turntable bolt bosses on the back, on a circle matching the hub
    // (same radius as the turntable's bolt pattern in rotation_hub.scad).
    translate([0,0,frame_h - wall])
        for (a = [0:90:359])
            rotate([0,0,a]) translate([(bearing_od + 6)/2 - 4, 0, 0])
                difference() {
                    cylinder(d = 9, h = wall + 4);
                    translate([0,0,-0.5]) cylinder(d = 2.9, h = wall + 5);
                }
}

// A 3D rounded rectangular prism centered in XY.
module rrect3(w, h, d, r) {
    linear_extrude(d)
        offset(r) offset(-r)
            square([w, h], center = true);
}

// One printable corner (a quadrant of the bezel).
module frame_corner() {
    intersection() {
        translate([-outer/2, -outer/2, 0]) frame_full_at_origin();
        cube([outer/2, outer/2, frame_h]);   // keep the +X+Y quadrant
    }
}
module frame_full_at_origin() {
    translate([outer/2, outer/2, 0]) frame_full();
}

PART = "full";   // "full" | "corner"
if (PART == "corner") frame_corner();
else frame_full();
