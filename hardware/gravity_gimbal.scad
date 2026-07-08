// =====================================================================
// gravity_gimbal.scad — the self-righting pivot ("pieces turn by gravity")
// =====================================================================
//
// This is the mechanism that makes a piece stay upright no matter how the
// board is rotated. It is printed as TWO parts plus one snap cap:
//
//   1) HUB PUCK  — a disc with a neodymium magnet press-fit in its back
//                  (grips the steel-backed board) and an AXLE POST on its
//                  front. The puck can be slid to any square; it rotates
//                  WITH the board when the board flips.
//
//   2) BODY BORE — a hole through the piece silhouette (see pieces.scad)
//                  that drops over the axle post. The body spins freely on
//                  the post. Because the body is bottom-weighted, gravity
//                  keeps it upright: as the board turns, the body counter-
//                  rotates on the post and never appears upside-down.
//
//   3) SNAP CAP  — a small printed cap that clips into the end of the axle
//                  so the body cannot fall off, while still spinning.
//
// Print the hub and cap in any material; PETG is a good tough choice.
// Keep the axle friction LOW (a drop of dry PTFE lube helps) so the
// pendulum settles quickly.
// =====================================================================

include <common.scad>

// ---- Hub puck: magnet in back, axle post on front --------------------
module hub_puck() {
    difference() {
        union() {
            // Puck body.
            cylinder(d = hub_dia, h = hub_thk);
            // Axle post on the front (room-facing) side.
            translate([0, 0, hub_thk])
                axle_post();
        }
        // Magnet cavity opening on the BACK (wall-facing) face.
        translate([0, 0, -0.01])
            cylinder(d = magnet_dia + 2*magnet_fit, h = magnet_thk + 0.01);
    }
}

// The axle post + snap groove + retention lip at the tip.
module axle_post() {
    groove_z = axle_len - cap_dia * 0.35;   // where the cap clips
    difference() {
        union() {
            cylinder(d = axle_dia, h = axle_len);
            // Retention lip (slightly wider tip so the cap snaps behind it).
            translate([0, 0, axle_len - 0.8])
                cylinder(d1 = axle_dia, d2 = axle_dia + 1.2, h = 0.8);
        }
        // Snap groove.
        translate([0, 0, groove_z])
            rotate_extrude()
                translate([axle_dia/2 - 0.4, 0])
                    circle(d = 1.0);
    }
}

// ---- Snap cap: retains the body on the post but lets it spin ----------
module snap_cap() {
    difference() {
        cylinder(d = cap_dia, h = cap_dia * 0.5);
        // Bore that grips the axle groove.
        translate([0, 0, -0.01])
            cylinder(d = axle_dia + 2*axle_fit, h = cap_dia * 0.5 + 0.02);
        // Internal bump matching the groove (printed as a shallow ring).
        translate([0, 0, cap_dia * 0.25])
            rotate_extrude()
                translate([(axle_dia + 2*axle_fit)/2, 0])
                    circle(d = 0.9);
    }
}

// ---- The through-bore a piece body needs (subtract from the body) ----
// Placed at the pivot point of a piece. The body rides on the post.
module body_bore() {
    cylinder(d = axle_dia + 2*axle_fit, h = piece_thk + 1, center = false);
}

// ---- Preview / test print layout -------------------------------------
// Renders hub + cap side by side so you can print a single test pair,
// verify the magnet press-fit and that the cap snaps and spins.
module gimbal_testprint() {
    hub_puck();
    translate([hub_dia + 8, 0, 0]) snap_cap();
}

gimbal_testprint();
