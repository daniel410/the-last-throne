# 영웅 스킬의 감속 표현

2026-11-23 확인 · TLT-033/057/059 · Roblox PC·터치, 솔로·협동

0.115.60에서 타격과 자세 붕괴는 각각 식별할 수 있었다. 반면 Sweeping Break, Low Sweep, Vine Trap, Tidal Ring으로 감속된 적은 Gravity와 같은 보라색 전신 강조 효과를 받았다. 시전 순간의 무기와 원소가 맞은 뒤에도 식별되는지, 적의 얼굴과 예고를 읽을 수 있는지 검토했다.

| 공식 자료의 관찰 | TLT 적용 |
| --- | --- |
| Diablo IV의 2021년 12월 개발자 업데이트는 적 예고·피해 영역·캐릭터 상태의 화면 우선순위를 다루고, 무기 움직임에 맞춘 판정과 방향성 있는 피격을 설명한다. [Blizzard VFX 개발 글](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 넓은 전신 채색 대신 맞은 적의 하체에서 작은 획이 나타나도록 한다. 기존 근접 타격 방향과 위험 예고를 사용한다. |
| WoW Retail Legion 7.3 개발 글에서 주문 준비는 지면이나 공중에서 힘을 모으는 진행형 자세를 사용한다. Frost Mage의 시전 효과는 다른 직업의 냉기 표현과 구별된다. [Blizzard 시전 애니메이션 개발 글](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) | Tidal Ring은 빈손으로 물을 모아 옆으로 풀고, Vine Trap은 높은 낙사 계열과 다른 낮은 자세에서 손을 내린다. 준비와 회수는 기존 발사·판정 시각에 맞춘다. |
| Lost Ark 글로벌 Destroyer 소개(2022년 5월)의 Earth Eater는 수평 휘두름에 돌이 따라붙는다. Aeromancer 소개(2023년 8월)는 Whirlpool의 회전과 Thick Fog의 일시적인 이동 속도 저하를 서로 다른 동작과 효과로 설명한다. [Destroyer 소개](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-destroyer-class) · [Aeromancer 소개](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-aeromancer) | Low Sweep은 낮게 휘두른 뒤 팔꿈치를 당겨 도끼의 무게를 받아낸다. 감속된 적의 흙 파편은 각을 주고 물결은 낮고 길게 그린다. TLT의 기존 기절·감속 규칙을 적용한다. |
| Roblox Beam은 두 Attachment 방향과 제어점으로 곡선을 만든다. Roblox의 하드웨어 시험 가이드는 모바일 기기에서 프레임 시간과 열 영향을 직접 측정하도록 안내한다. [Roblox Beams](https://create.roblox.com/docs/effects/beams) · [실기기 시험](https://create.roblox.com/docs/performance-optimization/test-on-hardware) | 적 한 개의 감속에 5선분 곡선 두 개를 사용한다. 95스터드 밖에서는 생성하지 않고, 같은 유형이 갱신되면 부착점을 재사용한다. 전신 효과와 하체 효과의 가독성은 같은 Studio 카메라에서 비교한다. |

공식 개발 글과 기술 설명을 바탕으로 한 TLT 적용 판단이다. 최소 시험은 기존 피해·감속 지속 시간과 면역, 중복·갱신·만료를 확인하고, 같은 리그에서 타격 뒤 자세와 감속 실루엣을 비교하는 것이다. 전투 QA는 실제 4인에서 예고와 상태를 읽을 수 있는지 관찰하고 저사양 터치 프레임 시간을 측정한다.
