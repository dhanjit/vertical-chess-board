/*
 * chess.js — a self-contained chess rules engine.
 *
 * Board representation: a flat array of 64 squares, index 0 = a8, index 63 = h1
 * (i.e. rank 8 first, files a..h left to right — the way you'd read a diagram).
 * Each square is either null or a piece object: { type, color }
 *   type:  'p' | 'n' | 'b' | 'r' | 'q' | 'k'
 *   color: 'w' | 'b'
 *
 * The engine generates fully legal moves (it filters out moves that leave the
 * mover in check) and knows about castling, en passant and promotion.
 */

const FILES = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

function idx(file, rank) {
  // file: 0..7 (a..h), rank: 0..7 (rank 8 == 0, rank 1 == 7)
  return rank * 8 + file;
}
function fileOf(i) { return i % 8; }
function rankOf(i) { return Math.floor(i / 8); }
function onBoard(file, rank) { return file >= 0 && file < 8 && rank >= 0 && rank < 8; }

function squareName(i) {
  return FILES[fileOf(i)] + (8 - rankOf(i));
}

class Chess {
  constructor() {
    this.reset();
  }

  reset() {
    const back = ['r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'];
    this.board = new Array(64).fill(null);
    for (let f = 0; f < 8; f++) {
      this.board[idx(f, 0)] = { type: back[f], color: 'b' };
      this.board[idx(f, 1)] = { type: 'p', color: 'b' };
      this.board[idx(f, 6)] = { type: 'p', color: 'w' };
      this.board[idx(f, 7)] = { type: back[f], color: 'w' };
    }
    this.turn = 'w';
    // Castling rights.
    this.castling = { w: { k: true, q: true }, b: { k: true, q: true } };
    // En passant target square index, or null.
    this.enPassant = null;
    this.halfmoveClock = 0;   // for the 50-move rule
    this.fullmove = 1;
    this.history = [];        // list of move records (SAN + metadata)
    this._positions = {};     // repetition counting keyed by position signature
    this._recordPosition();
  }

  clone() {
    const c = new Chess();
    c.board = this.board.map((p) => (p ? { type: p.type, color: p.color } : null));
    c.turn = this.turn;
    c.castling = {
      w: { k: this.castling.w.k, q: this.castling.w.q },
      b: { k: this.castling.b.k, q: this.castling.b.q },
    };
    c.enPassant = this.enPassant;
    c.halfmoveClock = this.halfmoveClock;
    c.fullmove = this.fullmove;
    c.history = this.history.slice();
    c._positions = Object.assign({}, this._positions);
    return c;
  }

  get(i) { return this.board[i]; }

  static other(color) { return color === 'w' ? 'b' : 'w'; }

  // ---- Attack / check detection -------------------------------------------

  // Is square `i` attacked by any piece of `color`?
  isAttacked(i, color) {
    const tf = fileOf(i);
    const tr = rankOf(i);

    // Pawn attacks. A white pawn on (f,r) attacks (f±1, r-1).
    const pawnDir = color === 'w' ? 1 : -1; // white pawns come from a higher rank number
    for (const df of [-1, 1]) {
      const pf = tf + df;
      const pr = tr + pawnDir;
      if (onBoard(pf, pr)) {
        const p = this.board[idx(pf, pr)];
        if (p && p.color === color && p.type === 'p') return true;
      }
    }

    // Knight attacks.
    const knight = [[1, 2], [2, 1], [-1, 2], [-2, 1], [1, -2], [2, -1], [-1, -2], [-2, -1]];
    for (const [df, dr] of knight) {
      const nf = tf + df, nr = tr + dr;
      if (onBoard(nf, nr)) {
        const p = this.board[idx(nf, nr)];
        if (p && p.color === color && p.type === 'n') return true;
      }
    }

    // King attacks (adjacent).
    for (let df = -1; df <= 1; df++) {
      for (let dr = -1; dr <= 1; dr++) {
        if (df === 0 && dr === 0) continue;
        const kf = tf + df, kr = tr + dr;
        if (onBoard(kf, kr)) {
          const p = this.board[idx(kf, kr)];
          if (p && p.color === color && p.type === 'k') return true;
        }
      }
    }

    // Sliding attacks: rook/queen (orthogonal), bishop/queen (diagonal).
    const ortho = [[1, 0], [-1, 0], [0, 1], [0, -1]];
    const diag = [[1, 1], [1, -1], [-1, 1], [-1, -1]];
    const scan = (dirs, types) => {
      for (const [df, dr] of dirs) {
        let f = tf + df, r = tr + dr;
        while (onBoard(f, r)) {
          const p = this.board[idx(f, r)];
          if (p) {
            if (p.color === color && types.includes(p.type)) return true;
            break;
          }
          f += df; r += dr;
        }
      }
      return false;
    };
    if (scan(ortho, ['r', 'q'])) return true;
    if (scan(diag, ['b', 'q'])) return true;

    return false;
  }

