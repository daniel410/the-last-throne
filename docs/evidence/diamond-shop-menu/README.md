# 로비 Diamond Shop 시험 구현

2026-10-31 · TLT-028/041/044/050/084 · ENG → QA/DIR · 부분 구현

HERO와 BAG의 상단 좌표와 높이를 같게 맞추고, 로비에서 HERO 왼쪽에 DIAMOND SHOP을 둔다. 좁은 화면에서는 세 버튼이 함께 축소된다. 상점은 기존 Veteran 무기4종과 방패·방어구·장신구8종을 RPG 계정 Diamonds로 판매한다. 신규 가격은 시험값이다. 기존 서버 카탈로그, 가방 용량·영웅 자격·revision·요청ID 검증 및 계정 단일 키 저장 경로를 사용한다. TD와 지갑을 공유하지 않는다.

검증: `lua tests/economy.spec.lua` 42개 통과. 신규8종의 지급·차감·중복 재요청을 포함한다. `git diff --check` 통과. 로컬 소스 변경이며 빌드·Studio 화면·작은 화면 터치·저장 장애 실서버·실기기와 밸런스는 미검증이다. 실제 Robux 충전 상품, 상품 ID 및 ProcessReceipt는 구현하지 않았고 활성화하지 않았다. 다음 담당 QA는 Studio/실기기 및 영속 저장을 확인하고, DIR/ENG는 가격과 충전 상품 계약을 정한다.
