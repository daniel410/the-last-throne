# 다섯 에픽 길목 모델 재질 대비

2026-11-19 UTC · TLT-061 / TLT-065(GW) / TLT-062 / TLT-063 / TLT-064 · G5 진행 중

[장별 제작표와 공식 RPG 사례](../../research/2026-11-19-epic-landmark-material-contrast.md)에서 이전 비교 화면과 변경 근거를 확인할 수 있다. GW-05의 야간 흙 단면을 대표 개선으로 삼고 DW-05 목책, FV-03 울타리, FV-04 동쪽 도관, EC-05 시험 회로, HG-03 배수구를 함께 다듬었다. 기존 Roblox 기본 입체를 서버 월드 생성 경로에서 편집했다.

## Studio 재현

PlaceId 0에서 [0.113.19 기준 빌드](../epic-route-perspectives-20261119/build.json)와 [0.113.20 고정 빌드](build.json)의 SHA-256을 확인한다. 기준 빌드에서 기존 카메라 화면을 촬영하고 후보에서 경로 회귀 검사, 진행 방향 표본, 동일 카메라 화면을 생성한다.

```sh
ev=docs/evidence/epic-landmark-material-contrast-20261119
views=docs/evidence/epic-route-perspectives-20261119
prior=docs/evidence/epic-rescue-infrastructure-20261119
base=builds/0.113.19/TheLastThrone-0.113.19.rbxlx
candidate=builds/0.113.20/TheLastThrone-0.113.20.rbxlx
python3 "$prior/prepare-studio.py" --output /tmp/tlt-material-audit.luau
python3 "$prior/prepare-studio.py" --cameras "$views/cameras.json" --output /tmp/tlt-material-frames.luau
cat "$ev/closeups.luau" docs/evidence/epic-approach-readability-20261118/capture-approaches.luau \
  >/tmp/tlt-material-closeups.luau
{
  cat /tmp/tlt-material-audit.luau
  printf '\ndo\nlocal existingWorld = reviewWorld\n'
  cat "$views/sample-route-views.luau"
  printf '\nend\ndo\nlocal existingWorld = reviewWorld\n'
  cat /tmp/tlt-material-frames.luau
  printf '\nend\n'
} >/tmp/tlt-material-all.luau
run-in-roblox --place "$base" --script /tmp/tlt-material-frames.luau >/tmp/tlt-material-base.log 2>&1
run-in-roblox --place "$candidate" --script /tmp/tlt-material-all.luau >/tmp/tlt-material-candidate.log 2>&1
run-in-roblox --place "$base" --script /tmp/tlt-material-closeups.luau >/tmp/tlt-material-base-close.log 2>&1
run-in-roblox --place "$candidate" --script /tmp/tlt-material-closeups.luau >/tmp/tlt-material-candidate-close.log 2>&1
python3 "$ev/compare-studio.py" /tmp/tlt-material-candidate.log /tmp/tlt-material-base.log \
  /tmp/tlt-material-base-close.log /tmp/tlt-material-candidate-close.log
```

## 결과와 인계

- Luau 544개를 검사했다. 5개 에픽 단독·전체·캐시 생성, 장식 모델 10개의 접지, 조사 지물 12개의 지면 위치와 목표 좌표, FV-03/HG-03의 충돌 형상을 확인했다. 원본 38,241개와 Easy 39,540개 보행 표본에서 차단 0건을 확인했고, 점프가 꺼진 R15가 15개 목표에 접근하고 돌아왔다. [Studio 측정](studio-results.json)
- 101개 가이드 카메라 표본의 위치·각도·거리·충돌 가림이 기준 빌드와 일치했다. 기존 FV-03, FV-04, HG-03의 원거리 발견 조건은 이전 기록을 따른다. [가이드 기준 측정](../epic-route-perspectives-20261119/README.md)
- 13쌍의 Studio 화면을 비교했다. GW-05 흙 단면 두 줄은 동일 야간 조명의 정면과 측면에서 밝게 이어진다. DW-05 절단면과 FV-03 목재 띠는 근거리에서 미세하게 보인다. EC-05 측면에서 플랜지의 단면이 커졌고 FV-04 근접 화면에서 넓어진 금속 띠가 구분된다. HG-03 후면의 밝은 가로선이 약해졌으며 전면 조적 변화는 작다. [Studio 전후 비교](comparison.jpg)

맵 구현·QA는 FV-03 굽이와 FV-04 도관의 실제 플레이 발견 시점, HG-03 관리 통로의 귀환, DW-Q1 실제 입력의 기록 회수부터 보고까지를 확인한다. 전투 카메라, 멀티플레이, 스트리밍, 게시 클라이언트, 실기기 및 사용자 미술 수용은 미검증이다.
