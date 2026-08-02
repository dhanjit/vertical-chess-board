# Making Auto-Move Work on a Vertical Board — a design exploration

Companion to [`AUTO_MOVER_ANALYSIS.md`](AUTO_MOVER_ANALYSIS.md). That doc
explains **why** the standard horizontal trick breaks on a wall. This one is
constructive: **how would we actually build a vertical board that moves its own
pieces?** It surveys the proven prior art, converges on a recommended
architecture, sketches the force/thermal/cost budget, and gives a cheap
prototype ladder.

> 🌠 Status: **aspirational — Phase-3 research track.** None of this is needed
> for the manual board (Phases 0–2), and it's deliberately out of the current
> focus. It's captured so it can be picked up deliberately later — see the
> scope note in [`OVERVIEW.md`](OVERVIEW.md).

---

## 1. What the mechanism must actually do (requirements)

| # | Requirement | Why it's the crux on a wall |
|---|---|---|
| **R1** | Hold **all 32 idle pieces** on a vertical face **continuously** | Gravity doesn't hold them; something magnetic must, at every square, all the time |
| **R1b** | **Fail-safe**: a power loss must **not** drop the pieces | On a wall, "hold" that needs power = a blackout dumps your game on the floor |
| **R2** | **Move** any one piece square→square, routing in the gaps so it passes *around* others | Same as commercial boards |
| **R3** | Do R1 **and** R2 without the two fighting each other | This is *the* problem — see the analysis doc |
| **R4** | Acceptable **heat / power / noise / thickness / cost** | It hangs on a living-room wall, sealed, thin, quiet |
| **R5** | Know where every piece is | Already handled — hall sensor per square in `board_panel.scad` |

---

## 2. The design space (and why it points to an *active backing*)

From the analysis doc, a passive ferromagnetic backing + a single moving
electromagnet **self-conflicts** on a wall (the hold shields the mover, the hold
is what the mover fights, and hold must be everywhere while the mover is one
point). That leaves two families:

- **Move from the *front*** (a robot arm / pick-and-place). Solves R3 trivially
  (no shielding) but a visible arm kills the "invisible magic." → fallback only.
- **Make the *backing itself* active** — a grid of controllable magnets behind
  every square that both **holds** and **moves**. The holders *are* the movers,
  so R3 dissolves: there is no separate shielded mover.

**The active-grid idea is not speculative — it's published, working prior art**
(for horizontal surfaces):

- **MIT Actuated Workbench (2002)** — an **array of electromagnets** under a
  table moves permanent-magnet pucks in 2D under computer control. It introduced
  the key trick for *smooth* motion over discrete coils (§6).
- **Madgets (RWTH Aachen, 2010)** — a **19×12 electromagnet array** that not
  only slides magnetic widgets but **lifts** them and transfers power. Each cell:
  ~19.5 mm dia × 34.5 mm, ~3,500 turns on an iron core; driven by an H-bridge per
  coil (PWM duty = force, polarity = direction).
- **Independent multi-magnet control from a single coil array** (IEEE 2023) —
  research showing several magnets tracked/controlled at once over one array.

So "grid of magnets moves pieces on a surface" is **solved horizontally.** The
only thing those systems *don't* do is hold continuously against gravity with a
blackout-safe latch — and that is exactly what an **electropermanent magnet**
provides.

---

## 3. Candidate architectures

### A. Electromagnet matrix (Actuated-Workbench style), turned vertical
One iron-core **coil behind every square** (64). Energize to hold; energize a
piece's neighbors with graded current to shift the attraction point and **walk**
it (field interpolation, §6).

- ✅ Proven motion technique; integrates with our hall grid.
- ❌ **Vertical killer:** to hold 32 pieces you must keep ~32 coils energized
  *continuously* → real standing power and heat inside a sealed wall panel
  (order **15–60 W**, §7), and a **blackout drops every piece** (fails R1b).
- **Verdict:** works in principle, poor on a wall for heat + fail-safe.

### B. Electropermanent-magnet (EPM) matrix — **recommended**
Replace each coil with an **EPM cell**: a permanent-magnet stack (low-coercivity
AlNiCo + high-coercivity NdFeB) with a small coil. A **~millisecond current
pulse** flips it ON or OFF; it then **holds with zero power**.

- ✅ **R1b fail-safe:** latched cells keep holding through a blackout.
- ✅ **R4 heat:** ~**zero standing power**; only *switching* costs energy, and a
  reference EPM switches on ~**5 mJ** while holding **4.4 N** (≈2000× its own
  weight). Moving a piece across a few cells ≈ tens of mJ total.
- ✅ **R3 dissolved:** the same cells hold and move.
- ✅ **Cheaper drivers than A:** because holding needs no power, only *one cell
  switches at a time*, so the pulse driver can be **shared/multiplexed** across
  the grid (a switching matrix) instead of 64 always-on H-bridges.
- ❌ EPM cells are **semi-custom** (AlNiCo + NdFeB + coil, tuned); discrete
  cell-to-cell hand-off can look **steppy** unless the pitch is fine or a small
  **assist coil** smooths it.
