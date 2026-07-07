# Project Review & Realistic Plan (for a first-time builder)

You've never done 3D printing, electronics, or a build like this — and you have
a friend with a printer. This document is an **honest review of the idea**, a
**feature-by-feature risk read**, and a **re-scoped plan** that fits a
first-timer. Bengaluru-specific sourcing is in
[`SOURCING_BANGALORE.md`](SOURCING_BANGALORE.md).

**Bottom line up front:** the idea is genuinely good and the *manual* board is
very achievable for a beginner (a weekend of proving it out, then a couple of
weekends to build). The *electronic* features (motorized spin, sensing,
auto-play, app) are each a real step up in difficulty — treat them as separate
future projects, not part of "version 1."

---

## 1. Is the idea sound?

Yes. Three things make it special, and all three are physically real:

- **Hangs on the wall** — a chess board as living-room art. ✔ straightforward.
- **Rotates to face whoever's turn it is** — nice touch. ✔ (by hand it's free;
  by motor it's an electronics project).
- **Pieces stay upright by gravity** — the "wow." ✔ works via a simple
  pendulum, *but it's the one mechanical unknown that must be prototyped first.*

Plus **magnetic hold** so pieces stick to a vertical surface — well-understood,
low risk.

Nothing here defies physics. The risk isn't "will it work at all," it's "how
much fiddly tuning and how much electronics do you want to take on."

---

## 2. Feature-by-feature risk read

| Feature | Difficulty for a beginner | Risk | Notes |
|---|---|---|---|
| Magnetic pieces holding on a steel-washer board | 🟢 Easy | Low | Proven idea; just pick magnet strength. |
| **Gravity self-righting** pieces (the pendulum) | 🟡 Medium | **Medium** | The one thing to prototype first. Tuning = friction + base weight. |
| Hanging on the wall (French cleat) | 🟢 Easy | Low | Standard picture-hanging method. |
| Manual 180° rotation on a bearing | 🟡 Medium | Low–Med | Mostly about balancing the board on its axis. |
| **Motorized** rotation (Phase 2) | 🟠 Hard | Med | First real electronics: motor + driver + homing sensor + code. |
| **Sensing** which piece is where (Phase 2) | 🔴 Harder | Med–High | 64 sensors, wiring, firmware. A project by itself. |
| **Auto-mover** — board plays you (Phase 3) | 🔴 Very hard | High | Robotics + a design conflict on a vertical board (see below). |
| Phone **app** (Phase 4) | 🟠 Hard | Med | A software project of its own. |

**Reading this table:** everything 🟢/🟡 is the achievable, satisfying first
board. Everything 🟠/🔴 is optional and best done *after* you've built the
manual board and picked up basic skills.

---

## 3. The one honest snag to know about up front

The **auto-mover** (pieces moving themselves) is the hardest part **and** it
fights our own design, because our board is **vertical**:

- Pieces need constant magnetic hold to the board (steel washers).
- But a moving electromagnet behind the board can't reach the pieces *through*
  a steel backing — steel shields magnets.

