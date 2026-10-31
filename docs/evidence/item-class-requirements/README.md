# 아이템 직업 제한 표시

2026-10-31 · TLT-028/041/044/050/084 · ENG → QA · 부분 구현

검·도끼·활·지팡이의 기본/상위 아이템은 각각 Knight·Dwarf Axe Thrower·Elf Archer·Mage의 classId를 가진다. 서버는 장착 요청과 저장 프로필 검증에서 이를 확인한다. 기사 방패도 Knight 전용이다. 다른 직업 장비의 구매/보관은 허용한다.

가방과 창고 상세에 장착 가능 직업을 표시하고, 일반 상점 및 Diamond Shop 구매와 판매 목록에도 같은 정보를 표시한다. 다른 직업 영웅으로 구매할 때 장착 불가 안내를 함께 보여준다. 공용 방어구는 모든 직업으로 표시한다. 텍스트는 InventoryText의 영어 키와 카탈로그 classId를 사용한다.

검증: `lua tests/inventory.spec.lua` 265개, `lua tests/economy.spec.lua` 42개 통과. 서버 장착 4직업 × 4무기 조합 16개 통과. `git diff --check` 통과. 빌드/Studio 화면 및 터치·패드, 실제 저장과 사용자 수용은 미검증이다. 다음 QA는 좁은 화면 글자 잘림과 구매/판매 확인을 검증한다.
