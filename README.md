# The Last Throne / 최후의 왕좌

Throne Defense의 세계관·영웅·타워·맵·몬스터·포탈·왕좌와 3D 자산을 공유하는 Roblox 협동 액션 RPG입니다. 직접 조작 전투, 클래스 안의 전직과 스킬트리, 공명 연계, 탐험과 이야기를 중심으로 최고의 액션 RPG를 목표로 합니다.

**문서 묶음 v0.25 + 2026-10-28 전투 결정 정리 · 최신 시험 빌드 0.17.0 · Deepwood K0 원형 제작·검증**

**개발 문서는 한국어, 게임의 UI·퀘스트·대사·아이템·스킬·상품·오류·음성/자막은 영어(en-US)로 제작합니다.**

Throne Defense와 세계관·원본 자산을 공유하지만, **독립 Roblox Experience**로 공개합니다. 개발 소스·공개 페이지·장르별 성장·장비·스토리·일반 재화는 분리합니다. 공통 Diamonds는 별도 서버 권위 지갑과 권리 조정 계약이 검증되기 전까지 자동 공유하지 않습니다.

## 개발 계획과 에이전트

기존 프롤로그·8장·에필로그 전체 구상, 상세4에픽·28스토리와 프롤로그4구간, 지도·영웅·전직·스탯·스킬·장비·공유 컨셉을 제작 계획으로 연결했습니다. 첫 구현은 **Deepwood 기사 K0 기본 전투**이며 전투→대표 구간→RPG 기반→전체 클래스/본편→후반 콘텐츠→출시 품질 순으로 검증합니다.

| 파일 | 내용 |
| --- | --- |
| [plan.md](plan.md) | 전체 제품·8장 제작 범위·G0~G8·품질·일정/비용 산정·미결정 |
| [backlog.md](backlog.md) | 기존24개ID를 보존한100개 작업·우선순위·담당·의존·수용 조건 |
| [agent.md](agent.md) | 총괄 디렉터·기획·디자인·3D 모델링·엔지니어·QA의 역할과 핸드오프 |
| [AGENTS.md](AGENTS.md) | 이후 작업에서 적용할 저장소 공통 지침·한국어 문서/영어 게임 계약 |
| [skill.md](skill.md) | 프로젝트 스킬 진입점·사용법·검증 명령 |
| [실제 SKILL.md](skills/the-last-throne-production/SKILL.md) | 기존 원천과 제작/검증/백로그를 연결하는 재사용 지침 |

| 분야별 상세 계획 | 내용 |
| --- | --- |
| [현재 개발 상태와 결정](docs/production/current-status.md) | 0.17.0 시험 구현·최신 결정·미구현 차이·다음 작업/수용 |
| [액션·스킬 설계](docs/production/action-and-skill-design.md) | 공통 액션·물리/마법 자원·전직별 슬롯·키/HUD |
| [기획·시스템](docs/production/game-systems-plan.md) | 32구간 추적·후반8장 연결·전직/스탯/스킬·장비/경제·동료 |
| [디자인·월드](docs/production/design-and-world-plan.md) | 승인 컨셉·맵/랜드마크·모바일/패드·가방 v2·접근성 |
| [3D 자산](docs/production/asset-production-plan.md) | 실제 TD 원본 조사·리그/무기/모션·재사용/파생/신규·지역 모듈 |
| [소프트웨어](docs/production/engineering-plan.md) | 서버 전투·콘텐츠 계약·소유/저장·창고/지급·결제/포탈/공통 지갑 |
| [QA·출시](docs/production/qa-and-release-plan.md) | 경계/장애/동시성·TD 회귀·실기기/영어·게이트/출시 판정 |
| [총괄 검토](docs/production/director-review.md) | 통합 우선순위·모순/잔여 위험·완료 수준의 검토 |
| [원천 검토표](docs/production/source-audit.md) | 기존 문서·컨셉·지도·정본 데이터와 새 계획의 연결 |
| [문서 검증 결과](docs/production/validation-report.md) | 링크·백로그 의존·컨셉 해시·성장 정합·스킬 구조의 실제 정적 검사 |

