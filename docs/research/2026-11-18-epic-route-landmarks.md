# 다섯 에픽의 길목 지형·설비 제작표

2026-11-18 · TLT-061 / TLT-065(Gloamwood) / TLT-062 / TLT-063 / TLT-064 · 환경 아트 → 환경 3D·맵 구현·QA · G5

이번 회차는 망루의 구조 보고 지점, 피난처로 이어지는 뿌리길, 기록고 중계기, 쌍수로 밸브, 안개 속 관리인 피난처를 다룬다. 각 장소의 기존 대형 건축이 원경에서 목적지를 가리키고, 새 지형·소품은 어깨와 측벽에서 그 목적지의 용도를 보여준다. 게임 내 스토리 원고, 목표, 상호작용 모델, 지역별 동선으로 제작표의 근거를 맞췄다. [영어 원고](../../src/shared/CampaignStoryText.luau) · [서사 정리](../production/campaign-context-review-2026-11-10.md) · [전투 동선](../production/campaign-combat-routes-2026-11-10.md) · [지역 제품 계약](../product-contracts.md)

## 이전 회차에서 확인한 화면

0.113.10의 근접 비교판에서 DW-02의 구조 쉼터는 지붕과 바닥 사이에 들것 형태가 보인다. GW-01은 밝은 갈라진 심재를 식별할 수 있지만 야간의 수피·암층 일부가 배경에 묻힌다. FV-03은 눈과 대비되는 짙은 수평 부재 덕분에 방풍 울타리가 읽힌다. EC-03은 테두리와 들어 올린 격자가 작업 설비의 용도를 드러내고, HG-03은 차가운 석재와 따뜻한 격자·등불에 명암 차가 있다. 촬영은 지물을 향한 근접 구도라 길목에서 처음 보이는 시점과 귀환 시야는 확인이 필요하다. 기존 DW-02 및 DW-Q1 동선 몸체 접촉과 FV·HG 측면 시야도 후속 검증 대상이다. [0.113.10 비교판](../evidence/epic-story-landmarks-20261118/comparison.jpg) · [시험 범위와 기준선](../evidence/epic-story-landmarks-20261118/README.md)

## 공식 사례와 적용

