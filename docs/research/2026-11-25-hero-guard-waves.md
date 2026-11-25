# 금빛 검격과 보호 기술의 공격 연출

2026-11-25 · TLT-033/057/059 · ART·ENG·QA

기준 빌드 0.115.121의 네 기술을 PC 전투 카메라와 1~4인 화면 합성 조건으로 검토했다. Radiant Sweep에는 높이가 일정한 금빛 호, 별도 검호와 바닥선이 겹쳤다. Tremor Guard에는 도끼를 내리치는 자세가 있지만 공통 지면 조각이 충격의 출발점을 가렸다. Warden Arrow의 공통 압력선과 잎은 서버 엄폐 경로와 시위의 시각적 연결이 약했다. Searing Ward에는 바닥 원, 높은 화염과 투명 돔이 함께 표시되어 공격과 보호의 구별이 어려웠다. [기존 보호막 부여 연구](2026-11-23-hero-shield-grant.md) · [이전 네 영웅 무기 방출 비교](2026-11-25-hero-weapon-releases.md)

## 공식 자료와 적용

| 사례 | 확인한 원리 | TLT 적용 |
| --- | --- | --- |
| Diablo IV 개발자 업데이트 · 2021-12 | 공격 방향, 무기 경로와 명중을 맞추고 큰 피해의 예고를 우선한다. | Radiant Sweep은 전방 부채 안에서 한 검격의 높이와 진행을 보여 준다. Tremor Guard는 먼저 도끼가 찍힌 쪽을 밝히고 짧은 지면 균열을 바깥으로 보낸다. [Blizzard](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) |
| WoW Retail · Legion 7.3 및 The War Within 11.2 | 시전 자세의 도달 시점을 맞추고 준비 중에 마법을 모으는 동작을 쓴다. 11.2 Spell Density는 판단에 필요한 효과를 살려 교전 가독성을 높인다. | Searing Ward는 손을 지팡이 쪽에 모은 뒤 바깥으로 쓸고 낮은 화염을 보낸다. 네 기술 모두 적 예고와 피해 숫자 위에 겹치는 보조광을 줄인다. [7.3](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) · [11.2](https://worldofwarcraft.blizzard.com/en-us/news/24226698/) |
| Lost Ark 글로벌 · Warrior·Gunner 소개(2021), Destroyer Academy(2022-05) | Paladin은 검 공격과 보호 오라에 서로 다른 표현을 쓴다. Destroyer는 내려치기 뒤 지면 충격을 보내며 별도의 보호 개념도 갖는다. Sharpshooter는 직선으로 진행하는 화살과 위에서 떨어지는 화살을 구별한다. | 공격 실루엣은 각각 금빛 검날, 바닥 충격, 시위부터 엄폐까지의 가는 화살 성분으로 구분한다. 보호막을 받은 영웅은 기존 서버 승인 메시지로 표시한다. [Warrior](https://www.playlostark.com/en-us/news/articles/warrior-advanced-classes) · [Destroyer](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-destroyer-class) · [Gunner](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) |
| Roblox Creator Hub · 하드웨어 시험 | 화면 밀도와 대비는 가장 낮은 지원 기기에서, 프레임 시간은 실제 클라이언트에서 확인한다. | Studio에서 네 기술의 효과 개수와 붉은 예고선을 대조한다. 다음 QA에서 터치 실기기의 프레임 시간을 기록한다. [하드웨어 시험](https://create.roblox.com/docs/performance-optimization/test-on-hardware) |

공식 설명과 개발자 예시를 검토했다. 해당 게임의 직접 플레이·최신 시즌 밸런스 검증은 범위 밖이다. 전신 돔과 높은 화염을 추가로 겹치는 안은 배경의 표적과 적 예고를 가려 채택하지 않았다. 기존 각도·범위·내려치기 시점과 서버가 확인한 명중·표식·보호를 사용한다. 제작은 기존 R6·R15 자세와 Beam 예산을 재사용하며 타 게임 자산이나 이미지를 쓰지 않는다.

ART·QA 수용 조건은 동일 R15 장면의 준비·방출·회수 비교, Warden Arrow의 시위 앞 엄폐, 피격·보호막 표시, 효과 중첩 시 적 예고 보존이다. 낮은 화염과 지면 균열은 바닥 재질과 시점에 따라 대비가 달라질 수 있어 실제 전투에서 확인한다.
