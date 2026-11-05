# 로비 복귀 후 딥우드 진도 재설정 방지

2026-11-04 · TLT-050/057/061/084 · ENG → QA

사용자 관찰: 딥우드7/7의 전투를 끝내고 Eryn에게 돌아가는 도중 로비로 복귀한 뒤2/7로 표시된다. 보고 전에는 Story7의 최종 완료가 아니지만, 완료된 전투/기믹/수집 체크포인트는 유지해야 한다.

원인: 원정의 `active.missionId`는 최초 입장 검증을 위해 고정된다. 본편을 계속 진행해도 로비의 기본 선택은 이 최초 임무를 재사용해 새로운 반복 원정을 시작했다. Studio에서는 로비로 돌아와도 명시적 임무 선택 캐시가 남을 수 있었다. 영구 `hero.deepwood`를 되돌리는 쓰기와 별개로, 반복 플레이 journal이 초반으로 돌아가는 경로다. 실제 사용자 계정 저장본은 조회/수정하지 않았으므로 영구 기록이 남아 있는지는 미검증이다.

수정:

- `AdventureRules.selection`으로 원정 journal의 현재 스토리를 기본 선택한다. 이미 초반 Easy 반복 journal이 생성됐더라도 영구 초회 진행이 더 앞서 있으면 그 진행을 우선해 복구한다. 고의로 초반을 반복하려면 해당 임무를 명시적으로 선택하며, 그 임무의 같은 난이도 체크포인트는 유지한다. 캠페인 전체 완료 때에도 최초 입장 스토리로 되돌리지 않는다.
- 같은 난이도·현재 미완료 스토리의 새 admission/runId에는 기존 journal을 복사해 전투·수집·대화 하위 체크포인트를 유지한다. 임의 다른 임무 또는 난이도 선택은 기존 반복 플레이 계약을 따른다. 신규 원정의 입장 권위/보상 원장은 기존 검증 경로를 유지한다.
- 로비 복귀 시 이전 임무 선택 캐시를 정리한다. 명시적으로 새 임무를 선택하는 기능은 유지한다.
- Eryn 보고 전에는 `main=6`, Story7 진행 중이 정상이다. `DW-07:king_shaman`·`DW-07:separate` 등을 보존해 보스를 다시 처치할 필요가 없으며 Eryn 보고 후 `main=7`, 다음 Frozen Vale로 진행한다.

검증: 실제 reducer/네트워크 함수 본문을 실행한 순수 Lua 검사이며 Roblox 실제 계정/Teleport·클라이언트 검증과 구분한다.

| 명령 | 결과 |
| --- | --- |
| `lua tests/story-lobby-resume.spec.lua` |24개 통과: Story1 출발→Story7 보스/공급품 완료→Eryn 보고 전 로비 선택→새 runId→체크포인트 유지→보고/다음 에픽, 중복 보상·반복 플레이 하위 진행·오래된 원정 차단·실제 선택/복귀 캐시·본편 완결 기본 선택 |
| `lua tests/story-continuation.spec.lua` |1,017개 통과 |
| `lua tests/difficulty-enhancement.spec.lua` |125개 통과 |
| `lua tests/difficulty-balance.spec.lua` |2,637개 통과 |
| `lua tests/expedition-departure.spec.lua` |42개 통과 |
| `lua tests/story-region-handoff.spec.lua` |52개 통과 |
| `lua tests/party-story.spec.lua` |2,765개 통과 |

명확한 결함 수정으로 별도 비교 게임 조사는 생략한다. 원정 이동/회피/무기/능력치의 기존 미커밋·스테이징 변경은 보존하며, `ExpeditionService`는 이번 선택/복귀 캐시 부분만 커밋한다. TD·live DataStore·실상품·Roblox 게시를 변경하지 않는다.

미검증/다음 담당 QA: 실제 게시된 Lobby/Battle에서1~4인으로 보스 처치 후 Eryn 보고 전 복귀·재접속·새 원정 입장·저장 응답 유실·완료 후 다음 에픽 기본 선택을 확인한다. 사용자 저장본의 삭제/복원 여부는 확인되지 않았다. 본편 전체/멀티 게이트는 미완료로 유지한다.
