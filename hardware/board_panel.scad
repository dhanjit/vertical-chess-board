// =====================================================================
// board_panel.scad — the vertical 8x8 playing surface (steel-sheet face)
// =====================================================================
//
// Printed as a shallow TRAY: the closed face is the FRONT (printed
// face-down for a flat gluing surface); the open face is the BACK (toward
// the wall) for sensors and wiring. The playing surface itself is a thin
// STEEL SHEET glued onto the front over the grid area: piece magnets grip
// the sheet DIRECTLY — the proven attachment every commercial magnetic
// wall set uses. Squares are painted / vinyl on the sheet; the printed
// border around it keeps the engraved a..h / 1..8 labels.
//
// Per square, the printed panel carries:
//   * a through BORE from the open back to the front face: a hall sensor
//     (Phase 2) slides in from behind until its tip sits flush at the face,
//     reading the piece magnet through a small hole laser-cut in the sheet
//     (`sheet_hole` in common.scad) — so the sheet never shields it.
//   * a BOSS around the bore, plus cross RIBS, stiffening the front wall.
//
// The steel sheet is bought / laser-cut, not printed. Export its 1:1
// cutting outline (grid square + the 64 sensing holes) for the fab shop:
//   openscad -D 'QUARTER="sheet_dxf"' -o steel_sheet.dxf board_panel.scad
// A plain un-holed sheet works fine for Phase 1 (no sensing).
//
// Print whole on a large bed, or in quarters for a small bed:
//   openscad -D 'QUARTER="bl"'   -o panel_bl.stl   board_panel.scad
//   openscad -D 'QUARTER="all"'  -o panel.stl      board_panel.scad
// Phase-0 test tile (1x2 squares — glue any steel offcut on its face):
//   openscad -D 'QUARTER="test"' -o board_test.stl board_panel.scad
// =====================================================================

include <common.scad>

QUARTER   = "all";        // "all" | "bl" | "br" | "tl" | "tr" | "test"
                          //   | "sheet" (3D ref) | "sheet_dxf" (2D cut path)
rib_w     = 2.4;          // stiffening rib thickness
boss_wall = 3;            // material around each sensor bore
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

// ---- Per-square sensor boss (added material) --------------------------
// A stud hanging from the front-wall inner face down through the cavity,
// giving the sensor bore a snug full-depth guide. Prints as an upward stud
// when the panel is face-down.
module sensor_bosses() {
    for (f = [0:7], r = [0:7]) {
        c = sq_center(f, r);
        translate([c[0], c[1], 0])
            cylinder(d = sensor_dia + 2*slop + 2*boss_wall, h = fw_inner);
    }
}

// ---- Per-square sensor bore: back cavity through to the front face ----
// The sensor slides in from behind; its tip ends up flush at the face,
// directly under the sheet's sensing hole. The face opening is hidden
// under the glued sheet.
module sensor_bores() {
    for (f = [0:7], r = [0:7]) {
        c = sq_center(f, r);
        translate([c[0], c[1], -0.01])
            cylinder(d = sensor_dia + 2*slop, h = board_thickness + 0.02);
    }
}

// ---- Corner mount bosses (bolt to the frame) -------------------------
module mount_bosses() {
    for (x = [board_margin*0.5, panel_size - board_margin*0.5],
         y = [board_margin*0.5, panel_size - board_margin*0.5])
        translate([x, y, 0])
            difference() {
                cylinder(d = 12, h = board_thickness);
                translate([0,0,-0.01]) cylinder(d = m3_clear, h = board_thickness + 0.02);
            }
}

module panel_solid() {
    difference() {
        union() {
            shell();
            ribs();
            sensor_bosses();
            mount_bosses();
        }
        labels();
        sensor_bores();
    }
}

// ---- Steel sheet cutting outline -------------------------------------
// 2D: the exact part to hand a laser/waterjet shop (or cut by hand and
// skip the holes for Phase 1). Origin at the sheet's own corner; it glues
// onto the panel covering the grid area exactly.
module sheet2d() {
    difference() {
        square(grid_size);
        if (sheet_hole > 0)
            for (f = [0:7], r = [0:7]) {
                c = sq_center(f, r);
                translate([c[0] - board_margin, c[1] - board_margin])
                    circle(d = sheet_hole);
            }
    }
}

// 3D reference of the same sheet (for previews / fit checks — not printed).
module sheet3d() {
    linear_extrude(height = sheet_thk) sheet2d();
}

// ---- Phase-0 test tile: a 1x2-square offcut of the panel -------------
// Same front wall and sensor bores as the real panel. Glue any steel
// offcut on its face and check the magnet holds, slides square-to-square
// nicely (tune the felt disc), and (Phase 2) that a hall sensor in the
// rear bore trips under a piece.
module board_test() {
    n      = 2;                        // squares
    border = 10;                       // rim around the squares
    tx     = n * square_size + 2*border;
    ty     = square_size + 2*border;
    difference() {
        union() {
            // Tray shell (rim + thin front wall, like the full panel).
            difference() {
                cube([tx, ty, board_thickness]);
                translate([border, border, -0.01])
                    cube([n * square_size, square_size, fw_inner + 0.01]);
            }
            // Sensor bosses.
            for (i = [0:n-1])
                translate([border + square_size*(i + 0.5), ty/2, 0])
                    cylinder(d = sensor_dia + 2*slop + 2*boss_wall,
                             h = fw_inner);
        }
        // Sensor bores, back cavity through to the face.
        for (i = [0:n-1])
            translate([border + square_size*(i + 0.5), ty/2, -0.01])
                cylinder(d = sensor_dia + 2*slop, h = board_thickness + 0.02);
    }
}

// ---- Quartering for smaller print beds ------------------------------
module panel() {
    if (QUARTER == "all") {
        panel_solid();
    } else if (QUARTER == "test") {
        board_test();
    } else if (QUARTER == "sheet") {
        sheet3d();
    } else if (QUARTER == "sheet_dxf") {
        sheet2d();
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
