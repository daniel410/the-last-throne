# 다섯 에픽 결말 시야 검증

2026-11-20 · TLT-061/DW-07 · TLT-065/GW-07 · TLT-062/FV-07 · TLT-063/EC-07 · TLT-064/HG-07 · G5 진행 중

[공식 RPG 사례와 제작표](../../research/2026-11-20-epic-finale-sightlines.md) · [0.114.20 고정 빌드](build.json) · [Studio 전후 화면](comparison.jpg) · [Studio 측정](studio-results.json)

## 변경과 확인

- FV-07 재회 등불을 경로 옆으로 4.5스터드 옮겨 목표 측 시점에서 두 썰매 고임목이 보인다. 목표 측 고정 시점에서 고임목 표본의 첫 충돌이 고임목인 광선은 3/6→6/6, 등불에 가로막힌 광선은 3/6→0/6이다. 목재를 어둡게 하고 고임목·러너 간격을 6.1→8.7스터드로 넓혀 중간 접근에서도 두 줄을 구분할 수 있다.
- EC-07 선적 받침과 철재 굴림대 간격을 8.4→9.5스터드로 넓히고 가공된 현무암을 밝게 했다. 상부 접촉면과 빈 적재 공간의 단면이 더 뚜렷하다. 목표 측 전경의 석재는 여전히 하단 일부를 가린다.
- HG-07 보호턱의 낮은 끝으로 갈수록 밝은 갓돌을 적용했다. 야간의 비스듬한 접근에서 높이 변화가 보인다. DW-07 적재로와 GW-07 셰일층은 앞선 실루엣을 보존했다.
- 모델 15개가 에픽 단독 생성과 전체 생성에서 일치했다. 변경한 세 지물 30부품의 피벗·조사 앵커가 기준과 일치하고 접지 15곳의 높이 오차는 0이었다. Luau 554개를 컴파일했다.
- Original 38,205개와 Easy 39,504개 표본에서 차단이 없었고, 기준·후보 각각 R15 접근·귀환 23쌍이 통과했다. 양쪽 동일 카메라 13쌍을 촬영하고 변경된 세 장의 9쌍을 비교판에 남겼다.
- 기존 Studio 스토리 소품 검사 11,547건이 두 빌드에서 통과했다. EC 재가동 플래그에 따른 계전기 색상 적용과 복귀를 포함한다. 기존 HG 복원 검사는 두 빌드에서 로비 루트의 오래된 조회 경로로 실패했다. 검사에서 현재 왕좌 아래의 모델을 조회하도록 바로잡고 후보에서 45건을 통과했다. 포털 폐쇄, 복원과 미완료 영웅 전환을 포함한다.
- Lua 전투 경로 77,381건, 에픽 지도 105,907건 및 내비게이션 8,791건이 통과했다. `late-epics.spec.lua`는 기준과 후보 모두 9행의 `DW-01:exp_1` 목표 가용성 단언에서 실패했다.

## 재현

[0.114.19 기준 소스와 Place](../epic-finale-readability-20261120/build.json) 및 후보 빌드의 커밋에서 동일한 카메라 및 이동 검사를 실행한다. 화면은 기본 생성 상태이며 프롬프트와 이름표는 숨긴다. R15 검사는 점프를 끈 Humanoid의 자동 보행이다.

```sh
# 각 Place에 해당하는 소스에서 감사 스크립트를 생성한다.
python3 docs/evidence/epic-finale-refinement-20261119/prepare-studio.py --output "$audit"
run-in-roblox --place "$place" --script "$audit" > "$log" 2>&1

# 0.114.20의 검증 기록에서 양쪽 로그를 비교한다.
python3 docs/evidence/epic-finale-sightlines-20261120/compare.py "$baseline_log" "$candidate_log"
run-in-roblox --place "$place" --script docs/evidence/epic-finale-sightlines-20261120/check-sights.luau
```

보조 검사는 격리된 Place에서 `tests/story-props-native.luau`를 실행한다. HG 검사는 먼저 `CampaignWorld.create()`로 본편 맵을 만들고 `tests/late-epics-presentation-native.luau`를 실행한다.

다음 담당은 환경 아트와 QA다. FV 재회와 EC 재가동 후 실제 조사 입력, HG 복원 뒤 귀환 시점에서 플레이어와 동료가 시야에 미치는 영향을 관찰한다. 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 전투 카메라 및 사용자 미술 수용은 미검증이다.
