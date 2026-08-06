# Start Here — zero experience needed

**You don't need to own a 3D printer or know electronics or coding.** For the
first version — a real chess board you hang on the wall and play by hand — your
whole job is:

1. **Get the plastic parts printed** — on your own printer if you have one, or
   a local print service / makerspace (this repo has everything they need).
2. **Buy a short list of small parts** (magnets, a steel sheet, a spinning
   bracket).
3. **Glue a few things together and hang it.**

That's it. The fancy stuff — a motor that spins the board, sensors, and
(aspirationally) a board that plays *you* and a phone app — is **optional and
comes much later**. Ignore all of it for now.

**What you end up with:** a panel about **49 cm square** (490 mm — roughly the
size of a large framed picture), with **55 mm squares** and pieces from 32 mm
(pawn) to 51 mm (king) tall. Big enough to read from a sofa across the room.

> **Nothing here has been built yet.** This repo is a complete, worked-out
> design, but no one has printed it and hung it on a wall — so the numbers in
> it are worked out on a computer, not measured off a real object. If you build
> it, you are the first. That is exactly why the cheap one-evening test below
> comes before the shopping.

> **Want the what/why/how first?** [`OVERVIEW.md`](OVERVIEW.md) is the whole
> project on one page — what it is, why, and the plan. Good to read (or share)
> before you start.

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
- 1 × "gravity gimbal" pair (the little pivot hub + its cap)
- 1 × **pawn** — test the *pawn*, not the king: it is the smallest, quickest,
  cheapest print, and what the test measures (pivot friction) is the same for
  every piece. (If you want to check the fussiest piece too, add a **rook** —
  it is the squattest one, so it hangs on the shortest pendulum and is the
  first to run out of margin.)
- 1 × small board test section (optional but nice)

**You buy:** a couple of the small magnets, a few self-adhesive felt discs,
**one Ø3 × 16 mm steel dowel pin** (this is the axle the piece hangs on — it's
a plain little steel rod, sold by the bag), and a tube of silicone damping
grease. See the list below — you only need a few of each for the test.

**Then:**
1. Press a magnet into the **back** of the pivot hub, and stick a felt disc
   over it.
2. Press the steel dowel into the **front** of the hub until it stops against
   the magnet. About 11 mm should stand proud.
3. Smear a dab of the grease inside the hole through the middle of the pawn,
   drop the pawn onto the dowel, and push the little cap onto the end so it
   can't fall off. It should still spin freely.
4. Stick the hub to a steel surface held sideways — a fridge side, a filing
   cabinet, any steel offcut. It should **hold on**, and the pawn should
   **stay upright when you rotate the surface**.

Nothing gets glued *into* the piece. It stays upright because of its shape:
solid at the bottom, hollow at the top, so it hangs like a pendulum. That is
also why a cheap PLA test print tells you the truth about a fancy resin one —
same shape, same behaviour, whatever the plastic weighs.

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
- **Test batch:** one `gimbal_testpair`, one `piece_pawn`, (optional) one
  `board_test` tile (`make gimbal board_test` + `make pieces`).
- **Material:** PLA is fine. 0.2 mm layers, **no supports needed** (parts are
  designed to print flat). ~15–20% infill for the big parts — the panel and
  the frame.
- **The pieces themselves print SOLID (100% infill).** They stay upright
  because they are solid low down and hollow up top, and that hollow is
  modelled into the part itself. Sparse infill lightens the *solid* lower half
  while leaving the walls around the modelled cavity, which flattens exactly
  the top-to-bottom weight difference the piece self-rights with. The slicer
  must also never add its own "hollow" or vary density top to bottom.
- **Resin printers:** every piece has a small **drain hole** in its back face.
  Don't orient the print so that hole ends up sealed, or uncured resin gets
  trapped inside. Each piece should slice as a single shell.
- **Colors:** the pieces print in **two colors** (one for White, one for
  Black) — for the test, any color is fine.
- **Full set (after the test passes):** 32 pieces + 32 pivot hubs and caps +
  the board panel + frame — see [`BOM.md`](BOM.md) and
  [`BUILD_GUIDE.md`](BUILD_GUIDE.md).
- **If anyone edits the piece shapes:** the knight is the one piece whose
  balance is hand-tuned rather than automatic. Change its head and it will
  still print perfectly and then hang permanently tilted. The details, and the
  full honest list of what is and isn't verified, are in
  [`../hardware/README.md`](../hardware/README.md).

---

## Your shopping list (the non-printed bits)

For the **test**, you only need a few of the first two items. For the **full
manual board**, get the quantities in [`BOM.md`](BOM.md). In plain terms:

| What | Why | Where |
|------|-----|-------|
| Small **neodymium disc magnets** (Ø8 mm × 3 mm) | one goes in the back of each little pivot hub — this is what sticks to the board. The pieces themselves hold no magnet | Amazon / hobby store |
| **Steel dowel pins** (**Ø3 × 16 mm**, one per piece) | the axles the pieces hang and swivel on. Plain steel rods; buy them, don't print them | hardware store / fastener shop |
| **Self-adhesive felt discs** (~10 mm) | one over each magnet — sets the glide and protects the board's paint | stationery / hardware store |
| A **thin steel sheet** (0.5–1 mm plain or galvanized steel, **440 mm square**) | the playing surface — glued to the front of the 490 mm board panel; the magnets grip it directly | sheet-metal / fabrication shop (get plain **steel**, not stainless) |
| **Silicone damping grease** (one small tube) | a dab in each pivot so pieces settle upright instead of swinging for ages | hardware / model shop |
| A **lazy-susan / turntable bearing** (~90 mm) | lets the board spin on the wall | Amazon / hardware store |
| A **French cleat** (a slanted hanging bracket) | how it hangs on the wall | hardware store |
| Super glue / epoxy | assembly (sheet to panel, and a drop in the pivot if a fit runs loose) | anywhere |

> **One tip that saves headaches:** magnet and dowel sizes vary slightly
> between sellers. Buy the sizes above, and the Phase 0 test confirms they fit
> the printed parts. If they don't, one number changes in the design
> (`hardware/common.scad`) and the small part gets re-printed — no problem.
> Buy the 16 mm dowel length specifically: 5 mm of it presses into the hub and
> 11 mm stands proud, so **nothing has to be cut**.
>
> **You will not find weights on this list, and nothing is missing.** Earlier
> versions of the design glued small metal weights into the base of every
> piece. They're gone — each piece is bottom-heavy by shape now, so it is one
> printed part with nothing added.
>
> This table covers the hand-played board's main parts; you also need **M3
> bolts + heat-set inserts** for the frame assembly. The complete per-phase
> list is [`BOM.md`](BOM.md).

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

- [`OVERVIEW.md`](OVERVIEW.md) — the whole project on one page: what it is, why,
  and the plan. The best thing to read (or share) for context.
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
