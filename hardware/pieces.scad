// =====================================================================
// pieces.scad — the 6 chess pieces as self-righting flat silhouettes
// =====================================================================
//
// Each piece is a flat SILHOUETTE plate (a bas-relief profile) so it reads
// cleanly from across the living room and prints flat with no supports.
// It carries:
//   * a central PIVOT BORE (rides on the hub's steel dowel — see
//     gravity_gimbal.scad), reinforced by a round boss so thin silhouettes
//     keep a solid wall;
//   * a MODELLED CAVITY covering everything ABOVE the pivot, which is what
//     puts the centre of mass below the pivot so the piece self-rights.
//     There is no weight pocket and nothing to glue in — see the
//     bottom-heaviness note in common.scad for why shaped-in beats glued-in;
//   * a DRAIN HOLE through the back face into that cavity, so resin cannot
//     be trapped.
//
// The pivot sits at the silhouette's bounding-box CENTRE (pivot_frac 0.50),
// so the piece both reads centred in its square and rotates about its own
// centre when it settles.
//
// Usage from the command line (renders one piece to STL):
//   openscad -D 'PART="king"'  -o king.stl  pieces.scad
//   openscad -D 'PART="queen"' -o queen.stl pieces.scad
// PART can be: pawn knight bishop rook queen king  (or "all" for a tray)
//
// =====================================================================
// THE DESIGN LANGUAGE — "Tapered Monolith"
// =====================================================================
// Reverse-engineerable from the finished set, and every piece obeys it:
//   * every piece is ONE straight-sided taper standing on the shared foot
//     flare — same FOOT_H, same FLARE, the same single 1:4 slope;
//   * the taper runs up, stops, and ONE terminal event sits on top of it;
//   * the event is always NARROWER THAN THE FOOT: the foot is the widest
//     point of every piece, and the flare is said exactly once, at the
//     bottom;
//   * rank reads twice over — as height (26/30/32/35/38/42 nominal) and as
//     how far the taper ran before the event started.
// The restricted angle set: every edge in the set is vertical, horizontal,
// the foot kick, or THE taper (a single 1:4 slope, 14.04 deg off vertical).
// The knight's head is the one deliberate exception — see its branch.
// =====================================================================

include <common.scad>
use <gravity_gimbal.scad>

PART = "all";   // overridden with -D on the command line
// (piece_thk, piece_scale, pivot_frac, hollow_wall, drain_dia and the nominal
//  heights h_pawn..h_king all live in common.scad with the other shared
//  dimensions. The constants below are different in kind: they are the
//  DRAWING LANGUAGE of the artwork — no other part in the project references
//  them — and they are expressed in NOMINAL artwork mm, i.e. before
//  piece_scale. Mixing those into common.scad next to real millimetres would
//  be a trap, so they stay here.)

// ---- family constants: one value each, applied to the whole set ------
SLOPE  = 0.25;         // 1 in 4. The one taper of the set.
TH     = atan(SLOPE);  // 14.04 deg off vertical
FOOT_H = 3.6;          // height of the foot kick, same on every piece
FLARE  = 1.6;          // how far the foot kicks out per side, same on every piece
STROKE = 4.4;          // the one stroke width (pawn crown, cross limb, cross arm)
HALF   = STROKE / 2;
CORNER = 0.8;          // the one convex corner radius for the whole set
FILLET = 0.5;          // the one concave fillet radius for the whole set
                       // both global; neither is ever chosen per piece

// ---- the counting language -------------------------------------------
// Two derived lengths, both multiples of the one STROKE. Nothing on a crown
// is ever chosen by hand: give it a tip count and it measures itself.
SLOT  = HALF;             // 2.2  every cut in a crown is one half-stroke
TIP   = 0.75 * STROKE;    // 3.3  every tip left standing between two cuts
PITCH = TIP + SLOT;       // 5.5  tip-to-tip
function head_hw(n) = (n * PITCH - SLOT) / 2;   // 1.65 / 4.4 / 7.15 / 9.9
PEARL = 1.9;              // radius of the queen's point-tips: 0.25 proud of a TIP

