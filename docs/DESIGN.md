# Design — Vertical Wall Chess Board

This is the engineering design for a chess board that **hangs on the wall
like a piece of art**, plays vertically, and has two signature mechanics:

1. **The board rotates 180° based on whose turn it is** — so the player to
   move always sees the position from their own side.
2. **The pieces stay upright by gravity** — as the board rotates, every
   piece swings on a pivot and self-levels, so nothing is ever upside-down.

Everything here is parametric: change one number in
[`hardware/common.scad`](../hardware/common.scad) and the whole system
re-sizes.

---

## 1. The big picture

```
        ┌───────────────────────────────┐
        │         WALL PLATE            │  ← screws to wall / French cleat
        │   ┌───────────────────────┐   │
        │   │   lazy-susan bearing   │   │  ← carries the weight, lets it spin
        │   └───────────────────────┘   │
        │        NEMA-17 + GT2 belt     │  ← rotates the board 180° per turn
        └───────────────┬───────────────┘
                        │ turntable
        ┌───────────────┴───────────────┐
        │           FRAME / BEZEL        │
        │  ┌─────────────────────────┐  │
        │  │      BOARD PANEL         │  │  ← 8×8 grid on a steel-sheet face
        │  │   ▟ ▙ ▟ ▙ ▟ ▙ ▟ ▙       │  │  ← hall sensor bore behind each square
        │  │   pieces stick + swivel  │  │
        │  └─────────────────────────┘  │
        └───────────────────────────────┘
```

The board is a **vertical plane** on a **central turntable**. The playing
surface is a thin **steel sheet** glued onto the printed panel (see §4);
every piece has a **magnet**
in its hub, so pieces grip the vertical surface and can slide square to
square. Each piece body hangs on a **low-friction pivot** and is
**bottom-heavy by shape** — solid below the pivot, hollow above it — making it
a pendulum that always points up.

---

## 2. Mechanic 1 — rotate by turn

When a player finishes their move, the board rotates **180°** so the other
player now looks at the board "the right way up" from their side.

- **Bearing:** an off-the-shelf **lazy-susan / turntable bearing**
  (`bearing_od`/`bearing_id` in `common.scad`) carries the ~2–3 kg board and
  keeps it flat against the wall.
- **Drive:** a **NEMA-17 stepper** turns a **GT2 timing belt** around a
  toothed rim on the turntable. Ratio is `motor_gear_teeth : ring_gear_teeth`
  (default 20:200 = **10:1**) — plenty of torque, and the board holds still
  between moves.
- **Homing:** two magnets 180° apart on the turntable pass a **hall sensor**
  on the wall plate. That gives the two exact stop positions
  ("White-up" / "Black-up"). The firmware always knows orientation.
- **Direction:** alternate direction each turn (CW, then CCW) so the belt and
  any wiring never wind up. A center **slip ring** is optional and only
  needed if you keep powered electronics on the rotating side (see §5).

Parts: [`rotation_hub.scad`](../hardware/rotation_hub.scad),
[`frame.scad`](../hardware/frame.scad).

---

## 3. Mechanic 2 — pieces stay upright by gravity

This is the fun one. On a vertical board the pivot axis points **straight
out of the wall** (normal to the board). A body that spins freely on that axis
and carries its mass **below** the axis behaves exactly like a **pendulum**: it
swings until its heavy end is down and stays there — regardless of how the
board around it is rotated.

```
   front (room) ◄──────────────────────────────► back (wall)

        ┌───────────┐        the stack, front to back
        │  ░░░░░░░  │          press cap    4.7 mm    Ø6, grips the dowel tip
        │  ░░░░░░░  │          piece body   6.0       the silhouette plate
        │──── ⊙ ────│          hub puck     8.0       Ø11.5, magnet in its back
        │           │          ─────────────────
        │  ███████  │          axle: Ø3 × 16 mm steel dowel, 11 mm proud
        │  ███████  │                6.0 + 3.5 grip = 9.5
        └───────────┘                → 1.5 mm axial float, by design

   ⊙ pivot — at the silhouette's own centre AND at the square's centre
   ░ hollow above the pivot      █ solid below it   → centre of mass BELOW ⊙
```

