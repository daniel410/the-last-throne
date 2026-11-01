# 지도 ZOOM 버튼 글자 잘림 수정

2026-11-01 · TLT-028/061/084 · ENG → QA · 0.58.32

사용자 첨부 화면의 ZOOM 글자 잘림을 수정했다. 기존 버튼58px에서 TDInventoryTheme 공통 캡션 좌우14px을 제외하면 글자 폭이30px뿐이었다. ZOOM 버튼을80px(캡션52px),FIT 버튼을64px로 넓히고6px 간격을 유지한다. 진행 요약 영역도 버튼과 겹치지 않게 줄였다. 기존 TD 아트·글꼴·지도 동작을 유지한다.

검증: 현재 연결된 프로젝트 Studio Play Client에 변경된 LobbyAtlas를 임시 모듈로 복제하고, `tests/lobby-atlas-native.luau`의 격리 가드/모듈 경로만 Client fixture로 바꿔 실행했다. 실제 GUI1000×750 / 366×756 / 643×293에서 캡션 TextFits·버튼 간격/창 경계·기존 지역 잠금/해금/지도 회귀72개 Pass. fixture/임시 모듈은 제거했다. 현재 PlayerGui의 기존 LobbyAtlas에도 동일한5개 Size/Position 속성을 적용했다. 사용자 Play는 유지한다.

미검증: 실기기·게시 클라이언트·독립 QA/사용자 최종 시각 수용. 다음 담당 QA는 새 빌드에서 모바일 터치와 화면 배율을 확인한다. 상위 티켓은 닫지 않는다. 다른 미커밋 작업은 보존하며 빌드 입력에서 제외한다. Roblox 미게시·릴리스 태그 없음. 고정 소스 Lobby/Battle 빌드와 해시는 build.json을 따른다.