현재 저장소에는 Dawnspire 시험용 로비, 네 영웅 생성·선택, Deepwood 튜토리얼 시험장과 Slime/Goblin/Orc Warrior/Ogre, 서버 전투 및 영어 HUD의 원형이 있습니다. 한 세션에서 Knight·Elf Archer·Dwarf Axe Thrower·Mage를 각 1명 생성해 시험할 수 있으며, 영웅과 튜토리얼 진행은 접속 종료 시 초기화됩니다. 각 영웅의 최초 직업은 고정됩니다. TD 초상과 검·방패·활·도끼, 새 나무 지팡이 및 Roblox 아바타에 적용한 TD 직업 색상을 사용합니다. 전신 플레이어 리그·최종 맵·성능·저장/결제·Experience 연동은 후속 작업입니다. 실제 검증과 남은 항목은 [영웅 로비 기록](docs/evidence/k0/hero-lobby.md)과 [K0 작업 기록](docs/evidence/k0/README.md)을 확인합니다. 공개 콘텐츠 묶음·출시일·인력·예산은 대표 구간의 실제 제작/검증 결과로 정합니다.

## Git·빌드·릴리스

[개발 마감 규칙](docs/development-workflow.md)에 따라 작업 완료마다 커밋·푸시합니다. 게임 빌드는 `MAJOR.MINOR.MICRO` 버전을 생성/증가하고 실제 릴리스에는 검증된 빌드 커밋의 `vMAJOR.MINOR.MICRO` 태그를 푸시합니다. 문서 버전과 게임 빌드 버전은 별개입니다.

이미지·3D 원본·대용량 컨셉 ZIP은 [.gitattributes](.gitattributes)의 Git LFS 규칙으로 관리합니다. 저장소를 새로 받은 환경에서는 `git lfs install --local`과 `git lfs pull`로 실제 자산을 준비합니다. SVG·JSON·Markdown·스크립트는 일반 Git으로 유지합니다.

## 문서 읽는 순서

| 순서 | 문서 | 담당 내용 |
| --- | --- | --- |
| 1 | [기획 결정과 미확정 항목](docs/decisions.md) | 사용자 결정·채택 방향·설계 초안·미정 항목 |
| 2 | [통합 제안서](the-last-throne-rpg-proposal.md) | 전체 세계관·인물·프롤로그부터 결말까지의 서사 |
| 3 | [게임 개발 기획안](docs/game-design.md) | 전투·탐험·성장·협동·경제·기술·운영 기준 |
| 4 | [Deepwood 지역 설계](docs/deepwood-region-design.md) | 주동선7지점·선택3구역·몬스터10종·제단·지역 선택 |
| 5 | [클래스·전직·스킬트리](docs/class-advancement-and-skill-trees.md) | 플레이어4클래스·8전직 계열·32단계·기술·노드·자격 |
| 6 | [기본 스탯·전투 능력치](docs/character-stats.md) | 힘·민첩·지력·체력·파생 능력치·성장/배분 초안 |
| 7 | [기사 전투 상세 명세](docs/knight-combat-spec.md) | 기사 액션·기본 스킬·판정과 전투 성장 초안 |
| 8 | [마법 분류·단계별 학습](docs/magic-schools-and-learning.md) | 비전/바람/물·Pyro/Cryo·추가 원소·광역·최강 주문 |
| 9 | [동료·성녀NPC·전술 지원](docs/companions-and-support.md) | 셀레네·선택형AI동료·보호/정화·교단NPC·편성 |
| 10 | [공유 세계관·자산 활용](docs/shared-universe-and-assets.md) | TD 영웅5·타워30·몬스터40엔트리와RPG 활용/신규 제작 |
| 11 | [Experience·공통 지갑 연동](docs/experience-integration.md) | 독립 Experience 이동·공통 Diamonds 후보·공통 권리·기존TD 보존 |
| 12 | [공통 UI·룩앤필](docs/shared-ui-and-look-and-feel.md) | TD 원본·메뉴/아이콘/이미지/3D 공유·로비/배틀 적용 기준 |
| 13 | [제작 로드맵](docs/production-roadmap.md) | 제작량·단계 게이트·최초24작업·품질/복구 기준 |