Each piece is **three printed parts plus one bought steel dowel** — see
[`gravity_gimbal.scad`](../hardware/gravity_gimbal.scad) and
[`pieces.scad`](../hardware/pieces.scad):

| Part | Role |
|------|------|
| **Hub puck** — Ø11.5 × 8 mm, printed | A Ø8 × 3 mm neodymium magnet press-fits into its **back** and grips the steel board face; the **front** is bored for the axle. The puck sticks to a square and turns *with* the board. It is deliberately small enough that the piece in front **hides** it (§3.2). |
| **Axle dowel** — Ø3 × 16 mm, **bought** | A stock steel dowel pin pressed into the hub until it bottoms out **on the magnet**, so there is no thin printed web to crack. Steel because friction is what decides how straight a piece parks (§3.1). Thin because a Ø3 *steel* dowel takes a 20 N sideways knock with **3.0× margin**, where the Ø4 *printed* post it replaced had only 1.29× — it snapped at the layer line. **Thinner and stronger, not a compromise.** |
| **Body** — the silhouette plate, 6 mm, printed | Flat, so it reads across the room and prints face-down with no supports. A central bore drops over the dowel and spins freely on it. Bottom-heavy **by shape** — solid below the pivot, hollow above — with **nothing glued in** (§3.3). |
| **Press cap** — Ø6 mm, printed | Grips the plain dowel by interference (three slit fingers spread as it goes on) so the body cannot fall off but still turns. It is the only part of the mechanism that faces the room, sitting mid-piece, so it is sized to vanish into the silhouette rather than read as a button. |

> **Jargon, plainly:** a **dowel pin** is a plain ground-steel rod, sold by the
> hundred in any fastener shop. A **press fit** means the hole is cut slightly
> *undersize* so the pin is held by friction alone — no glue, no thread. The
> **1.5 mm axial float** is deliberate slack along the dowel: without it,
> normal print tolerance could clamp the piece between cap and hub and stall
> the very rotation the mechanism exists to allow.

### 3.1 The physics, stated once

Every number in the piece design answers to one equation. A hanging piece does
**not** park perfectly upright — it parks at the angle where friction in the
bore exactly cancels the gravity torque:

```
    sin(lean)  =  μ · r / d

      μ  friction coefficient in the bore   assumed 0.08 (greased steel on plastic)
      r  bore RADIUS                        1.85 mm (a Ø3.70 bore on the Ø3 dowel)
      d  how far the centre of mass sits
         BELOW the pivot                    4.7 – 8.7 mm across this set
```

Three consequences drive the whole design:

1. **Mass cancels out — entirely.** Weight appears on both sides of the torque
   balance and divides away. Adding ballast to a piece does **nothing** for how
   straight it hangs; only geometry (`d`) and friction (`μ · r`) move the
   number. This is the most counter-intuitive fact in the project, and it is
   why the ballast was deleted rather than tuned (§3.3).
2. **The centre of mass must sit *below* the pivot.** That is what `d` is. Above
   the pivot it would be an inverted pendulum and would flop to whichever side
   it was nudged.
3. **It must also sit *directly under* the pivot.** A pendulum hangs with its
   mass plumb below the axis, so a silhouette that is heavier on one side hangs
   **permanently rotated** — and no amount of friction tuning fixes that,
   because it is not a lean, it is where "down" now is for that shape. Five of
   the six pieces are mirror-symmetric and get this for free. The knight is not,
   and is the set's one fragile piece because of it (§3.6).

So there are exactly **two levers** on the lean: **cut `μ · r`**, or **grow
`d`**. The bought steel dowel and the damping grease attack the first (and the
Ø4 → Ø3 change alone is ~19% less lean, for free). The pivot placement and the
shaped-in cavity fight over the second.

**Friction is a tuning knob that cuts both ways.** Too much and the piece parks
crooked. Too little and *nothing damps the swing* — a piece on a bare ball
bearing would ring for a minute after every flip. The answer is **silicone
damping grease**: viscous drag kills the ringing without adding the static
friction that causes the lean in the first place. (Dry PTFE lube makes the
opposite trade; a ball bearing was evaluated and rejected for the same reason —
see **D9** in [`GOALS.md`](GOALS.md).)

