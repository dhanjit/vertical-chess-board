# Auto-Mover on a Vertical Board — why it's hard, and how it could work

**Question:** the board plays you by moving its own pieces. On a horizontal
board that's a solved, commercial trick. Why is it hard on our *vertical* wall
board — and is it actually impossible? (Short answer: **not impossible**, but
the cheap elegant trick that works flat quietly breaks on a wall. There are
real ways out; each costs something. This doc captures the reasoning + sources
so we don't re-derive it later.)

Related: [`DESIGN.md` §6](DESIGN.md#6-phase-3--the-board-plays-you-auto-mover-future-scope),
decision **D6** in [`GOALS.md`](GOALS.md), reuse targets in
[`OPEN_SOURCE.md`](OPEN_SOURCE.md).

---

## 1. Two facts that are about to collide

**Fact 1 — what holds a piece on a board.**

| | Horizontal (table) | Vertical (wall) |
|---|---|---|
| What resists the piece falling | Gravity presses it **onto** the board (normal force = weight) | Nothing presses it on; gravity tries to **slide it down** |
| So the hold comes from… | Gravity (free, everywhere, always on) | **Friction**, which needs a **magnetic normal force**: the piece must be pulled hard against the surface so `μN ≥ mg` |

```
 HORIZONTAL                     VERTICAL (wall)
 ┌────┐                         ┌──┐
 │ pc │                         │pc│ →N  magnet pulls piece onto wall
 └────┘                      ═══│  │      (normal force)
═══════ board                   │  │ ↑ friction μN  ── holds it up
   │mg  (gravity = the hold)    └──┘ ↓ mg (gravity slides it down)
   ▼                            wall     need  μN ≥ mg
```

On a wall, **the hold is 100% magnetic.** (Confirmed by the market: vertical
*manual* magnetic boards are common — full steel/magnetic sheet, neodymium in
each piece. Holding pieces on a wall is a solved, shipped thing.)

**Fact 2 — how an auto-mover moves a piece.** A robot *behind* the board
carries an electromagnet on an XY gantry; it switches on to grab a piece's
magnet **through the board** and drags it to the target square. This is exactly
how Square Off / "Square On" and the DIY builds work — electromagnet on a
2-axis NEMA-17 gantry under a board with a magnetic layer, moves chosen by
Stockfish.

---

## 2. Why it's *easy* horizontally

On a flat board gravity is a **perfect** holding force: it is (a) always on,
(b) present under every square at once, and (c) it doesn't interfere with
magnetism. So the single moving electromagnet only has to supply a gentle
**sideways** tug to slide the one piece it's under; all the idle pieces just sit
there under their own weight. Nothing competes, nothing is shielded.

## 3. Why the same trick breaks vertically — three stacked conflicts

**① The "hold" knob and the "shield" knob are the same knob.**
On a wall the hold must be strong and behind *every* square (a steel sheet, or
our per-square washers). But a ferromagnetic backing sitting *between* the
piece magnet and the robot's electromagnet **redirects/absorbs the flux** —
the piece's field loops into the nearby steel instead of reaching the
electromagnet behind it, and the field on the far side of the plate falls as
the plate gets thicker. That's literally how magnetic shielding works. The
catch: **the very thickness/permeability that makes the hold strong is what
shields the mover.** Thin the backing to let the mover couple → the hold gets
weaker. You can't independently maximize both with a passive backing.

```
 piece magnet │ steel backing │ electromagnet (robot)
      ●───▶   │███████████████│   ◀── most flux absorbed by steel;
              │ flux loops in │       little reaches through →
              │ the steel     │       weak, shielded coupling
   strong hold  ⇕ same property ⇕  strong shielding
```

**② The hold is exactly the force the mover must overcome.**
To slide a piece you must beat friction `> μN`. On a wall `N` is deliberately
large (that's the hold). So the mover needs a big lateral force — delivered
magnetically — to beat friction from a big normal force, *while that coupling
is being shielded by ①.* Strong hold and easy motion pull opposite ways.

**③ Hold must be everywhere-always; the mover is one point.**
All 32 idle pieces need holding continuously. A passive backing does that. A
gantry electromagnet is at one (x,y) at a time. Remove the backing so the mover
couples cleanly (the horizontal recipe) and the instant it moves away the other
31 pieces have no normal force → they slide off. Gravity can't save them —
they're vertical.

**Horizontal dodges all three because gravity is a free hold that is always-on,
everywhere, and non-magnetic.** Vertical has to *manufacture* an "always-on,
everywhere, non-shielding" hold — that's the whole difficulty.

**Real-world signal:** every shipping auto-mover (Square Off, ChessUp, Phantom)
and essentially every DIY build is **horizontal**. Plenty of vertical *manual*
magnetic boards exist; **no one ships a vertical auto-mover.** Absence is data.

---

## 4. The subtle shielding truth (so we don't over-claim)

Steel between two magnets doesn't *always* reduce force — a **thin** plate can
act as a flux bridge and even *concentrate* attraction, while a **thick** plate
shields the far side. For our geometry (mover behind the hold layer) the
usable takeaways are:

- A **solid/thick** steel backing → strong hold, strong shielding (mover blind).
- A **thin** backing → weaker shielding (mover couples better) **but weaker
  hold**. The washer-with-a-hole idea exploits this — but a gantry travelling in
  the gaps between squares isn't aligned to the holes, so the surrounding steel
  still dominates.
- Net: there's a **genuine trade**, not a wall. That's why the escapes below are
  about *changing the architecture*, not tuning one number.

---

## 5. Ways it CAN work (each with its cost)

| Path | How it dissolves the conflict | Cost / catch |
|---|---|---|
| **A. Switchable-magnet matrix** — an **electropermanent magnet (EPM)** or driven **coil** behind *every* square | The holders **are** the movers. Squares are ON to hold all pieces; pulse a path of squares OFF/ON to walk a piece across. **No separate mover → no shield, no "one point" problem.** EPMs hold with **zero standing power**, toggled by a pulse. Independent multi-magnet control from a coil array is demonstrated in research. | 64 controlled magnets + driver electronics + heat/power + custom PCB. The **elegant** answer, but the most parts. |
| **B. Thin backing + strong, close mover** (+ grippy face, maybe mild recline) | Minimize the shield: thinnest steel that still holds idle pieces; a strong permanent/electro-magnet riding *right* against the back overpowers the local hold and drags. (This is the "make the gantry as thin as possible" idea from the *Mags* project.) | Marginal physics — hold is precarious, coupling is weak, knights/routing fiddly. Cheapest to try, least reliable. |
| **C. Front-side robot** (pick-and-place arm, "Raspberry Turk" style) | Hold with solid steel behind; move from the **front**, so shielding is irrelevant. | A visible arm on the wall — kills the clean "invisible magic" look. |
| **D. Recline to an easel** | Tilt lets gravity add real normal force, so the backing can be weaker / the mover couples better — you slide toward the solved horizontal case. | Not flush wall-art anymore, and the tilt must be **big** (next section). Usually combined with B or detents. |
| **E. Per-square dimples + weak magnet** | Pieces mechanically **nest** so they can't slide; a light magnet just seats them. | Then you must lift a nested piece *out* of its dish (a hard normal-direction pop) or shove it over ridges via a shielded magnet — hard to move. |

**The cleanest resolution is A.** It's the only one that removes the gantry
entirely, so conflicts ①–③ simply don't arise: the switchable holders do the
moving. If we ever seriously pursue vertical auto-play, **A is the path**, and a
single-column test rig is the way to de-risk it (see §7).

---

## 6. The recline math (why "just lean it back a bit" doesn't hold pieces)

For **gravity alone** to hold an idle piece on a board tilted `φ` from vertical:

```
 normal from gravity   = mg·sinφ      (presses piece onto board)
 down-slope pull        = mg·cosφ
 no-slip needs μ·mg·sinφ ≥ mg·cosφ  →  tanφ ≥ 1/μ  →  φ ≥ arctan(1/μ)
```

- Plastic-on-painted face, `μ ≈ 0.5` → `φ ≥ 63°` from vertical = only **27° off
  flat** (a drafting table, not a wall piece).
- Grippy silicone face, `μ ≈ 1` → `φ ≥ 45°` from vertical.

So a gentle 15–20° tilt does **not** let you drop the magnets; it only *reduces*
the load so a weaker backing / shallow detents can finish the hold. "Path D"
realistically = mild recline **plus** B or E. Good to know before anyone bets on
a small tilt.

---

## 7. If we ever build it: de-risking Path A

Before a full 8×8 EPM/coil matrix, build a **single row (1×8) test rig**:

1. 8 EPM (or coil) cells behind 8 squares on a **vertical** test panel.
2. Verify each cell **holds** a real piece with power off (EPM latched).
3. Verify a **pulse sequence** walks a piece cell→cell up/down/sideways on the
   vertical panel without it dropping.
4. Measure heat, pulse energy, driver count → extrapolate to 64 cells.
5. Only then commit to the full matrix + the reclined/steel-free panel variant.

This proves or kills the interesting path for the price of 8 cells, mirroring
the Phase-0 "prove the mechanic first" discipline used for the gravity pivot.

---

## 8. Bottom line

- **Not physically impossible.** The *cheap elegant* horizontal trick (passive
  steel + one hidden electromagnet) is **self-contradicting on a wall**: the
  hold shields the mover (①), the hold is what the mover fights (②), and the
  hold must be everywhere while the mover is one point (③).
- Vertical **holding** is solved (commercial). Vertical **auto-moving** is the
  unsolved part — and its absence from the market is corroborating evidence.
- The honest path to true vertical auto-play is a **switchable-magnet matrix
  (Path A)**, prototyped as a 1×8 rig first; the cheap fallback is **thin
  backing + strong close mover, mildly reclined (B/D)**, accepting lower
  reliability.
- **None of this affects the manual board.** Phases 0–2 stand as-is; this is a
  Phase-3 research track, deliberately deferred.

---

## Sources

- Square Off / "Square On" auto-board mechanism (electromagnet on a 2-axis
  NEMA-17 gantry under a magnetic-layer board, Stockfish move selection):
  <https://baranusluel.com/square-on/>,
  <https://squareoffnow.com/>,
  <https://techcrunch.com/2019/01/15/the-square-off-chess-board-melds-the-classical-with-the-robotic/>
- Vertical **manual** magnetic wall boards are common commercial products
  (holding is solved): <https://www.elevatedchess.com/category/vertical-chess>,
  <https://www.chessboart.com/products/chessclub-wall-chess-set>
- Steel redirects/concentrates flux and shields the far side (thin-vs-thick
  nuance): K&J Magnetics, "Does Steel Block or Improve Magnetic Strength?"
  <https://www.kjmagnetics.com/blog/steel-effect-on-magnet-strength>;
  magnet-to-iron vs magnet-to-magnet adhesion:
  <https://www.supermagnete.de/eng/faq/What-is-the-difference-between-the-combination-magnet-magnet-and-magnet-iron>
- Electropermanent magnets (switch with a pulse, hold with **zero standing
  power**), incl. array actuation:
  <https://blog.mbedded.ninja/electronics/components/electropermanent-magnets-epms/>,
  <https://www.sciencedirect.com/science/article/abs/pii/S0924424719301943>
- Independent control of **multiple magnets from a single coil array**
  (research basis for a switchable matrix):
  <https://ieeexplore.ieee.org/document/10196212>
- Thin-gantry magnetic mover ("Mags" project): <https://kogappa.com/projects/mags/>

*(Web-sourced 2026-07; treat product/spec details as starting points, verify before relying.)*
