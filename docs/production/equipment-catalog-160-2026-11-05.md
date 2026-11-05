# 장비 160종 등급과 영웅 클래스 제한 목록

2026-11-05 · TLT-028/029/052/084 · PLAN/DES → ENG/QA

[160종 통합 화면](../../assets/concepts/2026-11-04-equipment-icons/catalog-160.html)에서 이미지·등급·클래스 제한·이름을 한 표로 확인하고 검색/필터할 수 있다. [동일 JSON](../../assets/concepts/2026-11-04-equipment-icons/catalog-160.json)은 generation.json/manifest의 이미지 메타데이터와 현재 재산정 JSON의 레벨에서 생성했다. 아래 목록은 생성한 아이콘160종이며 게임에160종이 모두 구현됐다는 뜻은 아니다. 기존 Common/Uncommon 및 대장간의 별도 런타임 품목은 이160종에 합산하지 않는다.

| 구분 | Rare | Epic | Legendary | Unique | 합계 |
| --- | ---: | ---: | ---: | ---: | ---: |
| 공통 · 모든 영웅 | 11 | 11 | 11 | 11 | 44 |
| Knight 전용 | 8 | 8 | 8 | 8 | 32 |
| Elf Archer 전용 | 7 | 7 | 7 | 7 | 28 |
| Dwarf Axe Thrower 전용 | 7 | 7 | 7 | 7 | 28 |
| Mage 전용 | 7 | 7 | 7 | 7 | 28 |
| 합계 | 40 | 40 | 40 | 40 | 160 |

클래스 전용은 기본 클래스 조건이며 두 전직 계열 중 하나만의 전용품이라는 뜻은 아니다. 공통 MP품은 착용 가능 클래스와 MP 보너스 적용 자격을 구분한다. Unique 착용Lv60은 사용자 확정이며 Rare10/Epic20/Legendary40은 재산정 시험 기준이다. Unique Lv60 재산정은 v2 수치안을 사용하며 게임 등록/효과/드롭 수용은 후속이다.

