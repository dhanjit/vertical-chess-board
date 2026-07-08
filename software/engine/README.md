# Engine — the board's brain

Plain-JavaScript, dependency-free chess **rules engine** and **AI opponent**.
This is the shared brain that will run in the board firmware (Phase 2), drive
the auto-mover (Phase 3), and back the control app (Phase 4).

## Files

- **`chess.js`** — full rules: legal move generation, check / checkmate /
  stalemate, castling, en passant, promotion, SAN notation, and draw
  detection (threefold repetition, fifty-move, insufficient material).
- **`ai.js`** — opponent: negamax + alpha-beta pruning with a material +
  piece-square evaluation. `chooseMove(game, {depth})` returns a move.

## When to use this vs. a real engine

This engine is **dependency-free and tiny** — ideal for on-board move
validation or a gentle opponent on a microcontroller. For a genuinely *strong*
opponent, don't extend `ai.js` — run **Stockfish** (the world's best,
open-source) and set its skill level. If you'd rather use a maintained rules
library than our `chess.js`, the original **chess.js** (npm, BSD) is a drop-in.
See [`../../docs/OPEN_SOURCE.md`](../../docs/OPEN_SOURCE.md) for the full reuse
map.

## Correctness

Move generation is verified with **perft** from the start position:

| depth | nodes | expected |
|------:|------:|---------:|
| 1 | 20 | 20 ✅ |
| 2 | 400 | 400 ✅ |
| 3 | 8902 | 8902 ✅ |

## Quick use

```js
const { Chess } = require('./chess.js');
const { chooseMove } = require('./ai.js');

const g = new Chess();
console.log(g.legalMoves().length);      // 20

// Squares are indices; helpers convert names.
const from = /* e2 */ 6*8 + 4, to = /* e4 */ 4*8 + 4;
g.move({ from, to });                      // play e4
console.log(g.history.at(-1).san);         // "e4"

const reply = chooseMove(g, { depth: 3 }); // engine picks Black's move
g.move(reply);

console.log(g.status());                   // { over, result, reason }
```

## Board representation

Flat 64-array, index `0 = a8 … 63 = h1` (rank 8 first, files a→h). Pieces are
`{ type: 'p'|'n'|'b'|'r'|'q'|'k', color: 'w'|'b' }`. Helpers `Chess.idx`,
`Chess.squareName`, `Chess.fileOf/rankOf` map to/from square names — the same
indexing the hardware uses for the 8×8 sensor grid, so firmware and engine
speak the same coordinates.

## Notes for firmware

- The engine is authoritative over game *rules*; the sensor grid reports
  *occupancy changes*. Match a lift→place against `legalMoves()` to commit a
  move (see [`../../docs/ELECTRONICS.md`](../../docs/ELECTRONICS.md)).
- `ai.js` depth 2–3 is instant; depth 4 is ~1–2 s in a browser. On an ESP32,
  either transpile the algorithms to C++ or run a trimmed depth.
- No `Math.random` is used (deterministic), so replays and tests are stable.
