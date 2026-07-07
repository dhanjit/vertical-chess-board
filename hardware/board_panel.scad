// =====================================================================
// board_panel.scad — the vertical 8x8 playing surface
// =====================================================================
//
// Printed as a shallow TRAY: the closed face is the FRONT (the playing
// surface, printed face-down for a clean finish); the open face is the
// BACK (toward the wall), which holds the piece-holding hardware and, later,
// the sensor + electronics.
//
// FRONT (room-facing):
//   * 8x8 grid; dark squares recessed by `tile_engrave` (two-color print or
//     paint fill); thin engraved grid lines; a..h / 1..8 border labels.
//
// BACK (wall-facing), per square:
//   * a BOSS with a shallow pocket for a STEEL WASHER pressed against the
//     back of the front wall. The piece magnet grips the washer through the
//     front wall AND snaps to its center -> pieces self-center on the square.
//   * a smaller blind pocket behind the washer for a HALL SENSOR. The sensor
//     reads the piece magnet through the washer's CENTER HOLE (so it is not
//     magnetically shielded) plus the thin front wall.
//   * cross RIBS stiffen the large thin front wall.
//
// Print whole on a large bed, or in quarters for a small bed:
//   openscad -D 'QUARTER="bl"'  -o panel_bl.stl  board_panel.scad
//   openscad -D 'QUARTER="all"' -o panel.stl     board_panel.scad
// =====================================================================

include <common.scad>

QUARTER   = "all";        // "all" | "bl" | "br" | "tl" | "tr"
rib_w     = 2.4;          // stiffening rib thickness
boss_wall = 3;            // material around each washer pocket
label_depth = 0.8;
label_size  = board_margin * 0.45;

fw_inner  = board_thickness - front_wall;   // z of the front-wall inner face

// ---- Outer tray: full-thickness rim + thin front wall over the grid ---
module shell() {
    difference() {
        cube([panel_size, panel_size, board_thickness]);
        // Hollow the back over the grid, leaving the front wall + the rim.
        translate([board_margin, board_margin, -0.01])
            cube([grid_size, grid_size, fw_inner + 0.01]);
    }
}

// ---- Front engraving: dark squares + grid lines ----------------------
module front_engrave() {
    for (f = [0:7], r = [0:7])
        if (is_dark(f, r)) {
            c = sq_center(f, r);
            translate([c[0], c[1], board_thickness - tile_engrave])
                linear_extrude(tile_engrave + 0.1)
                    square(square_size - 0.6, center = true);
        }
    for (i = [0:8]) {
        translate([board_margin + i*square_size, board_margin + grid_size/2,
                   board_thickness - 0.4])
            linear_extrude(0.5) square([0.8, grid_size], center = true);
        translate([board_margin + grid_size/2, board_margin + i*square_size,
                   board_thickness - 0.4])
            linear_extrude(0.5) square([grid_size, 0.8], center = true);
    }
}

// ---- Border labels a..h / 1..8 --------------------------------------
module labels() {
    files = ["a","b","c","d","e","f","g","h"];
    for (f = [0:7]) {
        c = sq_center(f, 0);
        translate([c[0], board_margin*0.5, board_thickness - label_depth])
            linear_extrude(label_depth + 0.1)
                text(files[f], size = label_size, halign = "center",
                     valign = "center", font = "Liberation Sans:style=Bold");
    }
    for (r = [0:7]) {
        c = sq_center(0, r);
        translate([board_margin*0.5, c[1], board_thickness - label_depth])
            linear_extrude(label_depth + 0.1)
                text(str(r+1), size = label_size, halign = "center",
                     valign = "center", font = "Liberation Sans:style=Bold");
    }
}

// ---- Stiffening ribs across the cavity (both directions) -------------
module ribs() {
    for (i = [1:7]) {
        translate([board_margin, board_margin + i*square_size - rib_w/2, 0])
            cube([grid_size, rib_w, fw_inner]);
        translate([board_margin + i*square_size - rib_w/2, board_margin, 0])
            cube([rib_w, grid_size, fw_inner]);
    }
}

// ---- Per-square washer boss (added material) -------------------------
// A stud hanging from the front-wall inner face down through the cavity,
// giving material to seat the washer (at the front) and hold the sensor
// (behind it). Prints as an upward stud when the panel is face-down.
module square_bosses() {
    for (f = [0:7], r = [0:7]) {
        c = sq_center(f, r);
        translate([c[0], c[1], 0])
            cylinder(d = washer_od + 2*washer_fit + 2*boss_wall, h = fw_inner);
    }
}

// ---- Per-square subtractions: washer pocket + sensor bore ------------
module square_pockets() {
    for (f = [0:7], r = [0:7]) {
        c = sq_center(f, r);
        // Washer pocket: seats against the back of the front wall.
        translate([c[0], c[1], fw_inner - washer_thk])
            cylinder(d = washer_od + 2*washer_fit, h = washer_thk + 0.01);
        // Sensor bore: from the open back up to the washer floor; the sensor
        // slides in from behind and its tip sits under the washer's hole.
        translate([c[0], c[1], -0.01])
            cylinder(d = sensor_dia + 2*slop, h = fw_inner - washer_thk + 0.02);
    }
}

// ---- Corner mount bosses (bolt to the frame) -------------------------
module mount_bosses() {
    for (x = [board_margin*0.5, panel_size - board_margin*0.5],
         y = [board_margin*0.5, panel_size - board_margin*0.5])
        translate([x, y, 0])
            difference() {
                cylinder(d = 12, h = board_thickness);
                translate([0,0,-0.01]) cylinder(d = 3.2, h = board_thickness + 0.02);
            }
}

module panel_solid() {
    difference() {
        union() {
            shell();
            ribs();
            square_bosses();
            mount_bosses();
        }
        front_engrave();
        labels();
        square_pockets();
    }
}

// ---- Quartering for smaller print beds ------------------------------
module panel() {
    if (QUARTER == "all") {
        panel_solid();
    } else {
        half = panel_size/2;
        xr = (QUARTER == "bl" || QUARTER == "tl") ? [0, half] : [half, panel_size];
        yr = (QUARTER == "bl" || QUARTER == "br") ? [0, half] : [half, panel_size];
        intersection() {
            panel_solid();
            translate([xr[0], yr[0], -1])
                cube([xr[1]-xr[0], yr[1]-yr[0], board_thickness + 2]);
        }
    }
}

panel();