### 3.2 Why the pivot sits at the silhouette's centre

`pivot_frac = 0.50` puts the bore at the centre of the silhouette's bounding
box, and the hub puck at the centre of the square. Two things follow:

- **The piece reads centred in its square**, rather than dangling from its head
  like a pendant.
- **It stays centred through a flip.** Because the piece turns about its own
  centre, whatever small angle it settles at merely **rotates it in place**
  instead of swinging the body sideways. The sideways offset is zero at *every*
  angle, not just at rest — which matters, because the settling happens while
  the board is still moving. (An earlier design pivoted above the middle for a
  stronger "down"; it bought settling speed at the price of every piece hanging
  visibly low and swinging off-centre.) This is decision **D8**.

The cost is paid in `d`, and it is real: putting the pivot at the middle brings
the centre of mass close to it (4.7–8.7 mm across the set), and a small `d` is a
bigger lean. That is precisely what the steel dowel and the grease buy back.

A second consequence sets the board's scale. The puck sits *behind* the piece,
so the piece must **hide** it or every piece wears a grey collar. The mechanical
parts do not scale with the square — only the **artwork** does — so enlarging
the square runs the taper further until it swallows the puck. At 45 mm squares
the narrowest waist covered only Ø9.8 and the puck showed. **55 mm is the
smallest square at which the natural waist (Ø12.0) covers the Ø11.5 puck with
nothing added** — no skirt, no collar, no fake boss; 0.5 mm to spare. That
resolves decision **D1**, and it is why the panel grew from ~410 mm to ~490 mm
square.

### 3.3 Bottom-heavy by shape, not by ballast

There are two ways to put the centre of mass below the pivot:

| | How | What happens when the material changes |
|---|-----|-----------------------------------------|
| ~~(a) Ballast~~ | Glue a dense slug — lead, steel nuts — into a pocket low down | `d` depends on the **ratio** of slug density to body density, so tuning done in one material **does not transfer** to another. |
| **(b) Shape** ✅ | Make the body **solid below the pivot and hollow above it** | The piece is **one material**, so density cancels out of the equation completely. |

This set does **(b)**. There is **no weight pocket, no lead, no nuts, and
nothing to glue in** (decision **D10**).

The payoff is not tidiness — it is that the cheap test is a *valid* test. Under
(b), a PETG test print behaves **identically** to the final resin part, because
density has dropped out of `sin(lean) = μ · r / d` on both sides. Under (a) it
would not have, and a Phase-0 print would have proved nothing about the piece it
was standing in for. It is also one fewer part, one fewer assembly step, and one
fewer thing to rattle loose.

Two details that are easy to get wrong:

- **The cavity is modelled, not sliced.** A resin slicer's "hollow" button
  removes material *evenly everywhere*, which produces no top-to-bottom mass
  gradient at all — exactly the wrong thing. The cavity in `pieces.scad` is cut
  deliberately, **above the pivot only**, inset `hollow_wall` = 0.9 mm from
  every face and every silhouette edge. (0.9 mm is the floor for two perimeters
  on a 0.4 mm FDM nozzle, and comfortable in resin. Thinner walls would buy more
  lever; this is where that trade stops being safe.)
- **Every cavity needs its drain hole.** A sealed void traps uncured resin,
  which later leaks or bulges the wall. Each piece has a 2 mm drain through its
  **back** face only, so the front stays a clean silhouette. Verify it worked by
  counting shells in the exported STL: **a piece should be one shell.** A cavity
  the drain missed shows up as a second.

### 3.4 The set as modelled

At 55 mm squares, with the artwork scaled by `piece_scale` = 1.222 (the hub,
dowel and cap keep their own fixed millimetres — that asymmetry is the point,
see §3.2):

