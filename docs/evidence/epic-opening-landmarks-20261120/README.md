# 다섯 에픽 첫 사건의 맵 지물 검증

2026-11-20 UTC · TLT-061~065 · G5 진행 중

[공식 RPG 사례와 제작표](../../research/2026-11-20-epic-opening-landmarks.md) · [0.114.4 기준 빌드](../epic-quest-material-junctions-20261119/build.json) · [0.114.5 후보 빌드](build.json)

| 사건 | 지형·지물 | 설치 기준 |
| --- | --- | --- |
| DW-01 | Creek Cargo Sill · 실트, 씻긴 돌과 마른 목재 적재턱 | 약품 상자 조사 단계 옆 |
| GW-01 | Wheeltrack Fork Root Cut · 휠 자국 옆 흙 단면과 갈라진 뿌리 | 첫 바퀴 홈 조사 단계 옆 |
| FV-01 | Windbreak Ascent Bank · 회청 암빙과 압설 비탈 | 바람그늘 오름길 표시 단계 옆 |
| EC-01 | Freight Carrier Wheel Seat · 현무암 받침과 철제 고임쇠 | 화물 운반대 조사 단계 옆 |
| HG-01 | Scout Approach Stone Footing · 이끼 낀 기단과 마모된 낮은 돌 | 브란의 길돌 조사 단계 옆 |

설치 기준은 기존 활동 시퀀스의 진행 방향이며, 모델 피벗은 그 옆 9~10스터드의 바닥에 있다. 환경 킷의 로컬 기본 형상과 재질을 사용했다. 장식 부품은 고정·비충돌·비터치·비쿼리로 생성한다.

## 재현

로컬 Studio에서 단일 Place 파일을 열고 지역 조명, 접근·측면 카메라, 기본 저장 전 상태를 사용한다. 고정 촬영은 떠 있는 이름표와 프롬프트를 끈 상태로 수행한다.

```sh
evidence=docs/evidence/epic-opening-landmarks-20261120
cat "$evidence/camera-setup.luau" docs/evidence/epic-approach-readability-20261118/capture-approaches.luau > /tmp/tlt-opening-capture.luau
run-in-roblox --place builds/0.114.4/TheLastThrone-0.114.4.rbxlx --script /tmp/tlt-opening-capture.luau > /tmp/tlt-opening-baseline.log 2>&1
run-in-roblox --place builds/0.114.5/TheLastThrone-0.114.5.rbxlx --script /tmp/tlt-opening-capture.luau > /tmp/tlt-opening-candidate.log 2>&1
python3 tools/prepare-campaign-expansion-native.py
run-in-roblox --place builds/0.114.5/TheLastThrone-0.114.5.rbxlx --script /tmp/tlt-campaign-expansion-native.luau > /tmp/tlt-opening-regression.log 2>&1
python3 "$evidence/make-comparison.py" /tmp/tlt-opening-baseline.log /tmp/tlt-opening-candidate.log /tmp/tlt-opening-regression.log
```

Lua 회귀는 `campaign-context-review` 1,060건, `campaign-expansion-review` 3,492건, `campaign-mode-progress` 4,493건, `campaign-combat-routes` 77,381건을 통과했다.

## Studio 결과와 인계

- 새 지물 5개·33부품을 실제 캠페인 월드에서 확인했다. 각 모델의 중심과 외곽 접지 25곳은 바닥 오차 0스터드였다. 고정·비충돌·비터치·비쿼리, 캐시 재사용, 단계 앵커 위치를 확인했다. 기존 다섯 모델의 앵커·피벗·크기·부품 수는 기준 빌드와 같았다.
- 동일 카메라 10쌍에서 DW 적재턱과 EC 고임쇠가 기존 조사 지물 옆에 드러난다. FV 압설 상단은 정면의 밝은 설면과 합쳐 보이고 옆에서는 암빙 단면이 선명하다. GW 야간 뿌리와 HG 석조는 근경에서도 명도 차이가 작다. [전후 비교](comparison.jpg) · [Studio 측정](studio-results.json)
- 고정 소스와 Luau 컴파일을 포함한 캠페인 Studio 회귀 9,193건이 통과했다. 사건 82곳, 활동 단계 246개, 바닥·동선 표본 3,968개에서 차단 0건을 확인했다.
- 다음 담당은 환경 아트와 QA다. 실제 R15 조작에서 FV의 오름길, GW의 야간 분기 및 HG의 안개 속 단서를 처음 발견하는 시점을 확인한다. 실시간 조작, 전투 카메라, 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 사용자 미술 수용 및 G5는 미검증이다.
