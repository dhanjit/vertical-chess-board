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
  ~2–2.5 kg total for the full board (the panel is 490 mm square) — same
  quantity as [`BOM.md`](BOM.md).

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
| **Steel sheet** 0.5–1 mm **mild/GI** (galvanized) — *not* stainless (most isn't magnetic) — one **440 mm** square (the playing grid at the locked 55 mm squares; it glues centred on the 490 mm panel); for Phase 2 have the 64 sensing holes laser-cut (`make sheet` exports the 1:1 cutting DXF) | any sheet-metal/fabrication shop; SP Road; laser-cutting services (small DXF jobs are cheap and common in Bengaluru) | ₹300–800 incl. cutting |
| **Self-adhesive felt discs** ~10 mm (one per piece + spares; ~40) | stationery/hardware stores; Amazon.in | ₹50–150 |
| **Steel dowel pins Ø3 × 16 mm** (the piece axles — one per piece + spares; ~40) | fastener/hardware shops; SP Road; IndiaMART | ₹3–10 each → ₹150–400 |
| **Silicone damping grease** (1 small tube — a dab in each pivot bore) | hardware / model / RC shops; Amazon.in | ₹150–400 |
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
- a strip of self-adhesive felt discs — ₹50
- a couple of **Ø3 × 16 mm steel dowel pins** + a small tube of **silicone
  damping grease** + super glue — ₹150–400
- steel to stick to: any fridge side or offcut works — buy the real sheet at
  Stage B — ₹0
- (prints: 1 gimbal + 1 **pawn** on a personal printer, or ~₹200–400 at a service)

> **No weights on this list, and nothing is missing.** Earlier revisions glued
> M3 nuts into a pocket in each piece; that is gone. Every piece is bottom-heavy
> by shape now — one printed part, nothing added.

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
