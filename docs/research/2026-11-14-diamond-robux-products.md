# 다이아몬드 Robux 묶음 조사

TLT-041/049/084 · 2026-11-14 · 문서/API 조회, 직접 결제 플레이 아님.

사용자 요청은 TD를 참고한 RPG 다이아몬드 상품 추가다. PC/터치 상점에서 수량·실가격·RPG 지급 대상을 명시하는 흐름을 채택한다. 무료 성장·기존 다이아 소비·TD 지갑 계약은 유지한다.

- Diablo IV: [공식 출시 후 운영 설명](https://news.blizzard.com/en-us/article/23952500/what-you-can-expect-from-diablo-ivs-post-launch-experiences)은 Platinum 구매품의 계정 귀속과 상점 사용을 설명한다. 2023년 발표 자료의 구조만 참고하며 현 시즌 가격표로 취급하지 않는다. 적용 원리는 영웅 변경과 무관한 계정 지급이다. 외형 전용 판매 정책은 기존 RPG 장비 판매 결정에 적용하지 않는다.
- World of Warcraft Retail: [공식 WoW Token 안내](https://worldofwarcraft.blizzard.com/en-us/news/20542016)는 실금 구매·경매장 Gold·게임시간/Battle.net Balance의 구분을 설명한다. 2017년 자료이며 현 시세·지역 지원 여부는 미검증이다. 지급 자산과 사용처의 명시만 참고하고 환전/거래/Experience 공유는 도입하지 않는다.
- TD 현재 소스 `../throne-defense/src/Shared/Config.lua`의 `DIAMOND_PACKS`와 Studio `GetProductInfoAsync` 조회를 대조했다. 100/500/1,200 Diamonds, 기본 49/199/399 Robux다. TD ProductId는 각각3728491648/3728491767/3728491886이며 RPG에는 재사용하지 않는다. 가격 비교 목적이며 매출·인기 효과는 추정하지 않는다.
- [Roblox Developer Products](https://create.roblox.com/docs/production/monetization/developer-products), [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService), [상품 관리 API](https://create.roblox.com/docs/cloud/reference/features/developer-products): 반복 구매·실시간 가격 조회·서버 영수증 처리·구매ID 중복 방지가 구현 기준이다. 조회일2026-11-14.

권장안은 동일한 세 묶음의 별도 RPG 상품+기존 계정 키의 영구 영수증 장부다. 비용은 상품 생성 권한·새 상품ID 연결·실계정 결제/재접속 수용이다. 영수증을 별도 키에 저장하면 잔액과 원자적으로 확정할 수 없으므로 채택하지 않는다. 장부는 자동 삭제하지 않으며 장기 운영 시 DataStore 키 크기 모니터링/마이그레이션 설계가 필요하다.

최소 실험은 묶음별 정확 지급, 동일 구매ID 반복, 다른 구매ID 재구매, 저장 성공 후 응답 유실, 동시 서버 fencing, 재접속, 잔액 상한, 오프라인/알 수 없는 상품의 미확정 처리, PC/가로/좁은 화면 검증이다. 지표는 구매ID별 단일 지급과 실패 시 미확정 유지다. 실구매·가격 개인화·실기기 수용은 별도 QA 담당이다. [결과/권한 차단](../evidence/diamond-robux-products-20261114/README.md).
