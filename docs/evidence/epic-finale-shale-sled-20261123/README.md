# 7장 북부 고갯길과 썰매 정지 지점

2026-11-23 Toronto · TLT-061/DW-07 · TLT-065/GW-07 · TLT-062/FV-07 · TLT-063/EC-07 · TLT-064/HG-07

환경 아트와 환경 3D가 다섯 에픽의 [7장 제작표](../../research/2026-11-23-epic-finale-landmarks.md)와 [직전 후보 비교](../epic-finale-landmarks-20261123/README.md)를 검토했다. 접근 시 평행한 암층이 계단처럼 보이는 Gloamwood와 러너 자국이 고임목 앞에서 끊겨 보이는 Frozen Vale를 이번 조형 범위로 잡았다.

- **Gloamwood, Northern Windgap**. 출구 옆 두 셰일 단부의 길이와 방향을 다르게 잡고 위쪽 셰일과 눈이 비스듬히 만나도록 조형했다. 아래쪽 노출 단면은 귀환 쪽에서 보인다. 카메라 거리별 세부 배치와 지역 기후를 재질에 드러내는 접근을 참고했다. [Diablo IV 환경 제작](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- **Frozen Vale, Freight Sled Landing**. 두 러너 끝의 철제 좌석을 0.78에서 1.68스터드로 늘리고 경사를 주어 철제 정지판에 연결했다. 목재 단면의 높이와 폭을 조절해 러너 양쪽의 정지점을 구분했다. Ringing Deeps의 광차와 이동 설비처럼 궤적과 시설의 역할을 연결하는 사례를 참고했다. [World of Warcraft 장소·던전 제작 소개](https://news.blizzard.com/en-us/article/24125258/explore-the-zones-and-dungeons-of-the-war-within)
- Deepwood 적재장 접합, Ember Caldera 빈 선적대, Haunted Graveyard 귀환 보호턱은 앞선 후보 조형을 포함한다. South Kurzan의 Mount Antares처럼 스토리 사건의 결과를 해당 지역의 지형과 설비에서 찾을 수 있는지 검토했다. [Lost Ark South Kurzan](https://www.playlostark.com/en-gb/game/releases/summer-heat)

## 소스와 형상 비교

[런타임 모델](../../../src/server/World/EpicFinaleScenery.luau) · [0.115.59 고정 빌드](build.json) · [형상 비교판](comparison.jpg) · [부품·외곽 측정](measurements.json)

- 직전 후보 0.115.56과 새 후보 0.115.59의 두 모델을 기존 Kit 팔레트로 합성했다. Lua 추출값 중 직전 후보의 부품별 이름·재질·형상·변환·색상은 기존 Studio 추출값과 일치한다. 변환·색상 허용 오차는 0.00001이다. 로컬 세 축 외곽 차이 0이며 Gloamwood 10부품, Frozen Vale 15부품이다.
- Blender Standard/sRGB에서 같은 접근·귀환 카메라 4쌍을 비교했다. Gloamwood 정면의 긴 수평 띠가 두 단부로 갈리고 눈이 경사진 셰일에 붙는다. Frozen Vale 접근면에서 철제 경사판이 양쪽 러너와 정지판 사이를 잇는다. 정지판은 귀환면에서 상부 설비에 일부 가린다. 비교판에는 Roblox 지형·날씨·NPC와 플레이 카메라가 없다.
- 새 Place의 SHA-256과 포함된 7장 모듈을 고정 소스와 대조했다. 에픽 지도 105,907건, 도보 내비게이션 8,791건, 스토리 소품 문맥 4,264건, 전투 경로 77,381건의 Lua 회귀가 통과했다.
- 병행 main 작업도 0.115.58을 예약해 [첫 후보 빌드](build-0.115.58.json)를 보존하고, 그 main 소스를 포함한 별도 후보를 0.115.59로 생성했다. Roblox 게시와 G5 수용은 대기 상태다.

형상 비교를 다시 만들려면 직전 후보 모듈을 커밋 e4c41b7c의 EpicFinaleScenery.luau에서 추출한다. [Lua 추출기](export-profiles.lua)에 직전 모듈, 새 모듈, EpicEnvironmentKit.luau 순서로 넘기고 출력 JSON을 [Blender 렌더 스크립트](../epic-finale-landmarks-20261123/render-models.py)의 첫 번째 인자로 사용한다.

## 고정 Place Studio 감사

0.115.55 기준과 0.115.59 후보를 별도 로컬 Studio에서 실행했다. 공용 CLI 포트의 대기·충돌을 확인한 뒤 고정 소스 조건과 서로 다른 로컬 포트를 사용했다. 다른 Studio 작업에서 들어온 메시지는 해당 두 프로세스의 CreatorOutput과 맞춰 제거했다. 화면은 테스트의 스크립트 카메라로 캡처했다. [18시점 전후 비교](studio-comparison.jpg) · [배치·보행·시야 측정](studio-results.json)

- 두 Place에서 모듈 565개를 검사했다. 다섯 결말 지물의 목표·접근 좌표·바닥 높이·외곽이 기준과 일치했고 주변 지물 10개 측정도 동일했다.
- 두 Place에서 각각 R15 접근·귀환 23구간을 자동 이동으로 통과했다. 기본 38,184개와 Easy 39,483개 동선 표본의 차단 및 경로 실패는 0이다.
- 기준과 후보 모두 Ember Caldera 선적대 표본 27개가 Suri의 좌우 시점에서 각각 전부 보였다. Suri 정면 시점은 0개, 어깨 너머는 24개다. 후보의 롤러 6개와 축경 12개를 확인했다.
- Deepwood 근경에서 바퀴홈의 고임목 앞 접합석이 드러난다. Gloamwood는 근경에서 셰일 단부가 분리되고 뒤 사선에서 눈 경계가 드러나며, 야간 원거리 대비는 낮다. Frozen Vale의 표지 옆 양쪽 정지판은 중거리에서 보이고 러너와 철제 경사의 접점은 근경에서 선명하다. Ember Caldera는 양쪽 롤러 사이의 빈 중앙이 드러난다. Haunted Graveyard 귀환 사선에서는 끝돌이 낮아지는 윤곽이 보인다.

빌드 해시로 두 Place를 확인한 뒤 [감사 도구](../epic-finale-landmarks-20261123/audit.py)의 prepare와 compare에 여기에 있는 build.json을 --build-record로 지정한다. 재현은 0.115.55 고정 기준, 0.115.59 고정 후보, 생성한 두 Luau 스크립트를 사용한다.

다음 환경 아트·QA 확인 지점은 실제 조작의 Gloamwood 야간 첫 발견, Frozen Vale의 표지 옆 귀환, Ember Caldera의 Suri 정면에서 좌우로 이동할 때 선적대가 드러나는 순간이다. 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 전투 카메라, 사용자 미술 수용 및 G5는 미검증이다.
