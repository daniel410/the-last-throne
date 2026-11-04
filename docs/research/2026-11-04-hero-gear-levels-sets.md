# 영웅 장비·착용 레벨·세트 조사와 재리뷰

2026-11-04 · TLT-027/029/044/045/082 · RESEARCH → PLAN/ART/ENG/QA

[Grim Dawn 공식 아이템 가이드](https://www.grimdawn.com/guide/items/the-hunt-for-loot/)는 테마와 기능으로 묶인 세트가 상승효과를 가지므로 개별품 수치를 동급품보다 낮춰 보상한다고 설명한다. 적용 판단: 세트 보너스를 개별품/강화/Unique 효과에 추가만 하면 과해지므로 장비 예산 차감과 비세트 대안을 함께 비교한다. 본 프로젝트의97%·2% 수치는 자체 시험 가설이다.

[Diablo IV 공식 개발 초기 아이템 설명](https://news.blizzard.com/en-us/article/23189677/diablo-iv-feature-overview)은 Legendary가 세트와 동등하거나 더 강력한 선택지가 되게 하려는 당시 의도를 설명한다. 현재 운영 밸런스를 입증하지 않는다. 적용 판단: 공통 장비·혼합 장비도 유효하고 세트가 본편/전직 필수가 되지 않게 한다.

[Diablo IV 공식 난이도 설명](https://news.blizzard.com/en-us/article/24140803/conquer-colossal-foes-in-season-of-hatred-rising)은 높은 난이도의 고등급 드롭 유인을 설명한다. 우리 착용Lv나 적Lv에 대응하는 수치를 복제하지 않는다. 현재 로컬 ItemCatalog는 Lv1/5/10 중심, Difficulty의 후반 Easy 입장Lv27 시험값, Hell 적Lv80 이상이다. 따라서 레벨과 희귀도를 분리하고 각 보스/모드의 고정 세대·무료 성장 장비를 먼저 마련해야 한다.

검토 결론: 모든 품목×6등급×7세대를 한 번에 완성하겠다는 방식은 제작량과 검증 비용이 크다. 37개 계열과 Lv10 222변형을 명세 초안으로 준비하되 첫13실루엣부터 순차 제작한다. 세트는 5부위로 통일해 기사 방패/장신구 보너스가 타 클래스보다 많아지지 않게 하고 같은 세대/등급만 합산한다. 특수 MP/블록 효과는 현재 Power/Armor/Health 강화 엔진과 별도 구현이 필요하다. 연구는 제품 수용을 대체하지 않는다. [상세 설계 및 검증 범위](../production/hero-equipment-and-icon-plan-2026-11-04.md)를 따른다.
