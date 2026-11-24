# 다섯 에픽 6장 동선 지물 검증

2026-11-24 Toronto · TLT-061/DW-06 · TLT-065/GW-06 · TLT-062/FV-06 · TLT-063/EC-06 · TLT-064/HG-06 · G5 진행 중

[공식 RPG 레퍼런스와 제작표](../../research/2026-11-24-epic-sixth-chapter-route-fixtures.md) · [0.115.78 기준 빌드](../world-and-character-color-20261124/build.json) · [0.115.79 후보 빌드](build.json)

## Studio 결과

[접근·귀환 비교판](comparison.jpg) · [배치·보행·캠페인 측정](studio-results.json)

- 고정 카메라 10쌍에서 Deepwood의 낮은 배수 턱은 접근에서도 보이며, 뿌리와 실트는 귀환 사선에서 갈린다. Gloamwood의 말뚝과 셰일 받침은 두 시점에서 보인다. 야간 귀환 화면에서는 삼베 줄이 어두워 말뚝보다 읽기 어렵다.
- Frozen Vale의 석조 방풍턱과 눈의 경계는 접근에서도 드러나고 노출 얼음과 앵커는 귀환 사선에서 읽힌다. Ember Caldera의 레일과 디딤턱은 귀환에서 분리된다. Haunted Graveyard의 벽감은 접근에서 배경에 묻히며, 귀환에서는 인방과 밝은 기록 받침이 드러난다.
- 신규 조립체 5개에 고정·비충돌·비터치·비쿼리 부품 46개를 배치했다. 기존 지물 35개의 측정값이 일치했다. 신규 지물의 바닥 25점 최대 높이 오차는 0스터드이며 동선과의 최소 이격은 Gloamwood의 3.89스터드다.
- R15가 두 빌드 모두 다섯 구간을 왕복했다. 후보의 최대 수평 도착 오차는 1.99스터드이며 허용치는 2.50스터드다.
- 캠페인 회귀는 두 빌드에서 각각 9,310건을 통과했다. 사건 82곳, 단계 246개, 바닥과 동선 3,981표본에서 차단은 0건이다. 전체 캠페인 부품은 57,038→57,084개다.
- Lua 회귀에서 에픽 지도 105,907건, 이야기 소품 4,264건, 난이도 진행 4,269건, 캠페인 전투 동선 77,381건이 통과했다.

## 남은 수용

환경 아트와 QA가 실제 입력으로 Gloamwood 야간의 유도줄과 Haunted Graveyard의 첫 접근에서 기록 벽감이 읽히는 거리를 확인한다. 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 카메라, 사용자 미술 수용은 미검증이다.

## 재현

Place 두 개의 SHA-256과 내장 지물 모듈 소스를 빌드 기록과 해당 Git 커밋에 각각 대조했다. 점프를 끈 R15를 사용해 각 지점의 마지막 32스터드를 접근하고 돌아왔다. Studio 카메라 두 시점은 양쪽 빌드에서 동일한 좌표와 지역 조명을 사용하며 HUD와 프롬프트는 숨긴다. 캠페인 감사 스크립트는 빌드마다 해당 커밋의 소스로 준비한다.

```sh
evidence=docs/evidence/epic-sixth-chapter-route-fixtures-20261124
work=$(mktemp -d)
cat "$evidence/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    docs/evidence/epic-sixth-chapter-landmarks-20261120/walk-approaches.luau > "$work/audit.luau"
for version in 0.115.78 0.115.79; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/$version-expansion.luau" > "$work/$version-expansion.log" 2>&1
done
python3 "$evidence/compare.py" \
    "$work/0.115.78-audit.log" "$work/0.115.79-audit.log" \
    "$work/0.115.78-expansion.log" "$work/0.115.79-expansion.log"
```

`$work/0.115.78-expansion.luau`와 `$work/0.115.79-expansion.luau`는 각각 고정 커밋에서 `python3 tools/prepare-campaign-expansion-native.py`를 실행한 뒤 `/tmp/tlt-campaign-expansion-native.luau`를 복사한다.
