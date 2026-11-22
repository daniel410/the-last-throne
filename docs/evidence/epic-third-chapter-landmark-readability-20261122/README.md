# 다섯 에픽 3장 구조·정비 지물

2026-11-22 UTC · TLT-061/DW-03 · TLT-065/GW-03 · TLT-062/FV-03 · TLT-063/EC-03 · TLT-064/HG-03 · G5 진행 중

[공식 RPG 사례와 에픽별 제작표](../../research/2026-11-22-epic-third-chapter-working-fixtures.md) · [0.115.41 기준 빌드](../hero-contact-weight-20261121/build.json) · [0.115.42 후보 빌드](build.json)

| 에픽 | 배치한 3D 형상 |
| --- | --- |
| Deepwood | 구조 명부대에 닳은 기록면, 종이 받침턱, 주춧돌에 닿는 목재 버팀을 구현했다. |
| Gloamwood | 피난처 귀환점에 양면 목재 표식, 노출 뿌리 심재와 셰일 파단층을 만들었다. |
| Frozen Vale | 협곡 난간의 기둥 신발과 손잡이 아랫살을 보강하고 눈 옆 암반 단면을 노출했다. |
| Ember Caldera | 광차선 옆 냉각 점검구의 안쪽 내화벽과 문턱을 만들고 물때를 보강했다. |
| Haunted Graveyard | 관리 통로 문턱 끝에 단차를 내고 문설주 귀돌과 힌지 핀을 조형했다. |

## 화면과 검증

- 같은 카메라 10쌍에서 DW 명부대의 받침턱, FV 난간 기둥의 신발, EC 점검구 안쪽 단차, HG 문설주의 밝은 끝돌이 보인다. FV의 근접 접근 시점에서 교량 가림이 해소됐다. GW 목재 표식은 밝아졌으며 밤의 뿌리와 지면 대비는 낮다. [Studio 전후 비교](comparison.jpg)
- 다섯 모델은 부품 60→81개다. 모델 외곽, 피벗, 조사 앵커와 나머지 지물 30개가 일치했다. 바닥 높이 오차는 25점에서 0이고 최소 보행선 이격은 4.90스터드다. 기준·후보 각 다섯 구간에서 점프 없는 R15 왕복을 통과했다. [Studio 측정](studio-results.json)
- 기준·후보의 Studio 캠페인 회귀는 각각 9,310건을 통과했고 동선 3,981표본 모두에서 차단은 0건이다. [Studio 측정](studio-results.json)
- Lua 에픽 지도 105,907건, 이야기 소품 4,264건, 난이도 진행 4,269건, 전투 경로 77,381건과 변경 모듈 구문 검사를 통과했다. 고정 빌드는 Rojo 7.7.1을 사용했다.
- 첫 Studio 시도는 포트 공유와 저장 공간 부족으로 중단했다. 직전 작업의 깨끗한 임시 체크아웃을 정리하고 생성 빌드를 별도 보존한 뒤 재실행했다.

다음 담당은 환경 아트·QA다. 실제 입력과 퀘스트 프롬프트를 사용해 GW 야간 최초 발견, FV 교량 복구 전후 시야, HG 통로 개방 뒤 귀환에서 장식이 목표와 구분되는지 관찰한다. 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 전투 카메라와 사용자 미술 수용은 미검증이다.

## 재현

고정 빌드를 Studio에서 순차 실행한다. FV 접근 카메라는 조사점 앞 약 9스터드에 둔다. 촬영에는 지역 조명을 적용하고 프롬프트와 이름표를 숨긴다. 별도의 R15 이동은 점프를 끈 스크립트로 입력한다.

```sh
old=docs/evidence/epic-third-chapter-landmarks-20261120
evidence=docs/evidence/epic-third-chapter-landmark-readability-20261122
qa=$(mktemp -d)
cat "$evidence/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$old/walk-approaches.luau" > "$qa/audit.luau"
python3 tools/prepare-campaign-expansion-native.py
cp /tmp/tlt-campaign-expansion-native.luau "$qa/expansion.luau"
for version in 0.115.41 0.115.42; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    for suite in audit expansion; do
        run-in-roblox --place "$place" --script "$qa/$suite.luau" > "$qa/$version-$suite.log" 2>&1
    done
done
python3 "$evidence/compare.py" \
    "$qa/0.115.41-audit.log" "$qa/0.115.42-audit.log" \
    "$qa/0.115.41-expansion.log" "$qa/0.115.42-expansion.log"
```
