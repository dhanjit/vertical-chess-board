# Start Here — zero experience needed

**You don't need to own a 3D printer or know electronics or coding.** For the
first version — a real chess board you hang on the wall and play by hand — your
whole job is:

1. **Get the plastic parts printed** — on your own printer if you have one, or
   a local print service / makerspace (this repo has everything they need).
2. **Buy a short list of small parts** (magnets, washers, a spinning bracket).
3. **Glue a few things together and hang it.**

That's it. The fancy stuff — a motor that spins the board, sensors, a board
that plays against you, a phone app — is **optional and comes much later**.
Ignore all of it for now.

---

## The 30-second version of how this works

- A 3D printer builds objects out of plastic by reading a file called an
  **STL**. Think of an STL as a "shape file."
- This project describes each part in a design format (`.scad`) that turns
  into STLs — one command (or a few clicks) in a free program called OpenSCAD.
  Whoever runs the printer does this;
  [`../hardware/README.md`](../hardware/README.md) tells them exactly how.
- If a print service or makerspace is making the parts, you don't need
  OpenSCAD or a printer yourself — just send them the STLs.

---

## Do this first: a cheap 1-evening test (don't build everything yet!)

Before printing a whole chess set, prove the two "magic" tricks work:
**a piece sticks to the wall board, and it stays right-side-up when you spin
the board.** This is **Phase 0** and it costs almost nothing.

**Print just these test parts first (or have them printed):**
- 1 × "gravity gimbal" pair (the little pivot + cap)
- 1 × king piece
- 1 × small board test section (optional but nice)

**You buy:** a couple of the small magnets, one steel washer, two tiny M3
nuts, and super glue (see the list below — you only need a few for the test).

**Then:** press a magnet into the pivot, glue the two small steel nuts
(stacked) into the pocket at the piece's base, click the piece onto the pivot,
and stick it to a steel surface held sideways (a fridge side, a steel washer
taped to cardboard, anything steel). It should **hold on** and **stay upright
when you rotate it**.

If that works and feels good → print the rest. If it needs tuning (spins too
freely, or won't hold), the fix is usually one number in
`hardware/common.scad` — the tuning table in [`BUILD_GUIDE.md`](BUILD_GUIDE.md)
("Phase 0") says which one for each symptom. **This is the whole reason we
test first — it's much cheaper to tweak one piece than 32.**

Full step-by-step is in [`BUILD_GUIDE.md`](BUILD_GUIDE.md) ("Phase 0").

---

## Print spec — for whoever runs the printer

If someone else is printing (a print service, makerspace, or anyone with a
printer), this is everything they need. Print a **test batch first**, before
the whole set:

- **Source:** the 3D-printable parts live in this repo. Full render + print
  instructions are in [`../hardware/README.md`](../hardware/README.md).
- **Render:** install **OpenSCAD** (free), then from the `hardware/` folder run
  `make` to generate all the STLs — or render just the ones listed below.
- **Test batch:** one `gimbal_testpair`, one `piece_king`, (optional) one
  `board_test` tile (`make gimbal board_test` + the king render).
- **Material:** PLA is fine. ~15–20% infill, 0.2 mm layers, **no supports
  needed** (parts are designed to print flat).
- **Colors:** the pieces print in **two colors** (one for White, one for
  Black) — for the test, any color is fine.
- **Full set (after the test passes):** 32 pieces + the board panel + frame —
  see [`BOM.md`](BOM.md) and [`BUILD_GUIDE.md`](BUILD_GUIDE.md).

---

## Your shopping list (the non-printed bits)

For the **test**, you only need a few of the first two items. For the **full
manual board**, get the quantities in [`BOM.md`](BOM.md). In plain terms:

| What | Why | Where |
|------|-----|-------|
| Small **neodymium disc magnets** (8 mm × 3 mm) | go inside each piece so it sticks to the board | Amazon / hobby store |
| **Steel washers** (~16 mm, with a hole — ask for "M8 plain/flat washers") | one behind each square; the magnet grabs these | hardware store (get plain **steel**, not stainless) |
| Small **steel nuts** (**M3** — two per piece, glued) | tiny weights that keep pieces upright (M6 nuts are too big for the pocket) | hardware store |
| A **lazy-susan / turntable bearing** (~90 mm) | lets the board spin on the wall | Amazon / hardware store |
| A **French cleat** (a slanted hanging bracket) | how it hangs on the wall | hardware store |
| Super glue / epoxy | assembly | anywhere |

> **One tip that saves headaches:** magnets and washers come in slightly
> different sizes. Buy the sizes above, and during the Phase 0 test we confirm
> they fit. If they don't, one number changes in the design
> (`hardware/common.scad`) and the part gets re-printed — no problem.
>
> This table covers the hand-played board's main parts; the frame assembly
> also needs **M3 bolts + heat-set inserts** and **PTFE lube** — the complete
> per-phase list is [`BOM.md`](BOM.md).

---

## What to completely ignore for now

These are **later, optional, and advanced**. You never have to touch them to
have a working, beautiful board you play by hand:

- The motor that spins the board automatically (`ELECTRONICS.md`, the
  `rotation_hub` motor parts).
- The sensors that let the board "see" the pieces.
- The board playing against you (`software/engine/ai.js`).
- The phone app (`app/`).

When (if!) you ever want those, they're all planned out in
[`GOALS.md`](GOALS.md) — but there's zero pressure. Many people would stop at
the hand-played wall board, and it's great on its own.

---

## Want the bigger picture?

- [`PROJECT_REVIEW.md`](PROJECT_REVIEW.md) — an honest review of the whole idea,
  how hard each part is, and a **staged plan (A–E)** so you always know the next
  small step and where you can happily stop.
- [`SOURCING_BANGALORE.md`](SOURCING_BANGALORE.md) — where to print and buy
  everything in Bengaluru, with rough ₹ costs.

## If you get stuck

Note exactly what happened ("the piece won't stay upright," "the magnet is
too weak," "the printer bed is small"). Nearly every symptom maps to one
number in `hardware/common.scad` — the troubleshooting table in
[`BUILD_GUIDE.md`](BUILD_GUIDE.md) and the "ways to make it easier" list in
[`PROJECT_REVIEW.md`](PROJECT_REVIEW.md) §5 cover the common ones. The design
is parametric on purpose: tune the number, re-print the one part.
