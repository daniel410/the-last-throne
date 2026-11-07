# 모바일 Heroes 네 영웅 표시 수정

2026-11-06 · TLT-028/057/084 · 0.79.6 · 로컬 수정·미게시 · ENG → QA.

사용자 첨부1280×591에서 마법사가 화면에 없고 선택할 수 없었다. 짧은 패널의 UIGridLayout 셀 폭이32%여서 네 번째 카드는 다음 줄로 밀리는데 스크롤은 X만 허용했다. 셀 폭을25%−8px로 줄여 간격10px 포함 네 카드가 한 행에 들어가게 한다. 초상의 가로폭을 카드에 맞게 축소하고 세로6px도 줄여 SELECT HERO 버튼을38→44px로 확보한다. 이름표/레벨을6px 위로 옮기고 작은 폭에서 버튼 글자를10px로 조절한다. 기존 TD 초상/프레임/버튼, 서버 선택·생성 계약은 유지한다. 원인이 명확한 결함으로 제작 스킬의 별도 사례 리서치 예외를 적용한다.

변경: `src/client/HeroLobbyGui.luau`, 기존 GUI 회귀 `tests/lobby-panel-size-native.luau`, VERSION. GUI 검사는 사용자 크기1280×591·작은568×320을 추가해 네 클래스 버튼 모두의 X/Y경계·동일 행·44px를 검사한다. 기존1280×800·750×323·390×780도 유지한다.

검증/빌드 결과는 후속 기록한다. 실제 모바일 터치·최종 시각수용·게시 클라이언트는 미검증이다. 다음 QA는 새 빌드에서 HEROES 열기→Mage 선택 및 네 클래스 전환·가로/세로 회전·PC 복원을 확인한다. 부모 티켓은 In Progress다. 기존 미커밋 Blender/첨부 파일은 포함하지 않는다.

검증 결과:

- `/private/tmp/td233-luau/luau-compile` 런타임/수정 GUI 검사2파일 컴파일 PASS, `git diff --check` PASS.
- 고정 소스 `fdcf7e9732a8b05bbca34eb2af01f8538910be34`를 origin/main에 푸시하고 원격 동일SHA를 확인했다. `python3 tools/build-game.py --source HEAD --record docs/evidence/mobile-heroes-fit-20261106/build.json` 성공. 산출물 `builds/0.79.6/TheLastThrone-0.79.6.rbxlx`, SHA-256 `566e767ef3ca92d8ad8d4197e17be29766cb945199f3e9b4d8b1b0918208b441`. 신규 LFS 자산/전송 없음.
- `python3 tests/single-build.spec.py --artifact builds/0.79.6/TheLastThrone-0.79.6.rbxlx`: 역할10·도착로딩192·실제 구성/마운트 PASS([로그](checks.log)).
- 기존 전체 `tests/lobby-panel-size-native.luau` 실행은7번째 `non-lobby launcher visibility is preserved`에서 실패하여 Heroes 배치 루프까지 도달하지 않았다([로그](native.log)). 이번 배치와 무관한 기존 메뉴 표시 검증 실패이며 전체 로비 통과로 보고하지 않는다.
- 동일 검사에서 실제 HeroLobbyGui 생성·표시·억제와 Heroes 배치 검사만 추출한 [실행 fixture](focused-native.luau)를 `run-in-roblox --place builds/0.79.6/TheLastThrone-0.79.6.rbxlx --script /tmp/tlt-mobile-heroes-focused.luau`로 실행: **85검사 PASS**([로그](focused-native.log)). 1280×800·1280×591·844×390·750×323·568×320·390×780 생성. 짧은 패널의 네 클래스 선택 버튼 X/Y경계·동일 행·44px 및 제목/닫기 경계 확인. 세로 화면의 기존2열 스크롤은 유지한다. source 주입 없이 고정 빌드의 실제 모듈을 사용했고 LocalPlayer만 fixture로 대체했다. 엔진 기하 검사이며 실제 터치/시각수용과 구분한다.
- 네이티브 실행 후 해당 run-in-roblox/Studio 프로세스가 남아 있지 않음을 확인했다. 기존203785492 asset-type 경고는 로그에 보존했으며 이미지 로드 권한 수용으로 보고하지 않는다.

Roblox 게시·릴리스 태그는 수행하지 않았다. 증거 기록을 별도 커밋·푸시한다.
