# 로비·배틀 메뉴 통일

사용자 요청: 로비 STATS & SKILLS와 GEAR & BAG을 배틀과 동일하게 표시하고 영웅 미선택 시 선택을 안내한다.

두 화면은 원래 공통 컴포넌트였으나 로비에서만 LobbyPanelLayout이 800×510으로 덮어썼다. 해당 두 창의 예외를 제거해 배틀 크기·위치를 사용한다. 데이터 수신 완료 후 영웅 미선택이면 SELECT HERO로 창을 닫고 기존 영웅 선택 화면을 연다. 로딩 중에는 미선택으로 단정하지 않는다. 다른 로비 창의 크기 정책은 유지한다.

검증: `lua tests/k0-hero-session.spec.lua` 99 PASS. 수정한 Luau 파일과 크기 회귀 fixture 컴파일 PASS, `git diff --check` PASS. 크기 fixture는 로비/배틀의 크기·위치를 여러 뷰포트에서 비교하도록 갱신했으나 Studio 실행은 하지 않았다. 실제 UI, 선택 버튼, 서버 push 및 모바일 터치는 미검증이다. 빌드·Roblox 게시 없음.
