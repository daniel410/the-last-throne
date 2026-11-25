# 다섯 에픽 3장 구조·정찰 동선 검증

2026-11-24 Toronto · TLT-061/DW-03 · TLT-065/GW-03 · TLT-062/FV-03 · TLT-063/EC-03 · TLT-064/HG-03 · G5 진행 중

[제작표와 RPG 사례](../../research/2026-11-24-epic-third-chapter-rescue-routes.md) · [기준 0.115.102](../hero-mobile-releases-20261124/build.json) · [후보 0.115.103](build.json) · [배치 계산 결과](static-results.txt)

## 빌드와 정적 검증

- 커밋을 고정해 후보 Place를 빌드했다. 기준과 후보 파일의 SHA-256을 각각의 빌드 기록과 대조했다.
- 지도 105,907건, 전투 동선 77,381건, 사건 검토 4,048건을 통과했다.
- 실제 조형 함수로 고정 장식 44부품을 계산했다. 모든 부품의 크기가 양수이며, 새 조립체가 기존 대표 지물과 별개 사건의 2단계에 속한다. 사건의 입구부터 마지막 지점까지 직선 구간과 새 지물의 보수적 수평 외곽 사이의 최소 이격은 10.26스터드였다. 지물 주변 바닥 표본 405곳의 높이가 각 지물 피벗의 바닥 높이와 일치했다. Lua 계산에는 Studio 실제 바닥이나 다른 조형과의 물리적 겹침이 포함되지 않는다.

## Studio와 수용

기준 캠페인 회귀, 기준 카메라·보행, 별도 포트의 후보 카메라·보행 실행은 모두 Studio 준비 단계에서 시간 초과했다. 시작 로그는 이미 다른 Studio 프로세스 11개가 열려 있음을 기록했다. 기존 세션은 그대로 두었다. 카메라 비교, R15 자동 왕복, 엔진 내 겹침 및 캠페인 회귀는 미검증이다. 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 카메라, 사용자 미술 수용도 미검증이다.

환경 아트와 QA는 Studio에서 다섯 지점의 같은 카메라 비교와 왕복을 먼저 수행한다. Gloamwood의 목재 절단면과 묘지 난간이 야간 접근에서 읽히는지, Ember Caldera의 난간이 기존 구조 동작을 가리는지 확인한다.

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
# Copy the version-specific expansion scripts to "$work" before continuing.
for version in 0.115.102 0.115.103; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/$version-expansion.luau" > "$work/$version-expansion.log" 2>&1
done
python3 "$evidence/compare.py" "$work/0.115.102-audit.log" "$work/0.115.103-audit.log" \
    "$work/0.115.102-expansion.log" "$work/0.115.103-expansion.log"
```
