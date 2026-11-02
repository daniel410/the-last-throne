# 승인 물약 가격 적용

2026-11-02 · TLT-017/028/043/045/084 · ENG → QA

사용자가 추천 가격 적용을 승인했다. 변경 범위는 EconomyCatalog의8개 물약 구매 가격과 기존 검증의 가격/잔액 기대값이다. 다른 작업의 미커밋 변경은 보존한다.

| 크기 | HP 구매/매각 Gold | MP 구매/매각 Gold |
| --- | --- | --- |
| Small | 25 / 5 | 20 / 4 |
| Medium | 60 / 12 | 40 / 8 |
| Large | 100 / 20 | 80 / 16 |
| XL | 200 / 40 | 160 / 32 |

기존 매각가20% 정책을 유지한다. 회복량·상품ID·기본 지급·퀵슬롯·보상·Gold 묶음은 변경하지 않는다. 서버 구매와 기존 TD 공통 UI의 카드/부족 금액/확인은 같은 카탈로그를 사용한다.

근거: 사용자가 승인한 완만한 가격 인상안.500 Gold는Small HP20개 또는Large HP5개를 구매한다. 큰 물약의 회복량 대비 가격 이점을 유지한다. [Roblox 경제 균형 지침](https://create.roblox.com/docs/production/game-design/balance-virtual-economies)을2026-11-02 웹으로 확인했다. 수급·소비·가격 반응을 함께 관찰하는 접근을 참고하며, 이 문서는 실제 플레이 데이터나 최종 밸런스 수용의 증거가 아니다.

검증:

- `lua tests/starter-potions-and-shop.spec.lua`:172개 통과.4클래스8종 구매/스택·중복 방지·가방 한계·기존 지급 보존·저장 응답 불명 복구·연속 구매.
- `lua tests/store-split.spec.lua`:14개 통과.상점 분리·매각 대금·매각 중복 방지.
- `lua tests/economy.spec.lua`:42개 통과.
- `lua tests/diamond-gold-exchange.spec.lua`:25개 통과.
- `lua tests/inventory.spec.lua`:271개 통과.
- 일회성Lua실행으로8종 각각 승인 가격·매각20%·정확히 충족 시 구매/잔액0·1Gold 부족 시NotEnoughGold를 확인했다.
- `git diff --check`:통과.

처음 물약 검증 실행에서 이전20 Gold 기준 잔액 기대값이 남아 실패했다.75/50 Gold로 수정 후172개 전부 통과했다. UI native 검증의 가격/부족 금액과 레이아웃 시나리오 문구도 갱신했으나 Studio에서 실행하지 않았다.

빌드·게시·실제 클라이언트·실기기·소비량/골드 수급 밸런스는 미검증이다. 버전/릴리스 태그는 생성하지 않았다. 다음 담당 QA는 새 소스로 빌드한 상점의8종 가격·부족 금액·확인 구매를 검증하고 실제 모험의 소비량과 수급을 비교한다. 상위 티켓 완료 처리는 하지 않는다.
