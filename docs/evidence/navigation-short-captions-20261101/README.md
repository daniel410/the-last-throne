# 아이콘 전용 캡션과 대장간 글씨 여백

2026-11-01 · TLT-028/061/084 · ENG → QA · 0.58.19 로컬 시험판·미게시

사용자 지정 철자를 그대로 적용해 왼쪽 아이콘 캡션만 PORTION / DIAMOND / REWORDS로 표시한다. 로비 상점 간판과 상세창 제목의 POTION SHOP / DIAMOND SHOP / LOGIN REWARDS는 유지한다. 로그인 보상 가능 상태는 RewardAvailable 속성으로 유지하며 캡션에 느낌표를 붙이지 않는다.

BLACKSMITH는 이름표의 사선 테두리를 피하도록 텍스트 너비를 셀82% 안에 맞춘다. 다른 이름표·아이콘·기능·순서는 유지한다. 기존 제작 스킬/공통 UI 계약 아래 명확한 표기/배치 교정을 수행했다.

Studio Edit/CoreGui의 기존 배치 검사300개 통과:1280×800/750×323/529×323/530×323/390×317에서 전체 메뉴 크기·순서·텍스트 수용, BLACKSMITH의 내부 폭, 세 요청 캡션, 보상 가능/불가 전환 후 REWORDS 유지와 느낌표 없음. 결과는 native-result.json, 재현은 tests/lobby-navigation-grid-native.luau를 따른다. 실제 빌드 소스/해시는 build.json에 기록한다.

실기기·실제 보상 수령·게시 수용은 미검증이다. 다음 담당 QA는 실제 클라이언트에서 아이콘 글씨와 기존 상세창 제목을 확인한다.
