# 다섯 에픽 4장 길목 지물의 접근 가독성

2026-11-21 확인 · TLT-061/DW-04 · TLT-065/GW-04 · TLT-062/FV-04 · TLT-063/EC-04 · TLT-064/HG-04

[0.115.24 Studio 접근·귀환 비교 10쌍](../evidence/epic-fourth-chapter-repair-20261121/comparison.jpg)에서 다섯 지물을 일반 화면 크기로 봤다. Gloamwood는 밤의 정면에서 뿌리와 부러진 등불 받침이 한 덩어리로 겹치고, 밝은 셰일층은 귀환 사선에서만 구분된다. Haunted Graveyard는 야간 접근에서 보호턱이 짧고 닫힌 석재 덩어리처럼 보인다. 나머지 세 구간에서는 DW 철물의 연결, FV 중계축, EC 관의 개구부가 가까운 귀환 시점에 더 잘 드러난다.

## 비교 사례와 적용

- **Diablo IV: Vessel of Hatred**의 2024-08-21 공개 자료는 Nahantu의 평원·굴·수관에 다른 형태의 오염이 나타난다고 설명한다. TLT에서는 Deepwood의 목재 버팀과 Gloamwood의 뿌리 융기를 구분하고, 같은 숲 안에서도 사건의 원인을 다른 단면으로 전달한다. [Blizzard의 Nahantu 소개](https://news.blizzard.com/en-us/article/24128995/delve-deeper-into-nahantu-with-mercenaries-dark-citadel-and-more)
- **World of Warcraft Retail: The War Within**의 2024-08-14 소개는 고장 난 Ringing Deeps의 산업 시설과 Stonevault의 중앙 처리장으로 이어지는 광차를 함께 보여 준다. TLT에서는 금속 축이나 관의 끝을 받침·통로 쪽에서 읽을 수 있게 해 설비의 이전 쓰임을 짐작하게 한다. [Blizzard의 지역·던전 소개](https://news.blizzard.com/en-us/article/24125258/explore-the-zones-and-dungeons-of-the-war-within)
- **Lost Ark 서구 서비스: Arkesia Ignited**의 2024-10-09 업데이트는 Elnead의 해방 뒤 North Kurzan에서 연합군이 집결한다고 설명한다. TLT의 HG-04에서는 이전에 구한 동료들이 실제로 합류하는 위치에 낮은 길 경계를 배치해 집결과 귀환을 연결한다. [North Kurzan 업데이트](https://www.playlostark.com/en-us/game/releases/arkesia-ignited#north-kurzan)
- **Roblox Creator Hub**는 환경 제작 예시에서 재질이 바뀌는 바닥으로 실내·실외 위치를 식별하게 한다. TLT에는 지역 조명 아래에서 돌의 밝기와 단면으로 길 쪽을 인지시키는 방식을 적용한다. 이 문서의 예시는 1인칭 팀 게임이며, TLT의 3인칭 카메라에서는 별도 확인이 필요하다. [Roblox 환경 제작 지침](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/construct-your-world#floors)

## 환경 제작표

| 장 | 이야기와 기존 화면 | 이번 제작 목표와 화면 기준 |
| --- | --- | --- |
| DW-04 | 정령을 구조하고 안전한 귀환을 연다. 하단 케이블과 철물은 가까이 가야 보인다. | 절삭된 받침 면 앞에서 케이블이 철제 고정점 안으로 이어진다. 접근에서는 석재와 목재가 먼저 읽히고, 귀환에서는 케이블 끝에 시선이 닿는다. |
| GW-04 | 고대 뿌리가 정찰대의 구조 길을 밀어 올렸다. 야간 정면에서 융기와 등불 파손이 겹친다. | 밝은 셰일 두 층의 파단면을 길 쪽에 노출하고 뿌리와 부러진 소켓의 끝결을 서로 다른 높이에서 보여 준다. 정면에서 석재와 목재의 경계를 찾아야 한다. |
| FV-04 | 피난처 신호를 원래 방향으로 돌려 귀환로를 안전하게 만든다. 먼 시점에서는 축이 석축과 겹친다. | 압설에서 받침으로 이어지는 낮은 단면 위에 금속 중계축 끝을 드러낸다. 접근·귀환에서 눈·석재·금속의 경계가 구분되어야 한다. |
| EC-04 | Dagna와 냉각 밸브를 수리한다. 접근에서는 끊긴 관 두 끝이 붙어 보인다. | 파손 단부의 깊이와 비대칭, 받침 위의 침전층으로 단절을 드러낸다. 조사 위치와 가까운 사선에서 두 관 사이의 어두운 간극을 확인한다. |
| HG-04 | Finn의 신호와 Brann의 장치로 안쪽 집결지를 연다. 접근에서 보호턱의 방향성이 약하다. | 길 쪽 석재의 연속 모따기와 가까운 쪽 낮은 끝돌로 열린 방향을 읽게 한다. 신호와 집결한 인물의 실루엣에 시선이 닿아야 한다. |

기존 Roblox 지물과 기본 재질로 각 지물의 높이와 재질 경계를 조정한다. 조명·문구·진행·충돌을 다루는 기준은 [현재 제품 계약](../product-contracts.md)과 [도보 연결 및 스토리 맵 결정](../decisions/2026-11-13.md)을 따른다.

환경 3D와 맵 구현 담당은 동일 조명·카메라의 접근 및 귀환 10쌍과 원본 화면 크기에서 위 단서를 확인한다. QA는 조사 앵커, 피벗, 바닥 표본 및 장식 물리 속성을 비교하고 다섯 구간의 R15 왕복 경로를 점검한다. 실제 플레이 입력으로 GW 야간 첫 발견, EC 조사 각도, HG 동료 집결 뒤 귀환을 확인해야 미술 수용 범위를 넓힐 수 있다. 공식 비교 자료는 문서 열람이며, 레퍼런스 게임의 직접 플레이와 TLT 실기기 성능은 이번 조사 범위 밖이다.
