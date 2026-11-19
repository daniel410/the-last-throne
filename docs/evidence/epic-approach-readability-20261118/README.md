# 다섯 에픽 접근 지물과 습지 보고 동선

2026-11-18 · TLT-061 / TLT-065/GW / TLT-062 / TLT-063 / TLT-064 · G5 수용 진행 중

[환경 아트 제작표](../../research/2026-11-18-epic-approach-readability.md)에서 0.113.10·0.113.11 화면과 현행 스토리를 검토하고 Diablo IV, World of Warcraft, Lost Ark 및 Roblox 환경 제작 사례를 비교했다. 직전 작업의 [길목 배치와 Studio 기록](../epic-route-landmarks-20261118/README.md)을 기준으로 삼았다.

| 에픽·장 | 환경 3D와 맵 구현 |
| --- | --- |
| Deepwood · DW-Q1 | 습지 아치의 너비와 높이를 좁은 보급로에 맞춰 줄이고 발판을 건조한 연결로 안쪽에 배치했다. 안내가 습지에서 본구역으로 진입한 직후 다음 지역 쪽으로 일찍 꺾을 수 있어 그 구간도 나무 이동 후보에서 제외했다. 처음 적용한 높이 허용폭 조정만으로는 나무 접촉이 남아 해당 변경을 되돌렸다. |
| Gloamwood · GW-04 | 야간 뿌리의 갈라진 심재를 밝히고 가지가 갈라지는 면에 나뭇결을 늘렸다. 정찰 등불 주변의 뿌리 형태를 드러낸다. |
| Frozen Vale · FV-04 | 동쪽 중계기 도관을 6.6 × 2.82 × 11스터드 단면으로 줄여 중계기 방향으로 홈을 정렬했다. 동쪽 도관과 목표 사이 거리는 약 110에서 68스터드로 줄었다. |
| Ember Caldera · EC-04 | 서쪽 공급 수로의 낮은 돌턱 가운데에 고정 여과망을 배치했다. 동쪽 회수 수로는 양쪽 끝으로 이어지는 넓은 침전 홈과 닳은 모서리로 구별한다. |
| Haunted Graveyard · HG-03 | 기존 배수구에 낮은 사선 날개벽과 어두운 물받이를 덧대고 상부 석재를 밝게 했다. 실제 관리 통로의 문·상태는 기존 장치가 표현한다. |

환경 3D 모델의 편집 원본은 [도관·수로](../../../src/server/World/ArchiveAndCanalLandmarks.luau), [숲 뿌리](../../../src/server/World/ForestAndGraveyardLandmarks.luau), [배수구](../../../src/server/World/EpicStoryLandmarks.luau), [습지 아치](../../../src/server/World/CampaignExpansionWorld.luau)다. 아치와 지물은 기존 TLT 기본 입체와 위치·재질 프로필을 파생 편집했다. 신규 외부 메시·텍스처 입력이 없으며 TD 나무는 기존 원본 인스턴스와 간이 충돌체를 함께 배치한다.

## 로컬 재현

[고정 빌드](build.json)는 Rojo로 빌드한 0.113.12이며 소스는 `07386181e2dbdb5434000b5738107bb62ec3a0a0`이다. [기준 0.113.11 빌드](../epic-route-landmarks-20261118/build.json)의 SHA-256은 `4c89d888114e9c4e3faa15beed47574bc73f9ce98eaa2415d4bb4c262517a4cb`다. PlaceId 0의 로컬 Studio에서 플레이어 없이 실행했다. 아래 안내의 Place 경로에는 두 빌드의 실제 파일을 사용한다.

```sh
evidence=docs/evidence/epic-approach-readability-20261118
python3 "$evidence/prepare-studio.py" --baseline --with-frames --output /tmp/tlt-map-approach-baseline.luau
python3 "$evidence/prepare-studio.py" --with-frames --output /tmp/tlt-map-approach-fixed.luau
run-in-roblox --place builds/0.113.11/TheLastThrone-0.113.11.rbxlx --script /tmp/tlt-map-approach-baseline.luau > /tmp/tlt-map-approach-baseline.log 2>&1
run-in-roblox --place builds/0.113.12/TheLastThrone-0.113.12.rbxlx --script /tmp/tlt-map-approach-fixed.luau > /tmp/tlt-map-approach-fixed.log 2>&1
python3 "$evidence/summarize-studio.py" /tmp/tlt-map-approach-fixed.log /tmp/tlt-map-approach-baseline.log \
  --before-frames /tmp/tlt-map-approach-baseline.log --after-frames /tmp/tlt-map-approach-fixed.log
```

## 검증 결과

- 변경된 월드 모듈 다섯 개의 빌드 내 소스 일치와 Luau 543개 구문을 확인했다. 다섯 에픽의 단독 생성과 전체 캠페인 생성·캐시에서 신규 회차의 시각 전용 모델을 포함한 길목 모델 7개·96부품의 배치와 접지를 검사했다. 습지 아치의 양쪽 발판이 지면에 닿고 충돌이 활성화된 상태도 확인했다.
- 두 빌드에서 원본 739목표·38,241표본과 Easy 782목표·39,540표본을 검사했다. 바닥 누락, 서버 위치 보정, 경로 실패는 0건이다. 기존 DW-02 1건과 DW-Q1 3건의 몸체 겹침은 두 난이도 모두 4건에서 0건으로 줄었다.
- 동일 좌표에서 점프를 끈 R15의 12개 접근·귀환을 실행했다. 기준 빌드에서는 DW-Q1 보고 구간만 정방향 보행에서 멈췄다. 0.113.12는 보고 구간과 좁은 입구를 양방향으로 통과했고, 기존 보고 접촉점 각각을 접근·귀환 모두 1스터드 안에서 지났다. 이 시험은 보고 경로 중 충돌을 재현한 구간의 시뮬레이션이다. [Studio 측정 원본](studio-results.json)
- 안내 표식을 숨긴 고정 Studio 카메라 13쌍을 비교했다. 습지 아치의 열린 폭이 양쪽에서 읽혔고 GW의 뿌리와 차가운 암층이 야간 두 구도에서 더 잘 구분됐다. FV의 도관은 동쪽과 서쪽 두 넓은 구도에서 목표 쪽 설비와 한 화면에 들어왔지만, 넓은 구도에서는 도관 홈보다 외곽이 먼저 읽힌다. EC 공급 여과망은 양쪽에서 드러났고 회수 수로는 접근 쪽에서 넓은 홈이 보였다. HG의 날개벽과 물받이는 앞쪽에서 드러나며 등불을 등진 귀환 구도에서는 기존 뒷벽에 가려진다. 배수구는 실제 관리 통로 목표로부터 약 140스터드 외곽에 있다. [비교판](comparison.jpg) · [카메라 위치](cameras.json)

환경 아트·맵 구현의 다음 검토는 실제 시점에서 FV 도관의 접근 거리, HG 배수구의 귀환 면, FV-03 방풍 시설의 첫 발견 지점이다. QA는 DW-Q1 기록 회수부터 생존자 보고까지 실제 조작, 해당 에픽의 전투·회피 카메라, 멀티플레이어 스트리밍, 게시 클라이언트·실기기와 사용자 미술 수용을 이어서 확인한다. Roblox 게시 전 후보 빌드이며 G5 수용은 진행 중이다.
