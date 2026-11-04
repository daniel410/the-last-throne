# 지도 선택 지명 가독성 수정

2026-11-03 · TLT-028/061/084 · ENG → QA · 로컬 수정, 미게시

사용자 첨부 화면에서 Abandoned Watchtower 등 지명이 뭉개졌다. DeepwoodMapCanvas의 이름표 TextLabel에 붙인 선택 UIStroke가 기본 Contextual 모드라 글자에 금색 외곽선을 그렸다. Border 모드와 두께1을 명시해 이름표 가장자리에 선택 테두리를 표시하고, 지명 자체의 기존 TextStroke도 제거했다. TD 글꼴·배경·선택 색/전환 및 공용 로비/배틀 지도 경로를 유지한다.

근거: [Roblox UIStroke 공식 API](https://create.roblox.com/docs/reference/engine/classes/UIStroke#ApplyStrokeMode), 2026-11-03 확인. 원인이 명확한 결함 수정이므로 제작 스킬의 예외에 따라 별도 사례 조사는 생략했다.

검증:

- `rojo build /tmp/tlt-side-breakfall-qa.project.json -o /tmp/tlt-map-caption-qa.rbxlx`: 모듈 QA Place 생성 성공. 배포용 빌드가 아니므로 VERSION 유지.
- `run-in-roblox --place /tmp/tlt-map-caption-qa.rbxlx --script tests/deepwood-atlas-native.luau`: 실패. 여러 Studio 창이 열린 환경에서 격리 가드(`isolated local QA only`)가 중단했다. [실패 로그](native.log). 지도 회귀360개 PASS로 보고하지 않는다.
- 대체 검증: 연결된 0.68.0 로컬 Studio Play Client에서 수정 소스를 임시 ModuleScript로 실행하고 비표시 임시 ScreenGui에 실제 Canvas를 생성했다. 44지역의 Border 모드/글자 외곽선 제거/선택 강조 및 이전 선택 해제를 확인해 **134 PASS**. 임시 GUI와 모듈은 즉시 삭제했다. 최초 검증은 엔진 float 속성에 엄격 동등 비교를 사용해 2개 후 실패했고, 허용오차0.0001 비교로 교정 후 통과했다.
- `git diff --check`: PASS.

미검증: 전체 게임 화면의 시각 수용, 실제 모바일/패드, 게시 클라이언트. 비표시 GUI 속성 검사는 시각 검증과 구분한다. 현재 실행 중인 게임이나 Studio 원본에는 패치를 주입하지 않았다. 다음 담당 QA는 새 소스 동기화/재실행 후 지도 선택의 가독성을 확인한다. 상위 티켓은 완료로 변경하지 않는다. 기존 미커밋 변경은 보존하고 이번 지도 소스와 기록만 커밋한다. Roblox 게시/릴리스 태그 없음.
