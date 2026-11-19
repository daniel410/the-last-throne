# 구조·귀환 설비의 환경 제작표

2026-11-18 · TLT-061 / TLT-065(GW) / TLT-062 / TLT-063 / TLT-064 · G5 · 환경 아트 → 환경 3D·맵 구현·QA

0.113.16 소스와 0.113.10~12의 환경 검증을 검토했다. 기존 맵에는 지역별 대표 지물과 접근부가 들어가 있으며, 이번 범위는 포로 이송·정찰대 구조·협곡 횡단·설계 협업·관리 통로 귀환을 설명하는 다섯 장면이다. DW-05·GW-05·EC-05에는 스토리 소품이 이미 있으므로 목표와 연결되는 주변 구조를 다룬다. FV-03 방풍 울타리와 HG-03 배수구는 기존 지물의 발견·귀환 방향을 다룬다. FV-04 동쪽 도관과 DW-Q1 실제 입력 진행의 검증 과제는 앞 회차 기록에서 추적한다. [첫 지물 배치](../evidence/epic-story-landmarks-20261118/README.md) · [접근·귀환 검증](../evidence/epic-approach-readability-20261118/README.md)

## 공식 RPG 환경 사례

- **Diablo IV**의 환경 미술 개발 글은 Scosglen 내륙에서 해안으로 갈수록 바람을 따라 눕는 풀로 지형의 변화를 먼저 예고하고, 해안 곳곳에 남은 물건으로 약탈의 흔적을 보여 준다. TLT에서는 FV-03의 쌓인 눈 방향으로 강풍에 노출된 길목을, DW-05의 목재·석재 고정 흔적으로 점령 세력이 쓰던 운송 경계를 표현한다. [Blizzard 환경 미술 개발 글](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- **World of Warcraft: The War Within**의 Ringing Deeps는 용광로와 광산 장치를 관리하는 Machine Speakers의 일터다. 고장난 설비를 되살리는 일이 지역 주민의 문제 해결과 이어진다. TLT에서는 EC-04의 공급·회수 설비와 EC-05의 설계 모형에 같은 접속부 실루엣을 쓰고 크기를 달리해, 세 기술자의 단서가 다음 장의 실제 시험으로 이어지는 과정을 보여 준다. [Blizzard 지역·던전 소개](https://news.blizzard.com/en-us/article/24125258/explore-the-zones-and-dungeons-of-the-war-within)
- **Lost Ark**의 South Kurzan 소개에서는 바다의 붉은 유출물이 화산 지역으로 조사 방향을 이끈다. TLT에서는 GW-05의 곤충 외피·표면 흔적에서 사냥터를 먼저 알아보고, 별도의 정찰대 밧줄로 돌아갈 길을 알아보게 한다. [Amazon Games Summer Heat 출시 자료](https://www.playlostark.com/en-gb/game/releases/summer-heat)
- **Roblox Creator Hub**의 환경 제작 교본은 단순한 형태로 높이·시야·접근을 확인하고 표면과 재질을 구별하는 방식으로 공간을 다듬는다. 이 제작표에서는 낮은 지물의 단면과 지면 마감을 먼저 잡고, 각 목표의 접근·귀환 화면에서 형태와 재질을 확인한다. [Greybox your environment](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/greybox-your-environment) · [Construct your world](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/construct-your-world)

공식 자료는 2026-11-18에 확인했다. TLT 적용은 아래 장면에서 검증할 제작 가설이다.

## 장면별 제작 범위

| 에픽·장 | 현재 스토리와 지형 | 3D 제작 방향 | 확인할 화면 |
| --- | --- | --- | --- |
| Deepwood · DW-05 · Orc Occupied Ruins | 망루에서 얻은 지도는 붙잡힌 보급대 노동자가 있는 폐허로 이어진다. 대피 뒤 이송 명령이 마을과 Black Root Altar를 연결한다. | 무너진 석조 아래에 이송용 목재와 고정 장치를 두어 점령자의 임시 시설이라는 인상을 준다. 넓은 장방형 바닥과 장치의 방향을 실제 감금 구역에 맞춘다. | 진입 경로에서 석조 폐허와 새 목재의 재질이 구별되는지, 우리와 작업자 및 다음 교전이 계속 보이는지 확인한다. |
| Gloamwood · GW-05 · Venomcoil Crossing | 살려낸 등불은 경계까지 닿는다. Venomcoil King이 있는 사냥터를 확보한 뒤 정찰대의 귀환 밧줄을 쓸 수 있다. | 사냥터에 외피가 남은 낮은 암층과 긁힌 면을 두고, 정찰대가 쓰는 목재·밧줄은 별도의 작은 구조에 모은다. 두 재질의 명도와 방향으로 사냥터와 귀환 방향을 구별한다. | 초기 사냥터에서 흔적을 식별할 수 있는지, 보스 목표를 지난 뒤 귀환 방향에서 기존 밧줄 목표를 찾을 수 있는지 확인한다. |
| Frozen Vale · FV-03 · Wolf Ravine | 마을 사이에 끊긴 봉화를 복구해 좌초된 협곡지기와 횡단로를 되찾는다. 기존 울타리에는 퇴설과 낮은 얼음 턱이 있다. | 첫 굽이에서 깨져 드러난 윗살과 바람을 타고 쌓인 쐐기형 눈이 함께 보이는 형태를 검토한다. 상부 목재의 명도와 낮은 눈층의 단면으로 봉화까지 이어지는 협곡의 노출을 암시한다. | 봉화에 조준하지 않은 보행 카메라로 울타리가 처음 나타나는 지점을 잡고, 왕복에서 울타리와 봉화의 윤곽을 비교한다. |
| Ember Caldera · EC-05 · Ancestral Design Vault | 공급은 회복됐다. 기록고에서 Orik과 Dagna의 지식을 Brann의 보호 회로에 결합해 닫힌 회수선까지 확인하고 EC-06의 시험 키트를 준비한다. | 설계 작업대 주변에 기존 수로를 축소한 두 단면과 탈착식 접속부를 놓는다. 공급부는 일정한 폭으로 좁게, 회수부는 끝단을 벌려 앞 장의 흐름을 떠올리게 한다. | 기록고 진입과 회로 확인 후 귀환에서 작업대의 형태를 읽을 수 있는지, 기존 상호작용 모형과 시각적 우선순위가 구별되는지 확인한다. |
| Haunted Graveyard · HG-03 · Lumi Secret Passage | Lumi가 알려주는 관리 통로는 성문 윈치 안쪽까지 닿는다. 동맹은 다음 장에서 열린 큰 성문을 이용한다. 기존 배수구는 관리 설비의 흔적이다. | 귀환에서 보이는 배수구 외벽에 맞물린 석재와 가라앉은 배수선의 낮은 단면을 살린다. 실제 통로에 있는 등불과 배수구 외벽이 동시에 보이는 각도를 우선 검토한다. | 실제 통로에서 돌아볼 때 외벽·지면·등불을 구별할 수 있는지, 장식 격자에 진입로처럼 보이는 빈 단면이 없는지 확인한다. |

설비의 기능 상태가 바뀌는 순간은 기존 목표와 스토리 장치가 전달한다. 지물의 접지, 바닥, 몸체 여유, 목표와의 거리 및 카메라 가림을 기존과 같은 조건에서 비교한다. 동일한 조명·시야각의 접근 및 귀환 화면과 R15 이동은 구현 후 증거로 기록한다. 이 제작표는 정적 검토와 제작 방향을 기록한다. [현행 영어 원고](../../src/shared/CampaignStoryText.luau) · [기존 스토리 소품](../../src/server/World/StoryPropAssignments.luau) · [전투 동선](../production/campaign-combat-routes-2026-11-10.md) · [G5 티켓](../tasks/09.md) · [맵 제작 수용 기준](../../agent.md#맵-제작-호출과-공통-수용-기준)
