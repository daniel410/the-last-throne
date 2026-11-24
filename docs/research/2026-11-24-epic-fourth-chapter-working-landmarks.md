# 다섯 에픽 4장 조사와 귀환을 잇는 지물

2026-11-24 토론토 기준 · TLT-061/DW-04 · TLT-065/GW-04 · TLT-062/FV-04 · TLT-063/EC-04 · TLT-064/HG-04 · G5

이전 4장 후보 0.115.49의 동일 카메라 화면 10쌍을 검토했다. Gloamwood 야간 첫 접근에서 밝은 셰일 아래의 뿌리와 부러진 등불목이 어둠에 합쳐진다. Ember Caldera는 귀환 사선에서 관 둘의 윤곽이 드러나지만 첫 접근의 낮은 시점에서는 관 입구와 잔해가 겹친다. Deepwood는 목재 가로대에 비해 케이블 쪽 철물이 작고, Frozen Vale에서는 축 주변 압설과 석재 어깨의 명도가 비슷하다. Haunted Graveyard의 낮은 끝돌은 귀환 방향에서 읽히며 집결로를 향한 측면의 층이 어둡다. [이전 4장 비교판과 측정](../evidence/epic-fourth-chapter-working-surfaces-20261122/README.md)

## 공식 제작 사례

- **Diablo IV.** Orbei Monastery는 어두운 암석과 옅은 마른 풀로 장소를 구분하고 길 위 순례용 마차로 현재도 쓰이는 이유를 보여 준다. Gloamwood에는 광택이 낮은 목재 끝결과 차가운 셰일로 자연이 오래된 길을 들어 올렸다는 단서를 주고, Haunted Graveyard에는 반복 통행으로 닳은 석회석을 집결로를 향해 노출한다. [Blizzard 환경 아트 개발 노트](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- **World of Warcraft: The War Within.** The Ringing Deeps는 열원, 용광로, 수로와 정비가 밀린 설비를 같은 지역의 생산 과정으로 묶는다. Deepwood에서는 케이블 하중이 전달되는 철물, Frozen Vale에서는 압설에서 드러난 중계축 받침, Ember Caldera에서는 파손 관과 유출 흔적으로 설비의 기능을 보여 준다. [Blizzard 지역 설계 발표](https://wow-site-bwa-production-eks-prod-use1-01.worldofwarcraft.blizzard.com/en-us/news/24125258/explore-the-zones-and-dungeons-of-the-war-within)
- **Lost Ark: Voldis.** Macaboa Port에서 시작한 여정은 강 하구의 Kalinar와 거대 나무가 둘러싼 숲을 지나 Raiyas의 도움으로 Sage’s Tower에 이른다. TLT에서는 장소를 구별하는 재질과 앞서 만난 조력자의 역할을 연결한다. Ylva가 복원한 설원 신호는 중계축에서, Finn과 Brann이 마련한 통행은 묘지 집결로의 낮은 석축에서 읽히게 한다. [Lost Ark Voldis 소개](https://www.playlostark.com/en-us/news/articles/voldis-wonderland-release-notes)
- **Roblox: The Mystery of Duvall Drive.** 제작진은 이야기의 주요 장면에서 출발해 굽은 길과 나무 사이로 목적지를 일부씩 드러내고, Studio에서 접근 시간과 시야를 시험했다. TLT의 4장 지물도 첫 접근에서 한 가지 단서가 잡히고 가까운 귀환에서 접합부를 읽을 수 있도록 구성한다. [Roblox Creator Hub의 공간 제작기](https://create.roblox.com/docs/resources/the-mystery-of-duvall-drive/construct-the-house)

## 제작표

사건 전후는 [캠페인 사건과 결과](../production/campaign-context-review-2026-11-10.md)를 기준으로 삼았다. 배치는 [4장 조사 단계](../../src/shared/CampaignExpansionContent.luau)와 [기존 4장 조립체](../../src/server/World/EpicFourthChapterLandmarks.luau)에 연결한다.

| 에픽 · 장 · 배치 | 이야기의 전후와 플레이 목적 | 지형과 소품 표현 | 비교 장면 |
| --- | --- | --- | --- |
| Deepwood · DW-04 · `exp_1` 3단계 | 망루의 차단 케이블을 찾아 구조 시설과 신호실의 관계를 알아낸다. 구조 뒤 복구한 신호를 따라 돌아간다. | 열린 철제 안내구를 가로대 바깥으로 드러내 케이블이 석축 고정부까지 내려가는 방향을 잇는다. | 낮 귀환에서 케이블의 방향과 석축에 고정된 끝이 읽힌다. |
| Gloamwood · GW-04 · `exp_1` 1단계 | 부서진 등불 기둥을 통해 Hollowbark가 뿌리길을 지나갔음을 확인한다. 이후 반대쪽 피난처 연결을 복구한다. | 등불목의 넓은 끝결을 접근 쪽으로 돌리고 부러진 쇠띠를 남겨 뿌리에 밀린 셰일과 구분한다. | 야간 첫 접근에서 석판과 부러진 등불목이 동시에 읽히고 귀환에서 뿌리와 석판의 접점이 보인다. |
| Frozen Vale · FV-04 · `exp_2` 3단계 | 왜곡된 경보를 확인한 뒤 기록고의 안식 신호를 되살려 피난길과 수호수를 보호한다. | 밝은 압설과 차가운 빙면 사이에 색이 따뜻한 석재 받침을 드러내 중계축 양쪽의 접합을 표시한다. | 접근과 귀환에서 축의 방향과 압설에 묻힌 위치를 찾을 수 있다. |
| Ember Caldera · EC-04 · `exp_1` 2단계 | 마른 냉각관을 따라 고장 난 연결부를 찾아낸다. Dagna와 공급·회수 밸브를 복구한 뒤 보호 회로를 찾는다. | 건조한 파단면과 산화된 파단면의 색과 각도를 구분하고, 오래된 유출의 광물 침전을 내화 받침에 잇는다. | 낮은 조사 접근과 귀환 사선에서 두 관이 갈라지는 방향을 확인한다. |
| Haunted Graveyard · HG-04 · `exp_2` 3단계 | 윈치의 안전 잠금과 정찰 신호를 확보한 뒤 구한 동료가 성문 안에서 합류한다. | 보호턱 하단에 어긋난 석재 줄눈을 두고 집결로를 향한 수직면과 석회암 상단을 연결한다. | 야간에 석축 끝이 가리키는 도착 방향과 동료 집결 공간이 함께 보인다. |

기존 팔레트와 Roblox 기본 도형을 재사용했다. 조립체는 장식으로 배치하고 상호작용과 진행 상태는 기존 퀘스트가 제어한다. 동일 카메라의 전후 비교와 R15 접근·귀환으로 바닥 접지, 보행 이격, 조사점과 지물 위치를 검사한다. 실제 조작 수용에서는 Gloamwood의 야간 최초 발견, Ember Caldera의 조사 중 관 입구, Haunted Graveyard의 동료 집결 뒤 귀환 시야를 중점 확인한다.
