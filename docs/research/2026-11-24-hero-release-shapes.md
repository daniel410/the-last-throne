# 영웅 공격 방출 형상과 엄폐 판독

2026-11-24 · TLT-033/057/059 · 검토 기준 0.115.70

직전 후보는 피격 방향과 적 시전 차단을 다듬었다. 이번 소스 리뷰에서는 Scatter Shot, Fan Break, Piercing Volley에 무기 끝에서 시작하는 보조 궤적과 최대 사거리에 미리 그린 주 획이 겹치는 것을 확인했다. 이 주 획은 중앙에 엄폐물이 있어도 같은 길이였다. Rallying Slash는 겹친 가로 반원 때문에 검이 지나가는 높이가 약했고, Steam Burst는 옅은 안개와 동일한 명중 섬광 때문에 물에서 증기로 바뀌는 타격 시점을 판독하기 어려웠다.

| 공식 자료에서 확인한 요소 | TLT 적용 |
| --- | --- |
| Diablo IV 개발자 업데이트, 2021-12-20. 설계팀은 공격 판정·무기 궤적·피격 방향을 맞추고, 전투 판단에 필요한 정보를 효과보다 우선한다. | 산탄과 화살은 기존 피해 판정과 같은 엄폐 필터를 사용해 서버 펄스에서 다섯 표시 끝점을 계산한다. 검격의 높이 변화와 피격 방향을 연결한다. [Blizzard](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) |
| World of Warcraft Retail, Legion 7.3 개발자 글, 2017-08-16. 시전 전 동작과 주문이 나가는 자세에 직업별 변화를 주면서 발동 시점을 일관되게 맞췄다. | 기사 체중 이동, 드워프 왼팔 반동, 엘프의 수직 활과 회수, 마법사의 빈손 억눌림과 반동을 각각 다듬었다. 모션은 기존 펄스를 기준으로 샘플링한다. [Blizzard](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) |
| Lost Ark 글로벌, 2021-08-24 Gunner 소개와 2023-08-08 Aeromancer 소개. 산탄 무기는 반동과 밀어내기를, Sharpshooter는 진행하는 화살과 낙하 기술을 구분한다. Aeromancer는 비·바람과 무기 동작을 나눠 사용한다. | 산탄의 두껍고 짧게 사라지는 다섯 획과 화살촉의 좁고 긴 실루엣을 구분했다. Steam Burst는 낮게 튀는 물 가장자리와 위로 퍼지는 두 증기 획으로 나눴다. [Gunner](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) · [Aeromancer](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-aeromancer) |
| Roblox Creator Hub, 2026-11-24 확인. Beam은 끝점과 너비를 각각 제어할 수 있고, 반투명 효과의 중첩은 렌더링 비용을 늘린다. | 새 산탄·화살은 주 획에서 표시를 맡고, 예산이 모자랄 때 같은 끝점을 경량 경로에 사용한다. 세 기술에만 펄스당 레이캐스트 다섯 번을 추가한다. [Beam](https://create.roblox.com/docs/reference/engine/classes/Beam) · [렌더링 성능](https://create.roblox.com/docs/performance-optimization/improve) |

비교 범위는 공식 개발자 설명과 기술 소개다. 해당 게임을 직접 조작하거나 라이브 수치·파티 프레임 시간을 측정한 결과는 없다. TLT의 최소 실험은 같은 리그·카메라·엄폐물에서 각 기술을 이전 후보와 비교하고, 막힌 줄의 끝·열린 줄의 사거리·적중 결과와 기존 위험 표시를 확인하는 것이다. 게시 시험의 4인 교전과 저사양 터치 기기에서 실제 반응과 프레임 비용은 전투 QA가 이어서 확인한다. [구현과 검증](../evidence/hero-release-shapes-20261124/README.md)
