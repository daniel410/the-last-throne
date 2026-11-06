# 보스 공격력·공격속도·이동속도 상향

2026-11-05 · TLT-027/050/057/061~065/084 · ENG/PLAN → QA · 로컬 구현·미게시, 부모 티켓 In Progress.

사용자 후속 요청으로 실제 출현 보스22종의 공격력을0.75.10 대비10%, 이동속도를10%, 기본 공격 주기 빈도를10% 높인다. [조사·선택·위험·후속 실험](../../research/2026-11-05-boss-pressure.md). 일반 몬스터·보스 체력·보상·레벨·출현 수는 유지한다.

서버가 기존 Balance.isBoss 분류로 결정한다. 전 지역·4난이도·1~4인과 무난이도 로컬 모험에 적용한다. Damage는 반올림 전에1.1배를 적용한다. Attack은 예고(windup)/타격(active)을 유지하고 회복(recovery)을 줄여 기본 전체 주기를1/1.1로 만든다. Move는 해당 종류의 기존 프로필 속도1.1배다. 기존 공격 시계 복제와 Humanoid.WalkSpeed 설정을 통해 기존 표시/이동/느려짐/복귀 경로를 사용한다. 스턴/노출·AI 재판단 지연을 포함한 실전 공격 횟수의 정확한10% 증가를 뜻하지 않는다.

전달: DeepwoodService.applyBalance가 현재 원정 규칙으로 StoryAttackSpeed/StoryMoveSpeed를 설정한다. CombatService.registerEnemy는 지역 프로필과 공격 정의를 복제한 후 BossCombatTuning.apply로 자기 config만 조정한다. 훈련장 K0는 이 경로 밖이며 기존 프로필을 변이하지 않는다. 공격력과 입장 미리보기는 기존 unitStats 공통 경로다.

새 원정 규칙7을 저장하고 기존1~6의 피해/속도/저장·재접속을 유지한다. 구규칙에서는 두 속도 속성이1이며 중립 공격 주기는 재계산하지 않는다. 후속 게시 시 Lobby/Battle을 함께 갱신해야 한다.

검증:

- `lua tests/boss-combat-tuning.spec.lua`:307,910 PASS·실제 출현22보스. 전체 출현·난이도·인원별 보스 피해10%/일반 유지·HP/레벨/정예/보상 유지·예상/실제 일치·기존1~6 속도 보존·규칙6저장/재접속·새규칙7. 각 지역 프로필의 기본 주기10%/예고·타격시간 보존/유효 회복시간도 검사한다.
- [20개 관련 회귀 스위트](tests.log):PASS.
- `python3 tools/prepare-epic-monster-native-test.py` → `/tmp/tlt-epic-monster-native.luau` 격리 Edit Studio 실행:4개 순수 스위트688,430 PASS, 실제 applyBalance 임시 Model 속성238,700검사/6,820출현 PASS, 실제 CombatService의 config 등록 코드277검사 PASS. 일반/보스 전 종류의 원래·새 속도/공격 주기/예고 보존/StoryDamage 연결을 검사했다. PlaceId0·플레이어0. [엔진 결과](native.json).
- 빌드0.75.11: [고정 소스·산출물 해시](build.json). 게시/릴리스 태그 없음.

미검증: 실제 Player 전투·모션/공격 전조·추격 경로·반격 기회·보스 급사/동시 피격·실계정 저장/재접속·실기기·4인+AI·최종 사용자 난도 수용. 다음 QA/PLAN은 조사 문서의 대표 보스 전후 실전 실험을 수행한다.
