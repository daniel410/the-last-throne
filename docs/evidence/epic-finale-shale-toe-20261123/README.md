# 다섯 에픽 결말 지물 통합과 고갯길 밑단

2026-11-23 Toronto · TLT-061/DW-07 · TLT-065/GW-07 · TLT-062/FV-07 · TLT-063/EC-07 · TLT-064/HG-07

## 제작

환경 아트와 환경 3D가 [0.115.61의 다섯 에픽 검증](../epic-finale-windgap-20261123/README.md)을 검토했다. 맵 구현은 Deepwood의 적재장, Gloamwood의 북쪽 고갯길, Frozen Vale의 썰매 정지점, Ember Caldera의 선적대, Haunted Graveyard의 귀환 보호턱을 최신 영웅 소스와 통합했다. 0.115.63의 배치·동선·EC 시야 기록은 0.115.61과 일치했다.

Scosglen의 기후 전이, Hallowfall의 원거리 표지, Voldis에서 다음 이야기로 이어지는 지물의 역할을 참고했다. GW-07의 등불과 금색 표지는 밤에 먼저 읽히고, 가까워지면 노출 셰일과 적설이 Frozen Vale을 예고한다. [Diablo IV 환경 아트](https://news.blizzard.com/en-gb/article/23788294/diablo-iv-quarterly-updatemarch-2022) · [World of Warcraft Hallowfall](https://worldofwarcraft.blizzard.com/en-us/news/24125258) · [Lost Ark Voldis 제작기](https://www.playlostark.com/en-us/news/articles/creating-voldis)

0.115.63 로컬 실제 키 입력에서 지물까지 18스터드에 이르자 셰일 밑단의 긴 수직면이 드러났다. 0.115.64는 기존 1.32스터드 높이의 기저를 0.60스터드 바닥과 0.72스터드 경사로 나눴다. 진입자가 처음 마주한 측면으로 낮아지며 기존 적설층과 셰일 윗부분을 받친다. 공통 조형 도구와 기존 Slate 재질을 재사용했다.

## 재현

- [고정 빌드](build.json)의 소스 10개와 Place 내 모듈을 각각 대조했다. Lua 회귀는 에픽 지도 105,907건, 도보 내비게이션 8,791건, 스토리 소품 4,264건, 전투 경로 77,381건을 통과했다. 별도로 확인한 캠페인 확장 테스트는 최신 main과 통합 빌드 양쪽에서 기존 첫 장 Gold 단언이 실패했다.
- Studio 감사는 [기존 감사 도구](../epic-finale-landmarks-20261123/audit.py)에서 `--build-record`를 이 폴더의 build.json으로 지정해 두 Place를 준비한다. [카메라 추가 도구](../epic-finale-sightlines-20261123/add-cameras.py)로 [추가 시점 2개](../epic-finale-sightlines-20261123/cameras.json)와 [45스터드 진단 시점](../epic-finale-windgap-20261123/midpoint.json)을 두 스크립트에 추가한다. 각 고정 Place의 CreatorOutput에서 `TLT_` 행을 baseline.log와 candidate.log로 저장하고 [비교 도구](compare.py)에 해당 폴더를 넘긴다.
- 실제 조작은 [입력용 Place 생성기](prepare-input.py)로 복사본을 만든 뒤 Studio Play에서 Easy GW-07 Configure/Solo로 입장한다. [테스트 영웅 상태](seed.luau)는 출구 거미줄 해제 직전의 Gloamwood 기사이며 Studio 세션과 PlaceId 0에 한정된다. 복사본에서 InventoryService 소스 한 개만 바뀐 것을 대조했다. 실제 키 입력으로 D, Right, W, S를 사용하고 기본 Custom 카메라를 유지했다.

## Studio 배치와 고정 시점

두 Place 각각 Luau 모듈 565개, 고정 카메라 21시점, R15 자동 왕복 23구간을 통과했다. 기본 38,184개와 Easy 39,483개 동선 표본에서 차단과 경로 실패가 0이었다. 14개 비교 지물의 배치 기록이 일치했고 EC 선적대 시야는 Suri 좌우 각각 27/27, 정면 0/27로 같았다. GW 밑단은 10→11부품이며 고정·비충돌·비터치·비쿼리, 지물의 피벗·목표·수평 외곽, 바닥 표본 5개를 유지했다. 매립 깊이와 높이 외곽 차이는 각각 0.000001스터드 미만이다. [측정 기록](studio-results.json) · [대표 고정 시점 9쌍](fixed-camera-comparison.jpg)

처음 수집한 0.115.63 브리지 출력은 동일 모델을 가진 별도 Studio 세션의 메시지가 섞였다. 해당 Place를 단독으로 다시 실행해 프레임 4,725행과 경로 기록을 수집했다. 화면 해시는 캡처 식별에 사용하며 전체 장면 픽셀 차이를 지물 변경으로 해석하지 않았다.

## 실제 입력 결과

두 Place 복사본에서 Easy GW-07 입장과 출구 목표 HUD를 확인했다. 후보의 기본 카메라에서 첫 생성 위치는 지물과 약 90스터드 떨어져 있고 지물은 우측 화면 밖이다. 키 입력으로 화면을 돌려 약 44스터드에서 지물을 찾았으며, 약 16스터드에서 기저가 땅으로 내려가는 경사면이 보였다. 옛 기저는 약 18스터드에서 수직 단면이 두드러졌다. 물러난 약 85~88스터드에서는 등불과 목표 표지가 적설보다 먼저 읽혔다. 같은 입력을 사용한 두 실행의 실제 위치에는 약 2~3스터드 차이가 있다. [실제 조작 화면](gw07-input-comparison.jpg) · [위치·카메라 기록](input-results.json)

환경 아트·QA의 다음 확인 대상은 FV-07 재회 표지 옆 귀환과 EC-07 Suri 양옆을 실제로 이동할 때의 시야다. GW 출구 조작 완료, 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 전투 카메라, 사용자 미술 수용 및 G5는 미검증이다.
