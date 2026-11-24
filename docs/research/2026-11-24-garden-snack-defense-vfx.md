# Garden Defense와 SNACK Defense 전투 VFX 비교

2026-11-24 · TLT-033/057/059 · TLT 기준 0.115.73

두 Roblox Experience의 전투 영상에서 원거리 카메라로 공격의 출발과 명중을 어떻게 알아보는지 비교했다. 공개 트레일러의 1초 간격 프레임과 플레이 영상의 5초 간격 프레임을 확인했다. 개별 효과의 프레임 길이·내부 구현·라이브 기기 성능은 이 자료에서 확인할 수 없다.

| 참고 장면 | 관찰과 적용 |
| --- | --- |
| **Garden Defense!**, TD Creation 트레일러, 2024-09-29, 0:16~0:23. 초록색 구형 투사체가 지형과 다른 실루엣으로 이동한다. 0:24~0:26에는 흰 섬광과 주황색 명중부가 각기 다른 위치에서 드러난다. | 투사체의 몸체를 먼저 읽히게 하고 꼬리는 몸체 색으로 수렴시킨다. TLT의 활 모델에 짧고 뚜렷한 꼬리를 붙이고, 마나탄은 길쭉하게, 물탄은 둥글고 뒤로 물방울이 퍼지도록 구성한다. [Roblox 공식 페이지](https://www.roblox.com/games/124700121029896/Garden-Defense) · [공식 트레일러](https://www.youtube.com/watch?v=6KLrJLXzrYQ&t=16s) |
| **Garden Defense!**, TheGamerBay MobilePlay, 2026-02-02, 2:30~2:35 및 3:30~3:50. 원거리에서 노란 직선과 주변 청색 덩어리가 서로 다른 폭과 색으로 드러난다. | 직선 궤적과 부피가 있는 물체를 구별하는 대비를 활과 주문에 적용한다. 영웅 발사점, 도착점, 비행 시간은 기존 전투 연동을 사용한다. [Android 플레이 영상](https://www.youtube.com/watch?v=TzVTrlTHylM&t=210s) |
| **SNACK Defense!**, GuverseTD, 2026-10-02, 8:45과 9:10. 8:45의 흰색 명중점에서 굵은 노란 획이 바깥으로 퍼진다. 9:10에는 지형 위로 솟은 분홍색 덩어리가 보이며 주변의 얇은 궤적과 구별된다. | 무기 명중은 짧은 밝은 중심과 무기별로 기울기·길이가 다른 네 갈래로 구성한다. 흰 광량과 획 너비가 목표를 가릴 수 있어 TLT에서는 짧고 좁게 제한한다. [Roblox 공식 페이지](https://www.roblox.com/games/99714898369873/SNACK-Defense) · [실제 플레이](https://www.youtube.com/watch?v=oA_TF85gW8Y&t=525s) |
| **SNACK Defense!**, LuvYaCoffee 업데이트 3 플레이, 2026-10-03, 5:15~5:40 및 6:45~7:05. 이동하는 높은 아치, 지상 가까이 남는 밝은 색, 서로 다른 방향으로 튀는 조각이 한 전장에 함께 보인다. | 물은 옆으로 퍼지고 중력은 안으로 접히게 만든다. 불·얼음은 위로, 흙 파쇄는 낮게 갈라지며 접촉 형태가 먼저 사라지고 일부 물방울만 짧게 뒤따른다. [업데이트 3 플레이](https://www.youtube.com/watch?v=avztJe7pYvk&t=320s) |

Diablo IV의 2021년 VFX 개발 문서는 화면에서 전투 판단과 연결되는 효과의 우선순위를 설명한다. World of Warcraft Retail의 Midnight 개발자 글은 전투에 필요한 정보를 게임 안에서 읽을 수 있게 개선한 방향을 설명하며, Legion 7.3 시전 동작 연구는 기존 방출 기준으로 사용했다. Lost Ark 글로벌의 Aeromancer 소개는 바람·비와 우산의 타격 형태가 구별되는 사례다. 이 기준을 적용해 확정된 특수 명중과 적 예고 위에 반복 섬광이 쌓이지 않도록 했다. 파티 효과는 기존 공유 예산을 사용한다. [Diablo IV](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) · [WoW Midnight](https://news.blizzard.com/en-gb/article/24235745/developer-insight-combat-for-everyone-in-midnight) · [Legion 7.3 선행 조사](2026-11-24-hero-release-shapes.md) · [Lost Ark](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-aeromancer) · [Roblox 렌더링 성능](https://create.roblox.com/docs/performance-optimization/improve)

밤과 낮에 대응하는 원소 팔레트와 국소 명중을 유지하면서, 발사와 명중을 같은 카메라에서 비교한다. 접촉이 지나치게 넓으면 위험 바닥을 가릴 수 있으므로 타격점·진행 방향·각 효과의 소멸 순서, 아군 간소화와 예산 회수를 검사한다. 두 참고 게임의 직접 플레이, TLT의 게시 4인전과 터치 실기기 성능은 미검증이다. [TLT 구현과 수용](../evidence/td-inspired-vfx-20261124/README.md)
