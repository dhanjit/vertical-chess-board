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
// 20T pulley and a 200T rim that is 10:1 — a NEMA-17 turns the ~2-3 kg board
// smoothly and holds position under power-off if you add a small detent.
// The rim must be big enough to CLEAR the turntable disc (bearing_od + 28);
// common.scad's ring_gear_teeth comment gives the constraint.
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
// Tooth-gap cutters are kept clear of the outer wall (outer r = r+0.9,
// cutters reach r+0.6) and all cuts overhang top+bottom by 0.5, so no cut
// face is coplanar with a rim face -> the result stays a clean 2-manifold.
// (For a precision pulley use a GT2 gear library; the bolt interface is
// unchanged — see the note in the file header.)
module gt2_rim(pitch_dia, teeth, h) {
    r = pitch_dia/2;
    difference() {
        cylinder(d = pitch_dia + 1.8, h = h);
        translate([0, 0, -0.5]) cylinder(d = pitch_dia - 3, h = h + 1);
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
                translate([dx, dy, 0]) cylinder(d = m3_clear, h = plate_thk + 1);
        }
        // Wall mounting holes (4x, keyhole-friendly).
        for (a = [45:90:359])
            rotate([0,0,a]) translate([plate_dia/2 - 10, 0, -0.5])
                cylinder(d = 5, h = plate_thk + 1);
        // Home-position index sensor pocket (hall) — on the same radius as
        // the turntable's index magnets so they pass directly over it.
        translate([hub_bolt_r, 0, plate_thk - 4])
            cube([8, 6, 5], center = true);
    }
}

// ---- Turntable (bolts to board frame) --------------------------------
// Disc is bearing_od + 28 so the frame bolts (hub_bolt_r, OUTSIDE the
// bearing race) and the index magnets both land on solid material. Bolts
// sit at 45/135/225/315 deg, index magnets at 0/180 — no collision.
module turntable() {
    disc_od = bearing_od + 28;
    difference() {
        union() {
            cylinder(d = disc_od, h = turntable_thk);
            // Toothed drive rim (clears the disc; see common.scad note).
            gt2_rim(rim_pitch_dia, rim_teeth, turntable_thk);
            // Bridge spokes from the disc edge out to the rim. They stop
            // 1 mm short of the pitch radius so they anchor into the rim's
            // inner wall without filling any belt-tooth gaps.
            for (a = [0:60:359])
                rotate([0,0,a])
                    translate([0, -3, 0]) cube([rim_pitch_dia/2 - 1, 6, turntable_thk]);
        }
        // Rotating-race recess.
        translate([0,0,turntable_thk - 3])
            cylinder(d = bearing_od + slop*2, h = 4);
        // Central bore.
        translate([0,0,-0.5]) cylinder(d = bearing_id - 6, h = turntable_thk + 1);
        // Bolt pattern up into the board frame (hub_bolt_r in common.scad —
        // the SAME value frame.scad uses, so the parts actually mate).
        for (a = [45:90:359])
            rotate([0,0,a]) translate([hub_bolt_r, 0, -0.5])
                cylinder(d = m3_clear, h = turntable_thk + 1);
        // Two home-index magnet pockets, 180 deg apart (White-up / Black-up),
        // on hub_bolt_r so they pass over the wall plate's index sensor.
        for (a = [0, 180])
            rotate([0,0,a]) translate([hub_bolt_r, 0, turntable_thk - magnet_thk])
                cylinder(d = magnet_dia + 2*magnet_fit, h = magnet_thk + 0.5);
    }
}

// ---- GT2 20T drive pulley (or buy one — cheap and better) -------------
module drive_pulley() {
    pd = motor_gear_teeth * gt2_pitch / 3.14159265;
    difference() {
        union() {
            gt2_rim(pd, motor_gear_teeth, 7);
            cylinder(d = pd - 2, h = 7);           // solid hub filling the rim
            cylinder(d = pd + 4, h = 1);           // lower flange
            translate([0,0,7]) cylinder(d = pd + 4, h = 1); // upper flange
        }
        translate([0,0,-0.5]) cylinder(d = 5 + slop, h = 9);   // 5 mm motor shaft
        // Radial grub-screw bore (M3) — reaches the shaft through the hub wall.
        translate([0, 0, 3.5]) rotate([0, 90, 0]) cylinder(d = m3_clear, h = pd);
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