과거 변경 과정은 [변경 이력](docs/CHANGELOG.md), 최초 제안의 원문은 [보관 폴더](docs/archive/README.md)에 모았습니다. 루트의 통합 제안서는 현재 기준으로 갱신한 문서입니다. [TD 쪽 업데이트 제안서](../throne-defense/docs/throne-chronicles-rpg-proposal.md)는 공유 세계·연동 방향의 참고 자료이며, 이후 사용자 결정을 우선합니다.

## 현재 전직 구조

플레이어는 **기사·엘프·드워프·마법사4클래스·8전직 계열**입니다. 캐릭터의 최초 클래스는 고정되고 **다른 클래스로 전직할 수 없습니다.** Lv20에 두 계열 중 하나를 선택하고, Lv40·60·80에 같은 계열의 전직을 이어갑니다. 전직 계열 수와 배울 수 있는 마법 속성 수는 별개입니다.

| 클래스 | 계열 A | 계열 B | 결정 상태 |
| --- | --- | --- | --- |
| 기사 | 강철기사 | 성기사 | 사용자 결정 |
| 엘프 궁수 | 명궁 | 마법궁수 | 사용자 결정 |
| 드워프 | 강철 | 화약 | 사용자 결정 |
| 마법사 | Pyro 화염술사 | Cryo 냉기술사 | 사용자 성장 방향 반영 |

- **강철기사:** 기사 → Lv20 강철기사 → Lv40 중갑기사 → Lv60 철벽기사 → Lv80 강철의 수호자. 다른 계열의 상위 전직명은 가칭입니다.
- **마법사:** 비전 또는 바람 훈련 + 기초 물 마법 → Lv20 Pyro/Cryo → Lv40 Pyro 대지·Cryo 번개 → Lv60 대규모 광역 → Lv80 최강 마법. 입문 마법은 전직 후에도 유지합니다.
- **타워 활용:** Crusader와 Paladin은 성기사 계열입니다. 기존 타워와 RPG 전직을 일대일로 맞추지 않고, 필요한 자산은 새로 만들거나 NPC·동료·지원 캐릭터로 활용합니다.

**기본 스탯은 힘·민첩·지력·체력을 적용합니다.** 공격력·방어력·공격속도 등 파생 능력치와 함께 사용하며, **Lv2~80에 레벨업마다 스탯4포인트, 총316포인트**를 자유 배분하며 스킬트리79포인트와 별도로 관리합니다. Lv1은 기본 능력치로 시작하고 한 번 받은4포인트를 한 스탯에 집중할 수도 있습니다. 효과·계열별 활용·추천 배분과 재분배 초안은 [기본 스탯 설계](docs/character-stats.md)에 정리했습니다.

스킬트리의 **79포인트·216노드**, 기본 **액티브36개·궁극기12개**, 같은 클래스의 계열 재선택은 검증할 설계 초안입니다. 전투 스킬은 **전직 전 3개, Lv20 첫 전직 완료 후 5개** 장착하며 궁극기 슬롯은 미정입니다. 본편·던전·레이드 등 전체 완성상과 실제 공개 범위·출시 일정은 구분하며, 미정 사항은 결정표에서 관리합니다.

## 성녀와 Deepwood

[스토리1 고블린 숲길 제작 시나리오](docs/story-01-goblin-trail.md)에 승인한 이야기·경로·등장 몹·성공/재도전·보상/협동 기준을 기록했습니다. 수치 항목은 테스트용 초안으로 관리합니다.

성녀는 **주요 스토리NPC·선택형AI지원 동료·거점/수호전 지원**으로 활용합니다. 성녀의 플레이어 전직·스킬트리는 제외하고 성기사는 기사 전직으로 유지합니다. 성녀 없이도 모든 플레이어 클래스로 본편을 완주하도록 설계합니다. 주요 이야기 동료5명과 다섯 문명의 세계관은 유지하며, 성녀 지원AI·모션·대사는 별도 제작량입니다.

