# 대장간 레어와 에픽 Diamonds 전용 판매

2026-11-05 · TLT-028/029/041/043/044/046/052/057/084 · 0.75.0 · ENG/DES → QA

대장간에서 Rare12종과 Epic12종을 Diamonds로만 구매하도록 구현했다. 기존 Rare의 Gold SKU는 중단하고, 네 무기의 기존 Diamond SKU와 가격18은 유지한다. 새 Epic12종은 기존 Rare의 부위·클래스·착용Lv10·장신구 중복 그룹을 유지한 별도 정의다. [판매 명세](../../assets/economy/forge-diamond-stock-2026-11-05.json)와 서버 EconomyCatalog가 대응한다. 신규 가격은 실제 성장/경제 수용 전 시험값이다.

## 판매 목록

가격 단위는 RPG 계정 Diamonds다. 강화 보석 Enhancement Gem/마석 Magic Stone·TD 잔액과 구분한다.

| 기존Rare 이름 | Rare 가격 | 신규Epic 이름 | Epic 가격 |
| --- | ---: | --- | ---: |
| Dawnforge Sword | 18 | Epic Dawnforge Sword | 30 |
| Dawnforge Bow | 18 | Epic Dawnforge Bow | 30 |
| Dawnforge Axe | 18 | Epic Dawnforge Axe | 30 |
| Dawnforge Staff | 18 | Epic Dawnforge Staff | 30 |
| Sentinel Shield | 10 | Epic Sentinel Shield | 18 |
| Sentinel Helm | 8 | Epic Sentinel Helm | 14 |
| Sentinel Mail | 13 | Epic Sentinel Mail | 22 |
| Sentinel Gauntlets | 8 | Epic Sentinel Gauntlets | 14 |
| Sentinel Boots | 8 | Epic Sentinel Boots | 14 |
| Ruby Ring | 11 | Epic Ruby Ring | 18 |
| Guardian Charm | 11 | Epic Guardian Charm | 18 |
| Storm Pendant | 11 | Epic Storm Pendant | 18 |

## 동작과 보존

Common/Uncommon의 기존 대장간 Gold 판매16개는 유지한다. BUY 총40개는 Common5/Uncommon11/Rare12/Epic12이며 무기16·방어구16·장신구8이다. 새 Epic 기본치는 대응 Rare의 각 양수 스탯×128/118을 소수4자리 반올림한다. Power는 퍼센트 보너스 포인트이며 현재 강화식을 한 번만 적용한다. 기존51종의 정의/수치·아이템ID·강화 원장은 보존했다.

이번 Epic12종은 실제 대장간의 기존 품목을 확장한 **단독 장비**다. 앞서 설계한40계열 Epic 아이콘/세트/MP 장비와 별도이며40종 전체 구현으로 표시하지 않는다. 새ID는 기존ID+`_epic`, SKU는 정의ID+`_diamond`다. 새 세트 효과·MP 필드·전직 무기·3D모델은 추가하지 않고 기존 유형별TD 아이콘을 사용한다. 전체 런타임 카탈로그는 기존51+신규12=63종이다.

서버가 offerId로 실제 가격/통화를 조회하고 상점·잔액·가방 용량을 확인한다. 클라이언트가 Gold/가격0을 주장해도 무시하며 잘못 설정된 Rare/Epic Gold offer도 모든 구매 경로에서 거부한다. 저장된 과거 거래 영수증의 재요청은 기존 멱등 분기로 복구하고 신규 Gold 구매만 거부한다. 계정/영웅 보관·공유 창고·실상품 권리·TD 지갑은 변경하지 않는다.

장비 되팔기는 기존 Gold 지급을 유지하고 Diamonds를 환급하지 않는다. Epic의 되팔기 가격은 같은 기본 Rare의 Gold값이다. 기존 무료 Rare 획득/선택 상자 권리는 유지한다. 새 Epic이 기존 무료 상자에 자동 추가되지 않도록 cacheEligible=false를 UI/서버 양쪽에서 검사한다. 구매 통화 제한과 기존 정당한 보유품/상자 권리를 구분한다. 상점은 확정 품목 구매이며 랜덤 상품이 아니다.

드롭은 [최신 정책](../../assets/balance/boss-equipment-drop-policy-2026-11-05.json)을 따른다. Legendary는 Insane/Hell, Unique는 Hell 전용이며 이번 상점에 추가하지 않는다. 신규 보스 드롭의 실제 구현은 후속으로, 이번 상점 거래와 별개다.

[실행 기록](../evidence/forge-diamond-sales-20261105/README.md)에 검증 결과를 남긴다. 실제GUI/모바일·패드·게시 클라이언트·실계정 저장/가격 수용은 후속이다. Roblox 게시나 라이브 Diamonds 구매를 수행하지 않았다.
