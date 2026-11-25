# 다섯 에픽 3장 구조·정찰 동선의 지형과 지물

2026-11-24 Toronto · TLT-061/DW-03 · TLT-065/GW-03 · TLT-062/FV-03 · TLT-063/EC-03 · TLT-064/HG-03 · G5

환경 아트와 환경 3D 역할이 기존 3장 대표 지물과 각 사건의 원고·좌표를 대조했다. 명부대, 피난처 귀환 표식, 횡단 난간 소켓, 냉각 점검구, 묘지 문설주는 [기존 3장 비교](../evidence/epic-third-chapter-working-landmarks-20261123/README.md)에서 검토했다. 이번에는 각 지역의 다른 사건에서 조사 또는 구조를 이어 가는 단계에 집중했다. Gloamwood는 기존 지도대의 반복을 피하도록 회수 등불 선반을 골랐고, Haunted Graveyard는 배수 점검함 다음 단계인 석재 난간을 택했다.

## 공식 제작 사례

- Diablo IV의 Scosglen은 현지에서 구한 석재와 재활용 목재로 기후와 생업을 표현한다. TLT에서는 흙에 박힌 관측대 돌좌와 셰일에 기대 만든 회수 등불 선반을 같은 방식으로 해석했다. [환경 아트 제작기](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- World of Warcraft의 Ringing Deeps는 제련과 기계 정비의 생활을 용암, 공업 시설, 수로로 보여 준다. Ember Caldera에서는 화산재가 모인 현무암 기단과 내화벽돌 위에 정비 가능한 철제 난간 연결부를 드러냈다. [The War Within 지역 소개](https://worldofwarcraft.blizzard.com/en-gb/news/24125258/explore-the-zones-and-dungeons-of-the-war-within)
- Lost Ark의 Yorn은 거주민의 제작 기술이 오래 축적된 지하 건축을, Feiton은 과거 사건이 남긴 지형의 변화를 보여 준다. TLT에서는 Frozen Vale의 해빙 경계와 Haunted Graveyard의 철제 보수 흔적으로 시간과 사용을 표현했다. [Yorn·Feiton 공식 소개](https://www.playlostark.com/en-us/news/articles/january-2022-team-update)
- Roblox 환경 아트 과정은 건축, 재료, 소품으로 장소의 용도를 구별하는 방법을 보여 준다. 지역 팔레트와 Roblox 기본 입체를 사용해 외부 메시 에셋 의존성 없이 다섯 조립체를 통합했다. [Creator Hub 환경 제작 과정](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/construct-your-world)

## 제작표

원고와 단계 번호는 [CampaignExpansionContent](../../src/shared/CampaignExpansionContent.luau) 기준이다. 각 시설은 이전 단계에서 두 번째 단계로 들어오는 주행선 바깥에 놓이며, 영역에 진입할 때부터 보이는 고정 환경이다.

| 에픽·사건·단계 | 기존 사건의 맥락 | 추가 지형과 지물 | 화면에서 확인할 부분 |
| --- | --- | --- | --- |
| DW-03 · Outpost Signal Terrace · exp_2/2 | 끊긴 감시탑 신호를 읽는다. | 다져진 흙 어깨, 현지 돌좌, 조준 홈이 있는 목재 관측 받침 | 두 기둥과 그 사이의 열린 홈 |
| GW-03 · Lantern Refuge Arrivals · exp_1/2 | 정찰대의 귀환 물품과 Tali의 지도를 대조한다. | 셰일 물끊기, 갈라진 뿌리 선반, 회수 등불을 받는 쇠걸이 | 첫 접근에서 야간 바닥과 분리되는 절단면, 귀환에서 쇠걸이 |
| FV-03 · Lower Ravine Rescue · exp_1/2 | 구조된 마차 관리인을 오래된 보급 둑으로 안내한다. | 암반 절개면, 얼음 이음과 압설, 돌에 박힌 보급길 표지 | 표지 아래에서 이어지는 얼음과 눈의 층 |
| EC-03 · Mine Rescue Staging · exp_1/2 | 부상자가 걸어서 나가도록 낮은 난간을 고정한다. | 현무암과 화산재 바닥, 내화벽돌 받침과 철제 구조 난간 | 모양이 다른 지지 신발과 내화벽돌 사이의 결합부 |
| HG-03 · Fortress Side Landing · exp_2/2 | 요새 쪽 숨은 출구의 오래된 난간을 고정한다. | 석회암 기단과 마모된 난간 끝, 철제 보수 꺾쇠 | 어두운 석조 배경에서 밝은 난간 상부와 보수 흔적 |

[통합 소스](../../src/server/World/EpicThirdChapterRouteLandmarks.luau) · [검증과 재현](../evidence/epic-third-chapter-rescue-routes-20261124/README.md)
