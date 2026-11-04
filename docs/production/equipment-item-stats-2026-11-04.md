# 장비 120종 개별 능력치 계획

2026-11-04 · TLT-027/028/029/041/043/044/045/052/073/082/084 · PLAN → ENG/DES/QA

Rare/Epic/Legendary 각40종의 **개별 능력치 시험안120개**를 작성했다. [기계 판독 JSON](../../assets/balance/equipment-stats-plan-2026-11-04.json)과 [구현 순서](equipment-implementation-plan-2026-11-04.md)를 함께 사용한다. 현재 게임 카탈로그/보유품/보상 수치는 변경하지 않는다. 동일 세대의 등급 차이를 비교하기 위해 **모든 행은 착용Lv10 시험안**이며 등급별 최소 착용Lv 확정이나 Lv20~80 장비 구현을 의미하지 않는다.

## 1. 수치 의미와 예산

Power는 현재 코드의 power 필드로, 공격력·주문력에 더하는 **퍼센트 보너스 포인트**다. 예를 들어 합계Power24는 기존 파생 공격력에×1.24이며 고정 피해+24가 아니다. Armor/HP/MP는 각각 방어력/최대HP/최대MP의 가산값이다. Armor1이 피해감소1%라는 의미가 아니다. 속도·치명타·사거리·블록률·원소·기술 강화·MP재생/즉시 회복·Stamina 효과는 이번120종에 붙이지 않는다.

이번 자체 설계용 예산은 `B=Power+2×Armor+0.1×HP+0.4×MP`다. 이 가중치는 실측 전투 가치를 입증한 교환비가 아니라 비교를 위한 시험 기준이다. Common 환산 슬롯 예산은 무기21/방패14/머리12/몸통20/손10/발12/장신구12로 통일하고 클래스별로 배분한다. 실제 Common 신규품을 출시한다는 뜻은 아니다. 개별 스탯은 이 공통 환산값×Rare1.18/Epic1.28/Legendary1.40, 세트 조각은 추가×0.97이다. 숫자를 정수로 먼저 반올림하지 않아 작은 Armor/Power 보너스가 등급 간 같아지는 현상을 피한다. 기본치는 최대 소수4자리, JSON의+9는 소수6자리까지 보존하며 표는 소수3자리까지 반올림한 표시값이다.

Legendary/Epic 예산비는1.09375로 약9.375% 높다. 각 클래스의 공격·생존·MP 배분이 다르므로 최종 피해·생존시간이 그만큼 늘어난다는 뜻은 아니다. 기존 Rare Dawnforge 무기Power24와 비교하면 신규 Rare Elf Bow Power24.0366이다. 신규 Rare Knight Sword는Power20.6028+HP34.338로 전열 생존에 배분했다. 기존 무기의 자동 승급/능력치 변경은 없다. 기존 Sentinel Mail HP80/Armor7의 설계환산22와 신규 Rare 공통 Coat HP118/Armor5.9의23.6도 전투 실험에서 비교한다.

공통 장신구를 실제 선택지로 만들기 위해 앞선 Common 환산 마나 시험치를 일부 조정한다. Mana Ring은MP20에Armor2를 더하고, Arcane Reservoir Pendant는MP30을 유지하며, Wellspring Charm은MP15/HP30에서 **MP15/HP60**으로 바꾼다. 각각 환산예산12로 순수 MP/방어 혼합/HP 혼합을 비교한다. 이는 이전 초안 수치의 대체 제안이며 런타임 변경은 아니다. 같은 계열의 다른 등급은 동일uniqueGroup으로 중복 착용하지 않고 서로 다른 장신구는2슬롯에서 조합한다.

## 2. 개별 아이템 표

아이템 이름은 PNG와 같은 `등급_클래스_이름`이다. 공통품은 클래스 토큰을 생략한다. +9 열은 **Power / Armor / HP / MP** 순서이며 세트 효과를 제외한다. `—`는0이다. 세트 열의 조각은 해당 클래스의5부위 후보에 속한다. 모든 표는Lv10 시험값이다.

