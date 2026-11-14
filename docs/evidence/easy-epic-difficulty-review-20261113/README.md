# Easy 에픽 난이도 계산 증거

TLT-027/050/061/062/063/064/065/084 · 2026-11-13 · [리뷰·해석·제안·미검증·인계](../../research/2026-11-13-easy-epic-difficulty-review.md)

## 입력과 산출물

- 소스 HEAD `a040bf82f280d6d731a0382d427fe3cf85e86b57`, VERSION `0.105.4`, 현재 Easy 규칙14. 작업 트리의 기존 Hard 입장 조건 변경은 Easy 수치에 영향 없음.
- [measure.lua](measure.lua): 최종 CampaignContent47장의 실제 인구/능력치 함수를1~4인에서 실행. 신규 전체 교전 기준8,732행 생성. 무리 상한·처치 인덱스 고유성·양수 능력치·작성 레벨 검사 통과.
- [unit-stats.csv](unit-stats.csv): 원시 행을 인원/장/목표/종류/능력치로 집계한576행. `count` 합8,732. `side`와 `pacing`으로 선택/길목 분리 가능.
- [waves.csv](waves.csv): 인원/장/목표/웨이브별 적 수. 모든 무리가 동시에 존재한다는 의미가 아님.
- [source-sha256.txt](source-sha256.txt): 계산·정적 추적에 사용한 주요 소스10개의 SHA-256. 집계 CSV와 원시 행의 전체 일치 및576집계/1,125무리/8,732적 합계 검사 통과.

저장소 루트에서 재실행:

```sh
lua docs/evidence/easy-epic-difficulty-review-20261113/measure.lua > /tmp/tlt-easy-review.csv
```

`unit-stats.csv`는 원시 CSV의 `party,chapter,side,epic,goal,pacing,kind,boss,level,hp,damage`별 행 수, `waves.csv`는 `party,chapter,side,epic,goal,pacing,wave,waveSize`의 고유 행이다. 집계 시 입력/필드 문자열 순으로 정렬했다.

## 검증 수준

Lua 계산과 서버 소스 정적 추적만 수행했다. 보상/게임 수치/저장 데이터 변경 없음. 적 기본 피해는 방어 전 수치이며 다단 패턴에서는 분할된다. 실제 플레이어 성장·회피·광역·이동·지원 동료는 시뮬레이션하지 않았다. Studio/게시 클라이언트/실기기/사용자 수용 및 게시 소스 일치 여부는 미검증이다.
