# Bill of Materials

Quantities are for a **55 mm-square** board — the default in `common.scad`,
which gives a **490 mm** panel (about 49 cm / 19 in square) with a **440 mm**
playing grid inside it. Prices are rough ballparks for planning, not quotes.
Phase 1 is everything you need for a working manual wall board; later phases
layer on.

> **Buy the Phase-0 handful first, not the whole list.** Nothing in this
> project has been physically built or printed yet — every dimension and every
> lean angle quoted anywhere in these docs comes from a *model*, not from a
> finished object. A few magnets, one axle, a felt disc and a tube of grease is
> enough to run the Phase-0 test in [`BUILD_GUIDE.md`](BUILD_GUIDE.md). Buy the
> full quantities after that test passes.

## First: the shopping list depends on one choice

The design is kept as **selectable variants** on two independent axes, set at
the top of [`../hardware/common.scad`](../hardware/common.scad). More approaches
are expected to arrive, so nothing here is "the winner" — they sit side by side
so they can be compared.

```
piece_style = "familiar";   // "monolith" | "familiar"        — what the pieces LOOK like
pivot_type  = "pin";        // "pin" | "magnet" | "bearing"   — how a piece HANGS and TURNS
```

**Only `pivot_type` changes what you buy.** It decides whether the magnet lives
on the **board** (in a small printed hub, with a bought steel axle and a printed
cap) or **inside the piece** (with a bought steel disc holding it in). Those are
different bags of hardware, so the list below is split into a shared block plus
one block per architecture. Buy the shared block plus **exactly one** of the
other two.

**`piece_style` is buy-neutral** — same magnets, same sheet, same everything. It
only changes the silhouettes, and the filament difference is a rounding error: a
full 32-piece set is ~163 g of plastic in `"familiar"` against ~100 g in
`"monolith"`, both against a 2–2.5 kg total for the project. Pick it on looks,
not on cost. (The one place style *does* have a mechanical consequence is
`monolith` + `magnet` together — see the comparison table below.)

If you have no opinion yet, build the defaults: **`familiar` + `pin`**.

---

## Phase 1 — Manual magnetic wall board

### A. Shared parts — needed whichever pivot you choose

| Item | Qty | Notes | ~Cost |
|------|-----|-------|-------|
| 3-D printer filament (PLA/PETG) | ~2–2.5 kg | 2 colors for White/Black pieces, plus the panel and frame. The panel dominates; the pieces are ~100–165 g of it depending on `piece_style` | $40–60 |
| **Steel sheet**, 0.5–1 mm mild/galvanized, `grid_size` square (**440 mm** at the default 55 mm squares) | 1 | the playing surface — glued to the front of the 490 mm panel; the piece magnets grip it directly, in **both** architectures. For Phase 2, have the fab laser-cut the 64 sensing holes (`make sheet` exports the DXF) | $10–18 |
| **Lazy-susan / turntable bearing** (~90 mm OD) | 1 | carries the board, lets it rotate | $8–15 |
| French cleat (wood/metal) or heavy Z-bracket | 1 | wall mount | $10 |
| M3 bolts/heat-set inserts assortment | 1 kit | frame ↔ turntable, panel bosses | $10 |
| **Silicone damping grease** | 1 tube | a dab in each pivot bore under `"pin"` and `"magnet"`. Its *viscous* drag stops a piece ringing after a board flip without adding the *static* friction that parks it off-vertical — dry PTFE lube makes the opposite trade and is not recommended here. Under `"bearing"` keep it **out of the bearing**; the same tube is that architecture's ring-down retrofit, smeared between piece back and hub face if the flip test rings | $8 |
| Spray paint / epoxy (optional) | — | fill dark squares / finish | $15 |

**Shared subtotal:** ~$85–120 (add ~$15 if you paint or epoxy the squares).

### B. `pivot_type = "pin"` — the default. 3 printed + 2 bought per piece

The magnet sits on the **board** in a small printed hub puck, so its mass never
enters the pendulum. Buy these *in addition to* block A.

| Item | Qty | Notes | ~Cost |
|------|-----|-------|-------|
| Neodymium disc magnets, **Ø8 × 3 mm N52** | ~40 | 32 hubs + spares. The magnet lives in the **hub puck**, not in the piece — it is what grips the steel sheet | $10–15 |
| **Steel dowel pins, Ø3 × 16 mm** | ~40 | the piece axles — one pressed into each hub. Bought, not printed, and **thinner *and* stronger** than the printed post it replaced — see sourcing notes | $8–12 |
| Felt discs, self-adhesive (~10 mm) | ~40 | one over each hub magnet — sets the glide, protects the sheet's paint | $3 |
| *Printed:* hub pucks (Ø11.5 × 8) | 32 + spares | comes out of the filament in block A — the 32 hubs and 32 caps together are only ~30 g | — |
| *Printed:* press caps (Ø6) | 32 + spares | ditto. Small and quick; print a few extra | — |

**"pin" block subtotal:** ~$21–30
→ **Phase 1 total with `"pin"`: ~$105–150** + print time.

