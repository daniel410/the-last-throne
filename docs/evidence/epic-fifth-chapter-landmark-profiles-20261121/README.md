# 다섯 에픽 5장 지물의 접합과 사용 흔적

2026-11-21 UTC · TLT-061/DW-05 · TLT-065/GW-05 · TLT-062/FV-05 · TLT-063/EC-05 · TLT-064/HG-05 · G5 진행 중

[공식 RPG 사례와 장별 제작표](../../research/2026-11-21-epic-fifth-chapter-landmark-profiles.md) · [0.115.29 기준 빌드](../campaign-story-variety-20261121/build.json) · [0.115.30 후보 빌드](build.json)

## 실제 맵에 반영한 변경

| 장 | 배치 변화 |
| --- | --- |
| Deepwood | 파손된 병영 화물로의 롤러에 목재 끝결과 차축 와셔를 배치했다. |
| Gloamwood | 정찰대 석축의 끝에 밝은 석회석 파단면과 어두운 셰일 유수면을 배치했다. |
| Frozen Vale | 노출 차륜에 목재 허브와 철제 마개를 더하고 그 밑에 눌린 눈을 모았다. |
| Ember Caldera | 포집조 넘침구를 현무암으로 바꾸고 양쪽 내화벽돌과 광물 침전으로 배수 방향을 드러냈다. |
| Haunted Graveyard | 동쪽 회랑 도관의 양단에 고정띠를 더하고 석조 받침의 연결부에 금속 이음매를 드러냈다. |

## Studio와 정적 검증

- [전후 화면 10쌍](comparison.jpg)에서 Frozen Vale 차륜의 중심부가 접근에서 더 뚜렷하다. Gloamwood의 밝은 석축 끝층은 보이지만 야간 귀환에서는 하층 대비가 낮다. Deepwood 와셔와 Ember Caldera의 넘침구는 가까운 쪽에서 작은 변화로 읽힌다. Haunted Graveyard의 도관 끝은 근경에서 바뀐 윤곽이 보이고, 야간 원경의 이음매는 여전히 어둡다.
- [Studio 측정](studio-results.json)에서 조립체 5개의 부품이 57개에서 73개로 늘었다. 조사 앵커·피벗·3축 외곽과 주변 지물 30개가 일치했다. 바닥 25점의 오차는 0스터드이며 보행선과 지물의 최소 이격은 4.25스터드다. EC 표시 단계별 인물 위치와의 최소 이격은 6.82스터드다. 기준·후보에서 R15가 5구간씩 점프 없이 왕복했다.
- Studio 캠페인 회귀는 빌드별 9,310건으로 사건 82개와 단계 246개를 검사했다. 바닥·동선 3,981개 표본에서 차단은 0건이다. 후보의 첫 회귀 중 병행 Studio 도구 출력이 섞여 동일한 고정 빌드에서 독립 실행했다. Luau 변경 파일 구문 검사와 Lua 지도 105,907건, 이야기 소품 4,264건, 확장 사건 4,048건, 전투 경로 77,381건을 통과했다. 기존 `campaign-expansion.spec.lua`의 첫 본편 Gold 단언과 `difficulty-level-free.spec.lua`의 진행 계약 오류는 기준과 후보 소스에서 같은 위치에 재현됐다.

다음 담당은 환경 아트와 QA다. 실제 입력으로 FV의 차륜 최초 발견과 HG 귀환 때의 도관 판독을 확인한다. 게시 클라이언트, 실기기, 전투 카메라, 멀티플레이 스트리밍, 사용자 수용은 미검증이다.

## 재현

두 고정 소스 빌드를 로컬 Roblox Studio에서 순서대로 실행한다. 동일한 지역 조명과 접근·귀환 카메라를 사용한다. 점프를 끈 R15는 조사 지점 앞의 마지막 32스터드를 왕복한다.

```sh
original=docs/evidence/epic-fifth-chapter-landmarks-20261120
evidence=docs/evidence/epic-fifth-chapter-landmark-profiles-20261121
work=$(mktemp -d)
cat "$original/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$original/walk-approaches.luau" > "$work/audit.luau"
python3 tools/prepare-campaign-expansion-native.py
cp /tmp/tlt-campaign-expansion-native.luau "$work/expansion.luau"
for version in 0.115.29 0.115.30; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/expansion.luau" > "$work/$version-expansion.log" 2>&1
done
python3 "$evidence/compare.py" \
    "$work/0.115.29-audit.log" "$work/0.115.30-audit.log" \
    "$work/0.115.29-expansion.log" "$work/0.115.30-expansion.log"
```
