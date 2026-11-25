# 반격·관통탄·뿌리 부채·연쇄 번개의 동작 비교

2026-11-25 · TLT-033/057/059 · 기준 0.115.114

Guardian Counter는 방패로 준비하지만 방출에서 배경과 비슷한 두 검격과 바닥 호, 평면 방패가 겹쳤다. Piercing Round는 포구와 엄폐 끝점 사이에 기존 탄선과 공통 효과를 함께 그렸다. Rooting Fan은 전방 범위에 고정 길이 가지를 그렸다. Chain Lightning은 서버가 보내는 정확한 네 표적을 이었지만 모든 연결이 동시에 밝아져 점프 순서를 읽기 어려웠다. 이전 [성광·포탄·표식·빙편 비교](../evidence/hero-burst-contact-20261125/README.md)와 [상태 기술 명중](../evidence/hero-control-attacks-20261123/README.md)을 참고하고 이번에는 방출 동작과 초기에 보이는 주 형상을 검토했다.

| 공식 자료 | 관찰과 TLT 적용 |
| --- | --- |
| Diablo IV · 2021-12 개발자 업데이트 | 타격 방향과 접점을 연결하고 적 예고와 플레이어 효과에 시각 우선순위를 둔다. TLT에서는 반격의 낮은 시작점과 상승 검격, 포구의 한 줄, 연쇄 번개의 고정 접점을 강조했다. [전투와 VFX](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) |
| World of Warcraft Retail · Legion 7.3, The War Within 11.2 | 7.3은 주문 동작의 공통 시점 안에서 직업마다 준비와 방출 형태를 다르게 만든다고 설명한다. 11.2의 Spell Density는 판단 정보에 기여하는 효과를 우선한다. TLT에서 빈손이 번개를 모아 열고 지팡이는 시작점을 맡으며, 아군은 핵심 뿌리 세 갈래와 간결한 번개 연결을 본다. [7.3 시전 동작](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) · [11.2 표시 밀도](https://news.blizzard.com/en-us/article/24226698/ghosts-of-k-aresh-content-update-notes) |
| Lost Ark 글로벌 · 2021 직업 안내, 2025-04 패치 | Gunlancer Charged Stinger는 방어 자세에서 전방 공격으로 전환한다. Artillerist Gatling Gun은 방향성이 강한 연사이며 Sharpshooter Charged Shot과 Snipe는 조준과 해방의 단계가 분명하다. TLT의 반격은 방패 뒤 체중 이동에서 상승 검격으로 이어지고, 관통탄은 연사와 구별되는 한 방 및 늦은 포구 회수로, 마법궁수는 낮은 시위 회수와 지면을 타는 뿌리로 변형했다. [Warrior](https://www.playlostark.com/en-us/news/articles/warrior-advanced-classes?language-picker=true) · [Gunner](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) · [2025-04 조준 변경](https://www.playlostark.com/en-gb/news/articles/april-2025-update-release-notes) |
| Roblox Creator Hub · 렌더링 프로파일과 실기기 | 움직이는 Beam과 입자는 렌더 준비 비용이 있다. 같은 연쇄에 들어가던 면·보조광과 섬광을 줄이고 뿌리의 아군 경로 수를 낮춘다. Studio 효과 개수와 비교 화면을 기록하고 실기기 프레임 시간은 게시 시험에서 수집한다. [MicroProfiler 태그](https://create.roblox.com/docs/performance-optimization/microprofiler/tag-table) · [실기기 테스트](https://create.roblox.com/docs/performance-optimization/test-on-hardware) |

공식 문서와 직업 소개를 2026-11-25에 열람했다. 이번 비교는 애니메이션과 VFX 설계에 사용했다. 근접 엄폐에서도 경로를 자르는지, 아군 효과가 겹칠 때 적 예고의 우선순위가 유지되는지, 20ms 간격의 연출에서 번개 연결 순서가 보이는지를 확인한다. 보호막 수혜자, 포탄과 뿌리의 사거리, 번개 피해 시점은 기존 전투 계약을 적용한다.
