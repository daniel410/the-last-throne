# 다섯 에픽 네 번째 장의 지물 검증

2026-11-20 UTC · TLT-061/DW-04 · TLT-065/GW-04 · TLT-062/FV-04 · TLT-063/EC-04 · TLT-064/HG-04 · G5 진행 중

[공식 RPG 사례와 장별 제작표](../../research/2026-11-20-epic-fourth-chapter-landmarks.md) · [0.114.11 기준 빌드](../epic-third-chapter-landmarks-20261120/build.json) · [0.114.13 후보 빌드](build.json)

환경 3D는 환경 킷의 팔레트와 Roblox 기본 도형으로 조립체를 제작했다. TD 레지스트리에서 해당 시설에 바로 쓸 원본을 찾지 못했다. 0.114.12 소스 `cfedc86c`의 예비 검토에서 HG-04 석축과 마지막 단계의 집결 위치가 겹쳤다. 0.114.13에서 조사선 반대편으로 옮겼다.

## 재현

```sh
evidence=docs/evidence/epic-fourth-chapter-landmarks-20261120
cat "$evidence/camera-setup.luau" \
    docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
    "$evidence/walk-approaches.luau" > /tmp/tlt-epic-fourth-review.luau
run-in-roblox --place builds/0.114.11/TheLastThrone-0.114.11.rbxlx --script /tmp/tlt-epic-fourth-review.luau > /tmp/tlt-epic-fourth-before.log 2>&1
run-in-roblox --place builds/0.114.13/TheLastThrone-0.114.13.rbxlx --script /tmp/tlt-epic-fourth-review.luau > /tmp/tlt-epic-fourth-after.log 2>&1
python3 tools/prepare-campaign-expansion-native.py
run-in-roblox --place builds/0.114.13/TheLastThrone-0.114.13.rbxlx --script /tmp/tlt-campaign-expansion-native.luau > /tmp/tlt-epic-fourth-regression.log 2>&1
python3 "$evidence/compare.py" /tmp/tlt-epic-fourth-before.log /tmp/tlt-epic-fourth-after.log /tmp/tlt-epic-fourth-regression.log
```

기준과 후보에 동일한 지역 조명, 초기 사건 상태, 접근·귀환 측면 카메라를 적용하고 프롬프트와 이름표를 숨긴다. 모델 중심과 외곽 네 점을 수직 레이캐스트해 바닥 높이를 측정한다. 모델 외곽과 조사 전후로 이어지는 동선을 약 1스터드 간격으로 비교한다. HG는 집결 동료 네 명의 표시 단계별 위치에서 모델 외곽까지 수평 거리를 추가 측정한다. R15는 점프를 끄고 마지막 32스터드의 접근 구간을 왕복한다.

## 결과와 인계

- 신규 지물 5개와 46부품을 확인했다. 바닥 표본 25곳의 높이 오차는 0스터드였다. 각 부품은 고정·비충돌·비터치·비쿼리이며 에픽 캐시는 같은 모델을 재사용했다. 조사선과의 최단 거리는 DW 7.52, GW 6.74, FV 8.48, EC 3.67, HG 7.26스터드였다. HG 석축 외곽에서 동료 위치까지 최단 거리는 7.76스터드였다. [Studio 측정](studio-results.json)
- 접근과 귀환 측면에서 DW의 버팀 구조, FV의 압설 위 기단, EC의 두 파손 단부, HG의 석축과 정찰 등불 사이의 여백을 확인했다. GW는 옆에서 셰일과 파손 목재가 보이지만 정면 야간에서 눌린 등불의 단면이 어둡다. [동일 카메라 전후 10쌍](comparison.jpg)
- 기존 지물 20개의 피벗·외곽과 단계 앵커가 기준과 일치했다. 기준과 후보 모두 다섯 구간에서 R15 왕복에 성공했다. Studio 캠페인 회귀 9,193건을 통과했고 사건 82곳, 단계 246개, 바닥·동선 표본 3,968개에서 차단은 0건이었다. [Studio 측정](studio-results.json)
- Lua 회귀 `campaign-context-review` 1,060건, `campaign-mode-progress` 4,493건, `campaign-combat-routes` 77,381건을 통과했다. `campaign-expansion-review`는 10회 중 기준 7회, 후보 8회에 3,492건을 통과했다. 두 버전 모두 같은 절차의 41행에서 간헐적으로 실패했다. 해당 테스트와 공유 진행 소스의 두 버전 차이는 없다.
- 다음 담당은 환경 아트와 QA다. GW-04에서는 실제 입력으로 조작물과 파손 지물을 구별할 수 있는지, HG-04에서는 동료가 모인 상태에서 집결 조작과 귀환 시야를 확인한다. 이전 FV-03 교량 개폐 전후의 시야 확인도 남아 있다. 실기기, 전투 카메라, 게시 클라이언트, 멀티플레이 스트리밍과 사용자 미술 수용은 미검증이다.
