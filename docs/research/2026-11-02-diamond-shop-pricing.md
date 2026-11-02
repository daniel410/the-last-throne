# 다이아몬드 상점 묶음·무기 가격 비교

2026-11-02 · TLT-017/028/043/045/049/061/084 · PLAN/ENG → QA

사용자는 기존10 Diamonds→100 Gold의 낮은 구매력을 지적하고,500 Gold 추천에 이어1,000/2,000 Gold 상품과 다이아몬드 무기 상품을 요청했다. 이번 로컬 구현의 범위는 EconomyCatalog와 해당 거래 검증이다. 실제 Robux 상품·TD 경제·승인 이야기 보상은 범위 밖이다.

## 관찰과 적용

현재 Gold 가격은 Tempered250, Veteran600, Dawnforge950이며 Veteran은10 Diamonds로도 판매 중이다. 따라서10 Diamonds→100 Gold는 동일 화폐의 직접 장비 구매와 구매력이 크게 어긋난다. 시험 교환율을1 Diamond→50 Gold로 정하고500/1,000/2,000 Gold를10/20/40 Diamonds에 판매한다. 묶음 할인은 추가하지 않아 환산을 일정하게 유지한다.

네 클래스별 기존 Veteran10 Diamonds를 유지하고 Dawnforge18 Diamonds를 추가한다. Gold 환산500/900으로, 기존 Gold 가격600/950 대비 직접 구매 이점은100/50 Gold다. Veteran의 기존10 Diamonds와 기존 아이템ID/성능/요구 레벨을 보존한다. 같은 장비를 사용하므로 구매 통화로 성능 차이가 생기지 않는다. Gold로 재판매해도120/190 Gold로서 직접 교환보다 낮다.

## 비교 사례·한계

확인일2026-11-02. 웹 문서 열람이며 직접 플레이하지 않았다. 인기 순위 주장은 하지 않는다.

- Roblox [Economy events](https://create.roblox.com/docs/production/analytics/economy-events): 재화 유입/소비를 계측해 경제를 조정하도록 안내한다. 적용 제안은 묶음 선택률·직접 무기 구매율·순Gold 유입/소비·실제 플레이 수급을 함께 확인하는 것이다. 이번에는 분석 이벤트를 추가하지 않는다.
- Guild Wars 2 공식 [Managing Payment Information](https://help.guildwars2.com/hc/en-us/articles/230515368-Managing-Payment-Information): Gem Store에서 장비 관련 상품과 gems→gold 교환을 안내한다. 직접 상품과 재화 교환을 함께 제공하는 구조만 비교하며 타 게임 환율을 가져오지 않는다.

수치는 시험값이다. Diamonds의 실제 과금 원가·고레벨 강화 비용/수급·플레이 시간 대비 가치는 미검증이다. 최소 검증은 세 묶음의 정확한 차감/지급·중복 요청·잔액 부족·저장 응답 불명 복구와 네 클래스8개 무기의 같은 장비 지급·재판매 차익 부재다. QA의 후속은 로컬 Studio 카드/필터/확인 조작과 게시 클라이언트 저장 수용이다.

추가 사용자 지적으로 지급 중복을 확인했다. `InventoryRules.addHero`가 Tempered를 생성 때 지급하고 `grantStoryRewards` 경로도 일부 이야기에서 같은 무기를 지급한다. 따라서 Tempered 다이아몬드 판매 추가는 철회했다. Veteran은 소스 자동 지급 목록에서는 확인되지 않으나 기존 판매품이므로 신규 장비로 보고하지 않는다. Dawnforge 역시 기존 Gold 장비에 다이아몬드 구매 경로를 추가하는 것이며 새 디자인 무기 제작은 아니다.
