# 몬스터 복귀 시 체력 유지

2026-11-05 · TLT-005/032/057/084 · ENG → QA · 로컬 소스 수정·미게시

사용자가 추격 후 원위치로 돌아오는 몬스터의 체력 전량 회복 제거를 요청했다. 프로젝트 제작 스킬의 원인이 명확한 결함 수정 절차를 적용했다.

## 변경과 범위

- `src/server/Combat/CombatService.luau`: `resetEnemy`의 체력 회복을 명시적 `restoreHealth` 인자로 분리했다. 추격 대상 상실/거리 초과 후 복귀는 현재 체력을 유지하고, 기존 파티 전멸 호출만 `true`로 회복한다.
- 피해를 입은 채 Idle인 몬스터가 매 Heartbeat마다 복귀 초기화/PivotTo를 반복하지 않도록 상태 조건을 추가했다. 복귀 이동·공격/상태이상 정리·자세 회복은 기존 계약을 유지한다.
- 사망 적은 초기화하지 않으며 기존 새 개체 리스폰과 보상 경로는 변경하지 않았다. 사용자 Blender 파일과 미추적 산출물은 보존했다.

## 검증

| 명령/조건 | 결과 |
| --- | --- |
| `lua /tmp/tlt-enemy-return-check.lua` | 실제 수정된 `resetEnemy` 본문을 읽어 엔진 객체만 stub으로 대체한 격리 검사21개 PASS. HP1/217/899/900 복귀·반복 복귀 유지, 이동/공격 상태 정리, 전멸 회복, HP0 부활 방지 |
| `lua tests/k0-rules.spec.lua` | 기존 전투 규칙125개 PASS |
| `/private/tmp/td233-luau/luau-compile src/server/Combat/CombatService.luau` | PASS |
| `git diff --check` | PASS |

격리 검사는 서버 Heartbeat/실제 Humanoid를 실행한 Studio 검증이 아니다. 새 게임 빌드·VERSION 증가·릴리스 태그·Roblox 게시를 하지 않았다. 실제 클라이언트/실기기 및 일반 적·보스의 추격→복귀→재교전·파티 전멸/리스폰 검증은 미실행이다. 다음 QA는 해당 시나리오에서 복귀 전후 HP가 같고 재교전 피해가 누적되는지 확인한다. 부모 티켓의 완료 상태는 변경하지 않는다.
