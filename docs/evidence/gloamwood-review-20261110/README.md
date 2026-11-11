# Gloamwood 에픽·스토리·추가 보스 독립 리뷰

2026-11-10 · TLT-065/032/033/050/057/084 · QA · 검토 소스 `6707ea68dce2ddd4c218a254892285cb73c3b10e`, 보스 추가 `416244da` · 수정 전 리뷰.

판정: 진행·보상 로컬 회귀는 통과하지만 새 보스의 리그 연결 결함 때문에 현 상태 수용 불가. 런타임 수정·게임 빌드·게시는 수행하지 않았다. 기존 사용자 미커밋 변경은 검토 산출물에서 제외했다.

## 발견 사항

1. **P1 / Hollowbark Sovereign 외형이 전투 리그와 분리됨.** `assets/models/hollowbark-sovereign-td-v1/runtime.rbxmx`에는 Body와 VisualRoot만 있고 둘을 묶는 Weld/Joint가 없다. `src/server/World/GloamwoodAppearance.luau:33`은 Body를 unanchored/noncollidable로 바꾸고 36행에서는 HumanoidRootPart와 VisualRoot만 연결한다. 기존 모델 준비 도구 `tools/prepare-gloamwood-meshy-runtime.luau:22`의 MeshRootWeld 전제가 이 신규 TD 템플릿에는 성립하지 않는다. GW-06 마지막 웨이브 스폰 시 외형은 중력 영향을 받는 독립 파트가 되고 이동·공격·피해 리그를 따라가지 못한다. 격리 엔진에서 실제 attach를 호출해 **connectedToRig=false / rootMove=10 / bodyMove=0** 재현. 신규 모델만 Body↔VisualRoot 연결을 추가하거나 장착 단계에서 누락을 보완하고, connected-parts 및 이동 회귀를 추가해야 한다. [재현 스크립트](native-repro.luau), [출력](native-result.log). 두 BasePart의 위치 관계를 유지하려면 연결이 필요하다는 [Roblox Weld 공식 설명](https://create.roblox.com/docs/physics/constraints/weld)과 일치한다.
2. **P2 / GW-07 지도에 구 묘지행 지명이 남음.** `src/shared/CampaignCartography.luau:40`의 GW-07 landmark가 `Hidden Cemetery Gate`다. `DeepwoodMapCanvas.luau:88`은 이를 지도 지명으로, `DeepwoodMap.luau:35`는 선택 상세에 그대로 표시한다. 실제 현행 퀘스트는 북쪽 옛길·Frozen Vale행이며, Haunted Graveyard 진입로는 EC 이후다. 재현 조건은 GW-07 지도/상세 열기다. `src/server/World/EpicWorldArt.luau:15`의 같은 구 지명도 함께 정리하고 생성 원천/지도 정본을 일치시켜야 한다. 이동 자체는 캠페인 정본을 사용하므로 이번 발견은 진행 막힘이 아닌 지도 안내/서사 불일치다.

## 검증 결과

| 명령 | 결과 |
| --- | --- |
| `lua tests/hollowbark-sovereign.spec.lua` | 12,687 PASS. 보스 등록/1~4인 마지막wave/기존 처치 영수증·보상/구완료 보존/모션 데이터. 물리 연결은 검사하지 않아 P1을 놓침. |
| `python3 tests/hollowbark-sovereign-assets.spec.py` | PASS. 해시/스킨/10본/2,484tri/14stud/프로젝트 참조. Weld 연결 미검사. |
| `lua tests/campaign-reorder.spec.lua` | 1,870 PASS. 본편 순서·이관·저장 재시도. |
| `lua tests/campaign-expansion-review.spec.lua` | 3,362 PASS. 결과 전달·회로·경로. |
| `lua tests/campaign-expansion.spec.lua` | 7,698 PASS. 35메인/12사이드/82사건/246단계. |
| `lua tests/enemy-patterns.spec.lua` | 3,717 PASS. 패턴/판정 데이터. |
| `lua tests/late-epics-adventures.spec.lua` | 732 PASS. |
| `lua tests/quest-completion-rewards.spec.lua` | 1,416 PASS. 고정 보상·보충/저장 복구. |
| `lua tests/late-epics.spec.lua` | FAIL, 21행 `next goal available DW-01:exp_1`. `P.new()`에 expansionVersion이 없는데 optional 확장 목표까지 무조건 수행하는 기존 테스트 문제. 이전 보스 작업의 baseline.log에도 같은 실패 기록. 신규 보스 회귀로 분류하지 않음. |
| `python3 scripts/simulate_story_progression.py --output /tmp/tlt-gloamwood-review-progression.json` | 종료0. 승인 예산 산술 결과이며 현재 런타임 35장 성장/체감 증명과 구분. |
| 격리 Rojo 프로젝트 + `run-in-roblox --place /tmp/tlt-gw-review/review.rbxlx --script /tmp/tlt-gw-review/review.luau` | 종료0, P1 재현. 실제 게임 빌드가 아닌 최소 진단 fixture. |

격리 프로젝트에는 현재 XML을 ServerStorage.HollowbarkSovereignTemplate, 빈 Folder를 ServerStorage.GloamwoodMeshyModels, 현재 GloamwoodAppearance 모듈을 ServerScriptService.Appearance에 매핑했다. 게임/TD 문서·DataStore·Place는 변경하지 않았다. run-in-roblox 종료 뒤 해당 `/tmp/tlt-gw-review/review.rbxlx` 경로의 Studio 프로세스가 남지 않음을 확인했다. 다른 기존 TD 세션은 유지했다.

텍스처139387289433234는 격리 실행에서 ContentId 로드 경고가 발생했다. 이 경고만으로 권한 오류나 게시 환경 재현을 단정하지 않으며 실제 TLT 테스트 Experience에서 로드를 확인해야 한다. 이번 엔진 검사는 연결·이동만 검증하며 실제 전투/미술·회피 접점·재접속·모바일·4인+AI 성능·게시 클라이언트 수용은 미검증이다.

다음 담당자: ENG는 P1 Weld 연결 수정과 엔진 이동 회귀, DES/ENG는 P2 지도 지명 정리. QA는 고정 빌드의 GW-06 스폰→추적→공격→처치/재플레이와 GW-07→Frozen Vale 안내를 확인한다. 부모 티켓은 완료 처리하지 않는다.
