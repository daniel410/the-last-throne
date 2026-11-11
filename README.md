# The Last Throne / 최후의 왕좌

Throne Defense와 원본 자산을 공유하는 Roblox 협동 액션 RPG. 개발 문서 한국어, 게임 영어(en-US).

현재 소스 버전은 `VERSION`이 정본이다. 로컬 구현·게시·실기기 수용은 서로 다른 상태이며 [현재 상태](docs/production/current-status.md)에서 확인한다.

| 필요한 정보 | 진입점 |
| --- | --- |
| 변경하면 안 되는 계약 | [현재 제품 계약](docs/product-contracts.md) |
| 사용자 결정의 근거 | [결정 조회](docs/decisions.md) |
| 작업ID·의존·수용 조건 | [백로그](backlog.md) |
| 제작 단계·품질 게이트 | [개발 계획](plan.md) |
| 역할·제작 절차 | [역할](agent.md), [스킬](skills/the-last-throne-production/SKILL.md) |
| 커밋·빌드·릴리스 | [개발 마감](docs/development-workflow.md) |

필요한 분야만 검색해 읽는다. `rg -n "검색어" docs/production docs/decisions docs/tasks`로 범위를 좁힌다. `docs/evidence/`는 해당 작업의 검증을 확인할 때만 읽는다. 과거 통합 제안과 `docs/archive/`는 현재 계약의 정본이 아니다.

| 분야 | 상세 자료 |
| --- | --- |
| 본편·지역 | [현재 줄거리](docs/production/campaign-context-review-2026-11-10.md), [전투 동선](docs/production/campaign-combat-routes-2026-11-10.md) |
| 성장·전투 | [스탯](docs/character-stats.md), [전직·트리](docs/class-advancement-and-skill-trees.md), [기사 전투](docs/knight-combat-spec.md) |
| 장비·경제 | [현재4계열](docs/production/equipment-four-tier-reorganization-2026-11-09.md), [특수 효과](docs/production/equipment-special-effects-2026-11-10.md), [가방·창고](docs/equipment-bag-and-storage.md) |
| UI·자산 | [승인 UI](assets/concepts/2026-10-27-shared-ui-v2/approved-baseline.json), [TD 레지스트리](assets/shared/td-asset-registry.json) |
| 기술·QA | [기술 계획](docs/production/engineering-plan.md), [Experience 계약](docs/experience-integration.md), [QA 계획](docs/production/qa-and-release-plan.md) |

새 기록은 관련 사양과 작업 증거에만 추가하고 이 진입점에 변경 이력을 누적하지 않는다.
