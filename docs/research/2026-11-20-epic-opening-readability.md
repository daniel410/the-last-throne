# 다섯 에픽 첫 사건 지형의 가독성

2026-11-20 UTC · TLT-061~064 · Gloamwood TLT-065/concept-map · G5

0.114.5의 동일 카메라 비교에서 Deepwood와 Ember Caldera의 새 지물은 조사 대상 옆에서 구분된다. Gloamwood의 갈라진 뿌리와 Haunted Graveyard의 기단은 야간 지면에 섞인다. Frozen Vale의 암빙은 측면에서 뚜렷하지만 접근면의 압설은 일반 설면에 묻힌다. 이번 제작은 첫 사건의 지형과 소품 다섯 곳에서 접근 방향으로 노출되는 단면을 조형한다. Gloamwood는 야간 숲의 노출 뿌리와 셰일을 사용해 Deepwood의 물가와 적재 시설에서 구분한다. [0.114.5 비교 화면](../evidence/epic-opening-landmarks-20261120/comparison.jpg) · [지역별 맵 콘셉트 결정](../decisions/2026-11-13.md)

## 공식 사례와 제작 적용

- Diablo IV 환경 아트는 Scosglen에서 바람에 휘는 풀로 해안 접근을 예고하고, Dry Steppes에서는 암석과 식생의 명도 차이를 활용한다. TLT에서는 Deepwood의 물선 위 적재면과 Frozen Vale의 바람그늘 쪽 암빙 단면에 지역 환경을 드러낸다. [Diablo IV 환경 아트](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- World of Warcraft의 Ringing Deeps는 용암 제련소와 광차로 작업장의 용도를 보여 주고, Hallowfall에서는 거대한 광원이 지역의 방향 단서를 제공한다. Ember Caldera의 운반대 받침에 적재 흔적을 드러내고, Gloamwood와 Haunted Graveyard에서는 낮은 지형 단면에서 기존 등불로 시선이 이어지게 한다. [The War Within 지역과 던전](https://worldofwarcraft.blizzard.com/en-us/news/24125258)
- Lost Ark 제작진은 Voldis의 Sage’s Tower를 탐색하는 과정에서 현자들의 역할과 관점을 전달한다. TLT에서는 Gloamwood에서 정찰대가 갈라진 길, Haunted Graveyard에서 돌아온 동료들이 표시한 길이 지형의 형태에 드러나도록 적용한다. [Creating Voldis](https://www.playlostark.com/en-us/news/articles/creating-voldis)
- Roblox의 환경 아트 절차는 조형 초기의 보행과 방향 판독 확인을 강조한다. 같은 지역 조명과 카메라에서 실루엣과 재질을 비교하고, 첫 발견과 상호작용은 실제 아바타 입력에서 관찰한다. [Roblox Creator Hub의 환경 그레이박스](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/greybox-your-environment)

## 장별 제작표

사건과 단계의 출처는 [CampaignExpansionContent](../../src/shared/CampaignExpansionContent.luau)의 각 장 첫 활동이다. [환경 모델 원본](../../src/server/World/EpicQuestLandmarkAssemblies.luau)의 기본 형상과 재질을 사용한다.

| 에픽 · 스토리 | 사건과 위치 | 0.114.5 장면에서 확인한 점 | 조형 목표 | 플레이 확인 조건 |
| --- | --- | --- | --- | --- |
| Deepwood · DW-01 | Creekside Cargo의 마른 약품 상자 옆. 습격 때 흩어진 마을 보급품과 구조 단서를 찾는다. | 목재가 잔디 위에 드러나고 젖은 바닥과 마른 적재면의 관계는 약하다. | 낮은 씻긴 돌 면과 마른 목재 끝단으로 물선 위 적재 위치를 보여 준다. | 물가 접근과 측면에서 약품 상자가 먼저 보이고, 마른 적재면과 바퀴 자국이 다음 단서를 받쳐 준다. |
| Gloamwood · GW-01 | Scouts Wheeltrack Hollow의 깊은 바퀴 홈 옆. 화물은 북쪽으로, 정찰대는 친구를 돕기 위해 거미줄 쪽으로 향했다. | 밤의 흙과 낮은 뿌리의 명도 차이가 작다. | 노출 뿌리의 심재와 회청 셰일의 면으로 바퀴 홈 옆 갈라지는 형태를 읽게 한다. | 홈과 뿌리의 갈라짐이 접근·측면에서 구분되고, 기존 발자국과 등불을 따라 정찰대의 방향을 찾을 수 있다. |
| Frozen Vale · FV-01 | Snowbound Caravan Basin의 바람그늘 오름길 표식 옆. 조난자가 설원 피난처로 올라가는 길이다. | 압설 표면이 정면 설면에 섞이고 측면에서 암빙이 먼저 읽힌다. | 접근면의 암빙을 드러내고 압설과 눈의 경계를 청회색 단면으로 이어 오름길 방향을 보여 준다. | 수레에서 올라오며 압설 가장자리와 기존 오름길 표식을 한 화면에서 구분할 수 있다. |
| Ember Caldera · EC-01 | Ashbound Freight Yard의 멈춘 화물 운반대 옆. 공격 후 승강기 기어가 반출됐다. | 고임쇠가 먼저 보이며 검은 받침의 접촉면은 주변 현무암에 섞인다. | 받침의 마모 색과 고임쇠의 재질을 다르게 처리해 정지 위치를 보여 준다. | 접근과 측면에서 받침의 접촉면이 읽히고 기어를 끈 기존 흔적과 구별된다. |
| Haunted Graveyard · HG-01 | Scouts Hidden Approach의 Brann의 길돌 옆. 구해 준 정찰대와 광부가 오래된 피난처까지 길을 표시했다. | 낮은 기단이 안개 낀 야간 지면에 섞인다. | 마모된 돌의 상단과 접근면을 드러내고 낮은 기단으로 정찰 표식과 등불을 잇는다. | 접근과 측면에서 낮은 기단이 식별되고 정찰 표식, 길돌, 관리인의 등불을 순서대로 찾을 수 있다. |
