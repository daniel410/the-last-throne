# 세 번째 장의 구조 기록과 정비 시설

2026-11-22 UTC · TLT-061/DW-03 · TLT-065/GW-03 · TLT-062/FV-03 · TLT-063/EC-03 · TLT-064/HG-03 · G5

## 비교 화면에서 확인한 문제

0.115.40의 2장 비교판에서 설면의 석축 단면과 광차 주행면은 멀리서 구분된다. GW의 낮은 셰일은 밤에 주변 지면과 섞이고 HG의 벽감 아래는 사선에서 녹색 표식과 겹친다. 세 번째 장의 0.114.11 비교판에서도 비슷한 문제를 발견했다. GW 귀환 지물은 정면에서 푸른 셰일 바닥이 먼저 드러나며 목재의 방향이 흐리다. FV는 기존 교량 구조가 고정 접근 카메라를 가려 난간을 측면에서만 볼 수 있다. DW와 EC는 지물의 형태가 보이지만 DW에서는 명부를 올려두는 방식, EC에서는 흐름이 지나던 개구 안쪽이 잘 드러나지 않는다. HG는 밝은 문턱 뒤에 남은 문설주 단차를 귀환 방향에서도 읽을 필요가 있다. [2장 비교 화면](../evidence/epic-second-chapter-landmark-readability-20261122/comparison.jpg) · [3장 비교 화면](../evidence/epic-third-chapter-landmarks-20261120/comparison.jpg)

## 공식 사례와 적용

- **Diablo IV · Scosglen.** Blizzard 환경 팀은 해안 정착지의 석조 벽과 주워 모은 목재에 풍화 흔적을 남기고 선착장과 경사로를 배치해 어업을 보여 준다. TLT에서는 명부가 닿는 목재 면, 바람에 드러난 암빙과 눌린 눈, 문턱의 닳은 모서리로 재료의 쓰임을 전달한다. [Blizzard 환경 아트 제작기](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- **World of Warcraft · The Ringing Deeps.** Machine Speakers가 살며 오래된 기계를 관리하는 지역에 제련소와 수로가 배치되어 있다. TLT에서는 광차 옆 점검구의 내화벽과 건조한 광물 띠, 횡단로 난간과 체결판의 접합으로 유지보수 작업을 설명한다. [Blizzard 지역 소개](https://worldofwarcraft.blizzard.com/en-us/news/24125258/)
- **Lost Ark · Voldis.** Smilegate RPG는 현자의 탑을 방문하는 과정에서 주민들이 지식을 쌓고 전하는 방식을 보여 준다. TLT에서는 구조 명부를 잠시 올리는 작업면과 피난처로 향하는 귀환 표식에서 구조대의 역할과 기록의 목적이 드러나도록 한다. [Smilegate RPG 제작 인터뷰](https://www.playlostark.com/en-us/news/articles/creating-voldis)
- **Roblox · 환경 그레이박스.** Creator Hub는 장면을 다듬기 전에 캐릭터 규모와 카메라 시야, 통과 가능성을 검토한다. 같은 앵커를 향한 접근 및 귀환 화면과 R15 왕복을 비교하고, FV에서는 교량 밖 실제 보행 구간에서 카메라 위치를 잡는다. [Roblox Creator Hub](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/greybox-your-environment)

## 장별 제작표

기존 3장 지물의 조형을 수정한다. 돌·눈·재의 지면 접점은 기존 위치와 보행 폭 안에서 사용한다. 퀘스트의 상호작용은 각 기존 목표물에서 이루어지며, 시설에는 수리나 구조의 성공을 앞서 암시하는 완성 표시를 두지 않는다. [현재 줄거리](../production/campaign-context-review-2026-11-10.md) · [기존 장별 배치](../../src/server/World/EpicThirdChapterLandmarks.luau)

| 장 · 지물 | 환경 모델링 방향 | 접근·귀환 확인 |
| --- | --- | --- |
| DW-03 · `ReliefRosterStand` | 구조 명부를 대조하는 곳으로 읽히도록 명부를 얹는 수납 턱과 닳은 면을 드러내고 배면 쪽 버팀으로 작업대의 하중을 설명한다. | 캠프에서 다가올 때 목재 작업면과 기존 명부 조사가 각각 보인다. 옆과 뒤에서는 주춧돌과 목재의 접합이 보인다. |
| GW-03 · `RefugeReturnRootMarker` | 피난처로 돌아서는 지점의 양면 목재 표식과 노출 심재를 갈라진 뿌리, 푸른 셰일 발치에 연결한다. 표식의 마모면은 따뜻한 목재색으로 잡는다. | 접근과 귀환에서 목재와 지면의 윤곽이 분리된다. 기존 녹색 표식과 혼동할 정도로 두 표식이 겹치는지 확인한다. |
| FV-03 · `RavineWalkRailAnchor` | 난간의 철제 포스트와 체결판을 암빙 위에 이어 붙인다. 닳은 체결부, 푸른 암빙과 그 옆의 압설을 서로 다른 면으로 드러낸다. | 교량 밖에서 조사점으로 걷는 R15 시점에 난간과 기존 결속 지점이 보인다. 눈과 받침 연결이 측면에서도 구분된다. |
| EC-03 · `BelowRailCoolantInspectionHead` | 마른 홈에 닿는 내화벽 안쪽을 어둡게 두고 옅은 광물 침전으로 물이 지나던 높이를 보여 준다. 광차선 옆 낮은 점검구의 용도를 살린다. | 광차선에서 다가올 때 기존 화물 조사와 점검구가 구분된다. 옆에서 돌아볼 때 내화벽 개구와 침전 높이가 읽힌다. |
| HG-03 · `KeeperServiceDoorJamb` | 남은 문받이와 문턱 끝면에 단차를 내고 철제 힌지가 고정됐던 자리를 드러낸다. 낮은 접지면에서 관리 통로의 측면으로 시선을 잇는다. | 진입과 귀환에서 밝은 석재 단면이 구분되고 기존 황동 문양 조사가 보인다. |

고정 화면 비교는 미술 가설을 검토하는 증거다. R15 자동 왕복은 접근 가능성을 검증한다. 실제 조작에서 최초 발견과 프롬프트 사용을 관찰하고, 이후 전투 카메라·게시 클라이언트·실기기에서 확인한다.
