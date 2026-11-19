# 다섯 에픽 길목의 재질과 접합

2026-11-19 UTC · TLT-061 / TLT-065(GW) / TLT-062 / TLT-063 / TLT-064 · G5 진행 중

0.113.17의 비교 화면과 현행 영어 스토리 원고를 검토했다. [환경 제작표](../../research/2026-11-19-epic-landmark-visibility.md)에 Diablo IV, World of Warcraft, Lost Ark의 공식 환경 사례와 현행 장면의 적용 근거를 연결했다. 이번 작업은 현행 본편 다섯 에픽에서 구조·정찰·수리와 연결된 기존 길목 지물 한 곳씩을 개선했다.

| 장 | 모델 변경 |
| --- | --- |
| DW-05 · Orc Occupied Ruins | 낮은 절단석 높이를 교차시키고 단면을 밝게 했다. 철띠를 말뚝 발로 옮겨 옛 석조 위에 세운 임시 수용 시설을 표현했다. |
| GW-05 · Venomcoil Crossing | 둑 비탈에 밝은 흙 긁힘 세 줄을 얕게 묻고, 부러진 뿌리의 심재를 암석 위로 드러냈다. |
| FV-03 · Wolf Ravine | 방풍 울타리 윗살 두 곳에 닳은 나뭇결 단면을 얹어 적설과 목재를 구분했다. |
| EC-05 · Ancestral Design Vault | 가는 구리 공급관과 굵은 녹청 회수관을 양 끝의 별도 플랜지에 연결하고 표본 챔버 바닥을 석재 받침에 맞췄다. |
| HG-03 · Lumi Secret Passage | 후면의 젖은 홈을 어둡게 하고 물턱 깊이와 두 낮은 석재 단부로 배수 구조를 표현했다. |

[점령·사냥터·회로 모델](../../../src/server/World/RescueRouteLandmarks.luau)과 [방풍 울타리·배수구 모델](../../../src/server/World/EpicStoryLandmarks.luau)은 기존 Roblox 기본 입체와 지역 재질로 제작했다. 세 장식 모델은 기존 부품을 재가공했고, 울타리와 배수구에 장식 각 두 개를 추가했다.

## Studio 로컬 재현

[0.113.18 고정 빌드](build.json)는 소스 `6d71eaf9481be2516bdd7a2e57588c623dc1abea`에서 제작했다. 기준은 [0.113.17 고정 빌드](../epic-rescue-infrastructure-20261119/build.json)와 해당 버전의 기록이다. PlaceId 0에서 플레이어 없이 실행한다.

```sh
prior=docs/evidence/epic-rescue-infrastructure-20261119
evidence=docs/evidence/epic-landmark-visibility-20261119
base=builds/0.113.17/TheLastThrone-0.113.17.rbxlx
candidate=builds/0.113.18/TheLastThrone-0.113.18.rbxlx
python3 "$prior/prepare-studio.py" --output /tmp/tlt-visibility-after-audit.luau
python3 "$prior/prepare-studio.py" --cameras "$prior/cameras.json" --output /tmp/tlt-visibility-frames.luau
run-in-roblox --place "$candidate" --script /tmp/tlt-visibility-after-audit.luau >/tmp/tlt-visibility-after-audit.log 2>&1
run-in-roblox --place "$base" --script /tmp/tlt-visibility-frames.luau >/tmp/tlt-visibility-before-frames.log 2>&1
run-in-roblox --place "$candidate" --script /tmp/tlt-visibility-frames.luau >/tmp/tlt-visibility-after-frames.log 2>&1
python3 "$evidence/summarize-studio.py" /tmp/tlt-visibility-after-audit.log /tmp/tlt-visibility-before-frames.log /tmp/tlt-visibility-after-frames.log
```

## 검증 결과와 인계

- 변경 모듈이 고정 빌드의 소스와 일치했고 Luau 544개가 구문 검사를 통과했다. 에픽별 단독 생성과 전체 생성·캐시에서 장식 모델 10개의 접지와 수량을 확인했다. 10개 모델의 피벗 원점과 목표 위치는 0.113.17의 기록과 일치했다.
- FV-03 울타리와 HG-03 배수구의 피벗과 충돌 부품 19개·13개의 변환 및 크기가 일치했다. HG-03은 후면 물턱의 장식 범위가 커져 배치 검사용 반경이 12.62에서 12.70스터드로 늘었다.
- 목표 739개의 원본 38,241표본과 목표 782개의 Easy 39,540표본에서 바닥 누락·서버 위치 보정·경로 실패·몸체 겹침은 0건이다. 점프를 끈 R15가 15개 목표의 최종 접근과 귀환을 모두 통과했다. 가이드 경로를 따르는 Studio 자동 보행으로 검증했다. [Studio 측정](studio-results.json)
- 동일 카메라·지역 조명에서 8쌍을 비교했다. DW-05는 절단석 단면과 말뚝 발의 경계가 밝아졌고, EC-05는 양면에서 회수관과 매니폴드 접합부가 더 뚜렷하다. GW-05는 정면에서 긁힘 세 줄과 뿌리 심재가 확인되며 측면에서 흙 긁힘이 둑에 가린다. HG-03 후면에서는 물턱과 어두운 홈이 분리된다. FV-03의 윗살 표면 차이는 이 거리에서 작다. [Studio 전후 비교판](comparison.jpg) · [카메라 좌표](../epic-rescue-infrastructure-20261119/cameras.json)

맵 구현·QA는 FV-03의 첫 굽이와 FV-04 동쪽 도관 접근에서 실제 발견 시점을 확인하고, HG-03 관리 통로에서 귀환할 때 등불과 닫힌 배수 시설이 구분되는지 확인한다. 환경 아트는 GW-05 측면의 긁힘 가림과 FV-03 거리별 대비를 다시 평가한다. DW-Q1의 기록 회수부터 생존자 보고까지 실제 입력, 전투·회피 카메라, 멀티플레이·스트리밍, 게시 클라이언트·실기기, 사용자 미술 수용은 미검증이다.
