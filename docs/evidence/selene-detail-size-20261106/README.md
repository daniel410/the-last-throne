# Selene 상세창 축소·MENU 중첩 수정

2026-11-06 · TLT-028/057/084 · ENG → QA · 0.79.1 · 로컬 수정·미게시.

사용자 첨부1280×591 모바일 가로 화면에서 SUPPORTER DETAILS가 화면 대부분을 채우고, 오른쪽 위 CLOSE 위에 MENU가 겹쳤다. SupporterDetails는 DisplayOrder70, LobbyTopMenu는75인데 MENU의 상세창 숨김 조건에 TLTSupporterOpen이 빠져 있었다. 상세창 열기 시 카메라 전체 ViewportSize로 크기를 계산하던 부분도 실제 ScreenGui 안전영역 크기로 수정한다.

최대 크기를760×540→680×480으로 줄이고, 작은화면은 좌우32px/상하28px 여백을 둔다. 작은화면의 초상을42px로 줄이고 이름/역할/스크롤 시작점을 위로 모아 내용을 볼 공간을 확보한다. 구매 조건은 실제 줄바꿈 높이를 측정해 배치하고, 세 구매 버튼은 최소44px·닫기도44px를 유지한다. 표시 조건에 맞게 스크롤/약관/구매행을 분리해 겹치지 않게 한다. 영어 약관은1권=1메인스토리·로비 무료·완료/로비귀환 종료·미사용권 저장·자동갱신 없음의 의미를 유지하며 짧게 정리했다.

MENU는 상세창이 열리면 숨기고 닫을 때 기존 로비·다른 상세창·이동잠금 조건에 따라 복원한다. 기본 MENU의 TD 이미지·크기·위치·기능은 유지한다. 기존 TD 프레임/버튼/셀린 초상·3개 구매·서버 가격/소유/거래는 그대로다. 명확한 겹침/잘림 결함 수정이므로 제작 스킬의 예외에 따라 별도 게임 사례 조사는 생략한다.

검증: `/private/tmp/td233-luau/luau-compile`로 런타임3개와 관련 네이티브2개 컴파일 PASS, `git diff --check` PASS. `lua tests/supporter-info.spec.lua`45·support-passes30·selene-departure26, 총101검사 PASS. 기존 GUI 검사를1280×591·568×320까지 확장해 창 여백/텍스트·스크롤/약관/구매 버튼 경계·44px를 확인하고 MENU 숨김/복원/다른 상세창 중 복원 방지를 검사하도록 했다. 실제 엔진의 GUI 경계 검사는 아래 시작 실패로 실행하지 못했으며, 추가한 검사 정의를 통과 증거로 계산하지 않는다.

미검증: 사용자 실제 모바일 화면/터치/최종 시각수용·게시된 테스트 클라이언트. QA는 새 빌드에서 상세창 열기→CLOSE와 구매 버튼 노출→닫기 후 MENU복원을 확인한다. 부모 티켓은 In Progress다. TD 운영·기존 사용자 모델/첨부는 보존하며 신규 이미지 업로드·Roblox 게시·릴리스 태그는 수행하지 않는다.


고정 소스 `0c75cf49c1ec8cbdbfab9b37f6b31b911a45748b`와 VERSION0.79.1을 커밋·origin/main 푸시하고 원격 동일 SHA를 확인했다. `python3 tools/build-game.py --source HEAD --record docs/evidence/selene-detail-size-20261106/build.json` 성공. [정확한 입력·명령·해시](build.json). 산출물 `builds/0.79.1/TheLastThrone-0.79.1.rbxlx`, 실제 SHA-256 `e861644ced9e19fada2a9536a6733eb6c1b31a222ea33b3049fa30e7f0529276`. 신규 LFS 자산/전송은 없다. 기존 미커밋 모델은 고정 소스 빌드에 포함하지 않았다.

`python3 tests/single-build.spec.py --artifact builds/0.79.1/TheLastThrone-0.79.1.rbxlx`: 역할10·도착로딩108·실제 구성/마운트 검사 PASS([로그](checks.log)). 화면 검사는 `tests/supporter-details-native.luau`와 `tests/lobby-top-menu-native.luau`를 한 세션에 연결한 `/tmp/tlt-selene-detail-suite.luau`를 만들어 `run-in-roblox --place /tmp/tlt-selene-detail-candidate.rbxlx --script /tmp/tlt-selene-detail-suite.luau`로 시도했지만 Studio online 대기 시간 초과로 실행되지 않았다([로그](candidate-native.log)). 재현 시 상세창 검사는 해당 파일을 직접 실행하고, 메뉴 검사는 반환 report를 출력하는 wrapper에서 실행한다. 이번 화면 변경의 엔진 렌더·실기기 수용은 미검증이며 고정 빌드의 정적 통과와 구분한다.
