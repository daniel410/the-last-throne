# 오크·오우거 HP 복원 및 Easy 원인

2026-11-04 · TLT-005/057/061/084 · ENG → QA

사용자가 직전2배 상향을 과도하다고 판단하여 원상복구를 요청했다. `980fd80`의 런타임/테스트/기록 변경을 역적용했다. 다른 미커밋 변경은 보존했다.

Deepwood의 `DeepwoodService.applyBalance`는 `Balance.unitStats`로 산출한 값을 `StoryHealth`에 기록한다. `CombatService.registerEnemy`는 이를 훈련장용 `K0Config.Enemy[kind].health` 위에 덮어쓴다. 현재 Easy v2 솔로의 일반 적 HP식은 `round((100 + level ×25) × family.hp)`이며 오크 배율1.1, 오우거1.35다. 둘 다 일반 적이며 오우거에게 보스 HP식을 적용하지 않는다. 훈련장의 오크900/오우거6000은 이 경로의 기준값이 아니다.

실제 DW-05의 두 종족은Lv9다. 복원 후 `Difficulty.stats` 직접 실행에서 Easy 솔로 오크HP358/공격19, 오우거HP439/공격21을 확인했다. 즉 훈련장과 본편의 서로 다른 HP 계약 및 작은 종족 배율 차이가 낮은HP의 원인이다. 사용자의 실제 접속 세션/파티/저장 규칙 버전은 관찰하지 않았으므로 이 수치를 해당 화면의 실측이라고 보고하지 않는다.

검증:

- `lua tests/difficulty-balance.spec.lua`:2629검사 PASS.
- `lua tests/deepwood-encounter-balance.spec.lua`:3111검사 PASS.
- `lua tests/k0-rules.spec.lua`:125검사 PASS.
- 변경4파일(`Difficulty`, `DeepwoodEncounterBalance`, `K0Config`, `k0-rules.spec`)을 상향 전 커밋과 바이트 비교해 동일함을 확인한다.

새 빌드/Roblox 게시/Studio 실행은 하지 않았다. VERSION0.69.6 유지. 부모 티켓 상태 유지. 다음 담당 QA는 후속 조정이 요청되면 Easy의 실제 파티/레벨별 처치 시간을 확인한다.
