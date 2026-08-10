// =====================================================================
// styles/familiar.scad — PIECE STYLE "familiar" (artwork only)
// =====================================================================
//
// The look a chess player already knows: the online-board / fridge-magnet
// vocabulary. Ball-and-collar pawn, crenellated rook, horse knight, cleft
// mitre bishop, coronet queen, cross king. Nobody has to be taught what
// any of them is, which is the entire argument for the style.
//
// A STYLE FILE IS ARTWORK AND NOTHING ELSE. It draws six flat silhouettes
// and says how tall they are and where their cavities can be drained. It
// knows nothing about bores, magnets, hollowing, drainage depth or print
// thickness — pieces.scad owns all of that and applies the same mechanism
// to every style.
//
// THE CONTRACT every style file implements (see pieces.scad, "THE ENUM"):
//   familiar_silhouette2d(t)   2D artwork at FINAL SIZE. Base on y = 0,
//                              apex exactly at y = familiar_pheight(t).
//   familiar_pheight(t)        that height, in real printed mm.
//   familiar_drains(t)         back-face drain points [[x, y], ...] in the
//                              same silhouette coordinates (y from the base).
//
// The names carry a `familiar_` prefix because OpenSCAD has no namespaces
// and no dynamic `include`: pieces.scad has to `use` every style file at
// once, so the three PUBLIC names must be unique per style. Everything
// below the contract is private — helper modules and constants resolve in
// this file's own scope, so two styles may reuse the same internal names
// without colliding (verified, not assumed).
//
// ALL CONSTANTS IN THIS FILE ARE ARTWORK, NOT MECHANISM. They are drawing
// millimetres, no other part of the project references them, and they must
// NOT migrate into common.scad — next to real mechanical millimetres they
// would read as though the hub or the board depended on them. Unlike
// "monolith" this style is drawn AT FINAL SIZE, so it has no scale factor:
// what is written here is what gets printed.
//
// TWO DRAWING LANGUAGES LIVE HERE ON PURPOSE. Five pieces are drawn as
// hulls of circles and are EXACTLY mirror-symmetric by construction
// (sym()), so they hang plumb without tuning. The knight is drawn as a
// polygon and softened by a global opening/closing pass; it is the one
// asymmetric piece and the only one whose balance is solved numerically.
// Do not put the knight through sym() and do not put the other five
// through the rounding pass — each was verified in its own language.
//
// Heights 40 / 43 / 44.5 / 47.5 / 50 / 52 — strictly ordered, 1.30x spread.
// Widths  30 / 38 / 40.5 / 36   / 41.8 / 42.
// =====================================================================

// ------------------------------------------------ DRAWING LANGUAGE 1 --
// Hulls of circles, half-drawn and mirror-unioned. Exact symmetry.
module cir(x, y, r) translate([x, y]) circle(r = r);

// mirror-union: draw the right half only, get exact symmetry for free
module sym() { union() { children(); mirror([1, 0]) children(); } }

// rounded band, full width w, spanning y0..y1.  Use INSIDE sym().
module bandh(w, y0, y1, r) hull() {
    cir(-0.6,    y0 + r, r);  cir(w/2 - r, y0 + r, r);
    cir(w/2 - r, y1 - r, r);  cir(-0.6,    y1 - r, r);
}

// THE SHARED PLINTH: slab of width W, cove rising to width Wt, height h.
// Mass low and far from the pivot IS the self-righting lever arm.
module foot(W, Wt, h) sym() {
    bandh(W, 0, 0.55*h, 1.4);
    hull() {
        cir(-0.6,       0.42*h + 1.0, 1.0);  cir(W/2 - 1.6,  0.42*h + 1.0, 1.0);
        cir(-0.6,       h - 1.0,      1.0);  cir(Wt/2 - 1.0, h - 1.0,      1.0);
    }
}

// A coronet point: fat tapered cone from a wb-wide base to a ball of radius
// rb whose top touches ytip. Symmetric about its own axis, so a +x/-x pair
// is an exact mirror pair. The neck stays 1.44*rb wide, which keeps a
// >= 1.4 mm cavity running into every ball and back out — slim spikes are
// what strand six sealed voids in a coronet.
module spike(x, ybase, ytip, wb, rb) {
    yb = ytip - rb;
    hull() {
        cir(x - wb/2 + 0.9, ybase, 0.9);
        cir(x + wb/2 - 0.9, ybase, 0.9);
        cir(x, yb, rb * 0.72);
    }
    cir(x, yb, rb);
}

// ------------------------------------------------ DRAWING LANGUAGE 2 --
// One polygon, softened by a single opening then a single closing, so every
// convex corner gets KCORNER and every valley gets KFILLET. Knight only.
KCORNER = 1.6;
KFILLET = 1.2;
module kfoot(bw, tw) { polygon([[-bw,0],[bw,0],[tw,7.5],[-tw,7.5]]); }
module kcol(hw0, y0, hw1, y1) { polygon([[-hw0,y0],[hw0,y0],[hw1,y1],[-hw1,y1]]); }
module kcap(x0, y0, x1, y1, r) {
    hull() { translate([x0,y0]) circle(r=r); translate([x1,y1]) circle(r=r); }
}

