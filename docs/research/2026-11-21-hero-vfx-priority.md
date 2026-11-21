# 파티 전투에서 발사·착탄과 피격 효과의 우선순위

TLT-033/057/059 · 2026-11-21 · 기준 0.115.34

0.115.33의 궁극기 개선은 아군 효과의 중복 획과 표면을 줄였다. 후속 검토에서 짧은 피격 효과가 같은 렌더러의 슬롯을 채운 상태를 재현했다. 뒤따른 Vanguard Strike, Returning Echo, Grand Volley, Chain Lightning은 간략한 형태까지 생략됐고 일부 기술은 범용 섬광을 다시 만들었다. [이전 궁극기 검증](../evidence/hero-ultimate-finish-20261121/README.md)

| 공식 사례 | 관찰과 적용 |
| --- | --- |
| Diablo IV · 2021년 12월 개발자 업데이트 | 적의 위험 예고가 전투 판단에서 우선하며 스킬 위력에 따라 효과 강도를 배분한다. TLT는 별도의 적 예고를 유지하고, 영웅 효과 안에서는 한 번만 표시하는 공격 궤적을 여러 표적에 반복되는 장식보다 우선한다. [Blizzard](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) |
| World of Warcraft Retail · The War Within 11.2 | Spell Density는 중요도가 낮은 주문 표현을 줄여 조우 중 필요한 정보를 보기 쉽게 한다. TLT는 예산이 찼을 때 가장 오래된 아군 피격 장식부터 양보하되 현재 진행 중인 공격 궤적은 계속 표시한다. [Blizzard](https://news.blizzard.com/en-us/article/24226698/ghosts-of-k-aresh-content-update-notes) |
| Lost Ark 글로벌 · 2022년 3월 3일 업데이트 | Battle Effects Display의 파티 효과 옵션에서 일부 디버프가 누락되는 문제를 수정했다. TLT는 장식이 생략돼도 확정 피해 숫자, 피격 자세와 주요 발사 대체 경로를 유지하는지 따로 검사한다. [Amazon Games](https://www.playlostark.com/en-us/news/articles/march-3-2022-update) |
| Roblox Creator Hub | 겹치는 반투명 객체는 같은 픽셀의 중복 렌더링을 일으킬 수 있다. TLT는 본인·아군 슬롯 및 Beam 상한을 유지하면서 피격용 구형 섬광과 중복 표적 장식의 요청을 줄인다. Studio의 장면 카운트와 프레임 시각 비교는 실제 기기 프레임 측정과 별도로 기록한다. [렌더링 최적화](https://create.roblox.com/docs/performance-optimization/improve) · [실기기 검증](https://create.roblox.com/docs/performance-optimization/test-on-hardware) |

검증은 동일 카메라와 피격 부하에서 대표 발사 형태 수, 위험선, 피해 번호를 대조한다. 진행 중인 공격으로 예산이 모두 찬 경우 기존 투사체 대체 효과를 확인한다. 서버 피해, 피격 위치, 발동 시점과 기술 정의는 기존 계약을 따른다. [전후 장면과 결과](../evidence/hero-vfx-priority-20261121/README.md)
