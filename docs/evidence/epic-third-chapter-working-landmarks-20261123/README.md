# 다섯 에픽 3장 구조·정비 지물 검증

2026-11-23 토론토 기준 · TLT-061/DW-03 · TLT-065/GW-03 · TLT-062/FV-03 · TLT-063/EC-03 · TLT-064/HG-03 · G5 진행 중

[공식 RPG 사례와 장별 제작표](../../research/2026-11-23-epic-third-chapter-working-landmarks.md) · [후보 빌드 기록](build.json) · [기준 빌드 0.115.69](../hero-windup-interrupt-20261123/build.json)

3장에 이미 배치된 다섯 지물을 기존 지역 팔레트와 Roblox 기본 형상으로 수정했다. Deepwood 명부대의 기록면과 쓰기 받침, Gloamwood 귀환 표식 아래 셰일 파단층과 뿌리 심재, Frozen Vale 난간 받침의 압설과 노출 얼음, Ember Caldera 점검구의 마른 도랑과 퇴적, Haunted Graveyard 관리 통로의 문턱과 귀돌을 조형했다.

## Studio 화면과 보행

- 같은 카메라 10쌍에서 Gloamwood의 뿌리 심재가 접근과 사선 양쪽에서 더 넓게 드러났다. Frozen Vale의 압설 단면은 사선에서 구분됐다. Haunted Graveyard의 넓어진 문턱이 보이고 문설주 뒷면의 대비는 여전히 낮다. Deepwood 명부대의 쓰기 받침과 Ember Caldera 도랑의 퇴적은 가까운 사선에서 변화가 읽힌다. [전후 비교](comparison.jpg)
- 다섯 조립체는 90→96부품이다. 조사점, 피벗, 3축 외곽, 주변 지물 30개가 일치했다. 다섯 조립체 아래 바닥 25점의 높이 오차는 0스터드이고, 기존 동선의 최소 이격은 4.90스터드다.
- 두 빌드에서 점프를 끈 R15가 32스터드 접근 구간 다섯 곳을 각각 왕복했다. 후보의 최대 도착 오차는 2.22스터드이며 허용치는 2.50스터드다. [Studio 측정](studio-results.json)
- 두 빌드에서 캠페인 회귀 9,310건을 통과했다. 사건 82개와 활동 단계 246개를 확인했고 동선 3,981개 표본의 차단은 0건이었다. 전체 캠페인 부품은 56,650→56,656개다. 기준의 첫 회귀 실행은 Studio 포트 충돌로 중단됐고, 별도 포트에서도 도구 연결이 지연됐다. Studio 종료 후 같은 Place를 기본 도구로 다시 실행해 통과했다. [Studio 측정](studio-results.json)

## 정적 검사

두 Place의 SHA-256과 내장 3장 모델 모듈을 기록된 소스 커밋과 대조했다. 모듈 구문 검사와 Lua 에픽 지도 105,907건, 이야기 소품 4,264건, 난이도 진행 4,269건, 전투 경로 77,381건을 통과했다.

## 남은 수용

환경 아트와 QA가 실제 입력에서 Gloamwood의 야간 첫 발견, Frozen Vale의 횡단로 복구 전후 시야, Haunted Graveyard의 통로 개방 뒤 귀환을 확인한다. 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 카메라와 사용자 미술 수용은 미검증이다.

## 재현

Rojo 7.7.1로 기준 소스 `9931210d`와 후보 소스 `50bcee30`의 Place를 확보한다. Studio에서 아래 실행을 순차 진행한다. 두 빌드에 같은 지역 조명과 카메라를 적용하고 HUD와 프롬프트를 숨긴다. 보행은 점프를 끈 R15 자동 왕복이다. 앞선 Studio 실행이 종료된 뒤 다음 Place를 연다.

```sh
evidence=docs/evidence/epic-third-chapter-working-landmarks-20261123
prior=docs/evidence/epic-third-chapter-integrated-20261122
fixture=docs/evidence/epic-third-chapter-landmarks-20261120
work=$(mktemp -d)
cat "$prior/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$fixture/walk-approaches.luau" > "$work/audit.luau"
python3 tools/prepare-campaign-expansion-native.py
cp /tmp/tlt-campaign-expansion-native.luau "$work/expansion.luau"
for version in 0.115.69 0.115.70; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/expansion.luau" > "$work/$version-expansion.log" 2>&1
done
python3 "$prior/compare.py" \
    "$work/0.115.69-audit.log" "$work/0.115.70-audit.log" \
    "$work/0.115.69-expansion.log" "$work/0.115.70-expansion.log" \
    --baseline-version 0.115.69 --output-dir "$evidence"
```
