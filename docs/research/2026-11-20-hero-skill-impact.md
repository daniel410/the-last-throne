# 명중 모션과 협동 전투 가독성 조사

TLT-033/057/059 · 2026-11-20 확인 · PC·패드·터치, 1~4인 전투

[이전 개선](../evidence/hero-skill-choreography-20261120/README.md)은 무기 소켓 준비선과 시전·회수 타이밍을 정리했다. 0.114.20 코드에서는 기술 확인 후의 적 반응이 같은 0.18초 곡선을 공유했다. 다른 영웅의 연출에도 자기 공격과 같은 보조 잔광·광원·입자가 생성됐다. 적의 공격 예고와 영웅의 명중이 같은 위치에서 겹칠 때 무엇을 남겨야 하는지 집중해서 비교했다.

| 공식 자료에서 확인한 동작 | TLT 적용 |
| --- | --- |
| Diablo IV 개발진은 공격 범위의 시간 변화를 애니메이션과 맞추고 피격 효과에 입사 방향을 전달했다. Whirlwind 시연에서는 칼과 먼지의 조명 반응을 분리했다. 2021-12 개발 자료. [Blizzard](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 기존 서버 명중 이벤트의 방향으로 표면 파편과 시각 리그 반응을 편향했다. 방패는 밀고 도끼는 내려누르며, 지면 예고가 진행되는 적은 반응 폭을 줄인다. |
| WoW Retail The War Within의 Ghosts of K'aresh는 Reduced와 Essential Spell Density에서 전투 정보가 적은 효과를 줄인다. 2025-08 업데이트 기록이며 2025-12-19 핫픽스는 두 설정의 적용 주문을 확대했다. [업데이트](https://worldofwarcraft.blizzard.com/en-gb/news/24226698/), [핫픽스](https://worldofwarcraft.blizzard.com/en-us/news/24245107/hotfixes-16-de-diciembre-de-2025) | 다른 영웅의 타격에는 짧은 명중선과 피해 숫자를 남긴다. 발동 시 기술 형태를 유지하면서 보조광과 입자를 줄여 자기 기술과 적 예고가 읽힐 여유를 만든다. |
| Lost Ark 글로벌 Reaper Academy는 빠른 반복 찌르기 Piercing Blade와 이동·착지 베기 Spinning Dagger를 구별한다. Shadow Vortex는 끌어당기는 첫 입력과 후속 회전 타격을 구분한다. 2022-11 공개 기술 설명과 예시 이미지. [Lost Ark Academy](https://www.playlostark.com/en-us/news/articles/reaper-academy) | Rapid 계열 엘프는 반동을 빨리 회수하고 Heavy Draw는 당김을 푸는 동작을 더 길게 가져간다. Gravity는 시각 리그가 주문 중심 쪽으로 당겨지는 느낌을 준다. |
| Roblox Beam의 세그먼트는 곡선 해상도와 렌더링 단위를 결정한다. ParticleEmitter는 Rate를 0으로 두고 일회 발광을 발생시킬 수 있다. 2026-11-20 Creator Hub 조회. [Beam](https://create.roblox.com/docs/reference/engine/classes/Beam), [ParticleEmitter](https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter) | 아군 명중 형상을 Beam 최대 5개와 짧은 중심광으로 줄였다. 기술 종류에 따라 짧은 틈에서도 불의 상향 불티, 냉기 쐐기, 꺾인 번개를 구별한다. |

공식 자료에서 방향·리듬·효과 밀도 원리를 참고했다. 현재 서버 판정·펄스 시각·자원 계약 안에서 클라이언트 리그의 자세와 VFX만 조정했다. 별도 프레임 기반 자동 강등은 기기별 지연 데이터를 확보한 뒤 평가할 수 있다. 이번 검증은 동일 위치 4인 시전에서 적 예고 선분과 피해 숫자가 생성되고 아군 보조 장식이 억제되는지 확인한다. 화면에서 공격 방향을 읽는 시간과 프레임 시간은 전투 QA의 실기기 측정 항목이다.
