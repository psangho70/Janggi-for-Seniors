// 청춘 장기 AI 실측 벤치마크 (index.html의 엔진 코드만 추출하여 Node에서 실행)
const fs = require('fs');
const html = fs.readFileSync('c:/Antigravity/Janggi for Seniors/index.html', 'utf8').split(/\r?\n/);
// 상수 선언부 ~ JanggiAI 클래스 끝까지 추출
const start = html.findIndex(l => l.startsWith('const TEAM_CHO'));
const end = html.findIndex(l => l.startsWith('// [크로스플랫폼 통합 네이티브 브릿지'));
const code = html.slice(start, end - 1).join('\n');
const mod = new Function(code + '\nreturn { JanggiGame, JanggiAI, TEAM_CHO, TEAM_HAN, PIECE_NAMES };')();
const { JanggiGame, JanggiAI, TEAM_CHO, TEAM_HAN } = mod;

function instrument(ai) {
  // 반복 심화에서 실제로 완주한 깊이 기록
  const orig = ai.alphaBeta.bind(ai);
  let maxRootDepth = 0;
  ai.alphaBeta = function (depth, a, b, isMax, level, ply) {
    if (ply === 1 && !this.isSearchTimeout) maxRootDepth = Math.max(maxRootDepth, depth + 1);
    return orig(depth, a, b, isMax, level, ply);
  };
  return () => maxRootDepth;
}

// 1) 초기 국면에서 한 수 계산: 오프닝북 사용 여부 / 탐색 깊이 / 노드 수
const g = new JanggiGame();
g.initBoard(0, 0);
const ai = new JanggiAI(g);
const getDepth = instrument(ai);
const t0 = Date.now();
const mv = ai.getBestMove(TEAM_CHO, 'hard');
console.log('[초기국면] 반환 수:', mv && `${mv.fromX},${mv.fromY}->${mv.toX},${mv.toY}`, '배지:', mv && mv.badge, '소요(ms):', Date.now() - t0, '노드:', ai.nodeCount);

// 2) 오프닝북을 끈 상태에서 순수 탐색 성능 측정 (중반 유사 국면: 몇 수 진행)
ai.getOpeningMove = () => null;
const results = [];
for (let i = 0; i < 6; i++) {
  const team = g.currentTurn;
  const t1 = Date.now();
  const rootHash = ai.computeBoardHash(g.board, team);
  const m = ai.getBestMove(team, 'hard');
  const ms = Date.now() - t1;
  const rootEntry = ai.tt.get(rootHash);
  results.push({ ply: i, team: team === TEAM_CHO ? '초' : '한', ms, depth: rootEntry ? rootEntry.depth : '?', nodes: ai.nodeCount, nps: Math.round(ai.nodeCount / (ms / 1000)), move: `${m.fromX},${m.fromY}->${m.toX},${m.toY}` });
  g.makeMove(m.fromX, m.fromY, m.toX, m.toY);
}
console.table(results);

// 3) 평가함수 단독 호출 비용
const t2 = Date.now();
for (let i = 0; i < 20000; i++) ai.evaluatePosition('hard');
console.log('evaluatePosition 1회 평균(us):', ((Date.now() - t2) * 1000 / 20000).toFixed(1));

// 4) 장군 보너스 왜곡 확인: 장군 상태 보너스 vs 기물 가치
console.log('차 가치:', ai.pieceValues[2], '/ 고급 장군 보너스: 1500 (평가함수 내 상수)');
