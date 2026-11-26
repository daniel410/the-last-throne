# 전체 코드·문서 리뷰

2026-11-26 · 검토 기준 `355b66d9372219304ed455833791266e1aa00c2b` · 소스 버전 `0.117.10` · ENG·QA → 각 담당

저장소 전체를 대상으로 구문·테스트 목록과 문서 링크를 검사했다. 코드 정밀 검토는 서버 계정 저장, 원정 이동과 복구, 스토리 보상, 결제 및 최근 튜토리얼·HUD·지도 변경에 집중했다. 문서는 README에서 연결되는 현재 계약과 상태, 계획·백로그, 제작 스킬, 정책과 관련 검증 기록을 대조했다. 사용자 작업 트리의 기존 자산 변경은 별도로 확인했다.

## 코드

### [P1] 복귀 전 HP/MP 저장 실패 뒤 세션이 잠기고 마지막 수치가 유실된다

**TLT-041/053 · ENG, QA.** `captureVitals`가 저장 결과를 받지 못하면 계정의 `valid`를 끈다. 같은 체크포인트를 보관하는 재시도 상태도, 임대 갱신의 `renewPending`도 설정하지 않는다. 이후 복귀 시도는 `prepareTransfer`의 첫 조건에서 막히며, 연결 종료 시에는 `state.valid` 조건 때문에 최종 HP/MP 저장을 건너뛴다. 실제 `InventoryService`와 `AccountStore`를 사용하는 가짜 저장소에서 HP 7을 저장한 뒤 HP 4로 복귀를 시도하고 저장 오류를 주입했다. 저장소가 회복되고 갱신이 두 번 실행된 뒤에도 복귀가 막혔다. 연결 종료 처리 후 다시 열었을 때 HP 7이 남았다. [체크포인트 저장](../../src/server/Inventory/InventoryService.luau#L180-L191) · [접속 종료](../../src/server/Inventory/InventoryService.luau#L113-L121) · [임대 갱신 및 이동 준비](../../src/server/Inventory/InventoryService.luau#L643-L688)

동일한 서버 소유권 안에서 미확정 체크포인트를 재시도하도록 하고, 저장 응답 유실과 실제 미저장을 각각 검증한다. 소유권이 교체된 경우에는 이전 서버의 쓰기를 계속 차단한다. 실제 이동 직전과 연결 종료 직전에서 HP/MP 보존을 확인한다.

### [P1] 파티 출발 취소에서 계정 재열기에 실패하면 멤버가 잠긴다

**TLT-041/053 · ENG, QA.** 앞 멤버가 계정 임대를 반납한 뒤 다음 멤버의 출발 준비가 실패하면 `Departure.prepare`는 앞 멤버의 잠금 해제를 한 번 호출한다. `resumeTransfer`가 일시적인 저장 장애로 실패하면 `transferPrepared`와 `closing`이 유지된다. 취소 경로에는 후속 잠금 해제가 없다. 배틀에서 로비로 돌아갈 때 리조인 상태 갱신이 실패하는 분기에도 같은 단발 호출이 있다. 두 멤버의 출발 취소에서 재열기 호출이 한 번뿐임을 확인했고, 실제 `InventoryService`에서는 저장소 회복 후에도 재열기를 다시 호출하기 전까지 계정이 닫혀 있었다. [파티 출발 취소](../../src/server/Network/ExpeditionDeparture.luau#L10-L18) · [로비 복귀 취소](../../src/server/Network/ExpeditionService.luau#L371-L382) · [계정 재열기](../../src/server/Inventory/InventoryService.luau#L697-L702)

취소된 이동의 계정 복구를 추적하고 같은 계정을 다시 열 수 있을 때까지 재시도한다. 뒤 멤버 준비 실패 후 앞 멤버가 같은 로비에서 조작과 재출발을 회복하는지 검증한다.

### [P2] 현재 회귀 테스트가 이전 원정 규칙과 월드 인터페이스에서 중단된다

**TLT-050/057 · ENG, QA.** `advanced-mode-damage.spec.lua`는 신규 규칙을 18로 고정해 현재 기본값 19에서 첫 검사에 실패한다. `battle-startup.spec.lua`가 제공하는 월드 스텁은 `create`만 지원해 현재 `StoryGateTemplates.prepare()` 호출에서 종료된다. 그 결과 각각 기존 규칙의 수치 호환과 월드 시작 조건을 검사하는 후속 단언에 도달하지 못한다. Python의 피격 배경과 몬스터 크기 검사도 이전 파일에서 런타임 호출을 찾는다. 현재 호출 파일과 시그니처를 메모리에서 대입한 확인에서는 두 Python 검사 모두 통과했다. 버전별 회귀에 실제 검증 대상 버전을 명시하고, 스텁과 연결 경로를 현재 인터페이스에 맞춘다. [난이도 회귀](../../tests/advanced-mode-damage.spec.lua#L5) · [현재 난이도](../../src/shared/Difficulty.luau#L9) · [월드 스텁](../../tests/battle-startup.spec.lua#L21-L31) · [실제 초기화](../../src/server/World/CampaignWorld.luau#L18-L26) · [피격 검사](../../tests/hit-feedback-transparency.spec.py#L21-L24) · [몬스터 크기 검사](../../tests/story-monster-sizing.spec.py#L52-L54)

## 문서

### [P1] 로비·원정 실행 계약에 과거 빌드 게시 지시가 남아 있다

**TLT-016/053/057 · DIR, ENG.** 로비·원정 실행 계약은 두 프로젝트로 각각 빌드한 `0.37.2`를 로비·배틀에 게시하라고 지시한다. 현재 제작 계약에서는 두 프로젝트가 동일한 호환 사본이며 단일 파일을 두 Place에 게시한다. 현재 상태 문서는 기록상 최신 비공개 게시가 `0.115.33`임을 보여 준다. 구형 게시 지시를 실행 절차에서 제거하고 현행 단일 빌드·검증 절차로 연결한다. Place 생성의 증거는 기존 기록에서 확인할 수 있다. [구형 배포 지시](../production/lobby-economy-and-expeditions.md#배포와-다음-수용) · [단일 빌드 절차](../development-workflow.md#6-tlt-단일-빌드-2026-11-04-사용자-지시) · [현재 상태](../production/current-status.md)

### [P2] 경제 문서와 제작 스킬의 현행 수치가 제품 계약과 다르다

**TLT-027/042/049/050 · PLAN, ENG.** 로비·원정 문서와 상품 문서 상단은 난이도마다 3 Diamonds, 영웅당 420개로 안내한다. 현행 계약과 카탈로그는 Easy/Hard/Insane/Hell에 3/5/7/10 Diamonds를 지급한다. 메인 35개 전체를 네 난이도로 초회 완료하면 영웅당 875개, 네 영웅 총 3,500개다. 같은 로비 문서는 Robux 상품 ID와 영수증 처리가 구현 범위에서 빠졌다고 적지만, 소스에서 전용 상품과 서버 `ProcessReceipt` 연결을 확인했다. 제작 스킬도 스탯 316·스킬 79를 보존하라고 안내한다. 이 값은 Lv80 기준이며 Lv99 총예산은 스탯 392·스킬 98이다. 현재 값을 정본에 연결하고 이전 값을 날짜가 붙은 이력으로 명확히 표시한다. [로비 경제](../production/lobby-economy-and-expeditions.md#재화와-무기) · [상품 문서](../items-and-monetization.md) · [경제 카탈로그](../../src/shared/EconomyCatalog.luau#L10) · [영수증 처리](../../src/server/Lobby/DiamondProductService.luau#L8) · [제작 스킬](../../skills/the-last-throne-production/SKILL.md#제작-시-지킬-구분) · [제품 계약](../product-contracts.md)

### [P3] 왕좌 이력의 근거 링크 두 개가 끊겨 있다

**TLT-028 · 문서 담당.** 과거 금색 왕좌 문서가 `tools/snapshot-td-lobby-throne.py`와 `src/shared/TDLobbyThroneGeometry.luau`를 현재 트리 경로로 연결한다. 두 경로는 금색 왕좌 적용 커밋 `fc7ee80b`에 있었고 현재 트리에는 없다. 과거 근거는 해당 커밋을 가리키도록 연결한다. 별도로 현재 작업 트리에서만 삭제된 후드 시안 자산 네 개의 문서 링크를 확인했다. 해당 네 파일은 검토 기준 커밋에 존재한다. [왕좌 이력](../production/dawnspire-td-throne-expanded-2026-11-11.md#왕좌-원본) · [후드 파일럿](../production/equipment-rarity-visuals-2026-11-08.md#후드-파일럿)

## 검증

- 기존 로컬 테스트 174개 실행. Lua 5.5.1에서 161개 중 124개 통과·37개 실패, Python 3.14.3에서 13개 중 11개 통과·2개 실패. 두 번째 전체 실행은 240초 제한 안에 모두 종료했다. 기존 `hero-vitals-service`, `expedition-departure`, `expedition-arrival-latency`, `diamond-product-service`는 통과했다.
- Luau 컴파일 통과. 런타임 585개, 테스트 324개, 도구 53개. 테스트와 도구의 Roblox API 실행은 구문 검사 범위에 포함되지 않는다.
- Python 도구·스크립트·테스트 257개 구문 분석 통과. Rojo 소스맵 생성 통과. `default.project.json`과 `battle.project.json`이 바이트 단위로 일치한다.
- `0.117.10` 지도, `0.117.7` 전투 HUD, `0.117.5` 튜토리얼의 로컬 후보 빌드 SHA-256이 각 빌드 기록과 일치한다.
- 루트 및 제품·제작·결정·계획·백로그·역할 문서 250개의 저장소 내부 상대경로 링크 2,465개를 검사했다. 기준 커밋에서 끊긴 링크 2개, 사용자 작업 트리에서만 끊긴 링크 4개를 확인했다. 저장소 밖 원본과 앵커의 유효성은 이 집계 범위 밖이다.
- 실제 Studio 플레이, 게시된 Roblox Player·Experience 왕복, 실계정 저장/결제, 멀티플레이·실기기·사용자 수용은 이번 리뷰에서 새로 검증하지 않았다. 위 장애 재현에는 격리된 Lua 테스트 환경을 사용했다.

### 실패한 테스트

Lua 파일명에서 `.spec.lua`를 생략했다. 위에서 확인한 사례 외에 나머지 실패의 개별 원인은 후속 분류가 필요하다. 예를 들어 `k0-rules`와 `skill-presentation`은 Lua 실행 중 추출한 Luau 코드를 파싱하다 중단됐다. 전체 Luau 컴파일에서는 해당 문법을 통과했다.

- `accessory-auto-equip`, `advanced-mode-damage`, `battle-startup`, `boss-combat-tuning`, `boss-final-escort`, `boss-pressure-boost`
- `campaign-combat-pacing`, `campaign-expansion`, `campaign-reorder`, `campaign-save-latency`, `deepwood-progress`, `deepwood-quests`
- `difficulty-balance`, `difficulty-enhancement`, `difficulty-level-free`, `ember-caldera`, `epic-monster-progression`, `frozen-vale`, `hard-unlock`
- `k0-rules`, `late-epics-adventures`, `late-epics`, `material-exchange`, `monster-damage-boost`, `monster-damage-tuning`, `monster-health-boost`, `pixelfx`
- `quest-completion-rewards`, `reward-materials`, `side-quest-battle-start`, `side-quest-guidance`, `side-quest-review`, `skill-action-interrupt`, `skill-presentation`, `stat-investment-preview`, `story-continuation`, `story-region-handoff`
- Python의 `hit-feedback-transparency.spec.py`, `story-monster-sizing.spec.py`
