# 방향키 동시 입력 중 스프린트 처리 수정

2026-11-06 · TLT-005/006/032/033/084 · ENG → QA · 0.78.1 · 부모 티켓 In Progress.

사용자는 방향키 두 개를 함께 누르면 스프린트가 되지 않는 문제를 보고했다. 프로젝트 제작 스킬과 엔지니어 역할에 따라 기존 입력 경로를 확인했다. 원인이 명확한 입력 경로 수정 범위로 별도 게임성 리서치는 수행하지 않았다.

## 변경과 근거

`src/client/BattleController.luau`의 스프린트 E / ButtonL3 시작을 일반 `UserInputService.InputBegan`의 `processed` 조기 반환 뒤에서 별도 `ContextActionService:BindActionAtPriority` High 바인딩으로 옮겼다. 방향키에는 바인딩하지 않아 기본 이동 처리를 유지한다. 기존 회피와 같은 입력 방식을 사용하며 터치 버튼과 서버 속도/행동 검사는 유지한다. End/Cancel에서는 메뉴 등으로 입력 자격이 사라져도 해제한다. 일반 InputEnded의 기존 해제도 멱등적으로 유지한다.

기존 경로에서는 processed 입력이 스프린트 시작 전에 차단되는 것이 소스로 확인된다. 다만 사용자의 실제 키 조합에서 processed가 true였는지는 계측하지 않았으므로 보고된 현상의 원인으로 확정하지 않는다. 수정은 이 차단 경로를 제거한다. API 근거는 2026-11-06 확인한 [Roblox ContextActionService](https://create.roblox.com/docs/reference/engine/classes/ContextActionService)와 [ContextActionPriority](https://create.roblox.com/docs/reference/engine/enums/ContextActionPriority)다.

## 검증

- `lua tests/sprint-input.spec.lua`: 67검사 PASS. 실제 소스의 스프린트 생명주기와 바인딩 콜백을 추출하여 엔진 경계를 stub으로 대체한다. 방향키 조합8개를 가정한 반복 시작/lease 갱신/해제·중복 Begin/End·입력 자격 차단·Cancel을 검사한다. 물리 키 이벤트나 실제 기본 이동 스크립트를 시뮬레이션한 검사가 아니다.
- Studio `TheLastThrone-0.78.0.rbxlx` Edit에서 수정 BattleController 전체를 `loadstring`으로 컴파일: PASS. 모듈 실행·DataModel 수정은 하지 않았다.
- `lua tests/k0-rules.spec.lua`: 실패. 변경하지 않은 서버 `beginEnemyAttack`의 Luau `+=`를 Lua `load`로 읽는 fixture에서 syntax error near '+'가 발생한다. 해당 서버/테스트는 이번 수정 범위 밖이며 전체 회귀 통과로 보고하지 않는다.
- `git diff --check`: 통과. 고정 소스 단일 빌드 결과는 [build.json](build.json)에 기록한다.

## 미검증과 다음 담당

실제 키보드의 W+A/E 등 동시 입력·방향키 전환·실제 대각선 속도·패드/터치·게시 클라이언트/실기기는 미검증이다. QA는 수정 빌드에서 먼저 방향키 두 개→E, E→방향키 두 개 순서 모두의 속도24와 E해제 후16 복귀(이동속도 보정 없는 조건), 메뉴/채팅 입력 차단을 확인한다. 하드웨어가 키 입력 자체를 보내지 않는 경우는 이번 소프트웨어 경로 검사로 확인할 수 없다. TD·라이브 DataStore·Place 게시·릴리스 태그는 변경하지 않는다.
