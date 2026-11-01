# 모바일 영웅 선택 화면 겹침 수정

2026-10-31 · TLT-028/031/043/061/084 · ENG/DES → QA

사용자 제공 가로 모바일 화면에서 영웅 선택 창 위에 로비 바로가기·ADVENTURES·재화·MENU가 겹치고, 고정 높이 카드의 선택 버튼이 카드 영역 아래에 잘리는 것을 확인했다. 영웅 선택 창이 실제로 표시되는 동안에만 해당 로비 요소를 숨기고 닫거나 다른 화면으로 전환하면 복원한다. 선택 화면의 ScreenGui는 Roblox Core UI 안전 영역을 명시한다.

높이가 작은 창은 제목과 닫기 버튼을 창 안에 배치하고, 네 영웅 카드를 가로 스크롤로 바꾼다. 각 카드의 초상·직업·보유 상태·선택 버튼을 보이는 높이에 맞추며 역할 설명은 작은 화면에서 생략한다. 큰 화면은 기존 카드 배치를 사용한다. 서버 로직·재화·진행 상태는 변경하지 않았다.

근거: 기존 [로비 화면 조사](../../research/2026-10-31-lobby-panels-affordability.md)를 재사용했고 2026-10-31 [Roblox 적응형 UI](https://create.roblox.com/docs/production/publishing/adaptive-design)와 [안전 영역](https://create.roblox.com/docs/reference/engine/enums/ScreenInsets)을 확인했다. 공식 문서는 화면 크기별 재배치와 Core UI 안전 영역을 설명한다. 가로 카드와 다른 메뉴의 일시 숨김은 이 화면에 대한 적용 판단이다.

검증: 0.58.5 로비 빌드의 관련 모듈 4개만 작업 소스로 바꾼 임시 격리 Studio fixture에서 `tests/lobby-panel-size-native.luau` 95개, `tests/lobby-top-menu-native.luau` 32개, `tests/lobby-wallet-native.luau` 17개 통과. 1280×800, 750×323, 390×780 GUI 호스트, 카드 선택 버튼 영역, 안전한 제목·닫기 위치, 영웅 창 열기/숨김과 메뉴·재화 복귀를 검사했다. 시험 fixture이며 정식 빌드가 아니다. 모바일 실제 화면·터치 스크롤·기기별 노치·게임패드 및 사용자 시각 수용은 미검증이다. 다음 담당 QA는 실제 기기에서 확인한다. 기존 0.58.5 게시판에는 반영하지 않았다.
