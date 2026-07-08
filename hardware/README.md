# Hardware — parametric 3-D models

All parts are **OpenSCAD**, driven by one shared config so the whole board
resizes from a few numbers. Give these files (or the rendered STLs) to whoever
is printing.

## Files

| File | What it makes |
|------|---------------|
| **`common.scad`** | Shared parameters + helpers. **Edit this to resize everything.** |
| **`gravity_gimbal.scad`** | The self-righting pivot: hub puck (holds a magnet, carries the axle) + snap cap. |
| **`pieces.scad`** | The six pieces as flat self-righting silhouettes (pivot bore + base weight pocket). |
| **`board_panel.scad`** | The 8×8 playing surface: engraved grid + labels, steel-sheet pocket, hall-sensor pockets. Whole or quartered. |
| **`frame.scad`** | Bezel that captures the panel and mounts the turntable. |
| **`rotation_hub.scad`** | Wall plate + turntable (lazy-susan bearing) + GT2 drive pulley. |
| **`Makefile`** | Renders every part to `stl/`. |

## Render

Requires [OpenSCAD](https://openscad.org) on your PATH.

```
cd hardware
make            # everything -> hardware/stl/
make FN=128     # smoother curves for final prints
make pieces     # just the chess pieces
```

Render one part directly:
```
openscad -D 'PART="king"'      -o king.stl   pieces.scad
openscad -D 'QUARTER="bl"'     -o panel.stl  board_panel.scad
openscad -D 'PART="turntable"' -o tt.stl     rotation_hub.scad
```

## Print notes

- **Pieces** print flat (silhouette down) — no supports. Two filament colors
  for White/Black. Drop a steel weight in the base pocket; magnet press-fits
  in the hub.
- **Board panel** — dark squares are recessed for two-tone printing (pause &
  swap) or paint fill. Print whole on a big bed, or the four quarters.
- **Tolerances** live in `common.scad` (`slop`, `axle_fit`, `magnet_fit`).
  Do the Phase-0 test print first and tune before committing to a full set.

See [`../docs/BUILD_GUIDE.md`](../docs/BUILD_GUIDE.md) for assembly and
[`../docs/DESIGN.md`](../docs/DESIGN.md) for how the mechanics work.
