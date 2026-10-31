# 0.51.1 배틀 SETTINGS 가림 수정

작업ID: TLT-028/031/061/084 · 2026-10-31

사용자 보고의 원인은 배틀 추가 메뉴의 SETTINGS와 RETURN TO LOBBY가 모두 Y=140에 배치된 것이다. K0Hud에서 나중에 생성한 복귀 버튼이 SETTINGS를 가렸다. 복귀 버튼을 Y=190으로 옮기고 폭148로 메뉴 안에 맞춘다. 기존 설정 창과 입력 연결은 유지한다.

검증: Studio 로컬 Battle0.51.0의 실제 HUD 생성자로 수정 전 `tests/battle-menu-native.luau` 실행 시 `overlap Settings / BackToLobby` 재현. 수정 후 실제 GUI 사각형을 배율1/.72/.62에서 검사해62개 통과했다. 5개 버튼 표시·컨테이너 경계·버튼 상호 겹침·영문 SETTINGS·포인터/패드 선택 가능 상태를 확인한다. 기존 `tests/display-guides-native.luau` 설정 열기/닫기·ON/OFF·범위 표시 회귀50개도 통과했다. 이는 실기기 터치/패드 조작 수용을 대신하지 않는다.

빌드: VERSION0.51.1, 고정 소스 커밋·산출물 해시는 build.json. 미게시, 릴리스 태그 없음. 기존 미커밋 무기/로비/이동 변경은 제외한다. 다음 담당자는 QA이며 게시된 클라이언트·실기기 입력/회전 검증은 미검증이다.
