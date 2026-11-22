# 겹치는 타격의 피격 자세와 네 기술의 명중 형상

TLT-033/057/059 · 2026-11-21 (EST) · 기준 0.115.40

기존 발사축, 지연된 활시위, 파티 VFX 우선순위를 확인했다. `K0EnemyHitReaction`은 훨씬 약한 후속타를 잠시 무시하지만 비슷한 충격은 피격 상승 구간을 매번 다시 시작한다. 여러 공격이 같은 적에게 3~25ms 간격으로 몰리면 처음 타격의 정점과 방향이 희석된다. 이번 후보는 먼저 시작한 동작의 정점을 보여 주고, 눈에 띄게 강한 후속타는 일찍 전환한다. 이 시간에도 각 확정 타격의 피해 숫자와 명중 연출은 각각 표시한다.

| 공식 사례 | 관찰과 적용 |
| --- | --- |
| Diablo IV · 2021년 12월 개발자 업데이트 | 피해 방향과 VFX를 공격 애니메이션의 접점에 맞추고 적 예고의 가독성을 우선한다. TLT에서는 기사 내리찍기의 하향 압력과 드워프 총탄의 전방 관통을 서버가 확정한 방향에서 구분했다. [Blizzard 개발자 업데이트](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) |
| World of Warcraft Retail · The War Within 11.2 | Frostscythe의 전방 휘두름에 동작과 VFX를 함께 갱신했다. 같은 업데이트의 Spell Density는 전투 판단에 덜 필요한 시각 효과를 줄였다. TLT는 네 명중의 실루엣을 각각 두 획으로 만들고 중복 구형 섬광과 보조 입자를 생략한다. Glacial Spike 시전자 화면에는 짧은 얼음 면을 더했다. [Blizzard 업데이트 노트](https://news.blizzard.com/en-us/article/24226698/ghosts-of-k-aresh-content-update-notes) |
| Lost Ark 글로벌 · Machinist와 Destroyer | Strategic Fire는 몸을 낮춰 전방 사격을 버티며, Destroyer의 Vortex Gravity는 망치의 하강과 이어지는 폭발·표적 반응을 분리한다. TLT는 Piercing Round의 반동을 다리로 받게 하고 Oathbreaker Strike에서 검이 닿는 순간 뒤의 무게 이동을 강조했다. [Machinist](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-machinist) · [Destroyer](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-destroyer-class) |
| Roblox Creator Hub | Studio와 하드웨어의 프레임 시간과 네트워크 조건을 구분한다. 두 Beam 예산과 피격 자세는 Studio에서 고정 조건으로 비교하고 실제 전투의 프레임 시간은 실기기 시험에 남긴다. [실기기 검증](https://create.roblox.com/docs/performance-optimization/test-on-hardware) |

Elemental Pierce의 교차 광선은 같은 진행축 안에서 마법 활의 성격을 보여 주며, Glacial Spike는 지팡이 옆 손을 들어 올리는 동작과 솟는 파편을 연결한다. 형상은 각 판정이 확정됐을 때 출력하며 대상의 피해 결과를 표현한다. 기존 적 준비·공격 중 보정과 보스 감쇠를 적용한다. [시험 및 비교](../evidence/hero-contact-weight-20261121/README.md)
