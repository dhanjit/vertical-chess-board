// =====================================================================
// gravity_gimbal.scad — the self-righting pivot ("pieces turn by gravity")
// =====================================================================
//
// This is the mechanism that makes a piece stay upright no matter how the
// board is rotated. There are TWO architectures for it and this file builds
// both; `pivot_type` in common.scad picks one. They differ in WHERE THE
// MAGNET LIVES, and that single choice decides everything else.
//
// ---------------------------------------------------------------------
// pivot_type = "pin"  — the magnet is on the BOARD side.
//   PER PIECE: 3 PRINTED (piece body, hub puck, press cap)
//            + 2 BOUGHT  (Ø8 x 3 magnet, Ø3 x 16 steel dowel)
//            = 5 components, plus a felt disc over the magnet.
// ---------------------------------------------------------------------
//   1) HUB PUCK  — a Ø11.5 x 8 PRINTED disc with a neodymium magnet press-fit
//                  in its back (grips the steel-backed board) and a bore in
//                  its front for the AXLE DOWEL. Slides to any square and
//                  rotates WITH the board when the board flips.
//                  DELIBERATELY SMALL: at Ø22 it was a grey collar showing
//                  behind every piece. Ø11.5 is what a piece's own waist can
//                  hide (see square_size in common.scad), and it is not
//                  marginal structurally — a 3 g piece hanging 11 mm proud
//                  tips it with ~0.0003 N.m against the magnet's ~0.03 N.m.
//   2) AXLE      — a stock Ø3 x 16 mm STEEL DOWEL PIN, BOUGHT not printed,
//                  pressed in until it bottoms on the magnet. Ground steel
//                  roughly halves the sliding friction against the piece's
//                  bore, and friction is what decides how straight a piece
//                  settles; a Ø3 steel dowel also takes a 20 N sideways knock
//                  with 3.0x margin where the Ø4 PRINTED post it replaced had
//                  only 1.29x. Thinner AND stronger.
//   3) BODY       — the silhouette plate, with a Ø3.70 bore through it
//                  (pieces.scad subtracts body_pivot_cut()). The bore is a
//                  HOLE, not a part: it spins freely on the dowel.
//   4) PRESS CAP — a Ø6 PRINTED cap gripping the dowel tip by interference so
//                  the body cannot fall off while still spinning. Three slits
//                  let its fingers spread. The one part of the mechanism that
//                  faces the room: Ø8 read as a deliberate button, Ø6
//                  disappears into the waist.
//   THE STACK, front to back:  cap (4.7) | piece (6) | hub (8) | magnet.
//   The dowel stands axle_len = 11 proud and piece + cap grip = 9.5, so there
//   is 1.5 mm of AXIAL FLOAT by design — without it, tolerance stacking could
//   clamp the piece between cap and hub and stall the rotation.
//   THE POINT OF THIS ARCHITECTURE: the magnet's mass is on the BOARD, so it
//   never enters the pendulum at all.
//
// ---------------------------------------------------------------------
// pivot_type = "magnet" — the magnet is IN THE PIECE.
//   PER PIECE: 1 PRINTED (the body)
//            + 2 BOUGHT  (Ø4 x 5 magnet, Ø9 x 0.8 steel disc)
//            = 3 components, and no felt disc.
// ---------------------------------------------------------------------
//   NO hub puck, NO dowel, NO cap — three named parts go away and one arrives
//   (the retaining disc), so the NET saving is TWO components. Where it really
//   lands is printing: PRINTED parts per piece go 3 -> 1, and there is nothing
//   to print but the piece itself.
//   1) MAGNET    — a BOUGHT Ø4 x 5 neodymium disc dropped into the piece's own
//                  bore from the BACK, flush with the back face, gripping the
//                  steel sheet directly. THE PIECE TURNS ON THE MAGNET: the
//                  magnet is the journal.
//   2) RETAINING — a BOUGHT Ø9 x 0.8 steel disc, held on the magnet's front
//      DISC        pole by that same magnet with NO GLUE, recessed into a
//                  1.0 mm counterbore in the piece's FRONT face. Being wider
//                  than the bore it cannot pass through it, so it is what
//                  stops the piece pulling off the magnet.
//
//   WHAT IT COSTS, measured rather than assumed (see the tables in the
//   piece_style/pivot_type comments in common.scad):
//     * r grows. In sin(lean) = mu*r/d, r is now the Ø4.70 magnet bore's
//       radius (2.35) instead of the Ø3.70 pin bore's (1.85).
//     * d shrinks. The magnet AND the disc ride WITH the piece, sitting
//       exactly on the pivot at ZERO lever arm, so they drag the combined
//       centre of mass toward the axis. Mass cancels for a single rigid
//       piece — but mass added AT the pivot does not, and this is exactly
//       that case.
//   Together: roughly +0.4 to +0.6 deg of lean, for two fewer components per
//   piece — and two fewer PRINTED ones, which is the saving that matters.
//
//   TWO THINGS ABOUT THIS ARCHITECTURE ARE UNPROVEN, and neither is in the
//   lean numbers:
//     * nothing has verified that a Ø9 steel disc actually STAYS PUT on a
//       Ø4 magnet through a board flip;
//     * the disc bears on the counterbore floor and presses the piece's whole
//       back face onto the steel sheet with the magnet's full pull, so
//       rotation has to overcome FACE friction at silhouette radii, not just
//       bore friction at r = 2.35. The lean figures model bore friction only
//       and are therefore OPTIMISTIC for this architecture. Under "pin" the
//       piece bears on the hub puck's Ø11.5 face under its own weight only,
//       which is why the same objection does not apply there.
//   pivot_test_coupon() below is the cheap part that settles both.
//
// ---------------------------------------------------------------------
// Print the hub and cap in any material; PETG is a good tough choice.
//
// FRICTION IS THE TUNING KNOB, and it cuts both ways. Too much and the piece
// parks off-vertical. Too little and nothing damps the swing — a piece on a
// bare ball bearing would ring for minutes after every board flip. Use a
// SILICONE DAMPING GREASE: viscous, so it kills the ringing, without adding
// the static friction that creates the off-vertical error in the first place.
// The modelled lean figures assume mu = 0.08 (greased steel on plastic),
// which is a TEXTBOOK number, not a measured one — and NOTHING here has been
// printed yet. Printing one pawn and one hub is the cheapest way to settle
// it, and it is the test to do first.
// =====================================================================

