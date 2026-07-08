// =====================================================================
// rotation_hub.scad — wall mount + turntable that flips the board 180 deg
// =====================================================================
//
// Two printed parts sandwich an off-the-shelf lazy-susan bearing:
//
//   WALL PLATE   — screws to the wall (or a French cleat). Holds the fixed
//                  race of the lazy-susan bearing, a NEMA-17 stepper on a
//                  cantilever arm, and a central pass-through for wiring /
//                  an optional slip ring.
//
//   TURNTABLE    — bolts to the back of the board frame. Holds the rotating
//                  race of the bearing and a toothed rim driven by a GT2
//                  timing belt from the stepper pulley. A magnet + hall
//                  index sensor mark the two home positions (White-up and
//                  Black-up), 180 deg apart.
//
// Drive ratio: motor_gear_teeth : ring_gear_teeth (common.scad). With a
// 20T pulley and a 120T rim that is 6:1 — a NEMA-17 turns the ~2-3 kg board
// smoothly and holds position under power-off if you add a small detent.
//
// NOTE ON GEAR TEETH: the rim teeth here are a GT2 approximation (2 mm
// pitch, rounded). For a precision pulley/rim use the BOSL2 `gears` or
// a `GT2_pulley` library; the interface bolt pattern is unchanged.
// =====================================================================

include <common.scad>

bearing_h        = 8;      // height of the lazy-susan bearing
plate_dia        = bearing_od + 30;
plate_thk        = 6;
turntable_thk    = 6;
gt2_pitch        = 2;
rim_teeth        = ring_gear_teeth;
rim_pitch_dia    = rim_teeth * gt2_pitch / 3.14159265;  // circumference = teeth*pitch
nema_offset      = rim_pitch_dia/2 + 16;                 // stepper distance from center

// ---- GT2-ish toothed rim (approximation) ----------------------------
module gt2_rim(pitch_dia, teeth, h) {
    r = pitch_dia/2;
    difference() {
        cylinder(d = pitch_dia + 1.2, h = h);
        cylinder(d = pitch_dia - 3, h = h + 1, center = false);
        // tooth gaps
        for (i = [0 : teeth-1]) {
            a = i * 360/teeth;
            rotate([0,0,a]) translate([r, 0, -0.5])
                cylinder(d = 1.2, h = h + 1, $fn = 16);
        }
    }
}

// ---- Wall plate ------------------------------------------------------
module wall_plate() {
    difference() {
        union() {
            cylinder(d = plate_dia, h = plate_thk);
            // Bearing seat (fixed race sits in this recess) -> raised lip.
            translate([0,0,plate_thk])
                difference() {
                    cylinder(d = bearing_od + 6, h = 3);
                    translate([0,0,-0.5]) cylinder(d = bearing_od + slop*2, h = 4);
                }
            // Stepper cantilever arm.
            hull() {
                cylinder(d = 30, h = plate_thk);
                translate([nema_offset, 0, 0]) cylinder(d = 42, h = plate_thk);
            }
        }
        // Central wiring / slip-ring pass-through.
        translate([0,0,-0.5]) cylinder(d = bearing_id - 6, h = plate_thk + 6);
        // NEMA-17 mount: 31 mm bolt square + 22 mm center bore.
        translate([nema_offset, 0, -0.5]) {
            cylinder(d = 23, h = plate_thk + 1);
            for (dx = [-15.5, 15.5], dy = [-15.5, 15.5])
                translate([dx, dy, 0]) cylinder(d = 3.2, h = plate_thk + 1);
        }
        // Wall mounting holes (4x, keyhole-friendly).
        for (a = [45:90:359])
            rotate([0,0,a]) translate([plate_dia/2 - 10, 0, -0.5])
                cylinder(d = 5, h = plate_thk + 1);
        // Home-position index sensor pocket (hall).
        translate([bearing_od/2 + 4, 0, plate_thk - 4])
            cube([8, 6, 5], center = true);
    }
}

// ---- Turntable (bolts to board frame) --------------------------------
module turntable() {
    difference() {
        union() {
            cylinder(d = bearing_od + 6, h = turntable_thk);
            // Toothed drive rim.
            translate([0,0,0]) gt2_rim(rim_pitch_dia, rim_teeth, turntable_thk);
            // Bridge spokes from bearing hub out to the rim.
            for (a = [0:60:359])
                rotate([0,0,a])
                    translate([0, -3, 0]) cube([rim_pitch_dia/2, 6, turntable_thk]);
        }
        // Rotating-race recess.
        translate([0,0,turntable_thk - 3])
            cylinder(d = bearing_od + slop*2, h = 4);
        // Central bore.
        translate([0,0,-0.5]) cylinder(d = bearing_id - 6, h = turntable_thk + 1);
        // Bolt pattern up into the board frame (matches frame.scad bosses).
        for (a = [0:90:359])
            rotate([0,0,a]) translate([bearing_od/2 - 4, 0, -0.5])
                cylinder(d = 3.2, h = turntable_thk + 1);
        // Two home-index magnet pockets, 180 deg apart (White-up / Black-up).
        for (a = [0, 180])
            rotate([0,0,a]) translate([bearing_od/2 + 1, 0, turntable_thk - magnet_thk])
                cylinder(d = magnet_dia + 2*magnet_fit, h = magnet_thk + 0.5);
    }
}

// ---- GT2 20T drive pulley (or buy one) -------------------------------
module drive_pulley() {
    pd = motor_gear_teeth * gt2_pitch / 3.14159265;
    difference() {
        union() {
            gt2_rim(pd, motor_gear_teeth, 7);
            cylinder(d = pd + 4, h = 1);           // lower flange
            translate([0,0,7]) cylinder(d = pd + 4, h = 1); // upper flange
        }
        translate([0,0,-0.5]) cylinder(d = 5 + slop, h = 9);   // 5 mm motor shaft
        translate([pd/2 - 1, 0, 1]) cylinder(d = 3.2, h = 4);  // grub screw
    }
}

// ---- Exploded preview ------------------------------------------------
module assembly_preview() {
    color("silver") wall_plate();
    color("gray")   translate([0,0,plate_thk + 3 + bearing_h + 4]) turntable();
    color("orange") translate([nema_offset, 0, plate_thk + 4]) drive_pulley();
}

PART = "preview";  // "preview" | "wall" | "turntable" | "pulley"
if (PART == "wall") wall_plate();
else if (PART == "turntable") turntable();
else if (PART == "pulley") drive_pulley();
else assembly_preview();
