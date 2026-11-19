# 다섯 에픽 길목 모델과 보행 방향

2026-11-19 UTC · TLT-061 / TLT-065(GW) / TLT-062 / TLT-063 / TLT-064 · G5 진행 중

[환경 제작표](../../research/2026-11-19-epic-route-perspectives.md)에 공식 RPG 사례, 기존 비교 화면, 현행 스토리, 제작 조건을 연결했다. GW-05의 양면 둑을 대표 모델로 삼고 DW-05 말뚝·버팀, FV-03 울타리 끝단, FV-04 동쪽 도관 체결부, EC-05 시험 회로, HG-03 배수구 뒤쪽 물구멍에 적용했다. 서버 맵 생성 모듈에서 기존 Roblox 기본 입체와 지역 재질로 편집했다.

## Studio 로컬 재현

[0.113.18 기준 빌드](../epic-landmark-visibility-20261119/build.json)와 [0.113.19 고정 빌드](build.json)를 PlaceId 0에서 비교한다. 두 파일의 SHA-256을 빌드 기록과 대조한다. 샘플러는 이전 목표에서 해당 목표의 첫 단계로 향하는 가이드 경로를 최대 8스터드 간격으로 표본화한다. HG-03은 그 첫 구간을 역방향으로 표본화한다. 위치는 바닥에서 5스터드 위, 진행 방향 뒤로 9스터드다. 각도는 모델 중심과 수평 진행 방향이 이루는 각이다. 광선은 충돌 형상으로 가림을 확인하며 장식과 재질의 판독성은 화면으로 확인한다.

```sh
ev=docs/evidence/epic-route-perspectives-20261119
prior=docs/evidence/epic-rescue-infrastructure-20261119
base=builds/0.113.18/TheLastThrone-0.113.18.rbxlx
candidate=builds/0.113.19/TheLastThrone-0.113.19.rbxlx
python3 "$prior/prepare-studio.py" --output /tmp/tlt-route-audit.luau
python3 "$prior/prepare-studio.py" --cameras "$ev/cameras.json" --output /tmp/tlt-route-frames.luau
run-in-roblox --place "$base" --script "$ev/sample-route-views.luau" >/tmp/tlt-route-base.log 2>&1
run-in-roblox --place "$base" --script /tmp/tlt-route-frames.luau >/tmp/tlt-route-base-frames.log 2>&1
{
  cat /tmp/tlt-route-audit.luau
  printf '\ndo\nlocal existingWorld = reviewWorld\n'
  cat "$ev/sample-route-views.luau"
  printf '\nend\ndo\nlocal existingWorld = reviewWorld\n'
  cat /tmp/tlt-route-frames.luau
  printf '\nend\n'
} >/tmp/tlt-route-all.luau
run-in-roblox --place "$candidate" --script /tmp/tlt-route-all.luau >/tmp/tlt-route-candidate.log 2>&1
python3 "$ev/summarize-studio.py" /tmp/tlt-route-candidate.log /tmp/tlt-route-base-frames.log \
  /tmp/tlt-route-candidate.log /tmp/tlt-route-base.log /tmp/tlt-route-candidate.log
```

## 결과와 인계

- Studio에서 Luau 544개를 검사했다. 다섯 에픽의 단독 생성, 전체 생성과 캐시, 장식 모델 10개의 접지를 확인했다. 이전 빌드와 대조해 12개 조사 지물의 지면 피벗·목표 위치, FV-03 울타리와 HG-03 배수구의 충돌 형상이 일치했다. GW-05, FV-04, HG-03에 시각 부품이 각각 1개, 2개, 1개 늘었다. HG-03의 배치 검사용 반경은 12.70에서 13.01스터드로 바뀌었다.
- 원본 38,241표본과 Easy 39,540표본에서 바닥 누락·서버 위치 보정·경로 실패·몸체 겹침이 0건이었다. 점프를 끈 R15로 목표 15개에 접근하고 귀환했다. [Studio 측정](studio-results.json)
- 동일 카메라와 지역 조명에서 11쌍을 확인했다. DW-05 뒤쪽에서 목재 버팀이 석조까지 이어지고 EC-05 옆면에서 두 관의 직경과 원형 단면이 구분된다. GW-05 둑 측면에서 긁힘 두 줄이 보이며, 정면에서는 밝은 면적이 줄어 이전보다 어둡다. HG-03 배수구 뒤쪽의 긴 홈이 두 낮은 물구멍과 석재 물턱으로 읽힌다. [Studio 전후 비교](comparison.jpg)
- 가이드 경로 101개 카메라 위치는 두 빌드에서 일치했다. FV-03은 약 199스터드에서 울타리 격자가 화면 왼쪽에 들어오며 끝단 목재 차이는 작다. FV-04는 약 84스터드에서 동쪽 도관의 낮은 몸체가 보이고 금속 띠는 이 거리에서 구분하기 어렵다. HG-03 배수구는 귀환 표본에서 진행 방향 기준 최소 80도 옆에 있다. [카메라 위치](cameras.json) · [보행 방향 측정](studio-results.json)

환경 아트는 GW-05 정면 야간 대비를 보강하고, 맵 구현은 FV-04에서 도관의 표식 역할이 필요한지와 HG-03 통로 전 구간의 귀환 화면을 검토한다. QA는 실제 입력의 DW-Q1 회수·보고, 전투·회피 카메라, 멀티플레이·스트리밍, 게시 클라이언트·실기기와 사용자 미술 수용을 확인해야 한다. G5는 진행 중이다.
