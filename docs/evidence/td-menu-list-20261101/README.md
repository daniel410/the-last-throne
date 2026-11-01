# TLT-028/031/052/084 — TD 메뉴 리스트 룩앤필

2026-11-01 · 0.58.23 · 로컬 시험판, 미게시.

사용자 첨부 TD 메뉴 리스트와 현재 로컬 원본을 비교했다. TLT의 MENU를232px 폭 TD 원본 금속/금색 테두리·남색 패널,52px 파란 버튼,40px 왼쪽 아이콘, 금색 구분 제목으로 변경했다.16px 안쪽 여백·6px 항목 간격·GothamBold·caption inset60/24·원본 slice scale.45를 적용했다. 이미지 로딩 완료 뒤 native 배경/외곽선을 숨겨 원본 뒤에 둥근 사각형이 비치지 않도록 했다. 로딩 실패 시에는 기본 버튼 배경을 남긴다.

TLT의 기존 기능을 SUPPLIES(Gear & Bag), PROGRESS(Stats & Skills / Journal), MORE(Settings)로 묶었다. TD 기능을 새로 구현하거나 TD 전용 Battle Pass/메일/코드 기능을 추가하지 않았다. MENU 위치·단축키·패널 가림과 열릴 때 재화 숨김/닫힐 때 복원은 유지한다. 짧은 화면은 리스트만 세로 스크롤한다. [원본 경로/해시/치수](source-provenance.json).

## 검증

- `tests/lobby-top-menu-native.luau`: fresh ModuleScript identity로45개 검사 통과. 기존4개 action 연결, 카테고리/원본 이미지/치수,4개 화면 규격(1920×1080,1280×720,844×390,390×844) 경계, 재화 숨김/복원, 다른 패널/전투 가림을 검사했다.
- 초기 fixture는 이전 Wallet require 캐시로 위치 검사 실패. 최신 identity로 재실행했다. 이후 slice scale.45를 float 속성에 엄격 비교해 실패한 검사를 허용 오차.00001로 수정했다. CoreGui의 Edit 측정 크기는0이므로 fixture는 실제 화면 규격을 명시적으로 주입한다.
- 실제 Play: 로컬0.58.16 문서의 누적 수정 환경에 이번 LobbyTopMenu 소스를 반영했다.1392×707 뷰포트에서 패널·버튼 로딩, 모든 글자 TextFits, native 배경 제거, MENU 열기→재화 숨김, Settings 클릭→기존 설정창 열림/메뉴 닫힘을 확인했다. 로딩 이벤트만 사용했을 때 배경 제거가 반영되지 않아 TD와 같은 PreloadAsync 성공 콜백에서도 갱신하도록 수정하고 실제 Play에서 재검증했다. [결과](studio-results.json) · [실제 화면](studio-desktop.jpg).
- 커밋 고정 소스의 로비·배틀 빌드/해시: [build.json](build.json).

모바일 실제 터치·게임패드·게시된 클라이언트와 사용자 미술 수용은 후속이다. 기존 미커밋 작업은 포함하지 않는다. 다음 담당 QA는 짧은 화면 스크롤과 실제 기기 포커스를 확인한다. 상위 티켓/출시 게이트는 완료로 변경하지 않는다.