// ============================================================ THE SET ==

// PAWN  H 40  W 30 — plinth, collar, ball body ON the pivot, collar, head.
// The body ball is centred exactly on the bounding-box centre, so the piece
// is 19.2 mm of solid plastic exactly where the pivot hardware goes.
module pc_pawn() {
    foot(30, 18, 10);
    sym() bandh(15, 8, 13, 1.6);          // neck out of the plinth
    cir(0, 20.0, 9.6);                    // body ball -- centred ON the pivot
    sym() bandh(11.5, 27.6, 31.4, 1.4);   // collar under the head
    cir(0, 34.6, 5.4);                    // head ball, top = 40
}

// ROOK  H 43  W 38 — plinth, waisted tower, corbel, three EQUAL merlons.
// The crenellation is the whole read, and it only reads if the three teeth
// are the same width and the parapet is visibly wider than the waist:
//   parapet 31 wide  =  7.4 + 4.4 + 7.4 + 4.4 + 7.4
//   waist   20 wide, and the foot at 38 stays the widest thing on the piece,
//                    so the bounding box is owned by the symmetric plinth.
// The tower waist is where a Ø11.5 hub puck hides; at 20 mm it buries it
// twice over. Merlon teeth are 7.4 wide, so the 0.9 mm-walled cavity keeps a
// 5.6 mm channel up into each one and stays a single drained region.
//
// THE FOOT IS 38 WIDE AND 13.5 TALL, AND THAT IS MECHANISM, NOT TASTE.
// Crenellation is by definition a lot of area high above the pivot, so the
// rook is the worst lever in every candidate set that drew it correctly
// (rejected candidates: d 4.60 and 4.84). The lever is bought back with mass
// LOW rather than by softening the merlons: d 5.50 -> 5.89. That margin is
// what lets the set survive a pivot architecture that hangs the magnet ON
// the piece at zero lever arm — the rook is the piece that runs out first.
module pc_rook() {
    foot(38, 26, 13.5);
    sym() {
        polygon([[-0.6, 10.5], [12.5, 10.5], [10.0, 21.5], [11.6, 27.0],
                 [15.5, 31.5], [15.5, 37.0], [-0.6, 37.0]]);
        translate([-0.6, 36.0]) square([4.3, 7.0]);   // centre merlon, 7.4 wide
        translate([ 8.1, 36.0]) square([7.4, 7.0]);   // side merlon,   7.4 wide
    }
}

// KNIGHT  H 44.5  W 40.5 — the one asymmetric piece in the set.
// The head reads as a horse because of four things, in this order: the muzzle
// jutting low and clear of the neck, the jaw undercut over an OPEN throat,
// the eye set high and back, and two rounded ears. Everything else is
// negotiable; those four are not.
//
// The knight has to satisfy two conditions at once: the bore must sit on the
// bounding-box centre (so it reads centred and stays centred through a 180
// deg board flip) AND on the centre of mass (so it hangs plumb). On this head
// those are different points. Sliding the head to reconcile them takes 12-20
// mm and looks broken — the fix is structural: the SYMMETRIC foot is drawn
// wider than the head reaches on either side, so the foot owns both bbox
// edges, the bbox centre is pinned on x = 0 by construction, KSH is 0 and
// stays 0, and KDX is left with the single job of centring the mass.
//
// THE PRICE, stated plainly: this is why the knight (40.5) is WIDER than the
// bishop (36) and the rook (38). The foot has to out-reach the muzzle.
//
// KDX was solved numerically against the RENDERED STL (cavity, bore and drain
// included, not the 2D area). RE-SOLVE IT IF THE HEAD IS TOUCHED: the piece
// will keep rendering perfectly, keep passing the shell check and keep
// looking right while hanging crooked. The balance is TUNED, not structural.
KDX =  0.75742;
KSH =  0.00000;   // zero BY CONSTRUCTION: the foot owns both bbox edges.

module knight_head(H) {
    kcap(-6.0, H - 2.2, -6.0, 39.5, 2.2);   // near ear -- capsule, so the
    kcap( 2.5, 40.3,     2.5, 37.5, 2.2);   //   rounding cannot shave the apex
    polygon([
        [-19.5, 27.5], [-20.0, 32.5], [-14.5, 36.5], [ -8.5, 40.0],
        [ -6.0, 44.0], [ -1.5, 40.0], [  2.5, 42.5], [  6.0, 38.0],
        [ 11.5, 31.0], [ 14.5, 23.0], [ 15.0, 15.0], [-15.0, 15.0],
        [ -8.5, 23.5], [ -9.5, 28.5], [-14.5, 28.0]]);
}

