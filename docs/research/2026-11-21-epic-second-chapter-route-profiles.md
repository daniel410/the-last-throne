# 다섯 에픽 2장 길목의 지형 단면과 접합

2026-11-21 UTC · TLT-061/DW-02 · TLT-065/GW-02 · TLT-062/FV-02 · TLT-063/EC-02 · TLT-064/HG-02 · G5

직전 5장 화면에서 Frozen Vale의 차륜 중심은 접근부터 구분되지만 Ember Caldera의 넘침구와 Haunted Graveyard의 도관 이음은 근경에서야 드러난다. 2장 기존 화면에서도 Deepwood 돌섶과 Gloamwood 셰일 하단은 그늘에 묻히고, Haunted Graveyard 벽감은 사선에서 기존 귀환 표식에 일부 가린다. 장면의 구조를 읽는 데 필요한 면을 크게 잡고, 작은 접합부는 그 구조를 가까이서 설명하는 데 쓴다. [직전 5장 비교](https://github.com/daniel410/the-last-throne/blob/3c11890ab84308d24e779256c2879b8219c23992/docs/evidence/epic-fifth-chapter-landmark-profiles-20261121/README.md) · [기존 2장 비교](../evidence/epic-second-chapter-landmarks-20261120/README.md)

## 공식 사례와 적용

- Diablo IV 환경팀은 빗물과 진흙이 이동 흔적에 남는 방식으로 장소의 과거를 전달하고, 게임 카메라에서 필요한 곳에 묘사를 집중한다. Deepwood 굽이의 씻긴 돌면과 Ember Caldera 선로의 부식 흔적을 조립체가 사용된 방향을 설명하는 데 쓴다. [Diablo IV 환경 제작](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- World of Warcraft의 Azure Span은 해안 마을에서 숲과 툰드라를 거쳐 빙설 봉우리로 이어지며, 고도와 윤곽이 지역 변화를 보여 준다. Frozen Vale에서는 눈이 쌓인 면과 드러난 돌턱 사이의 단차로 봉화 전망대의 가장자리를 드러낸다. [Dragonflight Azure Span 소개](https://worldofwarcraft.blizzard.com/en-us/news/23823429/dragonflight-zone-preview-the-azure-span)
- Lost Ark의 Elgacia는 도시, 정원, 성산을 탐색하며 지역의 비밀을 알아가는 이야기다. Gloamwood의 구조 관측점에는 뿌리와 셰일, Haunted Graveyard의 피난처 귀환점에는 석조 개구를 배치해 서사적으로 역할이 다른 장소의 윤곽을 구별한다. [Lost Ark Elgacia 소개](https://www.playlostark.com/en-gb/news/articles/elgacia-release-notes)
- Roblox의 환경 그레이박스는 캐릭터 크기에 맞춰 이동 폭과 시야를 점검한다. 같은 조명에서 접근과 사선을 비교하고, 이전과 다음 조사점 사이의 보행 이격 및 실제 R15 왕복을 확인한다. [Roblox Creator Hub 환경 그레이박스](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/greybox-your-environment)

## 장별 제작표

다섯 지물은 각각 구조, 전망, 물류, 귀환에 쓰이는 지형과 시설의 일부다. 조형 범위는 기존 조립체이며 사건 단서와 조사 위치는 현행 캠페인 계약을 따른다. [캠페인 확장 사건](../../src/shared/CampaignExpansionContent.luau) · [환경 모델](../../src/server/World/EpicMidchapterLandmarks.luau)

| 장과 지물 | 조형 방향 | 화면에서 확인할 점 |
| --- | --- | --- |
| DW-02 · Straggler Bend Drainage Shoulder | 낙오자를 캠프로 데려가는 굽이의 돌섶에 씻겨 드러난 상단과 유수 퇴적면을 이어 붙인다. | 그늘에서 돌 가장자리가 흙과 분리되고 굽이 바깥쪽으로 배수되는 방향이 읽힌다. |
| GW-02 · Outer Web Root Shelf | Tali를 찾는 바깥 전망의 노출 셰일과 뿌리 안쪽 결에 넓은 단면을 둔다. | 야간 사선에서 셰일과 뿌리를 구별하고 기존 관측 표식을 함께 찾을 수 있다. |
| FV-02 · Twin Beacon Terrace Sill | 두 봉화의 연결을 살피는 전망대에서 마모된 석재 끝과 바람에 눌린 눈을 맞물린다. | 설면에서 돌턱이 구별되고 끝에서 눈층과 암석의 높이 차를 읽을 수 있다. |
| EC-02 · Mine Freight Line Seat | 갇힌 작업반으로 이어지는 끊긴 화물선에 레일 단면과 현무암 받침의 연결을 드러낸다. | 전망에서 두 줄의 진행 방향이 읽히고 사선에서 레일이 고정되는 위치를 알아볼 수 있다. |
| HG-02 · Keeper Return Lantern Niche | 동료들이 확보한 피난처 귀환로에서 벽감의 돌기둥 모서리와 낮은 등잔 받침을 다듬는다. | 야간 사선에서 석조 개구의 폭이 읽히고 기존 귀환 표식과 구별된다. |

고정 카메라 비교에는 같은 지역 조명을 사용한다. 접지와 보행 이격은 Studio에서 측정하고, 지물의 최초 발견과 표식 조작은 플레이어 입력으로 확인한다.