// Boss around the pivot bore, in nominal artwork mm. It is unioned into the
// profile so it scales with the artwork like everything else: 7.1 * 1.222 =
// Ø8.68 real, around a Ø3.70 bore, i.e. a 2.49 mm wall. Minimal on purpose —
// it exists only so a thin part of a silhouette (the royals' HALF-wide waist)
// still has material round the bore. It is NOT what hides the hub puck; the
// scaled body does that on its own.
BOSS = 7.1;

// ---- bishop mitre, the one reworked head -----------------------------
B_SLOT = 26.5;     // how deep the cleft is driven
B_LIFT = 0.84;     // the cleft eats the dome's crown, so the head is lifted
                   // until the HORNS -- not the vanished crown -- reach H
B_TW   = 5.0;      // where the taper stops, half-width...
B_TY   = 28.0;     // ...and at what height. Chosen so the taper's edge and
                   // the mitre's meet at the same width where they cross
                   // (y~25.7, both ~5.6): near-tangent, so the mitre SWELLS
                   // out of the body instead of perching on it as a lump.

// The knight is the only asymmetric piece in the set, so it is the only one
// whose centre of mass is not free. KDX slides the head sideways until the
// area moment about x=0 cancels; TUNED numerically, not derived.
// FRAGILE: any edit to the knight's head polygon silently breaks the hang --
// the piece keeps rendering and keeps looking right, and then hangs
// permanently rotated. Re-measure com_x and re-solve KDX if you touch it.
KDX = 1.67;

// ---- 2D silhouette profiles ------------------------------------------
// All drawn in ABSOLUTE nominal mm (base on y=0, symmetric about x=0,
// topmost point exactly at y=H), then scaled by piece_scale in piece().

// The shared body: broad foot -> short kick -> one long confident taper.
// Base width is DERIVED from the slope, so rank literally is "how far you
// run the taper" and nothing is chosen per piece.
module tapered_body(top_hw, top_y) {
    base_hw = top_hw + SLOPE * (top_y - FOOT_H) + FLARE;
    foot_hw = base_hw - FLARE;
    polygon([[-base_hw, 0     ], [ base_hw, 0     ],
             [ foot_hw, FOOT_H], [ top_hw,  top_y ],
             [-top_hw,  top_y ], [-foot_hw, FOOT_H]]);
}

// A crown: a vertical-sided block of n tips, dropped below the shoulder so
// it always overlaps the taper as area, never merely touches it.
module head_block(hw, y0, y1) {
    translate([-hw, y0]) square([2 * hw, y1 - y0]);
}

// The n-1 cuts. Placed off the crown's own left edge, so they come out
// symmetric about x = 0 by arithmetic rather than by being centred by hand.
module cuts(n, y_top, depth) {
    hw = head_hw(n);
    for (i = [0 : n - 2])
        translate([-hw + TIP + i * PITCH, y_top - depth])
            square([SLOT, depth + 2]);
}

// An opening then a closing put the SAME two radii on every corner of every
// piece — convex (base corners, foot kick, cross tips) and concave (foot
// junction, cross armpits). No corner is ever radiused by hand.
module profile(t, H) {
    offset(r = -FILLET) offset(r = FILLET)
        offset(r = CORNER) offset(r = -CORNER)
            raw_profile(t, H);
}

