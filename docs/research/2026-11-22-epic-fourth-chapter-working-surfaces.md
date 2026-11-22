# 다섯 에픽 4장 복구 설비의 단면과 귀환 방향

2026-11-22 · TLT-061/DW-04 · TLT-065/GW-04 · TLT-062/FV-04 · TLT-063/EC-04 · TLT-064/HG-04

환경 아트가 [기존 접근·귀환 10쌍](../evidence/epic-fourth-chapter-readability-20261121/README.md)과 현행 4장 지물 배치를 대조했다. Gloamwood의 부러진 등불 소켓은 야간 정면에서 뿌리에 묻히고, Haunted Graveyard의 보호턱은 집결로 접근에서 닫힌 석재 덩어리로 보인다. Deepwood 케이블 고정부, Frozen Vale 중계축, Ember Caldera 관의 개구부는 가까운 귀환 시점에서 읽힌다.

## 공식 사례

- **Diablo IV**의 환경 아트 개발 노트는 시점과 플레이 공간에 맞춘 세부 묘사와 명암, Scosglen의 사건을 전하는 사물을 설명한다. TLT에서는 망루 철물의 하중 지점과 뿌리에 깨진 소켓의 끝결을 접근 시점에 노출한다. [2022년 3월 환경 아트 개발 노트](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- **World of Warcraft: The War Within**은 정비가 필요한 Ringing Deeps 설비와 Stonevault 내부의 광차 동선을 함께 보여 준다. TLT에서는 중계축 받침과 냉각관의 파손 테두리 및 침전 자국으로 설비의 진행 방향을 드러낸다. [지역·던전 소개](https://news.blizzard.com/en-us/article/24125258/explore-the-zones-and-dungeons-of-the-war-within)
- **Lost Ark: Arkesia Ignited**는 Elnead 해방 이후 North Kurzan에 연합군이 집결하는 전개를 설명한다. TLT에서는 길을 따라 낮아지는 마모 석재의 상단선으로 집결과 귀환을 공간에서 연결한다. [North Kurzan 업데이트](https://www.playlostark.com/en-us/game/releases/arkesia-ignited#north-kurzan)
- **Roblox** 환경 아트 회색 상자 제작 지침은 캐릭터 시점에서 고저차와 시야선을 시험한다. TLT에서는 기존 조사점에 이르는 접근과 반대 편 귀환에 같은 검증 카메라를 사용한다. [환경 시야선 검증](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/greybox-your-environment)

## 제작표

사건과 설치 위치는 `CampaignContent.byId`의 장별 `expansionGoals` 및 `EpicQuestLandmarkAssemblies`의 배치를 기준으로 삼는다. 모델은 기존 Roblox 기본 재질과 조형을 재사용한다.

| 장 | 사건과 구간의 역할 | 표현과 비교 기준 |
| --- | --- | --- |
| DW-04 | 정령 구조 후 이어지는 망루 귀환 | 석축 절삭면과 철제 앵커가 케이블 끝을 받친다. 귀환 사선에서 케이블·철물·석재의 접합을 비교한다. |
| GW-04 | 고대 뿌리가 밀어 올린 정찰로 | 부러진 등불 소켓 끝결과 밝은 셰일 파단면을 분리한다. 야간 첫 접근과 귀환에서 두 실루엣을 비교한다. |
| FV-04 | 피난처 신호 복구 뒤 귀환 | 금속 중계축과 이를 감싼 석목 받침, 낮은 압설을 구분한다. 접근·귀환에서 조정축의 방향을 비교한다. |
| EC-04 | Dagna와 냉각 밸브 복구 | 서로 다른 높이의 파단 테두리와 광물 침전으로 관 사이 틈을 드러낸다. 조사점 접근과 측면에서 두 관을 비교한다. |
| HG-04 | Finn의 신호와 Brann의 장치 이후 집결 | 보호턱 상단을 도착 쪽으로 낮춰 통행 방향을 연다. 야간 접근·귀환 실루엣과 동료 집결 위치의 이격을 확인한다. |

비교 자료는 공식 문서 검토 결과다. TLT 모델은 기존 앵커·피벗·배치 외곽, 바닥 접지와 조사점까지의 보행으로 검증한다. 실제 스토리 조작과 기기별 판독은 수용 검증 범위다.
