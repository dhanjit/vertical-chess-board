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
surface is a thin **steel sheet** glued onto the printed panel (see §4); every
piece is held to it by a **magnet**, so pieces grip the vertical surface and
can slide square to square. Each piece body hangs on a **low-friction pivot**
and is **bottom-heavy by shape** — solid below the pivot, hollow above it —
making it a pendulum that always points up.

*Where* that magnet lives — behind the piece in a printed hub, or inside the
piece itself — is a **selectable variant**, and so is the piece artwork. Both
are laid out in §3.

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

        ┌───────────┐
        │  ░░░░░░░  │      ⊙ pivot — at the silhouette's own centre
        │  ░░░░░░░  │        AND at the square's centre
        │──── ⊙ ────│
        │           │      ░ hollow above the pivot
        │  ███████  │      █ solid below it
        │  ███████  │        → centre of mass BELOW ⊙ → it hangs upright
        └───────────┘
```

**Two things about a piece are kept as selectable variants**, set at the top of
[`common.scad`](../hardware/common.scad), because the point is to compare
approaches side by side rather than argue about them — and more approaches are
expected:

```
piece_style = "familiar";   // "monolith" | "familiar"        — the artwork   (§3.5)
pivot_type  = "pin";        // "pin" | "magnet" | "bearing"   — how it hangs  (§3.2)
```

The two axes are **independent**. Any of the six combinations builds; no
artwork file knows anything about bores or magnets, and no pivot code knows a
style by name. Everything in §3.1, §3.3 and §3.4 below is common to all of
them. (Rendering a variant: see [`../hardware/README.md`](../hardware/README.md).)

> **Choosing between them:** this section explains *how each approach works*.
> [`PIECE_DESIGNS.md`](PIECE_DESIGNS.md) is the page for *deciding* — the same
> options laid out side by side as a comparison, with each one's part count,
> measured costs and unproven claims collected in one place, plus how to add a
> further approach without touching any existing one.

### 3.1 The physics, stated once

Every number in the piece design answers to one equation, and it is the same
equation for every pivot architecture. A hanging piece does **not** park
perfectly upright — it parks at the angle where friction in the bore exactly
cancels the gravity torque:

```
    sin(lean)  =  μ · r / d

      μ  friction coefficient in the bore   assumed 0.08 (greased steel on plastic)
      r  the RADIUS the piece rubs at       1.85 mm  pivot_type "pin"    (Ø3.70 bore)
                                            2.35 mm  pivot_type "magnet" (Ø4.70 bore)
      d  how far the centre of mass sits
         BELOW the pivot                    4.7 – 9.0 mm across the styles
