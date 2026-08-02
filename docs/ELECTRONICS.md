# Electronics (Phase 2+)

The manual board (Phase 1) has **no electronics**. This plan covers the
powered board: rotate on turn, sense the pieces, run the rules engine, and
(Phase 3) drive the auto-mover.

## Block diagram

```
                    ┌──────────────────────────────────────┐
                    │              ESP32 (brain)             │
                    │  chess.js state · ai.js · BLE/Wi-Fi    │
                    └───┬───────────┬───────────┬────────────┘
       occupancy grid   │           │           │   move to make
     ┌──────────────────┘           │           └───────────────────┐
     │                              │                                │
┌────┴─────┐   4–8×          ┌──────┴──────┐                  ┌──────┴──────┐
│ 64 hall  ├──CD74HC4067────►│ stepper drv │──► NEMA-17 ──►   │  gantry +   │
│ sensors  │   muxes         │ (TMC2209)   │    rotate 180°   │ electromagnet│ (Ph.3)
└──────────┘                 └─────────────┘                  └─────────────┘
     ▲                              ▲                                ▲
  2 home-index hall            12 V rail                        MOSFET driver
```

## Rotation drive (Phase 2)

- **Motor:** NEMA-17, microstepped (TMC2209 for silence).
- **Ratio:** `motor_gear_teeth:ring_gear_teeth` = 20:200 = **10:1** via GT2 belt.
- **Homing:** two magnets 180° apart on the turntable + one hall sensor on the
  wall plate define the two stops. On boot, rotate until the index trips.
- **Move sequence per turn:** detect legal move complete → step 180° →
  confirm index → hand control to the player now on move.
- **Anti-wind-up:** alternate rotation direction each turn (CW, CCW, …). Keep
  logic/power on the **fixed** side and cross the joint with as few wires as
  possible; use a **slip ring** only if the rotating side is powered.

## Piece sensing (Phase 2)

- One **hall sensor per square** (64). Each sensor slides into a through-bore
  in `board_panel.scad` from the panel's open back until its tip sits **flush
  at the front face**, directly under that square's laser-cut hole in the
  steel sheet (`sheet_hole`) — it reads the piece magnet through **air**, so
  the sheet doesn't shield it. A piece on the square trips its sensor.
- Scan via **CD74HC4067 multiplexers** (4 muxes × 16, or 8 × 8) into a few
  ESP32 GPIO/ADC pins. Debounce in firmware.
- The firmware holds the true game state (from `chess.js`); it only needs
  **occupancy *changes*** to follow along:
  1. piece **lifted** (square goes empty) → remember origin,
  2. piece **placed** (square goes full) → candidate destination,
  3. ask `chess.js` for legal moves from origin → if dest is legal, commit;
     else flag illegal (LED red / buzzer / app toast) and wait for correction.
- Castling/en passant produce a known multi-square signature; the engine knows
  the pattern, so match it.

## Optional per-square LEDs

WS2812 under each square (behind a diffusing front) to highlight legal moves,
last move, check, or the square the auto-mover is about to use.

## Auto-mover (Phase 3)

> **Architecture per decision D6 in [`GOALS.md`](GOALS.md):** the default
> route is the **EPM matrix** (switchable magnets that hold *and* move — see
> [`AUTO_MOVER_DESIGN.md`](AUTO_MOVER_DESIGN.md)); the gantry described below
> is the **reclined-gantry fallback**.

- **Core-XY gantry** behind the panel; one **electromagnet** on the carriage.
- Energize the magnet, drive to the origin square, drag along the **grid gaps**
  to the destination, release. Knights and blocked paths route along edges.
- Captures: pull the captured piece to a **graveyard lane** first, then move
  the capturing piece.
- Driven by two more stepper drivers off the same ESP32 (or a dedicated
  motion MCU taking G-code-like commands).

## Firmware layout (suggested)

```
firmware/                 (to be written in Phase 2)
  main/                   ESP32 app
    game.*                wraps software/engine/chess.js logic
    sensors.*             mux scan + debounce -> occupancy
    rotation.*            homing + 180° moves
    mover.*               (Phase 3) gantry + electromagnet
    comms.*               BLE/Wi-Fi to the app
```

The rules/AI are already implemented in
[`../software/engine`](../software/engine); port or run them directly
(ESP32 can run JS via a small interpreter, or transpile the logic to C++ —
the algorithms in `chess.js`/`ai.js` are the reference).

> **Reuse, don't reinvent:** most of this firmware already exists as
> open-source. For sensing, fork **Open-Chess** (MIT); for the auto-mover,
> start from **Imperium** + **FluidNC**; for a strong opponent, run
> **Stockfish**. See [`OPEN_SOURCE.md`](OPEN_SOURCE.md) for the full reuse map
> — it turns these phases from "write firmware" into "port firmware."

## Safety

- Fuse the 12 V rail; strain-relieve everything on the rotating side.
- Give the rotation a **torque limit / current limit** so a hand or cat in the
  way stalls the motor instead of forcing it.
- Mount to a **stud or proper anchors** — a ~410 mm board faced with a steel
  sheet, plus frame and turntable, is not light.
