# 상점 상단 배치 정리

2026-11-07 · TLT-028/043/057/084 · ENG/DES → QA · 0.83.6 · 미게시

사용자 첨부 화면과 직접 지시를 기준으로 Blacksmith의 BUY/SELL/ENHANCE를 제목 옆 첫 행에, WEAPONS/ARMOR/ACCESSORIES를 잔액 옆 둘째 행에 배치한다. Enhancement Guide는 구매/판매에서 숨기고 ENHANCE 상세의 둘째 행에 표시한다. 가이드 열기/강화 복귀는 기존 동작을 유지한다. 좁은 세로 화면은 제목·거래/분류 두 행·잔액 순으로 쌓아 버튼44px과 목록 공간을 확보한다. TD 원본 버튼/프레임과 기존 상품·가격·강화 규칙을 유지한다.

후속 사용자 요청으로 Diamond Shop의 숨긴 BUY/SELL이 차지하던 데스크톱50px 여백을 제거한다. 분류 시작Y132→82, 상품 목록Y238→188이다. 낮은 화면의 기존Y66 분류는 유지한다. 두 화면의 원인이 명확한 배치 수정이므로 제작 스킬의 결함 수정 예외에 따라 별도 게임성 리서치를 추가하지 않았다.

변경: `src/client/ArmoryView.luau`, 기존 모바일 검사에서 구매 중 가이드 노출 기대를 숨김 계약으로 갱신. 기존 사용자 모델/이미지/첨부 변경은 제외한다.

후보 검증: `rojo build default.project.json -o /tmp/tlt-blacksmith-review.rbxlx`, `run-in-roblox`의 실제 GUI 생성자를 사용한 상점 한정 모바일 검사784조건 PASS, 7화면×6모드의 버튼 경계/텍스트/44px/두 행/가이드 표시/목록 최소공간1533조건 PASS. 구매·저장 요청은 보내지 않는다. 변경 전부터의 이미지203785492 타입 경고는 남아 있다. 최종 빌드 검증은 아래에 후속 기록한다.

현재 Studio Play에서 임시 복제 모듈과 fixture 상태로 구매·ENHANCE 화면을 렌더하고 캡처를 관찰했다. 사용자 첨부와 같은 두 행과 ENHANCE 내부 가이드 위치를 확인한 뒤 임시 GUI/모듈을 제거했다. 기존 Studio Edit 소스 적용/Place 저장·게시와 구분한다.

미검증: 실제 휴대폰 터치·게시 클라이언트·사용자 시각 수용. 다음 담당 QA는 새 빌드의 상점 세 종류·가이드 왕복·긴 잔액·마지막 상품 스크롤을 확인한다. 부모 티켓은 In Progress를 유지하며 릴리스 태그/Roblox 게시를 수행하지 않는다.

## 고정 빌드 마감

소스 `52fcfbb3ec7bf8a7fdaeb91ade76e384af313888`를 origin/main에 커밋·푸시한 뒤 `python3 tools/build-game.py --source 52fcfbb --record docs/evidence/blacksmith-two-rows-20261107/build.json` 성공. 산출물 `builds/0.83.6/TheLastThrone-0.83.6.rbxlx`, SHA256 `f11982729ca0ed252bfb9d280b85d9d4170e31cfa0012571cf66514f9a6f56fb`. [빌드 기록](build.json). 신규 LFS 대상/전송 없음.

고정 빌드에서 상점 모바일784·Blacksmith 7화면/6모드1533·기존 구매가능 상태23·Diamond Shop 6화면 상단24, 총 **2,364조건 PASS**, `run-in-roblox` 종료0. [최종 엔진 로그](fixed-native.log). `python3 tests/single-build.spec.py --artifact builds/0.83.6/TheLastThrone-0.83.6.rbxlx` 역할10·도착로딩192·실제 마운트/구성 PASS. 상점 배치 검사는 실제 생성자/fixture와 읽기 전용 관찰을 사용했으며 신규 영구 테스트를 추가하지 않았다.

Diamond Shop도 최종 변경 소스를 임시 복제해 Studio Play에서 직접 렌더·캡처 관찰하여 제목/잔액 아래 빈 거래 행이 없어졌음을 확인했다. 관찰 후 임시 GUI/모듈 제거. 실제 Studio Edit 소스 저장/적용·게시·실기기 수용은 수행하지 않았다. 빌드 입력은 고정하고 검증 기록만 후속 커밋한다.