### 공통 장비와 마나 장신구

| 아이템 | Power | Armor | HP | MP | +9 P / A / HP / MP | 세트 |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| Rare_Wayfarer_Hood | — | 7.08 | — | — | — / 8.992 / — / — | 없음 |
| Epic_Wayfarer_Hood | — | 7.68 | — | — | — / 9.754 / — / — | 없음 |
| Legendary_Wayfarer_Hood | — | 8.4 | — | — | — / 10.668 / — / — | 없음 |
| Rare_Wayfarer_Coat | — | 5.9 | 118 | — | — / 7.493 / 149.86 / — | 없음 |
| Epic_Wayfarer_Coat | — | 6.4 | 128 | — | — / 8.128 / 162.56 / — | 없음 |
| Legendary_Wayfarer_Coat | — | 7 | 140 | — | — / 8.89 / 177.8 / — | 없음 |
| Rare_Wayfarer_Gloves | 7.08 | 2.36 | — | — | 8.992 / 2.997 / — / — | 없음 |
| Epic_Wayfarer_Gloves | 7.68 | 2.56 | — | — | 9.754 / 3.251 / — / — | 없음 |
| Legendary_Wayfarer_Gloves | 8.4 | 2.8 | — | — | 10.668 / 3.556 / — / — | 없음 |
| Rare_Wayfarer_Boots | — | 4.72 | 47.2 | — | — / 5.994 / 59.944 / — | 없음 |
| Epic_Wayfarer_Boots | — | 5.12 | 51.2 | — | — / 6.502 / 65.024 / — | 없음 |
| Legendary_Wayfarer_Boots | — | 5.6 | 56 | — | — / 7.112 / 71.12 / — | 없음 |
| Rare_Vigor_Ring | — | — | 141.6 | — | — / — / 179.832 / — | 없음 |
| Epic_Vigor_Ring | — | — | 153.6 | — | — / — / 195.072 / — | 없음 |
| Legendary_Vigor_Ring | — | — | 168 | — | — / — / 213.36 / — | 없음 |
| Rare_Ward_Pendant | — | 7.08 | — | — | — / 8.992 / — / — | 없음 |
| Epic_Ward_Pendant | — | 7.68 | — | — | — / 9.754 / — / — | 없음 |
| Legendary_Ward_Pendant | — | 8.4 | — | — | — / 10.668 / — / — | 없음 |
| Rare_Valor_Ring | 14.16 | — | — | — | 17.983 / — / — / — | 없음 |
| Epic_Valor_Ring | 15.36 | — | — | — | 19.507 / — / — / — | 없음 |
| Legendary_Valor_Ring | 16.8 | — | — | — | 21.336 / — / — / — | 없음 |
| Rare_Refuge_Charm | — | 3.54 | 70.8 | — | — / 4.496 / 89.916 / — | 없음 |
| Epic_Refuge_Charm | — | 3.84 | 76.8 | — | — / 4.877 / 97.536 / — | 없음 |
| Legendary_Refuge_Charm | — | 4.2 | 84 | — | — / 5.334 / 106.68 / — | 없음 |
| Rare_Mana_Ring | — | 2.36 | — | 23.6 | — / 2.997 / — / 23.6 | 없음 |
| Epic_Mana_Ring | — | 2.56 | — | 25.6 | — / 3.251 / — / 25.6 | 없음 |
| Legendary_Mana_Ring | — | 2.8 | — | 28 | — / 3.556 / — / 28 | 없음 |
| Rare_Arcane_Reservoir_Pendant | — | — | — | 35.4 | — / — / — / 35.4 | 없음 |
| Epic_Arcane_Reservoir_Pendant | — | — | — | 38.4 | — / — / — / 38.4 | 없음 |
| Legendary_Arcane_Reservoir_Pendant | — | — | — | 42 | — / — / — / 42 | 없음 |
| Rare_Wellspring_Charm | — | — | 70.8 | 17.7 | — / — / 89.916 / 17.7 | 없음 |
| Epic_Wellspring_Charm | — | — | 76.8 | 19.2 | — / — / 97.536 / 19.2 | 없음 |
| Legendary_Wellspring_Charm | — | — | 84 | 21 | — / — / 106.68 / 21 | 없음 |