module raw_profile(t, H) {
    if (t == "pawn") {
        // Squattest aspect ratio in the set, and the only piece whose outline
        // has ZERO events: the taper runs into a dome of radius HALF that is
        // TANGENT to it, so the boundary never breaks. Identified by absence.
        r  = HALF;
        ty = H - r * (1 - sin(TH));    // tangent point height
        tw = r * cos(TH);              // and its half-width
        tapered_body(tw, ty);
        translate([0, H - r]) circle(r = r);
        translate([0, pivot_frac * H]) circle(d = BOSS);
    } else if (t == "queen") {
        // Second-longest run of the taper, down to the king's own HALF-wide
        // waist. The ONE event: the taper stops and the piece OPENS into a
        // coronet — THREE cuts, the most in the set, leaving four points, and
        // every point is finished with a PEARL: a circle of radius 1.9 that
        // mushrooms 0.25 mm proud of its 3.3 mm shaft. That is what keeps the
        // queen off the rook: the rook's merlons end SQUARE and level, the
        // queen's points end ROUND. Structurally the coronet IS the king's
        // crossbar — the same horizontal jump out of the same HALF-wide neck —
        // only divided; the king answers with one undivided bar and 4 mm more
        // height. Nothing here necks below 3.7 mm, so there is no snap-prone
        // shaft anywhere on the piece.
        hw = head_hw(4);               // 9.9
        difference() {
            union() {
                tapered_body(HALF, 31.6);      // narrow waist, same as the king's
                head_block(hw, 31.0, 36.2);    // the bar
            }
            cuts(4, 36.2, 1.6);                // divided into four
        }
        for (i = [0 : 3])                      // the pearls
            translate([-hw + TIP/2 + i*PITCH, H - PEARL]) circle(r = PEARL);
        translate([0, pivot_frac * H]) circle(d = BOSS);
    } else if (t == "bishop") {
        // The taper stops wide, and the ONE event is the mitre: a dome of
        // radius 1.5*STROKE with a STROKE-wide cleft driven down through its
        // crown, leaving two horns of one STROKE each.
        //
        // The rule this head is obeying is about the BODY, not the notch:
        //     slim neck + bifurcated head  ->  reads as an open-end WRENCH
        //     broad body + bifurcated head ->  reads as a MITRE
        // A deeper cleft, a narrower cleft and a taller ogive head all still
        // read as a tool while the body stays a stick, because two prongs on a
        // handle IS a tool no matter how the prongs are drawn. So the body has
        // to go broad: B_TW/B_TY stop the taper at 5.0 half-width, high, so the
        // mitre SWELLS out of the body (the two curves cross at y~25.7 within
        // 0.05 mm of each other — near-tangent, so the pinch is a 1 mm swell,
        // not a shoulder) instead of perching on a neck.
        // THE PRICE: this bishop is the widest piece in the set (29.98 mm) and
        // has no waist-neck. It also tidies the family rule rather than
        // breaking it — the two ROYALS run the taper down to a HALF-wide neck
        // and jump out sideways; pawn, rook, knight and bishop all stop the
        // taper wide and set the event straight on it. The neck is a royalty
        // marker, which is what it looked like anyway.
        r  = 1.5 * STROKE;              // 6.6 — the mitre
        cy = H - r + B_LIFT;
        difference() {
            union() {
                tapered_body(B_TW, B_TY);
                translate([0, cy]) circle(r = r);
                translate([0, pivot_frac * H]) circle(d = BOSS);
            }
            translate([-HALF, B_SLOT]) square([STROKE, H + 6 - B_SLOT]);
        }
    } else if (t == "knight") {
        // The taper is cut off early and low; the ONE event is a head that
        // FACES LEFT -- the only broken mirror in the set. Muzzle low-left,
        // ear spike high-right, one deep notch between ear and brow. The head
        // is slid KDX to the right so the area moment about x=0 still cancels
        // and the piece hangs plumb rather than permanently rotated.
        //
        // *** THE SET'S ONE DELIBERATE LANGUAGE EXCEPTION. ***
        // This head polygon uses FREE ANGLES. That is a priced trade, not an
        // oversight, and it comes with a second cost: the knight's balance is
        // TUNED (via KDX above) rather than structural, so it is the one piece
        // whose hang can be broken by an edit that renders perfectly cleanly.
        //
        // Three redraws in the family's four angles were built and rendered (a
        // mirrored-lobe head, a two-placements-of-one-spur head, and a stepped-
        // slab head). All three fix the vocabulary AND make the balance
        // structural instead of tuned -- and all three stop being a horse. The
        // reason is a hard property of the language, not a drafting failure:
        // the allowed set has NO diagonal. Its only sloped lines are 14.04 and
        // 23.96 deg off VERTICAL, so a jaw line, a nose bridge and an ear spike
        // are unbuildable -- at SLOPE 0.25 a 5 mm horizontal run costs 20 mm of
        // height, which does not exist inside a 32 mm piece. The redraws came
        // out as, respectively: a centre-notched T that collides with the
        // rook's crenellation and the king's cross (and is WIDER AT THE HEAD
        // THAN AT THE FOOT, breaking the family's strongest clause); a lopsided
        // slab; and a pinwheel of alternating tabs that reads as a key.
        //
        // So: ONE piece in six keeps free angles above its shoulder, and in
        // exchange the set keeps a knight a player identifies by shape rather
        // than by elimination. The body below the pivot is the pure shared
        // taper, so the break is confined to the head's edge angles and nothing
        // else. If a future editor decides language purity outweighs
        // legibility, the stepped-slab redraw is the one to revisit.
        //
        // IF YOU EDIT THE POLYGON BELOW, YOU MUST RE-SOLVE KDX.
        tapered_body(5.3, 21.0);
        translate([KDX, 0]) polygon([
            [ 3.8, 20.0], [ 6.9, 23.8], [ 5.4, 27.4], [ 2.2, 29.2],
            [ 2.2, 32.0], [-0.2, 32.0], [-0.9, 28.2], [-2.8, 30.6],
            [-5.2, 30.4], [-6.6, 27.2], [-10.8, 26.4], [-10.4, 23.2],
            [-6.4, 22.4], [-3.4, 20.0]]);
        translate([0, pivot_frac * H]) circle(d = BOSS);
    } else if (t == "rook") {
        // The shortest run of the taper -- squattest body in the set.
        //
        // The rook is the piece most at risk of reading as a plant pot, and the
        // guard against it is the king's move: put the event INSIDE the width
        // the taper already owns. The king's cross arms are 7.26 against a 10.9
        // foot (67%); this parapet is 7.15 against a 10.50 foot (68%), so the
        // merlons sit within the silhouette instead of hanging over it, the
        // foot stays the widest thing on the piece, and the profile is monotone
        // from parapet to foot with no waist. Aspect lands at 0.671.
        //
        // Two details answer to the language rather than to taste:
        //   * the corbel steps out by HALF -- one half-stroke, the same
        //     quantity that cuts every crown in the set -- NOT by FLARE. The
        //     foot's kick is the only FLARE on the piece, said once.
        //   * the merlons are counted with the set's own counting language:
        //     n=3 tips of one TIP with two SLOT bites between them, so
        //     head_hw(3) measures the parapet itself. Three square merlons
        //     against the queen's four round pearls -- the square/round
        //     separator survives, and the count separates them too.
        //
        // THE PRICE, honestly: the merlon gaps are SLOT (2.2) not STROKE (4.4).
        // That is arithmetic, not taste -- three STROKE merlons parted by two
        // STROKE gaps need a 22 mm parapet, which drags the foot back out past
        // 25 mm and the aspect outside the family band. Also, at 1.81 deg the
        // rook has the HIGHEST LEAN IN THE SET against a 2.2 deg working limit,
        // so it carries the least stiction margin of the six. A further diet
        // would break it -- if anything in this set needs watching once real
        // friction is measured, it is this piece.
        hw = head_hw(3);                // 7.15 - three merlons, two SLOT bites
        ty = 19.4;                      // where the taper stops
        tw = hw - HALF;                 // 4.95 - one half-stroke inside the parapet
        difference() {
            union() {
                tapered_body(tw, ty);
                head_block(hw, ty - 1.0, H);
                translate([0, pivot_frac * H]) circle(d = BOSS);
            }
            cuts(3, H, 5.0);
        }
    } else {
        // KING. Tallest, leanest run of the same taper. The single event is a
        // cross at the apex: horizontal width appearing exactly where the taper
        // has thinned to one stroke. Limb and arm are both one STROKE.
        tapered_body(HALF, 32.0);
        translate([-HALF, 30.0]) square([STROKE, H - 30.0]);      // vertical limb
        translate([-3.3*HALF, 33.6]) square([6.6*HALF, STROKE]);  // cross arms
        translate([0, pivot_frac * H]) circle(d = BOSS);
    }
}

