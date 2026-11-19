# 다섯 에픽의 접근로 단면과 조사 지물 판독

2026-11-19 UTC · G5 · TLT-061 (Deepwood) / TLT-065 (Gloamwood) / TLT-062 (Frozen Vale) / TLT-063 (Ember Caldera) / TLT-064 (Haunted Graveyard)

0.113.23 Studio 비교에서 Frozen Vale 암빙은 가까이서 눈 바닥과 분리됐지만 먼 굽이에서 화면 중앙의 표지판과 등화에 겹쳤다. 방풍 울타리는 왼쪽에 작게 보였다. Gloamwood 뿌리와 Haunted Graveyard 석조는 야간 배경에 묻혔고, Deepwood 둔턱과 Ember Caldera 현무암은 긴 직선 평면이 두드러졌다. 기존 단면 다섯 개를 대상으로 암빙을 우선 시험하고, 지역별 자연 단면과 조사 시설이 서로 다른 형태로 읽히게 다듬는다. [0.113.23 고정 카메라 비교](../evidence/epic-approach-contours-20261119/comparison.jpg) · [Studio 기준선](../evidence/epic-approach-contours-20261119/README.md)

## 공식 RPG 사례

| 사례 | 2026-11-19 공개 원문에서 확인한 사실 | TLT 적용 가설 |
| --- | --- | --- |
| Diablo IV · 환경 아트 개발 글 · 2022년 3월 | Flooded Depths는 마르고 비교적 온전한 상층과 침수로 썩은 하층을 이어 환경 변화와 이동을 보여 준다. 개발팀은 플레이 공간의 실루엣과 카메라에서 보이는 디테일의 양을 조절한다. | DW의 습지 실트와 HG의 석조 물때를 아래에 집중하면 발밑의 변화를 형상과 재질로 읽을 수 있다. GW와 HG는 기존 밤 조명에서 윗면에 드러나는 재질 차를 시험한다. [Blizzard 환경 아트 개발 글](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022) |
| World of Warcraft Retail · The War Within · 2024년 지역 소개 | The Ringing Deeps에는 Machine Speakers가 금속을 녹이는 용암 가열 용광로와 고장 난 설비를 관리하는 Stonevault가 있다. | EC의 암석 절개는 자연 암반을, 밝은 원형 계기와 배관은 작업 설비를 드러낸다. 계곡의 자연 암빙과 인간이 설치한 FV 울타리에도 같은 방식으로 형태 차를 둔다. [Blizzard 지역·던전 소개](https://news.blizzard.com/en-us/article/24125258/explore-the-zones-and-dungeons-of-the-war-within) |
| Lost Ark 글로벌 · Elgacia · 2023년 디렉터 인터뷰 | Gold River는 공중섬의 도서관과 신전까지 지상 대륙과 다른 콘셉트로 설계했다고 설명했다. | 같은 조사 구조라도 GW의 가지가 넓게 굽은 피난처와 HG의 수평 석조 관리 통로가 서로 다른 재질·윤곽을 갖게 한다. [Gold River 인터뷰](https://www.playlostark.com/en-gb/news/articles/elgacia-lore-interview-with-gold-river) |
| Roblox Creator Hub · 환경 미술 교육과정 | 샘플은 시야와 교전 거리를 만드는 높낮이를 보존하면서 실내·외 표면을 다른 재질로 구별한다. | 장식 단면을 길 가장자리에 두고 보행면을 확보한다. 원경 구도에서 표지와 모델이 겹치는지 먼저 보고, 근경에서 재질과 접지를 비교한다. [Roblox Creator Hub](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/construct-your-world) |

비교는 공식 문서와 TLT 고정 빌드 화면을 기반으로 했다. 참고작 직접 플레이와 실기기 판독은 후속 검증이다.

## 모델 제작표

| 에픽·스토리 | 원천과 사건 | 기존 형상 → 제작 방향 | 플레이 화면 수용 조건 |
| --- | --- | --- | --- |
| Frozen Vale · FV-03 Wolf Ravine | `CampaignStoryText[FV-03]` · 협곡지기를 구조하고 양쪽 봉화를 복구한다. | 굽이의 높은 암빙 덩어리 → 눈 아래로 낮아지는 비대칭 암빙과 바람에 쓸린 완만한 가장자리. 원경에서 기존 표지판·등화와 암빙의 윤곽이 겹치면 높이 또는 외곽 오프셋을 조정한다. | `FV-03_bend` 진행 방향에서 표지판과 봉화가 각각 보이고 방풍 울타리의 판독을 방해하지 않는다. `FV-03_windcut`에서 바위·얼음·눈이 바닥과 닿는다. 최초 발견 거리는 실제 이동 입력으로 별도 측정한다. |
| Deepwood · DW-Q1 Supplies in the Marsh | `CampaignStoryText[DW-Q1]` · 침수 구역의 방수 명단을 찾아 생존자에게 가져간다. | 길게 뻗은 판형 둔덕 → 낮은 수변 실트, 끊어진 자갈, 마른 상부 잔디로 이어지는 침식 단면. 보급대가 마른 지반 위에 놓인 이유를 드러낸다. | `DW-Q1_floodcut`의 습지 진입에서 침식면이 물줄기와 마른 작업면을 구별한다. 보급품 조작면과 보고 방향의 통과 폭을 확보한다. |
| Gloamwood · GW-03 Lantern Refuge | `CampaignStoryText[GW-03]` · Maeve의 피난처에 Tali를 데려가 지도에서 다음 구조 경로를 확인한다. | 야간에 한 덩어리로 보이는 뿌리 → 낮게 갈라지는 수피와 좁고 따뜻한 노출면. 쉼터 입구에서 지도판으로 시선이 이어지게 뿌리 윗면과 끝단을 조절한다. | `GW-03_root_shelf` 야간에서 뿌리와 쉼터 기둥을 구별하고 지도판 전면을 본다. 모바일에서는 해상도와 조명이 다른 상태에서 다시 확인한다. |
| Ember Caldera · EC-06 Geothermal Heart Testworks | `CampaignStoryText[EC-06]` · 보호 회로를 실제 열에서 시험해 대용광로 복구 근거를 얻는다. | 계기 뒤 큰 사각 현무암 → 높이가 서로 다른 절개면과 좁은 층리. 보호 배관의 규칙적인 형태와 구분한다. | `EC-06_cutbank`에서 계기의 원형 면과 배관 진행 방향이 먼저 보인다. 양쪽 접근 중 암반이 계기 윤곽을 가리지 않는다. |
| Haunted Graveyard · HG-03 Lumi Secret Passage | `CampaignStoryText[HG-03]` · 좁은 관리 통로에서 성문 윈치 안쪽에 도달한다. | 바닥과 섞이는 폐석 → 마른 석조 상단과 어두운 젖은 기단으로 나뉘는 낮은 둘레. 석조 절개를 점검함이 있는 귀환면으로 연결한다. | `HG-03_retaining_ruin` 야간에서 낮은 덮개 돌과 점검함의 개구부를 구별한다. 관리 통로의 접근과 귀환에서 윈치 시야 및 통과 폭을 확보한다. |

장면 원천은 [캠페인 런타임 원문](../../src/shared/CampaignStoryText.luau), [캠페인 맥락](../production/campaign-context-review-2026-11-10.md), [전투 동선](../production/campaign-combat-routes-2026-11-10.md)이다.

## 자산·검증 인계

- 공유 레지스트리의 `model.maps` (SHA-256 `4374cb7c66869fc1e9e9a8a3cc2f1fe5ee70564b5b875ed79232adf9542cfc39`)의 바위·설원·묘지 복합 랜드마크와 `model.forest-kit` (SHA-256 `d08038b65d548abf742d5517b46265c3d2e4688f42f04170341c639d3a0278d5`)의 하천 식생·연속 지형 후보를 검토했다. 이번 단면은 높이, 분기, 축 방향을 현장에서 조절할 수 있는 기존 RPG 네이티브 입체를 재편집하는 방식이다. 편집 원본은 `EpicApproachContours.luau`의 피벗 기준 형상이다. TD 자산과 팔레트 참조는 [공유 자산 레지스트리](../../assets/shared/td-asset-registry.json)에서 추적한다.
- 단면은 조사 전후에 성립하는 고정 지형이다. 상호작용, 봉화 점등, 조사 성공, 접근 제한과 진행 판정은 [제품 계약](../product-contracts.md)의 기존 스토리 상태가 표현한다. 모델링 비용은 Studio의 실제 생성 모델·부품 수로 기록하고 실기기 프레임 비용은 기기 검증 때 측정한다.
- FV부터 같은 카메라·조명으로 전후를 비교한다. 다섯 단면의 접지, 장식의 물리·쿼리 속성, 조사 좌표, 기존 FV/HG 충돌과 보행을 Studio에서 확인한다. QA가 DW-Q1 회수 및 보고를 실제 입력으로 재현하고 FV 첫 발견, GW·HG 야간 판독을 게시 클라이언트와 터치 기기에서 확인한다.
