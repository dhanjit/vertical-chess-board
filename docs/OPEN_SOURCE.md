# Don't reinvent it — open-source you can reuse

Good news: **almost all the hard electronics + software already exists as
open-source projects.** The only genuinely *new* thing about our board is the
**mechanical** idea — vertical, rotates by turn, gravity-upright magnetic
pieces. Nobody has open-sourced that. But the parts people *think* are hard —
sensing the pieces, a strong computer opponent, moving pieces automatically,
playing online — are all **solved**, and most are free to copy.

**Strategy:** keep our unique mechanical design (this repo), and for each
electronic phase, **fork/adapt an existing project instead of writing firmware
from scratch.** This turns Phases 2–4 from "invent it" into "port it."

> ⚠️ Licenses vary (MIT/BSD = do anything; **GPL** = you must share your
> source if you distribute; some repos list none — ask/assume all-rights-
> reserved until clarified). Fine for a personal build; check before selling.

---

## The brain (a computer opponent) — reuse, don't hand-roll

Our [`software/engine/`](../software/engine) (`chess.js` + `ai.js`) is a nice
**dependency-free** rules engine + light opponent — great for running on a
tiny microcontroller or validating moves. But for a genuinely *strong*
opponent, use a real engine:

| Project | What it is | License | Use for |
|---|---|---|---|
| **[Stockfish](https://github.com/official-stockfish/Stockfish)** | The strongest open-source chess engine on earth. Runs on a Pi/phone. | GPL | the actual opponent (adjustable strength) |
| **[stockfish.js](https://github.com/nmrugg/stockfish.js)** | Stockfish compiled to run in a browser / phone app (WASM) | GPL | the app's opponent, offline |
| **[chess.js](https://github.com/jhlywa/chess.js)** | The battle-tested JS rules library our `chess.js` reimplements | BSD | swap in if you'd rather use a maintained lib |
| **[python-chess](https://github.com/niklasf/python-chess)** | Comprehensive Python chess library | GPL | if the brain runs on a Raspberry Pi in Python |
| **[PicoChess](https://github.com/JohanSjoblom/picochess)** | A whole "chess computer" for Raspberry Pi: bundles engines (Stockfish, Lc0), **e-board support**, web UI, clock, opening books | GPL | get the *entire* brain + web app for free if our board speaks a supported protocol |

**Takeaway:** for a strong opponent, don't extend `ai.js` — run **Stockfish**
and set its skill level. Keep `chess.js` for on-board move validation if useful.

---

## Phase 2 (senses pieces, no motors) — copy a smart board

These detect where pieces are with hall sensors and light up legal moves /
play an engine. Closest to our Phase 2, and directly reusable wiring + firmware:

| Project | Highlights | License | Why it's relevant |
|---|---|---|---|
| **[Open-Chess (Concept Bytes)](https://github.com/Concept-Bytes/Open-Chess)** | Arduino + 64 hall sensors + NeoPixel LEDs + Stockfish over Wi-Fi. **Very well documented, build videos.** | **MIT** | **Best starting point for our Phase 2** — permissive license, beginner-friendly, same sensor idea. |
| **[eChess](https://github.com/aherve/eChess)** | Hall sensors + multiplexers, plays **online via the lichess API** | — | reuse the sensor-scan + lichess-online code |
| **[autopatzer](https://github.com/jes/autopatzer)** | Analog hall + CD4051 muxes; excellent write-up | — | great learning reference for sensing 64 squares cheaply |
| **[chesslr](https://github.com/abathur8bit/chesslr)**, **[ElectronicChessBoard](https://github.com/Hardware7253/ElectronicChessBoard)** | More hall-sensor boards + LEDs | — | extra reference designs |
| **[chess.fortherapy.co.uk](https://chess.fortherapy.co.uk/home/hardware/design-hall-effect-sensors/)** | Full tutorial site on building hall-sensor chess computers | — | step-by-step learning, not code |

**Takeaway:** for our sensing phase, **fork Open-Chess** and adapt the sensor
grid + LED wiring to our panel (we already put a hall sensor behind each
square). It even talks to Stockfish already.

---

## Phase 3 (moves pieces itself) — copy a self-moving board

An electromagnet on a CoreXY gantry behind the board, exactly the mechanism in
[`DESIGN.md` §6](DESIGN.md#6-phase-3--the-board-plays-you-auto-mover-future-scope):

| Project | Highlights | License | Why it's relevant |
|---|---|---|---|
| **[Imperium](https://github.com/DragonRoyal/Imperium)** | T-Bot/CoreXY + 2× NEMA-17 + **64 hall sensors** + electromagnet + ESP32, runs **[FluidNC](https://github.com/bdring/FluidNC)** (G-code). CAD + KiCad PCBs + BOM + videos. | check repo | **Nearly our exact Phase-3 machine.** Horizontal, but the gantry/firmware/PCB port over. |
| **[Mags](https://kogappa.com/projects/mags/)** | Deliberately *thin* CoreXY + reed switches + electromagnet + Stockfish | — | thin gantry ideas (helps a wall-hung board) |
| **[AndChen153/ChessBoard](https://github.com/AndChen153/ChessBoard)**, **[sumit11899/Automated-ChessBoard](https://github.com/sumit11899/Automated-ChessBoard)**, **[Shallow-Blue/AutoChess](https://github.com/Shallow-Blue/AutoChess)** | More self-moving builds | — | additional references/BOMs |

**Motion firmware — don't write it:** use **[FluidNC](https://github.com/bdring/FluidNC)**
(ESP32), **[GRBL](https://github.com/gnea/grbl)** (Arduino), or
**[Marlin](https://github.com/MarlinFirmware/Marlin)** (3D-printer firmware).
You send simple G-code ("move to X,Y; magnet on/off"); the firmware handles the
motors. Imperium already does this.

**Our twist:** all these are **horizontal** (gravity holds pieces down). Ours
is vertical — a gantry only works on the **reclined-gantry fallback** (see
`DESIGN.md §6` and `AUTO_MOVER_DESIGN.md`). We'd reuse their gantry +
firmware + engine and adapt the *holding* scheme. Still a huge head start.

---

## Phase 4 (app + online) — reuse UI + protocols

| Project | What it is | License |
|---|---|---|
| **[lichess Board API](https://lichess.org/api#tag/Board)** | Play real online games from a physical board | free API |
| **[lichess-bot](https://github.com/lichess-bot-devs/lichess-bot)** | Framework to connect an engine/board as a bot | AGPL |
| **[chessground](https://github.com/lichess-org/chessground)** | Lichess's own board UI widget | GPL |
| **[chessboard.js](https://github.com/oakmac/chessboardjs)** | Simple embeddable board UI | MIT |

**Takeaway:** the app's board display and "play online" features are libraries,
not things to build from zero.

---

## What stays uniquely ours

- The **vertical wall** form factor.
- **Rotate-by-turn** on a turntable.
- **Gravity self-righting** magnetic pieces (the pendulum).
- The **parametric printable models** in [`../hardware/`](../hardware).

Everything else — engine, sensing, motion, online — we **borrow**. That's the
efficient path, and it's how most of these projects were built too (nearly all
of them run Stockfish).

---

## Recommended reuse map

| Our phase | Instead of building… | …start from |
|---|---|---|
| Brain / opponent | extending `ai.js` | **Stockfish** (+ `chess.js` for validation) |
| Phase 2 sensing | firmware from scratch | **Open-Chess** (MIT) |
| Phase 3 auto-mover | gantry + motion code | **Imperium** + **FluidNC** |
| Phase 4 app / online | a chess UI + net code | **chessground/chessboard.js** + **lichess API** |

*(Project details/links current as of 2026-07; verify licenses and activity before depending on any repo.)*
