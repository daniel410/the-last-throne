# 경사에서 읽히는 네 영웅의 타격

2026-11-26 · TLT-033/057/059 · 기준 빌드 0.115.130

기준 빌드는 범위 중심 아래 높이를 한 번 구한 뒤 모든 경계선을 그 높이에 그렸다. 오르막에 겹친 선이 지형 안으로 들어가고 내리막 쪽이 뜨는지 경사 fixture에서 재현한다. Sweeping Break와 Mountain Sweep의 기술 반경은 서버의 원형 판정을 따른다. 검격과 바위가 튀는 방향은 각 기술의 동작을 설명한다. Arrow Rain과 Earth Rise는 서버가 확정한 목표 지점을 사용한다.

| 확인한 공식 자료 | TLT 적용 |
| --- | --- |
| Diablo IV 2021년 12월 개발자 업데이트. 무기 동작, 타격 방향, 피해 범위와 적 예고가 각각 전달하는 정보를 설명한다. [Blizzard 개발자 글](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 범위선의 XZ 반경은 그대로 두고 높이만 투영한다. Sweeping Break의 검이 낮아지는 방향과 Mountain Sweep의 낮은 바위 충격을 별도 형태로 읽히게 한다. |
| World of Warcraft Retail Legion 7.3의 개발자 글은 시전 자세와 방출의 차이를 설명한다. The War Within 11.2 업데이트는 전투 정보 비중이 낮은 주문 효과를 줄이는 Spell Density를 설명한다. [시전 애니메이션](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) · [11.2 업데이트](https://worldofwarcraft.blizzard.com/en-us/news/24226698/ghosts-of-karesh-content-update-notes) | 기사와 드워프의 손과 팔꿈치가 각각 검격과 무거운 도끼를 거둔다. 아군 화면에서도 무기나 착탄의 주 형태를 남기고 중복 효과를 줄인다. |
| Lost Ark 글로벌 클래스 소개의 Slayer Ground Smash는 무기를 땅에 꽂는 박자와 충격파를 나눈다. Sharpshooter Arrow Shower는 상향 사격 뒤 지정점에 화살이 쏟아진다. Summoner Earth Collapse는 지정 지면에서 지진을 일으킨다. [Slayer](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-slayer) · [Sharpshooter](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) · [Summoner](https://www.playlostark.com/en-us/news/articles/summoner-academy) | Arrow Rain의 하강과 착탄이 같은 지점을 쓰고, Earth Rise의 빈손이 들리는 박자에 중심 바위부터 차오른다. |
| Roblox Creator Hub는 실기기에서 프레임 시간과 메모리를 측정하고 Studio 에뮬레이션을 화면비·입력에 활용한다. [실기기 검증](https://create.roblox.com/docs/performance-optimization/test-on-hardware) | 시각 보간을 첫 생성에 한정하고 12/24선분 예산을 사용한다. 같은 Studio 경사에서 투영 오차와 효과 개수를 대조한다. |

공식 문서와 게시 시점의 기술 설명을 비교했다. 플레이 비교와 상용 게임 자산 도입은 이번 검토 범위 밖이다. 투영은 중심 아래 표면을 기준으로 가까운 지면을 찾는다. 기준 지면이 없으면 평면 표현을 사용하며 지지점이 없거나 단차가 큰 곳은 연결을 끊는다. 바닥 레이캐스트 비용과 게시 4인 전투에서 적 예고 인지는 실기기 QA에서 확인한다.