### C. `pivot_type = "magnet"` — 1 printed + 2 bought per piece

**No hub, no dowel, no cap, no felt disc.** A Ø4 magnet sits in the piece's own
bore and the piece turns *on the magnet*; a steel disc dropped into a counterbore
in the piece's front face is what stops the piece pulling off. Both are bought;
nothing is printed but the piece itself. Three named parts go away and one
arrives, so the **net saving is two components per piece — and two of the three
printed ones.** Buy these *in addition to* block A.

| Item | Qty | Notes | ~Cost |
|------|-----|-------|-------|
| Neodymium disc magnets, **Ø4 × 5 mm N52** | ~40 | the piece turns **on** this magnet — it is both the journal and the thing that grips the sheet. Ø4 not Ø5 on purpose: the bore radius is the numerator of the lean equation, and Ø5 measured meaningfully worse | $8–12 |
| **Steel discs, Ø9 × 0.8 mm** (plain "keeper" / shim discs) | ~40 | held on the magnet's front pole by the magnet itself — **no glue**. Being wider than the Ø4.70 bore is the only thing retaining the piece | $5–10 |
| ~~Hub pucks~~ | — | **not used in this architecture** | — |
| ~~Ø3 × 16 dowel pins~~ | — | **not used** | — |
| ~~Press caps~~ | — | **not used** | — |
| ~~Felt discs~~ | — | **not used** — the magnet is modelled flush with the piece's back face, touching the steel sheet with nothing in the gap. See the sourcing note on glide | — |
| *Printed:* pivot test coupon | 1 | a Ø16 × 6 disc carrying the bore and disc seat and nothing else. `make gimbal` renders it. It is the ~2 g experiment that settles both of this architecture's unproven claims — print one before you commit | — |

**"magnet" block subtotal:** ~$13–22
→ **Phase 1 total with `"magnet"`: ~$100–145** + print time.

### D. `pivot_type = "bearing"` — 3 printed + 3 bought per piece

Everything in block **B** unchanged — same hubs, dowels, magnets, felt, caps —
**plus one ball bearing per piece** pressed into the piece's back face, which
the piece turns on instead of sliding on the dowel. Parking error becomes ≈0°
at any friction; what is *not* solved is damping — read the `"bearing"` section
of [`PIECE_DESIGNS.md`](PIECE_DESIGNS.md) before choosing this, and print one
pawn + one bearing before buying 40.

| Item | Qty | Notes | ~Cost |
|------|-----|-------|-------|
| Everything in block B | — | hub magnets, dowels, felt, printed hubs + caps | $21–30 |
| **MR63ZZ bearings, Ø3 × Ø6 × 2.5 mm** (shielded) | ~36 | the priciest bought part in any architecture here. **ZZ (metal shields), not 2RS (rubber seals)** — and do **not** degrease them: the factory fill is the only damping this architecture has | $10–25 |

**"bearing" block subtotal:** ~$31–55
→ **Phase 1 total with `"bearing"`: ~$115–175** + print time.

### The architectures side by side

| | `"pin"` (default) | `"magnet"` | `"bearing"` |
|---|---|---|---|
| Components per piece | **5** — 3 printed + 2 bought (+ a felt disc) | **3** — 1 printed + 2 bought | **6** — 3 printed + 3 bought (+ a felt disc) |
| Printed per piece | **3** — piece + hub + cap | **1** — the piece only | **3** — piece + hub + cap |
| Bought per piece | Ø8 × 3 magnet, Ø3 × 16 dowel, felt disc | Ø4 × 5 magnet, Ø9 × 0.8 disc | Ø8 × 3 magnet, Ø3 × 16 dowel, MR63ZZ bearing, felt disc |
| Where the magnet lives | on the **board** — its mass never enters the pendulum | in the **piece** — at zero lever arm, which is the whole cost | on the **board**, exactly as `"pin"` |
| Bore radius `r` | 1.85 mm (Ø3.70 on a Ø3 dowel) | 2.35 mm (Ø4.70 on a Ø4 magnet) | — (rolling, not sliding; the seat is Ø6.10) |
| Modelled lean cost | baseline | **+0.4 to +0.6°** across the set | **parking ≈0° at any μ** — but see the next two rows |
| Works with `piece_style` | both | **`familiar` only, in practice** — `monolith` + `magnet` busts the 2.2° working limit on 3 pieces of 6, with a 4th a hundredth under it (see the tables in [`BUILD_GUIDE.md`](BUILD_GUIDE.md) §2) | both geometrically; its *ringing* risk lands hardest on `familiar`, the style with the least sweep margin |
| Assembly | 5 steps per piece, off the board | 4 steps per piece, done **on** the board | 6 steps per piece — `"pin"` plus pressing the bearing |
| Unproven | nothing specific to it | **two things** — see sourcing notes | **ring-down time** — nothing damps the swing; see [`PIECE_DESIGNS.md`](PIECE_DESIGNS.md) |

