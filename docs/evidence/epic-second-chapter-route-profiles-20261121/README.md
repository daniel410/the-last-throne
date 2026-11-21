# 다섯 에픽 2장 길목의 지형과 접합

2026-11-21 UTC · TLT-061/DW-02 · TLT-065/GW-02 · TLT-062/FV-02 · TLT-063/EC-02 · TLT-064/HG-02 · G5 진행 중

[공식 RPG 사례와 제작표](../../research/2026-11-21-epic-second-chapter-route-profiles.md) · [0.115.33 기준 빌드](../hero-ultimate-finish-20261121/build.json) · [0.115.34 후보 빌드](build.json)

| 에픽 | 맵에 반영한 지형과 지물 |
| --- | --- |
| Deepwood | 낙오자 구조 길목의 돌섶 윗면을 밝히고 물길을 따라 퇴적층 두 줄을 배치했다. |
| Gloamwood | 구조 관측점 양쪽에 갈라진 셰일층을 놓고 뿌리 갈래의 심재를 드러냈다. |
| Frozen Vale | 봉화 전망대 석축을 기단과 윗단으로 나누고 덮개 위에 바람에 밀린 눈층을 얹었다. |
| Ember Caldera | 갇힌 작업반으로 이어지는 화물선을 분리된 I자 단면과 마모된 철제 주행면으로 만들었다. |
| Haunted Graveyard | 피난처 귀환 길목에서 벽감 돌기둥의 이음과 문지방의 물끊기를 드러냈다. |

## 화면과 검증

- 동일 카메라 전후 10쌍에서 DW 배수 퇴적층이 사선에서 가는 선으로 보이고, FV 석축은 접근 시 눈과 돌의 단차가 조금 더 읽힌다. EC 주행면과 HG 문지방은 접근에서 드러난다. GW 셰일과 HG 사선의 벽감은 야간에 어둡고, HG 기존 표식과의 겹침이 남는다. [Studio 전후 10쌍](comparison.jpg)
- 대상 다섯 지물은 51→73부품이다. 기존 지물 30개와 다섯 조사 앵커·피벗·수평 외곽이 일치했다. 바닥 25점 오차는 0이며 보행선 최소 이격은 4.70스터드다. 기준·후보 각각 R15 접근·귀환 5개와 캠페인 회귀 9,310건을 통과했다. 두 빌드의 바닥·동선 표본 3,981개에서 차단은 0건이다. [Studio 측정](studio-results.json)
- Lua 에픽 지도 105,907건, 이야기 소품 4,264건, 난이도 진행 4,269건, 전투 경로 77,381건과 변경 모듈 Luau 컴파일을 통과했다. 고정 빌드에 Rojo 7.7.1을 사용했다.

환경 아트와 QA의 다음 확인 범위는 실제 조작에서 GW 야간 셰일의 최초 발견과 HG 사선의 표식·벽감 구분이다. 게시 클라이언트, 실기기, 전투 카메라, 멀티플레이 스트리밍과 사용자 미술 수용은 미검증이다.

## 재현

로컬 Studio에서 빌드별로 순서대로 실행한다. 같은 지역 조명과 카메라로 접근·사선을 찍는다. 점프를 끈 R15는 조사 지점 약 32스터드 전에서 출발해 지점 근처까지 이동한 뒤 출발점으로 돌아온다.

```sh
original=docs/evidence/epic-second-chapter-landmarks-20261120
evidence=docs/evidence/epic-second-chapter-route-profiles-20261121
work=$(mktemp -d)
cat "$original/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$original/walk-approaches.luau" > "$work/audit.luau"
python3 tools/prepare-campaign-expansion-native.py
cp /tmp/tlt-campaign-expansion-native.luau "$work/expansion.luau"
for version in 0.115.33 0.115.34; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/expansion.luau" > "$work/$version-expansion.log" 2>&1
done
python3 "$evidence/compare.py" \
    "$work/0.115.33-audit.log" "$work/0.115.34-audit.log" \
    "$work/0.115.33-expansion.log" "$work/0.115.34-expansion.log"
```
