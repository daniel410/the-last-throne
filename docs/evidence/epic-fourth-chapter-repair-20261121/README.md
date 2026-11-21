# 다섯 에픽 4장 복구 설비와 귀환 지형 검증

2026-11-21 UTC · TLT-061/DW-04 · TLT-065/GW-04 · TLT-062/FV-04 · TLT-063/EC-04 · TLT-064/HG-04 · G5 진행 중

[이전 화면 검토와 제작표](../../research/2026-11-21-epic-fourth-chapter-repair.md) · [0.115.23 기준 빌드](../hero-skill-beats-20261121/build.json) · [0.115.24 후보 빌드](build.json)

| 에픽 | 실제 맵의 변경 | 부품 |
| --- | --- | ---: |
| Deepwood | 망루에서 늘어진 케이블을 석축 발치 철제 고리와 마모석에 연결했다. | 10 → 14 |
| Gloamwood | 뿌리가 들어 올린 돌 아래 밝은 셰일층과 등불 받침의 쪼개진 단면을 드러냈다. | 9 → 12 |
| Frozen Vale | 석축 사이 오목한 중계축과 고정 고리, 밀린 눈 가장자리를 만들었다. | 8 → 12 |
| Ember Caldera | 두 냉각관에 서로 다른 결손이 난 테두리와 안쪽으로 들어간 어두운 개구부를 만들었다. | 11 → 21 |
| Haunted Graveyard | 집결로를 향한 석축 모서리를 깎고 좁은 마모 끝돌로 연결했다. | 8 → 11 |

## 화면과 검증

- [동일 카메라 10쌍](comparison.jpg)에서 접근·귀환을 비교했다. DW 케이블의 하단 연결과 FV 중계축은 귀환 측에서 구분된다. EC 관 안쪽은 가까운 사선에서 보이며, 접근에서는 파손 테두리 위주로 읽힌다. GW의 셰일과 등불 절단면은 야간 정면에서 대비가 낮다. HG의 마모 모서리는 근경에서 보이며 집결 방향 시점의 차이는 작다.
- [Studio 측정값](studio-results.json)에서 5개 지물의 조사 앵커·피벗·수평 외곽과 주변 지물 30개가 두 빌드에서 일치했다. 접지 25점의 바닥 오차는 0이었다. 보행선 최소 이격은 EC 3.67스터드, HG 지물과 집결 동료의 최소 이격은 7.76스터드였다. 기준·후보 각각 점프를 끈 R15 자동 보행 5개 접근·귀환을 통과했다.
- 순차 실행에서 두 빌드의 Studio 캠페인 회귀가 각각 9,193건을 통과했다. 사건 82개, 단계 246개와 바닥·동선 3,968개 표본에서 차단 0건이었다. 병렬 실행 중 두 스크립트가 같은 Studio에 주입된 결과는 폐기했다.
- Lua 에픽 지도 105,907건, 이야기 소품 4,264건, 난이도 진행 4,493건, 전투 경로 77,381건을 통과했다. 빌드 도구는 Rojo 7.7.1이다.

다음 담당은 환경 아트와 QA다. GW 야간 최초 발견, EC 조사 위치에서 냉각관을 바라보는 각도, HG 동료가 집결한 뒤 귀환 동선을 실제 입력으로 확인한다. 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 전투 카메라와 사용자 미술 수용은 미검증이다.

## 검증 재현

```sh
original=docs/evidence/epic-fourth-chapter-landmarks-20261120
evidence=docs/evidence/epic-fourth-chapter-repair-20261121
audit=/tmp/tlt-mid-review.luau
cat "$original/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$original/walk-approaches.luau" > "$audit"
run-in-roblox --place builds/0.115.23/TheLastThrone-0.115.23.rbxlx --script "$audit" > /tmp/tlt-mid-baseline.log 2>&1
run-in-roblox --place builds/0.115.24/TheLastThrone-0.115.24.rbxlx --script "$audit" > /tmp/tlt-mid-candidate.log 2>&1
python3 tools/prepare-campaign-expansion-native.py
run-in-roblox --place builds/0.115.23/TheLastThrone-0.115.23.rbxlx --script /tmp/tlt-campaign-expansion-native.luau > /tmp/tlt-mid-baseline-expansion.log 2>&1
run-in-roblox --place builds/0.115.24/TheLastThrone-0.115.24.rbxlx --script /tmp/tlt-campaign-expansion-native.luau > /tmp/tlt-mid-candidate-expansion.log 2>&1
python3 "$evidence/compare.py" /tmp/tlt-mid-baseline.log /tmp/tlt-mid-candidate.log \
    /tmp/tlt-mid-baseline-expansion.log /tmp/tlt-mid-candidate-expansion.log
```