### Knight 장비

| 아이템 | Power | Armor | HP | MP | +9 P / A / HP / MP | 세트 |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| Rare_Knight_Oathguard_Sword | 20.603 | — | 34.338 | — | 26.166 / — / 43.609 / — | 조각 |
| Epic_Knight_Oathguard_Sword | 22.349 | — | 37.248 | — | 28.383 / — / 47.305 / — | 조각 |
| Legendary_Knight_Oathguard_Sword | 24.444 | — | 40.74 | — | 31.044 / — / 51.74 / — | 조각 |
| Rare_Knight_Oathguard_Headguard | — | 5.723 | 22.892 | — | — / 7.268 / 29.073 / — | 조각 |
| Epic_Knight_Oathguard_Headguard | — | 6.208 | 24.832 | — | — / 7.884 / 31.537 / — | 조각 |
| Legendary_Knight_Oathguard_Headguard | — | 6.79 | 27.16 | — | — / 8.623 / 34.493 / — | 조각 |
| Rare_Knight_Oathguard_Vestments | — | 8.012 | 68.676 | — | — / 10.175 / 87.219 / — | 조각 |
| Epic_Knight_Oathguard_Vestments | — | 8.691 | 74.496 | — | — / 11.038 / 94.61 / — | 조각 |
| Legendary_Knight_Oathguard_Vestments | — | 9.506 | 81.48 | — | — / 12.073 / 103.48 / — | 조각 |
| Rare_Knight_Oathguard_Grips | 4.578 | 2.289 | 22.892 | — | 5.815 / 2.907 / 29.073 / — | 조각 |
| Epic_Knight_Oathguard_Grips | 4.966 | 2.483 | 24.832 | — | 6.307 / 3.154 / 31.537 / — | 조각 |
| Legendary_Knight_Oathguard_Grips | 5.432 | 2.716 | 27.16 | — | 6.899 / 3.449 / 34.493 / — | 조각 |
| Rare_Knight_Oathguard_Treads | — | 4.578 | 45.784 | — | — / 5.815 / 58.146 / — | 조각 |
| Epic_Knight_Oathguard_Treads | — | 4.966 | 49.664 | — | — / 6.307 / 63.073 / — | 조각 |
| Legendary_Knight_Oathguard_Treads | — | 5.432 | 54.32 | — | — / 6.899 / 68.986 / — | 조각 |
| Rare_Knight_Oathguard_Signet | 4.72 | — | 94.4 | — | 5.994 / — / 119.888 / — | 없음 |
| Epic_Knight_Oathguard_Signet | 5.12 | — | 102.4 | — | 6.502 / — / 130.048 / — | 없음 |
| Legendary_Knight_Oathguard_Signet | 5.6 | — | 112 | — | 7.112 / — / 142.24 / — | 없음 |
| Rare_Knight_Oathguard_Pendant | — | 4.72 | 47.2 | — | — / 5.994 / 59.944 / — | 없음 |
| Epic_Knight_Oathguard_Pendant | — | 5.12 | 51.2 | — | — / 6.502 / 65.024 / — | 없음 |
| Legendary_Knight_Oathguard_Pendant | — | 5.6 | 56 | — | — / 7.112 / 71.12 / — | 없음 |
| Rare_Knight_Oathguard_Shield | — | 8.26 | — | — | — / 10.49 / — / — | 없음 |
| Epic_Knight_Oathguard_Shield | — | 8.96 | — | — | — / 11.379 / — / — | 없음 |
| Legendary_Knight_Oathguard_Shield | — | 9.8 | — | — | — / 12.446 / — / — | 없음 |

