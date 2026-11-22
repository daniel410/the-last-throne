# 다섯 에픽 첫 사건의 지형과 작업 흔적

2026-11-22 UTC · TLT-061/DW-01 · TLT-065/GW-01 · TLT-062/FV-01 · TLT-063/EC-01 · TLT-064/HG-01 · G5

첫 사건의 기존 Studio 비교판에서 Deepwood의 받침은 약품 상자 옆에 보이지만 물가의 씻긴 돌에서 마른 적재목으로 이어지는 접점이 작다. Gloamwood는 드러난 뿌리 측면이 정면보다 밝고, Haunted Graveyard는 길돌 기단이 안개 낀 지면과 겹친다. Frozen Vale에서는 압설이 정면 설면에 섞인다. Ember Caldera에서는 차륜의 마모면이 접근 화면에서 보이는 반면, 고임쇠와 받침의 맞물림은 측면에서 구분하기 어렵다. [0.114.5↔0.114.6 Studio 비교판](../evidence/epic-opening-readability-20261120/comparison.jpg)

## 공식 제작 사례와 적용

- **Diablo IV · Scosglen.** Blizzard 환경 팀은 해안 바람에 한 방향으로 눕는 풀을 먼저 보여 주고, 선착장과 경사로로 어업 정착지의 형태를 드러낸다. TLT에서는 침식과 쌓임의 방향을 DW 물가 돌섶과 FV 바람그늘의 압설에 반영한다. [Blizzard 환경 아트 제작기](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- **World of Warcraft · The Azure Span.** 해안 마을에서 안개 낀 수림, 동토, 빙봉으로 이어지는 고저차와 지표 변화가 지역 안에서 여정의 단계를 구분한다. FV의 첫 오름길에는 설면, 눌린 눈, 노출 암빙이 차례로 이어지는 낮은 단면을 만든다. [Blizzard 지역 소개](https://news.blizzard.com/en-us/article/23823429/dragonflight-zone-preview-the-azure-span)
- **Lost Ark · Voldis.** Smilegate RPG 제작진은 현자들의 탐구 의지를 123층인 Sage’s Tower의 규모로 표현했다. TLT에서는 GW 정찰대가 갈라진 길에 남은 뿌리와 암층, HG 선발대가 사용한 길돌 받침, EC 작업자가 차륜을 고정한 받침 형태에 각각 사건과 사람의 행동을 읽을 단서를 둔다. [Smilegate RPG 제작 인터뷰](https://www.playlostark.com/en-us/news/articles/creating-voldis)
- **Roblox · 환경 그레이박스.** 캐릭터 축척, 보행과 방향 판독을 반복 점검하는 절차를 적용한다. 장면의 고정 카메라 비교와 R15 자동 왕복을 각각 기록하고, 최초 발견과 조사 입력은 실제 조작에서 확인한다. [Roblox Creator Hub](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/greybox-your-environment)

## 에픽별 제작표

기존 지물의 배치와 재질을 재사용한다. 조사 앵커, 모델 피벗, 동선 폭과 충돌을 보존하고 지형의 노출면과 소품의 접합부를 조형한다. 약품 상자, 발자국, 랜턴과 길돌은 진행을 읽는 기존 단서다. [캠페인 줄거리](../production/campaign-context-review-2026-11-10.md) · [지물 원본](../../src/server/World/EpicQuestLandmarkAssemblies.luau)

| 에픽 · 지물 | 스토리와 모델링 | 접근·귀환 확인 |
| --- | --- | --- |
| Deepwood · `CreekCargoSill` | 실종 보급대의 약품을 찾는 물가다. 씻긴 돌섶이 마른 목재 좌대를 받치도록 돌을 단차 내고, 바닥에 닿는 부분과 끝결을 구분한다. | 약품 상자와 좌대가 서로 분리되어 보이고 강둑 측면에서 받침이 지면에 닿는 형태를 읽을 수 있다. |
| Gloamwood · `WheeltrackForkRootCut` | 무거운 화물과 정찰대의 흔적이 갈라진다. 차가운 셰일 파단면과 그 위에 드러난 목재 심재가 분기 지형의 윤곽을 보여 준다. | 야간 정면과 사선에서 셰일과 심재가 지면에서 구분되고, 기존 발자국과 등불의 방향이 읽힌다. |
| Frozen Vale · `WindbreakAscentBank` | 조난자 수색 중 피난처로 오르는 바람그늘이다. 압설 아래 드러난 청회색 암빙을 층으로 나누고, 바람에 깎인 눈 끝을 오름길 한쪽으로 잇는다. | 수레 쪽과 오름길에서 설면·압설·암빙의 경계가 구분되고 기존 표식이 보인다. |
| Ember Caldera · `FreightCarrierWheelSeat` | 승강기 기어를 회수하기 전 운반대가 멎은 자리다. 닳은 차륜 접촉면을 쐐기에 닿게 하고, 현무암 받침과 고정핀의 연결을 노출한다. | 광차선에서 기존 조사 지점이 보이고, 측면에서 차륜이 닿은 마모면과 쐐기 고정 방식이 읽힌다. |
| Haunted Graveyard · `ScoutApproachStoneFooting` | Rook과 앞서 확보된 피난로를 따라간다. 늙은 길돌의 접근면을 모따기하고 기반석 단차에서 관리인 랜턴 쪽으로 시선이 이어지게 한다. | 야간 정면과 귀환 사선에서 밝은 석재 단면, 기존 표식, 관리인 랜턴을 차례로 식별할 수 있다. |

기준·후보를 같은 지역 조명과 카메라에서 비교한다. 피벗, 조사 앵커, 기존 지물, 바닥 높이와 보행 이격을 재측정한다. 실제 조작에서는 GW 갈림길 최초 발견과 HG 야간 접근의 기존 표식 가림을 우선 확인한다.
