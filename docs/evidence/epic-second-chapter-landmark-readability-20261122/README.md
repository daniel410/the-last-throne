# 다섯 에픽 2장 지물의 접근·귀환 가독성

2026-11-22 UTC · TLT-061/DW-02 · TLT-065/GW-02 · TLT-062/FV-02 · TLT-063/EC-02 · TLT-064/HG-02 · G5 진행 중

[공식 RPG 사례와 에픽별 제작표](../../research/2026-11-22-epic-second-chapter-landmark-readability.md) · [0.115.39 기준 빌드](../elf-late-shot-motion-20261121/build.json) · [0.115.40 후보 빌드](build.json)

| 에픽 | 배치된 조형 변경 |
| --- | --- |
| Deepwood | 구조 굽이의 배수 돌섶 상단을 0.17스터드 높이고 물에 깎인 석재 단면을 밝혔다. |
| Gloamwood | 거미줄 바깥 관측점의 셰일 파단층을 두껍게 하고 청회색 단면을 노출했다. |
| Frozen Vale | 쌍봉화 전망대의 깨진 끝돌을 높여 설선 아래 석축의 끝을 드러냈다. |
| Ember Caldera | 갇힌 작업반 쪽으로 이어지는 레일 절단면의 머리와 목을 재조형했다. |
| Haunted Graveyard | 피난처 귀환 벽감의 상인방에 경사를 주고 문설주 상부에 밝은 석회암 면을 적용했다. |

## 화면과 검증

- 같은 카메라 10쌍에서 HG 벽감의 상부가 배경과 분리된다. 사선에서 녹색 표식이 하단 일부를 계속 가린다. DW 돌섶 상단의 윤곽이 조금 넓어졌고, FV와 EC의 단면 변화는 멀리서 작다. GW 셰일은 여전히 어두워 최초 발견이 쉬워졌는지는 확인이 필요하다. [Studio 전후 비교](comparison.jpg)
- 다섯 지물 73부품과 다른 지물 30개를 대조했다. 조사 앵커, 피벗, 수평 외곽 및 보행선 최소 이격 4.70스터드가 일치했다. 지물 아래 바닥 25점의 높이 오차는 0이다. 기준·후보 각각 다섯 R15 왕복과 캠페인 회귀 9,310건을 통과했고, 동선 표본 3,981개에서 차단은 0건이다. [Studio 측정](studio-results.json)
- Lua 에픽 지도 105,907건, 이야기 소품 4,264건, 난이도 진행 4,269건, 전투 경로 77,381건과 변경 모듈 구문 검사를 통과했다. 고정 빌드는 Rojo 7.7.1을 사용했다. 첫 기준 촬영은 디스크 여유 부족으로 중단돼 여유 공간 복구 후 같은 빌드에서 다시 실행했다.

다음 확인은 환경 아트·QA가 맡는다. 실제 조작에서 GW 접근 중 셰일이 처음 보이는 거리와 HG 귀환에서 표식과 벽감이 분리되는 각도를 확인한다. 게시 클라이언트, 실기기, 전투 카메라, 멀티플레이 스트리밍과 사용자 미술 수용은 미검증이다.

## 재현

고정 빌드를 Studio에서 차례로 열고 지역 조명, 카메라와 R15 이동 조건을 일치시킨다. 스크린샷은 HUD와 프롬프트를 끈 Studio 장면이다. R15 보행은 점프를 끈 스크립트 입력으로 검증한다.

```sh
original=docs/evidence/epic-second-chapter-landmarks-20261120
comparison=docs/evidence/epic-second-chapter-route-profiles-20261121
evidence=docs/evidence/epic-second-chapter-landmark-readability-20261122
work=$(mktemp -d)
cat "$original/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$original/walk-approaches.luau" > "$work/audit.luau"
python3 tools/prepare-campaign-expansion-native.py
cp /tmp/tlt-campaign-expansion-native.luau "$work/expansion.luau"
for version in 0.115.39 0.115.40; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/expansion.luau" > "$work/$version-expansion.log" 2>&1
done
python3 "$comparison/compare.py" \
    "$work/0.115.39-audit.log" "$work/0.115.40-audit.log" \
    "$work/0.115.39-expansion.log" "$work/0.115.40-expansion.log" \
    --baseline-version 0.115.39 --height-rise StragglerBendDrainageShoulder 0.17 \
    --output-dir "$evidence"
```
