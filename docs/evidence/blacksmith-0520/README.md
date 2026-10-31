# 대장간 카테고리·신규 품목·TD 포탈 아이콘0.52.0

TLT-028/043/046/061/084 · 2026-10-31

BUY/SELL에 ALL / WEAPONS / ARMOR / ACCESSORIES를 제공한다. 기존 품목에 Dawnforge 무기4종, Sentinel 방어구5종, Ruby Ring/Guardian Charm/Storm Pendant를 추가한다. Gold 판매 품목은 무기12·방어구11·액세서리5이며 신규 Lv10 장비12종의 가격/능력치는 시험값이다. 기존 아이템/보상 정본·다이아몬드 상품ID는 보존한다. 물약은 Item Shop에서 구매한다. 구매/판매의 서버 권한과 UI 필터는 EconomyCatalog.allowed를 공유하며 기존 가방 지급·중복 요청·저장 복구 경로를 따른다. HP 증가 수치도 카드에 표시한다.

TD 표지판에 universe10770905829의 실제 GameIcon을 표시하며 영문 목적지 제목과 단독 이동 안내를 유지한다. ../throne-defense 운영 코드는 수정하지 않는다. [원본/사례/적용 근거](../../research/2026-10-31-blacksmith-and-td-icon.md).

검증: `lua tests/blacksmith-stock.spec.lua`181개, 기존 economy42개·starter-potions-and-shop170개 통과. 신규/기존 전 판매품 구매·재요청·판매·재요청 및 물약/Diamond 상점 위조 거부를 검사했다. Studio 실제 GUI/아이콘68개 통과, TD 이미지 다운로드 Success·IsLoaded=true. 결과는 native.json, 고정 소스 빌드는 build.json에 기록한다.

미검증: 게시 클라이언트·실기기 UI/입력·정상 성장의 가격/능력치 최종 밸런스. 게시하지 않으며 릴리스 태그 없음. 다음 담당자는 QA다. 기존 다른 작업의 미커밋 포탈 이동/안내 변경은 커밋·빌드에서 제외한다.
