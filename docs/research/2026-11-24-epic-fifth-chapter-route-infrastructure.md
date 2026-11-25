# 다섯 에픽 5장 이동로와 작업 시설

2026-11-24 · TLT-061/DW-05 · TLT-065/GW-05 · TLT-062/FV-05 · TLT-063/EC-05 · TLT-064/HG-05 · G5 · 환경 아트 → 환경 3D·맵 구현 → QA

앞선 5장 비교판에서는 병영 보급로, 정찰 난간 받침, 차륜 흔적, 시험 모형 포집조, 동쪽 도관 받침의 접근과 귀환 가독성을 다뤘다. 이번에는 각각 다른 사건의 2단계로 이동한다. 건너야 할 길목과 작업 시설이 그곳에 생긴 이유를 지면 단차, 재료 접합, 마모 방향으로 전달한다. [기존 5장 제작표와 비교 증거](2026-11-23-epic-fifth-chapter-approach-silhouettes.md) · [본편 서사](../production/campaign-context-review-2026-11-10.md) · [실제 사건 순서](../../src/shared/CampaignExpansionContent.luau)

## 공식 레퍼런스

2026-11-24에 공식 자료를 확인했다. TLT 적용은 각 사례에서 도출한 제작 판단이다.

| 사례 | 공식 자료의 관찰 | TLT 적용 |
| --- | --- | --- |
| Diablo IV · Vessel of Hatred | Nahantu 안에서도 Skittering Earth는 독에 오염된 굴, Lingering Hatred는 Hollows가 차지한 수관으로 위협과 서식지를 연결한다. [Blizzard의 Nahantu 소개](https://news.blizzard.com/en-gb/article/24128995/delve-deeper-into-nahantu-with-mercenaries-dark-citadel-and-more) | GW 사냥터의 낮은 분지와 외곽 셰일 턱을 높이와 재질로 구별한다. 턱의 층리와 이어지는 방향으로 물러날 수 있는 길을 보여 준다. |
| World of Warcraft Retail · The War Within | Ara-Kara는 현재의 City of Threads 아래 버려진 옛 층이다. 기존 도시 구조가 현재 세력의 채취 시설을 품고 있다. [Blizzard의 지역·던전 소개](https://news.blizzard.com/en-us/article/24125258/explore-the-zones-and-dungeons-of-the-war-within) | HG에서 오래된 조적과 그 벽을 이용하는 서쪽 방어 도관을 접합부로 연결한다. FV에서 구 보급 터널의 조적과 통행을 위한 고정 철물을 층으로 구별한다. |
| Lost Ark 글로벌 · Summer Heat | 봉인된 Kazeros의 힘이 Mount Antares의 화산 작용을 타고 지표에 스며든다는 설정이 South Kurzan의 조사 동기를 만든다. [Amazon Games의 South Kurzan 소개](https://www.playlostark.com/en-gb/game/releases/summer-heat) | EC에서 현무암 표면과 비상 회수 계통의 가공 금속을 함께 배치해 주위 지질과 기술자가 제어하는 흐름이 한 시설 안에서 읽히게 한다. |
| Roblox · Creator Hub 환경 아트 | 샘플은 실내 바닥과 외부에 가까운 바닥에 다른 재질을 써서 플레이어가 자신의 위치를 파악하게 한다. [Construct your world](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/construct-your-world) | 플레이어가 밟는 바닥은 현행 형태를 유지한다. 길가 조립체에서 다져진 흙, 셰일, 압설, 현무암, 조적의 접합으로 공간별 쓰임을 드러낸다. |

## 에픽별 제작표

| 스토리 · 사건 · 단계 | 환경 3D 제작 방향 | 플레이 시 확인할 점 |
| --- | --- | --- |
| DW-05 · Prison Escape Yard · `exp_1` 2단계 | `PrisonWalkwayWheelStop`. 매입한 냇돌 받침과 낮은 흙턱에 목재 멈춤목을 대어 수레가 구조 호송로 가장자리에 정차하는 이유를 드러낸다. | 빈 수레 쪽에서 보행로가 어느 방향으로 이어지는지 읽힌다. 통로 확보와 집결 등불 점등은 현행 단계 순서로 보인다. |
| GW-05 · Venomcoil Trail Shelf · `exp_1` 2단계 | `HuntingBankShaleCut`. 밝은 셰일 층을 조금씩 어긋나게 쌓고 바깥쪽 경사 둑에 붙여 분지 가장자리의 단차를 조형한다. | 낮은 분지와 외곽의 물러날 길이 접근과 귀환 양방향에서 구분된다. 야간에는 셰일 단면과 배경의 밝기 차를 확인한다. |
| FV-05 · Old Supply Tunnel · `exp_2` 2단계 | `TunnelHandrailFooting`. 해빙수가 흐른 석재 문턱과 압설에 목재 지주의 사선 보강을 배치하고 설면 가까운 지지부에 재질 차를 둔다. | 터널 손 윈치 이후 손잡이로 이어지는 방향이 보인다. 눈 위에서 고정 구조가 구별되고 Ivo의 만남 표지가 기존 위치에서 읽힌다. |
| EC-05 · Ancestral Circuit Gallery · `exp_1` 2단계 | `EmergencyReturnFlume`. 판독 위치 곁 내화턱과 비상 회수 수로에 묵은 퇴적을 두어 흐름이 꺾이는 방향을 드러낸다. | 유입 도면 다음에 읽는 비상 회수 도면의 기능을 주변 시설이 뒷받침한다. 도면·보호 모형과 기술자 시야가 계속 확보된다. |
| HG-05 · Throne Shield Connection · `exp_1` 2단계 | `WesternConduitWallSleeve`. 석회암 벽부와 철제 관통부의 개구로 서쪽 도관이 벽 안에 연결되는 방향을 보여 준다. | 야간의 사선에서 조적과 고정구가 구별되고 도관의 방향이 읽힌다. 귀환 아치와 방어선 차단은 기존 단계에서 드러난다. |

## 통합과 검증

모델러는 기존 지역 팔레트와 Roblox 네이티브 형상을 사용한다. 맵 구현은 조립체 바닥의 접지와 목표 시야를 먼저 확인하고 길가에 배치한다. 사건 시작 전에도 존재할 수 있는 구조와 마모를 공용 월드에 두고 장치 상태 및 단서 공개 시점은 각 사건 단계에 맡긴다.

고정된 기준·후보 빌드에서 같은 조명 및 카메라의 접근·귀환 화면 각 다섯 장을 비교한다. 기단 틈, 기존 조사점·인물·지물 시야, 보행 이격, 바닥 높이, 추가 파트 수와 장식의 충돌·쿼리 속성을 기록한다. 사건 2단계에서 R15가 조사점의 마지막 접근 구간을 점프 없이 왕복하는지 검증하고 캠페인 진행 회귀를 확인한다. 환경 아트와 QA는 게시 클라이언트와 터치 실기기에서 최초 발견을 관찰하고, 전투 중 시야와 파티 스트리밍, 사용자 미술 수용을 별도로 확인한다.
