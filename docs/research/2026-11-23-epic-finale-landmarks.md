# 다섯 에픽 7장 지형과 시설의 접근·귀환 판독

2026-11-23 Toronto · TLT-061/DW-07 · TLT-065/GW-07 · TLT-062/FV-07 · TLT-063/EC-07 · TLT-064/HG-07 · 환경 아트, 환경 3D, 맵 구현

지난 7장 Studio 비교판 13쌍과 현재 런타임 조형을 검토했다. Deepwood 적재장 앞 흙 사면과 Gloamwood 야간 셰일층은 정면에서 구분된다. Frozen Vale 정지판과 Ember Caldera 축경은 근경에서 드러나지만 중간 거리에서 작다. Haunted Graveyard 버팀은 목표 방향보다 귀환 사선에서 석재와 대비가 약하다. 이전 Suri 시야 감사에서 인물 중심은 선적대 표본 27개를 모두 가렸으며, 좌우에서는 각각 27개 모두 보였다. 이번 제작은 이동 중 보이는 이음부를 우선한다. [0.115.22 검증과 비교판](../evidence/epic-finale-route-profiles-20261121/README.md)

## 공식 사례에서 가져온 기준

- Diablo IV의 Scosglen은 해안에 닿기 전부터 방향성 있는 풀로 바람을 전달한다. TLT의 야간 북쪽 출구에서는 낮은 셰일층과 바람그늘에 고인 눈의 단차로 다음 지역의 기후를 예고한다. [Blizzard 환경 아트](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- World of Warcraft의 Ringing Deeps는 기계 정비와 광차 이동을 지역 활동에 연결한다. TLT의 적재장, 썰매 정지턱, 선적대에서는 화물의 접촉면과 운송 방향이 조형으로 이어지게 한다. [Blizzard 지역·던전 소개](https://news.blizzard.com/en-us/article/24125258/explore-the-zones-and-dungeons-of-the-war-within)
- Lost Ark의 Elgacia 제작진은 거대 석상과 움직이는 지형을 여러 카메라 각도로 시험해 장면의 방향을 정했다. TLT에서는 조사점에서 보는 정면과 귀환 중 옆으로 스치는 화면을 모두 비교한다. [Lost Ark Elgacia 개발자 인터뷰](https://www.playlostark.com/en-gb/news/articles/elgacia-lore-interview-with-gold-river)
- Roblox의 World // Zero는 서로 다른 지형의 월드에서 퀘스트와 탐험을 제공한다. TLT도 다음 지역에서 만나는 물성과 생활 시설을 경계에서 미리 보여 준다. Roblox 환경 아트 가이드의 바닥 재질과 방향 인지 사례를 지형 이음부에 적용한다. [World // Zero 공식 Experience](https://www.roblox.com/games/2727067538/World-Zero-Anime-RPG) · [Roblox 환경 아트 가이드](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/construct-your-world)

## 지역별 제작표

사건과 진행 순서는 [본편 스토리 검토](../production/campaign-context-review-2026-11-10.md)의 에픽별 7장 행을 따른다. [기존 7장 조형 모듈](../../src/server/World/EpicFinaleScenery.luau)의 Roblox 원생 형상과 지역 팔레트를 파생한다. 원본 Git blob은 `76c43046afdce1246f78e663222a69faae12bee1`이다. 조사 위치, 기존 지물 피벗과 진행 상태는 공통 입력이다.

| 스토리와 장면 | 조형 지시 | 비교 장면 |
| --- | --- | --- |
| DW-07 · 서로 다른 화물 표식과 Gloamwood행 문서를 확인하고 Eryn에게 보고한다. | 흙 경사와 나란한 바퀴홈이 두 고임장치에 닿는 면을 연결한다. 흙, 눌린 홈, 목재와 철의 순서가 보여야 운송 기록 주변이 실제 적재장으로 읽힌다. | 사면에서 기록으로 접근할 때와 조사점을 등지고 돌아올 때 두 바퀴홈의 끝을 비교한다. |
| GW-07 · Widow Queen 이후 Tali가 확인한 길로 Frozen Vale에 향한다. | 야간 사선에서도 낮은 셰일의 밝은 층과 어두운 절리가 따로 보이게 모서리를 드러낸다. 상부 눈은 바람그늘 쪽에 모아 방향감을 준다. | 북쪽 출구 접근과 귀환에서 눈과 하층이 한 덩어리로 뭉치는지 본다. |
| FV-07 · 마지막 거울을 복구하고 폭풍이 잦아들면 Ivo와 두 마을이 재회한다. | 압설에 남은 화물 썰매의 두 러너 흔적을 정지판과 목재 고임턱으로 잇는다. 미세한 나사보다 정지장치의 단면과 재료 경계에 무게를 둔다. | 먼 설경에서는 두 고임점의 간격, 근경에서는 러너와 정지면의 접점을 비교한다. |
| EC-07 · Suri와 빈 운반대 및 출하 문서를 보고 심장이 이미 떠났음을 확인한다. | 현무암 받침, 철제 롤러, 진입 접촉면이 빈 운반 경로로 이어지게 한다. 두 롤러 열 사이를 비워 출하가 끝난 설비의 기능을 드러낸다. | Suri 양옆과 접근에서 롤러와 경사면이 한 설비로 보이는지 본다. 인물 바로 뒤 시점도 기록한다. |
| HG-07 · 잔여 잠금을 정리하고 문을 닫은 뒤 왕좌를 복원한다. | 귀환 보호턱의 낮아지는 석재 단부와 철제 버팀이 물리는 단면을 드러낸다. 차가운 석축과 무광 철을 써서 오래된 벽과 보강 부재를 구분한다. | 문 조사 전 접근과 조사 뒤 귀환 사선에서 받침, 버팀, 끝돌의 관계를 비교한다. |

다섯 모델은 공용 정적 배경이다. 조사 전후에 같은 형태를 사용하며 지역 문, 폭풍, 왕좌와 개인 귀환의 상태 전환은 [제품 계약](../product-contracts.md)의 기존 동작이 맡는다. 카메라 각을 고정해 두 빌드에 적용하고, 조사 위치와 지물 외곽, 바닥 접지 및 접근·귀환 도달을 대조한다. 환경 아트와 QA는 실제 입력으로 야간에 처음 보이는 시점과 인물 곁을 통과할 때의 가림을 확인한다.
