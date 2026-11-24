# 다섯 에픽 1장 두 번째 사건의 환경 제작표

2026-11-24 Toronto · TLT-061/DW-01 · TLT-065/GW-01 · TLT-062/FV-01 · TLT-063/EC-01 · TLT-064/HG-01 · G5

환경 아트 에이전트는 [1장 첫 사건의 고정 카메라 비교판](../evidence/epic-opening-landmark-profiles-20261122/comparison.jpg)과 두 번째 사건의 목표를 검토했다. 3D 모델링 에이전트는 사건 보행선과 지형 영역을 투영해 좌우 후보를 비교했다. 첫 사건에서 이미 구현한 약품 물가받침, 갈림길 뿌리, 오름길 압설, 화물차 쐐기, 선발대 길돌에 이어 두 번째 사건에서 드러나는 현장의 사용 흔적을 제작 대상으로 잡았다.

## 참고 사례와 적용

- **Diablo IV** 개발팀은 Kyovashad 접근의 방어 시설과 Flooded Depths의 재질·조명 전환을 사례로 설명한다. TLT에서는 현장 규모가 바뀌는 지점에 낮은 목재·석재 단면을 두어 앞서 본 퀘스트 소품의 이야기를 이어간다. [Blizzard 환경 제작기](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- **World of Warcraft**의 Waking Shores는 물길이 암석과 퇴적층을 깎은 지형과 높이 변화에 따른 화산 요새를 보여 준다. TLT에서는 건널목 접근의 퇴적층, 정찰길의 셰일 단면, 얼음과 눈의 경계를 각기 다른 형태로 조형한다. [Blizzard 지역 소개](https://news.blizzard.com/en-us/article/23822253/dragonflight-zone-preview-the-waking-shores)
- **Lost Ark**의 Yorn은 황량한 지상과 Umar 장인들의 지하 건축을 대비시킨다. Ember Caldera에서도 거친 현무암과 정렬된 금속 고정면의 대비로 승강기 작업장의 용도를 드러낸다. [Lost Ark 공식 Yorn 소개](https://www.playlostark.com/en-us/news/articles/january-2022-team-update)
- **Roblox**의 The Mystery of Duvall Drive 제작기는 공간과 재질을 함께 설계해 한 장소의 상태를 전달한다. TLT에서는 기존 지역 조명 아래에서 가까운 접근과 귀환 시점 모두를 비교한다. [Roblox Creator Hub 제작기](https://create.roblox.com/docs/resources/the-mystery-of-duvall-drive)

| 사건 | 장면에서 읽혀야 할 정보 | 구현 |
| --- | --- | --- |
| Convoy Overlook | 수레 흔적이 얕은 건널목으로 이어진다 | 젖은 갓길 퇴적, 낮은 강돌, 닳은 목말뚝 |
| Lantern Fork Lookout | 정찰대가 낮은 가지 밑으로 지나갔다 | 눌린 낙엽, 노출된 셰일, 끊겨 보이는 뿌리 단면 |
| Lantern Ascent Shelter | 피난민이 바람을 피하며 오름길에 들어선다 | 청회색 얼음 기초, 낮은 횡목 방풍판, 뒷면 압설 |
| Freight Lift Service Walk | 작업자가 승강기 진입부의 하중을 받쳐 왔다 | 현무암 기초, 철제 안내 레일, 경사진 레일 선단과 볼트 |
| Keepers Waiting Ground | 묘지 관리인이 오래된 대기 터를 보수했다 | 석조 기단, 돌 빗물턱, 노출 철물과 닳은 손잡이 |

기존 사건 단계의 옆쪽 평탄 지점을 Roblox 네이티브 조립체의 피벗으로 사용했다. 접근로·귀환로와의 이격, 기존 조사 앵커, 바닥 접지, 두 방향의 가독성을 Studio에서 확인한다. [검증 증거](../evidence/epic-opening-route-fixtures-20261124/README.md)
