# 다섯 에픽 세 번째 장의 지물

2026-11-20 UTC · TLT-061/DW-03 · TLT-065/GW-03 · TLT-062/FV-03 · TLT-063/EC-03 · TLT-064/HG-03 · G5

0.114.8의 접근·측면 비교에서 Frozen Vale의 전망턱은 설면과 구분되고 Ember Caldera의 광차선 받침은 재질이 잘 읽히지만 기존 경로와 떨어져 보인다. Deepwood의 돌섶은 그늘에 묻히고 Gloamwood의 낮은 셰일은 야간 대비가 약하다. Haunted Graveyard의 벽감은 측면에서 귀환 표식과 겹친다. 세 번째 장은 구조 이후의 기록, 귀환, 복구, 우회에 쓰이는 시설을 다룬다. 낮은 기저로 지물과 바닥의 접점을 만들고, 기존 프롬프트가 놓인 방향에서 지물의 단면을 확인한다. [0.114.8 Studio 비교 및 보행 자료](../evidence/epic-second-chapter-landmarks-20261120/README.md)

## 공식 사례와 적용

- **Diablo IV · Scosglen과 Kyovashad.** Scosglen은 해안 바람과 파도에 닳은 지형, 현지 재료로 만든 작업 시설로 해안 생활을 보여 준다. Kyovashad는 목재 기둥과 석조 방어 시설을 접근 순서에 따라 드러낸다. Deepwood에서 구조 물자를 관리하는 작업대를 현지 돌과 목재로 표현하고, Frozen Vale의 난간 받침과 설면에 바람이 닿는 면과 쌓이는 면을 구분한다. [Blizzard 환경 아트 제작기](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- **World of Warcraft · Hallowfall과 The Ringing Deeps.** Hallowfall의 Beledar는 구역 여러 곳에서 반복해서 볼 수 있고, The Ringing Deeps의 제련소와 수로는 Machine Speakers가 관리하는 설비를 보여 준다. Gloamwood의 기존 귀환 표식이 양방향에서 읽히도록 주변 형태를 잡고, Ember Caldera에는 광차선 아래 냉각 수로를 관리했던 흔적을 둔다. [Blizzard 지역 소개](https://worldofwarcraft.blizzard.com/en-gb/news/24125258) · [Blizzard 개발 발표](https://worldofwarcraft.blizzard.com/en-us/news/24025827/world-of-warcraft-whats-next-panel-recap)
- **Lost Ark · Voldis.** Smilegate RPG는 현자의 탑을 둘러보는 과정에서 그곳 주민들이 어떤 지식을 모으고 어떻게 활용하는지 보여 준다. Deepwood에서는 구조 명부를 대조하던 작업 흔적을 기록 시설에 담고, Haunted Graveyard에서는 관리인이 쓰던 측문을 풍화된 경계와 철제 고정구로 드러낸다. [Smilegate RPG 제작 인터뷰](https://www.playlostark.com/en-us/news/articles/creating-voldis)
- **Roblox · 환경 그레이박스.** 실제 캐릭터 규모에서 통과 폭과 시야를 먼저 검토한다. 지물의 높이와 외곽을 기존 접근 경로, 목표물, 옆에서 돌아보는 위치에 대조한다. [Roblox Creator Hub 환경 제작 가이드](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/greybox-your-environment)

## 장별 제작표

사건의 단계 좌표를 기준으로 보행로의 옆에 배치한다. 기존 조사 물품과 장치가 상호작용을 담당하고, 새 지물은 사건 전후에 남을 작업 흔적을 보여 준다. [사건 원본](../../src/shared/CampaignExpansionContent.luau) · [물품 배치 원본](../../src/server/World/StoryPropAssignments.luau)

| 에픽 · 위치 | 제작 방향 | 플레이 확인 조건 |
| --- | --- | --- |
| Deepwood · DW-03 · Outpost Supply Yard · `exp_1:2` | 돌 받침과 현지 목재로 구조 명부 작업대 `ReliefRosterStand`를 구성한다. 낮은 주춧돌과 밝게 닳은 목재 상판으로 종이와 도구가 놓였던 면을 드러낸다. | 캠프에서 다가올 때 작업대가 그늘에서 드러나고 기존 명부 조사 위치를 찾을 수 있다. |
| Gloamwood · GW-03 · Northern Root Overlook · `exp_2:2` | 묵은 방향석과 지면에 드러난 갈라진 뿌리를 묶어 귀환 지물 `RefugeReturnRootMarker`를 구성한다. | 전망대에 도착할 때와 피난처로 돌아설 때 기존 귀환 표식과 받침 단면이 구분된다. |
| Frozen Vale · FV-03 · Eastern Lift Walk · `exp_2:2` | 암빙·압설 바닥 위에 `RavineWalkRailAnchor`를 조형한다. 가동 다리 바깥에 체결판과 짧은 난간 버팀대를 배치한다. | 설면과 받침이 분리되어 보이고, 기존 난간 결속 프롬프트와 통행 폭이 확보된다. |
| Ember Caldera · EC-03 · Miners Return Landing · `exp_2:2` | 광차선 옆의 낮은 `BelowRailCoolantInspectionHead`에 식은 현무암의 홈과 철제 점검구를 사용한다. | 운반 동선을 따라 접근할 때 점검구가 바닥과 연결되어 보이고 기존 화물 번호 조사에 접근할 수 있다. |
| Haunted Graveyard · HG-03 · Quiet Crypt Gallery · `exp_1:2` | 풍화된 문턱, 남은 한쪽 문설주 `KeeperServiceDoorJamb`, 철제 고정구로 옛 관리용 통로를 드러낸다. | 접근과 귀환에서 문틀 윤곽과 기존 문양 조사가 구분되고 다음 표식으로 향할 통로가 보인다. |

Studio에서는 기존 사건 앵커와 도보선, 모델 접지, 접근·측면 시야를 비교한다. 최초 발견과 기존 프롬프트 조작, 전투 카메라, 실기기 수용은 실제 플레이에서 판정한다.