### Elf Archer 장비

| 아이템 | Power | Armor | HP | MP | +9 P / A / HP / MP | 세트 |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| Rare_Elf_Briarwatch_Bow | 24.037 | — | — | — | 30.526 / — / — / — | 조각 |
| Epic_Elf_Briarwatch_Bow | 26.074 | — | — | — | 33.113 / — / — / — | 조각 |
| Legendary_Elf_Briarwatch_Bow | 28.518 | — | — | — | 36.218 / — / — / — | 조각 |
| Rare_Elf_Briarwatch_Headguard | 4.578 | 4.578 | — | — | 5.815 / 5.815 / — / — | 조각 |
| Epic_Elf_Briarwatch_Headguard | 4.966 | 4.966 | — | — | 6.307 / 6.307 / — / — | 조각 |
| Legendary_Elf_Briarwatch_Headguard | 5.432 | 5.432 | — | — | 6.899 / 6.899 / — / — | 조각 |
| Rare_Elf_Briarwatch_Vestments | — | 6.868 | 91.568 | — | — / 8.722 / 116.291 / — | 조각 |
| Epic_Elf_Briarwatch_Vestments | — | 7.45 | 99.328 | — | — / 9.461 / 126.147 / — | 조각 |
| Legendary_Elf_Briarwatch_Vestments | — | 8.148 | 108.64 | — | — / 10.348 / 137.973 / — | 조각 |
| Rare_Elf_Briarwatch_Grips | 9.157 | 1.145 | — | — | 11.629 / 1.454 / — / — | 조각 |
| Epic_Elf_Briarwatch_Grips | 9.933 | 1.242 | — | — | 12.615 / 1.577 / — / — | 조각 |
| Legendary_Elf_Briarwatch_Grips | 10.864 | 1.358 | — | — | 13.797 / 1.725 / — / — | 조각 |
| Rare_Elf_Briarwatch_Treads | 2.289 | 3.434 | 45.784 | — | 2.907 / 4.361 / 58.146 / — | 조각 |
| Epic_Elf_Briarwatch_Treads | 2.483 | 3.725 | 49.664 | — | 3.154 / 4.73 / 63.073 / — | 조각 |
| Legendary_Elf_Briarwatch_Treads | 2.716 | 4.074 | 54.32 | — | 3.449 / 5.174 / 68.986 / — | 조각 |
| Rare_Elf_Briarwatch_Signet | 11.8 | — | 23.6 | — | 14.986 / — / 29.972 / — | 없음 |
| Epic_Elf_Briarwatch_Signet | 12.8 | — | 25.6 | — | 16.256 / — / 32.512 / — | 없음 |
| Legendary_Elf_Briarwatch_Signet | 14 | — | 28 | — | 17.78 / — / 35.56 / — | 없음 |
| Rare_Elf_Briarwatch_Pendant | 4.72 | 4.72 | — | — | 5.994 / 5.994 / — / — | 없음 |
| Epic_Elf_Briarwatch_Pendant | 5.12 | 5.12 | — | — | 6.502 / 6.502 / — / — | 없음 |
| Legendary_Elf_Briarwatch_Pendant | 5.6 | 5.6 | — | — | 7.112 / 7.112 / — / — | 없음 |

### Dwarf Axe Thrower 장비

