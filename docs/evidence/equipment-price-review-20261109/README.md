# 장비 가격 리뷰·재산정·Traveler 구매 제외

2026-11-09 · TLT-027/029/041/052/057/084 · 0.93.5 · ENG/PLAN→QA

사용자가 Traveler/Tempered 동가, 후드·장갑의 저가를 지적하며 “가격 리뷰하고 다시 측정해서 개선”과 Traveler 상품 제외를 지시했다. 기존 Common 임시 가격 재사용과 Veteran 방패의 부위 우선 분기가 원인이었다. 이번 최신 지시로 기존 가격 승계 기록을 대체한다.

## 적용

[재계산 근거·전체 표·리서치](../../research/2026-11-09-equipment-price-review.md) · [실행 결과/입력 해시](recalculation.json).

| 부위 | Tempered Gold | Veteran Gold | Sentinel Diamonds |
| --- | ---: | ---: | ---: |
| 무기4종 | 500 | 1,200 | 40 |
| 기사 방패 | 400 | 1,000 | 32 |
| 후드 | 300 | 800 | 28 |
| 상의/로브 | 400 | 1,000 | 32 |
| 장갑/부츠 | 250 | 650 | 24 |

Copper Ring300Gold/6Diamonds, Amber Charm/Amber Mana Charm400Gold/8Diamonds. Traveler10품목의14구매 SKU(Gold10/Diamonds4)를 제거했다. 남은 구매 offer52개, 대장간33개(무기12/방어구18/장신구3). 물약8·리셋권2의 가격 및 Gold 환전3종·강화/재료/지원 비용은 유지한다.

`EquipmentPricing` 단일 표를 `EconomyCatalog`에서 사용한다. 중복 임시 가격 분기·Gold와 Diamonds의 할인 불일치를 제거했다. Diamonds 대체 SKU는 기존1Diamond→50Gold 환전의 기회비용 기준과 일치시킨다. Gold→Diamonds 교환 기능을 만들지 않는다. 되팔기는 현 Gold 기준가20%로 정리하되 Traveler/퇴역품은 기존 되팔기값과 기본 지급품 판매 제한을 유지한다. 과거 최저 구매가 대비 현재 되팔기 차익0을 검사했다.

기존 장비ID·비Traveler 상품ID·보유품·강화·잠금·지갑·영웅 기본 지급/자동착용·기존 영수증을 보존한다. 과거600Gold에 산 Veteran 영수증 재요청이 새1,200Gold를 소급 차감하지 않음을 별도로 검증했다. 서버의 실제 가격 확정·원자적 차감/지급·중복 요청·저장 응답 유실 복구 경로를 유지한다.

## 재계산과 검증

- `python3 scripts/review_equipment_prices.py --output docs/evidence/equipment-price-review-20261109/recalculation.json`: 현재 보상 규칙13, 메인35개×4난이도의 초회 고정/유한 처치/반복 Gold, 클래스별 세트 비용, 운영비0/200/400/800 예약 민감도를 계산했다. Deepwood2,796Gold, 첫 두 지역5,981Gold. Tempered 세트1,700/기사2,100Gold, Veteran4,300/기사5,300Gold. 장신구 제외이며 무료 Hood/전리품을 쓰지 않고 전부 사는 조건이다. 모든난이도 초회 고정 Gold에 모드 배수를 임의 적용하지 않는다.
- `lua tests/blacksmith-stock.spec.lua`: **449검사 PASS**.33개 실제 서버 구매/판매/재요청, Traveler 구/위조SKU60개 요청 거부·잔액/보유품 유지, 통화 간 동가·부위별 가격 증가·되팔기 차익 방지·저축 목표.
- `lua tests/equipment-families.spec.lua`: **458검사 PASS**. Traveler는 정상 지급/착용 경로, 나머지는 구매/착용·이관·강화·자격 유지.
- `lua tests/starter-potions-and-shop.spec.lua`: **316검사 PASS**. 네 클래스·최초 배급·물약/일회 지급·저장 복구.
- `lua tests/economy.spec.lua`: **38검사 PASS**. 서버 가격·구매/되팔기/영수증·저장 응답유실/재접속 복구·**과거 가격의 영수증 재요청**.
- `lua tests/item-shop-categories.spec.lua`: PASS. 상점 분류/필터.
- 격리 Studio(Edit, PlaceId0/플레이어0)에 현재 ItemCatalog/EquipmentFamilies/InventoryText/가격/상품/UI 모듈의 복사본으로 **1,710검사 PASS**.1280×720/844×390/390×844, 잔액0/10,000, 대장간3분류·다이아상점24경우. Traveler 미표시, 새로운 실제 가격/통화·부족분, 구입 버튼 활성/비활성, 글자 맞춤 확인. 거래 전송0회. [네이티브 결과](native-ui.json).

초기 네이티브 fixture가0.91 당시 InventoryText를 캐시해 Copper Ring의 Dexterity 포맷이 없어서 실패했다. 현재 ItemCatalog/계열/InventoryText까지 복사해 정합성을 맞춘 뒤 위 검사를 재실행했다. 그 fixture 오류 때문에 게임 런타임 코드를 추가 변경하지 않았다.

## 한계·인계

위 수입은 저작된 유한 적을 모두 합산한 정적 예산이며 실제 최소 동선·플레이 시간·사용자 잔액/지출을 측정한 결과가 아니다. 사이드·드롭·판매·로그인/다른 영웅·Diamonds 환전은 추가 유입, 물약·강화·Selene는 추가 소비다. 선택 구매·기본 배급/전리품 사용을 전제로 하며 전 단계 세트 완구매를 필수로 만들지 않는다.

현재 열린0.93.3/0.93.4 Play 세션/실제 계정을 변경하거나 중단하지 않았다. 새 소스와 새 빌드로 반영하며 Roblox 게시·라이브 DataStore 변경·차액 청구/환급 없음. 다음 담당은 QA/사용자의 첫/후속 영웅·4클래스 실플레이 지출/첫 교체 시점/진행 정체 수용이다. 부모 티켓 완료 처리 없음.

## 고정 빌드 결과

소스 `4332b7c99c80d12e4d0f96158e2b2cac2283a9c6`를 origin/main에 푸시한 뒤 **0.93.5 단일 빌드 성공**. `builds/0.93.5/TheLastThrone-0.93.5.rbxlx`, SHA256 `9f336afe21f585bc5d46dcbd6936dea918dcc340efc6deb0c5ddb4fce1a1f83a`. [빌드 기록](build.json). 고정된 입력의 가격/카탈로그/계열/캠페인/보상/유한 전투 관련 해시가 재계산 보고서와 모두 일치했다. 새 LFS 자산·릴리스 태그·Roblox 게시 없음.

아티팩트 추가 검증: `python3 tests/single-build.spec.py --artifact builds/0.93.5/TheLastThrone-0.93.5.rbxlx`에서 역할10/도착로딩192/마운트·실제 구성 PASS. 실제 XML의 EquipmentPricing/EconomyCatalog ModuleScript 각1개와 Source가 검증한 원본과 일치한다. XML 검증 도구의 초기 ProtectedString 가정은 실제 string Source 형식에 맞춰 수정했으며 게임 소스/빌드 바이트 변경은 없다.