So the "board plays you" version is a **different machine** (likely a slightly
reclined, steel-free variant — "Path B" in [`DESIGN.md` §6](DESIGN.md#6-phase-3--the-board-plays-you-auto-mover-future-scope)).
This is captured so nobody discovers it the hard way later. **It does not
affect the manual board at all** — pieces, brain, and most of the frame carry
over if you ever pursue auto-play.

---

## 4. Re-scoped plan (what I actually recommend you do)

Five stages, each a clean stopping point. **Most first-timers should aim for
Stage B and be delighted.**

### Stage A — Prove the magic (1 weekend, ~₹500)
Print **one** pendulum pivot + **one** piece; buy a few magnets + a washer +
a nut. Confirm: piece **sticks** to a vertical steel surface and **stays
upright** when you spin it.
→ **GO/NO-GO gate.** If it needs tuning, tell me what happened and I'll adjust
the numbers before you print a whole set. *(This is exactly why we test one
piece before printing 32.)*

### Stage B — The manual wall board (1–2 weekends, ~₹3–4.5k) ⭐ the real goal
Print the full set + board panel (in quarters) + frame; add the lazy-susan
bearing and a French cleat; assemble, balance, hang. **You now have a real,
beautiful board you play by hand and spin at each turn.** For most people,
*this is the finished project.*

### Stage C — Motorize the spin (optional, a few weekends)
Your first electronics. **Learn on a breadboard first** (blink an LED, spin one
motor, read one sensor) before touching the board. Then add the stepper +
driver + home sensor so it rotates itself on a button press.

### Stage D — Make it sense the game (optional, bigger)
Add the 64-sensor grid + a small controller running the chess brain, so the
board follows the game and flags illegal moves. A substantial standalone
project.

### Stage E — Auto-play + app (optional, biggest)
The reclined "Path B" auto-mover and a phone app. Real robotics + software.
Only if you've caught the bug and want a long project.

> **You can stop after any stage** and have a complete, working thing. The
> repo is built so later stages don't require redoing earlier ones.

---

## 5. Ways to make it *easier* (if Stage A is fiddly or you want simpler)

- **Skip motorized rotation forever** — spinning by hand is genuinely fine and
  removes all the Stage-C electronics.
- **Bigger squares, bigger magnets** — a 55–60 mm board is easier to assemble
  and holds pieces more confidently than tiny parts. (One number in
  `common.scad`; I'll change it.)
- **Tune, don't redesign** — if pieces don't self-right cleanly, the fix is
  usually more base weight or less pivot friction, not a new design.
- **Fallback if the pendulum frustrates you:** pieces whose shape reads the
  same either way up (letters, or symmetric silhouettes) need *no* pivot and
  *no* rotation — you lose the "wow," but it's a guaranteed-simple board. I'd
  only suggest this if Stage A really fights you.

---

## 6. Cost at a glance (Bengaluru, ₹)

Detail and shops in [`SOURCING_BANGALORE.md`](SOURCING_BANGALORE.md).

| Path | Rough cost | Notes |
|---|---|---|
| Stage A test | ~₹300–600 | a few magnets, a washer, one nut; prints are grams of filament |
| **Stage B manual board — friend prints** | **~₹2,500–4,500** | filament + magnets + washers + bearing + cleat + glue |
| Stage B manual board — *paid* print service | +₹8,000–15,000 | large board = lots of plastic; **friend's printer is far cheaper** |
| Stage C motorize | +₹1,500–3,000 | stepper, driver, controller, PSU |
| Stage D sensing | +₹2,500–4,000 | 64 hall sensors, muxes, wiring |

**Takeaway:** using your friend's printer keeps the whole manual board in the
**low thousands of rupees**. Paying a service to print it is the single most
expensive way to do it — avoid unless you have no printer access.

---

## 7. Skills you'll pick up (and where to get help locally)

- **Stage B** teaches basic assembly, gluing, magnets, balancing, wall-mounting.
  No coding or electronics.
- **Stages C–E** teach microcontrollers (ESP32/Arduino), stepper motors, sensors,
  and a bit of code — learnable, but new territory.
- **Local help:** Bengaluru makerspaces (Workbench Projects, IKP EDEN) run
  beginner sessions and have people who do exactly this; great for the
  electronics stages. See [`SOURCING_BANGALORE.md`](SOURCING_BANGALORE.md).

---

## 7.5. Don't build the electronics from scratch — reuse

The electronic phases (C–E) look scary, but **you mostly won't be inventing
anything** — the sensing, the computer opponent, the self-moving gantry, and
online play are all **solved open-source projects** you fork and adapt. Only
our *mechanical* idea (vertical, rotating, gravity-upright pieces) is new. See
[`OPEN_SOURCE.md`](OPEN_SOURCE.md) for the full map; the short version:

- **Opponent:** run **Stockfish** (world's best, free), not hand-written AI.
- **Phase D sensing:** fork **Open-Chess** (MIT, well-documented, same hall-sensor idea).
- **Phase E auto-mover:** start from **Imperium** + **FluidNC** motion firmware.
- **App/online:** **lichess API** + a ready-made board UI.

This is why the electronics stages are more approachable than they look — the
community has done the heavy lifting, and nearly every project just runs
Stockfish.

## 8. My recommendation in one line

**Do Stage A this month. If it delights you, do Stage B and hang a board you
built. Decide on electronics only after that — with a finished board already on
your wall.**
