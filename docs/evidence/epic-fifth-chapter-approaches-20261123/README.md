# 다섯 에픽 5장 조사 지형과 지물 검증

2026-11-23 Toronto · TLT-061/DW-05 · TLT-065/GW-05 · TLT-062/FV-05 · TLT-063/EC-05 · TLT-064/HG-05 · G5 진행 중

[공식 RPG 사례와 장별 제작표](../../research/2026-11-23-epic-fifth-chapter-approach-silhouettes.md) · [동일 카메라 전후 10쌍](comparison.jpg) · [Studio 측정](studio-results.json) · [기준 0.115.66](../hero-line-contact-20261123/build.json) · [후보 0.115.67](build.json)

## 실제 배치

| 에픽과 장면 | 조형 변경 |
| --- | --- |
| Deepwood · 병영 보급로 | 석재 적재 턱과 흙 둔덕에 단차를 주고 끊어진 화물 레일의 목재 파단면을 넓혔다. |
| Gloamwood · 정찰대 우회 지점 | 밝은 석회암 층리를 석축의 접근·귀환 면에 배치했다. |
| Frozen Vale · 매몰 호송대 | 압설 차륜 홈을 청회색 얼음으로 드러내고 바람에 쌓인 눈의 가장자리를 조형했다. |
| Ember Caldera · 순환 설비 모형 | 포집조 바닥의 침전물을 넘침구 방향으로 길게 배치했다. |
| Haunted Graveyard · 동쪽 회랑 | 넓은 금속 고정띠와 깎인 석조 받침 어깨로 도관의 접합부를 드러냈다. |

재현 가능한 Roblox 기본 형상과 지역 재질로 기존 조립체를 수정했다. 부품 순증 9개가 다섯 지물에 배치됐다.

## Studio 전후와 회귀

- 동일 카메라 10쌍에서 Frozen Vale의 청회색 차륜 홈은 접근과 귀환 양쪽에서 구분됐다. Gloamwood 석축의 밝은 중단과 Haunted Graveyard 도관의 받침 어깨는 귀환 근경에서 읽혔다. 두 야간 장면의 최초 접근에서는 세부 변화가 작았다.
- Deepwood의 적재 턱은 접근에서 밝은 끝면을 드러냈다. Ember Caldera의 침전은 귀환 화면에서 희미했고 접근 거리에서는 포집조의 전체 윤곽이 먼저 보였다.
- 조사점·피벗·3축 외곽과 주변 지물 30개가 일치했다. 다섯 모델의 바닥 25점에서 높이 오차는 0스터드였다. 기존 보행선 최소 이격은 4.25스터드, EC 인물 최소 이격은 6.82스터드였다.
- 기준과 후보에서 점프를 끈 R15가 다섯 조사 지점 앞 32스터드를 각각 왕복했다. 후보 최대 도착 오차는 2.35스터드로 허용치 2.50스터드 이내다.
- 캠페인 회귀는 각 빌드에서 사건 82개, 단계 246개를 포함한 9,310건을 통과했다. 바닥·동선 3,981개 표본에서 차단은 0건이었다. 전체 캠페인 부품 수는 56,641개에서 56,650개로 늘어 조립체 변경량과 일치했다.

## 정적 검증과 수용 범위

정적 검사는 Lua 지도 105,907건, 이야기 소품 4,264건, 난이도별 캠페인 진행 4,269건, 전투 경로 77,381건과 변경 모듈 구문을 통과했다. 두 Place의 파일 해시와 내장 모델 모듈을 각 빌드 기록 및 소스 커밋과 대조했다.

게시 클라이언트, 실기기, 파티 스트리밍, 전투 중 시야와 사용자 미술 수용은 미검증이다. 환경 아트와 QA의 다음 확인은 실제 입력에서 야간 최초 발견과 귀환 시 설비 판독이다.

## 재현

기준은 소스 `327674f9`, 후보는 `a205c763`이다. 각 빌드 기록에 나온 Rojo 7.7.1로 고정 Place를 확보한다. 아래 검증은 Studio에서 순차 실행한다.

```sh
fixture=docs/evidence/epic-fifth-chapter-landmarks-20261120
evidence=docs/evidence/epic-fifth-chapter-approaches-20261123
work=$(mktemp -d)
cat "$fixture/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$fixture/walk-approaches.luau" > "$work/audit.luau"
python3 tools/prepare-campaign-expansion-native.py
cp /tmp/tlt-campaign-expansion-native.luau "$work/expansion.luau"
for version in 0.115.66 0.115.67; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version-audit.log" 2>&1
    run-in-roblox --place "$place" --script "$work/expansion.luau" > "$work/$version-expansion.log" 2>&1
done
python3 "$evidence/compare.py" \
    "$work/0.115.66-audit.log" "$work/0.115.67-audit.log" \
    "$work/0.115.66-expansion.log" "$work/0.115.67-expansion.log" \
    --output-dir "$evidence"
```
