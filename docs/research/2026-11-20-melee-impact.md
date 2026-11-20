# 기사·드워프의 기술별 타격 박자

2026-11-20 · TLT-005/033/057/084 · ART·ENG

[기존 64기술 자세표와 Studio Play](../evidence/melee-actions-20261116/README.md)와 [전투 VFX 격차 리뷰](../evidence/rpg-vfx-gap-20261116/README.md)를 출발점으로 삼았다. 현재 코드를 대조한 결과 Oathblade와 Oathbound Assault는 매번 같은 검 곡선으로 돌아갔고, Sunward Cross는 각 타격에 두 검흔을 동시에 그렸다. 드워프의 Cleave 계열은 폭과 밝기가 달라도 같은 수직 중심선을 사용했다. 같은 총기 계열에서는 연사와 단발의 반동 감쇠가 비슷했다.

| 공식 자료에서 확인한 방식 | TLT 적용 판단 |
| --- | --- |
| Diablo IV 개발 업데이트는 무기 궤적과 피해 영역을 시간 축에서 맞추고 타격 방향에 맞게 반응을 배치하는 사례를 설명한다. [Blizzard 2021년 12월 개발 업데이트](https://news.blizzard.com/en-gb/article/23746639/diablo-iv-quarterly-updatedecember-2021) | Sunward Cross는 확정 타격마다 하나의 검호를 내고, 하강과 상승을 이어서 교차가 만들어지게 한다. |
| WoW의 Colossus 소개는 Shield Slam과 연속 강타 Demolish의 역할을 구분한다. 7.3 애니메이션 인터뷰에서는 짧은 시전 시간 안에서 준비를 읽히게 하는 접근을 설명한다. [Colossus 소개](https://worldofwarcraft.blizzard.com/en-us/news/24056988/get-an-early-look-at-eight-new-hero-talent-trees) · [7.3 애니메이션 인터뷰](https://news.blizzard.com/en-us/article/20946579/patch-7-3-new-combat-animations-its-magic) | Shield Breaker와 Shield Verdict는 방패를 당기고 상체를 싣는다. 성기사 연격은 정면 접촉으로 이어지는 서로 다른 회수 자세를 사용한다. |
| Lost Ark Destroyer는 Heavy Crush의 머리 위 준비, Jumping Smash의 도약 후 하강, Power Shoulder의 낮은 돌진을 각각 기술한다. [Destroyer Academy](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-destroyer-class) | Iron Axe는 좁게 가르는 도끼날과 옆으로 흐르는 도끼날을 구별한다. 착지 강타는 타격 뒤 무릎과 몸통으로 무게를 받는다. |
| Roblox는 움직이는 검의 경로를 보여주는 Trail과 폭·곡률·투명도를 조절하는 Beam을 제공한다. [Creator Hub Effects](https://create.roblox.com/docs/effects) | 기존 모델의 무기 Trail과 시간 기반 Beam을 재사용한다. Sunward Cross의 주날과 옅은 면은 같은 곡선을 사용한다. |

확인일은 2026-11-20이다. 공개 개발 자료와 기술 설명으로 동작 순서와 효과의 의도를 비교했다. TLT에 적용한 반동·곡선·체중 이동은 기존 리그에서 조정한 값이다. 준비 자세의 확대는 손·무기 소켓과 접촉 시각에서 회귀를 유발할 수 있으므로 접촉 양쪽의 연속성, 전방 조준, 복귀와 이펙트 회수를 함께 검사한다.
