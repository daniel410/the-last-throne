# 방패 강타와 도끼 절개의 타격 연출

2026-11-20 · TLT-005/033/057/084 · ART·ENG

[이전 연출 비교](../evidence/melee-impact-20261120/README.md)에서 기사 연격과 도끼 궤적을 구분했다. 이번 소스 검토에서 Shield Breaker와 Shield Verdict는 같은 방패 준비 자세와 고리형 효과를 사용했고, 좁은 Armor Splitter 궤적은 Crag Cleave와 비교해 옆쪽 변화가 작았다. 세 기술은 각각 높은 자세 피해, Oath 소모, Fracture 부여를 맡는다.

| 공식 자료에서 확인한 방식 | TLT 적용 판단 |
| --- | --- |
| Diablo IV 개발팀은 근접 무기 경로와 타격 연출을 시간축에서 맞추고, 피격 효과를 접촉 위치와 공격 방향에 맞춘다고 설명한다. 강한 시각 강조는 주요 기술에 배분한다. [2021년 12월 개발 업데이트](https://news.blizzard.com/en-gb/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 명중 지점에서만 방패 충격선과 도끼 절개가 갈라진다. 기술 발동 효과는 짧은 전방 파형과 검흔에 집중한다. |
| WoW의 Midnight Phalanx 소개에서 Shield Slam은 전방으로 힘의 파동을 내보낸다. Undermine(d)의 Warrior 변경에서는 새 Warbreaker 시각 효과에 맞춰 효과 중심을 전방에 배치했다. [Midnight Apex Talents](https://worldofwarcraft.blizzard.com/en-gb/news/24244472/) · [Undermine(d) 변경 기록](https://news.blizzard.com/en-gb/article/24179386/undermine-d-content-update-notes) | Shield Breaker에 수평 강철 파형과 전진하는 상체를 주고, Shield Verdict는 정면에서 들어 올리는 금빛 문장과 위로 퍼지는 피격선을 쓴다. |
| Lost Ark Destroyer의 Heavy Crush는 머리 위로 들어 내리찍으며, Earth Eater는 파편이 망치의 횡방향 움직임을 따라간다. [Destroyer Academy](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-destroyer-class) | Armor Splitter는 정수리 위에서 시작해 정면에서 좁게 떨어진다. 아래로 열린 절개와 타격 직후 몸통 하강으로 무게를 표현한다. |

공개 개발 설명과 기술 설명을 비교했다. 실제 게임의 프레임과 공격 판정을 계측하지 않았다. TLT 검토 기준은 같은 카메라에서 두 방패 기술의 주 형상을 구별할 수 있는지, 도끼 절개가 위에서 아래로 읽히는지, 기존 타격 경계에서 자세가 이어지는지다.