```

Four consequences drive the whole design:

1. **Mass cancels out — entirely — for a single rigid piece.** Weight appears on
   both sides of the torque balance and divides away. Adding ballast does
   **nothing** for how straight a piece hangs; only geometry (`d`) and friction
   (`μ · r`) move the number. This is the most counter-intuitive fact in the
   project, and it is why the ballast was deleted rather than tuned (§3.4).
2. **The exception, and it is the whole argument between the two pivot
   architectures: mass added *at* the pivot still hurts.** It sits at zero lever
   arm, so it adds **no** restoring torque — but it is still part of the body,
   so it drags the *combined* centre of mass toward the axis and **shrinks
   `d`**. Mass cancelling is a statement about a rigid body's *own* weight, not
   a licence to hang hardware on the axis for free. `pivot_type = "magnet"`
   hangs a magnet and a steel disc exactly there, and pays for it in lean
   (§3.2).
3. **The centre of mass must sit *below* the pivot.** That is what `d` is. Above
   the pivot it would be an inverted pendulum and would flop to whichever side
   it was nudged.
4. **It must also sit *directly under* the pivot.** A pendulum hangs with its
   mass plumb below the axis, so a silhouette that is heavier on one side hangs
   **permanently rotated** — and no amount of friction tuning fixes that,
   because it is not a lean, it is where "down" now is for that shape. Most
   pieces are drawn mirror-symmetric and get this for free. Each style's
   **knight** is not, and is that style's one fragile piece because of it
   (§3.5).

So there are exactly **two levers** on the lean: **cut `μ · r`**, or **grow
`d`**. Bought steel and damping grease attack the first (under `"pin"`, the
Ø4 → Ø3 change alone was ~19% less lean, for free). The pivot placement (§3.3),
the shaped-in cavity (§3.4) and the choice of artwork (§3.5) fight over the
second, and the pivot architecture (§3.2) trades one against the other.

**Friction is a tuning knob that cuts both ways.** Too much and the piece parks
crooked. Too little and *nothing damps the swing* — a piece on a bare ball
bearing would ring for a minute after every flip. The answer is **silicone
damping grease**: viscous drag kills the ringing without adding the static
friction that causes the lean in the first place. (Dry PTFE lube makes the
opposite trade; a ball bearing was evaluated and rejected for the same reason —
see **D9** in [`GOALS.md`](GOALS.md).)

### 3.2 The pivot architectures — where the magnet lives

All of them are built by
[`gravity_gimbal.scad`](../hardware/gravity_gimbal.scad), and `pivot_type` in
`common.scad` picks one. **The two magnet architectures differ in exactly one
decision — whether the magnet is on the board or in the piece — and everything
else follows from it.** The third, `"bearing"`, is the `"pin"` stack with the
piece's sliding bore swapped for a bought MR63ZZ ball bearing: parking becomes
≈0° at *any* friction (the fallback if Phase 0 measures μ badly), at the price
of one bearing per piece and an undamped swing — its full costing lives in
[`PIECE_DESIGNS.md`](PIECE_DESIGNS.md), and the table below compares the two
magnet architectures it modifies.

| | `pivot_type = "pin"` (default) | `pivot_type = "magnet"` |
|---|---|---|
| The magnet is… | on the **board**, in a printed hub puck | in the **piece**, in its own bore |
| The piece turns on… | a bought **Ø3 × 16 steel dowel** | **the magnet itself** — the magnet is the journal |
| Printed per piece | **3** — body, hub puck, press cap | **1** — the body, and nothing else |
| Bought per piece | 2 — Ø8 × 3 magnet, Ø3 × 16 dowel | 2 — Ø4 × 5 magnet, Ø9 × 0.8 steel disc |
| `r` in §3.1 | **1.85 mm** (Ø3.70 bore) | **2.35 mm** (Ø4.70 bore) |
| Magnet mass in the pendulum | **none** — it is on the board | **all of it**, at zero lever arm |
| Modelled lean, style `familiar` | 0.94 – 1.44° | 1.37 – 2.09° |
| Status | fully specified; nothing printed | fully specified; **two claims unproven** (below) |

Over a full 32-piece set that is **64 fewer printed parts and 32 fewer dowels**
under `"magnet"` — three things removed per piece (hub, dowel, cap) against one
added (the retaining disc).

#### `"pin"` — the magnet stays on the board

```
   front (room) ◄──────────────────────────────► back (wall)

        ┌───────────┐        the stack, front to back
        │  ░░░░░░░  │          press cap    4.7 mm    Ø6, grips the dowel tip
        │  ░░░░░░░  │          piece body   6.0       the silhouette plate
        │──── ⊙ ────│          hub puck     8.0       Ø11.5, magnet in its back
        │           │          ─────────────────      ↳ magnet touches the sheet
        │  ███████  │          axle: Ø3 × 16 mm steel dowel, 11 mm proud
        │  ███████  │                6.0 + 3.5 grip = 9.5
        └───────────┘                → 1.5 mm axial float, by design
