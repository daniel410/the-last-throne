# 다섯 에픽 6장 피난·정비 시설의 판독 개선

2026-11-21 UTC · TLT-061/DW-06 · TLT-065/GW-06 · TLT-062/FV-06 · TLT-063/EC-06 · TLT-064/HG-06 · 환경 아트 제작표

## 기존 화면 리뷰

직전 제작은 네 개의 에픽 경계에 집중했다. 이번 작업은 각 에픽 안에서 최종 장소에 닿기 전 구조, 안전 확인, 귀환을 맡는 6장에 적용한다. 0.114.16 Studio 접근·귀환 화면에서 DW 배수로는 풀밭과 맞닿은 단면보다 평평한 석재 상면이 먼저 보인다. GW 끌것은 야간에 낮고 어둡다. FV의 석축 끝과 EC의 내화벽돌은 측면에서 구분되며, HG의 난간 윗부분은 접근 화면에서 석조 받침과 겹쳐 보인다. 이 관찰은 이전 고정 카메라 화면을 기준으로 한다. [6장 Studio 비교판](../evidence/epic-sixth-chapter-landmarks-20261120/comparison.jpg) · [현재 본편 서사](../production/campaign-context-review-2026-11-10.md)

## 공식 사례와 적용

- **Diablo IV.** 환경 아트팀은 Scosglen에서 바람 방향과 해안 침식을 식생과 지형에 드러내고, 게임 카메라에서 필요한 세부에 밀도를 집중했다. DW는 물에 쓸린 경사와 배수구 입구의 높낮이, FV는 바람그늘에 쌓인 압설과 노출된 석조 단면으로 형성 과정을 보여 준다. [Blizzard 환경 아트 제작기](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- **World of Warcraft.** The Ringing Deeps의 Machine Speakers가 맡은 일은 낡은 제련 시설에 드러난다. Hallowfall의 결정은 구역 여러 방향에서 눈에 띈다. EC 관측소에서는 차열 구조의 바깥층과 안전한 정비 방향을 구분하고, GW에서는 먼저 보이는 Finn의 등불 다음에 목재 끌것의 작업 면이 드러나도록 한다. [Blizzard 지역 소개](https://news.blizzard.com/en-gb/article/24125258/explore-the-zones-and-dungeons-of-the-war-within)
- **Lost Ark.** Smilegate RPG는 Voldis의 현자 탑을 그곳의 지식과 기술을 표현하는 건축물로 설명한다. TLT에서는 HG 왕릉의 닳은 난간과 교체 흔적을 통해 관리인이 오랫동안 사용한 퇴로를 암시한다. 심장 회수나 봉인 해제는 기존 사건이 전달한다. [Smilegate RPG 제작 인터뷰](https://www.playlostark.com/en-us/news/articles/creating-voldis)
- **Roblox.** Creator Hub의 그레이박스 과정은 캐릭터 축척과 통과 난이도를 확인한다. 기존 다섯 접근 경로를 동일 카메라와 R15로 비교한다. [Roblox 환경 제작 가이드](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/greybox-your-environment)

## 장별 제작표

| 에픽 · 구간 | 서사와 모델링 의도 | 접근·귀환 수용 장면 |
| --- | --- | --- |
| **DW-06** · Rootwood Refuge Path | 가족이 되찾는 제단 접근로다. `RefugePathDrain`의 깎인 흙, 석재 배수 입구, 노출 뿌리가 서로 이어지도록 바닥과 만나는 단면을 다듬는다. | 조사 방향에서 마른 배수구 입구가 보인다. 귀환 측면에서 뿌리가 석턱에 걸쳐 있고 시설이 길옆 지면에 붙어 보인다. |
| **GW-06** · Finn의 본선 합류점 | 구조된 정찰대가 함께 돌아오는 장소다. `ScoutExtractionSkid`의 앞이 들린 러너와 마모된 목재 상면으로 운반 도구의 용도를 드러낸다. | 야간 전진·귀환에서 끌것의 앞단과 러너 한 줄 이상이 구분되고, Finn과 기존 등불이 먼저 위치를 알려 준다. |
| **FV-06** · Citadel Lock Courts 동쪽 관리로 | 두 잠금 뒤 요새 신호를 전달한다. `CitadelServiceCoping`의 압설, 어두운 석조, 비활성 전달관 끝을 각기 다른 면으로 읽히게 한다. | 접근에서 끝단이 눈과 구별된다. 귀환 시점에서 관과 눈이 쌓인 받침을 함께 확인할 수 있고, 조사 장치가 별도로 보인다. |
| **EC-06** · Heatworks Service Gallery | 본 용광로 재가동 전에 보호 회로를 시험한다. `HeatworksObservationBaffle`에서 내화벽돌과 현무암의 두께, 사람이 설 쪽의 금속 차열면을 드러낸다. | 진입에서 차열벽의 단면이 구분된다. 돌아설 때는 차열판과 기존 시험 장치가 떨어져 보이며 시험 전에 발광이나 가동 상태를 예고하지 않는다. |
| **HG-06** · Final Shelter Antechamber | 봉인을 열고 돌아올 길을 확인한다. `AntechamberRailFooting`에서 밝게 닳은 석재 턱과 어두운 금속 난간이 한 시설로 읽히게 한다. | 야간 접근과 귀환에서 낮은 석조와 난간 윗면의 높이 차가 드러난다. 기존 표식과 상호작용 위치가 함께 보인다. |

새 안내등을 배치하는 안은 GW의 기존 등불과 경쟁하고, EC·FV의 가동 장식은 영웅별 진행 상태를 앞서 보여 줄 수 있다. 기존 조립체의 윤곽과 재질 단면을 조정하는 안을 채택한다. 환경 3D는 기존 Roblox 네이티브 조립체와 지역 팔레트를 사용한다. 맵 구현은 장식의 고정·비충돌·비터치·비쿼리 속성, 조사 앵커와 보행 폭을 비교한다. QA는 접지, 주·야간 동일 카메라와 R15 왕복을 확인하고 실제 입력에서 최초 발견과 조사 조작을 따로 기록한다. [기존 조립체 소스](../../src/server/World/EpicSixthChapterLandmarks.luau) · [기준 측정과 재현 절차](../evidence/epic-sixth-chapter-landmarks-20261120/README.md)