- **Verdict:** the elegant, wall-appropriate path. Everything hard about vertical
  (continuous hold, fail-safe, heat) is what EPM is *good at*.

### C. Hybrid — passive hold + sparse active assist
Keep our **passive** steel-sheet face for baseline hold; add a smaller active
element only to *nudge* a piece from square to square. Reduces power vs A, but
reintroduces the shielding/one-point problems for the active part. Middle
child; only if B's fabrication proves too hard.

### D. Reclined easel + horizontal-style gantry — cheapest bridge
Tilt the board back far enough that gravity does much of the holding (recall
`tanφ ≥ 1/μ`, so **~45–63° from vertical** for gravity-only hold — a big lean),
then reuse a **stock horizontal auto-mover** (Square-Off-style electromagnet
gantry + Stockfish). Cheapest and lowest-risk *if* you accept it's an easel, not
flush wall-art.

| | Holds idle? | Fail-safe? | Standing heat | Motion smoothness | Cost/complexity | Wall-art look |
|---|---|---|---|---|---|---|
| **A** coil matrix | yes (powered) | ✗ | high | good (interp.) | high | ✓ flush |
| **B** EPM matrix | yes (latched) | ✓ | ~none | ok (steppy→assist) | high (custom cells) | ✓ flush |
| **C** hybrid | yes (passive) | ✓ | low | poor | medium | ✓ flush |
| **D** reclined gantry | yes (gravity) | ✓ | low | good | **low** | ✗ easel |

---

## 4. Recommended path: **B (EPM matrix)**, with **D as the cheap fallback**

B is the only option that meets **all** of R1–R4 on a true vertical wall: the
holders are the movers (R3), they latch through blackouts (R1b), and they cost
almost no standing power/heat (R4). It stands on proven building blocks — grid
actuation (Actuated Workbench/Madgets) + zero-power latching (Knaian EPM). If
custom EPM fabrication proves too fiddly for a first build, fall back to **D**
(reclined gantry) to get *a* self-moving board, and revisit B later.

---

## 5. How a piece actually moves (EPM matrix)

1. **Rest:** every occupied square's EPM is latched ON → all pieces held, no power.
2. **Start a move:** pulse the **origin** cell toward OFF while pulsing the
   **first neighbor** along the route toward ON → the piece's magnet is handed
   from cell to cell (a magnetic "bucket brigade").
3. **Route** along the **inter-square gaps** so the piece slides *around* others;
   knights and blocked pieces take an L in the gaps (identical routing logic to
   Square Off).
4. **Captures:** first walk the captured piece to an edge **graveyard lane**,
   then move the capturer.
5. **Smoothness:** discrete hand-off can be steppy; borrow the **Actuated
   Workbench field-interpolation** trick (drive a *cluster* of cells so the
   combined field peak sits *between* cells, then sweep the peak) using a small
   **assist coil** co-located with each EPM, or simply use a **finer pitch**
   (2×2 cells per square).

---

## 6. The shared hard problems — and their known solutions

| Sub-problem | Solution (with precedent) |
|---|---|
| Smooth motion over **discrete** cells | **Field interpolation / "anti-aliasing"** — superpose several cells' fields so the attraction peak lands between them and sweep it (Actuated Workbench) |
| **Collision-free** paths, knights | Route in the **gaps** between squares; **graveyard** captured pieces first (commercial-standard) |
| **Piece position** sensing | **Hall sensor per square** — already in `board_panel.scad`; matrix-addressed like a key-matrix |
| **Fail-safe** hold on a wall | **EPM latching** (B); or, for coil matrix (A), a printed **catch-lip per rank** so a dropped piece is caught, not lost |
| Driving **many** cells | A: **H-bridge per coil**, PWM duty = current (Madgets). B: a **shared pulse driver + row/col address**, since only one cell switches at a time |
| The **brain** | **Stockfish** picks the move; our `chess.js` validates; the mover executes (see `OPEN_SOURCE.md`) |

---

## 7. Force & thermal budget (order-of-magnitude, to be measured)

**Piece is light.** A flat PLA silhouette + 8×3 magnet + small steel weight is
roughly **m ≈ 15–25 g** → weight **≈ 0.15–0.25 N**.

**Holding force needed is small.** On a vertical face, friction must beat
gravity: `μN ≥ mg` → `N ≥ mg/μ`. With `μ ≈ 0.3–0.5`, **N ≈ 0.3–0.8 N** of
magnetic normal force per piece. For reference an 8 mm N52 disc pulls ~**10 N**
to thick steel in ideal contact; against our 0.5–1 mm sheet, through a felt
disc, it's less but still a **few N** — comfortably above the ~0.5 N needed. **So the
hold is easy to *achieve*; the whole game is delivering it at every square at
once, cheaply — which is the A-vs-B story.**