**Nothing is missing from either list.** There is deliberately **no ballast** on
them — no lead, no M3 nuts, no steel balls, and no pocket to glue them into.
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

> **Note if you chose `pivot_type = "magnet"`:** the sensing magnet is then the
> Ø4 × 5 in the piece rather than the Ø8 × 3 in a hub — a smaller magnet, sitting
> the same distance from the sensor. Whether a hall sensor trips reliably on it
> has **not** been checked. The Phase-0 board test tile is where you would find
> out; do that before buying 64 sensors.

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

#### Shared

- **Steel sheet:** must be *ferromagnetic* (mild/galvanized steel — **not**
  stainless 304 or aluminum; test with a fridge magnet before buying). 0.5–1 mm
  is plenty — the magnets, not the sheet, carry the load. Any laser/waterjet
  shop can cut the outline + 64 sensing holes from the exported DXF
  (`make sheet`); a plain hand-cut sheet is fine for Phase 1. The sheet covers
  the 440 mm playing grid and glues centred on the 490 mm printed panel, so the
  25 mm printed border stays visible for the file/rank labels.
- **Silicone damping grease:** the one consumable the design's behaviour
  actually depends on, in **both** architectures. A dab in each bore. Buy
  silicone (damper/plastic-safe) grease, not a dry PTFE lube: PTFE cuts the
  damping you want and leaves the static friction you don't. **Honest caveat:**
  every lean figure quoted anywhere in this repo assumes a friction coefficient
  of **0.08** for greased steel on plastic. That is a textbook number, not one
  measured on this hardware — lean scales **linearly** with it, so if the real
  figure is double, so is every angle. Printing one pawn plus one pivot is what
  settles it.
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

#### `pivot_type = "pin"` only

- **Magnets:** N52 Ø8×3 mm discs are common and cheap; verify polarity is
  consistent when you press them in (mark one face). They press into the **back
  of each hub puck** — the pieces themselves contain no magnet and no metal.
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
- **Felt discs:** ~10 mm self-adhesive, one over each hub magnet. They set the
  glide across the sheet and keep the magnet off the sheet's paint.

#### `pivot_type = "magnet"` only

- **Ø4 × 5 magnets:** the piece turns *on* this magnet, so it is the `r` in
  `sin(lean) = mu · r / d` as well as the thing gripping the sheet. Ø5 was
  modelled too and is worse on both counts (pawn 2.27° vs 1.80°, king 1.73° vs
  1.40°), so **buy Ø4**. Keep polarity consistent and mark a face, same as
  before — it matters for Phase-2 sensing.
- **Ø9 × 0.8 steel discs:** buy plain **solid** discs (sold as magnet "keeper"
  discs, or as steel shim discs), not washers. A washer's centre hole would sit
  directly over the magnet's pole, which is where the grip is strongest. They
  must be ferromagnetic — mild steel, not stainless 304 or aluminum. Test one
  with a fridge magnet before buying 40.
- **TWO THINGS ABOUT THIS ARCHITECTURE ARE UNPROVEN**, and neither is inside any
  lean figure quoted here:
  1. Nothing has verified that a Ø9 steel disc actually **stays put** on a Ø4
     magnet through a board flip. If it walks off, the piece comes off with it.
  2. The disc bears on the counterbore floor and therefore presses the piece's
     **whole back face** onto the steel sheet with the magnet's full pull. So
     rotation has to overcome **face** friction out at silhouette radii, not
     just bore friction at r = 2.35 mm. Every `"magnet"` lean figure models bore
     friction only and is therefore **optimistic**. (Under `"pin"` the piece
     bears on the hub puck's Ø11.5 face under its own weight only, so the same
     objection does not apply there.)

  Both are settled by one ~2 g print: `make gimbal` under `pivot_type =
  "magnet"` gives you the **pivot test coupon**. Do that before ordering 40 of
  anything.
- **Glide and paint:** there is no felt disc in this architecture — the magnet
  is modelled flush with the piece's back face so it touches the steel with no
  plastic in the gap, which means the piece's own plastic face slides on the
  sheet's paint. Nothing has tested how that wears, or whether the paint needs a
  clear coat. Add it to what the coupon test tells you.

#### `pivot_type = "bearing"` only

- **MR63ZZ, Ø3 × Ø6 × 2.5 mm:** a standard miniature deep-groove size, sold by
  RC-hobby and skate-bearing suppliers by the ten. Buy **ZZ (metal shields)**,
  not **2RS (rubber contact seals)** — a rubber lip is a sliding contact, which
  puts static friction right back at the pivot this architecture exists to
  clear. **Do not degrease them:** the light factory fill inside the shields is
  the *only* damping the pivot has. ABEC grade is irrelevant at these speeds;
  buy the cheap ones.
- **Buy one before forty.** Press it into one printed pawn: the seat
  (`pivot_bearing_seat_fit` in `common.scad`) has to grip the outer race
  without splitting, and the flip test has to show acceptable **ring-down** —
  the swing has nothing but the shields' grease to stop it. Both answers come
  from one pawn, one bearing, and the same hub + cap pair as `"pin"`.
