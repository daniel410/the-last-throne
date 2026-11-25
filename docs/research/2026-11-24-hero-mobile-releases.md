# 네 영웅의 이동 공격과 방출

2026-11-24 (토론토) · TLT-033/057/059

기준 0.115.100의 이동 기술 네 개를 직전 [네 영웅 방출 개선](../evidence/hero-weighted-releases-20261124/README.md)과 [서버 이동 흔적 검증](../evidence/hero-step-wakes-20261123/README.md)에서 이어 검토했다. Radiant Charge의 두 타격은 같은 방패 형상이고 Gliding Shot은 무기 쪽 발사선만 보여, 공격 전에 이동이 있었는지 원거리에서 읽기 어려웠다. Blast Step은 발사구에서 바닥 압력파까지 시선이 끊기고, Ember Step은 출발지의 잔불이 중복 원형 장식에 묻혔다.

| 비교 자료 | 확인한 연출 원칙 | The Last Throne 적용 |
| --- | --- | --- |
| [Diablo IV 2021년 12월 개발자 글](https://news.blizzard.com/en-gb/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 시각 효과를 타격 방향에 정렬하고 위험 예고에 높은 우선순위를 부여한다. | 서버 방향의 포구와 전방 압력을 연결하고, 지면 장식의 수를 줄여 피해 경계가 보이도록 한다. |
| [World of Warcraft Retail Legion 7.3 개발자 글](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-7-3-new-combat-animations-it-s-magic) | 주문 준비에서 힘을 모으는 방향과 방출 팔의 궤적으로 직업과 주문 규모를 구별한다. | Ember Step의 지팡이를 가슴 쪽으로 접고 반대 손으로 출발지를 쓸어 올린다. Gliding Shot은 활 손의 조준을 유지하며 디딤발과 시위 팔의 회수로 힘을 표현한다. |
| [Lost Ark 글로벌 Warrior 직업 소개](https://www.playlostark.com/en-us/news/articles/warrior-advanced-classes) · [Gunner 직업 소개](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) | Paladin의 Flash Slash는 전진을 동반하며 Execution of Justice는 연속 공격에 마무리 타격을 둔다. Artillerist의 Buckshot에는 전방 부채꼴이 있고 Deadeye의 Death Fire는 뒤로 빠지는 동작을 포함한다. Sharpshooter는 화살마다 다른 기능과 발사 형태를 사용한다. | Radiant Charge의 낮은 첫 박자와 상승하는 두 번째 박자를 분리한다. Blast Step의 뒤로 미끄러지는 흔적과 전방 포격을 분리하고, Gliding Shot은 낮은 이동 흔적과 한 줄의 화살 방출을 쓴다. |
| [Roblox Beam](https://create.roblox.com/docs/reference/engine/classes/Beam) · [렌더링 성능 가이드](https://create.roblox.com/docs/performance-optimization/improve) | Beam의 끝점과 접선으로 짧은 곡선을 그릴 수 있다. 투명 표면과 입자가 겹치면 렌더링 비용이 커질 수 있다. | 기존 Beam·면 예산 안에 얇은 이동 흔적과 방출선을 넣는다. 아군은 핵심 윤곽만 사용하며 범용 원형 장식을 줄인다. |

이동 흔적의 끝점은 서버가 확인한 출발·도착 좌표로 제한한다. 실제 피해 경계는 기존 부채꼴과 원으로 표시한다. 화살은 기존 발사 원점 보정과 서버 패킷의 끝점을 사용한다. 최종 적용과 수용 범위는 [Studio 검증](../evidence/hero-mobile-releases-20261124/README.md)에 기록한다.
