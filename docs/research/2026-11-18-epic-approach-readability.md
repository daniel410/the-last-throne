# 다섯 에픽의 접근·귀환 환경 제작표

2026-11-18 · TLT-061 / TLT-065/GW / TLT-062 / TLT-063 / TLT-064 · G5 · 환경 아트 → 환경 3D·맵 구현·QA

0.113.10과 0.113.11의 비교판에서 지물의 정면 형태를 검토했다. DW-Q1은 두 빌드의 R15가 보고 경로의 나무 부근에서 멈췄고 뒤쪽 석조 접촉 두 점은 정적 검사에서 관찰됐다. GW-04는 야간 두 구도에서 뿌리와 암층의 경계가 흐리다. FV-04 동쪽 도관은 근접 측면에서 기록고와 함께 보이지만 중계기 기준 약 110스터드 외곽에 있다. EC-04의 수로 두 곳은 근접하면 단면을 구별할 수 있으나 검은 지면에 접한 모서리가 약하다. HG-03 배수구의 정면은 석재와 금속이 구별되며 실제 접근·귀환 방향이 남은 확인 지점이다. [0.113.10 비교판과 검증](../evidence/epic-story-landmarks-20261118/README.md) · [0.113.11 비교판과 검증](../evidence/epic-route-landmarks-20261118/README.md)

## 공식 RPG 환경 사례

