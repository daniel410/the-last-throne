# 에픽 3장 사건 입구의 지역별 구조

2026-11-25 Toronto · TLT-061~065 · G5

환경 아트가 직전 Studio 비교판과 사건 데이터를 검토했다. Gloamwood에서는 옮긴 등불이 귀환 방향의 지도 차양에서 분리되어 보인다. Deepwood와 Haunted Graveyard의 낮은 설비는 같은 카메라 거리에서 차이가 작다. 이번 작업은 구조길의 직전 조형이 이어지는 다섯 사건의 진입부를 다룬다. 기존 입구는 같은 폭과 높이의 석조 아치에 지역 팔레트를 적용했다. 플레이어가 접근 중 구조물의 용도를 구분할 수 있도록 기둥, 상부 구조, 바닥에 닿는 재료를 사건별로 설계했다. [직전 비교](../evidence/epic-third-chapter-route-profiles-20261125/README.md) · [사건 데이터](../../src/shared/CampaignExpansionContent.luau)

## 공식 사례와 적용

- Diablo IV 환경팀은 Scosglen 해안으로 접근하는 단계에서 바람을 받는 풀과 지역 소품으로 지형의 변화와 생활 흔적을 드러낸다. TLT는 발밑의 석재·눈·화산재와 입구의 하부 구조가 같은 환경에서 만들어진 것처럼 이어지게 한다. [Diablo IV 환경 제작기](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- World of Warcraft의 Ringing Deeps는 용광로와 수로로 일하는 공간을 읽히게 하고, Hallowfall은 거대한 광원을 방향 기준으로 사용한다. TLT는 광산에 직각 철골을 쓰고, Gloamwood에는 지도 차양과 위치가 다른 입구 등갓을 둔다. [The War Within 지역 소개](https://worldofwarcraft.blizzard.com/en-gb/news/24125258)
- Lost Ark의 North Kurzan은 Antares 화산이 재를 내뿜는 지역에서 연합군이 집결하는 서사를 전개한다. TLT는 Ember Caldera의 현무암 받침 위에 구조대가 설치한 풍화 철골을 얹었다. [Arkesia Ignited](https://www.playlostark.com/en-us/game/releases/arkesia-ignited)
- Roblox의 Duvall Drive 제작팀은 대지의 접근 경로를 먼저 만들고 나무 사이에서 건물이 부분적으로 보이게 구성했다. TLT는 같은 위치의 진입·귀환 카메라에서 상부 실루엣과 중앙 통로를 확인한다. [Duvall Drive 환경 제작](https://create.roblox.com/docs/resources/the-mystery-of-duvall-drive/construct-the-house)

## 제작표

| 에픽·사건 | 플레이 중 발견하는 장소 | 입구의 형태 |
| --- | --- | --- |
| DW-03 · exp_2 | Outpost Signal Terrace에서 중단된 감시탑 신호를 찾는다. | 석재 받침에 얹은 목제 관측 프레임과 열린 관측 홈 |
| GW-03 · exp_1 | Lantern Refuge Arrivals에서 정찰대의 등불과 지도를 대조한다. | 셰일과 비대칭 뿌리, 통로 가장자리의 작은 등갓 |
| FV-03 · exp_1 | Lower Ravine Rescue에서 마차 관리인을 보급길로 안내한다. | 낮은 바위 기단과 목재 지붕에 얹힌 압설, 들보가 드러난 방풍 구조 |
| EC-03 · exp_1 | Mine Rescue Staging에서 광부 대피로를 확보한다. | 현무암 기단, 철골 트러스와 빛바랜 주의띠가 달린 갱구 |
| HG-03 · exp_2 | Fortress Side Landing에서 동맹군의 요새 측면 출구를 확보한다. | 줄눈이 읽히는 석회암 문설주와 쐐기돌 |

환경 3D는 기존 조립 도구와 지역 팔레트로 Roblox 네이티브 부품 72개를 조형했다. 지도 구현은 기존 사건 진입점과 방향, 표지판, 조사점과 함께 같은 맵 생성 경로에 연결한다. Studio에서 기존 사건과 보행을 비교하며 입구의 주요 구조는 영구 충돌 기준을 적용한다. [조형 소스](../../src/server/World/EpicThirdChapterEntrances.luau) · [검증](../evidence/epic-third-chapter-entry-silhouettes-20261125/README.md)
