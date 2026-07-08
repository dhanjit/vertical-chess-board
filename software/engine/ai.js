/*
 * ai.js — a small chess opponent for the "board plays you automatically" mode.
 *
 * This is deliberately lightweight: negamax with alpha-beta pruning plus a
 * material + piece-square evaluation. It is strong enough to be a fun living
 * room opponent and small enough to run on a phone (the control app) or even
 * an ESP32-class microcontroller if you later move the brain onto the board.
 *
 * Depth 2-3 plays instantly; depth 4 is a second or two in a browser.
 */

const PIECE_VALUE = { p: 100, n: 320, b: 330, r: 500, q: 900, k: 20000 };

// Piece-square tables from White's point of view (index 0 = a8 .. 63 = h1),
// matching chess.js board ordering. Encourage sensible development.
const PST = {
  p: [
     0,  0,  0,  0,  0,  0,  0,  0,
    50, 50, 50, 50, 50, 50, 50, 50,
    10, 10, 20, 30, 30, 20, 10, 10,
     5,  5, 10, 25, 25, 10,  5,  5,
     0,  0,  0, 20, 20,  0,  0,  0,
     5, -5,-10,  0,  0,-10, -5,  5,
     5, 10, 10,-20,-20, 10, 10,  5,
     0,  0,  0,  0,  0,  0,  0,  0,
  ],
  n: [
    -50,-40,-30,-30,-30,-30,-40,-50,
    -40,-20,  0,  0,  0,  0,-20,-40,
    -30,  0, 10, 15, 15, 10,  0,-30,
    -30,  5, 15, 20, 20, 15,  5,-30,
    -30,  0, 15, 20, 20, 15,  0,-30,
    -30,  5, 10, 15, 15, 10,  5,-30,
    -40,-20,  0,  5,  5,  0,-20,-40,
    -50,-40,-30,-30,-30,-30,-40,-50,
  ],
  b: [
    -20,-10,-10,-10,-10,-10,-10,-20,
    -10,  0,  0,  0,  0,  0,  0,-10,
    -10,  0,  5, 10, 10,  5,  0,-10,
    -10,  5,  5, 10, 10,  5,  5,-10,
    -10,  0, 10, 10, 10, 10,  0,-10,
    -10, 10, 10, 10, 10, 10, 10,-10,
    -10,  5,  0,  0,  0,  0,  5,-10,
    -20,-10,-10,-10,-10,-10,-10,-20,
  ],
  r: [
     0,  0,  0,  0,  0,  0,  0,  0,
     5, 10, 10, 10, 10, 10, 10,  5,
    -5,  0,  0,  0,  0,  0,  0, -5,
    -5,  0,  0,  0,  0,  0,  0, -5,
    -5,  0,  0,  0,  0,  0,  0, -5,
    -5,  0,  0,  0,  0,  0,  0, -5,
    -5,  0,  0,  0,  0,  0,  0, -5,
     0,  0,  0,  5,  5,  0,  0,  0,
  ],
  q: [
    -20,-10,-10, -5, -5,-10,-10,-20,
    -10,  0,  0,  0,  0,  0,  0,-10,
    -10,  0,  5,  5,  5,  5,  0,-10,
     -5,  0,  5,  5,  5,  5,  0, -5,
      0,  0,  5,  5,  5,  5,  0, -5,
    -10,  5,  5,  5,  5,  5,  0,-10,
    -10,  0,  5,  0,  0,  0,  0,-10,
    -20,-10,-10, -5, -5,-10,-10,-20,
  ],
  k: [
    -30,-40,-40,-50,-50,-40,-40,-30,
    -30,-40,-40,-50,-50,-40,-40,-30,
    -30,-40,-40,-50,-50,-40,-40,-30,
    -30,-40,-40,-50,-50,-40,-40,-30,
    -20,-30,-30,-40,-40,-30,-30,-20,
    -10,-20,-20,-20,-20,-20,-20,-10,
     20, 20,  0,  0,  0,  0, 20, 20,
     20, 30, 10,  0,  0, 10, 30, 20,
  ],
};

function mirror(i) {
  // Reflect a square vertically so we can reuse White's tables for Black.
  const rank = Math.floor(i / 8);
  const file = i % 8;
  return (7 - rank) * 8 + file;
}

function evaluate(game) {
  let score = 0;
  for (let i = 0; i < 64; i++) {
    const p = game.board[i];
    if (!p) continue;
    const base = PIECE_VALUE[p.type];
    const positional = p.color === 'w' ? PST[p.type][i] : PST[p.type][mirror(i)];
    const val = base + positional;
    score += p.color === 'w' ? val : -val;
  }
  return score; // positive favors White
}

// Move ordering: try captures first (MVV-LVA-ish) to help pruning.
function orderMoves(moves) {
  return moves.slice().sort((a, b) => {
    const av = a.captured ? PIECE_VALUE[a.captured] - PIECE_VALUE[a.piece] / 10 : 0;
    const bv = b.captured ? PIECE_VALUE[b.captured] - PIECE_VALUE[b.piece] / 10 : 0;
    return bv - av;
  });
}

function negamax(game, depth, alpha, beta, colorSign) {
  if (depth === 0) return colorSign * evaluate(game);

  const moves = game.legalMoves();
  if (moves.length === 0) {
    // Checkmate is very bad; stalemate is neutral.
    if (game.inCheck(game.turn)) return -100000 - depth; // prefer faster mates
    return 0;
  }

  let best = -Infinity;
  for (const m of orderMoves(moves)) {
    const snap = game._apply(m);
    const savedTurn = game.turn;
    game.turn = (game.turn === 'w') ? 'b' : 'w';
    const val = -negamax(game, depth - 1, -beta, -alpha, -colorSign);
    game.turn = savedTurn;
    game._undo(snap);
    if (val > best) best = val;
    if (best > alpha) alpha = best;
    if (alpha >= beta) break; // beta cutoff
  }
  return best;
}

/*
 * Choose the engine's move for the side to move.
 * options.depth  — search depth (default 3)
 * options.random — add tiny noise so equal-value games vary (default true)
 * Returns a legal move object (from game.legalMoves()) or null if none.
 */
function chooseMove(game, options = {}) {
  const depth = options.depth ?? 3;
  const useRandom = options.random ?? true;
  const colorSign = game.turn === 'w' ? 1 : -1;

  const moves = orderMoves(game.legalMoves());
  if (moves.length === 0) return null;

  let bestMove = moves[0];
  let bestVal = -Infinity;
  for (const m of moves) {
    const snap = game._apply(m);
    const savedTurn = game.turn;
    game.turn = (game.turn === 'w') ? 'b' : 'w';
    let val = -negamax(game, depth - 1, -Infinity, Infinity, -colorSign);
    game.turn = savedTurn;
    game._undo(snap);
    if (useRandom) val += (m.to * 7 + m.from * 3) % 5; // deterministic jitter, no Math.random
    if (val > bestVal) {
      bestVal = val;
      bestMove = m;
    }
  }
  return bestMove;
}

if (typeof module !== 'undefined' && module.exports) {
  module.exports = { chooseMove, evaluate };
}
