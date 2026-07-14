// =====================================================================
// frame.scad — bezel that holds the board panel and mounts the turntable
// =====================================================================
//
// A picture-frame bezel that:
//   * captures the board_panel front edge (a rabbet/lip),
//   * gives the whole assembly rigidity so it stays flat while rotating,
//   * carries four bolt bosses on its back that mate the turntable
//     (rotation_hub.scad) at the center of mass,
//   * hides the per-square steel washers, sensor wiring and electronics
//     behind the panel.
//
// Print as four L-shaped corners (epoxy the butt joints; the bezel lip and
// the four turntable bolts give the ring its rigidity), or print the full
// ring in one piece on a large bed.
//
//   openscad -D 'PART="corner"' -o frame_corner.stl frame.scad   // x4
//   (the default render below is the full ring, for preview)
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
    // Back web: two diagonal straps across the open back (behind the panel,
    // which sits at z = lip .. lip + board_thickness) that carry the
    // turntable bolt bosses and tie them into the bezel ring. Without these
    // the bosses would float in the panel-pocket void. The straps run
    // corner-to-corner because the square panel pocket leaves ring material
    // on the diagonal only near the corners (radius ~outer/sqrt(2)).
    web_len = outer * sqrt(2) - 26;
    for (a = [45, 135])
        rotate([0, 0, a])
            translate([-web_len/2, -12, frame_h - wall])
                cube([web_len, 24, wall]);
    // Turntable bolt bosses on the straps, at hub_bolt_r (common.scad) —
    // the SAME shared value the turntable's bolt pattern uses, at the same
    // 45/135/225/315 deg angles, so the two parts actually mate. The 45 deg
    // offset also keeps each boss whole within one printed corner.
    translate([0,0,frame_h - wall])
        for (a = [45:90:359])
            rotate([0,0,a]) translate([hub_bolt_r, 0, 0])
                difference() {
                    cylinder(d = 9, h = wall + 4);
                    translate([0,0,-0.5]) cylinder(d = m3_tap, h = wall + 5);
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
        // Keep the +X+Y quadrant; tall enough to include the bolt-boss
        // tips, which project 4 mm past the frame back.
        cube([outer/2, outer/2, frame_h + 6]);
    }
}
module frame_full_at_origin() {
    translate([outer/2, outer/2, 0]) frame_full();
}

PART = "full";   // "full" | "corner"
if (PART == "corner") frame_corner();
else frame_full();
