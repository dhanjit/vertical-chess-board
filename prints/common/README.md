# common/ — variant-independent parts

Everything here is the same whichever piece style and pivot architecture you
choose. It is the board itself, the Phase-0 test tile, and the manual-rotation
mechanism.

## Files

| File | What it is | Print | Phase |
|---|---|---|---|
| `board_test.stl` | 1×2-square Phase-0 test tile — glue a steel offcut on its face and prove magnet grip + glide before anything else | 1 | **0** |
| `board_panel.stl` | the full 8×8 panel, ~490 × 490 mm — needs a very large bed | 1 *(or use quarters)* | 1 |
| `board_panel_bl.stl` `_br` `_tl` `_tr` | the same panel as four quarters for normal beds | 4 | 1 |
| `hub_wall_plate.stl` | wall side of the rotation hub — screws to the wall or a French cleat | 1 | 1 |
| `hub_turntable.stl` | turntable disc riding the lazy-susan bearing — hand-rotated in Phase 1 | 1 | 1 |
| `frame_corner.stl` | L-shaped bezel corner capturing the panel | 4 | 1 |

The panel has a hall-sensor bore behind every square; that costs nothing now
and makes the Phase-2 electronics a drop-in later. Phase 1 needs no
electronics of any kind.

## Deliberately not here

- **`hub_drive_pulley`** — known defect: renders as 18 separate solids (loose
  teeth), documented in [`hardware/README.md`](../../hardware/README.md). It is
  a Phase-2 (powered rotation) part; nothing in Phase 0–1 needs it.
- **`steel_sheet.dxf`** — the playing face is laser-cut steel, not a print.
  Generate the cutting outline with `.\build.ps1 sheet` (or `make sheet`) and
  take it to a laser shop.

## Buy (board side)

- **Steel sheet, 0.5–1.0 mm mild or galvanized** — *not* stainless 304 (weakly
  magnetic). It glues onto the panel's front face and is the entire playing
  surface: squares are paint/vinyl on this sheet, and the piece magnets grip it
  directly.
- **Lazy-susan bearing** (seat modelled at Ø90 outer) for the turntable.
- French cleat stock, M3 hardware, adhesive.

Quantities and the full priced list: [`docs/BOM.md`](../../docs/BOM.md).
Assembly order and wall mounting: [`docs/BUILD_GUIDE.md`](../../docs/BUILD_GUIDE.md).

## Print notes

- The panel and quarters are large flat prints — a coarse layer height is
  fine; the steel sheet hides the face anyway.
- `frame_corner` prints 4×; check the panel-capture fit on one corner before
  printing all four.
- Everything here should slice as a single shell.
