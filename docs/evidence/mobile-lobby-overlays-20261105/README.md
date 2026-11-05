# 모바일 로비 상세창 겹침·영웅 선택·보상 카드 · 0.75.1

2026-11-05 · TLT-028/031/046/052/057/084 · ENG → QA · 로컬 구현·미게시.

## 사용자 보고와 변경

사용자가 첨부한 모바일 화면4장(17:21:55 맵/퀘스트,17:23:32 영웅 선택,17:24:38 포션 상점,17:25:53 리워드)에서 재화HUD/왼쪽아이콘/재접속 버튼의 상세창 중첩, 영웅 초상을 덮는 금색 표시, 보상 카드 하단 잘림을 확인했다. 원본 첨부는 Desktop 경로에 있고 사용자 파일을 이동/수정하거나 Git에 넣지 않았다.

- `LobbyChromeVisibility`의 공통 상세창 차단 상태를 `LobbyCommerce`의 왼쪽아이콘/재접속 버튼과 `LobbyWallet`에 적용한다. 맵·퀘스트·상점3종·원정·일일보상은 기존 `TLTLobbyPanelOpen`을 사용하며 영웅/인벤토리/성장/설정/상단메뉴/지원상세/지도/스토리/이동잠금도 포함한다. 상세창이 닫혀도 다른창/전투가 열렸다면 배경을 복원하지 않는다. 상점 내부의 잔액·가격은 유지한다. PC에서도 상세창 위의 배경 컨트롤 중첩을 막는다.
- 높이500미만 또는 너비600미만인 영웅 카드에서 SELECTED띠/금색 이름표 채움을 제거하고 테두리2px·모서리 체크12px로 선택을 표시한다. PC는 테두리5px·체크20px·기존 금색 문구/이름표를 유지한다. 레이아웃 변경 시 양방향으로 복원되며 선택/입력/초상 원본은 유지한다.
- 같은 작은화면 조건에서 일일보상의 제목 아래 여백과 상태영역을 줄이고 카드 높이를84~104px로 맞춘다. 가로 폭490이상의 캘린더는7열, 좁은 화면은 기존4/3열을 사용하며 행수에 맞춰 높이를 계산한다. 아이콘/일차/금액/상태도 카드 안에 맞춘다. 수령 터치 영역44px·금액·UTC/중복 수령/불명 저장 재시도는 유지한다. PC의124px 카드는 유지한다.

승인 TD 프레임/버튼/초상/아이콘을 유지하며 신규 이미지·재화·저장·보상·TD 운영 변경은 없다. 원인이 명확한 겹침/잘림 결함으로 프로젝트 제작 스킬의 예외에 따라 별도 사례 리서치는 생략했다. 기존 사용자 `dwarf-refinement.blend` 변경과 미추적 자산/첨부는 보존하고 스테이징에서 제외한다.

## 검증

- `/private/tmp/td233-luau/luau-compile`: 런타임5모듈과 관련 네이티브3개 컴파일 PASS.
- 후보의 실제 클라이언트 모듈을0.75.0 로컬Place 메모리에 주입한 `run-in-roblox --place builds/0.75.0/TheLastThrone-0.75.0.rbxlx --script /tmp/tlt-mobile-ui-suite.luau`: 총208 PASS([로그](candidate-native.log)). 네트워크/실계정 없이 실제 GUI와 가상 서버상태를 사용하는 엔진 검사다.
- `tests/lobby-wallet-native.luau`:37 PASS. 모든 상세창 플래그와 닫기 복원·단계/역할·잔액/로드미확정 표시 유지.
- `tests/lobby-hero-dock-native.luau`:65 PASS. 1920×1080/1280×720/844×390/390×844에서 선택 표시와 PC복원·4클래스·XP/입력/차단 회귀.
- `tests/daily-login-ui-native.luau`:106 PASS. 1280×800/844×390/750×323/667×375/568×320/390×780에서7일카드/상태가 세로영역 안에 있고 수령버튼44px 유지. 기존 동일ID 수령/불명 저장 재시도도 검사한다.
- `lua tests/daily-login.spec.lua`:73 PASS. 보상/UTC/멱등 저장 계약 회귀.
- `git diff --check`: PASS. 기존203785492 asset type 경고는 후보 로그에 남으며 이번 수정을 자산권한 성공으로 보고하지 않는다.

고정 소스 `7df4d832e1ab1a38009d8af040882c123292ba1b`를 origin/main에 푸시하고 원격 SHA 일치를 확인했다. `python3 tools/build-game.py --source HEAD --record docs/evidence/mobile-lobby-overlays-20261105/build.json`으로 단일 Lobby/Battle 빌드 성공, 기존 LFS 입력 검증 성공·신규 LFS 자산 없음. 산출물 `builds/0.75.1/TheLastThrone-0.75.1.rbxlx`의 SHA-256은 `6bb563fd934ab67f0157b0a12c67b42d7b1027ff861824523b14463b3eb99570`로 실제 바이트를 재확인했다([빌드 기록](build.json)).

고정 산출물에서 소스 주입 없이 `run-in-roblox --place builds/0.75.1/TheLastThrone-0.75.1.rbxlx --script /tmp/tlt-mobile-ui-fixed.luau`로 동일208검사를 재통과했다([로그](fixed-native.log)). `python3 tests/single-build.spec.py --artifact builds/0.75.1/TheLastThrone-0.75.1.rbxlx`도 실제 구성/마운트·역할10·도착로딩108 검사를 통과했다.

 실제 모바일 터치/클라이언트 렌더·사용자 최종 시각수용·게시된 계정 저장은 미검증이다. 엔진의 기하/상태검사를 실기기 화면수용으로 대신하지 않는다. 다음 담당 QA: 새 빌드에서 각 상세창 열기/닫기·PC선택보존·모바일 보상카드 가독성을 직접 확인한다. 부모 티켓 In Progress. Roblox 게시·릴리스 태그는 수행하지 않는다.
