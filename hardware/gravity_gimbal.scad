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
//   3) SNAP CAP  — a small printed cap that snaps over a flared lip at the
//                  axle tip so the body cannot fall off, while still
//                  spinning. Three slits let its grip fingers flex over
//                  the lip during assembly.
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

// The axle post: plain full-diameter shaft (no groove — a groove would neck
// the 4 mm post to a break point) with a printable double-cone snap LIP at
// the tip. The cap's fingers ride the entry ramp out, then settle behind
// the lip. Both cones are ~45 deg, so the post prints upright w/o supports.
lip_d = axle_dia + 1.2;      // widest point of the tip lip
module axle_post() {
    cylinder(d = axle_dia, h = axle_len - 1.6);
    // Root fillet: 45-deg cone strengthens the layer-line-weak root against
    // sideways knocks. Pieces countersink their bore to clear it.
    cylinder(d1 = axle_dia + 2*axle_root_fillet, d2 = axle_dia,
             h = axle_root_fillet);
    // Support cone (widens toward the tip).
    translate([0, 0, axle_len - 1.6])
        cylinder(d1 = axle_dia, d2 = lip_d, h = 0.8);
    // Entry ramp (narrows to the very tip so the cap slides on easily).
    translate([0, 0, axle_len - 0.8])
        cylinder(d1 = lip_d, d2 = axle_dia + 0.2, h = 0.8);
}

// ---- Snap cap: retains the body on the post but lets it spin ----------
// A short grip bore (split into three fingers by the slits) flexes over the
// tip lip; the lip then sits in a wider internal chamber and the fingers'
// rear shoulder retains it. Closed back hides the post tip. Pulls off with
// firm finger pressure for servicing.
module snap_cap() {
    grip = 2.2;    // length of the finger (grip) zone
    difference() {
        cylinder(d = cap_dia, h = 5.5);
        // Grip bore (rides the plain 4 mm post).
        translate([0, 0, -0.01])
            cylinder(d = axle_dia + 2*axle_fit, h = grip + 0.01);
        // Lip chamber (houses the flared tip; 5.5 total - 4.7 = solid back).
        translate([0, 0, grip])
            cylinder(d = lip_d + 0.6, h = 2.5);
        // Three radial slits so the grip fingers can flex over the lip.
        for (a = [0, 120, 240])
            rotate([0, 0, a])
                translate([cap_dia/2, 0, (grip + 1.5)/2])
                    cube([cap_dia, 1.2, grip + 1.5 + 0.02], center = true);
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