| Piece | Height | Width | Aspect | Lever `d` | Modelled lean | Mass (resin) |
|-------|-------:|------:|-------:|----------:|--------------:|-------------:|
| Pawn   | 31.77 | 20.74 | 0.653 | 5.71 mm | 1.49° | 2.24 g |
| Rook   | 36.66 | 24.61 | 0.671 | 4.68 mm | **1.81°** | 3.43 g |
| Knight | 39.10 | 26.44 | 0.676 | 6.05 mm | 1.40° | 3.75 g |
| Bishop | 42.77 | 29.98 | 0.701 | 7.29 mm | 1.16° | 4.52 g |
| Queen  | 46.44 | 25.34 | 0.546 | 5.72 mm | 1.48° | 4.23 g |
| King   | 51.32 | 25.59 | 0.499 | 8.68 mm | 0.98° | 4.24 g |

All six: **one shell** (so every cavity drained), pivot exactly centred,
balanced in x, and standing inside their square. Heights step ~3 mm and open to
4 mm at the top so the king still pulls away from the queen; the 42/26 ratio
between king and pawn sits inside the 1.6–2.0 band that makes rank read at
across-the-room distance.

**Clearance during a flip** is a slightly different question from "fits in its
square", because a rotating piece sweeps a *circle* of its longest corner. Five
pieces stay inside their own square at any angle; the king's foot corners sweep
**28.34 mm** against a 27.5 mm half-square, so they cross the square line by
0.84 mm mid-flip. No legal position collides: neighbours rotate in lockstep, and
the worst adjacent pair is king + queen at 28.34 + 26.10 = 54.44 mm against the
55 mm square pitch. Two kings would exceed it — and the rules of chess forbid
kings on adjacent squares.

### 3.5 Read these numbers honestly

> **Nothing in this repo has been printed.** Every figure above is measured off
> an exported mesh, not off an object. They are model outputs, not
> measurements of hardware.

- **The lean column rests on an assumed μ = 0.08** for greased steel on plastic.
  That is a **textbook figure, not one measured on this hardware.** Lean scales
  linearly with μ: if the real value is double, so is every angle in the table.
  **One printed pawn plus one hub settles it, and it is the cheapest test in the
  project** — do it before committing to a set (Phase 0 in
  [`BUILD_GUIDE.md`](BUILD_GUIDE.md)).
- **The rook has the least margin:** 1.81° against a 2.2° working limit. It is
  the squattest body in the set, so it has the shortest lever, and it is the
  piece that breaks first if real friction comes in higher.
- **The knight's balance is tuned, not structural** — see §3.6.
- **Unchecked:** print orientation, overhangs, and whether a Ø8 magnet holds the
  heaviest piece (bishop, 4.52 g, hanging 11 mm proud of the wall).

### 3.6 The piece design language — "Tapered Monolith"

**Flat silhouettes** are deliberate: readable at living-room distance, cheap to
print, and light (less pendulum inertia). Two finishes or two filament colours
separate White from Black. But "flat silhouette" is a format, not a style, so
the six shapes are drawn to **one shared rule set** (decision **D11**) rather
than designed piece by piece. The rules, in full:

- **One slope.** Every piece is a single straight-sided taper at **1 : 4**
  (14.04° off vertical). No piece has its own angle.
- **One stroke.** A single width, `STROKE` = 4.4 mm, is every deliberate line in
  the set — the pawn's crown radius, the king's cross limb and arm, the bishop's
  cleft.
- **One convex and one concave radius.** `CORNER` = 0.8 mm rounds every outside
  corner and `FILLET` = 0.5 mm every inside one, applied globally as an opening
  then a closing. **No corner is ever radiused by hand.**
- **One shared foot.** The same kick height (3.6 mm) and the same flare
  (1.6 mm per side) on all six. The flare is said exactly **once**, at the
  bottom.
- **The foot is the widest point of every piece** — verified on all six meshes.
  The terminal event always sits *inside* the width the taper already owns, so
  nothing overhangs the base.
- **Rank reads twice over:** as overall height, and as **how far the taper ran
  before the event started**.
- **Rank = taper run + exactly one terminal event.**

(Those constants are in *nominal artwork* millimetres — before `piece_scale`.
They live in `pieces.scad`, not `common.scad`, precisely because they are
drawing units rather than real ones.)

