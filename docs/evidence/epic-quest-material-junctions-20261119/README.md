# 다섯 에픽 퀘스트 시설의 지형 접합부 검증

2026-11-19 현지 시각 · TLT-061 / TLT-065(GW) / TLT-062 / TLT-063 / TLT-064 · G5 진행 중

[환경 아트의 RPG 사례 조사와 장별 제작표](../../research/2026-11-19-epic-quest-material-junctions.md) · [0.114.2 기준 빌드](../epic-quest-readability-20261119/build.json) · [0.114.4 후보 빌드](build.json)

| 스토리 | 실제 맵 변경 |
| --- | --- |
| DW-02 | 약품 보관 선반 처마 아래에 자갈 낙수받이와 낮은 돌 끝단을 배치했다. |
| GW-06 | 후위 등불 아래 노출 뿌리의 양쪽에 낮은 회청색 셰일을 붙였다. |
| FV-04 | 관측 받침의 압설·암빙 위에 철제 받침판과 체결부를 드러냈다. |
| EC-05 | 공동 도면대 양끝으로 내화 벽돌과 현무암으로 된 마른 회수 홈을 연장했다. |
| HG-04 | 윈치 베어링 아래 석조 받침과 측면 버팀을 추가했다. |

[중간 빌드 0.114.3](build-0.114.3.json)에서 EC 회수 홈의 코너 바닥끼리 같은 높이로 겹치는 것을 소스 검토에서 확인했다. 0.114.4는 바닥과 가장자리 부품을 맞대어 배치한다.

## Studio 재현

두 Place 파일을 같은 Studio 환경에서 별도로 연다. 활동에 배치된 기본 배우와 소품을 포함하고 프롬프트와 떠 있는 라벨을 숨긴 뒤 동일한 지역 조명과 13개 카메라로 비교한다.

```sh
evidence=docs/evidence/epic-quest-material-junctions-20261119
camera=docs/evidence/epic-quest-readability-20261119/camera-setup.luau
capture=docs/evidence/epic-approach-readability-20261118/capture-approaches.luau
check=docs/evidence/epic-quest-landmarks-20261119/check-landmarks.luau
cat "$camera" "$capture" > /tmp/tlt-quest-junction-before.luau
cat "$camera" > /tmp/tlt-quest-junction-after.luau
sed "s/GetAttribute('QuestLandmarkVersion') == 1/GetAttribute('QuestLandmarkVersion') == 3/" "$check" >> /tmp/tlt-quest-junction-after.luau
cat "$capture" >> /tmp/tlt-quest-junction-after.luau
run-in-roblox --place builds/0.114.2/TheLastThrone-0.114.2.rbxlx --script /tmp/tlt-quest-junction-before.luau > /tmp/tlt-quest-junction-before.log 2>&1
run-in-roblox --place builds/0.114.4/TheLastThrone-0.114.4.rbxlx --script /tmp/tlt-quest-junction-after.luau > /tmp/tlt-quest-junction-after.log 2>&1
python3 tools/prepare-campaign-expansion-native.py
run-in-roblox --place builds/0.114.4/TheLastThrone-0.114.4.rbxlx --script /tmp/tlt-campaign-expansion-native.luau > /tmp/tlt-quest-junction-regression.log 2>&1
python3 "$evidence/make-comparison.py" /tmp/tlt-quest-junction-before.log /tmp/tlt-quest-junction-after.log /tmp/tlt-quest-junction-regression.log
```

## Lua 회귀

| 실행 | 결과 |
| --- | --- |
| `lua tests/campaign-context-review.spec.lua` | 1,060건 통과 |
| `lua tests/campaign-expansion-review.spec.lua` | 3,492건 통과. 기준 소스에서 `field action introduces no persistent decision` 단언이 실행에 따라 통과하거나 실패했다. 이 단언은 `next`가 반환한 첫 키를 비교한다. |
| `lua tests/campaign-mode-progress.spec.lua` | 4,493건 통과 |
| `lua tests/campaign-combat-routes.spec.lua` | 77,381건 통과 |

Lua 5.5.1에서 `deepwood-quests.spec.lua`, `campaign-expansion.spec.lua`, `quest-completion-rewards.spec.lua`의 보상 단언은 기준 소스와 후보 소스에서 같은 위치에서 실패했다. 두 소스 사이의 공유 게임 규칙과 테스트 파일은 동일하다.

## Studio 결과와 인계

- 다섯 모델의 89부품은 고정·비충돌·비터치·비쿼리다. 모델과 퀘스트 앵커의 위치는 0.114.2와 일치한다. 각 모델의 중심과 모서리 접지 25곳에서 바닥 오차는 0스터드였고 같은 월드 요청은 캐시된 모델을 반환했다. [Studio 측정](studio-results.json)
- 13쌍을 비교했다. EC의 회수 홈은 정면에서 꺾이는 방향이 보이며 반대 측면에서도 도면대 양끝으로 드러난다. 상호작용부와 회수 홈은 높이와 재질이 달라 화면에서 구분된다. GW 귀환 시점에서는 셰일 단면이 보이며 어두운 본선 정면에서 차이는 작다. DW 낙수받이는 측면에서 보이고, FV의 금속 받침 위로 기존 신호가 드러나며 HG의 베어링 받침이 윈치 아래에 보인다. HG 동맹 방향의 Brann과 윈치는 계속 노출된다. [동일 카메라 전후 비교](comparison.jpg)
- 고정 소스 확인과 Luau 컴파일 검사를 포함한 Studio 회귀 9,193건이 통과했다. 사건 82곳의 동선·바닥 표본 3,968개에서 차단 0건이었다. FV 신호, EC 물리 조작 및 단계 저장, HG 동맹과 성문 진행도 회귀에 포함됐다.

다음 담당은 환경 아트와 QA다. 실제 R15 입력으로 GW 본선과 귀환에서 등불 최초 발견 시점을 기록하고, EC 도면을 조작할 때 회수 홈을 구분할 수 있는지 관찰한다. 실제 입력, 전투 카메라, 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 사용자 미술 수용은 미검증이다.
