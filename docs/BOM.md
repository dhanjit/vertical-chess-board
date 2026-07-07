# Bill of Materials

Quantities are for a **45 mm-square** board (default `common.scad`). Prices are
rough ballparks for planning, not quotes. Phase 1 is everything you need for a
working manual wall board; later phases layer on.

## Phase 1 — Manual magnetic wall board

| Item | Qty | Notes | ~Cost |
|------|-----|-------|-------|
| 3-D printer filament (PLA/PETG) | ~1.5–2 kg | 2 colors for White/Black + board | $30–50 |
| Neodymium disc magnets, **8 × 3 mm N52** | ~40 | 32 pieces + spares; press-fit into hubs | $10–15 |
| Steel washers (**~16 mm OD, 8.4 mm ID**, e.g. M8 fender) | ~70 | one behind each of the 64 squares (+ spares); pieces grip + self-center on these | $8–12 |
| Steel weights for piece bases (M6 nuts or 6 mm discs) | ~40 | drop into base pocket to tune self-righting | $5 |
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
| **Hall-effect sensors** (A3144 or 49E) | 64 + 2 | 64 board grid + 2 home index | $12–20 |
| 8-channel analog/digital multiplexers (CD74HC4067) | 4–8 | scan the 64 sensors | $8 |
| 12 V power supply (2–3 A) + buck to 5 V | 1 | motor + logic | $12 |
| Perfboard/PCB, wiring, connectors | — | sensor grid harness | $15 |
| WS2812 LEDs (optional, per-square hints) | 64 | move highlights | $10 |
| Slip ring (optional, if powered side rotates) | 1 | avoids wire wind-up | $10 |

**Phase 2 add:** ~$100–130.

## Phase 3 — Auto-mover (adds to Phase 2)

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
- **Steel washers:** must be *ferromagnetic* (zinc-plated/mild steel — **not**
  stainless 304 or aluminum; test with a fridge magnet before buying). Standard
  M8 fender washers (~16 mm OD) are ideal and cheap in bulk.
- **Bearing:** any turntable/lazy-susan bearing near `bearing_od` works; adjust
  `bearing_od`/`bearing_id` in `common.scad` to what you buy.
- **Stepper torque:** 6:1 reduction (default) makes a standard NEMA-17 ample for
  a 2–3 kg board. If you go big (60 mm squares), recheck.
