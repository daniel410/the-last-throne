# TD 현재 소스 기준 로비 왼쪽 아이콘 크기 · 0.75.2

2026-11-05 · TLT-028/031/061/084 · ENG → QA · 로컬 수정·미게시.

사용자가 RPG 로비 왼쪽 아이콘이 TD보다 커 보인다고 보고하고 TD와 비슷한 크기를 요청했다. 프로젝트 제작 스킬·기존2026-11-01 TD 실제 크기 규칙 승인에 따라 현재 로컬 TD 원본을 읽기 전용으로 비교했다. TD 소스2개는 TD Git에서 미추적 상태였으므로 커밋 버전/라이브 게시본과 동일하다고 가정하지 않는다. [로컬 원본 경로/해시](td-source-hashes.json).

RPG `LobbyNavigationSizing.measure`의 버튼 칸 크기·간격은 이미 TD `LobbyHomeUI.navigationMetrics`와 같았다. 차이는 실제 그림/이름판의 배치에서 남은 높이를 채우는 RPG의 확대 방식이었다. TD `LobbyHomeArt.navigationAtlas`는 그림을 셀의98%너비×72%높이, 이름판을98%너비×30%높이에 각각 Fit한다. RPG도 같은 실제 표시 크기를 계산하도록 수정했다. 그림·이름판 접합과 중앙 정렬은 유지하며 원본 이미지/자르기·메뉴 수/순서/두열·동작은 유지한다. 셀과 터치 영역을 임의로 축소하지 않는다.

작은 이름판에서는 기존 GothamBlack의 BLACKSMITH가8px미만으로 줄어드는 첫 후보가 가독성 검사에 실패했다. 높이64미만 셀의 캡션을 같은 Gotham 계열의 Medium으로 바꿔 작은 이름판에서도 BLACKSMITH8px·나머지10px 이상, 모서리 여백/텍스트 수용을 모두 통과했다. 큰 화면 글꼴은 기존 GothamBlack을 유지한다. TD 운영 소스·자산·잔액·Place는 변경하지 않았다. 새 자산/업로드는 없다. 원인이 명확한 기존 크기 규칙 불일치이므로 별도 타 게임 기능 리서치는 생략했다.

검증:

- `lua /tmp/tlt-td-icon-metrics.lua`:70 PASS. TD 원본에서 `navigationMetrics` 함수만 읽어 타입 표기를 제거한 뒤 RPG와 비교한다. 3840×2160~390×317의14화면에서 width/height/rowGap/large와 실제 가로 간격이 일치했다.
- 후보 `run-in-roblox --place builds/0.75.1/TheLastThrone-0.75.1.rbxlx --script /tmp/tlt-td-icon-size-native.luau`:1,755 PASS([로그](candidate-native.log)). 실제 새 Art를 메모리에 주입한 엔진 검사다. `lobby-navigation-grid-native`1,722 + `lobby-navigation-icon-native`33. 14차례 PC/가로모바일/세로모바일 연속 리사이즈에서 TD 실제 Fit크기·원본이미지/비율·접합·이름 최소크기/모서리·두열/하단영역·보상상태를 확인했다.
- `/private/tmp/td233-luau/luau-compile`:Art/Sizing과 수정한 네이티브 테스트 컴파일 PASS.
- 기존203785492 asset type 경고는 남는다. 자산권한 성공으로 보고하지 않는다.

다른 작업의 미커밋 장비카탈로그/문서/Blender 변경을 보존하기 위해 VERSION·README·이번Art/Sizing/테스트/증거만 스테이징한다. 진행 중 plan/backlog/decisions 파일은 편집하지 않으며 기존 TD크기 일치 승인에 대한 구현 교정으로 기록한다. 고정 빌드 결과는 후속 기록으로 추가한다. 실제 모바일/PC 화면의 최종 미술·터치·게시 클라이언트·사용자 시각 수용은 미검증이며 QA 후속이다. 부모 티켓 In Progress. Roblox 게시·릴리스 태그는 수행하지 않는다.
