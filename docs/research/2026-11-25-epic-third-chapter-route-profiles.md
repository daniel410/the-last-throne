# 에픽 3장 구조길의 바닥 접점과 시야

2026-11-25 Toronto · TLT-061~065 · G5

환경 아트·환경 3D·맵 구현 역할이 3·4장의 기존 조형과 Studio 비교를 검토했다. 기존 3장 화면에서 밝은 조사점 주변의 낮은 설비는 바닥과 닿는 형태가 약했고, Gloamwood 귀환 방향에서는 차양 기둥이 선반 일부를 가렸다. 이번 범위는 다섯 3장 사건의 기존 구조·정찰 시설과 바닥 접점이다. [기존 3장 전후 화면](../evidence/epic-third-chapter-rescue-routes-20261124/README.md) · [기존 4장 전후 화면](../evidence/epic-fourth-chapter-maintenance-profiles-20261125/README.md)

## 공식 사례와 적용

- Diablo IV 환경팀은 Scosglen의 재료와 기후에 맞춰 지역 색을 설계하고 조명과 배경에 플레이를 위한 여백을 둔다. TLT에서는 구릉의 다짐흙·토착 석재, 설원의 암반·청빙·압설처럼 서로 다른 접점을 조형했다. [Diablo IV 환경 제작기](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- World of Warcraft의 Hallowfall은 동굴 천장의 광원으로 어두운 지형에 방향 기준을 준다. TLT에서는 Gloamwood 선반에 작은 등갓과 발광 창을 넣어 야간에 위치를 읽을 수 있게 했다. [The War Within 지역 소개](https://worldofwarcraft.blizzard.com/en-gb/news/24125258)
- Lost Ark의 North Kurzan은 화산재를 뿜는 Mount Antares 아래에 병력이 집결하는 장소다. TLT에서는 Ember Caldera의 화산재와 현무암 위에 내화벽돌이 놓이는 구조로 구조대의 작업 장소를 표현했다. [Arkesia Ignited](https://www.playlostark.com/en-us/game/releases/arkesia-ignited)
- Roblox의 Duvall Drive는 나무 사이의 부분 노출을 이용해 접근하며 건물을 발견하게 한다. TLT는 조사점에서 고정 거리의 양방향 비교와 차양에 의한 선반 가림을 측정했다. [Duvall Drive 환경 제작](https://create.roblox.com/docs/resources/the-mystery-of-duvall-drive/construct-the-house)

## 제작표

원천은 [사건 데이터](../../src/shared/CampaignExpansionContent.luau)와 [기존 제작표](2026-11-24-epic-third-chapter-rescue-routes.md)다. 모든 형상은 기존 지역 팔레트와 Roblox 네이티브 부품을 사용하는 고정 환경이다.

| 에픽·사건 | 기존 사건 단계와 목적 | 이번 변경과 확인 장면 |
| --- | --- | --- |
| DW-03 · exp_2/2 | 감시탑에서 신호 방향을 읽는다. | 다짐흙 턱을 넓히고 드러난 돌좌와 관측 홈을 키웠다. 접근에서 양쪽 돌좌와 열린 홈을 확인한다. |
| GW-03 · exp_1/2 | 피난처에서 Tali의 지도와 정찰 흔적을 대조한다. | 회수 선반을 길 반대편으로 옮기고 고정 등갓을 붙였다. 진입·귀환 시 지도와 선반의 위치를 비교한다. |
| FV-03 · exp_1/2 | 구조한 마차 관리인을 보급 둑으로 안내한다. | 암반 절개와 푸른 얼음 단면을 늘리고 압설의 끝을 낮췄다. 보급 표지 아래의 재료 층을 확인한다. |
| EC-03 · exp_1/2 | 부상자 대피로의 낮은 난간을 고정한다. | 현무암 기단과 내화벽돌의 경사 발을 추가했다. 양 방향에서 화산재와 받침의 단면을 확인한다. |
| HG-03 · exp_2/2 | 요새 측면 출구의 오래된 난간을 고정한다. | 석회암 기단을 넓히고 두 경사 버팀을 추가했다. 귀환 시 난간과 석조 바닥의 접점을 확인한다. |

[통합 소스](../../src/server/World/EpicThirdChapterRouteLandmarks.luau) · [검증](../evidence/epic-third-chapter-route-profiles-20261125/README.md)
