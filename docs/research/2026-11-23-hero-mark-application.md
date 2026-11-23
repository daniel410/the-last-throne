# 표식 부여 공격의 자세와 명중

2026-11-23 · TLT-033/057/059 · PC와 터치, 1~4인 전투

TLT 0.115.56에서는 표식 소모 효과가 두 획으로 벌어진다. 적용 기술 8개의 명중 효과는 일반 타격과 같으며, 일부 시전 효과는 실제 표적의 생존과 관계없이 나온다. 플레이어가 후속기 전에 어떤 적에게 표식이 붙었는지 읽을 수 있도록, 명중에 대응하는 짧은 시각 신호를 추가한다.

| 공식 자료 | 관찰과 적용 |
| --- | --- |
| Diablo IV 개발자 업데이트, 2021-12 | 개발팀은 무기나 주문이 닿는 방향에 맞춰 명중 효과를 배치하고 겹치는 전투에서 신호의 우선순위를 설계했다. TLT에서는 서버 명중 방향의 앞면에 표식 획을 배치한다. [Blizzard](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) |
| World of Warcraft Retail Legion 7.3, 2017-08 | 개발팀은 준비 자세에 주문이 모이는 동작을 넣고 강한 주문과 빠른 주문의 팔 동작을 구분했다. Ember Lance는 보조 손으로 불씨를 모아 내밀고, 기존 시전 시간과 지팡이 발사점을 사용한다. [Blizzard](https://wow-site-bwa-production-eks-prod-use1-01.worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) |
| Lost Ark 글로벌 Wield the Storm, 2023-08 | Deadeye의 자세별 명중과 근거리 산탄 명중, Sharpshooter의 Charged Shot 효과를 따로 다듬었다. TLT는 갑옷 균열과 정밀 조준 표식을 별개 형태로 표현하고, 기사와 마법사에도 고유한 명중 형태를 부여한다. [공식 패치 노트](https://www.playlostark.com/en-us/news/articles/august-2023-wield-the-storm-release-notes) |
| Roblox Creator Hub, 2026-11-23 확인 | 파티클과 투명 면은 겹칠수록 렌더 비용을 높인다. 기존 클라이언트 효과 예산 안에서 짧은 Beam 두 개를 사용하고, 표시가 되면 범용 명중 섬광을 생략한다. [렌더링 성능 문서](https://create.roblox.com/docs/performance-optimization/improve) |

공식 문서에 설명된 사례를 비교했다. 적용 신호는 모이고 소모 신호는 퍼지는 방향을 채택한다. 지속 표식 UI를 추가하면 표적별 소유와 만료를 표현하는 별도 인터페이스가 필요하므로 이번에는 확정 타격 순간만 다룬다. 8개 기술의 본인·아군 효과, 피해 숫자, 사망·무피해 표적과 인접 생존 표적을 확인한다. 실전 수용은 4인 전투에서 적 예고가 보이고, 표식 적용과 소모를 각각 알아볼 수 있는지에 달려 있다.