  kingSquare(color) {
    for (let i = 0; i < 64; i++) {
      const p = this.board[i];
      if (p && p.type === 'k' && p.color === color) return i;
    }
    return -1;
  }

  inCheck(color) {
    const k = this.kingSquare(color);
    if (k < 0) return false;
    return this.isAttacked(k, Chess.other(color));
  }

  // ---- Move generation -----------------------------------------------------

  // Pseudo-legal moves (may leave own king in check). Each move:
  // { from, to, piece, captured, promotion, flag }
  // flag: '' | 'double' | 'ep' | 'kside' | 'qside'
  _pseudoMoves(color) {
    const moves = [];
    for (let i = 0; i < 64; i++) {
      const p = this.board[i];
      if (!p || p.color !== color) continue;
      const f = fileOf(i), r = rankOf(i);

      if (p.type === 'p') {
        const dir = color === 'w' ? -1 : 1; // white pawns move toward rank 8 (lower rank index)
        const startRank = color === 'w' ? 6 : 1;
        const promoRank = color === 'w' ? 0 : 7;

        // Forward one.
        const r1 = r + dir;
        if (onBoard(f, r1) && !this.board[idx(f, r1)]) {
          this._addPawnMove(moves, i, idx(f, r1), color, promoRank, '');
          // Forward two.
          const r2 = r + 2 * dir;
          if (r === startRank && !this.board[idx(f, r2)]) {
            moves.push({ from: i, to: idx(f, r2), piece: 'p', captured: null, promotion: null, flag: 'double' });
          }
        }
        // Captures.
        for (const df of [-1, 1]) {
          const cf = f + df, cr = r + dir;
          if (!onBoard(cf, cr)) continue;
          const target = idx(cf, cr);
          const tp = this.board[target];
          if (tp && tp.color !== color) {
            this._addPawnMove(moves, i, target, color, promoRank, '', tp);
          } else if (target === this.enPassant) {
            moves.push({ from: i, to: target, piece: 'p', captured: 'p', promotion: null, flag: 'ep' });
          }
        }
      } else if (p.type === 'n') {
        const jumps = [[1, 2], [2, 1], [-1, 2], [-2, 1], [1, -2], [2, -1], [-1, -2], [-2, -1]];
        for (const [df, dr] of jumps) {
          const nf = f + df, nr = r + dr;
          if (!onBoard(nf, nr)) continue;
          const t = idx(nf, nr);
          const tp = this.board[t];
          if (!tp || tp.color !== color) {
            moves.push({ from: i, to: t, piece: 'n', captured: tp ? tp.type : null, promotion: null, flag: '' });
          }
        }
      } else if (p.type === 'k') {
        for (let df = -1; df <= 1; df++) {
          for (let dr = -1; dr <= 1; dr++) {
            if (df === 0 && dr === 0) continue;
            const nf = f + df, nr = r + dr;
            if (!onBoard(nf, nr)) continue;
            const t = idx(nf, nr);
            const tp = this.board[t];
            if (!tp || tp.color !== color) {
              moves.push({ from: i, to: t, piece: 'k', captured: tp ? tp.type : null, promotion: null, flag: '' });
            }
          }
        }
        this._addCastling(moves, color);
      } else {
        // Sliding pieces.
        let dirs;
        if (p.type === 'r') dirs = [[1, 0], [-1, 0], [0, 1], [0, -1]];
        else if (p.type === 'b') dirs = [[1, 1], [1, -1], [-1, 1], [-1, -1]];
        else dirs = [[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [1, -1], [-1, 1], [-1, -1]];
        for (const [df, dr] of dirs) {
          let nf = f + df, nr = r + dr;
          while (onBoard(nf, nr)) {
            const t = idx(nf, nr);
            const tp = this.board[t];
            if (!tp) {
              moves.push({ from: i, to: t, piece: p.type, captured: null, promotion: null, flag: '' });
            } else {
              if (tp.color !== color) {
                moves.push({ from: i, to: t, piece: p.type, captured: tp.type, promotion: null, flag: '' });
              }
              break;
            }
            nf += df; nr += dr;
          }
        }
      }
    }
    return moves;
  }

  _addPawnMove(moves, from, to, color, promoRank, flag, captured) {
    const capturedType = captured ? captured.type : null;
    if (rankOf(to) === promoRank) {
      for (const promo of ['q', 'r', 'b', 'n']) {
        moves.push({ from, to, piece: 'p', captured: capturedType, promotion: promo, flag });
      }
    } else {
      moves.push({ from, to, piece: 'p', captured: capturedType, promotion: null, flag });
    }
  }

  _addCastling(moves, color) {
    const rights = this.castling[color];
    if (!rights.k && !rights.q) return;
    if (this.inCheck(color)) return;
    const rank = color === 'w' ? 7 : 0;
    const enemy = Chess.other(color);
    const kingFrom = idx(4, rank);

    // King-side: squares f,g must be empty and not attacked; rook on h.
    if (rights.k) {
      const fSq = idx(5, rank), gSq = idx(6, rank), hSq = idx(7, rank);
      const rook = this.board[hSq];
      if (!this.board[fSq] && !this.board[gSq] &&
          rook && rook.type === 'r' && rook.color === color &&
          !this.isAttacked(fSq, enemy) && !this.isAttacked(gSq, enemy)) {
        moves.push({ from: kingFrom, to: gSq, piece: 'k', captured: null, promotion: null, flag: 'kside' });
      }
    }
    // Queen-side: squares b,c,d empty; c,d not attacked; rook on a.
    if (rights.q) {
      const bSq = idx(1, rank), cSq = idx(2, rank), dSq = idx(3, rank), aSq = idx(0, rank);
      const rook = this.board[aSq];
      if (!this.board[bSq] && !this.board[cSq] && !this.board[dSq] &&
          rook && rook.type === 'r' && rook.color === color &&
          !this.isAttacked(cSq, enemy) && !this.isAttacked(dSq, enemy)) {
        moves.push({ from: kingFrom, to: cSq, piece: 'k', captured: null, promotion: null, flag: 'qside' });
      }
    }
  }

  // Legal moves for the side to move (or a given color).
  legalMoves(color = this.turn) {
    const pseudo = this._pseudoMoves(color);
    const legal = [];
    for (const m of pseudo) {
      const snapshot = this._apply(m);
      if (!this.inCheck(color)) legal.push(m);
      this._undo(snapshot);
    }
    return legal;
  }

  legalMovesFrom(from) {
    return this.legalMoves().filter((m) => m.from === from);
  }

  // ---- Applying moves ------------------------------------------------------

  // Apply a move to the board WITHOUT switching turn or bookkeeping SAN.
  // Returns a snapshot used by _undo. Used internally for legality checks.
  _apply(m) {
    const snapshot = {
      move: m,
      fromPiece: this.board[m.from],
      toPiece: this.board[m.to],
      enPassant: this.enPassant,
      castling: {
        w: { k: this.castling.w.k, q: this.castling.w.q },
        b: { k: this.castling.b.k, q: this.castling.b.q },
      },
      epCapturedIndex: null,
      epCapturedPiece: null,
      rookFrom: null,
      rookTo: null,
      rookPiece: null,
    };
    const piece = this.board[m.from];
    const color = piece.color;

    this.board[m.to] = m.promotion ? { type: m.promotion, color } : piece;
    this.board[m.from] = null;

    if (m.flag === 'ep') {
      const dir = color === 'w' ? 1 : -1; // captured pawn sits "behind" the ep square
      const capIndex = idx(fileOf(m.to), rankOf(m.to) + dir);
      snapshot.epCapturedIndex = capIndex;
      snapshot.epCapturedPiece = this.board[capIndex];
      this.board[capIndex] = null;
    } else if (m.flag === 'kside' || m.flag === 'qside') {
      const rank = color === 'w' ? 7 : 0;
      if (m.flag === 'kside') {
        snapshot.rookFrom = idx(7, rank);
        snapshot.rookTo = idx(5, rank);
      } else {
        snapshot.rookFrom = idx(0, rank);
        snapshot.rookTo = idx(3, rank);
      }
      snapshot.rookPiece = this.board[snapshot.rookFrom];
      this.board[snapshot.rookTo] = snapshot.rookPiece;
      this.board[snapshot.rookFrom] = null;
    }

    // Update en passant target (only set on a double pawn push).
    if (m.flag === 'double') {
      const dir = color === 'w' ? -1 : 1;
      this.enPassant = idx(fileOf(m.from), rankOf(m.from) + dir);
    } else {
      this.enPassant = null;
    }

    // Update castling rights.
    if (piece.type === 'k') {
      this.castling[color].k = false;
      this.castling[color].q = false;
    }
    const touchRook = (sq, col) => {
      const rank = col === 'w' ? 7 : 0;
      if (sq === idx(0, rank)) this.castling[col].q = false;
      if (sq === idx(7, rank)) this.castling[col].k = false;
    };
    if (piece.type === 'r') touchRook(m.from, color);
    // If a rook is captured on its home square, the opponent loses that right.
    if (m.captured === 'r') touchRook(m.to, Chess.other(color));

    return snapshot;
  }

  _undo(snapshot) {
    const m = snapshot.move;
    this.board[m.from] = snapshot.fromPiece;
    this.board[m.to] = snapshot.toPiece;
    if (snapshot.epCapturedIndex !== null) {
      this.board[snapshot.epCapturedIndex] = snapshot.epCapturedPiece;
    }
    if (snapshot.rookFrom !== null) {
      this.board[snapshot.rookFrom] = snapshot.rookPiece;
      this.board[snapshot.rookTo] = null;
    }
    this.enPassant = snapshot.enPassant;
    this.castling = snapshot.castling;
  }

  // Find the legal move matching from/to (+ optional promotion). Returns it or null.
  findMove(from, to, promotion) {
    const legal = this.legalMoves();
    const matches = legal.filter((m) => m.from === from && m.to === to);
    if (matches.length === 0) return null;
    if (matches[0].promotion) {
      return matches.find((m) => m.promotion === (promotion || 'q')) || null;
    }
    return matches[0];
  }

  // Play a move (mutating the game). Accepts a move object from legalMoves()
  // or a {from,to,promotion}. Returns the move record (with SAN) or null.
  move(input) {
    let m = input;
    if (!('flag' in input)) {
      m = this.findMove(input.from, input.to, input.promotion);
      if (!m) return null;
    }
    const color = this.turn;
    const san = this._san(m);

    this._apply(m);

    // Half-move clock for the 50-move rule.
    if (m.piece === 'p' || m.captured) this.halfmoveClock = 0;
    else this.halfmoveClock++;

    if (color === 'b') this.fullmove++;
    this.turn = Chess.other(color);

    const record = {
      ...m,
      color,
      san,
      fromName: squareName(m.from),
      toName: squareName(m.to),
    };
    this.history.push(record);
    this._recordPosition();
    return record;
  }

  // ---- Status --------------------------------------------------------------

  isCheckmate() {
    return this.inCheck(this.turn) && this.legalMoves().length === 0;
  }
  isStalemate() {
    return !this.inCheck(this.turn) && this.legalMoves().length === 0;
  }
  isThreefoldRepetition() {
    return Object.values(this._positions).some((n) => n >= 3);
  }
  isFiftyMoveRule() {
    return this.halfmoveClock >= 100;
  }
  isInsufficientMaterial() {
    const pieces = this.board.filter(Boolean);
    const nonKings = pieces.filter((p) => p.type !== 'k');
    if (nonKings.length === 0) return true; // K vs K
    if (nonKings.length === 1 && (nonKings[0].type === 'b' || nonKings[0].type === 'n')) return true; // K+minor vs K
    if (nonKings.length === 2 && nonKings.every((p) => p.type === 'b')) {
      // K+B vs K+B — draw only if bishops are same color complex.
      const squares = [];
      for (let i = 0; i < 64; i++) {
        const p = this.board[i];
        if (p && p.type === 'b') squares.push((fileOf(i) + rankOf(i)) % 2);
      }
      if (squares.length === 2 && squares[0] === squares[1]) return true;
    }
    return false;
  }

  isDraw() {
    return this.isStalemate() || this.isThreefoldRepetition() ||
      this.isFiftyMoveRule() || this.isInsufficientMaterial();
  }
  isGameOver() {
    return this.isCheckmate() || this.isDraw();
  }

  status() {
    if (this.isCheckmate()) {
      return { over: true, result: Chess.other(this.turn), reason: 'checkmate' };
    }
    if (this.isStalemate()) return { over: true, result: 'draw', reason: 'stalemate' };
    if (this.isThreefoldRepetition()) return { over: true, result: 'draw', reason: 'threefold repetition' };
    if (this.isFiftyMoveRule()) return { over: true, result: 'draw', reason: 'fifty-move rule' };
    if (this.isInsufficientMaterial()) return { over: true, result: 'draw', reason: 'insufficient material' };
    return { over: false, result: null, reason: this.inCheck(this.turn) ? 'check' : null };
  }

  // ---- SAN notation --------------------------------------------------------

  _san(m) {
    if (m.flag === 'kside') return this._checkSuffix(m, 'O-O');
    if (m.flag === 'qside') return this._checkSuffix(m, 'O-O-O');

    const piece = this.board[m.from];
    let san = '';
    if (piece.type === 'p') {
      if (m.captured || m.flag === 'ep') san += FILES[fileOf(m.from)] + 'x';
      san += squareName(m.to);
      if (m.promotion) san += '=' + m.promotion.toUpperCase();
    } else {
      san += piece.type.toUpperCase();
      san += this._disambiguation(m);
      if (m.captured) san += 'x';
      san += squareName(m.to);
    }
    return this._checkSuffix(m, san);
  }

  _disambiguation(m) {
    const piece = this.board[m.from];
    const others = this._pseudoMoves(piece.color).filter(
      (o) => o.to === m.to && o.from !== m.from &&
        this.board[o.from] && this.board[o.from].type === piece.type
    );
    // Only keep truly legal alternatives.
    const legalOthers = others.filter((o) => {
      const snap = this._apply(o);
      const ok = !this.inCheck(piece.color);
      this._undo(snap);
      return ok;
    });
    if (legalOthers.length === 0) return '';
    const sameFile = legalOthers.some((o) => fileOf(o.from) === fileOf(m.from));
    const sameRank = legalOthers.some((o) => rankOf(o.from) === rankOf(m.from));
    if (!sameFile) return FILES[fileOf(m.from)];
    if (!sameRank) return String(8 - rankOf(m.from));
    return squareName(m.from);
  }

  _checkSuffix(m, san) {
    const snap = this._apply(m);
    const opponent = Chess.other(this.board[m.to].color);
    let suffix = '';
    if (this.inCheck(opponent)) {
      suffix = this.legalMoves(opponent).length === 0 ? '#' : '+';
    }
    this._undo(snap);
    return san + suffix;
  }

  // ---- Position signature (for repetition) ---------------------------------

  _signature() {
    let s = '';
    for (let i = 0; i < 64; i++) {
      const p = this.board[i];
      s += p ? (p.color === 'w' ? p.type.toUpperCase() : p.type) : '.';
    }
    s += '|' + this.turn;
    s += '|' + (this.castling.w.k ? 'K' : '') + (this.castling.w.q ? 'Q' : '') +
      (this.castling.b.k ? 'k' : '') + (this.castling.b.q ? 'q' : '');
    s += '|' + (this.enPassant === null ? '-' : this.enPassant);
    return s;
  }

  _recordPosition() {
    const sig = this._signature();
    this._positions[sig] = (this._positions[sig] || 0) + 1;
  }
}

// Expose helpers alongside the class.
Chess.idx = idx;
Chess.fileOf = fileOf;
Chess.rankOf = rankOf;
Chess.squareName = squareName;
Chess.FILES = FILES;

if (typeof module !== 'undefined' && module.exports) {
  module.exports = { Chess, idx, fileOf, rankOf, squareName, FILES };
}
