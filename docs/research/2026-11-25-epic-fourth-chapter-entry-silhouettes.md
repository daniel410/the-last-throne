# 에픽 4장 복구 동선의 사건 입구

2026-11-25 Toronto · G5 · TLT-061/DW-04 · TLT-065/GW-04 · TLT-062/FV-04 · TLT-063/EC-04 · TLT-064/HG-04

직전 2·3장 비교판에서 2장 Gloamwood의 낮은 셰일과 뿌리는 야간 노면에 묻혔고, 3장 Deepwood의 새 목기둥과 입구 표지판은 화면에서 가까워졌다. 기존 4장 설비에서도 Gloamwood 목재 윤곽이 약했고 Ember Caldera의 관은 접근할 때 한 선에 겹쳤다. 4장 입구에서는 길 중앙을 열고 측면에 구조·정비·기록의 단서를 둔다. Gloamwood는 붕괴 조사 구간 다음의 Root Refuge Connection을 택해 정찰대가 피난처로 돌아가는 방향을 입구에서도 읽을 수 있게 한다. [2장 입구 비교](../evidence/epic-second-chapter-entry-silhouettes-20261125/README.md) · [3장 입구 비교](../evidence/epic-third-chapter-entry-silhouettes-20261125/README.md) · [기존 4장 설비 비교](../evidence/epic-fourth-chapter-maintenance-profiles-20261125/README.md)

## 공식 사례와 적용

- **Diablo IV.** Scosglen 해안은 바람에 눕는 풀과 현지 돌·재활용 목재로 해안의 기후와 생업을 나타낸다. TLT에서는 Deepwood의 석재 위 목제 셔터와 Gloamwood의 셰일 위 노출 뿌리를 서로 다른 시공과 침식의 결과로 조형한다. [Blizzard 환경 제작기](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- **World of Warcraft.** The Ringing Deeps는 용광로와 노후 기계에 주민들의 유지보수 작업을 연결한다. TLT에서는 Ember Caldera의 받침과 열린 플랜지로 냉각관이 지면에 고정되는 방식과 조사할 방향을 드러낸다. [The War Within 지역 소개](https://news.blizzard.com/en-gb/article/24125258/explore-the-zones-and-dungeons-of-the-war-within)
- **Lost Ark.** Voldis 제작진은 현자들의 지식과 탐구 의지를 거대한 탑의 실루엣에 담았다. TLT에서는 Frozen Vale의 층진 석재와 기록 슬롯으로 입구에서 기록 시설의 용도를 전달한다. [Voldis 개발자 인터뷰](https://www.playlostark.com/en-us/news/articles/creating-voldis)
- **Roblox.** The Mystery of Duvall Drive 제작진은 접근 경로에서 건물의 일부를 먼저 드러내고 아바타를 기준으로 문과 계단의 비례를 확인했다. TLT에서는 진입 시 구조의 외곽을, 귀환 시에는 같은 지물의 접합부를 확인하고 아바타 왕복으로 중앙 통로를 검사한다. [Roblox Creator Hub 공간 제작기](https://create.roblox.com/docs/resources/the-mystery-of-duvall-drive/construct-the-house)

## 제작표

| 에픽·사건 | 입구에서 읽을 역할 | 지형과 구조 |
| --- | --- | --- |
| DW-04 · `exp_1` · Watchtower Rescue Court | 구조 뜰에서 측문과 망루 신호 장치가 막힌 원인을 찾는다. | 한쪽 석재 받침에 경첩과 목제 신호 셔터를 얹고 반대편에는 낮은 파손 문턱을 둔다. |
| GW-04 · `exp_2` · Root Refuge Connection | 안쪽 뿌리길을 피난처에 다시 연결한다. | 셰일 옹벽에서 밝은 심재가 드러난 뿌리가 뻗고, 맞은편 낮은 암반에 로프 체결 흔적이 남는다. 기존 방향판이 야간 유도의 기준이다. |
| FV-04 · `exp_1` · Archive Signal Galleries | 기록고에서 원래 피난 신호와 변조된 경보를 대조한다. | 층진 판석과 압설을 양쪽에 쌓고 석재 외곽에 열린 기록판 슬롯을 둔다. 판의 해석은 기존 조사 단계에서 드러난다. |
| EC-04 · `exp_1` · Coolant Flow Inspection | 마른 유입관을 따라 첫 막힘을 찾는다. | 양쪽의 낮은 현무암 받침에 열린 플랜지와 건식 가이드를 배치한다. 관의 열린 단면으로 점검 방향을 읽을 수 있다. |
| HG-04 · `exp_1` · Dwarven Gate Workshop | 성문 윈치에 필요한 닻틀과 작업 동선을 확인한다. | 비대칭 하중 받침 위 철제 가로빔과 대각 버팀으로 성문 앞 준비 작업을 표현한다. |

기존 사건 진입점과 표지판을 기준으로 Roblox 네이티브 부품을 배치한다. 조형은 공유 공간에 놓인 구조와 작업 흔적을 표현한다. 장치 복구와 통행 해금은 기존 퀘스트 단계가 담당한다. [캠페인 4장 사건 데이터](../../src/shared/CampaignExpansionContent.luau) · [제품 계약](../product-contracts.md)

## 수용 조건

- 기준·후보에서 진입과 귀환을 동일한 55도 카메라로 기록한다. 첫 접근에서는 다섯 입구의 실루엣과 표지판, 귀환에서는 지역별 재료 접합과 구조의 용도를 확인한다. Gloamwood는 야간 방향판의 구조물 가림과 뿌리 심재 대비를 함께 본다.
- 다섯 입구에서 R15가 점프 없이 양방향으로 각각 32스터드를 걷는다. 입구별 65표본에서 바닥 높이와 몸체 여유를, 54개 시점의 108개 광선에서 표지판과 이름표의 시야를 검사한다. 영구 충돌 감사 후 사건 좌표·피벗과 비대상 입구 77개를 기준 빌드에 대조하고 캠페인 회귀를 실행한다.
- Studio 결과를 게시 클라이언트, 실기기, 사용자 미술 수용과 구분해 기록한다.
