---
name: the-last-throne-production
description: The Last Throne의 기존 서사·승인 컨셉·성장·공유 자산을 확인해 Roblox RPG의 설계, 제작 작업, 검증과 백로그를 연결한다. 이 저장소의 개발 작업에 사용하며 TD 운영 변경이나 외부 배포를 자동으로 수행하지 않는다.
---

# The Last Throne 제작

저장소 루트는 이 파일에서 `../..`다. 개발 문서는 한국어, 게임에 표시/재생하는 콘텐츠와 식별자는 영어다. [공통 지침](../../AGENTS.md)과 최신 사용자 요청을 먼저 적용한다.

## 작업 선택과 원천

[plan.md](../../plan.md)와 [backlog.md](../../backlog.md)에서 작업ID·선행·수용 조건·현재 상태를 확인한다. 사용자가 특정 작업을 지정했다면 그 범위를 우선한다. 역할은 [agent.md](../../agent.md)에서 선택하고 해당 역할 파일을 읽는다. 독립 역할의 위임은 사용자 요청과 실행 환경에서 허용한 범위에 맞게 사용한다.

[현재 결정표](../../docs/decisions.md)의 최신 변경과 분야별 상세 사양을 원천으로 삼는다. 오래된 통합 문구와 충돌하면 최신 사용자 결정의 원천을 기록한다. 새 제안은 승인된 사양과 구분하고 담당자·결정 시점·영향받는 작업을 남긴다.

필요한 분야만 추가로 읽는다.

| 분야 | 읽을 자료 |
| --- | --- |
| 서사·성장·경제 | [시스템 제작 계획](../../docs/production/game-systems-plan.md), 관련 epic/story 문서, [스탯](../../docs/character-stats.md), [전직](../../docs/class-advancement-and-skill-trees.md), [보상 정본](../../assets/balance/story-reward-budget.json), [상품](../../docs/items-and-monetization.md) |
| 맵·UI | [디자인 제작 계획](../../docs/production/design-and-world-plan.md), 관련 assets/maps 보드/JSON, [승인 UI](../../assets/concepts/2026-10-27-shared-ui-v2/approved-baseline.json), [장비 UX](../../docs/equipment-bag-and-storage.md) |
| 자산 | [자산 제작 계획](../../docs/production/asset-production-plan.md), [공유 레지스트리](../../assets/shared/td-asset-registry.json), 실제 TD 원본/파생 메타데이터 |
| 구현·연동 | [기술 제작 계획](../../docs/production/engineering-plan.md), [Experience 계약](../../docs/experience-integration.md), [기사 전투](../../docs/knight-combat-spec.md) |
| 수용·출시 | [QA 계획](../../docs/production/qa-and-release-plan.md), 티켓 수용 조건·빌드/데이터/자산 버전 |

## 제작 시 지킬 구분

- 클래스4·클래스별2계열·20/40/60/80 전직, 성녀NPC, 스탯316/별도 스킬79 기준을 보존한다. 수치 제안과 사용자 결정은 공통 지침에서 구분한다.
- 첫 전투 구현은 Deepwood 기사 K0다. 시연용 레벨/계열 해금은 정상 성장·저장 완료로 보고하지 않는다.
- 승인된32구간 보상을 수정할 때에는 보상 정본·해당 시나리오/JSON·계산 보고를 함께 검토한다. 검증 실패를 숨기기 위해 XP를 자동 조정하지 않는다.
- 장비9슬롯·가방 v2·리셋권/성능 장비 판매의 최신 결정을 유지한다. 가격/능력치/용량을 컨셉 그림에서 확정하지 않는다.
- 공유 자산은 후보ID·현재 파일/해시·적합성·파생 사유를 기록한다. 카탈로그 수와 실행 가능한 모델/리그 수를 구분한다.
- TD와 RPG는 독립 Experience다. 공통 Diamonds는 외부 서버 권위 지갑과 각 Experience 영수증 조정 계약이 검증될 때만 제공하며, 그 전에는 장르별 재화를 분리한다. 지갑·창고·아이템·영수증은 동시 요청/불명 응답/재접속 후에도 단일 권리로 복구하는 계약을 설계한다.
- 영어 문자열은 키·en-US 원문·플레이스홀더 계약으로 작성한다. 개발 주석/기획 문장을 게임 화면에 그대로 붙이지 않는다.

## 검증과 마감

티켓이 요구한 수준에 맞춰 정적 데이터 → Studio/엔진 → 실제 클라이언트 → 실기기/멀티플레이 → 사용자 관찰을 구분해 검증한다. 화면이나 문서만으로 저장·결제·성능·Teleport를 통과시키지 않는다. 보상 정합성은 아래 명령으로 원본을 덮어쓰지 않고 확인할 수 있다.

```bash
python3 scripts/simulate_story_progression.py --output /tmp/tlt-progression-check.json
```

변경·재현 조건·결과·미검증 범위를 작업ID와 함께 남긴다. 완료 증거를 충족한 티켓만 상태를 바꾸고, 새로운 제품 결정은 결정표/관련 상세 사양, 전체 순서 변경은 plan/backlog에 반영한다. 작업이 설계에 한정됐다면 구현 완료로 기록하지 않는다.

마감은 [Git·빌드 버전·릴리스·LFS 규칙](../../docs/development-workflow.md)을 따른다. 사용자 지시에 따라 작업 완료마다 해당 파일을 커밋·푸시하고 원격 반영을 확인한다. 여러 역할의 같은 작업은 통합 담당자 한 명이 마감한다. 빌드 시 `VERSION`에 `MAJOR.MINOR.MICRO`를 생성/증가하고 입력 커밋을 고정하며, 실제 릴리스 때만 검증된 빌드 커밋의 `vMAJOR.MINOR.MICRO` 주석 태그를 만들고 푸시한다. 이미지/3D/자산 압축본은 `.gitattributes`의 LFS 규칙으로 저장하고 전송한다. 이 범위의 기존 승인을 반복 질문하지 않는다.
