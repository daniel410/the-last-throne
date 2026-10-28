# Deepwood 기사 K0 원형 작업 기록

2026-10-28 · 총괄: DIR · 작업: TLT-002/003/005/006/007/021/026/030~034 일부

## 목적과 현재 범위

Deepwood의 평탄한 훈련장에서 플레이어가 기사로 Goblin, Orc Warrior, Ogre의 전방 공격을 보고 검·방패·회피를 시험하는 첫 원형이다. 월드와 기사 무기는 Roblox 기본 도형을 이용한 임시 자산이며, 적 외형은 TD에서 사용하는 실제 Meshy 메시·텍스처를 사용한다. Slime 원본과 어댑터도 포함하되 슬라임 전투는 아직 추가하지 않는다. 스토리 임무, 성장·장비 소유, 저장, 상품, 공통 지갑과 TD↔RPG 포탈은 연결하지 않았다. 이 원형은 선행 게이트나 각 백로그 티켓의 전체 수용을 대신하지 않는다.

| 구성 | 소스와 확인해야 할 계약 |
| --- | --- |
| 월드 | `src/server/World/TrainingField.luau`: 안전 시작·96×96 공터·엄폐·TD 외형을 연결한 적. [독립 지형/물리 기록](world-design.md)과 통합 플레이 검증을 구분한다. |
| 전투 | `src/server/Combat/CombatService.luau`, `K0Rules.luau`, `src/shared/K0Config.luau`: 서버 시간과 서버 위치로 검격·방어·회피·피해·적 AI를 판정한다. 수치와 입력 제한은 K0 실험용이다. |
| 시각 | `src/server/Cosmetics/KnightAppearance.luau`: R6/R15 임시 검·방패. `src/client/K0SwordVisual.luau`, `K0Telegraphs.luau`: 서버 전투 상태에 따른 로컬 검 연출과 공격 예고. 연출은 판정을 계산하지 않는다. |
| 조작/UI | `src/client/init.client.luau`, `K0Hud.luau`: PC 왼쪽 클릭/오른쪽 클릭 유지/Space, 패드 R2/L2/B, 터치 공격/방어/회피 버튼. 문자열은 `src/shared/K0Text.luau`의 en-US 키를 사용한다. |
| 기존 원본 | [TD 몬스터 연결 결과](td-monster-integration.md), [기존 원본 기록](td-monster-sources.md), [오크 원본 기록](orc-source.md)에 채택한 runtime과 Meshy 원본 경로·해시를 고정했다. 이전 [TD 3D 조사](asset-audit.md)와 조사 시점을 구분한다. [Studio 로딩 조사](asset-load-probe.md)는 소유자 컨텍스트의 후보 12개 preload 성공을 확인했으며, RPG 게시 환경 권한·최종 리그/모션은 별도다. |

HP 1000, 공격력 100, 스태미나 100은 전투 실험 프리셋이다. 스탯 포인트나 레벨·보상을 지급하지 않는다. 클라이언트는 행동 의도만 전송하며 서버가 대상·거리·각도·사선·피해·스태미나와 적 행동을 처리한다. 부정 입력, 위치 소유권과 지연에 대한 실제 네트워크 검증이 필요하다.

## 검증과 인계

- 독립 월드 테스트의 조건·시험 당시 파일 해시·Studio 로그는 [월드 기록](world-design.md)에 남겼다. 이후 영어 키 통합으로 월드 소스가 변경됐으므로 이전 테스트를 현재 소스 전체에 대한 통합 통과로 취급하지 않는다.
- 전투 규칙의 순수 경계 검사는 `lua tests/k0-rules.spec.lua`로 실행한다. 해당 결과는 서버 로직의 Roblox 런타임·멀티플레이 통과를 의미하지 않는다.
- 독립 QA와 첫 게임 빌드 결과는 각각 [QA 기록](qa.md), [빌드 기록](build.md)에 남긴다. 기록이 실제로 추가되기 전에는 이를 통과 증거로 간주하지 않는다.
- 첫 리뷰의 프레임 건너뜀·입력 버퍼 수정과 한계는 [전투 타이밍 기록](combat-timing-fix.md)에 분리해 남긴다. 검 방향과 캐릭터 회전, 메뉴/채팅 진입 시 홀드 정리는 후속 과제다.
- 다음은 고정된 빌드에서 실제 Studio 플레이와 PC·터치·게임패드 입력, 적 AI/예고·접지·장애물·리스폰, 네트워크 악용과 지연을 확인하는 것이다. 이후 TD 자산의 현재 권한·대상 Experience 로드를 검증하고 실측에 맞게 리그와 모션을 교체한다.
- 공통 지갑/상품은 [TD 지갑 읽기 전용 감사](td-wallet-audit.md)를 시작점으로 writer 전수 확인과 중복 처리 계약을 완성한다. 운영 데이터, TD 시작 Place, 지갑과 구매권은 변경하지 않는다.

다음 담당: QA가 통합 실행과 재현 가능한 결함 기록을 맡고, ENG가 결함과 지연/동시성에 대응하며, ART·DES가 공유 자산과 실제 시야·모션을 검증한다.