Deepwood는 **고블린 숲길 → 무너진 수레 공터 → 거목 전초기지 → 버려진 감시탑 → 오크 점령지 → 오염된 뿌리숲 → 검은 뿌리의 제단**으로 연결합니다. 필수 보스는 Orc Warlord·King Shaman, 선택 보스는 Goblin King·King Ogre·Enraged Warlord입니다. 구체 지명·배치·수치는 제작 기준안으로 관리합니다.

## 공통 UI·자산 원칙

**TD와 RPG는 메뉴·아이콘·이미지·3D 모델을 최대한 반드시 공유합니다.** 로비·배틀·상세 메뉴는 같은 컴포넌트/자산 원본과 룩앤필을 사용하고 장르별 정보와 동작을 연결합니다. [공통 UI/룩앤필 기준](docs/shared-ui-and-look-and-feel.md)과 [공유 원본 레지스트리](assets/shared/td-asset-registry.json)에 실제 TD 원본 조사와 적용 계획을 정리했습니다. 공통 라이브러리 분리·통일 시안·RPG 런타임 연결은 후속 구현 항목입니다.

## 컨셉 이미지

**v2 공통 UI 컨셉은2026-10-27 사용자 승인 기준으로 저장했습니다.** [승인 기록](assets/concepts/2026-10-27-shared-ui-v2/approved-baseline.json)에 최종9개 이미지 해시와 프롬프트 위치를 보존합니다.

[최신 공통 UI 컨셉 v2 갤러리](assets/concepts/2026-10-27-shared-ui-v2/index.html) · [v2 제작 메모·프롬프트](assets/concepts/2026-10-27-shared-ui-v2/README.md)

TD 실제 아틀라스를 참조한 공통 보드와 로비HUD·로비 메뉴·배틀HUD·배틀 메뉴·스탯·스킬·영웅 생성·원정 메뉴의 **신규9장**, 기존 외형/환경을 유지한 영웅/NPC5·환경3·몬스터10의 **기존18장**을 모았습니다. 생성 시안은 원본을 참조한 컨셉이며 실제 스프라이트 배치·공통 라이브러리·3D 런타임 연결을 완료한 화면은 아닙니다.

[v1 갤러리](assets/concepts/2026-10-27-v1/index.html)와 [Dawnspire 로비 전경](assets/concepts/2026-10-27-v1/world/dawnspire-lobby-v1.png)은 보관합니다. v1의 최초 ZIP은 로비 추가 전 스냅샷이며 최신 UI는 v2에서 확인합니다.

## 다음 구현 작업

Deepwood 시험장에서 네 영웅의 공통 공격·방어·회피·달리기와 직업 스킬을 사용할 수 있습니다. 기사의 기본 스킬은 Shield Bash·Whirlwind·Provoke, 마법사는 Mana Bolt·Water Ball·Gravity입니다. 드워프는 Overhead Smash·Axe Throw·Ground Slam, 엘프는 Aimed Shot·Rapid Fire·Multi Shot을 사용합니다. Whirlwind·Gravity·Ground Slam·Multi Shot은 광역기이며 각 기본 스킬에 시험용 동작과 적중 효과가 있습니다. PC는 왼쪽 클릭 공격, Q/오른쪽 클릭 방어, E 유지 달리기, R/V 회피, 1~5번 장착 스킬, Space 점프, X 표적 해제입니다. 물리 스킬은 Stamina, 마법은 MP와 기술별 쿨다운을 사용합니다. 정식 전직·저장은 미구현이며 5슬롯은 연습 전용입니다. [현재 상태와 검증](docs/production/current-status.md).

## Deepwood 에픽·상세 시나리오

