# Bill of Materials

Quantities are for a **55 mm-square** board — the default in `common.scad`,
which gives a **490 mm** panel (about 49 cm / 19 in square) with a **440 mm**
playing grid inside it. Prices are rough ballparks for planning, not quotes.
Phase 1 is everything you need for a working manual wall board; later phases
layer on.

> **Buy the Phase-0 handful first, not the whole list.** Nothing in this
> project has been physically built or printed yet — every dimension and every
> lean angle quoted anywhere in these docs comes from a *model*, not from a
> finished object. A few magnets, one dowel pin, a felt disc and a tube of
> grease is enough to run the Phase-0 test in
> [`BUILD_GUIDE.md`](BUILD_GUIDE.md). Buy the full quantities after that test
> passes.

## Phase 1 — Manual magnetic wall board

| Item | Qty | Notes | ~Cost |
|------|-----|-------|-------|
| 3-D printer filament (PLA/PETG) | ~2–2.5 kg | 2 colors for White/Black pieces, plus the panel, frame, 32 hub pucks and 32 press caps | $40–60 |
| Neodymium disc magnets, **Ø8 × 3 mm N52** | ~40 | 32 hubs + spares. The magnet lives in the **hub puck**, not in the piece — it is what grips the steel sheet | $10–15 |
| **Steel sheet**, 0.5–1 mm mild/galvanized, `grid_size` square (**440 mm** at the default 55 mm squares) | 1 | the playing surface — glued to the front of the 490 mm panel; hub magnets grip it directly. For Phase 2, have the fab laser-cut the 64 sensing holes (`make sheet` exports the DXF) | $10–18 |
| Felt discs, self-adhesive (~10 mm) | ~40 | one over each hub magnet — sets the glide, protects the sheet's paint | $3 |
| **Steel dowel pins, Ø3 × 16 mm** | ~40 | the piece axles — one pressed into each hub. Bought, not printed, and **thinner *and* stronger** than the printed post it replaced — see sourcing notes | $8–12 |
| **Lazy-susan / turntable bearing** (~90 mm OD) | 1 | carries the board, lets it rotate | $8–15 |
| French cleat (wood/metal) or heavy Z-bracket | 1 | wall mount | $10 |
| M3 bolts/heat-set inserts assortment | 1 kit | frame ↔ turntable, panel bosses | $10 |
| **Silicone damping grease** | 1 tube | a dab in each pivot bore. Its *viscous* drag stops a piece ringing after a board flip without adding the *static* friction that parks it off-vertical — dry PTFE lube makes the opposite trade and is no longer recommended here | $8 |
| Spray paint / epoxy (optional) | — | fill dark squares / finish | $15 |

**Phase 1 subtotal:** ~$105–150 + print time (add ~$15 if you paint or epoxy
the squares).

**Nothing is missing from that list.** There is deliberately **no ballast on
it** — no lead, no M3 nuts, no steel balls, and no pocket to glue them into.
Each piece is bottom-heavy *by shape*, so it is one printed part with nothing
added; see the sourcing notes below for why that is better than a glued-in
weight, not just simpler.

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
- **Magnets:** N52 Ø8×3 mm discs are common and cheap; verify polarity is
  consistent when you press them in (mark one face). They press into the **back
  of each hub puck** — the pieces themselves contain no magnet and no metal.
- **Steel sheet:** must be *ferromagnetic* (mild/galvanized steel — **not**
  stainless 304 or aluminum; test with a fridge magnet before buying). 0.5–1 mm
  is plenty — the magnets, not the sheet, carry the load. Any laser/waterjet
  shop can cut the outline + 64 sensing holes from the exported DXF
  (`make sheet`); a plain hand-cut sheet is fine for Phase 1. The sheet covers
  the 440 mm playing grid and glues centred on the 490 mm printed panel, so the
  25 mm printed border stays visible for the file/rank labels.
- **Dowel pins:** plain Ø3 h8 × 16 mm steel dowels, sold by the bag. Length
  matters and is why 16 mm is the size to buy: 5 mm presses into the hub and
  11 mm stands proud (`axle_embed` + `axle_len` in `common.scad`), so **nothing
  has to be cut to length**. A smooth M3 screw shank works in a pinch, but
  *threads* in the bore raise friction and defeat the point.
  - *Why bought and not printed:* how straight a piece hangs is set by friction
    in its bore, and ground steel sliding on plastic is roughly half the
    friction of a printed post in a printed bore. It is also **stronger** even
    though it is *thinner* than the Ø4 printed post it replaced: against a 20 N
    sideways knock (a firm accidental swipe), a printed Ø4 post modelled at
    only 1.29× margin — it snaps at the layer line where it meets the hub —
    while a Ø3 steel dowel carries 3.0×. Going thinner also directly shrinks
    the settling error, because the error scales with the bore radius.
  - *Why no ball bearing:* one was evaluated and **rejected on two counts.**
    (1) A bearing needs a seat, and the reinforcing boss around the pivot would
    have to grow wider than the pawn — the smallest piece in the set — has to
    give, so the artwork would end up designed around its hardware. (2) A
    bearing has almost *no* friction, and here friction is doing a second job:
    **damping**. With nothing to bleed off the energy, a piece would swing back
    and forth for minutes after every board flip. What this pivot wants is low
    *static* friction with *viscous* damping, and a greased steel dowel is
    exactly that.
- **Silicone damping grease:** the one consumable the design's behaviour
  actually depends on. A dab in each bore. Buy silicone (damper/plastic-safe)
  grease, not a dry PTFE lube: PTFE cuts the damping you want and leaves the
  static friction you don't. **Honest caveat:** the lean figures quoted in
  [`../hardware/README.md`](../hardware/README.md) assume a friction
  coefficient of 0.08 for greased steel on plastic. That is a textbook number,
  not one measured on this hardware — the lean angles scale with it, so if the
  real figure is double, so is every angle. Printing one pawn and one hub is
  what settles it.
- **No ballast, no lead, no nuts:** earlier revisions glued a dense slug into a
  pocket in each piece's base. That is gone, and not only to save a step. A
  glued-in weight makes the balance depend on the *ratio* of slug density to
  plastic density, so tuning done in one material does not carry to another — a
  cheap PLA/PETG test print would settle differently from a final resin piece
  and would prove nothing. With the weight shaped in instead (solid below the
  pivot, hollow above it) the piece is one material, density cancels out of the
  physics entirely, and **a cheap test print behaves identically to the final
  part.** That is what makes the Phase-0 test worth trusting.
- **Bearing:** any turntable/lazy-susan bearing near `bearing_od` works; adjust
  `bearing_od`/`bearing_id` in `common.scad` to what you buy.
- **Stepper torque:** 10:1 reduction (default) makes a standard NEMA-17 ample
  for a 2–3 kg board. If you go bigger still (65 mm squares), recheck.
