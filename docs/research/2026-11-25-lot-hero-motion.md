# League of Throne 영웅 모션 참고

2026-11-25 · TLT-033/057/059 · Research → ART·ENG

League of Throne 로컬 소스 0.21.6의 `game/shared/Motion.luau`, `assets/models/runtime/SkillMotion.luau`, `Factory.luau`와 실제 런타임 클립을 확인했다. 클립의 프레임별 월드 회전과 골반 높이를 비교했다. LoT는 준비 중인 원거리 동작을 서버 발사 신호까지 유지하고, 무기와 스킬 슬롯에 따라 준비·방출 자세를 선택한다. 아래 회전 시점은 원본 클립에서 가장 큰 프레임 간 회전이 발생한 위치다.

| LoT 원본 | 관찰 | TLT 적용 |
| --- | --- | --- |
| Swordsman `Right_Hand_Sword_Slash`, Lancer `Thrust_Slash`, Shieldbearer `Shield_Push_Left` | 검격은 23구간 중 7에서 골반, 8에서 어깨 회전이 가장 크다. 찌르기는 45구간 중 10에서 골반, 21에서 무기 팔이 먼저 뻗는 구간을 보인다. 방패 밀기는 36구간 중 17에서 방패 팔, 19에서 골반 변화가 가장 크다. | 방패는 준비를 길게 모은 뒤 빠르게 회수한다. 검격은 골반과 어깨에 시차를 두고, 2타째의 지지 다리를 좌우로 바꾼다. |
| Axe `Charged_Axe_Chop`, Grenadier `Crouch_Pull_and_Throw`, 공용 `Charged_Ground_Slam` | 도끼는 115구간 중 49에서 골반, 66에서 도끼 팔이 크게 움직인다. 지면 강타는 내려찍는 구간에서 몸이 낮아진다. | 도끼 후속타와 강타에서 체중을 늦게 싣고, 충격을 받는 시간을 검격보다 길게 둔다. 투척도 낮게 모았다가 펴는 리듬을 적용한다. |
| Archer `Draw_and_Shoot_from_Back`, 공용 `Archery_Shot_2` | 기본 공격은 화살을 집는 팔 동작이 먼저 나오고 이후 어깨와 몸통이 조준으로 이어진다. 연사 클립은 몸통 변화가 작다. | 화살통에서 꺼내는 구간을 확보하고 뒷다리로 당긴 뒤 놓는 순간 앞다리로 받는다. 발사 확인이 늦어도 시위·다리·곡사 조준 각도를 함께 유지한다. |
| Arcanist `Charged_Spell_Cast_1`, Geomancer `mage_soell_cast_5` | Arcanist는 65구간 중 15에서 지팡이 팔, 29에서 반대 팔의 회전 변화가 가장 크다. | 지팡이가 먼저 움직이고 빈손이 따라가도록 분리한다. 지면 주문은 무릎을 접고 늦게 모으며 기본 지팡이 타격은 빈손을 접으며 회수한다. |
| 공용 `Cowboy_Quick_Draw_Shooting`, Mortar `Walk_Forward_While_Shooting` | 빠른 사격에는 팔꿈치의 짧은 반동이 있고 포격은 큰 팔 회전보다 버티는 자세가 두드러진다. | 총탄은 짧게 튀고 포격은 다리로 받는 시간을 늘린다. |

- Diablo IV 개발자 글은 무기 궤적과 피해 영역을 같은 시간축에서 조정한다. TLT는 준비와 회수의 가중치만 조정하고 접촉 경계에서 연속성을 검사한다. [Blizzard](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021)
- World of Warcraft Legion 7.3은 가볍게 튕기는 즉시 시전과 모아서 직선으로 밀어내는 무거운 시전을 구분한다. TLT는 지면 주문에 늦게 모으는 자세를 적용한다. [Blizzard](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic)
- Lost Ark의 Glaivier와 Destroyer 소개는 연속 베기의 박자와 도약 이후 내려찍는 단계가 구별되는 사례다. TLT는 각 기본 연격과 지면 강타에 서로 다른 지지 자세를 사용한다. [Glaivier](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-glaivier) · [Destroyer](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-destroyer-class)

TLT의 기존 리그와 소켓으로 해석했다. 공통 모션과 스킬별 고유 동작은 R6·R15의 샘플링 경로에서 검증했다. [구현과 검증](../evidence/hero-lot-motion-20261125/README.md)
