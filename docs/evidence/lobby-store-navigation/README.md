# 로비 상점 분리와 왼쪽 메뉴

2026-10-31 · TLT-028/041/044/050/084 · ENG/DES → QA · 부분 구현

- ARMORY 버튼을 제거했다. TD 원본의 왼쪽 그림 타일과 명판 구성에서 영감을 받아 HEROES, ITEM SHOP, BLACKSMITH, QUEST, MAPS 아이콘을 Roblox GUI 도형으로 새로 제작했다. 기존 TD 화면·이미지 ID를 복사하지 않았다. 좁은 화면에서 축소하는 시험 배치다.
- BLACKSMITH와 Aldric은 Gold 무기만 거래한다. ITEM SHOP과 Mira는 Gold 물약·방패·방어구·장신구를 거래한다. Mira 뒤에 보급품 카운터를 추가했다. Diamond Shop은 별도다. 상점 가격/재판매가는 시험값이다.
- 물약은 하나씩 판매하며 묶음 수량과 버전을 줄인다. 계정 저장·잔액 갱신, 중복 요청·저장 불명 재시도는 기존 서버 경로를 사용한다. 상점 식별자가 있는 요청은 서버가 상품 분류를 검사한다. 구버전 요청은 호환을 위해 기존 분류를 유지한다.
- QUEST/MAPS는 선택한 영웅의 저장 진행을 요약한다. 상세 퀘스트 추적과 실제 지도 탐험은 모험 내부의 기존 기능이다.

검증: `lua tests/store-split.spec.lua` 13개, `lua tests/economy.spec.lua` 42개, `lua tests/inventory.spec.lua` 265개 통과. Studio의 실행 중인 서버에서 임시 비부모 ModuleScript로 변경 핵심 소스 8개 Luau 구문 컴파일 통과. `git diff --check` 통과. 실제 GUI 표시·상호작용·로비 배치/동선·기기/패드·다중 서버 저장은 미검증이고 별도 빌드나 게시를 하지 않았다. 다음 QA는 실제 기기에서 겹침과 텍스트/버튼 크기, NPC 상호작용 및 저장 장애를 확인한다.