| Piece | Where the taper stops | The one event |
|-------|----------------------:|---------------|
| **Pawn** | tangent, no stop | **None** — the taper runs into a dome that is *tangent* to it, so the outline never breaks. The pawn is identified by absence. |
| **Rook** | 19.4 mm (shortest run) | A parapet of **three square merlons**, counted in the set's own units. |
| **Knight** | 21.0 mm (cut off early) | A head that **faces left** — the only broken mirror. *The exception; see below.* |
| **Bishop** | 28.0 mm, stopped wide | A **mitre**: a dome with one stroke-wide cleft driven through it, leaving two horns. |
| **Queen** | 31.6 mm, down to a narrow waist | A **coronet** — four points, each finished with a rounded pearl. |
| **King** | 32.0 mm (longest run) | A **cross**: one limb, one arm, both exactly one stroke. |

Queen and king are separated structurally, not decoratively: both run the taper
down to the same narrow waist and jump out sideways, and the coronet *is* the
crossbar, only divided. Rook and queen are separated by shape *and* by count —
three square merlons against four round pearls.

> **⚠ The knight is the set's one deliberate exception, and its one fragile
> part.** Its head above the shoulder uses **free angles**, outside the family's
> restricted set. This is a priced trade, not an oversight: the allowed angles
> contain **no diagonal**, so a jaw line, a nose bridge and an ear spike are
> literally unbuildable inside a 32 mm piece. Three compliant redraws were
> modelled; all three stopped being a horse.
>
> The trade has a second cost that matters more. Because the head is asymmetric,
> the knight is the only piece whose centre of mass is not free — it hangs plumb
> only because a constant, `KDX`, slides the head sideways until the moment about
> the centreline cancels. That balance is **tuned numerically, not structural**.
> **Edit the head polygon and the piece will still render perfectly, still look
> right, and then hang permanently rotated** (see consequence 3 in §3.1). If you
> touch it, re-measure the centre of mass and re-solve `KDX`. This is flagged in
> `pieces.scad` at both the constant and the knight's branch.

> **Do we need both mechanics?** Yes, and they complement each other. The
> *rotation* flips the board coordinates so the mover sees their own back
> rank at the bottom; the *gravity pivot* guarantees the piece art is upright
> throughout and after that flip. Together the board always looks "normal" to
> whoever is on move.

---

## 4. Holding pieces on a vertical board (magnets + steel sheet)

- The magnet — an **8 mm × 3 mm N52 neodymium disc** (`magnet_dia`/`magnet_thk`) —
  lives in the **hub puck**, pressed into its back. The piece body itself
  contains **no magnet and no metal**; it just hangs on the hub's dowel.
- The playing surface is a **thin steel sheet** (`sheet_thk` ≈ 0.5–1 mm) glued
  onto the printed panel's front. The piece magnet grips the sheet
  **directly** — the same attachment every commercial magnetic wall chess set
  uses, so the hold is proven rather than hoped-for (decision **D7** in
  [`GOALS.md`](GOALS.md)).
- A **felt disc over the hub magnet** is the tuning knob: it sets the glide
  (thicker felt = weaker, smoother slide) and keeps the sheet's paint
  scratch-free.
- Direct 8×3 N52 contact holds far more than a piece weighs, with margin for
  the pendulum swing. If you scale pieces up, hold scales with `magnet_dia`.

**Sensing through steel?** A solid sheet would magnetically shield the hall
sensors (§5), so the sheet gets a **small laser-cut hole at each square
center** (`sheet_hole` ≈ 8 mm): the sensor tip sits flush in a bore just
behind the hole and reads the piece magnet through air. Phase-1 builders can
use a plain un-holed sheet and switch to the holed sheet only for Phase 2.

> An earlier design buried a steel washer behind each square and gripped it
> *through* a 2.5 mm plastic wall — cleaner face, and the washer self-centered
> the pieces, but the through-wall grip was unproven. Direct sheet contact was
> adopted as the tested option; players center pieces by eye, as on any
> magnetic set.

---

## 5. Sensing the board (for validation + auto-play)

Behind each square, a **hall-effect sensor** slides into a bore from the open
back (`sensor_dia` in [`board_panel.scad`](../hardware/board_panel.scad))
until its tip sits flush at the front face, directly under the **sensing hole
in the steel sheet** (`sheet_hole`). It reads the piece magnet through that
hole — mostly air, so the sheet does **not** shield it. Each piece magnet
trips the sensor on its square, so the electronics read an **8×8 occupancy
grid**.
Combined with the rules engine
([`software/engine/chess.js`](../software/engine/chess.js)) the board can:

