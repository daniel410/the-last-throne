# 에픽별 몬스터 성장 조정

2026-11-05 · TLT-027/050/057/061~065/084 · ENG/PLAN → QA · 로컬 구현/검증, 미게시. 부모 티켓 In Progress.

원인: 몬스터 레벨·StoryHealth/StoryDamage는 서버 전투로 전달되지만 모든 에픽이 같은 완만한 선형식에 의존했다. 에픽1 Orc/Ogre의 Easy HP보정과 후반의 약한 가족 계수도 차이를 줄인다. [조사·선택·플레이 위험](../../research/2026-11-05-epic-monster-progression.md).

| 현재 교전 에픽 | 기존 대비 HP | 기존 대비 공격력 |
| --- | --- | --- |
| 1 Deepwood | ×1 | ×1 |
| 2 Frozen Vale | ×1.35 | ×1.20 |
| 3 Ember Caldera | ×1.75 | ×1.45 |
| 4 Gloamwood | ×2.20 | ×1.70 |
| 5 Haunted Graveyard | ×2.70 | ×2.00 |

일반/보스 공통의 지역 보정이며 기존 가족·레벨·난이도·인원 계수에 추가한다. 정예를 적용하기 전에 반올림하므로 정수의 비율은 약간 다를 수 있다. 전후 동일 몬스터 비교이며 서로 다른 에픽의 절대 수치 배율이 아니다.

Easy 솔로 예: IceWolf Lv12 HP360→486/피해28→33, Imp Lv20 HP510→893/피해34→49. QueenIceElf Lv20 HP2700→3645/피해85→102, InfernoOverlord Lv30 HP4000→7000/피해110→160. 방어·블록·회피·보호막 이전 단일 적중 수치다.

변경 경로: 저작된 현재 chapter.epic → encounterWaves/expand의 spec.epic → unitStats → Difficulty.stats → 실제 DeepwoodService.applyBalance의 StoryHealth/StoryDamage → 기존 CombatService 등록/피해 경로. 원정 최초 임무가 아니라 현재 교전의 에픽을 사용하므로 같은 원정의 에픽 경계에서도 적용한다. 입장 미리보기도 같은 유한 웨이브와 unitStats를 사용한다. 무난이도 로컬 모험도 보정하며 훈련장 고정 K0에는 적용하지 않는다.

Difficulty 규칙4를 새 원정에 저장한다. 규칙1/2/3 저장·재접속은 기존 수치를 유지하므로 이미 진행 중인 원정은 새 보정을 받지 않는다. 보상·레벨·출현 수·예고·공격 주기·영웅 능력치는 유지한다. 규칙4를 모르는 구버전 서버로 새 원정을 보내지 않도록 후속 게시 시 Lobby/Battle을 같이 갱신해야 한다.

검증:

- `lua tests/epic-monster-progression.spec.lua`:201,484 PASS. 5에픽·4난이도·1~4인 전체 실제 출현/보강/보스, 지역 전달·후반 수치 상승·에픽1 보존·기존1~3 고정·보상 보존·예상/교전 일치·v3저장/재접속·v4새원정.
- `python3 tools/prepare-epic-monster-native-test.py` → `/tmp/tlt-epic-monster-native.luau`를 격리 Edit Studio 실행: 위201,484 검사 PASS, 실제 applyBalance 함수와 임시 Model 속성81,840검사/6,820출현 PASS. PlaceId0·플레이어0, 게임 서비스/계정 저장이나 실제 피격 Play시험은 아니다. [엔진 결과](native.json).
- [관련16개 스위트 결과](tests.log): 몬스터 피해/난이도·보상·출발·저장·파티·스토리/에픽경계 회귀 PASS.
- 빌드:0.75.8. 고정 소스/산출물 해시는 [build.json](build.json)에 기록한다. 고정 소스 `12612e6`의 단일 빌드 성공. 게시/릴리스 태그 없음.

미검증: 실제 정상 전투의 처치 시간·실피해·보스 급사/겹침·4인+AI·실기기·사용자 난도 수용·실계정 재접속과 게시 클라이언트. 최종 밸런스 완료로 처리하지 않는다. 다음 담당 QA/PLAN은 조사 문서의 최소 플레이 실험을 수행한다.
