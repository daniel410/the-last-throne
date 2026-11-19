# 다섯 에픽 길목의 접근 방향과 실루엣

2026-11-19 UTC · TLT-061 / TLT-065(GW) / TLT-062 / TLT-063 / TLT-064 · G5

0.113.18의 [Studio 비교판](../evidence/epic-landmark-visibility-20261119/comparison.jpg)에서 GW-05 긁힘은 정면에서 밝은 띠로 보이지만 측면에서 둑에 가렸다. FV-03의 기존 윗살 마감은 가까이서도 대비 변화가 작았다. HG-03의 긴 검은 홈은 후면에서 문턱처럼 보였다. 현행 사건은 [영어 원고](../../src/shared/CampaignStoryText.luau)와 [런타임 목표](../../src/shared/CampaignContent.luau)를 기준으로 확인했다.

- Diablo IV의 Dry Steppes 제작팀은 카메라 높이에서 암석과 밝은 지표의 대비 및 세부 밀도를 조절했다. GW-05에서는 밤의 지표 대비를 경사면에서 옆 능선까지 이어지는 흙 단면에 적용했다. [Blizzard 환경 제작](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- World of Warcraft의 Waking Shores에는 djaradin이 점령한 흑룡 석조 요새와 지역 중심으로 이어지는 수로가 있다. DW-05는 기존 석조에 덧댄 목재 시설의 접합을, HG-03은 아치와 구별되는 폐쇄 배수 기능을 표현했다. [Blizzard 지역 소개](https://worldofwarcraft.blizzard.com/en-us/news/23874316)
- Lost Ark의 Voldis 제작팀은 Sage’s Tower에 축적된 지식과 지역 역사를 건축에 담았다. FV-04 도관은 눈 아래의 금속 체결부를, EC-05는 시험 설비의 공급·회수 분기를 보여준다. [Smilegate 제작 인터뷰](https://www.playlostark.com/en-us/news/articles/creating-voldis)
- Roblox 환경 블록아웃 지침은 세부 표현을 확장하기 전에 축척과 주요 시야를 확인한다. 거리와 방향을 먼저 측정하고 고정 카메라에서 재질과 모델 면을 비교했다. [Roblox Creator Hub](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/greybox-your-environment)

| 장과 목표 | 사건과 표현 | 검증 장면 |
| --- | --- | --- |
| DW-05 · prisoners | 옛 석조 안에 임시 수용 시설이 들어섰다. 교차하는 말뚝과 밖으로 벌어진 지지대로 임시 구조의 하중 방향을 보여준다. | 입구와 후면에서 목재 발과 절단석을 구분한다. |
| GW-05 · rope | 둑을 긁고 넘어간 흔적이 남았다. 대표 모델에서 긁힘을 양쪽 흙 경사와 능선에 연결했다. | 밤의 정면과 측면에서 자국의 연속성을 확인한다. |
| FV-03 · west_beacon | 대상은 협곡 신호 복구다. 방풍 울타리의 눈 덮인 윗면이 양 끝에서 끊기며 목재 단면이 드러난다. | 굽이에서의 각도·거리와 울타리 단면을 각각 확인한다. |
| FV-04 · relay_east | 피난 신호를 복구한다. 짧은 서리 이음새와 노출 금속 띠로 도관 체결부를 드러낸다. | 진행 방향의 화면에서 도관 폭과 어두운 체결부를 확인한다. |
| EC-05 · crew | 설계 금고에서 시험 단계를 돕는다. 높이와 직경이 다른 원형 관과 플랜지의 접합을 드러낸다. | 양면에서 구리 공급관과 녹청 회수관을 구분한다. |
| HG-03 · passage, crypt | Lumi가 안내하는 통로와 주변 묘역 설비의 기능이 다르다. 배수 시설의 홈을 두 개의 낮은 물구멍으로 나눴다. | 통로 귀환 방향과 배수구 후면을 따로 확인한다. |

기존 Roblox 기본 입체 모델을 편집했다. 설치와 검증은 기존 서버 맵 생성 경로에서 수행한다. 모든 지물은 목표 전후에 같은 모습이며 실제 상호작용과 진행 상태는 기존 원고와 활동이 전달한다.