| 아이템 | Power | Armor | HP | MP | +9 P / A / HP / MP | 세트 |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| Rare_Dwarf_Stonehearth_Axe | 22.892 | — | 11.446 | — | 29.073 / — / 14.536 / — | 조각 |
| Epic_Dwarf_Stonehearth_Axe | 24.832 | — | 12.416 | — | 31.537 / — / 15.768 / — | 조각 |
| Legendary_Dwarf_Stonehearth_Axe | 27.16 | — | 13.58 | — | 34.493 / — / 17.247 / — | 조각 |
| Rare_Dwarf_Stonehearth_Headguard | — | 4.578 | 45.784 | — | — / 5.815 / 58.146 / — | 조각 |
| Epic_Dwarf_Stonehearth_Headguard | — | 4.966 | 49.664 | — | — / 6.307 / 63.073 / — | 조각 |
| Legendary_Dwarf_Stonehearth_Headguard | — | 5.432 | 54.32 | — | — / 6.899 / 68.986 / — | 조각 |
| Rare_Dwarf_Stonehearth_Vestments | — | 5.723 | 114.46 | — | — / 7.268 / 145.364 / — | 조각 |
| Epic_Dwarf_Stonehearth_Vestments | — | 6.208 | 124.16 | — | — / 7.884 / 157.683 / — | 조각 |
| Legendary_Dwarf_Stonehearth_Vestments | — | 6.79 | 135.8 | — | — / 8.623 / 172.466 / — | 조각 |
| Rare_Dwarf_Stonehearth_Grips | 6.868 | 2.289 | — | — | 8.722 / 2.907 / — / — | 조각 |
| Epic_Dwarf_Stonehearth_Grips | 7.45 | 2.483 | — | — | 9.461 / 3.154 / — / — | 조각 |
| Legendary_Dwarf_Stonehearth_Grips | 8.148 | 2.716 | — | — | 10.348 / 3.449 / — / — | 조각 |
| Rare_Dwarf_Stonehearth_Treads | — | 3.434 | 68.676 | — | — / 4.361 / 87.219 / — | 조각 |
| Epic_Dwarf_Stonehearth_Treads | — | 3.725 | 74.496 | — | — / 4.73 / 94.61 / — | 조각 |
| Legendary_Dwarf_Stonehearth_Treads | — | 4.074 | 81.48 | — | — / 5.174 / 103.48 / — | 조각 |
| Rare_Dwarf_Stonehearth_Signet | 9.44 | 2.36 | — | — | 11.989 / 2.997 / — / — | 없음 |
| Epic_Dwarf_Stonehearth_Signet | 10.24 | 2.56 | — | — | 13.005 / 3.251 / — / — | 없음 |
| Legendary_Dwarf_Stonehearth_Signet | 11.2 | 2.8 | — | — | 14.224 / 3.556 / — / — | 없음 |
| Rare_Dwarf_Stonehearth_Pendant | — | 2.36 | 94.4 | — | — / 2.997 / 119.888 / — | 없음 |
| Epic_Dwarf_Stonehearth_Pendant | — | 2.56 | 102.4 | — | — / 3.251 / 130.048 / — | 없음 |
| Legendary_Dwarf_Stonehearth_Pendant | — | 2.8 | 112 | — | — / 3.556 / 142.24 / — | 없음 |

### Mage 장비

