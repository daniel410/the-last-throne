# 일반 근접 적 교정·공격 범위 가이드 접지

2026-11-06 · TLT-005/027/050/057/061~065/084 · ENG → QA · 0.78.8 · 로컬/미게시

사용자가 일반 고블린/오크/오우거·아이스 울프/베어는 근접 전용, 아이스 엘프·마법형/보스는 원거리 역할을 유지하도록 요청했다. 이어 공격 타격 범위 가이드가 공중에도 표시되는 문제를 보고했다. 최신 사용자 역할 지시와 확인된 범위/접지 결함 교정이며 신규 몬스터/전투 시스템을 추가하지 않는다. 기존 제작 스킬과 엔지니어 지침을 적용하고 사용자 Blender 변경은 보존한다.

## 변경

- `Goblin.1` 찌르기·`Orc.2` 내려치기·`Ogre.2` 지면 강타의 직선 판정이24stud/발동21.6stud였다. 실제 판정6stud/발동5.4stud로 줄인다. 실제 비행탄이 아니라 긴 직선 판정이 원거리 타격을 만들던 원인이다.
- IceWolf/아이스 베어 기본기는 근접 유지. 두 번째8stud 돌진은 각각 `Frost Rend`/`Heavy Maul`의 근접 부채꼴 강공격으로 변경한다. 울프는 hop, 베어는 slam 표현이며 이동 돌진/원거리 판정이 없다. 기존 강공격 예고1.55초·회복1.25초·쿨다운7초·블록 불가 계약은 유지한다.
- 이5종의 모든 기술은 판정6stud/선택5.4stud이며 밖에서는 공격 선택이 없어 추격한다. 안정ID/스킬 수는 유지한다. 프로필/manifest 데이터 버전2로 갱신하고 생성기를 함께 수정했다. 기존 원정1~8의 구형 패턴과 원정9 게이트는 유지하며 기존9도 교정된 정의를 쓴다.
- IceElf2종 원거리 마법탄·Shaman/VolcanoShaman·보스22종 등 **나머지44종은 정의 전체가 이전과 동일**하다. 능력치/보상/기여/난도/전직/저장은 변경하지 않는다. [전체 비교](profile-comparison.json).
- 새 `EnemyPatternEffects` 가이드의 raycast가 공격자만 제외해 다른 몸체/충돌 장식 위에 붙고, 바닥 미검출 시 루트-2.5stud에 떠 있었다. 정본 월드의 실제 지면/경사로/길/지지 지형과 Terrain만 raycast에 포함한다. 지면 미검출 시 선을 만들지 않는다. 새 지면 로드/해제 시 캐시·활성 가이드를 무효화하고 재투영한다.
- 3stud 이하의 짧은 선분으로 경사를 따르고, 단차1.5stud 초과/미검출 구간은 연결하지 않아 허공을 가로지르는 선을 막는다. 최대 사거리/반경과 렌더 주기·기존 캐싱을 유지한다. 판정/투사체 비행·손의 시전 빛·명중 효과는 바꾸지 않는다. 구형 K0Telegraphs는 이미 미검출 시 숨기는 별도 경로이며 이번 변경 대상은 새 패턴 가이드다.

## 검증

| 명령/조건 | 결과 |
| --- | --- |
| `lua tests/enemy-patterns.spec.lua` |3642개 PASS.49종/142공격·22보스·기하/원정8/9 능력치/보상 보존,5종의 모든 기술 근접 범위·7~32stud 공격 선택 차단, 아이스 엘프/마법형/원거리 보스 선택 유지 |
| `python3 tools/assemble-enemy-pattern-test.py` → `run-in-roblox --place /tmp/tlt-audio-empty.rbxlx --script /tmp/tlt-enemy-patterns-native.luau` | 격리 빈 Studio에서1297개 PASS·CLI종료0.5종10공격4stud 실제 타격/12stud 무타격/투사체·돌진 없음, IceElf2기술20stud 투사체 명중,49종142공격 기존 회귀.6종류 가이드가 실제 바닥+0.12stud에 놓이고 머리/장식 충돌면 무시, 활성 바닥 해제 시 숨김/재로드 시 복원. [엔진 결과](native.json) |
| 생성기 재실행·JSON 전후 비교 | 멱등·변경5종/나머지44종 동일. 보스/마법형 개별 정의 불변 |
| `lua tests/boss-pressure-boost.spec.lua` |307910개 PASS·22보스 능력치/원정 호환 |
| `lua tests/pixelfx.spec.lua` |634개 PASS |
| `luau-compile` 변경 모듈/fixture4개 · `git diff --check` |PASS |

기존203785492 asset-type 경고가 발생했으며 검사에는 영향이 없었다. fixture는 실제 엔진 Parts/raycast/피해 콜백을 쓰되 플레이어·원격/계정·정상 전투 입력은 대역이다. 정상 전투 화면의 최종 미술/경사·절벽 경계/스트리밍·기기 성능·실제 체감 난도·다인·네트워크 수용은 미검증이다. 지면 후보 검색은 최초/지면 스트리밍 변화 때만 갱신하며 경사 분할의 실기기 비용은 후속 측정한다. 부모 티켓은 In Progress를 유지한다.

다음 QA는5종이 접근 후 타격하는지·공격 중 거리 이탈 시 회피되는지, IceElf/주술사/원거리 보스의 비행탄, 지형 높이가 다른 Deepwood/설원/화산/숲/묘지에서 바닥 전용 예고를 정상 플레이로 확인한다. Place게시·태그·TD변경은 수행하지 않는다.

## 고정 빌드·서버 통합 후속

단일 빌드0.78.8 성공. 입력 소스 `70b111825b1ae0ebffb1ea088ec2552f2d9ddb8a`, SHA-256 `da659d63daaba0cfbe28af5893bcfd10cd086823733a49538ee1c7ba4956031f`, 13,288,824bytes. 산출물 XML의 변경2개 모듈이 소스와 동일함을 확인했다. [빌드 기록](build.json).

`python3 tools/assemble-enemy-pattern-service-test.py` → `run-in-roblox --place builds/0.78.8/TheLastThrone-0.78.8.rbxlx --script /tmp/tlt-enemy-pattern-service-native.luau`:72개/23사례 PASS·CLI종료0. 실제 CombatService에서5종의12stud 공격 미시작/4stud 시작·6stud 판정, IceElf20stud 투사체 실제 피해,4클래스/벽·다른 원정·일시중단·블록/완벽블록·회피·보호막 회귀를 확인했다. [서버 결과](service.json). 테스트용 Studio 프로세스는 자동 종료됐으며 기존 사용자 Studio는 보존했다. 소스 origin/main 푸시 성공. 게시/실제 사람 플레이 수용은 별도다.
