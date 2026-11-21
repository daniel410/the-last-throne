# 다섯 에픽 4장 복구 지물의 접근 가독성

2026-11-21 UTC · TLT-061/DW-04 · TLT-065/GW-04 · TLT-062/FV-04 · TLT-063/EC-04 · TLT-064/HG-04 · G5 진행 중

[공식 RPG 비교와 환경 제작표](../../research/2026-11-21-epic-fourth-chapter-readability.md) · [0.115.27 기준 빌드](../hero-force-feedback-20261121/build.json) · [0.115.28 후보 빌드](build.json)

| 에픽 | 실제 맵 배치 |
| --- | --- |
| Deepwood | 망루 케이블 끝에 마모된 돌 받침과 리벳 두 개로 고정한 철판을 배치했다. |
| Gloamwood | 뿌리가 들어 올린 지면에 밝은 셰일 두 층을 드러냈다. 부러진 등불 소켓을 길 쪽으로 옮기고 나무 끝결을 키웠다. |
| Frozen Vale | 석축 위로 중계축을 올리고 접근 쪽에 단면과 고정 고리를 드러냈다. |
| Ember Caldera | 냉각관 양쪽의 중심을 다르게 두고, 끊긴 틈의 내화벽돌 조각과 광물 침전으로 파손 단면을 연결했다. |
| Haunted Graveyard | 집결로 석축 덮개를 보강하고 도착 쪽 끝 높이를 단계적으로 낮췄다. |

## 화면과 검증

- [Studio 전후 10쌍](comparison.jpg)에서 GW 셰일의 밝은 단면과 부러진 소켓이 접근 방향에서 조금 더 분리된다. 야간 전체 화면에서는 소켓의 대비가 여전히 낮다. HG 접근에서는 석축 끝돌의 단차가 보인다. DW 철판의 리벳은 원경에서 작고, FV 중계축과 EC 냉각관의 내부는 가까운 귀환 시점에서 선명하다.
- [Studio 측정](studio-results.json)에서 다섯 지물은 70→81부품이다. 조사 앵커·피벗·수평 외곽과 주변 지물 30개가 일치했다. 바닥 25점 오차는 0이며 보행선 최소 이격은 3.67스터드, HG 집결 인물 최소 이격은 7.76스터드다. 기준·후보 각각 접근·귀환 5개를 통과했다.
- Studio 캠페인 회귀는 두 빌드 각각 9,193건을 통과했다. 사건 82개, 단계 246개와 바닥·동선 3,968개 표본에서 차단 0건이다. 후보 회귀의 첫 실행은 로컬 포트 충돌로 시작되지 않아 같은 빌드로 재실행했다. Lua 에픽 지도 105,907건, 이야기 소품 4,264건, 난이도 진행 4,493건, 전투 경로 77,381건을 통과했다. Rojo 7.7.1로 고정 빌드를 생성했다.

환경 아트와 QA의 다음 확인 범위는 실제 입력에서 GW의 야간 첫 발견, EC 조사 위치에서 냉각관 틈의 가시성, HG 동료 집결 뒤 귀환이다. 게시 클라이언트, 실기기, 전투 카메라, 멀티플레이 스트리밍, 사용자 미술 수용은 미검증이다.

## 재현

아래 검증은 로컬 Roblox Studio에서 빌드별로 순서대로 실행한다. 자동 이동은 점프를 끈 R15가 조사점에 가까이 갔다가 돌아오는 방식이다. 두 빌드에 동일한 지역 조명·카메라·스토리 장면을 적용한다.

```sh
original=docs/evidence/epic-fourth-chapter-landmarks-20261120
evidence=docs/evidence/epic-fourth-chapter-readability-20261121
work=$(mktemp -d)
cat "$original/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$original/walk-approaches.luau" > "$work/audit.luau"
python3 tools/prepare-campaign-expansion-native.py
cp /tmp/tlt-campaign-expansion-native.luau "$work/expansion.luau"
for version in 0.115.27 0.115.28; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/expansion.luau" > "$work/$version-expansion.log" 2>&1
done
python3 docs/evidence/epic-fourth-chapter-repair-20261121/compare.py \
    "$work/0.115.27-audit.log" "$work/0.115.28-audit.log" \
    "$work/0.115.27-expansion.log" "$work/0.115.28-expansion.log" \
    --baseline-version 0.115.27 --output-dir "$evidence"
```