| 아이템 | Power | Armor | HP | MP | +9 P / A / HP / MP | 세트 |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| Rare_Mage_Aetherweave_Staff | 19.458 | — | — | 11.446 | 24.712 / — / — / 11.446 | 조각 |
| Epic_Mage_Aetherweave_Staff | 21.107 | — | — | 12.416 | 26.806 / — / — / 12.416 | 조각 |
| Legendary_Mage_Aetherweave_Staff | 23.086 | — | — | 13.58 | 29.319 / — / — / 13.58 | 조각 |
| Rare_Mage_Aetherweave_Headguard | — | 3.434 | — | 17.169 | — / 4.361 / — / 17.169 | 조각 |
| Epic_Mage_Aetherweave_Headguard | — | 3.725 | — | 18.624 | — / 4.73 / — / 18.624 | 조각 |
| Legendary_Mage_Aetherweave_Headguard | — | 4.074 | — | 20.37 | — / 5.174 / — / 20.37 | 조각 |
| Rare_Mage_Aetherweave_Vestments | — | 5.723 | 68.676 | 11.446 | — / 7.268 / 87.219 / 11.446 | 조각 |
| Epic_Mage_Aetherweave_Vestments | — | 6.208 | 74.496 | 12.416 | — / 7.884 / 94.61 / 12.416 | 조각 |
| Legendary_Mage_Aetherweave_Vestments | — | 6.79 | 81.48 | 13.58 | — / 8.623 / 103.48 / 13.58 | 조각 |
| Rare_Mage_Aetherweave_Grips | 6.868 | — | — | 11.446 | 8.722 / — / — / 11.446 | 조각 |
| Epic_Mage_Aetherweave_Grips | 7.45 | — | — | 12.416 | 9.461 / — / — / 12.416 | 조각 |
| Legendary_Mage_Aetherweave_Grips | 8.148 | — | — | 13.58 | 10.348 / — / — / 13.58 | 조각 |
| Rare_Mage_Aetherweave_Treads | — | 3.434 | 22.892 | 11.446 | — / 4.361 / 29.073 / 11.446 | 조각 |
| Epic_Mage_Aetherweave_Treads | — | 3.725 | 24.832 | 12.416 | — / 4.73 / 31.537 / 12.416 | 조각 |
| Legendary_Mage_Aetherweave_Treads | — | 4.074 | 27.16 | 13.58 | — / 5.174 / 34.493 / 13.58 | 조각 |
| Rare_Mage_Aetherweave_Signet | 9.44 | — | — | 11.8 | 11.989 / — / — / 11.8 | 없음 |
| Epic_Mage_Aetherweave_Signet | 10.24 | — | — | 12.8 | 13.005 / — / — / 12.8 | 없음 |
| Legendary_Mage_Aetherweave_Signet | 11.2 | — | — | 14 | 14.224 / — / — / 14 | 없음 |
| Rare_Mage_Aetherweave_Pendant | — | — | 47.2 | 23.6 | — / — / 59.944 / 23.6 | 없음 |
| Epic_Mage_Aetherweave_Pendant | — | — | 51.2 | 25.6 | — / — / 65.024 / 25.6 | 없음 |
| Legendary_Mage_Aetherweave_Pendant | — | — | 56 | 28 | — / — / 71.12 / 28 | 없음 |

## 3. 클래스별 선택과 세트 효과

Knight는 무기의Power 일부를HP로, 방어구는Armor/HP에 배분한다. Elf는Power 중심 무기·손과Power/Armor 혼합 머리/발로 공격·위치선정 역할을 표현하되 이동속도를 직접 올리지는 않는다. Dwarf는 도끼Power/HP와HP가 많은 방어구로 근거리 지속력을 비교한다. Mage는Power/Armor/MP 배분으로 주문 지속력을 주며 최대MP를 늘려도 주문을 새로 해금하지 않는다. 다른 계열 전직도 같은 기본 클래스 전용품을 사용할 수 있다.

| 클래스 | 세트 이름 | 조각 |
| --- | --- | --- |
| Knight | Oathguard Bastion | Sword / Headguard / Vestments / Grips / Treads |
| Elf Archer | Briarwatch Vigil | Bow / Headguard / Vestments / Grips / Treads |
| Dwarf Axe Thrower | Stonehearth Resolve | Axe / Headguard / Vestments / Grips / Treads |
| Mage | Aetherweave Constellation | Staff / Headguard / Vestments / Grips / Treads |

네 세트 모두 시험 문턱은 **2/4/5부위**다. 동일 setId·세대·등급의 서로 다른 부위만 센다. 2부위는 세트 적용 전 영웅+장비 최대HP의2%, 4부위는 강화 후 장비 Armor 합계의2%, 5부위는 강화 후 장비 Power 합계의2%를 추가한다. 5부위 Power 보너스는 공격력+2퍼센트포인트가 아니라 기존 장비 Power 합계×0.02다. 문턱별 효과는 누적하며 서로 재귀적으로 곱하거나 강화하지 않는다. 방패/장신구는 카운트에서 제외한다. 세트 해제/등급 혼합 교체로 잃는 효과를 비교창에 표시하고 HP/MP를 채우지 않는다. 개별 조각3%차감과 보너스 가치가 실제 동등한지는 수용 전 실험한다.

