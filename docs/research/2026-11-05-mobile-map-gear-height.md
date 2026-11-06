# 모바일 맵·장비 높이 개선 조사

2026-11-05 확인 · TLT-028/031/052/084 · RES/DES → ENG/QA

질문: 가로 휴대폰에서 지도와8슬롯을 보기 위해 글자/터치 크기를 줄이지 않고 고정 UI가 차지하는 높이를 어떻게 줄일 것인가?

| 사례/출처 | 확인 사실 | 적용 해석과 한계 |
| --- | --- | --- |
| [Roblox Scrolling frames](https://create.roblox.com/docs/ui/scrolling-frames) | CanvasSize가 프레임보다 크면 스크롤하며, 스크롤바 인셋과 clipping을 별도 관리한다 | 슬롯 생성 여부 대신 실제 뷰포트/캔버스·클립 경계를 검증해야 한다. Roblox 특정 게임의 실제 UI를 플레이한 근거는 아님 |
| [Roblox ScreenGui](https://create.roblox.com/docs/reference/engine/classes/ScreenGui) | ScreenInsets로 화면 안전 영역을 관리하며 기본 CoreUISafeInsets를 제공한다 | 안전 영역 내부 크기를 기준으로 배치하고 노치/상단 버튼을 덮는 방식으로 공간을 확보하지 않는다 |
| [Diablo Immortal 공식 업데이트 — Item Power UI](https://news.blizzard.com/en-gb/article/24206338/come-to-sharvals-aid-in-our-next-major-update) | 장착 효과를 보기 위한 탭/클릭이 많다는 문제에 대해 Inventory/Armory에 효과 개요 버튼을 추가한다고 설명한다 | 요약은 한 번에 보고 상세는 필요할 때 여는 방향을 참고한다. 모바일 현재8슬롯 배치나 이 제안의 성공률을 입증하지 않는다. 원문의6월19일 업데이트 안내를 확인했으며 현재 라이브 화면을 직접 플레이하지 않음 |

공식 웹 문서를 확인했으며 인기 순위·매출·유지율이나 특정 Roblox 게임의 최신 UI를 검증하지 않았다. 기존 [모바일 메뉴 조사](2026-11-01-mobile-menu-stats.md)를 재사용하고 이번 첨부/현재 소스의 높이 누수를 추가 근거로 삼았다.

추천: 장비 푸터/성공 안내의 높이부터 회수하고 큰 초상을 헤더로 옮기며, 맵의 지역 탭/하단 띠를 선택 목록/측면 조작부로 바꾼다. 비용은 중간 수준의 클라이언트 배치·선택 상태 관리이며 서버 저장/여행 정책 변경은 필요하지 않다. 최소 시험은 안전 영역750×280에서8슬롯 전체 표시와 지도 높이65%다. 자세한 가설·대안·실험/수용 기준·다음 담당자는 [개선안](../production/mobile-map-gear-height-2026-11-05.md)을 따른다. 실제 터치·사용자 읽기 수용은 미검증이다.