**Why A runs hot and B doesn't.** A coil making ~0.5–1 N at a few mm of standoff
draws roughly **~0.5–2 W** continuously (rough); holding ~32 pieces → **~15–60 W**
of standing heat sealed in a wall panel. An **EPM holds the same force at 0 W**
and only spends a **~5 mJ** pulse to toggle — moving a piece across ~4 cells is
**tens of mJ total**, i.e. thermally free. This single fact is why B is the wall
answer. *(All numbers are estimates to be confirmed on the P1 rig.)*

---

## 8. Prototype ladder (de-risk cheaply, mirrors Phase 0)

| Step | Build | Proves / measures | Cost |
|---|---|---|---|
| **P1** | **One EPM cell** on a vertical plate | Latch-holds a real piece; **power off → stays** (R1b). Measure hold force + switch energy | tiny |
| **P2** | **2–3 cells in a line** | **Hand-off**: walk a piece cell→cell **up/down and sideways** on a vertical plate | small |
| **P3** | **1×8 vertical column** | Full-file moves; total switch energy, driver count, heat; try the assist-coil smoothing | medium |
| **P4** | **8×8** + hall grid + Stockfish | Full game: legal moves, captures→graveyard, rotation hand-off | large |

Only P4 commits real money; P1–P3 answer "does vertical EPM hand-off actually
work?" for the price of a handful of cells — the same "prove the mechanic before
the fleet" discipline used for the gravity pivot.

---

## 9. Rough BOM sketch (EPM path, order-of-magnitude)

- 64 × **EPM cells** — AlNiCo rod + NdFeB + ~hundreds of turns of magnet wire on
  a small core, per cell (semi-custom; the main effort/cost driver).
- **Pulse driver**: a few H-bridge/FET stages + **row/column addressing**
  (shift registers or a mux) — *not* 64 always-on drivers, because holding is
  passive.
- Big **pulse capacitor** + modest PSU (energy is per-switch, not continuous).
- **ESP32/Pi** controller running the sequencer + Stockfish.
- Reuse the existing **hall-sensor grid**, **frame**, **pieces**, **rotation
  hub**. A steel-free / thin-front panel variant for the EPM faces.

*(No firm price yet — P1–P3 exist to turn these into real numbers.)*

---

## 10. Open questions / risks

- **EPM cell fabrication** at square pitch — can we get reliable latching + a few
  N hold from a cheap, hand-woundable cell? (P1 answers this.)
- **Motion smoothness** — is discrete hand-off acceptable, or do we need assist
  coils / finer pitch? (P2–P3.)
- **Cross-talk** — does toggling one cell disturb neighbors holding pieces?
- **Diagonal/knight routing** timing without bumping held pieces.
- **Rotation interaction** — moving happens with the board static; sequence
  move → settle → rotate.
- **Cost/effort** — 64 semi-custom cells is real work; **D (reclined gantry)**
  remains the pragmatic escape if B is too much.

---

## 11. Decision

Updates **D6** in [`GOALS.md`](GOALS.md): if we pursue vertical auto-play, the
target is the **EPM matrix (Path B)**, gated behind prototypes **P1–P3**; keep
the **reclined gantry (Path D)** as the low-risk fallback that yields a working
self-mover sooner at the cost of the flush-wall look.

---

## Sources

- **MIT Actuated Workbench** — array of electromagnets moves magnets in 2D;
  field-interpolation for smooth motion (Pangaro, Maynes-Aminzade, Ishii, UIST
  2002): <https://www.media.mit.edu/publications/the-actuated-workbench-2d-actuation-in-tabletop-tangible-interfaces/>,
  <https://dl.acm.org/doi/10.1145/571985.572011>
- **Madgets** — 19×12 electromagnet array slides **and lifts** magnetic widgets;
  per-coil H-bridge/PWM drive (Weiss et al., UIST 2010):
  <https://hci.rwth-aachen.de/madgets>
- **Electropermanent magnets** — zero-standing-power latch, ~5 mJ switch, ~4.4 N
  hold; AlNiCo+NdFeB+coil (Knaian, MIT thesis 2010):
  <https://cba.mit.edu/docs/theses/10.06.knaian.pdf>,
  <https://en.wikipedia.org/wiki/Electropermanent_magnet>
- **Independent multi-magnet control from one coil array** (IEEE 2023):
  <https://ieeexplore.ieee.org/document/10196212>
- **Hobby electromagnet-grid chess** (concept + challenges): James Stanley,
  "Towards a high-resolution grid of tiny electromagnets"
  <https://incoherency.co.uk/blog/stories/electromagnet-grid.html>;
  "Ghost Chess" (Raspberry Pi):
  <https://magazine.raspberrypi.com/articles/ghost-chess-electromagnets-move-pieces>
- **Horizontal gantry baseline** (Path D reuse): Square Off / "Square On"
  <https://baranusluel.com/square-on/>
- **Magnet pull-force reference** (N52 8 mm disc; falls off through thin
  walls/plates): K&J Magnetics
  <https://www.kjmagnetics.com/magnet-strength-calculator.asp>

*(Web-sourced 2026-07. Force/thermal figures are engineering estimates to be
confirmed on the P1–P3 rigs, not measured results.)*
