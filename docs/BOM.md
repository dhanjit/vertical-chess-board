# Bill of Materials

Quantities are for a **45 mm-square** board (default `common.scad`). Prices are
rough ballparks for planning, not quotes. Phase 1 is everything you need for a
working manual wall board; later phases layer on.

## Phase 1 — Manual magnetic wall board

| Item | Qty | Notes | ~Cost |
|------|-----|-------|-------|
| 3-D printer filament (PLA/PETG) | ~1.5–2 kg | 2 colors for White/Black + board | $30–50 |
| Neodymium disc magnets, **8 × 3 mm N52** | ~40 | 32 pieces + spares; press-fit into hubs | $10–15 |
| **Steel sheet**, 0.5–1 mm mild/galvanized, `grid_size` square (**360 mm** at default) | 1 | the playing surface — glued to the panel front; piece magnets grip it directly. For Phase 2, have the fab laser-cut the 64 sensing holes (`make sheet` exports the DXF) | $8–15 |
| Felt discs, self-adhesive (~10 mm) | ~40 | one over each hub magnet — sets the glide, protects the sheet's paint | $3 |
| Steel weights for piece bases (**M3 nuts**, two per piece, or ~6 mm steel balls/discs) | ~70 | glue into the 7 mm base pocket to tune self-righting. **An M6 nut is too big for the pocket** | $5 |
| **Lazy-susan / turntable bearing** (~90 mm OD) | 1 | carries the board, lets it rotate | $8–15 |
| French cleat (wood/metal) or heavy Z-bracket | 1 | wall mount | $10 |
| M3 bolts/heat-set inserts assortment | 1 kit | frame ↔ turntable, panel bosses | $10 |
| Dry PTFE lube | 1 | crisp pivot swing | $6 |
| Spray paint / epoxy (optional) | — | fill dark squares / finish | $15 |

**Phase 1 subtotal:** ~$120–160 + print time.

## Phase 2 — Powered rotation + sensing (adds to Phase 1)

| Item | Qty | Notes | ~Cost |
|------|-----|-------|-------|
| **NEMA-17 stepper** (e.g. 17HS4401) | 1 | rotates the board | $10–14 |
| Stepper driver (A4988/DRV8825/TMC2209) | 1 | TMC2209 = quiet | $3–10 |
| **GT2 timing belt** (6 mm) + 20T pulley | 1 | belt loop around turntable rim | $8 |
| Microcontroller — **ESP32** (Wi-Fi/BLE) | 1 | reads sensors, drives motor, hosts brain | $6–10 |
| **Hall-effect sensors** (A3144 or 49E) | 64 + 2 | 64 board grid + 2 home index (the 2 index *magnets* come out of the Phase-1 magnet spares) | $12–20 |
| **16-channel** analog/digital multiplexers (CD74HC4067) | 4 | scan the 64 sensors (or wire an 8×8 matrix instead) | $8 |
| 12 V power supply (2–3 A) + buck to 5 V | 1 | motor + logic | $12 |
| Perfboard/PCB, wiring, connectors | — | sensor grid harness | $15 |
| WS2812 LEDs (optional, per-square hints) | 64 | move highlights | $10 |
| Slip ring (optional, if powered side rotates) | 1 | avoids wire wind-up | $10 |

**Phase 2 add:** ~$100–130.

## Phase 3 — Auto-mover (adds to Phase 2) — 🌠 aspirational

> **Aspirational / not the current focus** — the manual board needs none of
> this. This table prices the **reclined-gantry fallback**; if auto-play is
> ever pursued, the researched route per decision D6 is the **EPM matrix** —
> its (different) parts budget is in [`AUTO_MOVER_DESIGN.md`](AUTO_MOVER_DESIGN.md).

| Item | Qty | Notes | ~Cost |
|------|-----|-------|-------|
| 2× NEMA-17 + Core-XY hardware (belts, pulleys, rails/rods) | 1 set | XY gantry behind the panel | $60–90 |
| Electromagnet (5 V/12 V, ~10 N) + driver (MOSFET) | 1 | drags piece magnets | $10 |
| Extra stepper driver | 2 | for the gantry | $10 |
| Deeper frame / spacer ring | 1 | room for the gantry behind the panel | print |

**Phase 3 add:** ~$90–130.

---

### Sourcing notes
- **Magnets:** N52 8×3 mm discs are common and cheap; verify polarity is
  consistent when you press them in (mark one face).
- **Steel sheet:** must be *ferromagnetic* (mild/galvanized steel — **not**
  stainless 304 or aluminum; test with a fridge magnet before buying). 0.5–1 mm
  is plenty — the magnets, not the sheet, carry the load. Any laser/waterjet
  shop can cut the outline + 64 sensing holes from the exported DXF
  (`make sheet`); a plain hand-cut sheet is fine for Phase 1.
- **Bearing:** any turntable/lazy-susan bearing near `bearing_od` works; adjust
  `bearing_od`/`bearing_id` in `common.scad` to what you buy.
- **Stepper torque:** 10:1 reduction (default) makes a standard NEMA-17 ample
  for a 2–3 kg board. If you go big (60 mm squares), recheck.