- **Diablo IV**의 미술 개발 글은 Kyovashad 바깥의 작은 방어 시설에서 성문으로 규모를 키워 접근을 예고하고, 어두운 던전에서 플레이 공간의 윤곽을 조명으로 드러낸다고 설명한다. TLT에서는 DW 보고 구간의 남은 석재와 HG의 낮은 배수구 가장자리를 보행 높이의 단서로 활용한다. 회전하는 카메라에서 전경 가림은 각 방향으로 확인한다. [Blizzard의 2022년 3월 환경 미술 개발 글](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- **World of Warcraft: The War Within**에서 Hallowfall의 Beledar는 지역 전반에서 보이는 큰 지표이며, 아라시 사람들에게 빛과 온기를 주는 서사적 장소이기도 하다. TLT에서는 기록고와 펌프장의 기존 원경 조형을 방향 기준으로 삼고, 중계기와 각 밸브 가까이에서는 규모가 작은 단면으로 설비의 기능을 전달한다. [Blizzard의 Khaz Algar 지역·던전 소개](https://worldofwarcraft.blizzard.com/en-us/news/24125258/explore-the-zones-and-dungeons-of-the-war-within)
- **Lost Ark** 글로벌판의 Voldis 소개는 강 하구의 Kalinar와 거목이 자라는 Great Rainforest를 구별하고, 숲 주민의 도움을 현자 탑 접근에 연결한다. TLT에서는 GW 뿌리길의 수피와 드러난 심재가 야간 지형을 식별하게 하고, 기존 정찰 등불이 실제 귀환 방향을 알려 준다. [Amazon Games의 2023년 Voldis 출시 자료](https://www.playlostark.com/en-gb/news/articles/voldis-wonderland-release-notes?tag=release-notes)
- **Roblox Creator Hub** 환경 교본은 높이와 단순 형태로 시야·통행을 검증한 뒤 위치를 식별할 수 있도록 표면을 구별한다. TLT에서는 길 가장자리 단면의 형태·재질을 소규모로 수정하고 R15 접근·귀환에서 발견 시점과 차폐를 비교한다. [Greybox your environment](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/greybox-your-environment) · [Construct your world](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/construct-your-world)

공식 소개와 개발 글은 2026-11-18에 열람했다. TLT 적용은 이 빌드에서 시험할 가설이다.

## 장면별 제작과 확인

| 에픽·장·목표 | 스토리와 지역 특성 | 지형·지물 방향 | 진행과 비교 장면 |
| --- | --- | --- | --- |
| Deepwood · DW-Q1 · `waterproof_log`, `marsh_report` | 습지에서 건진 방수 보급 명단을 전초기지 생존자에게 전달한다. 보고부는 개울과 낮은 폐허 사이의 좁은 길이다. | 기존 나무와 아치의 형태를 살려 길 가장자리와 통행 면을 구분한다. 나무의 굵은 뿌리와 석재 받침은 아바타 폭과 카메라를 고려해 열려 있는 길 중심에서 비켜가게 한다. | 명단 회수와 보고 조건은 현행 스토리가 담당한다. 습지 쪽에서 보고 장소까지 나무와 뒤쪽 아치를 차례로 지나고 실제 보고 위치에서 출발점으로 돌아온다. 기존 DW-02 접촉점도 회귀 검사한다. |
| Gloamwood · GW-04 · `roots`, `ent`, `lantern` | Ancient Hollowbark를 넘은 뒤 등불을 다시 켜 정찰대의 귀로를 되찾는다. 흙둑을 붙드는 뿌리와 밤의 수피가 구간의 특징이다. | `RootwayBankCut`의 드러난 뿌리 측면과 끝을 넓게 읽히도록 하고, 무발광 심재와 짙은 수피·암석에 명도 차를 둔다. 낮은 실루엣은 등불의 빛과 윤곽 아래에 둔다. | 기존 등불이 점등 결과를 나타낸다. 뿌리길 첫 굽이와 등불 접근, 등불에서 피난처 쪽으로 돌았을 때 바닥·뿌리·등불이 분리되어 보이는지 비교한다. |
| Frozen Vale · FV-04 · `relay_west`, `relay_east`, `ylva` | 기록고의 두 중계기를 수리해 피난로의 신호를 되찾는다. 눈에 묻힌 석재 턱의 직선과 도관 홈이 연결의 흔적이다. | 동쪽 도관을 중계기 접근에서 읽을 수 있는 작은 받침으로 검토한다. 청회색 테두리와 어두운 홈의 방향을 중계기 쪽으로 잡고 낮은 옆면에서 바닥과 잇는다. | 경보·복구는 기존 보라색과 청록색 신호가 표현한다. 서쪽에서 동쪽 중계기로 다가갈 때와 Ylva 쪽에서 돌아설 때 도관과 중계기 본체가 한 구도에 들어오는지 확인한다. |
| Ember Caldera · EC-04 · `engineer`, `west_valve`, `east_valve`, `plans` | Dagna가 막힌 공급·회수 채널을 되살린다. 서쪽은 좁은 여과 설비, 동쪽은 침전물을 받는 넓은 회수부다. | 기존 두 수로의 가장자리를 보강한다. 공급부는 짧고 규칙적인 여과틀과 곧은 돌턱, 회수부는 벌어지는 석조 단면과 닳은 턱으로 만들어 실루엣을 구별한다. | 건식 모형의 형태는 유지되며 흐름 회복은 기존 밸브 상태로 전달한다. Dagna 쪽 접근, 밸브 사이, 설계도를 확보한 뒤 역방향에서 색 단서 없이 윤곽을 구별할 수 있는지 비교한다. |
| Haunted Graveyard · HG-03 · `lumi`, `crypt`, `passage` | Lumi가 알려주는 좁은 관리 통로는 다음 장에서 성문 윈치 안쪽으로 이어진다. 차갑고 낮은 석재와 작은 격자가 관리 시설의 흔적이다. | `KeeperDrainCulvert`의 길을 향한 낮은 석재 모서리와 노출된 측면을 읽히게 한다. 장식 배수구와 실제 관리 통로가 혼동되지 않도록 석재의 방향과 높이를 기존 등불·통행 바닥에 맞춘다. | 통로 열림과 일행의 진행은 기존 목표가 나타낸다. 등불 아치 쪽에서 접근하고 배수구 옆을 지나며, 실제 통로 방향에서 돌아올 때 석재·격자·등불을 각각 확인한다. |

[영어 본편·선택 스토리 원고](../../src/shared/CampaignStoryText.luau) · [DW 목표](../../src/shared/DeepwoodContent.luau) · [GW/HG 목표](../../src/shared/LateEpicContent.luau) · [FV 목표](../../src/shared/FrozenValeContent.luau) · [EC 목표](../../src/shared/EmberCalderaContent.luau) · [현행 전투 동선](../production/campaign-combat-routes-2026-11-10.md) · [Gloamwood 작업 기록](../tasks/02.md) · [G5 티켓](../tasks/09.md)

환경 3D는 기존 지물의 편집 가능한 형태와 지역 팔레트를 우선 사용한다. 같은 위치·높이·시야각·조명에서 기존과 후보를 찍되 랜드마크를 향해 따로 조준한 구도와 경로를 따라가는 구도를 구분한다. 맵 구현·QA는 원본/Easy 바닥·몸체 겹침·경계 및 해당 목표의 R15 접근과 귀환을 확인한다. 접지·가림·통행 결과와 실제 반영한 모델은 해당 빌드 증거에 기록한다. [맵 제작 공통 수용 기준](../../agent.md#맵-제작-호출과-공통-수용-기준)
