# 다섯 에픽 4장 복구 설비의 조형과 검증

2026-11-25 Toronto · TLT-061/DW-04 · TLT-065/GW-04 · TLT-062/FV-04 · TLT-063/EC-04 · TLT-064/HG-04 · G5 진행 중

[조사와 에픽별 제작표](../../research/2026-11-25-epic-fourth-chapter-maintenance-profiles.md) · [기준 0.115.108](../hero-directional-releases-20261125/build.json) · [후보 0.115.109](build.json)

4장 복구 지물에서 Deepwood의 로프 처짐, Gloamwood의 밝은 목판, Frozen Vale의 중계판 받침, Ember Caldera의 열린 이음관, Haunted Graveyard의 선반 접합부를 조형했다. 기준은 직전 누적 빌드 0.115.108이며 이 빌드의 4장 설비 소스는 최초 배치 후보 0.115.106과 동일하다.

## 빌드와 정적 검증

- 양쪽 Place의 SHA-256이 빌드 기록과 일치했다. 각 빌드에 들어간 4장 설비 모듈의 바이트를 해당 소스 커밋과 대조했다. 단일 Place의 역할·입장 구성 검사 336건을 통과했다.
- 다섯 지물은 Roblox 네이티브 부품 59개로 구성된다. 부품 21개가 늘었고, 보수적 수평 외곽과 사건 경로 사이의 최소 이격은 10.26스터드였다. 지물 기단 주변의 바닥 405표본이 피벗의 바닥 높이와 일치했다.
- 지도 105,907건, 전투 동선 77,381건, 사건 확장 4,048건을 통과했다.

## Studio와 수용

- 접근·귀환 고정 카메라 10쌍에서 Ember Caldera의 열린 단면과 Haunted Graveyard의 선반 아래 받침이 확인된다. Gloamwood는 목판의 외곽이 커졌지만 야간의 바닥·목재 대비는 여전히 낮다. Deepwood 로프의 곡률과 Frozen Vale 받침의 결은 이 거리에서 구분하기 어렵다. 화면 캡처에서는 상호작용 UI를 숨겼다. [동일 카메라 비교](comparison.jpg)
- 기준과 후보에서 다섯 지물의 조사점·피벗이 일치했다. 두 빌드에서 다른 지물 60개의 측정값이 일치했고, 검사한 다섯 지물 모두 기존 퀘스트 랜드마크와 외곽 겹침이 없었다. 후보의 실제 지물 외곽과 목표 경로 사이 최소 이격은 10.58스터드, 바닥 25점의 높이 오차는 0이었다. 점프를 끈 R15가 양쪽에서 다섯 조사점 앞 16스터드를 왕복했고 후보 최대 도착 오차는 2.29스터드였다.
- 캠페인 회귀는 두 빌드에서 각각 9,310건을 통과했다. 사건 82개, 단계 246개, 바닥·보행 표본 3,981개를 검사했고 차단은 두 빌드 모두 0건이었다. [Studio 측정](studio-results.json)

후보는 미게시다. 다음 담당인 환경 아트와 QA는 Gloamwood의 야간 최초 발견, 3장 차양에 가려지는 귀환 측 선반, 접근 시 지물과 배경의 분리를 실제 입력에서 확인한다. 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 카메라, 사용자 미술 수용은 미검증이다.

## 재현

```sh
old=docs/evidence/epic-fourth-chapter-maintenance-routes-20261125
evidence=docs/evidence/epic-fourth-chapter-maintenance-profiles-20261125
work=$(mktemp -d)
lua "$old/check-geometry.lua"
for suite in epic-map-navigation campaign-combat-routes campaign-expansion-review; do
    lua "tests/$suite.spec.lua"
done
python3 tests/single-build.spec.py --artifact builds/0.115.109/TheLastThrone-0.115.109.rbxlx
python3 "$old/prepare-studio.py" "$work/audit.luau"
# Prepare the expansion audit from the frozen candidate source.
python3 tools/prepare-campaign-expansion-native.py
cp /tmp/tlt-campaign-expansion-native.luau "$work/regression.luau"
for version in 0.115.108 0.115.109; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/regression.luau" > "$work/$version-regression.log" 2>&1
done
python3 "$evidence/compare-studio.py" "$work"
```
