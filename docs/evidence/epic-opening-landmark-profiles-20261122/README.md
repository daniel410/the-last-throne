# 다섯 에픽 첫 사건의 지면과 작업 지물

2026-11-22 UTC · TLT-061/DW-01 · TLT-065/GW-01 · TLT-062/FV-01 · TLT-063/EC-01 · TLT-064/HG-01 · G5 진행 중

[공식 자료와 제작표](../../research/2026-11-22-epic-opening-landmark-profiles.md) · [0.115.43 기준 빌드](../hero-contact-weight-20261121/build.json) · [0.115.44 후보 빌드](build.json)

| 에픽 | 변경 |
| --- | --- |
| Deepwood | 물가 돌섶의 적재목 받침을 드러내고 돌 사이에 퇴적면을 조형했다. |
| Gloamwood | 바퀴 자국이 갈라지는 자리의 셰일 파단면과 뿌리 심재를 조형했다. |
| Frozen Vale | 오름길 압설 아래 암석과 푸른 얼음층을 드러냈다. |
| Ember Caldera | 운반대 차륜 고임쇠의 금속 받침과 뒤턱을 조형했다. |
| Haunted Graveyard | 피난로 길돌의 접근면과 갈라진 기단 상부를 다듬었다. |

## 화면과 검증

- 같은 지역 조명과 카메라로 10쌍을 비교했다. FV는 압설 옆 암빙의 경계가 더 분명하고 GW는 셰일 파단면이 측면에서 읽힌다. HG 기단의 야간 원경 대비는 낮다. [Studio 비교판](comparison.jpg)
- 다섯 모델은 부품 41→55개다. 나머지 지물 30개, 모델 수평 외곽, 조사 위치와 지면 기준점이 일치했고, 바닥 높이 오차는 25점에서 0이다. 두 빌드에서 각각 R15 다섯 구간 왕복을 통과했다.
- 두 빌드의 캠페인 회귀는 각각 9,310건을 통과했고 보행선 3,981표본 모두 차단 0건이었다. [Studio 측정](studio-results.json)

환경 아트·QA는 실제 조작에서 GW 갈림길 최초 발견과 HG 야간 경로 판독을 확인한다. 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 전투 카메라와 사용자 미술 수용은 미검증이다.

## 재현

고정 빌드 두 개를 Rojo 7.7.1로 준비한다. Studio를 순차 실행해 지역 조명과 카메라를 맞춘다. 캡처 중 HUD와 조사 프롬프트를 숨겼으며, R15 왕복은 점프를 끈 스크립트 입력이다.

```sh
evidence=docs/evidence/epic-opening-landmark-profiles-20261122
work=$(mktemp -d)
cat "$evidence/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    docs/evidence/epic-second-chapter-landmarks-20261120/walk-approaches.luau > "$work/audit.luau"
GIT_LFS_SKIP_SMUDGE=1 git worktree add --detach "$work/baseline" c3974c3f
GIT_LFS_SKIP_SMUDGE=1 git worktree add --detach "$work/candidate" ec4b73fd
rojo build "$work/baseline/default.project.json" -o "$work/0.115.43.rbxlx"
rojo build "$work/candidate/default.project.json" -o "$work/0.115.44.rbxlx"
(cd "$work/baseline" && python3 tools/prepare-campaign-expansion-native.py)
cp /tmp/tlt-campaign-expansion-native.luau "$work/0.115.43-expansion.luau"
(cd "$work/candidate" && python3 tools/prepare-campaign-expansion-native.py)
cp /tmp/tlt-campaign-expansion-native.luau "$work/0.115.44-expansion.luau"
for version in 0.115.43 0.115.44; do
    place="$work/$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/$version-expansion.luau" > "$work/$version-expansion.log" 2>&1
done
python3 "$evidence/compare.py" \
    "$work/0.115.43-audit.log" "$work/0.115.44-audit.log" \
    "$work/0.115.43-expansion.log" "$work/0.115.44-expansion.log"
```