| 원천 | 공식 자료에서 확인한 사실 | TLT 적용 가설 |
| --- | --- | --- |
| Diablo IV · Blizzard · 2022년 3월 출시 전 미술 개발 글 | Orbei Monastery는 주변의 소박한 건축과 다른 정교한 조형과 파손 상태로 과거의 역할을 드러낸다. Kyovashad는 접근로의 작은 방어 구조에서 성문 규모로 커지며, 개발진은 고정 카메라에서 전투 가독성에 맞춰 디테일을 배치한다. | DW 석축의 마모와 남은 목재가 망루의 옛 용도를 보여주고, HG에서는 낮은 기단이 문과 피난처 사이를 잇는다. 회전 가능한 TLT 카메라에서 전경이 목표를 가리는지 양쪽 방향으로 잰다. [환경 미술 개발 글](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022) |
| World of Warcraft Retail · Dragonflight · 2022년 Azure Span 소개 | 안개 낀 숲과 해안 정착지, 열린 툰드라, 눈·얼음의 고도 변화가 있고, Kalecgos의 목적지로 Azure Archives를 제시한다. | FV의 눈 쌓인 접근로에서 청회색 암반과 규칙적인 인공 홈으로 전환해 기록고의 용도를 살린다. 보행 경사에 손대기 전에 중계기 바깥 낮은 단면으로 명암 차를 시험한다. [Azure Span 지역 소개](https://news.blizzard.com/en-gb/article/23823429/dragonflight-zone-preview-the-azure-span) |
| Lost Ark 글로벌 · Amazon Games · 2021년 9월 출시 전 Luterra 소개 | Yudia는 일대의 소금 자원과 교역 갈등을, East Luterra의 Luoden River는 오염·정화 설비·비옥한 땅을 인과 관계로 묶는다. West Luterra의 전쟁 흔적은 East Luterra와 지역 성격을 구별한다. | EC 수로는 단면·마감과 끝의 결합 형상으로 두 계통 용도를 구별한다. 복구 결과는 기존 밸브·냉각 흐름으로 읽고, 설계 약속이나 용광로 재가동을 새 정적 조형보다 뒤에서 전달한다. [글로벌 Luterra 지역 소개](https://www.playlostark.com/en-gb/news/articles/tales-of-arkesia-luterra) |
| Elden Ring · Bandai Namco Europe · 2022년 기본 게임 출시 소개 | 야외 지형에서 주변 경관에 이어지는 복잡한 Legacy Dungeon으로 접근한다. | GW의 기존 성채와 외곽 흙·뿌리 경계를 이어 개활지에서 뿌리길로 접어드는 감각을 만든다. 기존 통행 조건과 양방향 도보 연결로 검증한다. [Enter the Lands Between](https://en.bandainamcoent.eu/elden-ring/news/elden-ring-enter-the-lands-between-101-trailer) |
| Roblox Creator Hub · 환경 미술 교본 · 게시일 미표기 | 예시 맵은 실내·경계·실외 바닥을 재질로 구분하고 외부의 주요 경로를 별도 지표면으로 드러낸다. | 새 지물은 기존 길의 바깥에서 지면과 맞물리게 둔다. 이동 표본에서 접지·통행 여유를 확인하고, 설비의 위치 단서가 정면과 귀환에서 남는지 비교한다. [Construct your world](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/construct-your-world) |

2026-11-18에 공개 개발 글과 공식 지역 소개를 열람했다. 적용란은 TLT에 대한 가설이며 직접 플레이, 현재 라이브 패치에서의 형태 변화, 방문자 반응은 이 조사에서 미측정이다. [앞선 35장 제작표](2026-11-18-epic-environment-landmarks.md)

## 스토리별 제작표

원천의 ID는 현재 장·목표 정의를 가리킨다. 현행 영문 본문은 양쪽 망루 장치와 구조, 재점등, 중계기 복구, 두 밸브 작동, 기존 선발대 등불의 순서를 유지한다. 지물은 진행 전후 같은 곳에 남으며 각 사건의 변화는 기존 개인 목표·장면이 표현한다. [Deepwood 목표](../../src/shared/DeepwoodContent.luau) · [Gloamwood·Haunted Graveyard 목표](../../src/shared/LateEpicContent.luau) · [Frozen Vale 목표](../../src/shared/FrozenValeContent.luau) · [Ember Caldera 목표](../../src/shared/EmberCalderaContent.luau) · [개인 사건 장면](../../src/server/World/CampaignNarrativeScenes.luau)

| 에픽·스토리와 원천 목표 | 사건·감정과 기존 조형 | 지형·지물과 배치 | 진행 전후 표현과 비교 장면 |
| --- | --- | --- | --- |
| 1 Deepwood · DW-04 · `west_link`, `east_link`, `spirit`, `link_record` | 망루의 두 전원 장치를 멈추고 붙잡힌 숲 친구를 구조한다. 구조 뒤 지도에 점령 폐허의 포로 단서가 나온다. 기존 Watchtower가 원경이고 망루 앞은 두 장치와 감옥을 오가는 곳이다. | `WatchtowerSignalFooting`을 `link_record` 바깥에 둔다. 낮은 비대칭 이끼 석축과 짧은 목재 버팀으로 오래된 망루의 측면을 잡고 밝은 돌 모서리는 지도 쪽을 드러낸다. | 지도와 지름길은 기존 상호작용으로 읽힌다. 망루 첫 진입 → 서·동 장치 → 감옥 → 지도 → 돌아오는 구간에서 석축과 두 장치가 각각 읽히고 회피 중 감옥이 가려지지 않는지 확인한다. |
| 2 Gloamwood · GW-04 · `ent`, `lantern` | Ancient Hollowbark를 지나고 등불을 켜 정찰대의 귀환길을 확보한다. 기존 `HollowbarkRootBastion`이 뿌리에게 잠식된 구간을 구획한다. | `RootwayBankCut`을 `lantern` 쪽 길 바깥에 접지한다. 낮고 긴 흙 단면을 비대칭 뿌리로 붙들고 밝은 심재와 쐐기 끝으로 어두운 수피의 윤곽을 이어준다. | Hollowbark와 통행 상태는 기존 사건이 맡는다. 뿌리길 입구, 전투 가장자리, 점등 직전과 직후, 피난처 방향 역주행에서 열린 바닥과 기존 램프 시야를 본다. |
| 3 Frozen Vale · FV-04 · `relay_west`, `relay_east`, `ylva`, `exp_2` | `SubglacialRelayHall`의 양쪽 중계기를 수리한 뒤 피난로에 한해 온전한 신호를 보낸다. 요새와 왕궁의 오경보는 뒤의 사건이다. | `WestArchiveConduitBed`와 `EastArchiveConduitBed`를 각각 `relay_west`와 `relay_east`를 기준으로 배치한다. 청회색의 낮은 석조 턱, 홈에 묻힌 무발광 도관, 눈이 쌓인 받침으로 장치의 바깥을 잡는다. | 기존 보라색 오경보와 복구 후 청록색 신호가 상태를 표시한다. 서쪽에서 처음 보는 구도, 양쪽 중계기를 오갈 때, 수호수 반응을 볼 때, 요새 쪽 진출과 역방향에서 지면·중계기 본체를 각각 확인한다. |
| 4 Ember Caldera · EC-04 · `engineer`, `west_valve`, `east_valve`, `plans` | Orik의 배치도를 Dagna에게 전달한 뒤 `TwinPumpHouse`의 두 채널 밸브를 열어 냉각을 되돌린다. 도시 보호 회로는 다음 장의 설계 자료에서 드러난다. | `WesternIntakeSluice`는 `west_valve` 바깥의 좁고 규칙적인 석축과 고정 금속 여과망, `EasternReturnRace`는 `east_valve` 바깥의 넓고 벌어진 현무암과 침전 바닥으로 구분한다. 밸브의 활성 색 없이도 두 윤곽이 달라야 한다. | 마른 기단은 고정이다. 첫 밸브와 두 번째 밸브 작동 결과는 기존 흐름과 문구로 나뉜다. Dagna 쪽 첫 진입, 각 밸브의 조작 구도, 두 밸브 사이, 설계도와 기록고 방향 귀환에서 구별 여부를 본다. |
| 5 Haunted Graveyard · HG-01 · `rook`, `lantern_guards`, `shelter` | Rook을 만나 Finn과 Tali가 남긴 등불을 따라가면 Garrick이 기다리는 피난처에 닿는다. 규모가 큰 `KeeperGate` 뒤에서 작은 안내 단서가 필요하다. | `KeeperLanternRevetment`를 `shelter` 접근부 외곽에 배치한다. 낮은 풍화 석재와 열린 측면의 기단은 기존 등불과 바닥 사이의 연결 면을 보여준다. | 기존 등불과 개인 사건이 안내를 맡는다. Rook → 안개 길목에서 등불이 처음 보이는 각도 → 피난처 진입 → 묘역을 등진 귀로에서 기단이 등불·실루엣 또는 교전 예고를 가리는지 확인한다. |

## 구현·검증 인계

공유 `model.forest-kit`, TD의 `maps-mesh-v2` 원본과 기존 지역 건축을 먼저 검토했다. `ForestLandmark`와 `CemeteryLandmark`는 원경 규모에 맞아 낮은 지물의 형상으로 재사용하기 어려웠다. 이번 장면의 낮은 단면에는 각 지역 팔레트에 맞춘 Roblox 기본형 모듈을 사용한다. 장식의 크기와 비용을 제한하고, 기존 벽·길·전투 구역에 닿지 않는 접지 후보만 채택한다. 기존 TD 자산의 관리 기준과 에픽 사이 도보 연결을 적용한다. [공유 자산 레지스트리](../../assets/shared/td-asset-registry.json) · [TD 맵 원본과 해시](../../assets/shared/td-deepwood-environment/manifest.json) · [지역 건축 원본](../../assets/models/regional-architecture-blender-v1/README.md) · [지역 소품 배정](../../src/server/World/StoryPropAssignments.luau) · [맵 구성 규칙](../production/story-map-composition-2026-11-12.md) · [도보 연결 결정](../decisions/2026-11-13.md)

비교 프레임에서는 같은 카메라·조명·진행 상태로 기존과 후보를 촬영한다. 첫 위치에서 목적지가 보이는지, 중간 교전에서 적 예고와 다음 장치를 함께 읽는지, 역방향에서 안전한 길을 찾는지 관찰한다. 원본/Easy 통행·몸체 여유와 모델 접지·쿼리·충돌·파트 수는 Studio에서 검사한다. 실제 R15 양방향 보행·회피, 터치 기기의 프레임 시간, 두 진행 상태의 동시 이용, 게시 클라이언트, 사용자 미술 수용은 증거를 확보한 단계만 통과로 기록한다. [맵 제작 수용 기준](../../agent.md#맵-제작-호출과-공통-수용-기준) · [G5 티켓](../tasks/09.md)