// ---- Dispatch: nominal height -> real printed height -------------------
// The profiles above are drawn so their topmost point is EXACTLY H, so the
// nominal height and the drawn height are the same number.
// (The old top_frac() table is gone with the old profiles. It existed because
// those silhouettes topped out at 0.86-0.94 of the H they were drawn to, so
// piece_height() over-reported and pivot_frac placed the bore above the true
// middle. Nothing to compensate for any more — a fudge factor that reads 1.00
// for all six pieces is just a bug waiting to be reintroduced.)
function piece_height(t) =
    t == "pawn"   ? h_pawn   * piece_scale :
    t == "knight" ? h_knight * piece_scale :
    t == "bishop" ? h_bishop * piece_scale :
    t == "rook"   ? h_rook   * piece_scale :
    t == "queen"  ? h_queen  * piece_scale :
    t == "king"   ? h_king   * piece_scale : h_pawn * piece_scale;

// The artwork, at final size. The profiles use ABSOLUTE mm, so piece_scale
// must be applied as a scale() around the finished drawing — NOT by handing
// profile() a bigger H, which would run the taper further while leaving the
// fixed-size heads (crown, cross, mitre, foot kick) at their drawn size and
// silently change the design.
module silhouette2d(t, H) {
    scale([piece_scale, piece_scale]) profile(t, H / piece_scale);
}

