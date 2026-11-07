# 모험 복귀 시 영웅 선택 유지

2026-11-06 · TLT-003/028/057/084 · ENG → QA · 0.79.2 · 로컬 수정·미게시.

드워프로 플레이한 뒤 로비에서 엘프가 선택되는 사용자 보고를 수정한다. 배틀의 returnLobby는 returning/replay만 보내고 영웅ID를 생략했으며, 새 로비의 HeroSessionService는 로드한 영웅을 ID순으로 정렬해 첫 항목을 선택했다. 첫 영웅이 엘프인 계정에서 드워프 선택이 사라지는 원인이다. 같은 Studio 세션의 복귀는 기존 선택을 보존해 이 결함을 숨겼다.

서버가 검증한 배틀 멤버의 heroId를 복귀 데이터에 포함한다. 동일 Experience의 배틀 Place에서 returning=true로 도착한 유효한 문자열만 로비 선택 힌트(lobbyHeroId)로 전달하며, 계정 로드 후 본인 소유 영웅에만 적용한다. 미보유/누락/잘못된 힌트는 기존 소유 영웅 기본값으로 복구한다. 이 힌트는 전투 입장권·소유권·보상의 원천이 아니다. 배틀 입장의 필수 영웅 검증/미보유 거부, 저장 후 이동·재시도·replay 안내와 네 클래스 원형을 유지한다. 원인이 명확한 결함 수정으로 제작 스킬의 별도 조사 예외를 적용한다.

변경: Network/ExpeditionService, Lobby/HeroSessionService, 관련 Lua 회귀 검사2개, VERSION. 기존 사용자 모델·첨부·작업 파일은 포함하지 않는다.

검증: 새 회귀 검사를 수정 전 HEAD 소스에 실행하면 두 검사 모두 실패한다(복귀 데이터의 영웅 누락, 새 로비가 선택 힌트를 필수 배틀 영웅 정보로 처리해 초기화 중단). 수정 후 `lua tests/lobby-return-hero.spec.lua`27, `lua tests/k0-hero-session.spec.lua`121, `lua tests/story-lobby-resume.spec.lua`32, `lua tests/travel-attempt.spec.lua`8, 총188검사 PASS. 실제 서비스의 복귀/입장 함수와 세션 서비스를 실행하는 결정적 fixture이며 실제 Teleport는 아니다. `/private/tmp/td233-luau/luau-compile`로 변경 런타임2개 컴파일 PASS, `git diff --check` PASS.

미검증: 실제 게시된 배틀→로비 Teleport 및 PC/모바일 선택 표시. 다음 QA는 네 영웅이 있는 계정에서 엘프 외 영웅 선택→모험 출발→로비 복귀 후 선택 카드·초상·무기·다음 출발 영웅을 확인한다. 최초 클래스/저장 영웅은 변경하지 않는다. Roblox 게시·릴리스 태그는 수행하지 않으며 부모 티켓 In Progress를 유지한다.

고정 소스 `df7dc6d41a74ed79791091f799ac5f9ecb24d418`를 origin/main에 푸시한 뒤 `python3 tools/build-game.py --source HEAD --record docs/evidence/lobby-return-hero-20261106/build.json` 성공. 단일 산출물 `builds/0.79.2/TheLastThrone-0.79.2.rbxlx`, SHA-256 `edcd83208b030eea66b4383ca67a975da635434c203920048996526c23a1200f`. `python3 tests/single-build.spec.py --artifact builds/0.79.2/TheLastThrone-0.79.2.rbxlx` PASS([로그](build-check.log)). 신규 LFS 자산은 없으며 기존 사용자 미커밋 모델은 빌드에 포함하지 않았다. 정확한 입력/검증 자산은 [빌드 기록](build.json)에 남긴다. 미게시.