```

| Part | Role |
|------|------|
| **Hub puck** — Ø11.5 × 8 mm, printed | A Ø8 × 3 mm neodymium magnet press-fits into its **back** and grips the steel board face; the **front** is bored for the axle. The puck sticks to a square and turns *with* the board. It is deliberately small enough that the piece in front **hides** it (§3.3). |
| **Axle dowel** — Ø3 × 16 mm, **bought** | A stock steel dowel pin pressed into the hub until it bottoms out **on the magnet**, so there is no thin printed web to crack. Steel because friction is what decides how straight a piece parks (§3.1). Thin because a Ø3 *steel* dowel takes a 20 N sideways knock with **3.0× margin**, where the Ø4 *printed* post it replaced had only 1.29× — it snapped at the layer line. **Thinner and stronger, not a compromise.** |
| **Body** — the silhouette plate, 6 mm, printed | Flat, so it reads across the room and prints face-down with no supports. A Ø3.70 bore drops over the dowel and spins freely on it. Bottom-heavy **by shape** — solid below the pivot, hollow above — with **nothing glued in** (§3.4). |
| **Press cap** — Ø6 mm, printed | Grips the plain dowel by interference (three slit fingers spread as it goes on) so the body cannot fall off but still turns. It is the only part of the mechanism that faces the room, sitting mid-piece, so it is sized to vanish into the silhouette rather than read as a button. |

**The point of this architecture:** the magnet's mass is on the *board* side of
the joint, so it never enters the pendulum at all. Every gram in the piece is a
gram that is free to sit low and lengthen `d`.

#### `"magnet"` — the magnet rides in the piece

```
   front (room) ◄──────────────────────────────► back (wall)

        ┌───────────┐        the stack, front to back
        │  ░░░░░░░  │          steel disc   0.8 mm    Ø9, sunk in a 1.0 counterbore
        │  ░░░░░░░  │          piece body   6.0       the silhouette plate
        │──── ⊙ ────│          magnet       5.0       Ø4, in the piece's own bore,
        │           │                                 flush with the back face
        │  ███████  │          ─────────────────      ↳ magnet touches the sheet
        │  ███████  │          no hub, no dowel, no cap
        └───────────┘
