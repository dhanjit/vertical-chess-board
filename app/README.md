# Control App (Phase 4 — spec only)

Future phone/tablet app to control the board. **Nothing is built yet** — this
captures intent so we design toward it.

## What it does

- **Pair** with the board over **BLE** (setup) / **Wi-Fi** (gameplay, updates).
- **Play the machine:** pick difficulty (maps to `ai.js` search depth/eval),
  request hints, take back moves.
- **Follow along:** live board mirror, move list (SAN/PGN), clocks, captures.
- **Two-player helpers:** clock, auto-rotate on/off, illegal-move nudges.
- **Setup:** "set position" flow (resolve piece-identity ambiguity the sensors
  can't), calibrate rotation home, sensor diagnostics.
- **Extras:** PGN export/import, puzzles, "mirror an online game on the wall."

## Shared brain

The app and the board run the **same logic** already in this repo:
- [`software/engine/chess.js`](../software/engine/chess.js) — rules/state,
- [`software/engine/ai.js`](../software/engine/ai.js) — opponent.

Keeping one engine means the app can validate/preview locally and the board
stays authoritative over the physical state.

## Suggested stack

- **App:** React Native or Flutter (cross-platform); reuse the JS engine
  directly in RN.
- **Transport:** BLE GATT for control + a compact state characteristic; switch
  to Wi-Fi/WebSocket for firmware updates and online play.
- **Protocol:** small JSON/CBOR messages — `state`, `move`, `rotate`,
  `set_difficulty`, `home`, `diagnostics`.

## Open questions

- Difficulty curve — how depth/eval map to "beginner … club player."
- Online play — direct, or through a tiny relay service?
- Do we need an account/cloud, or keep it fully local? (privacy-friendly local
  default preferred)
