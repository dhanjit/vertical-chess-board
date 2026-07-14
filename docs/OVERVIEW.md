# Project Overview — Vertical Wall Chess Board

**One page: what this is, why we're building it, how it works, and the plan to
get there.** If you're new to the project — or about to print the parts — read
this first. Everything else in the repo is detail that hangs off this page.

---

## What it is

A real chess board that **hangs on the living-room wall like a piece of art**
and plays vertically. Three things make it special:

- 🔄 **It rotates 180° to face whoever's turn it is** — the player to move
  always sees the board from their own side.
- 🌍 **Pieces stay upright by gravity** — each piece hangs on a pivot and is
  bottom-weighted, so as the board turns, every piece self-levels like a
  pendulum and is never upside-down.
- 🧲 **Pieces are magnetic** — they grip a steel-backed vertical surface, so
  they hold on and slide square to square.

It's **3-D printed** from parametric models (a few numbers resize the whole
board) plus a short list of off-the-shelf parts — magnets, steel washers, a
turntable bearing, a wall cleat.

## Why we're building it

- A chess board that's also **wall art** — quietly beautiful when idle,
  a little bit magical in play.
- The combination — **face-the-player rotation** *and* **gravity-upright
  pieces** on a **vertical** board — is genuinely new. Smart/auto boards on the
  market lie flat; none do the self-righting wall trick.
- It's an achievable, satisfying **making project**. The first version needs
  **no electronics and no coding** — just printed parts, magnets, and glue —
  so it's a real object on the wall long before any of the fancy stuff.

## How it works (30 seconds)

- The board is a **vertical plane on a central turntable**. Behind every square
  is a **steel washer**; every piece carries a **magnet**, so pieces grip the
  surface through a thin front wall and even **self-center** on their square.
- Each piece body hangs on a **low-friction pivot** with a **weight in its
  base** — a pendulum that always points up, no matter how the board is turned.
- *(Later, optionally)* a motor spins the board, hall sensors behind each
  square read the position, and the built-in chess engine follows and
  validates the game.

Full engineering detail: [`DESIGN.md`](DESIGN.md).

---

## The plan — how we get there

Build in **phases**, and **each phase is a complete, usable thing on its own**.
You can stop after any of them and have something real.

| Phase | What you get | Where it sits |
|---|---|---|
| **Phase 0 — Prove the magic** | Print *one* pivot + *one* piece; confirm a piece **sticks** to a vertical steel surface and **stays upright** when you spin it. ~1 evening, ~₹500. | ✅ **do this first** — a GO/NO-GO gate before printing a whole set |
| **Phase 1 — Manual wall board** ⭐ | The full 32-piece set + board panel + frame + turntable, hung on the wall and **spun by hand** each turn. No electronics, no code. | 🎯 **this is the goal we're focused on** — and, for most people, the finished project |
| **Phase 2 — Powered + sensing** | A motor rotates the board on a button press; hall sensors read the pieces so the board follows the game and flags illegal moves. Your first electronics. | 🟡 optional, later |
| **Phase 3 — The board plays you** | An auto-mover physically moves its own pieces and plays you (via Stockfish). | 🌠 **aspirational — not a current focus** (see below) |
| **Phase 4 — App & polish** | Phone app: difficulty, hints, clocks, online play, sound/LED. | 🌠 aspirational — later |

> Two docs expand this same path: [`PROJECT_REVIEW.md`](PROJECT_REVIEW.md)
> breaks it into finer beginner **stages A–E** with an honest difficulty/risk
> read, and [`GOALS.md`](GOALS.md) is the full technical roadmap with the open
> design decisions. This table is the summary they both detail.

---

## What we're focused on right now

**Focus: get to a hung, hand-played manual board (Phase 0 → Phase 1).** That is
a complete, beautiful object and, for most builders, the whole project. The
near-term repo work — printable parts, BOM, build steps — all serves this.

**Aspirational — deliberately *not* the current focus:**

- **The auto-mover** (Phase 3 — a board that moves its own pieces and plays
  you). On a *vertical* board this is genuinely hard: the steel backing that
  **holds** pieces up also **shields** the magnet that would **move** them, so
  it's a **different machine**, not a bolt-on. We've researched *how* it could
  work and *why* it's hard — [`AUTO_MOVER_ANALYSIS.md`](AUTO_MOVER_ANALYSIS.md)
  (the why) and [`AUTO_MOVER_DESIGN.md`](AUTO_MOVER_DESIGN.md) (the how) — and
  we're parking it as a **someday** goal.
- **The phone app** (Phase 4) is a similarly later, aspirational add.

**Good news:** nothing built for Phase 1 is wasted if auto-play is ever
pursued — the pieces, the chess brain, and most of the frame carry straight
over. So there's no penalty for building the manual board first and deciding on
the rest later.

---

## If you're the one printing the parts

You don't need to understand the whole project to print — but if you want the
context (what this is, why, what you're printing toward), it's right here:

1. **This page** — what it is, why we're building it, and the plan *(the what &
   why)*.
2. [`../hardware/README.md`](../hardware/README.md) — how to turn the `.scad`
   models into STLs, and the print settings *(the how)*.
3. [`START_HERE.md`](START_HERE.md) — a plain-language, **no-experience-needed**
   walk-through, including a **print spec** (what to render first) and the
   small shopping list.

**Short version:** render a **test batch first** — one gravity gimbal + one
king — prove the piece sticks and self-rights, *then* print the full set.

---

## The rest of the repo, at a glance

| Doc | What's in it |
|---|---|
| [`START_HERE.md`](START_HERE.md) | Plain-language first steps + print spec (start here if you're new to printing) |
| [`DESIGN.md`](DESIGN.md) | How the two mechanics, magnets, and sensing actually work |
| [`GOALS.md`](GOALS.md) | Full technical roadmap (Phases 0–4) + open decisions to lock |
| [`PROJECT_REVIEW.md`](PROJECT_REVIEW.md) | Honest difficulty/risk read + beginner staged plan (A–E) |
| [`BOM.md`](BOM.md) | Shopping list per phase |
| [`BUILD_GUIDE.md`](BUILD_GUIDE.md) | Step-by-step assembly (start at Phase 0) |
| [`SOURCING_BANGALORE.md`](SOURCING_BANGALORE.md) | Where to print + buy parts locally (₹) |
| [`OPEN_SOURCE.md`](OPEN_SOURCE.md) | Existing projects to reuse instead of reinventing |
| [`ELECTRONICS.md`](ELECTRONICS.md) | Powered rotation + sensing plan (Phase 2) |
| `AUTO_MOVER_*.md` | 🌠 Aspirational auto-play research (Phase 3) |
| [`../hardware/README.md`](../hardware/README.md) | The OpenSCAD models + how to render STLs |
| [`../software/engine/README.md`](../software/engine/README.md) | The chess brain (rules engine + AI) |

## Status

| Area | State |
|---|---|
| Rules engine + AI | ✅ implemented, perft-verified |
| Parametric models (pieces, gimbal, panel, frame, hub) | ✅ drafted, ready to render/tune |
| Docs (design, goals, BOM, build, electronics) | ✅ drafted |
| Anything physically built | ⬜ next step is **Phase 0** |

**Next real-world step:** Phase 0 in [`BUILD_GUIDE.md`](BUILD_GUIDE.md) — prove
the gravity-magnet piece before printing a full set.
