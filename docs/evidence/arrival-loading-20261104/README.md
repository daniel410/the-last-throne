# 배틀 도착 로딩 유지 · 2026-11-04

작업: TLT-028/057/061/084 · ENG → QA · 0.69.4. 사용자 제보 이미지에서 이동 로딩 후 기본 캐릭터와 회색 도착 발판이 노출됐다. 원인은 기존 `TravelLoadingScreen`이 출발 측 `SetTeleportGui`만 설정하고 도착 화면을 이어받지 않던 것이다. `BattleArrival`은 검증된 원정과 에픽 생성 전 임시 안전 공간이며 게임 화면으로 공개하지 않는다.

## 변경과 근거

- Lobby/Battle 프로젝트에 `ReplicatedFirst.ArrivalLoading` 및 기존 로딩 화면 모듈·역할 값을 연결한다. 배틀은 직접 접속에도 승인된 Deepwood 이미지의 불투명 배경으로 덮고, 도착 GUI가 있으면 그림을 그대로 이어받는다. 일반 로비 최초 접속은 기존 시작 방식을 유지한다.
- 도착 GUI를 PlayerGui에 부모 지정한 뒤 기본 로딩을 제거한다. ResetOnSpawn=false와 DisplayOrder=10000으로 캐릭터 교체·게임 UI 위에서 유지한다.
- 배틀은 Tutorial 단계, 서버 CombatReady, 클라이언트 BattleController/HUD 생성 완료, 이동 잠금 해제, 현재 생존 캐릭터의 서버 SpawnReady가 모두 필요하다. 카메라가 해당 Humanoid를 따르고 초점이 캐릭터 근처여야 하며 GameplayPaused 중에는 닫지 않는다.
- 로컬 바닥 레이캐스트는 캐릭터·BattleArrival·Baseplate를 제외한다. 최종 캐릭터 위치 주변 스트리밍을 요청하고, 준비 상태를 매 렌더 프레임 다시 확인한 뒤 연속3프레임 후 닫는다. 스트리밍 API 실패 시 재시도한다. 5초 스트리밍 요청 제한은 로딩 화면의 강제 종료 시간이 아니며, 실제 바닥과 준비 상태 검사를 계속한다. 준비 실패/오류는 미완성 월드 공개로 전환하지 않는다.
- 돌아오는 로비 이동도 기존 이동 그림을 유지하고 로비의 캐릭터·카메라·현지 바닥/스트리밍 준비 뒤 닫는다. 새로운 화면 미술이나 텍스트는 만들지 않았다.
- 공식 근거(2026-11-04 확인): [TeleportService](https://create.roblox.com/docs/reference/engine/classes/TeleportService)의 GetArrivingTeleportGui/PlayerGui 재부모 지정, [ReplicatedFirst](https://create.roblox.com/docs/reference/engine/classes/ReplicatedFirst)의 초기 실행과 RemoveDefaultLoadingScreen, [Player](https://create.roblox.com/docs/reference/engine/classes/Player#RequestStreamAroundAsync)의 목적지 스트리밍 요청. 명확한 결함 수정이므로 별도 기능 비교 리서치는 생략했다.

## 검증

- `lua tests/arrival-loading.spec.lua`: 실제 초기 실행 스크립트를 서비스 모의 환경에서 실행, 108검사 PASS. 일반 로비/돌아오는 로비/배틀 전달 GUI/배틀 직접 접속, 기본 로딩 제거 전 덮개 설치, 늦은 서버·캐릭터·전투UI·잠금·카메라·바닥, GameplayPaused, 비동기 스트리밍 중 준비 철회, API 실패 재시도, 준비 뒤 연속 프레임을 확인한다. Roblox 렌더러/네트워크 검증과 구분한다.
- `lua tests/battle-startup.spec.lua`: 기존 에픽 선택 생성/재진입·전투 지연 초기화223검사 PASS.
- `/private/tmp/td233-luau/luau-compile`: ArrivalLoading/TravelLoadingScreen/init.client 컴파일 PASS.
- Lobby/Battle `rojo sourcemap` 및 `git diff --check` PASS.
- 고정 소스 Lobby/Battle 빌드 결과는 `build.json`에 기록한다. 다른 진행 작업의 미커밋 파일은 포함하지 않는다.

## 미검증과 후속

연결된 Studio가 없어 엔진 실행·실제 렌더 전환은 미검증이다. Roblox 게시·릴리스 태그를 수행하지 않는다. QA는 게시된 테스트 Lobby→Battle 및 Battle→Lobby에서 느린 네트워크/모바일 가로, 파티 늦은 합류, 입장 검증 실패/재접속, 맵 생성 실패 조건을 확인해야 한다. 스크린샷의 발판/기본 캐릭터가1프레임도 보이지 않는다는 최종 수용은 그 검증 후 가능하다. 준비가 영구 실패하면 덮개를 유지하므로 기존 플랫폼 메뉴의 나가기/재접속 경로를 사용한다. 상위 티켓은 완료 처리하지 않는다.