## 4. 마나와 강화

MP는 Mage 및Lv20 첫 전직을 완료한 magic_archer Elf에게만 적용한다. 공통품은 다른 영웅도 착용/보관할 수 있으나 마나 풀을 만들지 않고 HP/Armor만 적용한다. MP 비적용 상태는 영어 안내로 표시한다. MP가 없는 영웅의 자동 보상 추천에서 순수 MP품을 어떻게 다룰지는 보스 유효 풀 설계에서 결정한다. 장착/해제/계열 변경·재접속 때 현재MP는 새 최대치 이하로 제한하며 최대치가 커졌다고 회복시키지 않는다.

+9는 양수 Power/Armor/HP에×1.27, MP에는×1이다. 순수MP Arcane Reservoir Pendant는 모든 등급에서 강화 불가·재료 소비0이다. Mana Ring은Armor만, Wellspring Charm은HP만 강화한다. Mage 혼합 장비도MP는 그대로다. 강화 성공률100/90/80/70/60/50/40/30/20%, 목표n 보석2n·마석max(0,n−3), Gold0, 실패 단계 보존·재료 소모·성공 투입분만80%회수를 유지한다. 예전+10과 구재료 원장은 보존한다.

## 5. 보스와 성장 연결

신규품은 보스별 개인 드롭 표에 definitionId로 등록하고 난이도는 등급 확률/장비 세대를 선택한다. 이번Lv10 표를Hell Lv80 보상으로 그대로 사용하지 않는다. 지역·난이도별 입장/전투/무료 성장 장비와Lv20/40/60/80 예산을 먼저 만든다. 낮은 난이도의Legendary 희소·높은 난이도의빈도 증가 방향을 유지하며 세트 완성을 필수 본편/전직 조건으로 삼지 않는다. Unique는 고유 효과/예산이 미작성이라 이번120종에 포함하지 않는다. 기존6등급 드롭 표의Unique 확률을 다른 등급에 임의 배분하지 않는다. 실제 드롭 활성화와 미획득 보호는 구현 계획E05의 조건을 충족한 뒤 진행한다.

## 6. 검증과 남은 수용

`scripts/validate_equipment_stats_plan.py`로40계열/120고유제안·이름/아이콘·Lv10 상태·슬롯예산·등급배율·세트97%/2·4·5문턱·강화 Power/Armor/HP만×1.27·MP 불변/순수 MP 강화 불가·같은 계열uniqueGroup을 검사한다. `scripts/validate_equipment_icon_assets.py`와 함께 실행한다. 정적 검증은 런타임 능력치/저장·유료품·게임 난이도 수용을 대신하지 않는다.

다음은 PLAN/QA의 부위별 현재 장비 대비·세트/비세트·4클래스×4모드×강화 0/5/9 전투 실험과ENG의 신규 필드 스키마·서버 집계·UI 동일계산이다. 1~4인/AI0 및 인원별 최대2/2/1/1 조건으로 처치시간·사망·보스/시간·강화 순소비·MP 회전율·이전 세대 교체를 측정한다. 기사 방패로 인한 추가 방어를 클래스 공정성 실험에 포함한다. 실측 전에는 동일 가중 예산을 동일 성능이라고 보고하지 않는다. 신규120정의·효과·드롭·저장·실기기 검증은 후속이며 이번에는 JSON/문서만 저장한다.

검증 기록: `python3 scripts/validate_equipment_stats_plan.py` 및 `python3 scripts/validate_equipment_icon_assets.py` PASS. 새 문서 상대 링크/기존120아이콘 연결과 `git diff --check`도 PASS. 생성 당시 generation.json의 budget-only 상태는 당시 제작 이력이며 현재 시험 스탯의 원천은 이 문서/수치 JSON과 manifest.statsPlan이다.
