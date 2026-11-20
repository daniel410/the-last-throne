# 다섯 에픽 두 번째 장의 길목과 시설

2026-11-20 UTC · TLT-061/DW-02 · TLT-065/GW-02 · TLT-062/FV-02 · TLT-063/EC-02 · TLT-064/HG-02 · G5

0.114.6 첫 사건 비교에서 Deepwood의 적재면과 Ember Caldera의 선로 마모면은 기존 목표 옆에서 구분된다. Frozen Vale의 암빙은 밝은 설면과 경계가 드러나고, Gloamwood의 뿌리와 Haunted Graveyard의 돌은 정면 야간 대비보다 측면의 단면이 읽힌다. 두 번째 장에서는 플레이어가 조사 단서를 찾은 뒤 구조, 출발 준비, 귀환에 쓰는 길을 조형한다. 기존 DW-02 구조 쉼터와 약품 선반, FV-02 피난처의 실내 마루·난로는 이미 장면을 설명한다. [0.114.6 비교 화면](../evidence/epic-opening-readability-20261120/comparison.jpg) · [DW-02 시설 비교](../evidence/epic-quest-material-junctions-20261119/README.md) · [FV-02 피난처 비교](../evidence/fv02-floor-20261116/README.md)

## 공식 사례와 적용

- **Diablo IV · Kyovashad.** 접근 구간에서 작은 방어 시설을 단계적으로 보여 주고 거점에 도달하면 절벽과 성벽의 규모를 드러낸다. Deepwood의 캠프 앞 굽이와 Frozen Vale의 봉화 전망대에는 가까이서 구분되는 낮은 측면 단면을 두고, 기존 등불과 조망이 먼 거리의 단서가 되도록 한다. [Blizzard 환경 아트 제작기](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- **World of Warcraft · Ringing Deeps와 Hallowfall.** 수로와 제련소가 장비를 관리하는 주민의 역할을 보여 주고, Hallowfall의 광원은 거주지의 생태와 활동을 설명한다. Ember Caldera의 광차선 받침은 작업 구역의 연결을 보여 준다. Haunted Graveyard에서는 오래된 석조가 기존 등불을 받치는 구조를 드러낸다. [Blizzard 지역 개발 발표](https://worldofwarcraft.blizzard.com/en-gb/news/24025827/)
- **Lost Ark · Voldis.** Smilegate RPG는 현자의 사회적 역할을 탑의 실루엣에 담고, 내부를 탐색하며 현자들의 관점을 접하게 했다. Gloamwood에서는 Finn이 Tali를 볼 수 있는 안전 선반에 실루엣을 집중하고, Haunted Graveyard에서는 동료들이 남긴 피난처 쪽 귀환 표식을 기존 등불과 함께 읽게 한다. [Smilegate RPG의 Voldis 제작 인터뷰](https://www.playlostark.com/en-us/news/articles/creating-voldis)
- **Roblox · 환경 그레이박스.** 실제 크기에서 플레이어가 경로를 따라 이동하고 시야를 판독하는지 먼저 확인한다. 같은 조명과 카메라의 접근·측면 비교를 남기고, 발견과 프롬프트 입력은 실제 플레이에서 관찰한다. [Roblox Creator Hub 환경 제작 가이드](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/greybox-your-environment)

## 장별 제작표

[사건 원본](../../src/shared/CampaignExpansionContent.luau)과 [인물·장면 대사](../../src/shared/CampaignStoryBeats.luau)를 함께 대조했다. 시설은 사건 시작 전에도 존재하는 지형과 작업 흔적을 표현한다. 기존 환경 킷과 지역 재질을 사용하고 사건 목표점 옆에 배치한다. [환경 모델 원본](../../src/server/World/EpicMidchapterLandmarks.luau) · [모델 배치](../../src/server/World/EpicQuestLandmarkAssemblies.luau)

| 에픽 · 위치 | 제작 방향 | 플레이 확인 조건 |
| --- | --- | --- |
| Deepwood · DW-02 · Straggler Path 두 번째 굽이 · `exp_2:2` | 캠프가 보이는 축 옆에 빗물에 드러난 낮은 돌섶을 둔다. 젖은 실트와 노출된 돌 단면으로 구조 쉼터 밖의 숲길이 이어지는 방향을 보여 준다. | 천 표식과 캠프 등불이 보이고 운전사와 함께 굽이를 돌 때 도보선이 바닥과 구분된다. |
| Gloamwood · GW-02 · Outer Web Shelves의 web anchor lookout · `exp_1:2` | 바깥쪽 셰일과 노출 뿌리를 붙여 거미줄이 걸리는 가장자리와 안전 발판의 관계를 만든다. | 야간 진입과 귀환에서 셰일 윗면이 보이고 Finn의 세 줄 등불과 구출 개구부를 곧바로 찾을 수 있다. |
| Frozen Vale · FV-02 · Twin Beacon Terrace 첫 전망 · `exp_2:1` | 낮은 돌 전망턱과 바람그늘의 압설로 안전한 전망 발판의 바깥단을 잡는다. | 쉼터에서 다가올 때 눈과 돌 쪽 단면이 구별되고 협곡·두 봉화 방향으로 카메라를 돌릴 수 있다. |
| Ember Caldera · EC-02 · City Cooling Overlook의 mine freight line · `exp_2:2` | 현무암 받침, 어두운 선로형 부재와 무딘 철 체결구로 광산 화물선의 단면을 드러낸다. 수리 전에 남아 있을 만한 마모를 사용한다. | 전망에서 선로 방향을 찾고 기존 표식과 선로 받침의 용도를 구분할 수 있다. |
| Haunted Graveyard · HG-02 · Departure Lantern Walk의 return-to-shelter marker · `exp_2:3` | 풍화 석조 등잔 벽감과 낮은 측면 덮개로 피난처 등불 주변에 기존 관리 시설의 흔적을 둔다. | 크립트 방향에서 돌아볼 때 석조 측면과 기존 귀환 등불이 구분되고 통로를 찾을 수 있다. |

Studio 검증은 배치·접지·보행 폭, 기존 사건 앵커와 동일 카메라를 대상으로 한다. 실제 R15 접근·귀환과 사건 상호작용, 기기별 카메라·가독성, 사용자 미술 수용은 각 검증 기록에서 별도로 판정한다.
