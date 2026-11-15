# 상위 난이도 공격력·인식 후 추적 중단 수정

2026-11-15 · TLT-005/027/050/084 · ENG → QA/사용자

## 변경과 근거

사용자 요청으로 Hard·Insane·Hell 일반/정예/보스의 공격력 계수를 기존 대비25%/35%/50% 올렸다. 규칙18을 새 원정에 고정하고 기존 규칙1~17의 공격력/재접속 계약은 유지한다. Easy·HP·레벨·XP/Gold/재료/입장 조건은 보존한다. [수치 정본](../../production/monster-combat-design-2026-11-15.md#상위-난이도-공격력과-추적-유지)·[RPG 비교/Roblox 공식 근거](../../research/2026-11-15-advanced-monster-damage.md).

추적 중 매 프레임 RootPart CFrame을 바꿔 시선을 돌리면서 MoveTo는0.25초마다만 실행했다. CFrame 변경이 MoveTo를 취소해 인식해도 충분히 접근하지 못했다. 선회 후 마지막 경로 검사 통과 지점을 재명령하고 정지/공격/차단 시 캐시를 폐기했다. 새 경로 계산 주기·벽/낭떠러지 보호·공격권·준비 시간은 유지한다.

## 검증

- `lua tests/advanced-mode-damage.spec.lua`: **62,199 PASS**.50종·5에픽·1~4인·대표 레벨5개·4난이도에서 HP/레벨·피해·퀘스트/처치 보상 대조.
- `lua tests/enemy-combat-tactics.spec.lua`:7,212 PASS. `enemy-patterns.spec.lua`:3,717 PASS. `enemy-pack-rules.spec.lua`:1,366 PASS.
- `difficulty-reward-rates.spec.lua`:2,162 PASS. `campaign-growth-v16.spec.lua`:389,857 PASS; Easy30→Hard60→Insane80→Hell90/95/97/98/99 누적 예상치 유지. `hard-unlock.spec.lua`:56 PASS. `campaign-mode-migration.spec.lua`:88 PASS.
- `python3 tools/prepare-enemy-combat-native.py` 뒤 출력된 `run-in-roblox --place /tmp/tlt-enemy-encounter-depth/qa.rbxlx --script /tmp/tlt-enemy-encounter-depth/all-native.luau`: 종료0·`ENEMY_COMBAT_ALL_PASS`. [전체 엔진 결과](results.json)·[로그](native.log). 실제 전투 서비스·공격권·기하/효과·공격 준비/피해·방향 모션 회귀와 추적 재명령/차단/공격 시 캐시 폐기 사례를 포함한다.
- 실제 R15+Humanoid를 평지에 놓고 서비스의 `stepEnemy`로 추적했다. 좌표 보정·직접 공격 호출 없이 **18→5.3068 studs, 1.558초에 공격 시작**. 같은 시험에 변경 전 `CombatService` 원문을 넣으면 **6.005초 후14.5872 studs, 공격 미시작**으로 실패했다. [변경 전 엔진 기록](baseline-native.log). 두 경우 모두 같은 새 fixture/규칙18을 쓰며 전투 서비스 원문만 교체했다. 본편 입력·실제 플레이어/네트워크 시험은 아니다.
- `difficulty-balance.spec.lua`의 구 v1 완료 보상 기대와 `difficulty-level-free.spec.lua`의 `CampaignModeProgress: Incompatible`은 변경 전 Difficulty 원문으로 대조해도 같은 지점에서 실패했다. 이번 변경의 성공으로 집계하지 않고 기존 기대/fixture를 수정하지 않았다.

## 미검증과 다음 담당

현재 열린0.110.10 Play는 읽기 전용 확인만 했으며 몬스터가 없는 상태였다. 그 세션을 변경하거나 재시작하지 않았다. 실제 새 빌드의 게시 클라이언트·다인·모바일·사용자 재미 수용은 미검증이다. QA/사용자는 새 빌드에서 새 원정/재입장 후 근접/원거리 몬스터 접근·공격, 대표 보스 및 Hard/Insane/Hell 합산 피해·물약 소모를 확인한다. 전체 G1/G7 티켓을 완료 처리하지 않는다.

복구는 해당 코드 커밋의 revert 후 새 버전 빌드로 수행한다. 저장 규칙1~17과 성장/소유 데이터는 보존되어 있고 기존 원정에 규칙18을 강제로 덮지 않았다.

## 고정 빌드

`0.110.11` · 입력 소스 `640ba93bb93cbdc56f77d2a116b53c855fd096c4` · [LFS/산출물 SHA-256 빌드 기록](build.json). `python3 tools/build-game.py --source 640ba93b --record docs/evidence/advanced-monster-combat-20261115/build.json`이 성공했다. 산출물은 `builds/0.110.11/TheLastThrone-0.110.11.rbxlx`다.

같은 고정 빌드를 `run-in-roblox --place builds/0.110.11/TheLastThrone-0.110.11.rbxlx --script /tmp/tlt-advanced-fixed-native.luau`로 열어 시작 스크립트를 비활성화한 격리 엔진 시험을 수행했다. 두 변경 모듈의 원문이 입력 커밋과 같은지 먼저 검사했고 `ADVANCED_FIXED_SOURCE_EQUAL true`, 종료0·`ENEMY_COMBAT_ALL_PASS`를 확인했다. [고정 빌드 엔진 로그](fixed-native.log). 실제 R15 추적은18→5.2973 studs, 1.570초에 공격 시작을 다시 확인했다. Roblox 게시·릴리스 태그는 만들지 않았다.
