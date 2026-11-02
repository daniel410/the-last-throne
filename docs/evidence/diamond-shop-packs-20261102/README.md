# Gold 묶음·다이아몬드 무기 상품

2026-11-02 · TLT-017/028/043/045/049/061/084 · ENG → QA

- Gold 상품:500/1,000/2,000 Gold를10/20/40 RPG Diamonds에 제공한다.100 Gold 상품ID는 퇴역하며 같은ID의 지급량을 바꾸지 않는다. 이미 기록된 요청 재시도는 기존 operations 조회가 상품 조회보다 먼저 수행되어 재지급하지 않는다.
- 무기 상품: 네 클래스별 Veteran10 / Dawnforge18 Diamonds. Veteran4개는 기존 상품, Dawnforge4개 구매 경로를 추가하여 총8개다. 무료 지급 Tempered의 다이아몬드 판매 추가는 사용자 지적에 따라 철회했다. 기존 정의/능력치/요구 레벨·Gold 가격·매각가 유지.
- 기존 ArmoryView가 서버와 같은 카탈로그를 읽어 GOLD / WEAPONS / ALL 카드·가격·부족 금액·확인 구매를 구성한다. 승인된 TD 공통 UI 원본을 유지한다.
- [가격 근거·사례·시험 한계](../../research/2026-11-02-diamond-shop-pricing.md).

검증 명령/결과:

- `lua tests/diamond-gold-exchange.spec.lua`:25개 통과. 세 묶음 정확한 차감/지급·중복 요청·부족·잘못된 상점·로비 제한·지갑 상한·가방 가득·응답 불명 복구·재접속.
- `lua tests/diamond-weapons.spec.lua`:53개 통과.8개 무기 정확한 지급·차감·중복 방지·부족·Gold 재판매·환전 차익 부재.
- `lua tests/blacksmith-stock.spec.lua`:189개 통과.
- `lua tests/store-split.spec.lua`:14개 통과.
- `lua tests/economy.spec.lua`:42개, `lua tests/daily-login.spec.lua`:73개, `lua tests/inventory.spec.lua`:271개 통과.

소스 검증이며 새 빌드/Studio 실행/게시/실제 과금/실기기 수용은 하지 않았다. UI native 검증 스크립트는 새 묶음/무기 카드 기대값으로 갱신했고 미실행이다. 관련 상위 티켓은 완료 처리하지 않는다. 기존 미커밋 작업은 마감에 포함하지 않는다.
