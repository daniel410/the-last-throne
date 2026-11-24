# 영웅 직선 공격의 준비와 명중

2026-11-23 · TLT-033/057/059 · 로컬 기준 0.115.63 · PC와 터치 전투 카메라

기준 빌드의 네 직선 공격은 서버 확정 방향과 실제 피해 지점을 전달한다. Vanguard Strike에는 전용 검격이 있었고, Braced Throw와 Piercing Line은 공통 물리 명중, Lightning Line은 공통 번개 명중을 사용했다. 기존 감속·자세 붕괴·표식 연출을 검토하고, 이번에는 공격 방법을 구분하는 피격 실루엣과 회수 동작을 선정했다.

| 공식 자료와 관찰 | TLT 적용 |
| --- | --- |
| Diablo IV의 2021년 12월 개발 업데이트는 공격 애니메이션, 피해 구역과 타격 방향을 연결하고 적 예고와 상태의 가독성을 우선한다고 설명한다. [Blizzard 개발자 업데이트](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 발동 경로의 방향을 이미 전달하는 서버 피해 이벤트에서 명중 획을 그린다. 화면을 덮는 섬광과 별개의 피해 이벤트를 추가할 필요가 없다. |
| World of Warcraft Retail의 Legion 7.3은 주문 시작부터 발사까지의 일관된 타이밍과 시전자의 준비 자세를 함께 다듬었다. [Blizzard 애니메이션 업데이트](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) | Lightning Line의 지팡이와 유도 손에 고유한 준비 자세를 주고 번개를 낸 직후 팔과 앞다리로 제동한다. |
| Lost Ark 글로벌의 2023년 8월 Wield the Storm은 Sharpshooter Charged Shot의 효과를 갱신하고, Deadeye Aimed Shot에서 허리를 펴는 자세를 별도로 조정했다. 글로벌 Gunner 소개는 Charged Shot의 충전을 활 기술의 특징으로 소개한다. [업데이트 노트](https://www.playlostark.com/en-us/news/articles/august-2023-wield-the-storm-release-notes) · [Gunner 소개](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) | Piercing Line은 활 방향을 유지한 채 시선을 길게 두고 시위를 놓는 팔을 직선으로 당긴다. Braced Throw는 빈손으로 도끼 무게를 받치고 투척 뒤 앞다리에서 받아낸다. |
| Roblox Creator Hub는 Beam의 부착점, 곡률, 폭을 제어할 수 있다고 설명하고 그래픽 품질별 확인을 권장한다. [Beam 가이드](https://create.roblox.com/docs/effects/beams) · [렌더링 성능](https://create.roblox.com/docs/performance-optimization/improve) | 기술마다 네 선분의 Beam 두 개로 타격을 표현한다. 타격 예산이 소진되면 기존 피해 표시를 사용한다. |

공식 개발 문서와 출시 노트의 관찰이다. TLT에서는 같은 R15 카메라의 전후 프레임, R6/R15 자세, 두 타격 방향과 소유자·아군 렌더링을 확인한다. 출시 QA는 일반 카메라로 네 명이 싸울 때 적 예고와 피해 숫자를 읽을 수 있는지, 터치 실기기에서도 네 공격의 차이가 보이는지 확인한다.