```

| Part | Role |
|------|------|
| **Magnet** — Ø4 × 5 mm, **bought** | Drops into the piece's own Ø4.70 bore **from the back** and finishes flush with the back face, so it grips the steel sheet with no plastic in the gap. **The piece turns on the magnet** — the magnet is both the holder and the journal. Ø4 rather than Ø5 because it *is* the `r` in §3.1: Ø5 was modelled and is worse on every piece (familiar pawn 2.27° vs 1.80°). |
| **Retaining disc** — Ø9 × 0.8 mm steel, **bought** | Held on the magnet's front pole by that same magnet — **no glue** — and recessed into a 1.0 mm counterbore in the piece's **front** face, so it sits 0.2 mm below flush. Being wider than the bore it cannot pass through it, and that is the *only* thing stopping the piece pulling off the magnet. |
| **Body** — the silhouette plate, 6 mm, printed | As above, plus the counterbore. A local Ø11.4 collar keeps a full 0.9 mm floor under the disc seat, so the disc bears on solid plastic all round instead of over the lightening cavity. The collar sits at ~zero lever arm, so it costs under 0.1 mm of `d`. |

**What it costs, and why — both halves are §3.1 consequences 1 and 2:**

- **`r` grows**, 1.85 → 2.35 mm, because the piece now rubs on a Ø4.70 bore
  instead of a Ø3.70 one. Straight numerator.
- **`d` shrinks**, because the magnet *and* the disc ride **with** the piece at
  zero lever arm. Their mass adds no restoring torque and pulls the combined
  centre of mass toward the axis.

On style `familiar` that is measured at roughly **+0.4 to +0.6°** of lean (the
rook worst, at +0.65°). On the smaller `monolith` pieces the same swap costs up
to **+1.1°**, which is enough to break them — see §3.6. That is the trade in one
line: **two fewer parts per piece — and two fewer *printed* ones — paid for in
lean**, and how much lean depends on the artwork it is paired with.

> **Two things about `"magnet"` are UNPROVEN, and neither is in the lean
> numbers.**
> 1. Nothing has verified that a Ø9 steel disc actually **stays put** on a Ø4
>    magnet through a board flip.
> 2. The disc bears on the counterbore floor, so it presses the piece's **whole
>    back face** onto the steel sheet with the magnet's full pull. Rotation then
>    has to overcome **face** friction at silhouette radii, not just bore
>    friction at r = 2.35 mm. **The lean figures model bore friction only and
>    are therefore optimistic for this architecture.** Under `"pin"` the piece
>    bears on the hub's Ø11.5 face under its own weight only, so the same
>    objection does not apply there.
>
> Both are settled by one ~2 g print: under `pivot_type = "magnet"`,
> `make gimbal` renders a **pivot test coupon** carrying exactly the bore and
> the disc seat and nothing else. Press a magnet in, stick the disc on, put it
> on the steel sheet, flip it, and see whether it holds and still turns.

> **Jargon, plainly:** a **dowel pin** is a plain ground-steel rod, sold by the
> hundred in any fastener shop. A **press fit** means the hole is cut slightly
> *undersize* so the pin is held by friction alone — no glue, no thread. A
> **counterbore** is a flat-bottomed widening at the mouth of a hole, here so a
> disc can sit **in** the face rather than on it. The **1.5 mm axial float**
> under `"pin"` is deliberate slack along the dowel: without it, normal print
> tolerance could clamp the piece between cap and hub and stall the very
> rotation the mechanism exists to allow.

### 3.3 Why the pivot sits at the silhouette's centre

`pivot_frac = 0.50` puts the bore at the centre of the silhouette's bounding
box, and that bore at the centre of the square. It applies to **every** style
and **both** pivot architectures — it is the mechanism's one demand on the
artwork. Two things follow:

- **The piece reads centred in its square**, rather than dangling from its head
  like a pendant.
- **It stays centred through a flip.** Because the piece turns about its own
  centre, whatever small angle it settles at merely **rotates it in place**
  instead of swinging the body sideways. The sideways offset is zero at *every*
  angle, not just at rest — which matters, because the settling happens while
  the board is still moving. Pivot anywhere else and the settling error becomes
  a *translation*: the piece finishes the flip visibly off-centre in its square,
  and the error is largest exactly while the board is turning and someone is
  watching. (An earlier design pivoted above the middle for a stronger "down";
  it bought settling speed at the price of every piece hanging low and swinging
  off-centre.) This is decision **D8**.

**The cost is paid in `d`, and it is real.** The centre of mass of a shape can
never be far below the *middle* of that same shape — pivoting at the centre
caps `d` at a few millimetres (4.7–9.0 mm across the two styles) where a
head-hung piece could have had twenty. A small `d` is a bigger lean, straight
out of §3.1. That is precisely what the steel dowel, the grease, and the cavity
above the pivot are buying back. **It is a deliberate purchase of appearance
with mechanism, made once, and it sets the difficulty of everything else in
this section.**

A second consequence sets the board's scale, and it belongs to `pivot_type =
"pin"`: the puck sits *behind* the piece, so the piece must **hide** it or every
piece wears a grey collar. The mechanical parts do not scale with the square —
only the **artwork** does — so enlarging the square grows the silhouette until
it swallows the puck. At 45 mm squares the narrowest waist covered only Ø9.8 and
the puck showed. **55 mm is the smallest square at which the narrowest waist in
the `monolith` style (Ø12.0) covers the Ø11.5 puck with nothing added** — no
skirt, no collar, no fake boss; 0.5 mm to spare. (`familiar` is far clear of it:
its narrowest waist is the rook's 20 mm tower.) That resolves decision **D1**,
and it is why the panel grew from ~410 mm to ~490 mm square.

Under `pivot_type = "magnet"` there is no puck to hide, but the pivot still
demands silhouette width at the centre: the Ø9.6 disc seat plus its 0.9 mm wall
is a **Ø11.4 collar** that has to fit inside the artwork. The narrowest waist
either style puts at the pivot is the monolith king's 12.1 mm, so this is a real
constraint on any future style, not a formality.

### 3.4 Bottom-heavy by shape, not by ballast

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

### 3.5 Two piece styles

**Flat silhouettes** are deliberate whichever style you pick: readable at
living-room distance, cheap to print, and light (less pendulum inertia). Two
finishes or two filament colours separate White from Black.

But "flat silhouette" is a *format*, not a style. Two complete sets are drawn to
it and kept side by side, one file each in
[`hardware/styles/`](../hardware/styles), and `piece_style` chooses between
them. Each style file is **artwork and nothing else** — it draws six
silhouettes, says how tall they are, and says where their cavities can be
drained. It knows nothing about bores, magnets, hollowing or thickness;
`pieces.scad` owns all of that and applies the identical mechanism to whatever
it is handed. **Adding a third style is one new file and one enum entry**, not a
rewrite.

| | `"monolith"` | `"familiar"` (default) |
|---|---|---|
| What it looks like | an invented design language: one taper, one stroke, rank = height + one terminal event | the online-chess / fridge-magnet vocabulary a player already knows |
| Learning curve | you have to learn it | nobody has to be taught what any piece is |
| Drawn at | nominal mm × `MONO_SCALE` = 1.222 | final size — no scale factor |
| Heights | 31.8 – 51.3 mm | 40.0 – 52.0 mm |
| Widths | 20.7 – 30.0 mm — sits *in* its square | 30.0 – 42.0 mm — *fills* its square |
| Modelled lean (`"pin"`) | 0.98 – 1.81° | 0.94 – 1.44° — better on five pieces of six |
| Survives `pivot_type = "magnet"` | **no** — busts the 2.2° limit on three pieces, with a fourth 0.01° under it | yes, 1.37 – 2.09° |

`"familiar"` is the default because it is both the look asked for **and** the
better mechanism: bigger pieces put more area further below the pivot, and that
area *is* `d`. What it trades away is width and sweep clearance (§3.6).

#### `"monolith"` — the invented language ("Tapered Monolith")

The six shapes are drawn to **one shared rule set** (decision **D11**) rather
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

(Those constants are in *nominal artwork* millimetres — before `MONO_SCALE` =
1.222. They live in `styles/monolith.scad`, **not** `common.scad`, precisely
because they are drawing units rather than real ones: next to real mechanical
millimetres they would read as though the hub or the board depended on them.
The board depends on exactly one thing from a style — the real printed height
it reports back.)

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

> **⚠ The knight is this style's one deliberate exception, and its one fragile
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
> right, and then hang permanently rotated** (see consequence 4 in §3.1). If you
> touch it, re-measure the centre of mass and re-solve `KDX`. This is flagged in
> `styles/monolith.scad` at both the constant and the knight's branch. As drawn
> it lands at **+0.06°**, not 0.00 — small, but it is the one piece in the style
> that is not exactly plumb.

#### `"familiar"` — the vocabulary everyone already knows

The look asked for, and the default: **ball-and-collar pawn, crenellated rook,
horse knight, cleft-mitre bishop, coronet queen, cross king.** There is no
design language to learn — the whole argument for the style is that nobody has
to be taught what any piece is.

It is drawn **at final size**, so there is no scale factor: what is written in
`styles/familiar.scad` is what gets printed. Heights run 40 / 43 / 44.5 / 47.5 /
50 / 52 mm — a 1.30× spread, strictly ordered.

Two drawing languages live in the file on purpose:

- **Five pieces are hulls of circles, half-drawn and mirror-unioned.** They are
  *exactly* mirror-symmetric by construction, so §3.1 consequence 4 is satisfied
  structurally and they hang plumb with no tuning at all.
- **The knight is a polygon**, softened by one global rounding pass. It is the
  one asymmetric piece, and the only one whose balance is solved numerically.

Two properties are worth knowing before editing anything:

> **⚠ The familiar knight is 40.5 mm wide — wider than the bishop (36) and the
> rook (38) — and that is structural, not taste.** The bore must land on the
> bounding-box centre (so the piece reads centred and *stays* centred through a
> flip, §3.3) **and** on the centre of mass (so it hangs plumb, §3.1). On a
> horse's head those are different points. The fix is to draw the **symmetric
> foot wider than the head reaches on either side**, so the foot owns both
> bounding-box edges and the centre is pinned on x = 0 by construction. The foot
> has to out-reach the muzzle, and that is where the width goes.
>
> **Its balance is still tuned, exactly like the monolith knight's.** A constant
> `KDX` slides the head until the moment about the centreline cancels — solved
> against the *rendered mesh*, cavity and bore and drain included, not against
> the 2D area. **Edit the head and the piece renders fine, passes the shell
> check, and hangs crooked.** Re-solve `KDX` if you touch it.

> **The rook's foot is 38 mm wide and 13.5 mm tall for mechanical reasons.**
> Crenellation is by definition a lot of area high above the pivot, so the rook
> is the worst lever in any set that draws it honestly. The lever is bought back
> with mass **low** rather than by softening the merlons (`d` 5.50 → 5.89 mm).
> That margin is what lets the style survive `pivot_type = "magnet"` at all — the
> rook is the piece that runs out first (§3.7).

### 3.6 The set as modelled

At 55 mm squares. **Every figure below is measured off an exported mesh — see
§3.7 before quoting any of it.** All 24 combinations of piece × style × pivot
render as **one shell** (so every cavity drained), with the pivot exactly on the
silhouette centre and the piece standing inside its square.

**Style `"familiar"` (the default):**

| Piece | Height | Width | Lever `d` | Lean, `"pin"` | Lean, `"magnet"` | Mass |
|-------|-------:|------:|----------:|--------------:|-----------------:|-----:|
| Pawn   | 40.00 | 30.00 | 7.34 mm | 1.16° | 1.80° | 3.79 g |
| Rook   | 43.00 | 38.00 | 5.89 mm | **1.44°** | **2.09°** | 6.11 g |
| Knight | 44.50 | 40.47 | 7.51 mm | 1.13° | 1.62° | 6.49 g |
| Bishop | 47.50 | 36.00 | 9.02 mm | 0.94° | 1.37° | 5.64 g |
| Queen  | 50.00 | 41.80 | 7.55 mm | 1.12° | 1.60° | 7.17 g |
| King   | 52.00 | 42.00 | 8.59 mm | 0.99° | 1.40° | 7.49 g |

**Style `"monolith"`:**

| Piece | Height | Width | Lever `d` | Lean, `"pin"` | Lean, `"magnet"` | Mass |
|-------|-------:|------:|----------:|--------------:|-----------------:|-----:|
| Pawn   | 31.77 | 20.74 | 5.71 mm | 1.49° | **2.61°** | 2.24 g |
| Rook   | 36.66 | 24.61 | 4.68 mm | **1.81°** | **2.89°** | 3.43 g |
| Knight | 39.10 | 26.44 | 6.05 mm | 1.40° | **2.19°** | 3.75 g |
| Bishop | 42.77 | 29.98 | 7.29 mm | 1.16° | 1.75° | 4.52 g |
| Queen  | 46.44 | 25.34 | 5.72 mm | 1.48° | **2.27°** | 4.23 g |
| King   | 51.32 | 25.59 | 8.68 mm | 0.98° | 1.49° | 4.24 g |

`d` is the pendulum lever under `"pin"`; under `"magnet"` it is smaller on every
piece, for the reason in §3.1 consequence 2, which is why the last two columns
differ. **Bold = at or past the 2.2° working limit, or the worst in its column.**

**The one result that is not a free choice:** `monolith` + `magnet` **busts the
2.2° limit on three pieces of six** (rook 2.89°, pawn 2.61°, queen 2.27°), with
the knight a hundredth under it at 2.19° — only the bishop and king keep real
margin. The monolith pieces are small, so `d` is
small, and the magnet architecture's penalty is close to a fixed subtraction
from `d` — a fixed subtraction hurts a short lever far more than a long one.
The two axes are independent *in the code*; they are **not** independent in the
outcome, and this is the pair to avoid.

**Clearance during a flip** is a different question from "fits in its square",
because a rotating piece sweeps a *circle* of its longest corner. Measured
sweep radius from the pivot, against a **27.5 mm** half-square:

| | pawn | rook | knight | bishop | queen | king |
|---|---:|---:|---:|---:|---:|---:|
| `familiar` | 24.44 | 28.12 | 29.42 | 29.24 | 31.45 | **32.85** |
| `monolith` | 18.60 | 21.70 | 23.22 | 25.73 | 26.10 | **28.34** |

The monolith king crosses its square line by 0.84 mm mid-flip; **the familiar
king crosses by 5.35 mm**, and four of its six pieces cross at all. **This is
still not a collision, but the reason it is not has become the only thing
holding it up:** neighbouring pieces ride one rigid board and each stays upright
in the *room's* frame, so two adjacent pieces never move relative to each other.
That argument fails only if one piece **lags** while its neighbour is already
upright, and then the bound is the lagging piece's sweep plus the neighbour's
half-width. Worst legal pair:

- `familiar` — king + queen, 32.85 + 20.90 = **53.75 mm** against the 55 mm
  pitch: **1.25 mm of margin.**
- `monolith` — king + bishop, 28.34 + 14.99 = **43.33 mm**: 11.67 mm of margin.

**Two adjacent royals lagging at once is not covered** for `familiar`
(32.85 + 31.45 = 64.30 mm), and **nothing has tested whether pieces stay in step
through a flip.** If they do not, that is a mechanical argument for the monolith
set — the one place where the artwork choice is also a mechanism choice.

### 3.7 Read these numbers honestly

> **Nothing in this repo has been printed.** Every figure above is measured off
> an exported mesh, not off an object. They are model outputs, not
> measurements of hardware.

- **Every lean rests on an assumed μ = 0.08** for greased steel on plastic. That
  is a **textbook figure, not one measured on this hardware.** Lean scales
  linearly with μ: if the real value is double, so is every angle in both
  tables. **One printed pawn plus one hub settles it, and it is the cheapest
  test in the project** — do it before committing to a set (Phase 0 in
  [`BUILD_GUIDE.md`](BUILD_GUIDE.md)).
- **The rook has the least margin in both styles** — 1.44° familiar, 1.81°
  monolith, against a 2.2° working limit. Crenellation is a lot of area high
  above the pivot. It is the piece to watch once real friction is known.
- **Both knights' balance is tuned, not structural** — see §3.5. Either one can
  be broken by an edit that renders perfectly cleanly.
- **`pivot_type = "magnet"` carries two unproven claims** (§3.2), and neither is
  in the lean numbers: that the retaining disc stays put through a flip, and
  that the piece still turns once that disc clamps its whole back face to the
  steel sheet. Those figures model **bore** friction only, so they are
  optimistic for that architecture.
- **Unchecked:** print orientation, overhangs, and whether the magnet holds the
  heaviest piece — the familiar king at 7.49 g, hanging 11 mm proud of the wall,
  two-thirds heavier than the monolith set's heaviest (bishop, 4.52 g). Under
  `"magnet"` that hold is a **Ø4** disc rather than a Ø8 one, and it is also
  carrying the retaining disc.

> **Do we need both mechanics?** Yes, and they complement each other. The
> *rotation* flips the board coordinates so the mover sees their own back
> rank at the bottom; the *gravity pivot* guarantees the piece art is upright
> throughout and after that flip. Together the board always looks "normal" to
> whoever is on move.

---

## 4. Holding pieces on a vertical board (magnets + steel sheet)

- The playing surface is a **thin steel sheet** (`sheet_thk` ≈ 0.5–1 mm) glued
  onto the printed panel's front. The piece magnet grips the sheet
  **directly** — the same attachment every commercial magnetic wall chess set
  uses, so the hold is proven rather than hoped-for (decision **D7** in
  [`GOALS.md`](GOALS.md)). This is true of **both** pivot architectures; what
  changes between them is only which side of the joint the magnet is on (§3.2).
- Under `pivot_type = "pin"` the magnet is an **8 × 3 mm N52 neodymium disc**
  (`magnet_dia`/`magnet_thk`) pressed into the **back of the hub puck**. The
  piece body itself then contains **no magnet and no metal**; it just hangs on
  the hub's dowel.
- Under `pivot_type = "magnet"` the magnet is a **Ø4 × 5 mm disc inside the
  piece's own bore**, flush with its back face, plus a **Ø9 × 0.8 steel disc**
  in the front face that keeps the piece on it. The hold is smaller in diameter
  but longer, and it is carrying a heavier assembly (piece + magnet + disc);
  **that combination has not been checked against a piece's weight.**
- A **felt disc over the magnet** is the tuning knob under `"pin"`: it sets the
  glide (thicker felt = weaker, smoother slide) and keeps the sheet's paint
  scratch-free. Under `"magnet"` there is nowhere to put it without also
  lifting the piece off the sheet, which is one more reason that architecture
  needs the coupon test in §3.2.
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
| **`piece_style`** | **`"familiar"`** | which artwork — `"monolith"` or `"familiar"` (§3.5). One file each in `hardware/styles/` |
| **`pivot_type`** | **`"pin"`** | how a piece hangs — `"pin"` or `"magnet"` (§3.2) |
| `square_size` | **55 mm** | one playing square (**D1**, locked — see §3.3) |
| `pivot_frac` | 0.50 | pivot height as a fraction of piece height — 0.50 = the silhouette's centre |
| `piece_thk` / `hollow_wall` | 6 / 0.9 mm | silhouette plate thickness, and the wall left around the cavity |
| `magnet_dia` × `magnet_thk` | 8 × 3 mm | hub magnet — `pivot_type = "pin"` only |
| `hub_dia` / `axle_dia` | **11.5 / 3 mm** | `"pin"` pivot: puck diameter, dowel diameter |
| `cap_dia` | 6 mm | `"pin"` pivot: the retaining cap, the one part facing the room |
| `pivot_magnet_dia` × `_thk` | 4 × 5 mm | `"magnet"` pivot: the magnet the piece turns **on** |
| `retain_disc_dia` × `_thk` | 9 × 0.8 mm | `"magnet"` pivot: the steel disc that keeps the piece on the magnet |
| `disc_seat_depth` | 1.0 mm | `"magnet"` pivot: counterbore in the piece's front face |
| `axle_fit` | 0.35 mm | swivel clearance (lower = tighter); sets `r` in §3.1 — 1.85 mm under `"pin"`, 2.35 mm under `"magnet"` |
| `bearing_od` / `bearing_id` | 90 / 60 mm | turntable bearing |
| `ring_gear_teeth` : `motor_gear_teeth` | 200 : 20 | rotation reduction (10:1) |
| `sheet_thk` | 0.8 mm | steel playing sheet glued to the panel front |
| `sheet_hole` | 8 mm | per-square laser-cut sensing hole in the sheet |
| `front_wall` | 2.5 mm | printed wall behind the sheet (sensor bore runs through it) |

**Piece size is deliberately *not* in this table.** How tall each piece is — and
whether the artwork carries a scale factor at all — belongs to the style file:
`monolith` is drawn nominal and scaled by `MONO_SCALE` = 1.222, `familiar` is
drawn at final size and has no scale factor. The mechanism only ever asks a
style for a piece's height and gets real printed millimetres back, so no board
dimension depends on one style's drawing grid.

A full 8×8 at `square_size = 55` gives a **440 mm** playing area and a
**490 mm** panel (~514 mm over the frame) — a genuine statement wall piece.

`square_size` is no longer a free knob. It was resolved to 55 mm on physical
grounds (§3.3): it is the smallest square whose piece artwork hides the hub
puck. **Changing it means re-checking two things** — that the narrowest waist
still covers Ø11.5, and that `pivot_frac × king_height` still fits inside
`square_size / 2` for **every** style (at present: monolith 25.66 mm and
familiar 26.00 mm into a 27.5 mm half-square, so 1.84 and 1.50 mm of headroom).
Going larger also means re-checking magnet hold, since the pieces get heavier
while the magnet does not.

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
- **Which variant is the build target** — the open half of **D12**. *That the
  design is carried as selectable variants at all is now locked* (D12 in
  [`GOALS.md`](GOALS.md)); what is still open is which combination gets printed
  32 times. Both axes in §3 stay selectable so approaches can be compared and
  more can be added. `familiar` + `pin` is what the files default to;
  `monolith` + `magnet` is the one combination the modelling rules out (§3.6).
  The blocking input is the same one everything else waits on: **print the
  Phase-0 pieces and measure μ.** The options are set out for comparison in
  [`PIECE_DESIGNS.md`](PIECE_DESIGNS.md).
- **Weight budget** — how heavy before the turntable and stepper need upsizing?
  Now bounded rather than open: the panel is fixed at 490 mm square by D1, so
  this is a check to run at Phase 2, not a shape decision. Note that a familiar
  set masses roughly **1.6×** a monolith one (81 g vs 50 g per side, as
  modelled), so the answer depends on the open question above.

**Recently closed** (do not re-open casually — each was settled on physical
grounds, not taste):

| | Decision | Outcome |
|---|----------|---------|
| **D1** | Board size | **55 mm squares** — the smallest square whose artwork hides the hub puck (§3.3) |
| **D8** | Pivot placement | **the silhouette's centre**, so settling rotates the piece in place (§3.3) |
| **D9** | Pivot hardware | **a bought Ø3 × 16 mm steel dowel** + silicone damping grease (§3.1) — this decides the hardware *inside* the `"pin"` architecture; `"magnet"` (§3.2) is an alternative kept alongside it under **D12**, not a replacement for it |
| **D10** | Bottom-heaviness | **shaped into the body**; no ballast anywhere in either set (§3.4) |
| **D11** | Piece design language, `"monolith"` | **one shared rule set**, "Tapered Monolith" (§3.5) — scoped to that one style, not a repo-wide rule |
| **D12** | How competing approaches are carried | **kept side by side as selectable variants** on two independent axes — `piece_style` and `pivot_type` (§3) — rather than narrowed to one answer. *Which* combination is the build target is the open question above. |

**Not a decision — an unmeasured input.** The friction coefficient μ is
*assumed*, and every lean figure in this document depends on it linearly.
Nothing has been printed. This is settled by a test, not by a discussion: print
one pawn and one hub (Phase 0 in [`BUILD_GUIDE.md`](BUILD_GUIDE.md)).
