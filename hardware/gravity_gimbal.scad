// =====================================================================
// gravity_gimbal.scad — the self-righting pivot ("pieces turn by gravity")
// =====================================================================
//
// This is the mechanism that makes a piece stay upright no matter how the
// board is rotated. TWO printed parts live in THIS file (the hub puck and the
// press cap), plus one bought steel dowel; the third printed part -- the piece
// body the dowel passes through -- comes from pieces.scad. All four are listed
// below so the stack reads in order:
//
//   1) HUB PUCK  — a Ø11.5 x 8 disc with a neodymium magnet press-fit in its
//                  back (grips the steel-backed board) and a bore in its front
//                  for the AXLE DOWEL. The puck can be slid to any square;
//                  it rotates WITH the board when the board flips.
//                  It is DELIBERATELY SMALL: at Ø22 it was a grey collar
//                  showing behind every piece. Ø11.5 is the size a piece's
//                  own waist can hide (see square_size in common.scad), and
//                  it is not marginal structurally -- a 3 g piece hanging
//                  11 mm proud tips it with ~0.0003 N.m against the magnet's
//                  ~0.03 N.m, ~90x margin.
//
//   2) AXLE      — a stock Ø3 x 16 mm STEEL DOWEL PIN, pressed into the hub
//                  until it bottoms on the magnet. BOUGHT, NOT PRINTED, and
//                  drawn in this file only for the assembly preview. Two
//                  reasons it is steel and thin: ground steel roughly halves
//                  the sliding friction against the piece's bore, and friction
//                  is what decides how straight a piece settles; and a Ø3
//                  steel dowel takes a 20 N sideways knock with 3.0x margin
//                  where the Ø4 PRINTED post it replaced had only 1.29x.
//                  Thinner AND stronger -- see common.scad.
//
//   3) BODY BORE — a hole through the piece silhouette (see pieces.scad)
//                  that drops over the dowel. The body spins freely on it.
//                  Because the body is bottom-heavy BY SHAPE (solid below the
//                  pivot, hollow above it — no ballast, nothing glued in),
//                  gravity keeps it upright: as the board turns, the body
//                  counter-rotates on the dowel and never appears upside-down.
//
//   4) PRESS CAP — a small Ø6 printed cap that grips the dowel tip by
//                  interference so the body cannot fall off, while still
//                  spinning. Three slits let its fingers spread.
//                  This is the ONE part of the mechanism that faces the room,
//                  sitting in the middle of the piece: Ø8 read as a deliberate
//                  button, Ø6 disappears into the waist.
//
// THE STACK, front to back:  cap (4.7) | piece (6) | hub (8) | magnet in hub.
// The dowel stands axle_len = 11 proud of the hub, and piece + cap grip = 9.5,
// so there is 1.5 mm of AXIAL FLOAT by design. That slack is not sloppiness:
// without it, print tolerance stacking could clamp the piece between cap and
// hub and stall the very rotation the mechanism exists to allow.
//
// Print the hub and cap in any material; PETG is a good tough choice.
//
// FRICTION IS THE TUNING KNOB, and it cuts both ways. Too much and the piece
// parks off-vertical. Too little and nothing damps the swing -- a piece on a
// bare ball bearing would ring for minutes after every board flip. Use a
// SILICONE DAMPING GREASE: it is viscous, so it kills the ringing, without
// adding the static friction that creates the off-vertical error in the first
// place. The modelled lean figures assume mu = 0.08 (greased steel on
// plastic), which is a TEXTBOOK number, not a measured one -- and nothing here
// has been printed yet. Printing one pawn and one hub is the cheapest way to
// settle it, and it is the test to do first.
// =====================================================================

include <common.scad>

// ---- Hub puck: magnet in the back, dowel bore in the front -----------
// The puck prints flat with no post and no supports. The Ø3 steel dowel is
// pressed in afterwards; it bottoms out on the back of the magnet, so the
// two cavities meet in the middle (magnet_thk 3 + axle_embed 5 = hub_thk 8)
// and there is no thin printed web between them to crack.
module hub_puck() {
    difference() {
        cylinder(d = hub_dia, h = hub_thk);
        // Magnet cavity opening on the BACK (wall-facing) face. Ø8.3 in an
        // Ø11.5 puck leaves a 1.6 mm wall all round the magnet.
        translate([0, 0, -0.01])
            cylinder(d = magnet_dia + 2*magnet_fit, h = magnet_thk + 0.01);
        // Dowel bore from the FRONT face, interference fit. Ends exactly on
        // the magnet, which is what the dowel bottoms out against.
        translate([0, 0, hub_thk - axle_embed])
            cylinder(d = axle_dia + axle_press_fit, h = axle_embed + 0.01);
        // Chamfer at the bore mouth so the dowel starts square when pressed.
        // It is cut INTO this face, so nothing protrudes and the piece needs
        // no matching countersink.
        translate([0, 0, hub_thk - axle_root_fillet])
            cylinder(d1 = axle_dia + axle_press_fit,
                     d2 = axle_dia + axle_press_fit + 2*axle_root_fillet,
                     h  = axle_root_fillet + 0.01);
    }
}

// The dowel itself is BOUGHT, not printed (stock Ø3 x 16 mm). Drawn here only
// so the assembly preview has something to show; it is not exported.
module axle_dowel() {
    color("Silver")
        translate([0, 0, hub_thk - axle_embed])
            cylinder(d = axle_dia, h = axle_embed + axle_len);
}

// ---- Press cap: retains the body on the dowel but lets it spin --------
// A steel dowel has no lip to snap behind, so the cap grips the plain shaft
// by interference instead: an undersize bore split into three fingers by the
// slits, which spread as it is pushed on. Closed back hides the dowel tip.
// Pulls off with firm finger pressure for servicing.
// It only has to resist knocks -- on a vertical board gravity pulls the piece
// DOWN the silhouette, not OFF the axle.
module press_cap() {
    grip = 3.5;    // length of the finger (grip) zone. 3.5 + the 6 mm piece
                   //   = 9.5 against axle_len 11 -> the 1.5 mm axial float.
    back = 1.2;    // solid closed back over the dowel tip
    slit = 1.2;    // slit width. Ø6 cap over a Ø2.85 bore leaves a 1.58 mm
                   //   finger wall, so a 1.2 slit still prints as three
                   //   distinct fingers on a 0.4 mm nozzle.
    difference() {
        cylinder(d = cap_dia, h = grip + back);
        // Grip bore: interference on the plain dowel (cap_grip_fit < 0).
        translate([0, 0, -0.01])
            cylinder(d = axle_dia + cap_grip_fit, h = grip + 0.01);
        // Three radial slits so the fingers can spread over the dowel.
        for (a = [0, 120, 240])
            rotate([0, 0, a])
                translate([cap_dia/2, 0, grip/2])
                    cube([cap_dia, slit, grip + 0.02], center = true);
    }
}

// ---- The through-bore a piece body needs (subtract from the body) ----
// Placed at the pivot point of a piece; pieces.scad subtracts this rather
// than repeating the arithmetic. The body rides straight on the steel dowel.
module body_bore() {
    cylinder(d = axle_dia + 2*axle_fit, h = piece_thk + 1, center = false);
}

// ---- Preview / test print layout -------------------------------------
// Renders hub + cap side by side so you can print a single test pair,
// verify the magnet press-fit and that the cap snaps and spins.
module gimbal_testprint() {
    hub_puck();
    translate([hub_dia + 8, 0, 0]) press_cap();
}

gimbal_testprint();
