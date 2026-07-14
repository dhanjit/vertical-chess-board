# Sourcing in Bengaluru

Where to get parts printed and buy the bits, locally. Prices are **rough,
2026 ballparks in ₹** for planning — confirm at purchase. Read
[`PROJECT_REVIEW.md`](PROJECT_REVIEW.md) first for what you actually need at
each stage.

> **Biggest money tip:** printing on a **printer you have access to** (your own
> or a borrowed one) costs only filament (₹1.5–2.5k for the whole manual board).
> Paying a print *service* for the large board panel runs ₹8–15k. Use a personal
> printer if you can; use a service only for one-off test parts or if you have
> no printer access.

---

## A. Getting the parts printed

### Option 1 — Your own or a borrowed printer (recommended)
The cheapest route if you have access to a printer: just buy filament and
render the parts. The print spec (what to render, settings) is in
[`START_HERE.md`](START_HERE.md) and
[`../hardware/README.md`](../hardware/README.md).

**Filament (PLA), Bengaluru / online:**
- ~₹700–1,300 per 1 kg spool (WOL3D, ClayObjects, iamRapid, Robu.in, Amazon.in).
- You'll want **two colours** (white/black pieces) + one for the board. Budget
  ~1.5–2 kg total for the full board.

### Option 2 — Online print service (upload STL, they print & deliver)
Good for the **Stage A test parts** or if you have no printer. Render the STLs
first (see `hardware/README.md`), then upload:

- **iamRapid** — Bengaluru; instant quote, FDM PLA from ~₹6/g, parts from
  ~₹99, ~24 h delivery in the city. <https://iamrapid.com/3d-printing-services-in-bangalore/>
- **Makenica** — Bengaluru; same-day FDM/SLA/SLS. <https://makenica.com/3d-printing-services-in-bangalore>
- **Rapid3D**, **3Ding**, **3D Paradise** — other Bengaluru FDM services.

**Reality check on cost:** the board panel is a large part (~700–900 g). At
~₹6/g that's ₹4–5k for the panel *alone*, plus pieces and frame → a full board
via a service is easily ₹10–15k. Hence: a personal printer for the big stuff.

### Option 3 — Makerspaces (print it yourself + get guidance)
Also the best place for help when you reach the electronics stages.
- **Workbench Projects** (near Ulsoor/Halasuru) — 3D printers, laser, CNC.
  <https://workbenchprojects.com/>
- **IKP EDEN** (Koramangala) — membership + beginner 3D-printing sessions.
- **CMR University Makerspace** / **Alliance University CoE** — hourly/project
  access to external users (ask their desk).

---

## B. Non-printed parts (the shopping list)

### Physical / hardware store + online

| Part | Where (Bengaluru) | Rough ₹ |
|---|---|---|
| **Neodymium disc magnets** 8×3 mm N52 (~40) | **SP Road** magnet dealers (physical); Robu.in, Amazon.in, IndiaMART online | ₹5–15 each → ₹300–600 |
| **Steel washers** ~16 mm (**M8 plain/flat**, DIN 125 — *not* "fender/repair" washers, those are ~24 mm), plain steel (~70) | any hardware store; SP Road; online | ₹1–3 each → ₹150–300 |
| **Steel nuts** **M3** (piece weights — two per piece, glued; ~70) | hardware store | ₹1–2 each → ₹100 |
| **Lazy-susan / turntable bearing** ~90 mm (design default; any size works if you set `bearing_od`/`bearing_id` in `hardware/common.scad` **before printing**) | IndiaMART, Amazon.in; hardware/furniture-fittings shops | ₹80–400 |
| **French cleat** (or a strip of wood/aluminium to make one) | timber/hardware shop; Amazon.in | ₹150–500 |
| **Super glue / epoxy (Araldite)** | anywhere | ₹100–200 |
| **M3 bolts + heat-set inserts** (frame/turntable) | SP Road, hardware, Robu.in | ₹150–300 |
| Spray paint / marker for dark squares (optional) | hardware/stationery | ₹150–300 |

> **SP Road (Sadar Patrappa Road)** is Bengaluru's electronics & components
> market — magnets, fasteners, motors, sensors, wire, tools, all in one area.
> Great for buying in person and asking questions. Robu.in and Robocraze are
> the go-to **online** stores (both India-based, fast shipping).

### Electronics (only for Stage C+ — ignore for the manual board)

| Part | Where | Rough ₹ |
|---|---|---|
| **NEMA-17 stepper** (e.g. 17HS4401, ~4 kg-cm) | Robu.in, Robocraze, SP Road | ₹450–700 |
| **Stepper driver** (A4988 / DRV8825 / TMC2209) | Robu.in, Robocraze | ₹80–350 |
| **GT2 belt (6 mm) + 20T pulley** | Robu.in, Amazon.in | ₹150–300 |
| **ESP32 dev board** | Robu.in, Robocraze, Amazon.in | ₹350–600 |
| **Hall sensors** A3144 (digital) or 49E (analog), ×64+ | Robu.in, SP Road (buy in bulk) | ₹5–12 each |
| **Multiplexers** CD74HC4067 (×4–8) | Robu.in, Robocraze | ₹40–90 each |
| **12 V power supply** (2–3 A) + buck converter | SP Road, Robu.in | ₹300–600 |
| Perfboard, wire, connectors, breadboard (for learning) | SP Road, Robu.in | ₹300–700 |

Online stores: **Robu.in**, **Robocraze.com**, **Quartzcomponents**,
**ProtoCentral**, **Amazon.in**. In person: **SP Road**.

---

## C. Suggested first purchase (Stage A test only)

Keep it tiny — you're just proving the mechanic:
- ~10 neodymium magnets (8×3 mm) — ₹100–150
- 4–5 steel washers (~16 mm, M8 plain) — ₹20
- a few M3 nuts + super glue — ₹50
- (prints: 1 gimbal + 1 king on a personal printer, or ~₹200–400 at a service)

**Total ≈ ₹300–600.** Then run the Stage A test in
[`BUILD_GUIDE.md`](BUILD_GUIDE.md) ("Phase 0") and note how it behaves — the
tuning table there maps each symptom to one number in `hardware/common.scad`.

---

## Sources
- iamRapid — Bengaluru 3D printing pricing: <https://iamrapid.com/3d-printing-services-in-bangalore/>
- Makenica — Bengaluru 3D printing: <https://makenica.com/3d-printing-services-in-bangalore>
- Workbench Projects makerspace: <https://workbenchprojects.com/>
- Robu.in NEMA-17 steppers: <https://robu.in/product-category/dc-motors/motors/stepper-motors/>
- Turntable/lazy-susan bearings (IndiaMART): <https://dir.indiamart.com/impcat/turntable-bearing.html>
- Neodymium magnet dealers, SP Road (Justdial): <https://www.justdial.com/Bangalore/Neodymium-Magnet-Dealers-in-Sp-Road/nct-10800511>

*(Prices/vendors change — treat as a starting map, not a quote. Verify before buying.)*