| 번호 | 등급 | 영웅 클래스 제한 | 이름 | 부위 | 착용Lv |
| --- | --- | --- | --- | --- | --- |
| 001 | Rare | 공통 · 모든 영웅 | `Rare_Wayfarer_Hood` | 머리 | 10 · 시험안 |
| 002 | Rare | 공통 · 모든 영웅 | `Rare_Wayfarer_Coat` | 몸통 | 10 · 시험안 |
| 003 | Rare | 공통 · 모든 영웅 | `Rare_Wayfarer_Gloves` | 손 | 10 · 시험안 |
| 004 | Rare | 공통 · 모든 영웅 | `Rare_Wayfarer_Boots` | 발 | 10 · 시험안 |
| 005 | Rare | 공통 · 모든 영웅 | `Rare_Arcane_Reservoir_Pendant` | 장신구 | 10 · 시험안 |
| 006 | Rare | 공통 · 모든 영웅 | `Rare_Mana_Ring` | 장신구 | 10 · 시험안 |
| 007 | Rare | 공통 · 모든 영웅 | `Rare_Refuge_Charm` | 장신구 | 10 · 시험안 |
| 008 | Rare | 공통 · 모든 영웅 | `Rare_Valor_Ring` | 장신구 | 10 · 시험안 |
| 009 | Rare | 공통 · 모든 영웅 | `Rare_Vigor_Ring` | 장신구 | 10 · 시험안 |
| 010 | Rare | 공통 · 모든 영웅 | `Rare_Ward_Pendant` | 장신구 | 10 · 시험안 |
| 011 | Rare | 공통 · 모든 영웅 | `Rare_Wellspring_Charm` | 장신구 | 10 · 시험안 |
| 012 | Rare | Knight · 기사 전용 | `Rare_Knight_Oathguard_Sword` | 무기 | 10 · 시험안 |
| 013 | Rare | Knight · 기사 전용 | `Rare_Knight_Oathguard_Shield` | 방패 | 10 · 시험안 |
| 014 | Rare | Knight · 기사 전용 | `Rare_Knight_Oathguard_Headguard` | 머리 | 10 · 시험안 |
| 015 | Rare | Knight · 기사 전용 | `Rare_Knight_Oathguard_Vestments` | 몸통 | 10 · 시험안 |
| 016 | Rare | Knight · 기사 전용 | `Rare_Knight_Oathguard_Grips` | 손 | 10 · 시험안 |
| 017 | Rare | Knight · 기사 전용 | `Rare_Knight_Oathguard_Treads` | 발 | 10 · 시험안 |
| 018 | Rare | Knight · 기사 전용 | `Rare_Knight_Oathguard_Pendant` | 장신구 | 10 · 시험안 |
| 019 | Rare | Knight · 기사 전용 | `Rare_Knight_Oathguard_Signet` | 장신구 | 10 · 시험안 |
| 020 | Rare | Elf Archer · 엘프 궁수 전용 | `Rare_Elf_Briarwatch_Bow` | 무기 | 10 · 시험안 |
| 021 | Rare | Elf Archer · 엘프 궁수 전용 | `Rare_Elf_Briarwatch_Headguard` | 머리 | 10 · 시험안 |
| 022 | Rare | Elf Archer · 엘프 궁수 전용 | `Rare_Elf_Briarwatch_Vestments` | 몸통 | 10 · 시험안 |
| 023 | Rare | Elf Archer · 엘프 궁수 전용 | `Rare_Elf_Briarwatch_Grips` | 손 | 10 · 시험안 |
| 024 | Rare | Elf Archer · 엘프 궁수 전용 | `Rare_Elf_Briarwatch_Treads` | 발 | 10 · 시험안 |
| 025 | Rare | Elf Archer · 엘프 궁수 전용 | `Rare_Elf_Briarwatch_Pendant` | 장신구 | 10 · 시험안 |
| 026 | Rare | Elf Archer · 엘프 궁수 전용 | `Rare_Elf_Briarwatch_Signet` | 장신구 | 10 · 시험안 |
| 027 | Rare | Dwarf Axe Thrower · 드워프 전용 | `Rare_Dwarf_Stonehearth_Axe` | 무기 | 10 · 시험안 |
| 028 | Rare | Dwarf Axe Thrower · 드워프 전용 | `Rare_Dwarf_Stonehearth_Headguard` | 머리 | 10 · 시험안 |
| 029 | Rare | Dwarf Axe Thrower · 드워프 전용 | `Rare_Dwarf_Stonehearth_Vestments` | 몸통 | 10 · 시험안 |
| 030 | Rare | Dwarf Axe Thrower · 드워프 전용 | `Rare_Dwarf_Stonehearth_Grips` | 손 | 10 · 시험안 |
| 031 | Rare | Dwarf Axe Thrower · 드워프 전용 | `Rare_Dwarf_Stonehearth_Treads` | 발 | 10 · 시험안 |
| 032 | Rare | Dwarf Axe Thrower · 드워프 전용 | `Rare_Dwarf_Stonehearth_Pendant` | 장신구 | 10 · 시험안 |
| 033 | Rare | Dwarf Axe Thrower · 드워프 전용 | `Rare_Dwarf_Stonehearth_Signet` | 장신구 | 10 · 시험안 |
| 034 | Rare | Mage · 마법사 전용 | `Rare_Mage_Aetherweave_Staff` | 무기 | 10 · 시험안 |
| 035 | Rare | Mage · 마법사 전용 | `Rare_Mage_Aetherweave_Headguard` | 머리 | 10 · 시험안 |
| 036 | Rare | Mage · 마법사 전용 | `Rare_Mage_Aetherweave_Vestments` | 몸통 | 10 · 시험안 |
| 037 | Rare | Mage · 마법사 전용 | `Rare_Mage_Aetherweave_Grips` | 손 | 10 · 시험안 |
| 038 | Rare | Mage · 마법사 전용 | `Rare_Mage_Aetherweave_Treads` | 발 | 10 · 시험안 |
| 039 | Rare | Mage · 마법사 전용 | `Rare_Mage_Aetherweave_Pendant` | 장신구 | 10 · 시험안 |
| 040 | Rare | Mage · 마법사 전용 | `Rare_Mage_Aetherweave_Signet` | 장신구 | 10 · 시험안 |
| 041 | Epic | 공통 · 모든 영웅 | `Epic_Wayfarer_Hood` | 머리 | 20 · 시험안 |
| 042 | Epic | 공통 · 모든 영웅 | `Epic_Wayfarer_Coat` | 몸통 | 20 · 시험안 |
| 043 | Epic | 공통 · 모든 영웅 | `Epic_Wayfarer_Gloves` | 손 | 20 · 시험안 |
| 044 | Epic | 공통 · 모든 영웅 | `Epic_Wayfarer_Boots` | 발 | 20 · 시험안 |
| 045 | Epic | 공통 · 모든 영웅 | `Epic_Arcane_Reservoir_Pendant` | 장신구 | 20 · 시험안 |
| 046 | Epic | 공통 · 모든 영웅 | `Epic_Mana_Ring` | 장신구 | 20 · 시험안 |
| 047 | Epic | 공통 · 모든 영웅 | `Epic_Refuge_Charm` | 장신구 | 20 · 시험안 |
| 048 | Epic | 공통 · 모든 영웅 | `Epic_Valor_Ring` | 장신구 | 20 · 시험안 |
| 049 | Epic | 공통 · 모든 영웅 | `Epic_Vigor_Ring` | 장신구 | 20 · 시험안 |
| 050 | Epic | 공통 · 모든 영웅 | `Epic_Ward_Pendant` | 장신구 | 20 · 시험안 |
| 051 | Epic | 공통 · 모든 영웅 | `Epic_Wellspring_Charm` | 장신구 | 20 · 시험안 |
| 052 | Epic | Knight · 기사 전용 | `Epic_Knight_Oathguard_Sword` | 무기 | 20 · 시험안 |
| 053 | Epic | Knight · 기사 전용 | `Epic_Knight_Oathguard_Shield` | 방패 | 20 · 시험안 |
| 054 | Epic | Knight · 기사 전용 | `Epic_Knight_Oathguard_Headguard` | 머리 | 20 · 시험안 |
| 055 | Epic | Knight · 기사 전용 | `Epic_Knight_Oathguard_Vestments` | 몸통 | 20 · 시험안 |
| 056 | Epic | Knight · 기사 전용 | `Epic_Knight_Oathguard_Grips` | 손 | 20 · 시험안 |
| 057 | Epic | Knight · 기사 전용 | `Epic_Knight_Oathguard_Treads` | 발 | 20 · 시험안 |
| 058 | Epic | Knight · 기사 전용 | `Epic_Knight_Oathguard_Pendant` | 장신구 | 20 · 시험안 |
| 059 | Epic | Knight · 기사 전용 | `Epic_Knight_Oathguard_Signet` | 장신구 | 20 · 시험안 |
| 060 | Epic | Elf Archer · 엘프 궁수 전용 | `Epic_Elf_Briarwatch_Bow` | 무기 | 20 · 시험안 |
| 061 | Epic | Elf Archer · 엘프 궁수 전용 | `Epic_Elf_Briarwatch_Headguard` | 머리 | 20 · 시험안 |
| 062 | Epic | Elf Archer · 엘프 궁수 전용 | `Epic_Elf_Briarwatch_Vestments` | 몸통 | 20 · 시험안 |
| 063 | Epic | Elf Archer · 엘프 궁수 전용 | `Epic_Elf_Briarwatch_Grips` | 손 | 20 · 시험안 |
| 064 | Epic | Elf Archer · 엘프 궁수 전용 | `Epic_Elf_Briarwatch_Treads` | 발 | 20 · 시험안 |
| 065 | Epic | Elf Archer · 엘프 궁수 전용 | `Epic_Elf_Briarwatch_Pendant` | 장신구 | 20 · 시험안 |
| 066 | Epic | Elf Archer · 엘프 궁수 전용 | `Epic_Elf_Briarwatch_Signet` | 장신구 | 20 · 시험안 |
| 067 | Epic | Dwarf Axe Thrower · 드워프 전용 | `Epic_Dwarf_Stonehearth_Axe` | 무기 | 20 · 시험안 |
| 068 | Epic | Dwarf Axe Thrower · 드워프 전용 | `Epic_Dwarf_Stonehearth_Headguard` | 머리 | 20 · 시험안 |
| 069 | Epic | Dwarf Axe Thrower · 드워프 전용 | `Epic_Dwarf_Stonehearth_Vestments` | 몸통 | 20 · 시험안 |
| 070 | Epic | Dwarf Axe Thrower · 드워프 전용 | `Epic_Dwarf_Stonehearth_Grips` | 손 | 20 · 시험안 |
| 071 | Epic | Dwarf Axe Thrower · 드워프 전용 | `Epic_Dwarf_Stonehearth_Treads` | 발 | 20 · 시험안 |
| 072 | Epic | Dwarf Axe Thrower · 드워프 전용 | `Epic_Dwarf_Stonehearth_Pendant` | 장신구 | 20 · 시험안 |
| 073 | Epic | Dwarf Axe Thrower · 드워프 전용 | `Epic_Dwarf_Stonehearth_Signet` | 장신구 | 20 · 시험안 |
| 074 | Epic | Mage · 마법사 전용 | `Epic_Mage_Aetherweave_Staff` | 무기 | 20 · 시험안 |
| 075 | Epic | Mage · 마법사 전용 | `Epic_Mage_Aetherweave_Headguard` | 머리 | 20 · 시험안 |
| 076 | Epic | Mage · 마법사 전용 | `Epic_Mage_Aetherweave_Vestments` | 몸통 | 20 · 시험안 |
| 077 | Epic | Mage · 마법사 전용 | `Epic_Mage_Aetherweave_Grips` | 손 | 20 · 시험안 |
| 078 | Epic | Mage · 마법사 전용 | `Epic_Mage_Aetherweave_Treads` | 발 | 20 · 시험안 |
| 079 | Epic | Mage · 마법사 전용 | `Epic_Mage_Aetherweave_Pendant` | 장신구 | 20 · 시험안 |
| 080 | Epic | Mage · 마법사 전용 | `Epic_Mage_Aetherweave_Signet` | 장신구 | 20 · 시험안 |
| 081 | Legendary | 공통 · 모든 영웅 | `Legendary_Wayfarer_Hood` | 머리 | 40 · 시험안 |
| 082 | Legendary | 공통 · 모든 영웅 | `Legendary_Wayfarer_Coat` | 몸통 | 40 · 시험안 |
| 083 | Legendary | 공통 · 모든 영웅 | `Legendary_Wayfarer_Gloves` | 손 | 40 · 시험안 |
| 084 | Legendary | 공통 · 모든 영웅 | `Legendary_Wayfarer_Boots` | 발 | 40 · 시험안 |
| 085 | Legendary | 공통 · 모든 영웅 | `Legendary_Arcane_Reservoir_Pendant` | 장신구 | 40 · 시험안 |
| 086 | Legendary | 공통 · 모든 영웅 | `Legendary_Mana_Ring` | 장신구 | 40 · 시험안 |
| 087 | Legendary | 공통 · 모든 영웅 | `Legendary_Refuge_Charm` | 장신구 | 40 · 시험안 |
| 088 | Legendary | 공통 · 모든 영웅 | `Legendary_Valor_Ring` | 장신구 | 40 · 시험안 |
| 089 | Legendary | 공통 · 모든 영웅 | `Legendary_Vigor_Ring` | 장신구 | 40 · 시험안 |
| 090 | Legendary | 공통 · 모든 영웅 | `Legendary_Ward_Pendant` | 장신구 | 40 · 시험안 |
| 091 | Legendary | 공통 · 모든 영웅 | `Legendary_Wellspring_Charm` | 장신구 | 40 · 시험안 |
| 092 | Legendary | Knight · 기사 전용 | `Legendary_Knight_Oathguard_Sword` | 무기 | 40 · 시험안 |
| 093 | Legendary | Knight · 기사 전용 | `Legendary_Knight_Oathguard_Shield` | 방패 | 40 · 시험안 |
| 094 | Legendary | Knight · 기사 전용 | `Legendary_Knight_Oathguard_Headguard` | 머리 | 40 · 시험안 |
| 095 | Legendary | Knight · 기사 전용 | `Legendary_Knight_Oathguard_Vestments` | 몸통 | 40 · 시험안 |
| 096 | Legendary | Knight · 기사 전용 | `Legendary_Knight_Oathguard_Grips` | 손 | 40 · 시험안 |
| 097 | Legendary | Knight · 기사 전용 | `Legendary_Knight_Oathguard_Treads` | 발 | 40 · 시험안 |
| 098 | Legendary | Knight · 기사 전용 | `Legendary_Knight_Oathguard_Pendant` | 장신구 | 40 · 시험안 |
| 099 | Legendary | Knight · 기사 전용 | `Legendary_Knight_Oathguard_Signet` | 장신구 | 40 · 시험안 |
| 100 | Legendary | Elf Archer · 엘프 궁수 전용 | `Legendary_Elf_Briarwatch_Bow` | 무기 | 40 · 시험안 |
| 101 | Legendary | Elf Archer · 엘프 궁수 전용 | `Legendary_Elf_Briarwatch_Headguard` | 머리 | 40 · 시험안 |
| 102 | Legendary | Elf Archer · 엘프 궁수 전용 | `Legendary_Elf_Briarwatch_Vestments` | 몸통 | 40 · 시험안 |
| 103 | Legendary | Elf Archer · 엘프 궁수 전용 | `Legendary_Elf_Briarwatch_Grips` | 손 | 40 · 시험안 |
| 104 | Legendary | Elf Archer · 엘프 궁수 전용 | `Legendary_Elf_Briarwatch_Treads` | 발 | 40 · 시험안 |
| 105 | Legendary | Elf Archer · 엘프 궁수 전용 | `Legendary_Elf_Briarwatch_Pendant` | 장신구 | 40 · 시험안 |
| 106 | Legendary | Elf Archer · 엘프 궁수 전용 | `Legendary_Elf_Briarwatch_Signet` | 장신구 | 40 · 시험안 |
| 107 | Legendary | Dwarf Axe Thrower · 드워프 전용 | `Legendary_Dwarf_Stonehearth_Axe` | 무기 | 40 · 시험안 |
| 108 | Legendary | Dwarf Axe Thrower · 드워프 전용 | `Legendary_Dwarf_Stonehearth_Headguard` | 머리 | 40 · 시험안 |
| 109 | Legendary | Dwarf Axe Thrower · 드워프 전용 | `Legendary_Dwarf_Stonehearth_Vestments` | 몸통 | 40 · 시험안 |
| 110 | Legendary | Dwarf Axe Thrower · 드워프 전용 | `Legendary_Dwarf_Stonehearth_Grips` | 손 | 40 · 시험안 |
| 111 | Legendary | Dwarf Axe Thrower · 드워프 전용 | `Legendary_Dwarf_Stonehearth_Treads` | 발 | 40 · 시험안 |
| 112 | Legendary | Dwarf Axe Thrower · 드워프 전용 | `Legendary_Dwarf_Stonehearth_Pendant` | 장신구 | 40 · 시험안 |
| 113 | Legendary | Dwarf Axe Thrower · 드워프 전용 | `Legendary_Dwarf_Stonehearth_Signet` | 장신구 | 40 · 시험안 |
| 114 | Legendary | Mage · 마법사 전용 | `Legendary_Mage_Aetherweave_Staff` | 무기 | 40 · 시험안 |
| 115 | Legendary | Mage · 마법사 전용 | `Legendary_Mage_Aetherweave_Headguard` | 머리 | 40 · 시험안 |
| 116 | Legendary | Mage · 마법사 전용 | `Legendary_Mage_Aetherweave_Vestments` | 몸통 | 40 · 시험안 |
| 117 | Legendary | Mage · 마법사 전용 | `Legendary_Mage_Aetherweave_Grips` | 손 | 40 · 시험안 |
| 118 | Legendary | Mage · 마법사 전용 | `Legendary_Mage_Aetherweave_Treads` | 발 | 40 · 시험안 |
| 119 | Legendary | Mage · 마법사 전용 | `Legendary_Mage_Aetherweave_Pendant` | 장신구 | 40 · 시험안 |
| 120 | Legendary | Mage · 마법사 전용 | `Legendary_Mage_Aetherweave_Signet` | 장신구 | 40 · 시험안 |
| 121 | Unique | 공통 · 모든 영웅 | `Unique_Quarrykeeper_Hood` | 머리 | 60 · 확정 |
| 122 | Unique | 공통 · 모든 영웅 | `Unique_Hollowbark_Mantle` | 몸통 | 60 · 확정 |
| 123 | Unique | 공통 · 모든 영웅 | `Unique_Ashforged_Grips` | 손 | 60 · 확정 |
| 124 | Unique | 공통 · 모든 영웅 | `Unique_Widowstep_Boots` | 발 | 60 · 확정 |
| 125 | Unique | 공통 · 모든 영웅 | `Unique_Grovewell_Pendant` | 장신구 | 60 · 확정 |
| 126 | Unique | 공통 · 모든 영웅 | `Unique_Stillwater_Ring` | 장신구 | 60 · 확정 |
| 127 | Unique | 공통 · 모든 영웅 | `Unique_Lastlight_Charm` | 장신구 | 60 · 확정 |
| 128 | Unique | 공통 · 모든 영웅 | `Unique_Emberfang_Ring` | 장신구 | 60 · 확정 |
| 129 | Unique | 공통 · 모든 영웅 | `Unique_Ogreheart_Ring` | 장신구 | 60 · 확정 |
| 130 | Unique | 공통 · 모든 영웅 | `Unique_Glacier_Ward` | 장신구 | 60 · 확정 |
| 131 | Unique | 공통 · 모든 영웅 | `Unique_Moonwell_Charm` | 장신구 | 60 · 확정 |
| 132 | Unique | Knight · 기사 전용 | `Unique_Knight_Rootwardens_Oath` | 무기 | 60 · 확정 |
| 133 | Unique | Knight · 기사 전용 | `Unique_Knight_Throneward_Shield` | 방패 | 60 · 확정 |
| 134 | Unique | Knight · 기사 전용 | `Unique_Knight_Glacierwatch_Helm` | 머리 | 60 · 확정 |
| 135 | Unique | Knight · 기사 전용 | `Unique_Knight_Hollowbark_Bulwark` | 몸통 | 60 · 확정 |
| 136 | Unique | Knight · 기사 전용 | `Unique_Knight_Ogregrip_Gauntlets` | 손 | 60 · 확정 |
| 137 | Unique | Knight · 기사 전용 | `Unique_Knight_Citadel_Step` | 발 | 60 · 확정 |
| 138 | Unique | Knight · 기사 전용 | `Unique_Knight_Oathkeeper_Pendant` | 장신구 | 60 · 확정 |
| 139 | Unique | Knight · 기사 전용 | `Unique_Knight_Lionheart_Signet` | 장신구 | 60 · 확정 |
| 140 | Unique | Elf Archer · 엘프 궁수 전용 | `Unique_Elf_Thornsong` | 무기 | 60 · 확정 |
| 141 | Unique | Elf Archer · 엘프 궁수 전용 | `Unique_Elf_Widowwatch_Hood` | 머리 | 60 · 확정 |
| 142 | Unique | Elf Archer · 엘프 궁수 전용 | `Unique_Elf_Hollowbark_Jerkin` | 몸통 | 60 · 확정 |
| 143 | Unique | Elf Archer · 엘프 궁수 전용 | `Unique_Elf_Emberflight_Grips` | 손 | 60 · 확정 |
| 144 | Unique | Elf Archer · 엘프 궁수 전용 | `Unique_Elf_Silkstep_Treads` | 발 | 60 · 확정 |
| 145 | Unique | Elf Archer · 엘프 궁수 전용 | `Unique_Elf_Glacierleaf_Pendant` | 장신구 | 60 · 확정 |
| 146 | Unique | Elf Archer · 엘프 궁수 전용 | `Unique_Elf_Thornmark_Signet` | 장신구 | 60 · 확정 |
| 147 | Unique | Dwarf Axe Thrower · 드워프 전용 | `Unique_Dwarf_Stonebreakers_Resolve` | 무기 | 60 · 확정 |
| 148 | Unique | Dwarf Axe Thrower · 드워프 전용 | `Unique_Dwarf_Quarryking_Helm` | 머리 | 60 · 확정 |
| 149 | Unique | Dwarf Axe Thrower · 드워프 전용 | `Unique_Dwarf_Caldera_Heartplate` | 몸통 | 60 · 확정 |
| 150 | Unique | Dwarf Axe Thrower · 드워프 전용 | `Unique_Dwarf_Cragbreaker_Grips` | 손 | 60 · 확정 |
| 151 | Unique | Dwarf Axe Thrower · 드워프 전용 | `Unique_Dwarf_Glacieranchor_Boots` | 발 | 60 · 확정 |
| 152 | Unique | Dwarf Axe Thrower · 드워프 전용 | `Unique_Dwarf_Hollowstone_Pendant` | 장신구 | 60 · 확정 |
| 153 | Unique | Dwarf Axe Thrower · 드워프 전용 | `Unique_Dwarf_Forgeheart_Signet` | 장신구 | 60 · 확정 |
| 154 | Unique | Mage · 마법사 전용 | `Unique_Mage_Groveheart_Staff` | 무기 | 60 · 확정 |
| 155 | Unique | Mage · 마법사 전용 | `Unique_Mage_Stillgrove_Hood` | 머리 | 60 · 확정 |
| 156 | Unique | Mage · 마법사 전용 | `Unique_Mage_Glacierveil_Robe` | 몸통 | 60 · 확정 |
| 157 | Unique | Mage · 마법사 전용 | `Unique_Mage_Emberweave_Grips` | 손 | 60 · 확정 |
| 158 | Unique | Mage · 마법사 전용 | `Unique_Mage_Silkweave_Treads` | 발 | 60 · 확정 |
| 159 | Unique | Mage · 마법사 전용 | `Unique_Mage_Lastlight_Focus` | 장신구 | 60 · 확정 |
| 160 | Unique | Mage · 마법사 전용 | `Unique_Mage_Grovepulse_Signet` | 장신구 | 60 · 확정 |

검증: `python3 scripts/build_equipment_catalog.py`로160개 고유 이름·등급별40·클래스44/32/28/28/28·아이콘 파일과의 일치를 확인한다. `python3 scripts/validate_equipment_icon_assets.py`로 원본 이미지·해시·기존 보드 링크도 검사한다. 이 목록은 기존 아이템/이미지를 수정하지 않는 조회용 산출물이다. 실제 Roblox/실기기 검증은 이 작업 범위가 아니며 VERSION/빌드/릴리스 태그를 만들지 않는다. 다음 담당은 PLAN/DES의 품목 비교와 ENG의 실제 카탈로그 연결이다.
