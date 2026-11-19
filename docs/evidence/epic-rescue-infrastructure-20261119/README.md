# 다섯 에픽의 구조·정찰·수리 길목

2026-11-18 Toronto · TLT-061 / TLT-065(GW) / TLT-062 / TLT-063 / TLT-064 · G5 수용 진행 중

[환경 제작표](../../research/2026-11-18-epic-rescue-infrastructure.md)는 현행 스토리와 Diablo IV, World of Warcraft, Lost Ark의 공식 환경 사례를 대조한다. [이전 다섯 에픽 작업](../epic-approach-readability-20261118/README.md)의 접근·귀환 비교와 습지 경로를 회귀 기준에 포함했다.

| 장 | 실제 3D 모델과 배치 | 목표와 거리 |
| --- | --- | ---: |
| DW-05 · Orc Occupied Ruins | 낮게 묻힌 석재 위에 습격대가 임시로 세운 말뚝, 가로재, 버팀대, 재활용 철띠를 배치했다. 포로 수용 구역의 점령 흔적이다. | `prisoners` · 38스터드 |
| GW-05 · Venomcoil Crossing | 밧줄 목표 주변의 사냥터에 긁혀 드러난 흙과 암편, 뽑힌 뿌리가 있는 둑을 배치했다. | `rope` · 26스터드 |
| FV-03 · Wolf Ravine | 기존 방풍 울타리의 기둥에 철제 보강 띠를 두르고 반대쪽 널 위에 두 번째 눈마루를 얹었다. | `west_beacon` · 158스터드 |
| EC-05 · Ancestral Design Vault | 작업대 근처에 두 배관을 양쪽 매니폴드로 닫은 회로 모형을 배치했다. 구리와 녹청, 연결 이음쇠, 표본 덮개로 다음 장의 시험을 예고한다. | `crew` · 44스터드 |
| HG-03 · Lumi Secret Passage | 닫힌 배수구 후면에 얕은 배수 슬롯과 석재 물턱을 배치했다. 루미가 안내하는 실제 관리 통로는 기존 스토리 장치로 구현된다. | `crypt` · 140스터드 |

편집 원본은 [3개 지형·설비 모델](../../../src/server/World/RescueRouteLandmarks.luau)과 [울타리·배수구 및 배치](../../../src/server/World/EpicStoryLandmarks.luau)에 있다. Roblox 기본 입체와 기존 지역 팔레트로 구성했으며, 신규 부품 47개는 충돌·터치·쿼리가 비활성화된 환경 장식이다. 새 모델 세 곳은 기존 배치기의 지면·가이드 동선·주변 부품 검사를 통과한 후보에 생성된다.

## Studio 로컬 재현

[0.113.17 고정 빌드 기록](build.json)의 소스는 `2bc9685757b7a29fe379ca72739fceeb36e354e3`이다. [기준 0.113.16](../battle-arrival-latency-20261118/build.json)의 SHA-256은 `74e5f168a98e3f318b092203846a6fa7287f0a86fea0a85778feb2c703c0e572`이다. PlaceId 0의 Studio에서 플레이어 없이 수행했다. 두 Place 파일을 준비해 아래와 같이 실행한다.

```sh
evidence=docs/evidence/epic-rescue-infrastructure-20261119
base=builds/0.113.16/TheLastThrone-0.113.16.rbxlx
candidate=builds/0.113.17/TheLastThrone-0.113.17.rbxlx
python3 "$evidence/prepare-studio.py" --baseline --output /tmp/tlt-rescue-before.luau
python3 "$evidence/prepare-studio.py" --output /tmp/tlt-rescue-after.luau
python3 "$evidence/prepare-studio.py" --cameras "$evidence/cameras.json" --output /tmp/tlt-rescue-frames.luau
run-in-roblox --place "$base" --script /tmp/tlt-rescue-before.luau >/tmp/tlt-rescue-before.log 2>&1
run-in-roblox --place "$candidate" --script /tmp/tlt-rescue-after.luau >/tmp/tlt-rescue-after.log 2>&1
run-in-roblox --place "$base" --script /tmp/tlt-rescue-frames.luau >/tmp/tlt-rescue-before-frames.log 2>&1
run-in-roblox --place "$candidate" --script /tmp/tlt-rescue-frames.luau >/tmp/tlt-rescue-after-frames.log 2>&1
python3 "$evidence/summarize-studio.py" /tmp/tlt-rescue-before.log /tmp/tlt-rescue-after.log \
  /tmp/tlt-rescue-before-frames.log /tmp/tlt-rescue-after-frames.log
```

## 검증 결과

- 고정 빌드의 변경 모듈 소스가 작업본과 일치했다. Luau 544개를 구문 검사했다. 다섯 에픽을 각각 생성한 뒤 전체 캠페인 및 캐시 생성에서 장식 모델 10개의 접지와 수량을 대조했다.
- 두 빌드의 원본 739목표·38,241표본과 Easy 782목표·39,540표본에서 바닥 누락, 서버 위치 보정, 경로 실패, 몸체 겹침은 0건이다. 점프를 끈 R15가 해당 다섯 목표를 포함한 15개 최종 접근·귀환 구간을 두 빌드에서 모두 통과했다. 이 시험은 스토리 전투와 입력 없이 가이드 경로를 따라가는 로컬 시뮬레이션이다.
- FV-03 울타리와 HG-03 배수구의 피벗, 배치 반경, 충돌 부품 수와 각 부품의 형상 크기·변환은 두 빌드에서 일치했다. [Studio 측정](studio-results.json)
- 동일한 조명, 시야각, 위치에서 지물에 조준한 8쌍을 비교했다. DW-05의 석조와 목재, EC-05의 맞물린 배관이 두 면에서 읽힌다. GW-05는 밤에 암층 윤곽이 보이고 긁힌 흙과 뿌리의 명도 차는 작다. FV-03 정면에서 기둥 띠와 윗부분의 눈을 볼 수 있다. HG-03 후면에서 닫힌 벽의 좁은 배수선과 석조 물턱이 구별된다. [전후 비교판](comparison.jpg) · [카메라 위치](cameras.json)

환경 아트는 GW-05 야간 흙과 뿌리의 대비를 보완할 수 있다. 맵 구현·QA는 FV-03 협곡 첫 굽이에서 울타리 발견 시점, HG-03 실제 관리 통로에서 귀환 시야, FV-04 동쪽 도관을 실제 플레이 카메라로 확인한다. DW-Q1의 기록 회수부터 생존자 보고까지 실제 입력과 전투·회피 카메라, 멀티플레이·스트리밍, 게시 클라이언트·실기기, 사용자 수용은 미검증이다. G5는 진행 중이다.