[대삼림의 검은 뿌리: 전체 줄거리와 7개 시나리오](docs/epic-01-deepwood-story.md)를 제작 기준으로 저장했습니다. 이 문서에서 각 구간의 지도·동선·적 레벨·성공 조건·보상·협동·복구 규칙으로 이동할 수 있습니다. 스토리2~7 상세안까지 작성했으며 실제 맵/전투 구현은 다음 단계입니다. 세부 수치는 테스트 초안입니다.

[Deepwood 맵 디자인 보드](assets/maps/deepwood-v1/index.html) · [7스토리 공간 제작안](docs/deepwood-map-design.md): 전체 배치도, 구역별 동선, 도보/장애물/포탈 연결과 축척 초안.

## Frozen Vale 에픽2

[얼어붙은 왕의 기억: 에픽 전체/7스토리](docs/epic-02-frozen-vale-story.md) · [맵 디자인 보드](assets/maps/frozen-vale-v1/index.html) · [공간 제작안](docs/frozen-vale-map-design.md). 기존 제2장을 바탕으로 한 신규 상세 제안이며, 여왕과의 비살상 대면·스타트/리조인·Lv20 첫 전직 연결을 포함한다. 수치와 세부 선택은 검토/플레이테스트 전이다.

## Ember Caldera 에픽3

[꺼지지 않는 용광로: 전체 줄거리/7시나리오](docs/epic-03-ember-caldera-story.md) · [맵 디자인 보드](assets/maps/ember-caldera-v1/index.html) · [공간 제작안](docs/ember-caldera-map-design.md). 도시 보호막·노동자 안전·브란 가문의 책임과 대체 열원 전환을 연결한 신규 상세안이다.7개SP와 재시작/리조인을 포함하며 수치/개인 선택은 검토 전이다.

## Haunted Graveyard 에픽4

[죽은 자들의 증언: 전체/7스토리](docs/epic-04-haunted-graveyard-story.md) · [맵 디자인 보드](assets/maps/haunted-graveyard-v1/index.html) · [공간 제작안](docs/haunted-graveyard-map-design.md). 이름/옛집/징발 기록/베이르/원본/안식을 연결한 신규 상세안이며SP7개·재시작/리조인을 포함한다. 세부 수치/개인 추모 선택은 검토 전이다.

[에픽1~4·28스토리 리뷰 결과](docs/epics-01-04-review.md): 전체 서사 연결, 즉시 수정한 문서 오류, 핵/봉인/성장/협동/반복 플레이 보완 우선순위를 기록했습니다.

[28스토리 Coins/XP/예상 완료 레벨 계산](docs/story-progression-budget.md) · [성장 예산표](assets/balance/epics-01-04-progression.html). 사용자 승인 조정안을28스토리/에픽 보상표/시나리오 데이터에 반영했습니다. 반영된 성장 기준의 검증표이며 실제 게임 런타임 적용·플레이테스트는 아직입니다.

## Dawnspire 프롤로그·아이템 수익화

[Lv1~5 프롤로그/스탯·스킬 튜토리얼](docs/prologue-dawnspire-tutorial.md) · [맵 보드](assets/maps/dawnspire-prologue-v1/index.html) · [아이템/수익화](docs/items-and-monetization.md) · [상품 검토표](assets/economy/item-catalog-v1.html). 프롤로그4구간을 기존28스토리에 이어 Lv1→40을 검증합니다. 스탯/스킬 확정 초기화는 리셋권 소비로 변경하고 실제 장비 상품도 포함했습니다. 가격/계수는 신규 제안이며 실제 상품/맵/결제 구현은 아직입니다.

## 장비 장착·가방·스토리지

[기능 기획](docs/equipment-bag-and-storage.md) · [간소화 콘셉트/동작 보드](assets/concepts/2026-10-27-equipment-storage-v2/index.html).9슬롯을 유지하고 기본 진입을 가방으로 통합했습니다. 고정 슬롯 자동 지정·접힌 상세/정리·거점 창고·미수령 배지·단계별 안내를 반영했습니다. 용량60/120은 신규 제안이며 실제 Roblox UI/저장 구현은 아직입니다.
