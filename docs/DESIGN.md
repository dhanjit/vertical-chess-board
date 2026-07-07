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
        │  │      BOARD PANEL         │  │  ← 8×8 grid, steel washer per square
        │  │   ▟ ▙ ▟ ▙ ▟ ▙ ▟ ▙       │  │  ← hall sensor behind each washer
        │  │   pieces stick + swivel  │  │
        │  └─────────────────────────┘  │
        └───────────────────────────────┘
```

The board is a **vertical plane** on a **central turntable**. The playing
surface has a thin **steel sheet** behind it; every piece has a **magnet**
in its hub, so pieces grip the vertical surface and can slide square to
square. Each piece body hangs on a **low-friction pivot** and is
**bottom-weighted**, making it a pendulum that always points up.

---

## 2. Mechanic 1 — rotate by turn

When a player finishes their move, the board rotates **180°** so the other
player now looks at the board "the right way up" from their side.

- **Bearing:** an off-the-shelf **lazy-susan / turntable bearing**
  (`bearing_od`/`bearing_id` in `common.scad`) carries the ~2–3 kg board and
  keeps it flat against the wall.
- **Drive:** a **NEMA-17 stepper** turns a **GT2 timing belt** around a
  toothed rim on the turntable. Ratio is `motor_gear_teeth : ring_gear_teeth`
  (default 20:120 = **6:1**) — plenty of torque, and the board holds still
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
out of the wall** (normal to the board). A body that spins on that axis and
carries its mass **below** the axis behaves exactly like a **pendulum**: it
always swings so its heavy end is down, i.e. it stays upright — regardless of
how the board around it is rotated.

```
   axle (⊙, pointing out of wall)
        │
        ●  ← pivot at square center (rides on the hub's axle post)
       ╱ ╲
      │ K │   ← flat silhouette body
       ╲ ╱
      [ ▪ ]  ← steel weight in base pocket  →  center of mass BELOW pivot
```

Each piece is **two printed parts** (see
[`gravity_gimbal.scad`](../hardware/gravity_gimbal.scad) and
[`pieces.scad`](../hardware/pieces.scad)):

| Part | Role |
|------|------|
| **Hub puck** | Neodymium magnet press-fit in the back grips the steel board. An **axle post** projects toward the room. The puck rotates *with* the board. |
| **Body** | A flat **silhouette** (reads across the room, prints flat, no supports) with a **pivot bore** that drops onto the post, and a **base pocket** for a steel weight. The body spins freely and self-levels. |
| **Snap cap** | Clips into the axle groove so the body can't fall off but still spins. |

Design notes:
- **Pivot above middle, weight at the base** → a strong, unambiguous "down,"
  so the piece settles quickly and doesn't spin freely.
- **Low friction matters.** Tune `axle_fit` in `common.scad`; a touch of dry
  PTFE lube on the post makes the pendulum crisp.
- **Flat silhouettes** are deliberate: they're readable at living-room
  distance, cheap to print, and light (less pendulum inertia). Two finishes
  (or two filament colors) distinguish White vs. Black.

> **Do we need both mechanics?** Yes, and they complement each other. The
> *rotation* flips the board coordinates so the mover sees their own back
> rank at the bottom; the *gravity pivot* guarantees the piece art is upright
> throughout and after that flip. Together the board always looks "normal" to
> whoever is on move.

---

## 4. Holding pieces on a vertical board (magnets + washers)

- Pieces carry an **8 mm × 3 mm N52 neodymium disc** (`magnet_dia`/`magnet_thk`).
- Behind **each square** sits a **steel washer** (`washer_od`/`washer_id`),
  pressed against the back of a thin **front wall** (`front_wall` ≈ 2.5 mm).
  The piece magnet grips the washer *through* the front wall.
- Because the magnet is strongest on-axis, it also **snaps to the washer's
  center**, so **pieces self-center on their square** — a nice side effect that
  also helps the future auto-mover.
- Hold force with an 8×3 N52 disc through a 2.5 mm wall to a steel washer is
  comfortably more than a light silhouette's weight, with margin for the
  pendulum swing. If you scale pieces up, bump `magnet_dia` and re-check.

**Why per-square washers, not one big steel sheet?** A solid steel sheet
behind the whole board would **magnetically shield the hall sensors** (§5) so
they couldn't read the pieces, and it forces a thicker front wall. Per-square
washers with an open center hole solve both: the sensor reads through the hole
(see §5), and the piece still gets a firm, self-centering hold. (A steel sheet
*with a clearance hole per square* is an equivalent alternative if you prefer
sheet stock — same geometry, more cutting.)

---

## 5. Sensing the board (for validation + auto-play)

Behind each square, a **hall-effect sensor** sits in a blind pocket *behind
the washer* (`sensor_dia`/`sensor_h` in
[`board_panel.scad`](../hardware/board_panel.scad)). It reads the piece magnet
through the **washer's center hole** (mostly air — so it is **not**
magnetically shielded) plus the thin front wall. Each piece magnet trips the
sensor on its square, so the electronics read an **8×8 occupancy grid**.
Combined with the rules engine
([`software/engine/chess.js`](../software/engine/chess.js)) the board can:

- detect when a piece is lifted and where it lands,
- validate the move is legal (reject illegal ones with an LED/app nudge),
- keep the game state, clocks, and move history,
- (Phase 3) compute and physically play the opponent's reply.

64 sensors are read through **two 8-channel multiplexers** (or a matrix) into
one microcontroller — see [`ELECTRONICS.md`](ELECTRONICS.md).

> Occupancy alone tells you *which* squares are full, not *which piece* is
> where. That's fine: the firmware knows the full game state, so it only needs
> occupancy changes to follow along. (Piece identity is only ambiguous if you
> set up an arbitrary position — handle that with an app "set position" flow.)

---

## 6. Phase 3 — the board plays you (future scope)

The "board moves its own pieces" trick is the same one used by commercial
auto-chess boards: an **electromagnet on an XY gantry behind the board**
grabs a piece's magnet and drags it along the gaps between squares.

- **Gantry:** a Core-XY or H-bot behind the panel, one electromagnet on the
  carriage. Because pieces slide on the steel sheet, the magnet can pull any
  piece; knights route along square edges.
- **Brain:** [`software/engine/ai.js`](../software/engine/ai.js) (negamax +
  alpha-beta) chooses the move; the gantry executes it; the board rotates;
  your turn.
- **Control app:** phone app over BLE/Wi-Fi picks difficulty, shows the game,
  offers takebacks/hints. See [`app/README.md`](../app/README.md).

This is intentionally **later** — Phases 1–2 give you a beautiful, fully
working wall board first. See [`GOALS.md`](GOALS.md) for the roadmap.

---

## 7. Key parameters (edit in `common.scad`)

| Parameter | Default | Meaning |
|-----------|---------|---------|
| `square_size` | 45 mm | one playing square |
| `piece_scale` | 1.0 | scales every piece |
| `magnet_dia` × `magnet_thk` | 8 × 3 mm | piece magnets |
| `hub_dia` / `axle_dia` | 22 / 4 mm | gravity pivot |
| `axle_fit` | 0.35 mm | swivel clearance (lower = tighter) |
| `bearing_od` / `bearing_id` | 90 / 60 mm | turntable bearing |
| `ring_gear_teeth` : `motor_gear_teeth` | 120 : 20 | rotation reduction |
| `front_wall` | 2.5 mm | wall between piece magnet and washer/sensor |
| `washer_od` / `washer_id` | 16 / 8.4 mm | per-square steel washer (hold + sense) |

A full 8×8 at `square_size = 45` gives a **~410 mm** playing area and a
**~460 mm** panel — a substantial, readable wall piece. Bump `square_size`
to 55–60 mm for a real statement board (re-check magnet hold).

---

## 8. Open design questions

Tracked so we decide deliberately (see `GOALS.md` for status):

- **Board size / weight budget** — how big before the turntable/motor needs
  upsizing? (drives `square_size`, bearing, stepper choice)
- **Piece style** — flat silhouettes (current) vs. shallow 3-D relief.
- **Finish** — printed two-tone vs. painted vs. veneer/laminate front.
- **Rotate every move vs. on-demand** — always flip, or a button, or only in
  two-player mode? (UX + belt/slip-ring implications)
- **Where the brain lives** — phone app, a Pi/ESP32 on the wall, or both.
