# 방패 진입, 구르는 폭약, 강궁, 얼음 파쇄의 타격 연출

2026-11-24 (토론토) · TLT-033/057/059 · 기준 0.115.95

직전 교차 타격 검토는 두 공격의 방향과 무기 회수에 집중했다. 이번 검토에서는 Challenging Strike와 일반 수평 베기의 형태가 비슷하고, Rolling Charge와 Skipping Charge가 같은 낮은 방출 자세를 사용하는 점을 확인했다. Heavy Draw는 준비 시간이 길지만 방출 때 평소 화살의 표적 장식이 반복됐고, Shatter Dart는 짧은 결정이 어디서 날아왔는지 읽기 어려웠다. [직전 교차 타격과 도끼 회수 검증](../evidence/hero-crossed-releases-20261124/README.md)

| 공식 자료에서 확인한 내용 | TLT에 적용한 판단 |
| --- | --- |
| Diablo IV의 2021년 12월 개발 기록은 공격 모션과 범위를 맞추고 적중 효과가 공격 방향을 따르도록 설계한 사례를 설명한다. 전투 중 먼저 읽어야 할 정보에 시각 강도를 배분한다. [Diablo IV 전투 및 시각 효과](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 방패 뒤 준비와 하강 검격을 구분하고 맞은 면의 기존 반응에 연결한다. 하강 검격과 폭약 바닥 흔적은 열린 형상으로 그린다. |
| World of Warcraft Retail Legion 7.3 개발자 소개는 마법을 모으는 진행 동작, 큰 직선 팔 동작, 작은 손목 동작으로 시전을 구분한다. The War Within 11.2 기록에서는 Frostwyrm’s Fury의 동작과 시각 효과를 함께 갱신했다. [Legion 시전 애니메이션](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-7-3-new-combat-animations-it-s-magic) · [11.2 패치 노트](https://news.blizzard.com/en-us/article/24226698/ghosts-of-k-aresh-content-update-notes) | Shatter Dart는 빈손을 몸쪽으로 접었다 짧게 튕긴다. 짧은 얼음 결정의 속도감은 좁은 잔상과 높이가 다른 피격 파편으로 표현한다. |
| Lost Ark 글로벌 Gunner 소개(2021-08-24)의 Sharpshooter Charged Shot은 장전과 한 발의 결과를, Machinist 소개(2022-09-20)의 Overcharged Battery는 투척과 위치 폭발을 각각 기술한다. [Gunner 공식 소개](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) · [Machinist Academy](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-machinist) | Heavy Draw는 뒷발에 버티고 당기는 팔을 더 깊게 회수한다. Rolling Charge는 왼손을 낮춰 굴린 뒤 바닥 흔적에서 짧은 폭발로 전환한다. 피해와 폭발 시각·중심은 현행 서버 이벤트를 사용한다. |
| Roblox Beam은 부착점과 굵기로 궤적을 정의한다. Creator Hub는 저사양 기준 기기의 프레임과 메모리를 따로 확인하도록 안내한다. [Beam](https://create.roblox.com/docs/reference/engine/classes/Beam) · [기기 성능 지침](https://create.roblox.com/docs/performance-optimization/test-on-hardware) | 아군 화면은 얇은 궤적과 낮은 폭발 중심을 우선한다. 같은 장면에서 근접 엄폐, 폭발 위치, 적 예고와의 겹침을 확인하고 실제 프레임 시간은 터치 기기에서 측정한다. |

공식 문서와 개발자 설명을 2026-11-24에 확인했다. 이 비교는 문서 조사이며 외부 게임 플레이 측정은 포함하지 않는다. 기존 네 영웅 중 하나씩 선택해 준비·방출·확정 명중의 식별 비용을 낮추는 데 범위를 뒀다.
