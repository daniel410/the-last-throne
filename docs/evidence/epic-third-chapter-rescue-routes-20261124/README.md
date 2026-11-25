# 다섯 에픽 3장 구조·정찰 동선 검증

2026-11-24 Toronto · TLT-061/DW-03 · TLT-065/GW-03 · TLT-062/FV-03 · TLT-063/EC-03 · TLT-064/HG-03 · G5 진행 중

[제작표와 RPG 사례](../../research/2026-11-24-epic-third-chapter-rescue-routes.md) · [기준 0.115.102](../hero-mobile-releases-20261124/build.json) · [후보 0.115.103](build.json) · [배치 계산 결과](static-results.txt) · [동일 카메라 비교](comparison.jpg) · [Studio 측정](studio-results.json)

## 빌드와 정적 검증

- 커밋을 고정해 후보 Place를 빌드했다. 기준과 후보 파일의 SHA-256을 각각의 빌드 기록과 대조했다.
- 지도 105,907건, 전투 동선 77,381건, 사건 검토 4,048건을 통과했다.
- 실제 조형 함수로 고정 장식 44부품을 계산했다. 모든 부품의 크기가 양수이며, 새 조립체가 기존 대표 지물과 별개 사건의 2단계에 속한다. 사건의 입구부터 마지막 지점까지 직선 구간과 새 지물의 보수적 수평 외곽 사이의 최소 이격은 10.26스터드였다. 지물 주변 바닥 표본 405곳의 높이가 각 지물 피벗의 바닥 높이와 일치했다. Lua 계산에는 Studio 실제 바닥이나 다른 조형과의 물리적 겹침이 포함되지 않는다.

## Studio와 수용

11월 25일에 고정 Place 두 개를 기본 실행기에서 순차 실행해 전날의 Studio 준비 시간 초과 이후 검증을 재개했다. 양쪽 Place SHA-256이 빌드 기록과 일치했고, 기존 Studio 세션은 유지했다.

- 새 조립체 5개는 고정 비충돌 장식 44부품으로 구성되며 각 외곽 중심과 모서리 25점의 바닥 오차는 0스터드였다. 목표 경로와 외곽의 최소 수평 이격은 10.69스터드였다. 기존 지물 55개의 조사점, 피벗, 부품 수와 외곽 치수가 일치했다. 새 조립체에서 충돌 가능한 주변 지물과 기존 퀘스트 랜드마크에 대한 외곽 검사도 각각 통과했다.
- 점프를 끈 R15가 양쪽에서 다섯 조사점 앞 16스터드를 왕복했다. 후보의 최대 수평 도착 오차는 2.26스터드였다.
- 캠페인 회귀는 양쪽에서 9,310건씩 통과했다. 사건 82개와 단계 246개를 전개했으며 바닥·보행 표본 3,981개에서 차단은 0건이었다. 전체 부품 순증 44개는 새 조립체의 부품 수와 일치했다.
- 지역 조명을 적용한 접근·귀환 카메라 10쌍에서 Deepwood의 열린 관측 홈, Frozen Vale의 보급길 표지, Ember Caldera의 내화벽돌 위 난간, Haunted Graveyard의 밝은 석재 난간을 확인했다. Gloamwood는 접근에서 기존 지도 차양 옆으로 선반 끝이 보이고, 귀환 방향에서는 차양 기둥이 선반 일부를 가렸다. 화면 캡처에서는 상호작용 UI를 숨겼다.

환경 아트와 QA는 Gloamwood에서 실제 입력으로 선반의 첫 발견 지점을 확인한다. 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 카메라, 사용자 미술 수용은 미검증이다.

## 재현

저장소 루트에서 정적 검사를 실행한다. 기준과 후보 Place는 각 빌드 기록의 고정 소스로 준비한다. 각 버전의 고정 소스에서 `python3 tools/prepare-campaign-expansion-native.py`를 실행하고 출력 파일을 버전별 `*-expansion.luau`로 작업 폴더에 복사한다.

```sh
evidence=docs/evidence/epic-third-chapter-rescue-routes-20261124
lua "$evidence/check-geometry.lua"
for suite in epic-map-navigation campaign-combat-routes campaign-expansion-review; do
    lua "tests/$suite.spec.lua"
done

work=$(mktemp -d)
cat "$evidence/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    docs/evidence/epic-second-chapter-landmarks-20261120/walk-approaches.luau > "$work/audit.luau"
sed 's/FOURTH_CHAPTER_LANDMARK_OVERLAP_CLEAR/THIRD_CHAPTER_LANDMARK_OVERLAP_CLEAR/' \
    docs/evidence/epic-fourth-chapter-maintenance-routes-20261125/check-landmark-overlap.luau >> "$work/audit.luau"
# Copy the version-specific expansion scripts to "$work" before continuing.
for version in 0.115.102 0.115.103; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/$version-expansion.luau" > "$work/$version-expansion.log" 2>&1
done
python3 "$evidence/compare.py" "$work/0.115.102-audit.log" "$work/0.115.103-audit.log" \
    "$work/0.115.102-expansion.log" "$work/0.115.103-expansion.log"
```
