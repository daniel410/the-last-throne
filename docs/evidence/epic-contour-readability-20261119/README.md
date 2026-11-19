# 다섯 에픽 접근로의 지형 실루엣 검증

2026-11-19 UTC · TLT-061 / TLT-065(GW) / TLT-062 / TLT-063 / TLT-064 · G5 진행 중

환경 아트가 [0.113.23 화면](../epic-approach-contours-20261119/comparison.jpg)과 실제 스토리 원문을 검토했다. 환경 3D가 습지 실트와 마른 지반, 피난처의 뿌리, 늑대 협곡의 암빙, 시험 시설 배후 현무암, 관리 통로의 배수 석조를 기존 5개 런타임 모델에서 다시 조형했다. 맵 구현은 Frozen Vale 암빙의 피벗을 약 29스터드 옮겨 굽이의 표지판과 분리했다. 해당 대표 구간의 Studio 파일럿을 보고 카메라 쪽 암빙 경사를 한 번 더 낮췄다. [환경 아트 제작표](../../research/2026-11-19-epic-contour-readability.md)

## Studio 재현

PlaceId 0에서 [0.113.23 기준 빌드](../epic-approach-contours-20261119/build.json)와 [0.113.24 후보 빌드](build.json)의 소스 커밋과 SHA-256을 확인한다. 이전 6개 카메라에 Frozen Vale 양쪽 피벗을 담는 근경 구도를 추가했다. 아래 명령은 저장소 루트에서 실행한다.

```sh
prior=docs/evidence/epic-approach-contours-20261119
evidence=docs/evidence/epic-contour-readability-20261119
python3 "$prior/prepare-studio.py" --extra-cameras "$evidence/cameras.json" --output /tmp/tlt-contour-readability-base.luau
python3 "$prior/prepare-studio.py" --audit --extra-cameras "$evidence/cameras.json" --output /tmp/tlt-contour-readability-final.luau
run-in-roblox --place builds/0.113.23/TheLastThrone-0.113.23.rbxlx --script /tmp/tlt-contour-readability-base.luau >/tmp/tlt-contour-readability-base.log 2>&1
run-in-roblox --place builds/0.113.24/TheLastThrone-0.113.24.rbxlx --script /tmp/tlt-contour-readability-final.luau >/tmp/tlt-contour-readability-final.log 2>&1
python3 "$prior/compare.py" /tmp/tlt-contour-readability-base.log /tmp/tlt-contour-readability-final.log --versions 0.113.23 0.113.24 --extra-cameras "$evidence/cameras.json" --output-dir "$evidence"
```

## 결과와 인계

- Luau 545개 컴파일, 다섯 에픽의 단독·전체 생성과 캐시 재사용이 통과했다. 5개 모델 30부품은 고정·비충돌·비터치·비쿼리이며 모델마다 지면을 3곳에서 확인했다. 조사 지물 12개의 접지·접근 좌표, 확장 시설 4개의 위치, FV/HG 기존 충돌 형상이 기준과 일치했다. [Studio 측정](studio-results.json)
- Original 38,241개와 Easy 39,540개 보행 표본에서 차단 0건이었다. 점프를 끈 R15 접근·귀환 18개 경로가 통과했다.
- Frozen Vale 암빙의 바운딩 높이는 6.88→4.40스터드다. 굽이에서 중앙 표지판과 분리됐고 양쪽 피벗을 담은 근경에서는 눈에 낮게 이어지는 단면이 기존 등화와 따로 보인다. 먼 거리의 방풍 울타리는 여전히 작다. Deepwood는 실트와 잔디 가장자리의 차이가 작고, Ember Caldera는 낮아진 현무암 위로 계기의 원형 면이 읽힌다. Gloamwood의 뿌리와 Haunted Graveyard의 덮개 돌은 일부 윤곽이 밝아졌지만 어두운 배경에서는 대비가 작다. [동일 카메라 전후 7쌍](comparison.jpg)

다음 담당은 QA와 환경 아트다. DW-Q1의 방수 명단 회수와 보고, FV 굽이의 최초 발견 시점, GW·HG 야간 터치 기기 판독을 실제 입력으로 확인한다. 전투 카메라, 게시 클라이언트, 실기기, 멀티플레이, 스트리밍 및 사용자 미술 수용은 미검증이다.
