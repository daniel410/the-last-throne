# 로비 TD 메뉴 버튼 · 2026-10-31

- 작업: RPG 로비 오른쪽 메뉴를 TD `LobbyHomeUI`의 `HomeOptions`와 같은 112×44 셸·톱니 아이콘·영문 `MENU` 구성으로 변경한다. 메뉴의 동작은 유지한다. 넓어진 버튼을 위해 지갑과 좁은 화면 내비게이션을 조정한다.
- 원본: TD `src/Client/LobbyHomeUI.lua`와 `StatusWindowArt.lua`. 공유 `UIIconAssets`와 `StatusWindowArtAssets`의 로컬 SHA-256은 TD 원본과 각각 `b6de17e2...` 및 `c6927fe3...`으로 일치한다. 이미지 권한과 로드 결과는 대상 환경에서 확인해야 한다.
- 참고: [Roblox 적응형 디자인](https://create.roblox.com/docs/production/publishing/adaptive-design)은 다양한 화면 크기와 입력의 레이아웃·가독성 검증을 권장한다. 이번 적용은 TD의 버튼 크기와 메뉴 동작을 보존하고 좁은 화면에서 내비게이션을 아래로 이동하는 방식이다.
- 검증: `git diff --check` 및 `rojo sourcemap default.project.json -o /tmp/tlt-lobby-menu-sourcemap.json` 성공. 네이티브 검사에 버튼 크기·아이콘·지갑 간격 및 529/530px 경계 조건을 추가했다.
- 미검증: 연결된 Studio가 없어 네이티브 검사를 실행하지 못했다. 실제 시각·터치·게임패드 및 실기기 검증이 필요하다. 게임 빌드·게시 없음. 다음 담당: UI/QA.
