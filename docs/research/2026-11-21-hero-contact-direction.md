# 영웅 스킬의 타격 방향과 회수 동작

TLT-033/057/059 · 2026-11-21 확인 · PC·패드·터치, 1~4인 전투

0.115.11의 시전·낙하·마지막 펄스·Gunner 연출을 검토했다. 영웅 128개 스킬은 이미 타격 형상을 갖췄다. 서버 피격 이벤트는 대개 공격자에서 적으로 향하는 벡터를 보냈다. 이 때문에 연쇄 번개의 두 번째 표적도 시전자 쪽에서 밀리는 듯 보였고, 귀환 도끼의 두 번째 타격은 나가는 방향으로 표시됐다. 낙하 기술도 수평 명중 위치와 일반 스킬의 보조 파편을 사용했다. 전직 활의 단발은 확정 발사 이벤트를 수신했지만 활시위 회수는 예상 시간에 시작했다. [이전 마무리 박자](../evidence/hero-skill-final-beat-20261120/README.md) · [Gunner 왼손 검증](../evidence/gunner-left-hand-payloads-20261120/README.md)

| 비교 사례 | 공식 자료의 관찰 | TLT 적용 |
| --- | --- | --- |
| Diablo IV 개발자 분기 업데이트, 2021-12 | 애니메이션과 타격 영역을 연결하고, 피격 파편과 적 반응에 타격 위치와 방향을 반영한다. 위험 예고에 시선 우선순위를 둔다. [Blizzard](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 연쇄는 직전 표적, 폭발은 착탄 중심, 귀환 도끼는 복귀 방향을 기준으로 한다. 낙하 타격은 상반신 위에서 시작하며 적이 공격을 준비하는 동안에는 몸 반응 폭을 줄인다. |
| World of Warcraft Retail Legion 7.3 전투 애니메이션 | 동작의 무게와 즉응성을 함께 다루고, Frost Mage의 절제되고 정확한 자세처럼 같은 원소에도 직업의 성격을 부여했다. [Blizzard](https://news.blizzard.com/en-us/article/20946579/patch-7-3-new-combat-animations-its-magic) | Frost Lance는 짧게 손을 거두고, 다단 Hailfall은 상대의 상체를 아래로 압박하는 얼음 조각으로 읽히게 한다. |
| Lost Ark 글로벌 Breaker 프리뷰, 2024-03 | Brawl King Stance는 콤보 마지막 타격에 별도 의미를 부여한다. Destroyer 소개에는 충전 시간이 있는 Perfect Swing과 즉시 사용하는 타격이 함께 제시된다. [Breaker](https://www.playlostark.com/en-us/news/articles/breaker-breakdown) · [Destroyer](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-destroyer-class) | Heavy Draw는 확정 발사 뒤 긴 체중 이동을, 빠른 사격은 짧은 반응을 사용한다. 제작된 8개 연속기의 마지막 타격은 적 반응과 접촉 크기에 강세를 준다. |
| Roblox Creator Hub 엔진 성능과 실기기 테스트 | 파티클·투명 장식의 밀도가 렌더링 비용에 영향을 주며, 저사양 단말 성능은 해당 기기에서 확인해야 한다. [렌더링 비용](https://create.roblox.com/docs/performance-optimization/improve) · [기기 테스트](https://create.roblox.com/docs/performance-optimization/test-on-hardware) | 낙하 명중에는 본인 최대 3개, 아군 최대 1개의 짧은 획을 쓴다. 이 획을 그린 경우 보조 명중 파편과 일반 스킬 잔광을 생략한다. |

공식 개발 글과 기술 설명을 검토했다. TLT에서는 중심점·진행 각·펄스를 이미 해결된 피해 이벤트에 실어 보내고 연출에만 사용한다. 산개 폭탄과 회전하는 선형 기술은 실제 타격의 중심과 방위를 사용한다. 스킬별 회수 동작은 이전 준비 자세와 무기 소켓을 기준으로 조정했다. 위치·각도·피격 크기를 Studio에서 검사하고, 적 예고가 겹치는 장면의 가독성과 프레임 시간은 게시 테스트와 실제 저사양 터치 기기에서 확인한다.