- detect when a piece is lifted and where it lands,
- validate the move is legal (reject illegal ones with an LED/app nudge),
- keep the game state, clocks, and move history,
- (Phase 3) compute and physically play the opponent's reply.

64 sensors are read through **four 16-channel multiplexers** (CD74HC4067), or
an 8×8 matrix, into one microcontroller — see [`ELECTRONICS.md`](ELECTRONICS.md).

> Occupancy alone tells you *which* squares are full, not *which piece* is
> where. That's fine: the firmware knows the full game state, so it only needs
> occupancy changes to follow along. (Piece identity is only ambiguous if you
> set up an arbitrary position — handle that with an app "set position" flow.)

---

## 6. Phase 3 — the board plays you (auto-mover, future scope)

> 🌠 **Aspirational — not a current focus.** The manual board (Phases 0–2)
> needs none of this. It's captured so auto-play can be picked up deliberately
> later; it does not drive near-term work.

Commercial auto-chess boards (Square Off, "wizard chess" boards) all use the
same trick: an **electromagnet on an XY gantry behind the board** grabs a
piece's magnet and drags it across the front.

- **Gantry:** a Core-XY / H-bot behind the panel carrying one electromagnet.
- **Routing:** pieces slide along the **gaps between squares**, so knights and
  blocked pieces route *around* others; a piece never passes through another.
- **Captures:** drag the captured piece to an edge **graveyard lane** first,
  then move the capturing piece.
- **Brain:** **Stockfish** at selectable strength (see
  [`OPEN_SOURCE.md`](OPEN_SOURCE.md)) — or the built-in zero-dependency
  [`ai.js`](../software/engine/ai.js) as fallback — chooses the move; the
  mover executes it; the board rotates; your turn.

### The honest hard part (it's harder because our board is vertical)

Commercial auto-boards lie **flat**: gravity holds pieces down and the magnet
only slides them sideways. Ours is **vertical**, which creates a real conflict:

- Pieces need a constant holding force to the board (our **steel-sheet face**).
- But the moving electromagnet must reach the pieces **through** the board —
  and **a steel backing shields/blocks a magnet**.

You can't easily have *steel behind every square holding pieces up* **and**
*an electromagnet behind the board grabbing them* in the same place. So the
auto-mover is a **different machine** from the manual board, not a bolt-on.
Three honest routes:

| Route | What it is | Difficulty |
|------|-----------|------------|
| **Manual / motor-rotate only** (Phases 1–2) | No robot. Beautiful, achievable. Many people stop here. | approachable |
| **EPM matrix** (switchable-magnet grid) | An electropermanent magnet behind *every* square: the holders **are** the movers, so nothing shields anything. Holds with zero standing power (blackout-safe). **The recommended path to true vertical auto-play.** | hard, most parts |
| **Reclined gantry** (~45–63° from vertical — an easel, not a wall piece) | The classic gantry works once the board leans back far enough for gravity + friction to hold idle pieces without steel. The math in [`AUTO_MOVER_ANALYSIS.md` §6](AUTO_MOVER_ANALYSIS.md) shows a gentle 15–20° tilt does **not** suffice. | hard, proven parts |

**Recommendation:** build Phase 1 first; treat auto-play as **aspirational** and
decide on it much later. Nothing printed for Phase 1 is wasted — pieces, brain,
and most of the frame carry into either route. *If* it's ever pursued, the
researched route (decision **D6** in [`GOALS.md`](GOALS.md)) is the **EPM
matrix**, gated behind cheap prototypes, with the **reclined gantry** as the
low-risk fallback — full design in
[`AUTO_MOVER_DESIGN.md`](AUTO_MOVER_DESIGN.md).

> **Full analysis:** the physics of *why* a vertical auto-mover is hard (the
> hold shields the mover, the hold is what the mover fights, and it must be
> everywhere while the mover is one point), the recline math, and the viable
> paths — including a **switchable-magnet matrix** that dissolves the conflict —
> are worked out with sources in
> [`AUTO_MOVER_ANALYSIS.md`](AUTO_MOVER_ANALYSIS.md).

