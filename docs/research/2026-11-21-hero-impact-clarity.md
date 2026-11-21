# 영웅별 명중 형태와 파티 전투 가독성

TLT-033/057/059 · 2026-11-21 확인 · PC·패드·터치, 1~4인 전투

기준 0.115.14에는 128개 기술의 연출과 서버 확정 명중 이벤트가 연결돼 있다. Shield Breaker와 Shield Verdict는 비슷한 접점 효과를 쓰고, Mountain Strike, Pinning Shot, Shatter Dart는 발동 실루엣에 비해 명중 순간에 일반 무기나 원소 효과에 가깝게 보인다. 아군 모드에서도 발동 이벤트의 범용 구체가 실제 피해 이벤트의 명중 표현과 겹친다. [이전 명중 방향 검증](../evidence/hero-contact-direction-20261121/README.md)

| 공식 자료와 범위 | 관찰 | TLT 적용 |
| --- | --- | --- |
| Diablo IV 개발자 업데이트, 2021-12 | 타격 영역과 공격 동작을 연결하고, 적 예고와 강한 공격의 시각적 우선순위를 조절한다. [Blizzard](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 동일한 피해 신호에서 방패는 대각선으로 벌어지고, 강타는 아래로 접히는 두 획을 그린다. 준비와 제동 자세는 제작된 무기 접촉 시점을 기준으로 보정한다. |
| WoW Retail The War Within 11.2 | Spell Density의 Reduced와 Essential은 전투 정보 전달에 필요하지 않은 효과를 줄인다. [Ghosts of K’aresh 업데이트](https://worldofwarcraft.blizzard.com/en-gb/news/24226698) | 기존 아군 간소화 경로에서 범위·궤적·확정 명중은 유지하고, 겹쳐 나오는 범용 섬광을 줄인다. |
| Lost Ark 글로벌 공식 소개와 2022-03 업데이트 | Artillerist의 폭발과 Sharpshooter의 활은 서로 다른 전달 방식으로 표현된다. Battle Effects Display에는 파티 효과 표시 구성이 있다. [Gunner 소개](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) · [Battle Effects Display 수정 기록](https://www.playlostark.com/en-gb/news/articles/march-3-2022-update) | Pinning Shot은 짧은 몸 반동 뒤 한 점에 모이는 화살촉, Shatter Dart는 좁게 모아 시전한 뒤 위로 갈라지는 얼음 조각으로 표현한다. |
| Roblox Creator Hub | 겹친 투명 표면은 같은 픽셀을 반복해서 그리게 하고, 기기별 성능은 해당 기기에서 측정한다. [렌더링 비용](https://create.roblox.com/docs/performance-optimization/improve) · [실기기 측정](https://create.roblox.com/docs/performance-optimization/test-on-hardware) | 아군 발동 효과의 공통 구체 수, 적 예고 선분, 피해 숫자를 같은 겹침 장면에서 비교한다. |

공식 업데이트와 클래스 소개를 비교했다. 유지할 전투 계약은 서버 피해·범위·펄스와 상태이상 판정이다. 이번에는 기존 네 기술의 자세와 확정 명중에 집중했다. 아군의 기본 형상이 렌더링 예산으로 생략될 때는 간단한 발동 효과가 돌아오게 했다. Studio에서는 동일 방향의 접점, 로컬/아군 두 가지 보기와 4인 모의 겹침을 확인하고, 해석 가능성과 프레임 시간은 게시된 클라이언트와 실기기에서 별도로 평가한다.
