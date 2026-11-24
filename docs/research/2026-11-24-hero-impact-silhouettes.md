# 네 영웅의 단발 타격 실루엣 비교

2026-11-24 · TLT-033/057/059 · 기준 0.115.79

연속 타격 작업에 이어 단발 효과를 점검했다. Steel Sweep은 일반 초승달을, Crag Cleave는 나란한 내려베기 두 겹을 사용했다. Vine Burst의 뿌리 높이는 Vine Trap과 같았고, Lava Eruption은 넓은 지면 압력선과 여러 겹의 균열이 분출을 가렸다. 전투 거리를 유지한 상태에서 검격 방향과 지면 발동의 순서를 구분하는 데 초점을 맞췄다.

| 공식 자료 | 관찰 | TLT 적용 |
| --- | --- | --- |
| [Diablo IV 2021년 12월 개발자 업데이트](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 움직이는 무기 궤적과 타격을 맞추고, 몬스터에 남는 효과를 피격 방향에 맞춘다. 위협 예고와 공격의 시각적 우선순위를 구분한다. | Steel Sweep의 낮은 횡베기와 Crag Cleave의 사선에 서로 다른 표적 명중 획을 사용한다. 서버 경계선과 적 예고선을 두고, 넓은 중복 장식을 걷어낸다. |
| [World of Warcraft Retail Legion 7.3 전투 애니메이션](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) | 대지나 공기에서 힘을 모으는 준비 동작과 짧은 시전 동작을 구분한다. 시전 자세까지의 응답 시간을 조정했다. | Vine Burst는 낮게 겨눈 뒤 당긴 팔을 열고, Lava Eruption은 웅크림에서 상체와 손을 올린다. 기존 발동 시각과 이동·회복 계약을 사용한다. |
| [Lost Ark 글로벌 Slayer](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-slayer) · [Summoner](https://www.playlostark.com/en-us/news/articles/summoner-academy) | Slayer의 Brutal Impact는 무기에 체중을 싣는다. Summoner의 Earth Collapse는 지정한 지점에서 지면 반응이 시작된다. | 도끼를 내리는 순간 앞무릎으로 충격을 받는다. 같은 지면 지정 방식에서도 Vine Burst는 바깥쪽 뿌리 끝이, Lava Eruption은 안쪽 분출구가 차례로 솟게 한다. |
| [Roblox 렌더링 성능](https://create.roblox.com/docs/performance-optimization/improve) | 부분 투명 오브젝트가 겹치면 반복 렌더링이 발생한다. 클라이언트에서 VFX를 만들 수 있다. | 기존 빔·면 예산을 재사용하고 아군용 분출구와 뿌리 수를 줄인다. 예산이 꽉 차면 시각 범위는 기존 경계선으로 전달한다. |

2026-11-24에 공개 개발자 글과 직업 가이드를 확인했다. TLT에서 구현한 방향·실루엣은 자료를 바탕으로 정한 미술 판단이다. 같은 렌더러에서 개별 발동·확정 명중·수명·예산 초과 조건을 검사한다. Solo와 4인 실전에서의 판독성과 터치 기기 프레임 시간은 별도 수용 조건이다.
