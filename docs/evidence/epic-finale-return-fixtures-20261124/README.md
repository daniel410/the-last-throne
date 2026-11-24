# 다섯 에픽 7장 결말길 보조 지물 검증

2026-11-24 Toronto · TLT-061/DW-07 · TLT-065/GW-07 · TLT-062/FV-07 · TLT-063/EC-07 · TLT-064/HG-07 · G5 진행 중

[공식 RPG 사례와 제작표](../../research/2026-11-24-epic-finale-return-fixtures.md) · [기준 0.115.87 빌드](../hero-cast-shapes-20261124/build.json) · [후보 0.115.89 빌드](build.json) · [Studio 비교판](comparison.jpg) · [측정 결과](studio-results.json)

| 에픽 | 실제 배치 |
| --- | --- |
| Deepwood | 제단길의 다져진 흙, 석재 받침, 닳은 목재 앉음턱 |
| Gloamwood | 북쪽 길의 높이가 다른 두 셰일 경계석과 바람 그늘의 눈 |
| Frozen Vale | 설원 재회 장소의 석판 바닥, 결빙 턱, 낮은 목제 벤치 |
| Ember Caldera | 현무암 기단 위에 세운 출하 지도 받침과 철제 턱 |
| Haunted Graveyard | 귀환 가장자리의 오래된 석조 표석과 수리한 철제 버팀 |

## Studio 결과

- 두 빌드에서 동일 카메라 10쌍을 비교했다. Frozen Vale의 목재 좌판과 얼음 기단, Ember Caldera의 지도 받침과 별도 롤러 선적대가 구별된다. Gloamwood는 눈이 어두운 경계석의 밑면을 드러낸다. Haunted Graveyard의 철제 버팀은 야간 귀환 시점에서 석재보다 대비가 낮다.
- 기존 결말 지물 5개의 피벗·외곽·조사점 측정이 일치했다. 새 조립체 5개, 총 52부품은 고정·비충돌·비터치·비쿼리다. 기단 매입은 0.17~0.26스터드이고 바닥 25점 최대 높이 차는 0.000004스터드 미만이다. 기존 결말 지물 외곽과 최소 3.80스터드, 마지막 목표로 가는 내비게이션 경로와 최소 11.10스터드 떨어져 있다.
- 두 빌드에서 점프를 끈 R15가 다섯 목표의 마지막 접근과 귀환을 왕복했다. Lua 에픽 지도 105,907건, 내비게이션 8,791건, 이야기 소품 문맥 4,264건, 전투 경로 77,381건이 통과했다.
- 캠페인 Studio 회귀는 양쪽 각각 9,310건을 통과했다. 사건 82개, 단계 246개, 바닥과 동선 3,981표본에서 차단은 0건이다. 전체 월드 부품은 57,133개에서 57,185개로 늘었다.

## 남은 수용

다음 담당은 환경 아트와 QA다. Deepwood의 대기 터는 마지막 목표 안내 경로에서 약 47스터드 떨어져 있어 조작 중 발견하기 쉬운지 확인한다. Gloamwood와 Haunted Graveyard는 야간 대비를 우선 확인한다. 다섯 지점의 실제 입력, 게시 클라이언트, 터치 기기, 파티 스트리밍, 전투 카메라, 사용자 미술 수용은 미검증이다.

## 배치 수정

첫 후보 0.115.88에서 Ember Caldera 지도 받침이 기존 선적대와 같은 피벗을 차지했다. Deepwood 지물은 지상 높이가 2스터드 미만이라 기존 배치 검색의 겹침 검사 범위가 음수가 됐다. 후보 0.115.89는 기존 결말 지물의 외곽에 여유 폭을 예약하고 낮은 지물에도 양의 검사 높이를 적용했다. [기각 후보 빌드](build-rejected.json)

## 재현

각 Place의 SHA-256을 빌드 기록과 대조한다. 검증 스크립트는 고정 소스에서 내장 지물 모듈을 비교한다. 후보는 실제 생성된 피벗으로 카메라를 계산하고, 기준에는 같은 [카메라 좌표](cameras.json)를 쓴다. Studio 캡처는 HUD와 프롬프트를 숨기고 지역 조명을 적용한다.

```sh
evidence=docs/evidence/epic-finale-return-fixtures-20261124
work=$(mktemp -d)
baseline="$PWD/builds/0.115.87/TheLastThrone-0.115.87.rbxlx"
candidate="$PWD/builds/0.115.89/TheLastThrone-0.115.89.rbxlx"
python3 "$evidence/prepare-studio.py" --source 8b327a23 --baseline --output "$work/baseline-audit.luau"
python3 "$evidence/prepare-studio.py" --source dcb7a01c --candidate --output "$work/candidate-audit.luau"
python3 "$evidence/prepare-studio.py" --source 8b327a23 --cameras "$evidence/cameras.json" --output "$work/baseline-capture.luau"
run-in-roblox --place "$baseline" --script "$work/baseline-audit.luau" > "$work/baseline-audit.log" 2>&1
run-in-roblox --place "$candidate" --script "$work/candidate-audit.luau" > "$work/candidate-audit.log" 2>&1
run-in-roblox --place "$baseline" --script "$work/baseline-capture.luau" > "$work/baseline-capture.log" 2>&1
run-in-roblox --place "$baseline" --script "$work/baseline-expansion.luau" > "$work/baseline-expansion.log" 2>&1
run-in-roblox --place "$candidate" --script "$work/candidate-expansion.luau" > "$work/candidate-expansion.log" 2>&1
python3 "$evidence/compare.py" "$work"
```

두 `*-expansion.luau`는 해당 고정 커밋에서 `python3 tools/prepare-campaign-expansion-native.py`를 실행한 뒤 `/tmp/tlt-campaign-expansion-native.luau`를 각 경로에 복사한다.
