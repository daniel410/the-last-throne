# 찌르기·착지·관통 공격의 타격 연출 조사

2026-11-25 · TLT-033/057/059 · RES·ART·ENG·QA

0.115.125의 R15 준비·방출·회수 화면을 기준으로 네 영웅의 공격을 비교했다. Vanguard Strike에는 평행 압력선과 표면이 겹쳤다. Stonebound Leap에서는 범용 원과 돌조각이 착지점 주변의 큰 공간을 차지했다. Piercing Line에는 화살 궤적 위로 끝점 근처 압력선과 화살촉 효과가 겹쳤다. Stone Lance에는 지팡이 쪽 광선과 표적 부근의 돌창이 한꺼번에 나타났다.

| 공식 자료 | 사례에서 확인한 원리 | TLT에 반영한 방식 |
| --- | --- | --- |
| Diablo IV · 2021-12 전투 개발자 업데이트 | 무기 경로와 명중 시각·방향을 맞추고 전투 판단에 중요한 적 예고를 우선한다. | 검끝·시위·빈손에서 시작한 세 공격을 서버가 보낸 끝점까지 한 축으로 읽히게 한다. 착지 충격은 서버가 확정한 중심에서 바깥으로 퍼진다. [Blizzard](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) |
| World of Warcraft Retail · Legion 7.3, The War Within 11.2 | 시전 준비는 마법을 모으는 몸짓으로 표시한다. Spell Density는 전투 판단에 필요한 효과를 우선한다. | Stone Lance에서 빈손에 모으고 뻗는 준비·방출을 분리한다. 파티 시점은 주요 궤적과 균열을 읽을 수 있도록 석편과 발광층을 줄인다. [Legion 애니메이션](https://news.blizzard.com/en-us/article/20946579/patch-7-3-new-combat-animations-its-magic) · [11.2 패치 설명](https://news.blizzard.com/en-us/article/24226698/ghosts-of-k-aresh-content-update-notes) |
| Lost Ark 글로벌 · 2021 Sharpshooter, 2022 Glaivier·Destroyer | Sharpshooter는 직선 화살과 위에서 떨어지는 화살비를 구별한다. Glaivier의 Thrust of Destruction은 무기에 모은 힘을 전방으로 보낸다. Destroyer의 Jumping Smash는 도약 뒤 지면에 충돌한다. | Piercing Line은 활의 노크에서 단일 화살을 방출하고 시위 손을 회수한다. Vanguard Strike는 검을 거두는 박자를 주고 Stonebound Leap은 무릎으로 충격을 받은 뒤 낮은 균열을 펼친다. [Sharpshooter](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) · [Glaivier](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-glaivier) · [Destroyer](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-destroyer-class) |
| Roblox Creator Hub · 하드웨어 시험 | 실기기에서 가독성·프레임 시간·메모리를 확인한다. | 같은 Studio 장면에서 효과 개수와 적 예고를 비교한다. 실제 터치 기기 계측은 별도로 확인해야 한다. [하드웨어 시험](https://create.roblox.com/docs/performance-optimization/test-on-hardware) |

공식 개발자 글과 클래스 설명을 바탕으로 TLT 적용을 도출했다. 타 게임의 자산을 사용하지 않았으며 직접 플레이 비교는 수행하지 않았다. 세 선형 효과는 서버가 전달한 끝점으로 점차 수축한다. 장비 소켓이 엄폐 끝점보다 앞서 있으면 서버의 공격 원점을 사용한다. Stonebound Leap은 범위를 나타내는 기존 외곽선과 착지에서 퍼지는 균열을 함께 표시한다.

[고정 빌드와 전후 화면](../evidence/hero-forward-impact-20261125/README.md)
