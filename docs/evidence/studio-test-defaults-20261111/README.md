# 로컬 테스트 초기값

작업: TLT-003/041 · 소프트웨어 엔지니어 · 2026-11-11

사용자 요청: 로컬 테스트에서만 Gold 10,000, Diamonds 5,000, 모든 영웅 Lv10으로 초기화한다. 게임성 변경이 아닌 테스트 fixture 설정이므로 별도 게임성 조사는 생략했다.

## 변경과 경계

- `InventoryService`가 `RunService:IsStudio()`인 경우에만 `StudioTestRules`를 설치한다. 기존 메모리 전용 어댑터를 유지하며 DataStore에 접근하지 않는다.
- 새 Studio 세션 계정은 Gold 10,000 / Diamonds 5,000. 각 클래스 영웅은 생성 시 Lv10 / 현재 레벨 XP 0으로 시작한다. 영웅 자동 생성이나 클래스/장비/본편 해금은 추가하지 않는다.
- 성장 데이터도 Lv10으로 맞추며 기본 미배분 스탯36P/스킬9P 규칙을 따른다. 테스트 중 소비·획득·성장은 유지하며 매 요청/갱신/동일 세션 재접속마다 덮어쓰지 않는다. Stop 후 새 Play에서 메모리 계정이 재생성된다.
- 일반 계정의 Gold 0 / Diamonds 0 / 영웅 Lv1 초기값, 게시 Experience 저장, TD는 변경하지 않았다.

## 검증

- `lua tests/studio-test-defaults.spec.lua`: PASS. 네 클래스 Lv10·성장/인벤토리 유효성·중복 생성 거절·거래/갱신/동일 세션 재접속의 변경값 보존·새 세션 초기값·일반 규칙 격리를 확인했다. Studio 진입 조건은 소스 구조 검사다.
- `lua tests/inventory.spec.lua`: 274검사 PASS.
- `lua tests/last-selected-hero.spec.lua`: 21검사 PASS.
- 로컬 빌드: `build.json`에 버전·고정 소스 커밋·결과 해시 기록.
- 미검증: Studio 실제 Play/UI, 게시 클라이언트, 실기기, 사용자 수용. 게시/릴리스 태그 없음.

다음 담당: QA/사용자. 로컬 0.103.5를 Studio에서 열고 새 Play → 영웅 생성 → 재화/레벨 확인 → 소비/성장 → Stop/Play 초기화 순서로 확인한다. TLT-003/041 전체 게이트 완료를 의미하지 않는다.
