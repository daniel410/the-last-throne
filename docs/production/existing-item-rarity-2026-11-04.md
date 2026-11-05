# 기존 아이템 등급과 상세 화면 표시

> **2026-11-05 / 0.75.0:** 아래51종은 당시 기존품 분류 스냅샷이다. 현재는 [대장간 Epic12종](forge-diamond-sales-2026-11-05.md)을 추가해 전체63종이며 기존51종의 등급/수치는 유지한다.

2026-11-04 · TLT-028/029/043/052/084 · ENG/DES → QA

기존 서버 카탈로그51종의 등급을 확인하고 기본 장비의Common 지정도 명시했다. 기존 장비33종은Common10/Uncommon11/Rare12, 물약/재료를 포함한 전체51종은Common20/Uncommon14/Rare17이다. 기존ID·표시 이름·능력치·가격·소유 인스턴스·강화 원장은 변경하지 않는다. `UnCommon`이라는 별도 등급은 만들지 않고 기존 키/표준 표기 **Uncommon**을 사용한다. [기계 판독 목록](../../assets/economy/existing-item-rarity-assignments-2026-11-04.json)은 이번 카탈로그 분류의 스냅샷이다.

기본 검/활/도끼/지팡이·방패, Traveler 방어구, Copper Ring은Common이다. Tempered/Veteran 무기·Citadel Shield·Amber Charm·Veteran Hood는Uncommon이다. Dawnforge/Sentinel과Lv10 장신구는Rare를 유지한다. 레어/에픽/레전더리 신규120종의 [수치 시험안](equipment-item-stats-2026-11-04.md)과 기존51종은 다른 정의이므로 자동 대체/승급하지 않는다.

## 개별 분류