include <common.scad>

// =====================================================================
// SHARED — what the piece body needs from the pivot, either architecture.
// pieces.scad calls these and never repeats the arithmetic itself.
// =====================================================================

// The bore the piece turns in. This is `r` (halved) in sin(lean) = mu*r/d.
function pivot_bore_dia() =
      pivot_type == "pin"    ? axle_dia + 2*axle_fit              // 3.70
    : pivot_type == "magnet" ? pivot_magnet_dia + 2*axle_fit      // 4.70
    : assert(false, str("gravity_gimbal.scad: unknown pivot_type \"", pivot_type, "\"")) 0;

// Diameter of the seat that receives the retaining disc ("magnet" only).
function disc_seat_dia() = retain_disc_dia + 2*disc_seat_slop;

// Everything subtracted from a piece body at the pivot. Piece coordinates:
// pivot on the origin, FRONT face at z = 0, BACK face at z = piece_thk.
module body_pivot_cut() {
    translate([0, 0, -0.5])
        cylinder(d = pivot_bore_dia(), h = piece_thk + 1);
    if (pivot_type == "magnet")
        // Seat for the steel retaining disc, in the FRONT face. 1.0 deep for
        // a 0.8 disc, so the disc sits 0.2 below flush and never rubs the
        // player's fingers before the piece does.
        translate([0, 0, -0.5])
            cylinder(d = disc_seat_dia(), h = disc_seat_depth + 0.5);
}

// Solid that the lightening cavity must NOT eat into.
// Under "pin" the cavity's own bore-wall circle is the whole story, so this
// is empty. Under "magnet" the disc seat is 1.0 deep and the cavity starts at
// hollow_wall = 0.9, so without this the seat would open straight into the
// cavity above the pivot and the disc would be left bearing on half a floor.
// It is a local collar, not a thicker front wall: it adds solid only within
// Ø(seat + 2 walls) of the axis, where the lever arm is ~0, so it costs
// almost nothing in `d`.
module pivot_cavity_keepout() {
    if (pivot_type == "magnet")
        translate([0, 0, -0.5])
            cylinder(d = disc_seat_dia() + 2*hollow_wall,
                     h = disc_seat_depth + hollow_wall + 0.5);
}

// =====================================================================
// PIVOT "pin" — the printed parts.
// =====================================================================

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
// It only has to resist knocks — on a vertical board gravity pulls the piece
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

// Hub + cap side by side: print one pair, verify the magnet press-fit and
// that the cap snaps on and still spins.
module gimbal_testprint() {
    hub_puck();
    translate([hub_dia + 8, 0, 0]) press_cap();
}

// =====================================================================
// PIVOT "magnet" — there are NO printed pivot parts.
// The magnet and the retaining disc are both bought. The only printed
// geometry is the bore and counterbore, and those live in the piece itself
// (body_pivot_cut above), so there is nothing here to export as a part.
// What IS worth printing is a coupon carrying exactly that geometry and
// nothing else, because it is what settles the two unproven claims in the
// header: press a Ø4 magnet in, stick the Ø9 disc on, put it on the steel
// sheet, and flip it. If the disc walks off, or if the coupon will not turn
// under a fingertip because its back face is clamped to the sheet, this
// architecture is answered for the cost of one 2 g print.
// =====================================================================
module pivot_test_coupon() {
    difference() {
        cylinder(d = 16, h = piece_thk);
        body_pivot_cut();
    }
}

// The two bought parts, drawn for the assembly preview only. NOT exported.
module pivot_magnet() {
    color("DimGray")
        translate([0, 0, disc_seat_depth])
            cylinder(d = pivot_magnet_dia, h = pivot_magnet_thk);
}
module retain_disc() {
    color("Silver")
        translate([0, 0, disc_seat_depth - retain_disc_thk])
            cylinder(d = retain_disc_dia, h = retain_disc_thk);
}

// ---- Render dispatch --------------------------------------------------
// Under "magnet" the hub and the cap are not part of the design at all, so
// they are not exported: the file renders the coupon instead.
if (pivot_type == "pin") gimbal_testprint();
else if (pivot_type == "magnet") pivot_test_coupon();
else assert(false, str("gravity_gimbal.scad: unknown pivot_type \"", pivot_type, "\""));
