# Hard Lv30 / Insane Lv60 입장 제한

2026-11-06 · TLT-027/028/057/061/073/084 · ENG → QA · 0.79.5 · 로컬 구현·미게시, 부모 티켓 In Progress.

사용자 확정 지시: Hard Lv30 이상·Insane Lv60 이상. 기존 Hard20/Insane40 입장 기준을 교체하며 Easy1/Hell80과 이전 난이도 완료·지역 스토리 조건은 유지한다. 명시된 입장 정책의 수치 변경이므로 별도 게임성 비교 조사 없이 적용한다. 기존 제작 스킬·엔지니어 역할·난이도 설계·실제 서버/표시 경로를 확인했다.

Difficulty.entryLevels/requiredLevel에 현재 입장 정책을 분리했다. allowed를 공유하는 서버 출발(파티 전원)·AdventureRules.begin·verifyRun(배틀 도착/재입장)이 현재 제한을 검사한다. 기존 낮은 레벨의 저장 원정도 재입장 때 제한되며 저장 데이터/권리를 삭제하지 않는다. UI 임무별 레벨·파티원 부족 레벨·클라이언트 기본 캡션에 같은 값을 사용한다. 적/보상 계산의 mode.level은 기존20/40을 보존해 입장 변경이 전투·드롭 수치까지 바꾸지 않도록 했다. 규칙 버전9·저장 스키마·기존 원정 전투/보상 배율 유지.

검증: `lua tests/difficulty-enhancement.spec.lua`149·`expedition-presentation.spec.lua`22·`difficulty-balance.spec.lua`2661·`expedition-departure.spec.lua`42·`expedition-store.spec.lua`43, 총 **2917검사 PASS**. 기존 클리어 권리가 있어도29/59레벨은1~9 규칙 버전 모두 원정 시작을 거부하고,30/60레벨은 시작/verifyRun에 성공한다. 저장 원정 검증의 하한 우회 차단,4인 중1명 부족 시 출발 불가·모두 경계 레벨이면 가능, UI30/60 안내를 검사했다. 기존 전투·보상·출발 저장/복구 회귀도 통과했다. `/private/tmp/td233-luau/luau-compile` 변경 런타임3개 컴파일·`git diff --check` PASS.

미검증: 실제 Studio GUI·게시된 각 테스트 Experience의 Teleport/재입장·실기기/4인 입력 수용. 순수 규칙 검증을 실제 이동 증거로 간주하지 않는다. 다음 담당 QA는29/30·59/60 영웅의 솔로/4인 혼합 파티 및 과거 낮은 레벨 원정 재입장을 확인한다. Roblox 게시·릴리스 태그 없음. 기존 사용자 모델/첨부/미추적 산출물은 보존했다. 고정 빌드/푸시 결과는 후속 기록한다.

고정 소스 `11affc7af3c6b72a69c15a85fe2965d8ebef5d84`·VERSION0.79.5를 커밋해 origin/main에 푸시한 뒤 `python3 tools/build-game.py --source HEAD --record docs/evidence/difficulty-entry-levels-20261106/build.json` 빌드 성공. [입력·명령·LFS 확인](build.json). 산출물 `builds/0.79.5/TheLastThrone-0.79.5.rbxlx`·SHA-256 `65bcafe83075b1c089a721a6b40ea978e7f78adb75c0c042c4bdf5a37923d06d` 실제 일치. `python3 tests/single-build.spec.py --artifact builds/0.79.5/TheLastThrone-0.79.5.rbxlx` 역할10·도착로딩192·마운트/실제 바이트 검사 PASS([로그](artifact-checks.log)). 신규 LFS 자산 없음, 기존 사용자 미커밋 모델은 입력에서 제외했다. 증거도 origin/main에 푸시하고 원격 SHA를 확인한다. 미게시·실제 이동/기기 수용 후속.
