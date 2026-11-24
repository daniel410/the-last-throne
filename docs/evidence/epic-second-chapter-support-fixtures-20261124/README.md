# 다섯 에픽 2장 구조·정비 지물의 Studio 검증

2026-11-24 Toronto · TLT-061/DW-02 · TLT-065/GW-02 · TLT-062/FV-02 · TLT-063/EC-02 · TLT-064/HG-02 · G5 진행 중

[공식 RPG 사례와 장면별 제작표](../../research/2026-11-24-epic-second-chapter-support-fixtures.md) · [기준 0.115.94](../hero-crossed-releases-20261124/build.json) · [후보 0.115.95](build.json) · [Studio 비교판](comparison.jpg) · [측정 결과](studio-results.json)

기존 2장 대표 지물과 다른 사건 위치에 건설·구조·정비용 지물을 조형했다. 로컬 Place 두 파일의 SHA-256은 각 빌드 기록과 일치한다. Lua 에픽 내비게이션 105,907건, 전투 동선 77,381건, 사건 검토 4,048건을 통과했다.

| 에픽 | 조형 | 보행선 최소 이격 |
| --- | --- | --- |
| Deepwood | 차양 지주와 빗물 받침 | 8.73스터드 |
| Gloamwood | 노출 뿌리, 셰일 턱과 등불 받침 | 8.78스터드 |
| Frozen Vale | 빙설 문턱과 목재 팔레트 | 8.69스터드 |
| Ember Caldera | 현무암 도면 작업대 | 8.74스터드 |
| Haunted Graveyard | 윈치용 고정구, 쐐기와 석재 기단 | 8.76스터드 |

## 결과

- 새 조립체 다섯 개는 고정·비충돌·비터치·비쿼리인 부품 43개로 구성했다. 각 지물의 중심과 모서리 25점에서 바닥 높이 오차는 0스터드였다. 기존 지물 45개의 외곽 크기, 지물 원점과 조사점 측정은 일치했다.
- 동일 카메라 10쌍에서 Deepwood 지주와 Frozen Vale 목재 팔레트의 윤곽이 두 방향에서 구별됐다. Ember Caldera의 작업대 상판과 받침 사이 열린 면은 귀환 사선에서 더 선명했다. Gloamwood의 등불 받침과 Haunted Graveyard의 고정구는 야간 조명에서 명암 대비가 낮았다.
- 점프를 끈 R15가 기준과 후보의 다섯 접근 구간을 각각 왕복했다. 후보의 최대 수평 도착 오차는 2.22스터드였다. 양쪽 Studio 캠페인 검사는 각각 9,310건을 통과했다. 사건 82개와 단계 246개에서 바닥·동선 표본 3,981개를 검사했고 차단은 0건이었다.
- 첫 카메라 실행에서는 다른 Studio 세션에서 로컬 Place 확인이 실패해 재실행했다. Gloamwood 카메라와 보행 검증에 지정한 단계를 1에서 실제 등불 회수 단계인 2로 고쳐 같은 소스의 두 빌드를 다시 실행했다.

## 남은 수용

환경 아트와 QA가 실제 입력에서 Gloamwood와 Haunted Graveyard 지물의 최초 발견 거리와 야간 대비를 확인한다. 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 카메라와 사용자 미술 수용은 미검증이다.

## 재현

기준과 후보의 고정 소스에서 Place를 준비하고 SHA-256을 확인한다. 각 고정 소스에서 `python3 tools/prepare-campaign-expansion-native.py`를 실행하고 출력된 파일을 아래 작업 폴더에 `0.115.94-expansion.luau`, `0.115.95-expansion.luau`로 각각 복사한다. 카메라 검증에서는 지역 조명을 적용하고 HUD와 프롬프트를 숨긴다. 점프를 끈 R15가 조사 지점 직전 16스터드를 왕복한다.

```sh
evidence=docs/evidence/epic-second-chapter-support-fixtures-20261124
work=$(mktemp -d)
cat "$evidence/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    docs/evidence/epic-second-chapter-landmarks-20261120/walk-approaches.luau > "$work/audit.luau"
for version in 0.115.94 0.115.95; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/$version-expansion.luau" > "$work/$version-expansion.log" 2>&1
done
python3 "$evidence/compare.py" "$work/0.115.94-audit.log" "$work/0.115.95-audit.log" \
    "$work/0.115.94-expansion.log" "$work/0.115.95-expansion.log"
```