- **Control app:** phone app over BLE/Wi-Fi picks difficulty, shows the game,
  offers takebacks/hints. See [`app/README.md`](../app/README.md).

---

## 7. Key parameters (edit in `common.scad`)

| Parameter | Default | Meaning |
|-----------|---------|---------|
| `square_size` | **55 mm** | one playing square (**D1**, locked — see §3.2) |
| `piece_scale` | **1.222** | scales the piece **artwork only**; hub, dowel and cap keep their own millimetres |
| `pivot_frac` | 0.50 | pivot height as a fraction of piece height — 0.50 = the silhouette's centre |
| `piece_thk` / `hollow_wall` | 6 / 0.9 mm | silhouette plate thickness, and the wall left around the cavity |
| `magnet_dia` × `magnet_thk` | 8 × 3 mm | piece magnets |
| `hub_dia` / `axle_dia` | **11.5 / 3 mm** | gravity pivot (puck diameter, dowel diameter) |
| `axle_fit` | 0.35 mm | swivel clearance (lower = tighter); sets `r` = 1.85 mm in §3.1 |
| `bearing_od` / `bearing_id` | 90 / 60 mm | turntable bearing |
| `ring_gear_teeth` : `motor_gear_teeth` | 200 : 20 | rotation reduction (10:1) |
| `sheet_thk` | 0.8 mm | steel playing sheet glued to the panel front |
| `sheet_hole` | 8 mm | per-square laser-cut sensing hole in the sheet |
| `front_wall` | 2.5 mm | printed wall behind the sheet (sensor bore runs through it) |

A full 8×8 at `square_size = 55` gives a **440 mm** playing area and a
**490 mm** panel (~514 mm over the frame) — a genuine statement wall piece.

`square_size` is no longer a free knob. It was resolved to 55 mm on physical
grounds (§3.2): it is the smallest square whose piece artwork hides the hub
puck. **Changing it means re-checking two things** — that the narrowest waist
still covers Ø11.5, and that `pivot_frac × king_height × piece_scale` still
fits inside `square_size / 2` (at present: 25.66 mm into 27.5 mm, 1.84 mm of
headroom). Going larger also means re-checking magnet hold, since the pieces get
heavier while the Ø8 magnet does not.

---

## 8. Open design questions

Tracked so we decide deliberately. Full status and reasoning for every decision
is in [`GOALS.md`](GOALS.md).

**Still open:**

- **Finish** (D3) — printed two-tone vs. painted vs. veneer/laminate front.
- **Rotate every move vs. on-demand** (D4) — always flip, or a button, or only
  in two-player mode? (UX + belt/slip-ring implications)
- **Where the brain lives** (D5) — phone app, a Pi/ESP32 on the wall, or both.
- **Auto-mover in scope, and by which route** (D6) — aspirational; see §6.
- **Weight budget** — how heavy before the turntable and stepper need upsizing?
  Now bounded rather than open: the panel is fixed at 490 mm square by D1, so
  this is a check to run at Phase 2, not a shape decision.

**Recently closed** (do not re-open casually — each was settled on physical
grounds, not taste):

| | Decision | Outcome |
|---|----------|---------|
| **D1** | Board size | **55 mm squares** — the smallest square whose artwork hides the hub puck (§3.2) |
| **D8** | Pivot placement | **the silhouette's centre**, so settling rotates the piece in place (§3.2) |
| **D9** | Pivot hardware | **a bought Ø3 × 16 mm steel dowel** + silicone damping grease (§3.1) |
| **D10** | Bottom-heaviness | **shaped into the body**; no ballast anywhere in the set (§3.3) |
| **D11** | Piece design language | **one shared rule set**, "Tapered Monolith" (§3.6) |

**Not a decision — an unmeasured input.** The friction coefficient μ is
*assumed*, and every lean figure in this document depends on it linearly.
Nothing has been printed. This is settled by a test, not by a discussion: print
one pawn and one hub (Phase 0 in [`BUILD_GUIDE.md`](BUILD_GUIDE.md)).
