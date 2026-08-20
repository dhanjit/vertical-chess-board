# prints/ — print-ready output, every variant side by side

This folder is the **printable output** of the repo, pre-rendered at final
quality (`$fn = 128`, binary STL, millimetres). The piece design is carried as
a **variant system** (decision **D12** in [`docs/GOALS.md`](../docs/GOALS.md)):
two independent selectors — the **artwork** (`piece_style`) and the **pivot
architecture** (`pivot_type`) — give six buildable combinations, and each one
gets its own folder here with its own instructions. Nothing in this folder is
"the" set; `familiar` + `pin` is the documented **default**, and the choice of
which combination gets printed 32 times is still open.

> **Nothing in this repo has been printed yet.** Every number quoted in these
> READMEs is modelled, not measured, and every lean figure assumes bore
> friction μ = 0.08 — a textbook value. **Do not print a full set from any
> folder before running the Phase-0 test in that folder's README** (one pivot +
> one pawn, flip it ten times). Lean scales linearly with μ, so that one cheap
> print validates — or re-scales — every figure below.

## The folders

| Folder | Artwork | Pivot | Printed parts per piece | Worst modelled lean (rook) | Verdict |
|---|---|---|---:|---:|---|
| [`familiar_pin/`](familiar_pin/) | recognizable chess vocabulary | magnet on the board, piece turns on a steel pin | 3 | 1.44° | **the default** — the look asked for, no unproven claims |
| [`familiar_magnet/`](familiar_magnet/) | same artwork | magnet in the piece, no printed pivot parts | 1 | 2.09° | viable, but two claims unproven — print the coupon first |
| [`monolith_pin/`](monolith_pin/) | austere invented language | pin | 3 | 1.81° | viable — smaller, quieter set, less margin than familiar |
| [`monolith_magnet/`](monolith_magnet/) | monolith | magnet | 1 | 2.89° | **ruled out by the modelling** — busts the 2.2° limit on 3 of 6 pieces; kept for honest comparison |
| [`familiar_bearing/`](familiar_bearing/) | familiar | ball bearing in the piece, hub as `pin` | 3 | ≈0° at any μ | the μ-immune fallback — **undamped**: ring-down after a flip is its open Phase-0 question |
| [`monolith_bearing/`](monolith_bearing/) | monolith | bearing | 3 | ≈0° at any μ | same, with 9× the sweep margin — the pairing that tolerates ringing |
| [`common/`](common/) | — | — | — | — | variant-independent parts: board panel, Phase-0 tile, turntable, frame |

The two axes are independent in the code but **not in the outcome** — the
monolith pieces are small, so their pendulum levers are short, and the magnet
architecture's penalty hurts a short lever most; the bearing's penalty
(ringing) instead lands hardest on the wide familiar set. Side-by-side
comparison with all the reasoning:
[`docs/PIECE_DESIGNS.md`](../docs/PIECE_DESIGNS.md).

## How to choose

- **Want it to read as chess from across the room?** `familiar`. Its pieces
  fill the square (king 42 mm wide) and it is the better pendulum on five of
  six pieces.
- **Want minimal print effort?** `pivot_type = "magnet"`: 1 printed part per
  piece instead of 3 — over a set that is 64 fewer printed parts and 32 fewer
  dowels — at ~0.4–0.6° more lean and a visible steel disc on every piece's
  face. Its two unproven mechanical claims cost one ~2 g coupon to test.
- **Worried friction will measure badly?** `pivot_type = "bearing"` parks ≈0°
  no matter what μ turns out to be — at the price of one MR63ZZ per piece and
  an undamped swing. It is the plan B the Phase-0 test can promote.
- **Undecided?** Print one pawn from two folders and look at them on a wall.
  That is what this layout is for.

## Regenerating

STLs are **gitignored** repo-wide (`*.stl`) — only these READMEs are tracked.
Rebuild the whole folder from source at any time:

```powershell
cd hardware
.\build.ps1 matrix -Fn 128 -Out ..\prints            # the six variant folders
.\build.ps1 board -Fn 128 -Out ..\prints\common      # panel + quarters
.\build.ps1 board_test -Fn 128 -Out ..\prints\common # Phase-0 tile
```

(macOS/Linux: `make matrix FN=128` etc. — same targets.) The `mech` parts in
`common/` were rendered individually to **exclude `hub_drive_pulley`**, which
has a known defect — it renders as 18 separate solids (see the note in
[`hardware/README.md`](../hardware/README.md)) and is a Phase-2 part nothing
near-term needs. The STLs here were exported with `--export-format binstl`;
the build scripts default to ASCII, which slices identically but is ~4× larger
on disk.

## Reading order for a first build

1. [`docs/OVERVIEW.md`](../docs/OVERVIEW.md) — what this thing is.
2. [`docs/BUILD_GUIDE.md`](../docs/BUILD_GUIDE.md) — Phase 0: prove the pivot
   before printing a set.
3. The README inside your chosen variant folder — files, shopping list,
   assembly, and that variant's numbers.
4. [`common/README.md`](common/README.md) — the board itself.
