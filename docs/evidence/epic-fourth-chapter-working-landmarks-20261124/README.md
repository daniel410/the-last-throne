# 다섯 에픽 4장 복구 지물의 접근면 검증

2026-11-24 토론토 기준 · TLT-061/DW-04 · TLT-065/GW-04 · TLT-062/FV-04 · TLT-063/EC-04 · TLT-064/HG-04 · G5 진행 중

[공식 RPG 레퍼런스와 환경 제작표](../../research/2026-11-24-epic-fourth-chapter-working-landmarks.md) · [후보 고정 빌드](build.json) · [기준 빌드 0.115.72](../hero-release-shapes-20261124/build.json)

## Studio와 정적 검증

- 동일 카메라 10쌍에서 Gloamwood 등불목의 밝은 끝결이 접근과 귀환 양쪽에서 더 또렷했다. 뿌리 몸통은 야간에 여전히 어둡다. Frozen Vale의 중계축 받침과 압설 경계는 귀환 사선에서 읽힌다. Ember Caldera는 접근에서 앞쪽 관의 구멍이 보이고 뒤쪽 단면은 여전히 잔해와 겹친다. Deepwood 케이블 안내구와 Haunted Graveyard 석축 줄눈의 원경 변화는 작다. [전후 비교](comparison.jpg)
- 기준과 후보 각각 다섯 구간에서 점프를 끈 R15가 32스터드를 접근하고 돌아왔다. 후보의 최대 도착 오차는 2.26스터드이며 허용치는 2.50스터드다. [Studio 측정](studio-results.json)
- 다섯 조립체는 91→98부품이다. 조사점, 피벗, 수평 외곽, 주변 지물 30개의 측정값이 일치했다. 수직 외곽은 Gloamwood 등불 파단면에서 약 0.049스터드, Ember Caldera 냉각관에서 약 0.002스터드 낮아졌다. 바닥 표본 25곳의 높이 오차는 0스터드다. 보행선 최소 이격은 3.67스터드, Haunted Graveyard 집결 인물과의 최소 이격은 7.76스터드다. 다섯 조립체의 모든 부품은 고정·비충돌·비터치·비쿼리다. [Studio 측정](studio-results.json)
- 두 Place에서 캠페인 회귀가 각각 9,310건을 통과했다. 82개 사건, 246개 단계와 바닥·동선 표본 3,981개에서 차단은 0건이다. 캠페인 부품은 56,656→56,663개다. [Studio 측정](studio-results.json)
- 두 Place의 SHA-256과 내장 4장 Luau 모듈을 기록된 소스 커밋과 대조했다. 변경 모듈 구문 검사와 Lua 에픽 지도 105,907건, 이야기 소품 4,264건, 난이도 진행 4,269건, 전투 경로 77,381건을 통과했다. [빌드와 소스 해시](build.json)

## 남은 수용

환경 아트와 QA가 실제 입력에서 Gloamwood 야간 첫 발견, Ember Caldera 조사 지점에서의 파손 단면, Haunted Graveyard 동료 집결 뒤 귀환 시야를 확인한다. 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 카메라, 사용자 미술 수용은 미검증이다.

## 재현

기존 4장 검증과 같은 위치에서 두 Place를 비교한다. 지역별 조명과 카메라를 고정하고 HUD와 프롬프트를 숨긴다. R15 자동 보행은 점프를 끈 상태로 마지막 32스터드를 왕복한다. 한 Studio 실행을 마친 뒤 다음 실행을 시작한다.

```sh
original=docs/evidence/epic-fourth-chapter-landmarks-20261120
evidence=docs/evidence/epic-fourth-chapter-working-landmarks-20261124
work=$(mktemp -d)
cat "$original/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$original/walk-approaches.luau" > "$work/audit.luau"
python3 tools/prepare-campaign-expansion-native.py
cp /tmp/tlt-campaign-expansion-native.luau "$work/expansion.luau"
for version in 0.115.72 0.115.73; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/expansion.luau" > "$work/$version-expansion.log" 2>&1
done
python3 docs/evidence/epic-fourth-chapter-repair-20261121/compare.py \
    "$work/0.115.72-audit.log" "$work/0.115.73-audit.log" \
    "$work/0.115.72-expansion.log" "$work/0.115.73-expansion.log" \
    --baseline-version 0.115.72 --expected-regression 82 246 3981 9310 --output-dir "$evidence"
```
