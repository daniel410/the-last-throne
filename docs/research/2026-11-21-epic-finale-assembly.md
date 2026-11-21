# 다섯 에픽 결말의 운송 시설과 지형 조립

2026-11-21 UTC · TLT-061/DW-07 · TLT-065/GW-07 · TLT-062/FV-07 · TLT-063/EC-07 · TLT-064/HG-07

환경 아트가 [결말 전후](../evidence/epic-finale-readability-20261120/README.md), [목표 측 시야](../evidence/epic-finale-sightlines-20261120/README.md), [선적대 롤러](../evidence/epic-finale-dispatch-20261120/README.md)를 검토했다. 직전 회차의 6장 설비를 바탕으로, 이번에는 다섯 7장 장면에서 각 시설이 지형과 맞물리는 부분을 우선했다.

- Diablo IV 환경 팀은 카메라에 따른 디테일과 명도 배분, Scosglen의 풍향이 지물에 남기는 흔적을 설명한다. GW-07에서 바람에 드러난 셰일과 바람그늘의 눈이 만드는 단면을 우선한다. [Blizzard 환경 아트 개발 업데이트](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- World of Warcraft의 Ringing Deeps는 주민의 작업과 제련소·수로를 같은 산업 공간에 배치한다. DW·FV·EC에서 바퀴홈, 고임목, 축과 받침의 접촉이 운송 과정을 설명하게 한다. [Blizzard Ringing Deeps 지역 소개](https://news.blizzard.com/en-us/article/24025827/world-of-warcraft-whats-next-panel-recap)
- Lost Ark Voldis 제작진은 Sage’s Tower의 높이로 건설 주체의 의지를 표현했다. HG-07의 낮아지는 갓돌과 보강철은 복원 이후 아군이 활용하는 귀환 공간의 규모와 기능을 드러낸다. 기존 복원 상태는 유지한다. [Lost Ark 제작진의 Voldis 해설](https://www.playlostark.com/en-us/news/articles/creating-voldis)
- Roblox는 Studio 테스트와 실기기 확인을 구분한다. 동일 시점 전후와 R15 자동 보행을 확인하고, 실제 조작에서 보이는 첫 시점은 후속 수용 대상으로 둔다. [Studio 테스트 모드](https://create.roblox.com/docs/studio/testing-modes) · [실기기 테스트](https://create.roblox.com/docs/performance-optimization/test-on-hardware)

| 장·행동 | 기존 화면에서 보인 문제 | 제작·확인 범위 |
| --- | --- | --- |
| DW-07 운송 기록 확인 | 흙 외곽이 사각형으로 읽히고 목표 쪽 바퀴홈이 묻힌다. | 바퀴홈과 목재 고임목의 접촉, 마모된 단면 |
| GW-07 북쪽 길 진입 | 야간 눈이 평평한 한 장처럼 읽힌다. | 풍화 셰일층과 바람그늘의 점감하는 적설 |
| FV-07 Ivo 재회 | 얼음 궤와 갈색 정지턱의 용도가 따로 읽힌다. | 양쪽 화물 러너와 각각 맞물리는 접촉면 |
| EC-07 Suri 출하 확인 | 롤러 두 열이 보이고 측면 연결부는 받침에 묻힌다. | 축과 현무암 받침의 결합, Suri 좌측과 중간 접근 시야 |
| HG-07 복원 뒤 귀환 | 단차는 보이나 철제 버팀과 석재가 한 덩어리로 읽힌다. | 세 단 석재 리듬과 버팀의 발·벽 접촉부 |

기존 런타임 조립체와 팔레트를 사용한다. 다섯 지물 각각의 조사점, 피벗, 지면, 보행·충돌 속성과 상태 전환 계약을 기준 빌드와 비교한다.
