# 에픽 퀘스트 다양화 검증

2026-11-19 · TLT-050/061/062/063/064/065 · G5 진행 중

[공식 사례와 에픽별 구현·확장 계획](../../research/2026-11-19-epic-quest-variety.md) · [0.114.0 고정 빌드 기록](build.json)

빌드 소스는 `e7574cafafb6bd8f59999c8d43465806100c37eb`이다. Rojo로 만든 단일 Place는 [TheLastThrone-0.114.0.rbxlx](../../../builds/0.114.0/TheLastThrone-0.114.0.rbxlx)이며 26,641,976바이트다. SHA-256은 `54a9e4ab1baf7ae725800b2ef69dd8331f36c1f90a1e9e0048740fb8166baca9`이다.

## 정적·계정 회귀

| 검사 | 결과 |
| --- | --- |
| `lua tests/campaign-expansion-review.spec.lua` | 3,492건 통과. 여덟 사건의 신규·부분 저장, 정답/오답, 기존 세 단계 모양 복원, 중복 완료 무지급을 확인했다. |
| `lua tests/campaign-mode-progress.spec.lua` | 4,493건 통과. 새로운 `resolve` 입력을 실제 `AdventureRules.event`에 넣어 Easy/Hard/Insane/Hell에서 본편 35장씩 완주했다. 난이도별 지급, 반복 요청, 다른 난이도 기록과 로드 회귀를 확인했다. |
| `lua tests/campaign-mode-legacy-replay.spec.lua` | 3,723건 통과. 기존 계정의 에픽 누락, 이어하기, 재접속과 지급 영수증 회귀를 확인했다. |
| `lua tests/campaign-context-review.spec.lua` | 1,060건 통과. 47장 원고와 418개 저장 전이를 확인했다. |
| `lua tests/campaign-combat-routes.spec.lua` | 77,381건 통과. 88개 조우·315개 교전 지점, 1~4인 인원별 적 구성과 지급 ID를 확인했다. |
| 0.113.26과 런타임 데이터 비교 | 기준 소스의 `DeepwoodProgress.validate`가 새 현장 행동 8개를 포함한 본편 전이 402개의 저장 결과를 모두 읽었다. 47장의 `reward` 및 `combatRoutes`를 기준 소스와 필드별로 비교해 일치했다. |
| `lua tests/campaign-expansion.spec.lua` | 첫 Gold 합산 기대값 `19170` 검사에서 중단됐다. 변경 전 `76cf564f`의 파일만 별도 폴더에 풀어 동일 오류를 재현했다. 위 난이도별 테스트는 현행 보상 계약으로 완주한다. |

## Studio 재현

```sh
python3 tools/prepare-campaign-expansion-native.py
run-in-roblox --place builds/0.114.0/TheLastThrone-0.114.0.rbxlx --script /tmp/tlt-campaign-expansion-native.luau
```

격리된 Studio Place에서 빌드에 들어간 모듈 소스를 대조한 뒤 Shared·Server·Client Luau를 컴파일한다. 다섯 지역을 생성하고 실제 프롬프트·장면·회로·저널과 3개 지도 크기로 회귀를 검사한다. 활동 입력은 서버에 테스트 캐릭터 위치와 실제 프롬프트의 콜백을 연결한다.

**9,193건 통과.** 바닥·이동 표본 3,968곳에서 차단 0건이었다. GW의 두 본선 도착은 이전 호위 위치에서 발동하지 않았고, 부분 저장 이후 새 위치에서 후위전이 열렸다. FV는 오답을 처리하고 먼 거리의 선택을 거절했으며 정답을 한 번 저장했다. 저장 결과에 맞춰 수호수가 방향을 바꿨다. EC의 여섯 물리 선택, HG의 성문과 Brann, 현재 로비 복원 장면도 확인했다. [Studio 결과](studio-results.json)

## 인계와 남은 수용

다음 담당은 QA·기획이다. 게시 클라이언트의 실제 저장 재개, PC·터치·패드에서 다섯 장 플레이, 실계정 파티 최대 4인의 혼합 진도, 기준판 대비 우회 보행과 재미 체감이 수용 범위다. 이 후보는 Roblox 미게시 상태다.
