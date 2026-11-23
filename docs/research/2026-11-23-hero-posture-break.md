# 자세 붕괴를 알리는 영웅 스킬 연출

2026-11-23 · TLT-033/057/059 · Roblox PC·터치, 솔로·협동

0.115.58은 기술별 명중과 표식 부여·소모, 이동 잔상을 표현한다. 몬스터가 자세를 잃으면 기존 상태 표시와 자세 모션은 바뀌지만, 해당 타격의 이펙트와 순간 반동은 일반 명중과 같다. 이번 비교에서는 파티원이 공격 기회가 열린 순간을 표적에서 바로 읽을 수 있는지 살폈다.

| 공식 자료에서 확인한 동작 | TLT 적용 판단 |
| --- | --- |
| Diablo IV BlizzCon 2019 소개에서 Ashava는 누적 Stagger가 임계점에 도달하면 팔날이 부서지고 회전 공격 범위가 줄어든다. [Blizzard 기능 소개](https://news.blizzard.com/en-gb/article/23189677/diablo-iv-feature-overview) | 붕괴를 일으킨 타격에 눈에 띄는 형태 변화를 준다. TLT의 기존 노출 시간과 몬스터 외형을 사용한다. |
| WoW Retail Legion 7.3의 개발자 글은 주문에 따라 준비 동작의 크기와 손 방향을 달리하고, 빠른 시전 입력에 맞춰 무게를 잡았다고 설명한다. [Blizzard 애니메이션 개발 글](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) | 방패를 거두는 동작, 도끼에 실리는 체중, 시위를 푼 팔꿈치, 돌을 밀어내는 빈손을 기존 타격 시간에 맞춘다. |
| Lost Ark 글로벌의 Guardian Raid 공식 안내에서는 Stagger 체크를 협동 전투의 별도 성공 조건으로 다룬다. 2022년 글로벌 Destroyer 소개에서 Heavy Crush는 해머를 크게 들었다가 아래로 내리며, Earth Eater는 해머를 수평으로 휘두르고 돌 조각이 무기를 따른다. [Guardian Raid 안내](https://www.playlostark.com/en-us/game/guide/guardian-raid-guide) · [Destroyer 소개](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-destroyer-class) | 도끼의 준비와 하중 전달을 관절로 보여 준다. 실제 자세 전환에만 맞춰 적 쪽에서 두 획을 벌려, 여러 영웅이 동시에 쳐도 결과를 한 번 읽게 한다. |
| Roblox Beam은 두 Attachment와 제어점으로 곡선을 그린다. Epic Games의 Niagara 공식 자료는 짧은 시간에 투사체와 충격 이펙트가 집중될 때 인스턴스 비용을 검토하도록 안내한다. [Roblox Beam](https://create.roblox.com/docs/reference/engine/classes/Beam) · [Epic Games 효과 확장성](https://dev.epicgames.com/documentation/en-us/unreal-engine/scalability-and-best-practices-for-niagara) | 기존 명중 예산에서 곡선 두 개를 공유한다. 타격이 표식도 부여하거나 소모하면 예산이 허용할 때 해당 두 획을 함께 표시한다. |

자료는 공식 개발 글과 가이드의 기술 설명으로 확인했다. 타격에 대한 주관적 체감은 TLT 플레이에서 판단한다. 화면 전체 플래시와 추가 정지는 주변 위험을 읽는 시간을 줄일 수 있어 보류했다. 최소 시험은 같은 영웅·적·조명의 일반 명중과 자세 붕괴 비교, 면역·후속타·동시 표식 검증이다. 협동 QA는 좁은 화면에서 적 예고와 자세 붕괴를 구분하는지 확인한다.