module knight_raw(H) {
    translate([-KSH, 0]) {
        kfoot(21.0, 18.0);
        kcol(18.0, 7.0, 14.0, 16.0);
        translate([KDX, 0]) difference() {
            knight_head(H);
            // The eye sits high and set back, where a horse's actually is —
            // and, not by coincidence, where the head is thick. Any hole must
            // keep more than 2*KCORNER of material to the outline, or the
            // opening erodes the band to nothing and the eye breaks out.
            translate([-6.5, 34.0]) circle(r = 2.2);
        }
    }
}

module pc_knight() {
    offset(r = -KFILLET) offset(r = KFILLET)
        offset(r = KCORNER) offset(r = -KCORNER)
            knight_raw(44.5);
}

// BISHOP  H 47.5  W 36 — plinth, bulb, fat mitre egg, finial ball.
// The mitre's cross is carried HIGH. On the references the cross sits at mid
// height, which is exactly where the bore has to go.
module pc_bishop() {
    difference() {
        union() {
            foot(36, 22, 11);
            sym() bandh(26, 9, 16, 3.0);                        // bulb
            hull() { cir(0, 24.0, 12.0); cir(0, 32.5, 8.4); }   // mitre egg (24 mm at the pivot)
            hull() { cir(0, 32.5,  8.4); cir(0, 38.8, 3.9); }   // mitre taper
            cir(0, 44.4, 3.1);                                  // finial, top = 47.5
        }
        sym() {
            bandh(3.4, 30.6, 36.8, 0.8);                        // cross, upright
            bandh(7.4, 32.4, 35.6, 0.8);                        // cross, arm
        }
    }
}

// QUEEN  H 50  W 41.8 — plinth, vase, flared coronet, five ball-tipped
// points, graded tallest-in-the-centre. The grading is what stops the queen
// being read as a rook.
module pc_queen() {
    foot(40, 26, 12);
    sym() {
        polygon([[-0.6, 11.0], [13.0, 11.0], [11.0, 21.5], [15.0, 27.0], [-0.6, 27.0]]);
        polygon([[-0.6, 26.5], [15.0, 26.5], [20.4, 33.5], [-0.6, 33.5]]);   // flared coronet
    }
    spike(  0.00, 32.0, 50.0, 5.6, 3.0);
    spike(  9.15, 31.8, 45.0, 5.4, 2.9);   spike( -9.15, 31.8, 45.0, 5.4, 2.9);
    spike( 18.10, 31.4, 40.5, 5.2, 2.8);   spike(-18.10, 31.4, 40.5, 5.2, 2.8);
}

// KING  H 52  W 42 — plinth, vase, flared crown with two lobes, and the
// cross rising between them.
module pc_king() {
    foot(42, 27, 13);
    sym() {
        polygon([[-0.6, 12.0], [13.5, 12.0], [11.5, 22.5], [14.0, 28.5], [-0.6, 28.5]]);
        polygon([[-0.6, 27.5], [14.0, 27.5], [16.4, 35.0], [-0.6, 35.0]]);   // crown band
        cir(11.0, 36.5, 6.0);                                                // crown lobe
        bandh(6.6, 33.0, 52.0, 1.0);                                         // cross, upright
        bandh(15.0, 44.0, 49.0, 1.0);                                        // cross, arm
    }
}

// ============================================== THE CONTRACT ==========
module familiar_silhouette2d(t) {
         if (t == "pawn")   pc_pawn();
    else if (t == "rook")   pc_rook();
    else if (t == "knight") pc_knight();
    else if (t == "bishop") pc_bishop();
    else if (t == "queen")  pc_queen();
    else if (t == "king")   pc_king();
}

function familiar_pheight(t) =
      t == "pawn"   ? 40.0
    : t == "rook"   ? 43.0
    : t == "knight" ? 44.5
    : t == "bishop" ? 47.5
    : t == "queen"  ? 50.0
    : t == "king"   ? 52.0
    : 0;

// Back-face drains, in SILHOUETTE coordinates (piece base = y 0). Every
// connected region of the cavity needs one, or that region is a sealed void
// that traps uncured resin — and it shows up as an extra shell in the STL.
// A drain on the centreline is not safe by default: it has to land in broad
// cavity, above the pivot, clear of the bore boss and of every cut.
function familiar_drains(t) =
      t == "pawn"   ? [[0.0, 34.40]]   // head ball
    : t == "rook"   ? [[0.0, 28.00]]   // tower, under the corbel
    : t == "knight" ? [[0.0, 27.60]]   // thick of the head, clear of the eye
    : t == "bishop" ? [[0.0, 40.85]]   // above the cross: the centreline below
                                       //   it is blocked by the bore boss and
                                       //   by the cross itself
    : t == "queen"  ? [[0.0, 30.50]]   // coronet band
    : t == "king"   ? [[0.0, 32.76]]   // crown band
    : [[0, 0]];
