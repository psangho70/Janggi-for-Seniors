// 청춘 장기 AI 자가대국 비교 도구
// 사용법: node selfplay.js <신버전 html> <기준 html> <시작번호> <판수> <한 수당 ms> [최대 반수]
// - 같은 무작위 초반(4반수)과 차림으로 두 판씩 두며, 진영을 바꿔 공정하게 비교합니다.
const fs = require('fs');

function loadEngine(path) {
  const html = fs.readFileSync(path, 'utf8').split(/\r?\n/);
  const start = html.findIndex(l => l.startsWith('const TEAM_CHO'));
  const end = html.findIndex(l => l.startsWith('// [크로스플랫폼 통합 네이티브 브릿지'));
  const code = html.slice(start, end - 1).join('\n');
  return new Function(code + '\nreturn { JanggiGame, JanggiAI, TEAM_CHO, TEAM_HAN, TYPE_KING };')();
}

// 재현 가능한 난수 (Mulberry32)
function rng(seed) {
  return function () {
    seed |= 0; seed = (seed + 0x6D2B79F5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

const [newPath, oldPath, startIdxS, gamesS, msS, maxPliesS] = process.argv.slice(2);
const N = loadEngine(newPath);
const O = loadEngine(oldPath);
const startIdx = parseInt(startIdxS, 10);
const games = parseInt(gamesS, 10);
const ms = parseInt(msS, 10);
const maxPlies = parseInt(maxPliesS || '160', 10);
const LEVEL = process.env.LEVEL || 'hard';
const TEAM_CHO = N.TEAM_CHO, TEAM_HAN = N.TEAM_HAN;

let newWins = 0, oldWins = 0, draws = 0;
const records = [];

for (let i = startIdx; i < startIdx + games; i++) {
  const pair = Math.floor(i / 2);
  const r = rng(1000 + pair);
  const hf = Math.floor(r() * 4), cf = Math.floor(r() * 4);
  const newIsCho = (i % 2 === 0);

  const gN = new N.JanggiGame(); gN.initBoard(hf, cf);
  const gO = new O.JanggiGame(); gO.initBoard(hf, cf);
  const aiN = new N.JanggiAI(gN);
  const aiO = new O.JanggiAI(gO);

  let winner = null, reason = '';
  // 무작위 초반 4반수 (양쪽 동일)
  for (let k = 0; k < 4; k++) {
    const moves = aiN.getAllLegalMoves(gN.currentTurn);
    const m = moves[Math.floor(r() * moves.length)];
    gN.makeMove(m.fromX, m.fromY, m.toX, m.toY);
    gO.makeMove(m.fromX, m.fromY, m.toX, m.toY);
  }

  let ply = 0;
  for (; ply < maxPlies; ply++) {
    const team = gN.currentTurn;
    const useNew = (team === TEAM_CHO) === newIsCho;
    const ai = useNew ? aiN : aiO;
    const m = ai.getBestMove(team, LEVEL, ms);
    if (!m) { winner = team === TEAM_CHO ? TEAM_HAN : TEAM_CHO; reason = '외통(둘 수 없음)'; break; }
    const target = gN.board[m.toY][m.toX];
    gN.makeMove(m.fromX, m.fromY, m.toX, m.toY);
    gO.makeMove(m.fromX, m.fromY, m.toX, m.toY);
    if (target && target.type === N.TYPE_KING) { winner = team; reason = '궁 포획'; break; }
  }
  if (!winner) {
    const s = gN.calculateScores();
    const diff = s.cho - s.han;
    if (Math.abs(diff) < 3) { reason = `수 제한 무승부(${s.cho}:${s.han})`; }
    else { winner = diff > 0 ? TEAM_CHO : TEAM_HAN; reason = `수 제한 점수판정(${s.cho}:${s.han})`; }
  }

  let result;
  if (!winner) { draws++; result = '무'; }
  else if ((winner === TEAM_CHO) === newIsCho) { newWins++; result = '신 승'; }
  else { oldWins++; result = '구 승'; }
  records.push({ game: i, newSide: newIsCho ? '초' : '한', result, reason, plies: ply });
  console.log(JSON.stringify(records[records.length - 1]));
}

console.log(JSON.stringify({ summary: true, startIdx, games, newWins, oldWins, draws }));

