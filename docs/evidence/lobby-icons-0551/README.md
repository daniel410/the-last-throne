# 로비 메뉴 아이콘 정리 · 0.55.1

- 작업: 로그인 보상 아이콘에 기존 TD 버튼 배경을 표시하고, 로비 왼쪽 메뉴 7개를 순서대로 두 열에 배치한다. 화면 높이에 맞춰 크기를 조절하고 하단 모험 버튼 공간을 확보한다.
- 근거: TD `src/Client/LoginCalendarUI.lua`의 로그인 보상 버튼과 기존 공유 UI 테마를 참고했다. [Roblox UIGridLayout 문서](https://create.roblox.com/docs/ui/grid-table-layouts)는 동일 크기 셀, `FillDirectionMaxCells`, `LayoutOrder`를 통한 배열을 설명한다.
- 검증: 격리된 로컬 Studio Edit에서 `tests/lobby-navigation-grid-native.luau` 105개 검사 통과(1280×800, 750×323, 390×317 가상 크기). `lobby-navigation-icon-native.luau` 5개, `lobby-quest-journal-native.luau` 24개, `daily-login-ui-native.luau` 27개 검사 통과. 실제 기기와 게시 클라이언트의 시각적 수용은 별도다.
- 다음 담당: UI/QA의 실기기 시각 및 터치 수용.
