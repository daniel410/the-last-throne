# 전직별 스킬 성장 리뷰

2026-10-29 · TLT-013/015/042/052/054~056/058 · PLAN → ENG·DES·QA · 설계 리뷰, 구현 전

사용자 결정: 모든 클래스·계열은 Lv20/40/60/80 **각 전직 완료 시** 이전에 없던 새 스킬을 최소 하나 해금한다. 레벨 도달만으로 자동 전직하지 않는다. 해금과 장착은 별개이며 슬롯은 기본3, Lv20 완료 후4, Lv40 완료 후5다. 궁극기 슬롯은 미결정이다.

## 비교 근거

- [FFXIV Machinist 공식 직업 가이드](https://na.finalfantasyxiv.com/jobguide/machinist/): 레벨과 직업 퀘스트에 따라 서로 다른 공격·포탑·지원 행동을 배운다. 단계별로 조작이 달라지는 예시이며 모든 전직에서 새 기술을 준다는 뜻은 아니다.
- [Diablo IV 스킬트리 설명](https://news.blizzard.com/en-us/article/23938756/make-sanctuary-yoursplay-your-way-in-diablo-iv): 액티브·강화·선택의 시너지를 설계한다. [3.0 트리 설명](https://news.blizzard.com/en-us/article/24267729/prepare-for-the-reckoning-lord-of-hatred-draws-near)은 스킬별 변형 선택을 설명한다. 버전별 구성을 그대로 복제하지 않는다.
- [FFXIV Blue Mage 공식 가이드](https://na.finalfantasyxiv.com/jobguide/bluemage/): 학습한 행동과 전투에 지정한 행동을 구분하고 전투 중 편성 변경을 제한한다. 해당 직업은 별도 규칙을 가진 특수 직업이다.

## 발견과 제안

기존 기사·엘프·드워프는 Lv20/24/28에 계열 액티브를 몰아 Lv40/60 전직에 새 기술이 없었다. 마법사는 Lv20/40/60 신규 주문과 Lv80 최강 주문 방향이 있어 더 가깝다. Lv80은 기존 공통 궁극기 강화가 아니라 별도의 새 계열 궁극기를 제안한다. 직업별 기술의 상세 판정·자원·이름은 가칭이다.

| 계열 | Lv20 신규 | Lv40 신규 | Lv60 신규 | Lv80 새 궁극기 방향 |
| --- | --- | --- | --- | --- |
| Knight 강철 | Counter Slash | Iron Guard | Breaker Charge | 방어·파쇄 |
| Knight 성기사 | Oathblade | Dawn Burst | Radiant Bulwark | 성광 보호 |
| Elf 명궁 | Precision Volley | Weakpoint Shot | Piercing Volley | 정밀 일제사격 |
| Elf 마법궁수 | Elemental Arrow | Vine Trap | Storm Arrow | 정령 화살비 |
| Dwarf 강철 | Armor Splitter | Returning Echo | Mountain Strike | 강한 충격 |
| Dwarf 화약 | Bomb Toss | Scatter Shot | Field Mortar | 공성 포격 |
| Mage Pyro | Ember Lance | Earth Rise | Lava Eruption | 최강 화염 주문 |
| Mage Cryo | Frost Lance | Chain Lightning | Froststorm | 최강 빙결 주문 |

이 배치는 기존 계열 액티브3·궁극기1 예산을 재배치하는 제안이다. 기존 Lv24/28에서 학습할 기술이 사라지므로 그 구간의 성장 경험은 기존 스킬 강화·노드와 콘텐츠를 통해 별도 설계한다. 계열 기술이 열리기 전 그 기술의 숙련 노드에는 투자할 수 없다. 216개 노드의 효과와 선행은 아직 전수 정의되지 않았으므로 79P로 실제 투자 가능한 빌드와 예산을 다시 검증해야 한다.

Lv60에 새 기술을 배워도 슬롯은 5개이므로 사용하려면 기존 편성을 교체한다. Lv80 궁극기도 새 스킬로 제공하되 기존 다섯 슬롯 안에 넣을지 별도 방식으로 쓸지는 미정이다. Lv15 공통 궁극기는 삭제했다. 궁극기 슬롯/사용 방식을 결정해야 사용 가능한 완성 경험을 검증할 수 있다. 스킬 자체의 무료 습득 제안과 강화에 쓰는 79SP를 구분하고, 초기 투자·편성 변경 및 확정 리셋권의 기존 규칙을 유지한다.

시스템의 실용성은 미검증이다. 4인 파티 및 동료 없는 솔로 전투, 보스 제어 면역, Stamina/MP 비용, 성기사 MP 자격, 마법궁수 전직 후 MP, 작은 화면 편성과 전직 직후 사용성, 중복 요청·저장 실패·재접속을 확인한다. 클래스별 스킬/모션/VFX는 시험 원형 외 미구현이다. 다음 담당 PLAN 상세 정의 → ENG 구현 → DES 편성 UX → QA 경계·게임플레이 수용.
