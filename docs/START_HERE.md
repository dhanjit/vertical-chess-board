# Start Here — zero experience needed

**You do not need to know 3D printing, electronics, or coding.** For the first
version — a real chess board you hang on the wall and play by hand — your whole
job is:

1. **Send your friend some files** (their printer makes the plastic parts).
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
  into STLs. **Your friend handles that part** — it's one command (or a few
  clicks in a free program called OpenSCAD). Point them at
  [`../hardware/README.md`](../hardware/README.md); it tells them exactly how.
- You don't need OpenSCAD or a printer yourself.

---

## Do this first: a cheap 1-evening test (don't build everything yet!)

Before printing a whole chess set, prove the two "magic" tricks work:
**a piece sticks to the wall board, and it stays right-side-up when you spin
the board.** This is **Phase 0** and it costs almost nothing.

**Ask your friend to print just these test parts:**
- 1 × "gravity gimbal" pair (the little pivot + cap)
- 1 × king piece
- 1 × small board test section (optional but nice)

**You buy:** a couple of the small magnets and one steel washer (see the list
below — you only need a few for the test).

**Then:** press a magnet into the pivot, drop a small steel weight (a nut) into
the piece's base, click the piece onto the pivot, and stick it to a steel
surface held sideways (a fridge side, a steel washer taped to cardboard,
anything steel). It should **hold on** and **stay upright when you rotate it**.

If that works and feels good → print the rest. If it needs tuning (spins too
freely, or won't hold), tell me what happened and I'll adjust the design
numbers for you. **This is the whole reason we test first — it's much cheaper
to tweak one piece than 32.**

Full step-by-step is in [`BUILD_GUIDE.md`](BUILD_GUIDE.md) ("Phase 0").

---

## Copy-paste this to your friend

> Hey! I'm building a wall-mounted chess board and the 3D-printable parts live
> in this repo: https://github.com/dhanjit/vertical-chess-board
>
> Could you render and print a **test batch first**, before the whole set?
> Everything you need (how to turn the `.scad` files into STLs, and print
> settings) is in `hardware/README.md`. In short:
> - Install **OpenSCAD** (free), then from the `hardware/` folder run `make`
>   to generate all the STLs — or just render the ones I list below.
> - **Test batch:** one `gravity_gimbal`, one `piece_king`, (optional) one
>   small board offcut.
> - **Material:** PLA is fine. ~15–20% infill, 0.2 mm layers, **no supports
>   needed** (parts are designed to print flat).
> - The pieces print in **two colors** (one for white, one for black) — but
>   for the test, any color is fine.
>
> If the test works I'll send the full print list (32 pieces + the board
> panel + frame). Thanks!!

---

## Your shopping list (the non-printed bits)

For the **test**, you only need a few of the first two items. For the **full
manual board**, get the quantities in [`BOM.md`](BOM.md). In plain terms:

| What | Why | Where |
|------|-----|-------|
| Small **neodymium disc magnets** (8 mm × 3 mm) | go inside each piece so it sticks to the board | Amazon / hobby store |
| **Steel washers** (~16 mm, with a hole — "M8 fender washers") | one behind each square; the magnet grabs these | hardware store (get plain **steel**, not stainless) |
| Small **steel nuts** (M6) | tiny weights that keep pieces upright | hardware store |
| A **lazy-susan / turntable bearing** (~90 mm) | lets the board spin on the wall | Amazon / hardware store |
| A **French cleat** (a slanted hanging bracket) | how it hangs on the wall | hardware store |
| Super glue / epoxy | assembly | anywhere |

> **One tip that saves headaches:** magnets and washers come in slightly
> different sizes. Buy the sizes above, and during the Phase 0 test we confirm
> they fit. If they don't, I change one number in the design and your friend
> re-prints — no problem.

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

Tell me exactly what happened ("the piece won't stay upright," "the magnet is
too weak," "my friend's printer bed is small") and I'll adjust the design or
the plan. That's what this repo is for.