// Where to drop the resin drain hole, as a fraction of the piece's height
// measured from its base. Must land where the cavity is comfortably wider than
// drain_dia and above the boss ring, so it breaks into the void rather than
// into solid wall. Verify by exporting the STL and counting shells: a cavity
// the drain failed to reach shows up as a SECOND shell.
function drain_frac(t) =
    t == "king"   ? 0.60  :
    t == "queen"  ? 0.64  :   // y=29.7, cavity ~7 wide
    t == "bishop" ? 0.629 :   // y=26.9, cavity 6.2 wide
    t == "knight" ? 0.781 :   // y=30.5, inside the head
    t == "rook"   ? 0.700 :   // y=25.7, mid-parapet, 17.5 wide
                    0.68;     // pawn

// ---- The lightening cavity --------------------------------------------
// Everything ABOVE the pivot, inset by hollow_wall on all six sides. This is
// what puts the centre of mass below the pivot — see the bottom-heaviness note
// in common.scad for why it is shaped in rather than glued in.
// NOTE the order of operations: the inset offset is taken AFTER the scale, so
// hollow_wall stays a real 0.9 mm at final size instead of being magnified to
// 1.1 by piece_scale.
module hollow_cavity(t, H, py) {
    translate([0, -py, hollow_wall])
        linear_extrude(height = piece_thk - 2*hollow_wall)
            difference() {
                intersection() {
                    offset(r = -hollow_wall) silhouette2d(t, H);
                    // keep only what is ABOVE the pivot
                    translate([-2*H, py]) square([4*H, 1.2*H]);
                }
                // never break into the pivot bore: leave a full wall round it
                translate([0, py])
                    circle(d = axle_dia + 2*axle_fit + 2*hollow_wall);
            }
}

module piece(t) {
    H  = piece_height(t);
    py = pivot_frac * H;   // pivot height from base == the piece's own centre
    difference() {
        // Body, translated so the pivot point sits at the origin.
        translate([0, -py, 0])
            linear_extrude(height = piece_thk) silhouette2d(t, H);

        // Pivot bore at origin, through the plate (see gravity_gimbal.scad).
        // No countersink: the hub's bore chamfer is cut INTO the hub face, so
        // nothing protrudes for the piece to clear, and the 1.5 mm of designed
        // axial float means the piece never seats hard against the hub anyway.
        translate([0, 0, -0.5]) body_bore();

        hollow_cavity(t, H, py);

        // Drain hole: back face only, so the front stays a clean silhouette.
        translate([0, -py + drain_frac(t) * H, piece_thk - hollow_wall - 0.6])
            cylinder(d = drain_dia, h = hollow_wall + 0.7);
    }
}

// A print tray of all six pieces (one of each) for a quick full set proof.
module tray() {
    types = ["pawn", "knight", "bishop", "rook", "queen", "king"];
    for (i = [0 : len(types)-1])
        translate([i * (square_size*0.9), 0, 0])
            piece(types[i]);
}

// ---- Render dispatch --------------------------------------------------
if (PART == "all") tray();
else piece(PART);
