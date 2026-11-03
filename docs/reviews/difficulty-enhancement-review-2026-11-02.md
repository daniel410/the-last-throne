# 난이도·원정 반복·강화 재검토

2026-11-02 · TLT-027/029/041/043/044/045/052/061/073/084 · ENG/QA 리뷰 · 상태: R1~R3 코드 수정·격리 회귀 통과 / 게시 클라이언트 QA 후속

대상은0.62.1의 기능 커밋 `8a083a0` 및 `354ef89`와 현재 작업 파일의 관련 경로다. 이후 월드 소품 작업과 미커밋 TD 이동 변경은 발견 원인으로 포함하지 않는다. 사용자 요청은 리뷰이며 게임 코드를 수정하거나 빌드/게시하지 않았다. 현재 다른 작업의 VERSION·자산·미커밋 코드는 보존했다.

> 후속 사용자 요청으로0.62.4에서 세 결함을 수정했다. [수정·검증·미검증 기록](../evidence/difficulty-enhancement-fixes-20261102/README.md). 아래는 수정 전 발견 당시 기록이며 실제 클라이언트 수용은 후속이다.

## 발견 사항

### R1 / P1 — 출발 실패 전에 이전 활성 원정을 덮어쓴다

위치: `src/server/Network/ExpeditionService.luau`의 `startRunLocked`에서 `beginExpedition` 루프 및 그 뒤의 `createRun`/`prepareTransfer` 실패 처리. 활성 원정 덮어쓰기는 `src/shared/AdventureRules.luau:53`이다.

이전 전투 원정에서 연결이 끊겨 로비로 돌아온 영웅이 새 출발을 시도하면, 새 MemoryStore 원정 생성/이동 준비가 성공하기 전에 계정의 `expeditions.active`를 새 runId와 초기 저널로 저장한다. 이후 `createRun`이 실패하면 forming 상태만 복구하며 이전 활성 원정/체크포인트는 되돌리지 않는다. 다른 파티원의 저장/전송 준비가 실패하는 경우에도 앞서 저장한 멤버가 같은 영향을 받는다.

이전 rejoin 영수증이 남아 있어도 Battle의 `Difficulty.verifyRun`이 계정 활성 runId 불일치를 감지해 거부한다. 원래 반복 원정의 중간 저널/처치 기록을 새 출발 실패만으로 잃는다. 원본 본편 초회 기록까지 지워지는 문제는 아니다.

재현은 이전 원정의 첫 전투 목표를 저장한 후, 실제 출발 코드의 순서대로 새 `A.begin`을 커밋하고 뒤의 원정 생성이 실패한 상태를 가정해 이전 manifest를 검증한다. 결과는 `oldRunAdmitted=false / AdventureChanged / previousCheckpointRetained=false`다. 실제 네트워크/MemoryStore 장애 주입 전체 실행은 하지 않았으며, 실패 분기의 복구 부재와 데이터/검증 결과를 결합한 재현이다.

권장 수정: 이전 활성 원정을 보존한 출발 준비 상태를 두고 서버 원정/전체 멤버 준비가 확정될 때 새 원정을 활성화한다. 알려진 취소/실패는 이전 원정으로 복구하되 불명 저장 응답을 실패로 단정해 새 영수증/임의 환급을 만들지 않는다. `createRun` 실패·파티 두 번째 멤버 실패·Teleport 실패 후 기존 원정 재접속 테스트가 필요하다.

### R2 / P2 — 완주 조건을 충족하지 못한 선택 임무에 입장할 수 있다

위치: `src/shared/Difficulty.luau:23`의 `c.minMain` 검사. 관련 조건은 `FrozenValeContent`의FV-Q1 보고 `minMain=8`, `EmberCalderaContent`의EC-Q1 보고 `minMain=15`다.

FV-Q1은 main7에서 입장을 허용하지만 마지막 보고는 main8이 필요하다. EC-Q1도 main14에서 허용하고 마지막 보고는15가 필요하다. 새 원정에서는 `expeditionMission`으로 다른 본편 진행을 차단하므로 같은 원정 안에서 이 조건을 채울 수 없다. 입장 후 수집을 마쳐도 보고가 `StoryLocked`로 막히고, 로비로 나가 본편을 진행한 뒤 다시 출발해야 한다.

순수 실제 리듀서 재현 결과 두 임무 모두 `admitted=true`, 보고 `StoryLocked`, `canAdvanceMain=false`다. 권장 수정은 임무 전용 원정의 입장 자격에 모든 필수 목표/보고 장소의 본편 선행을 포함하거나, 다른 본편을 진행할 수 있는 기존 선택 퀘스트 흐름과 원정 흐름을 명시적으로 분리하는 것이다.

### R3 / P2 — 탐색 저장과 지도 표시가 서로 다른 저널을 사용한다

위치: `src/server/Inventory/InventoryService.luau:215`의 원정 저널 projection과 `src/server/Inventory/InventoryRules.luau:379`~382의 탐색 갱신.

원정 시작 때 복사한 `active.journal`을 모험 중 화면에 보내지만, 실제 위치 기반 탐색은 계속 `hero.deepwood.explored`만 갱신한다. 새 셀을 밟고 저장에 성공해도 원정 화면의 탐색 셀은 그대로다. 초회 원정에서는 다음 이야기 이벤트가 저널을 다시 복사할 때까지 늦게 반영되고, 반복 원정은 `P.apply(active.journal,...)`만 사용하므로 새 탐색이 끝까지 표시되지 않는다.

새 원정→`R.explore(...,'DW-01',2,2)` 재현에서 `canonicalRevealed=true / activeRevealed=false`다. 권장 수정은 탐색을 개인 공통 단일 원천으로 유지해 projection 때 합치거나, 같은 계정 트랜잭션에서 원정 저널에도 갱신하는 것이다. 탐색만 수행한 즉시/재접속 후 지도 셀 표시 테스트가 필요하다.

## 검증·한계·인계

- `lua tests/difficulty-enhancement.spec.lua`: 기존95검사 통과. 위 세 경계는 해당 묶음에 없으므로 통과가 발견 사항을 반증하지 않는다.
- `lua docs/evidence/difficulty-enhancement-review-20261102/repro.lua`: 발견 사항을 확인하는 assertion 및2종 선택 퀘스트/탐색/실패 출발 상태 재현 성공. [스크립트](../evidence/difficulty-enhancement-review-20261102/repro.lua), [출력](../evidence/difficulty-enhancement-review-20261102/repro.log).
- 실제 계정·게시된 클라이언트·기기·다인·네트워크 장애 주입은 실행하지 않았다. 강화 비용/원장/동일 요청 처리에서 이번 재검토로 확정한 추가 결함은 없으며, 이를 전 범위 무결함으로 해석하지 않는다.
- 다음 담당: ENG가R1 복구 계약, PLAN/ENG가R2 선행, ENG/DES가R3 projection을 수정하고 QA가 실제 서비스/재접속을 재검증한다. 상위 티켓 수용·게시 완료를 선언하지 않는다.
