# 영웅 무기 동작과 확정 공격 방향

TLT-033/057/059 · 2026-11-21 확인 · PC·터치 전투 카메라

0.115.35에서 휩쓸기 효과가 옆에서 선택한 표적을 향해 돌아갔다. 직선 기술의 발사자가 준비 중 밀려나는 상황에서는 발사 시점의 원점과 시전 당시의 끝점을 잇는 선이 실제 판정 방향에서 벗어났다. [직전 후보의 파티 효과 검증](../evidence/hero-vfx-priority-20261121/README.md)

| 공식 사례 | 관찰과 TLT 적용 |
| --- | --- |
| Diablo IV · 2021년 12월 개발자 업데이트 | 애니메이션이 적용된 공격 범위와 VFX를 맞추고 충돌 방향에 따라 피격 효과를 표현한다고 설명한다. TLT는 서버가 승인한 방향으로 부채꼴을 표시하고 직선 효과의 종점을 현재 원점에서 계산한다. 원래의 표적 선정과 피격 적용 순서를 사용한다. [Blizzard](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) |
| World of Warcraft · Legion 7.3 | 시전 방향과 범위에 따라 준비에서 방출까지의 동작을 구분하고 반복 시전 사이 전환을 개선했다. TLT에서는 Thunder Spear의 지팡이 회전과 유도 팔의 뻗는 구간을 일반 번개 시전과 구분한다. [Blizzard](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) |
| Lost Ark 글로벌 · Glaivier 출시 안내 · 2022년 4월 | 긴 글레이브의 휩쓸기와 짧은 창의 연속 공격을 다른 자세와 무기로 표현한다. TLT의 Crescent Cut은 몸통 회전과 넓게 떨어지는 호를, Braced Throw는 양발 버팀과 좁은 진행선을 사용한다. Retreating Shot은 활의 조준선을 유지한 채 뒤쪽 다리로 제동한다. [Amazon Games](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-glaivier?tag=academy) |
| Roblox Creator Hub · 렌더링 최적화 | 반투명 효과의 겹침과 Beam·ParticleEmitter 업데이트가 렌더링 부하에 영향을 준다. TLT는 중복 초승달 호와 화살 잔상을 제거하고 예산 초과 시 기존 대체 표현으로 이어간다. [성능 최적화](https://create.roblox.com/docs/performance-optimization/improve) · [프로파일러 태그](https://create.roblox.com/docs/performance-optimization/microprofiler/tag-table) |

공식 개발 문서와 출시 안내를 비교했다. 사례 게임의 플레이 관찰은 포함하지 않았다. 동일한 Studio 카메라에서 공격 한 번의 준비와 방출을 비교하고, 옆 표적이 있어도 부채꼴의 축이 유지되는지, 직선 궤적이 벽에서 멎는지, 원래의 표적과 피해 이벤트가 전달되는지 확인한다. 실제 파티 카메라의 방향 판독과 저사양 터치 기기 성능은 전투 QA의 관찰 항목이다. [구현과 검증](../evidence/hero-release-alignment-20261121/README.md)