| 기존 아이템 ID | 이름 | 분류 | 등급 | 착용Lv 또는 기본표시Lv |
| --- | --- | --- | --- | ---: |
| `amber_charm` | Amber Charm | Equipment | **Uncommon** | 1 |
| `copper_ring` | Copper Ring | Equipment | **Common** | 1 |
| `dwarf_weapon` | Training Axe | Equipment | **Common** | 1 |
| `dwarf_weapon_fine` | Tempered Axe | Equipment | **Uncommon** | 1 |
| `dwarf_weapon_forged` | Dawnforge Axe | Equipment | **Rare** | 10 |
| `dwarf_weapon_veteran` | Veteran's Axe | Equipment | **Uncommon** | 5 |
| `elf_weapon` | Training Bow | Equipment | **Common** | 1 |
| `elf_weapon_fine` | Tempered Bow | Equipment | **Uncommon** | 1 |
| `elf_weapon_forged` | Dawnforge Bow | Equipment | **Rare** | 10 |
| `elf_weapon_veteran` | Veteran's Bow | Equipment | **Uncommon** | 5 |
| `enhancement_gem` | Enhancement Gem | Materials | **Uncommon** | 1 |
| `equipment_cache_1` | Level 1 Equipment Cache | Materials | **Rare** | 1 |
| `equipment_cache_10` | Level 10 Equipment Cache | Materials | **Rare** | 1 |
| `equipment_cache_5` | Level 5 Equipment Cache | Materials | **Rare** | 1 |
| `forge_core` | Forge Core | Materials | **Rare** | 1 |
| `guardian_charm` | Guardian Charm | Equipment | **Rare** | 10 |
| `health_potion` | Small Health Potion | Consumables | **Common** | 1 |
| `health_potion_large` | Large Health Potion | Consumables | **Common** | 1 |
| `health_potion_medium` | Medium Health Potion | Consumables | **Common** | 1 |
| `health_potion_xl` | XL Health Potion | Consumables | **Common** | 1 |
| `iron_ore` | Iron Ore | Materials | **Common** | 1 |
| `king_shaman_seal` | King Shaman Seal | Materials | **Uncommon** | 1 |
| `knight_shield` | Training Shield | Equipment | **Common** | 1 |
| `knight_shield_fine` | Citadel Shield | Equipment | **Uncommon** | 1 |
| `knight_weapon` | Training Sword | Equipment | **Common** | 1 |
| `knight_weapon_fine` | Tempered Sword | Equipment | **Uncommon** | 1 |
| `knight_weapon_forged` | Dawnforge Sword | Equipment | **Rare** | 10 |
| `knight_weapon_veteran` | Veteran's Sword | Equipment | **Uncommon** | 5 |
| `mage_weapon` | Training Staff | Equipment | **Common** | 1 |
| `mage_weapon_fine` | Tempered Staff | Equipment | **Uncommon** | 1 |
| `mage_weapon_forged` | Dawnforge Staff | Equipment | **Rare** | 10 |
| `mage_weapon_veteran` | Veteran's Staff | Equipment | **Uncommon** | 5 |
| `magic_stone` | Magic Stone | Materials | **Rare** | 1 |
| `mana_potion` | Small Mana Potion | Consumables | **Common** | 1 |
| `mana_potion_large` | Large Mana Potion | Consumables | **Common** | 1 |
| `mana_potion_medium` | Medium Mana Potion | Consumables | **Common** | 1 |
| `mana_potion_xl` | XL Mana Potion | Consumables | **Common** | 1 |
| `ruby_ring` | Ruby Ring | Equipment | **Rare** | 10 |
| `sentinel_boots` | Sentinel Boots | Equipment | **Rare** | 10 |
| `sentinel_gauntlets` | Sentinel Gauntlets | Equipment | **Rare** | 10 |
| `sentinel_helm` | Sentinel Helm | Equipment | **Rare** | 10 |
| `sentinel_mail` | Sentinel Mail | Equipment | **Rare** | 10 |
| `sentinel_shield` | Sentinel Shield | Equipment | **Rare** | 10 |
| `soft_hide` | Soft Hide | Materials | **Common** | 1 |
| `storm_pendant` | Storm Pendant | Equipment | **Rare** | 10 |
| `traveler_boots` | Traveler's Boots | Equipment | **Common** | 1 |
| `traveler_coat` | Traveler's Coat | Equipment | **Common** | 1 |
| `traveler_gloves` | Traveler's Gloves | Equipment | **Common** | 1 |
| `traveler_hood` | Traveler's Hood | Equipment | **Common** | 1 |
| `veteran_hood` | Veteran's Hood | Equipment | **Uncommon** | 5 |
| `warlord_seal` | Orc Warlord Seal | Materials | **Uncommon** | 1 |

물약/재료의Lv1은 카탈로그에 착용 제한이 없어 화면에 쓰는 기본값이며 장비 착용 조건이 아니다. 재료·상자의Rare 표시는 개봉 결과Rare 보장이나 회복량/재료 효과의 배율을 뜻하지 않는다.

## 상세 화면 동작

가방·장착품·미수령·모바일 상세와 데스크톱 창고 요약에 `RARITY: Common` 같은 영어 등급명을 항상 표시한다. 이전에는 일반 상세에서DETAILS를 펼친 경우에만 작은 회색 글씨로 나왔다. 이제14px 굵은 글씨와 등급색(Common 회색/Uncommon 녹색/Rare 파랑/Epic 보라/Legendary 주황/Unique 금색)을 함께 사용한다. 승인된TD 원본 프레임·버튼·아이콘을 유지한다. 신규 장비가 연결되면 같은6등급 표시 경로를 사용한다. 알 수 없는 등급은Unknown으로 표시하며Common으로 덮어쓰지 않는다.

검증과 빌드/미검증 범위는 [실행 기록](../evidence/item-rarity-details-20261104/README.md)을 따른다. 실제Studio/게시 클라이언트·모바일/패드 시각 수용은 후속이다. 다음 담당자는 QA/DES의 기본 상세/DETAILS/창고·가방·미수령 및 좁은 화면 검수다.
