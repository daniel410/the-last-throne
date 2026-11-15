# RPG 다이아몬드 Robux 상품

작업: TLT-041/049/084 · 소프트웨어 엔지니어 · 소스 구현/검증, 실제 상품 생성 권한 대기. 상위 티켓/G3/G7 완료 아님.

사용자 요청: 다이아몬드 로벅스 상품을 TD 참고하여 추가.

## 변경과 근거

- TD 현재100/500/1,200 Diamonds와 기본49/199/399 Robux를 참고한 `DiamondProducts` 카탈로그. [조사·출처·미검증](../../research/2026-11-14-diamond-robux-products.md).
- 기존 TD 프레임/버튼/다이아 아이콘을 사용한 Diamond Shop의 ROBUX 탭과 ALL 카드. 수량·RPG 전용 지급처 표시, 표시 가격은 `GetProductInfoAsync`로 조회한다. 로딩/조회 실패/미설정/Studio/지갑 미준비는 구매 비활성이다. 7개 카테고리는 넓은 화면4열/좁은 화면3열로 배치한다.
- 서버의 유일한 `ProcessReceipt`는 로비/배틀 공통 시작점에 연결했다. 확인된 RPG 상품만 처리하며 클라이언트 완료 신호로 지급하지 않는다. 계정 단일 키에 잔액+영구 구매ID 장부를 함께 저장한다. 기존96개 일반 요청 기록의 퇴출과 유료 영수증은 독립이다.
- 기존 계정 lease/epoch와 busy를 사용하며 저장 응답 불명은 같은 영수증만 재시도한다. 다른 서버/로드 실패/부재 플레이어/잔액 상한/알 수 없는 상품/Studio에서는 구매를 확정하지 않는다. 영웅 미선택/변경·가방 용량과 무관하게 계정 지갑에 지급한다. TD 소스/잔액/상품은 변경하지 않았다.

## 실제 API 상태

2026-11-14 Studio MCP에서 RPG Universe10773575153의 상품 목록을 조회했다. HTTP200, `developerProducts=[]`, `nextPageToken=null`이다. TD100/500/1,200 상품의 Marketplace 조회 가격은49/199/399였다.

100 Diamonds의 RPG 전용 상품을 판매 비활성으로 생성하는 요청은 인증 토큰 취득 단계에서 거절됐다: `Scope 'developer-product:write' has not been granted.` 생성/외부 상품 변경은 발생하지 않았다. 사용자에게 Studio Assistant MCP Permissions 권한 설정을 요청했다. 권한 우회는 하지 않았다. 카탈로그 ProductId는 모두0으로 유지하므로 실제 구매가 열리지 않는다. referencePrice는 TD 비교값이며 실제 결제 표시에는 사용하지 않는다.

## 검증

- `lua tests/diamond-products.spec.lua`:34검사 통과. 세 묶음·재구매·중복·잘못된 구매자/상품/구매ID·상한·영수증 충돌/손상·응답 유실·재접속·동시 서버 fence·로드 실패.
- `lua tests/diamond-product-service.spec.lua`:12검사 통과. 저장 성공 때만 확정, Busy/Unavailable/SaveUnknown/AccountBusy/BalanceLimit/ReceiptConflict/예외는 미확정, TD/Studio/부재/다른 상품 지급 거부.
- `lua tests/diamond-gold-exchange.spec.lua`:25, `economy.spec.lua`:38, `inventory.spec.lua`:276, `store-split.spec.lua`:14, `delivery.spec.lua`:34, `delivery-remote.spec.lua`:9검사 통과.
- Luau 컴파일러:변경된8개 런타임 파일 통과.
- 실제 Studio Edit, 임시 ModuleScript/GUI로 `tests/diamond-product-ui-native.luau`:42검사 통과.1280×720/844×390/390×650에서 스크롤 높이306/178/256px, 카테고리 겹침 없음, 세 상품·Studio 구매 비활성·RPG 안내·기존 Gold 탭 보존·렌더 시 구매 요청0. 시험 객체는 제거했다. 실제 Play/결제 검증은 아니다.
- 기존 `diamond-weapons.spec.lua`는15행 `Economy.offer(def.id)`가nil이라 실패했다. 변경 전 HEAD06d40455의 격리된 소스에서도 동일 실패를 재현했다. 이번 상품 추가가 해당 카탈로그/테스트를 변경하지는 않았다.
- `git diff --check` 통과. 빌드/버전 증가/게시/릴리스 태그 없음.

## 다음 담당·남은 수용

사용자: Studio Assistant MCP Permissions의 `developer-product:write` 허용. 엔지니어: RPG 상품을 중복 조회 후 생성하고 ProductId/Universe/수량/기본가격을 대조, 실제 아이콘·판매 상태 연결. 상품 생성만으로 실제 판매 동작 완료 처리하지 않는다. 상품 쓰기 API는 multipart 요구이므로 연결 도구의 지원도 확인해야 한다.

엔지니어/QA: 상품ID 연결 뒤 고정 소스 빌드와 Studio Play, 게시 클라이언트의 가격/결제/저장/재접속·동시 영수증·영웅 변경·로비↔배틀 복구 및 실기기 수용. 실제Robux 지출 테스트는 아직 수행하지 않았다. 영구 장부의 장기 키 크기/운영 복구는 후속이다.
