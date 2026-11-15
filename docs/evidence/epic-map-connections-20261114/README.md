# 에픽 지도 연결 누락 수정

2026-11-14 · TLT-061/062/063/064/065/overland · ENG · 로컬 소스/후보 Studio 검증, 미게시

사용자 스크린샷에서 Deepwood 7/7 완료 뒤 Gloamwood로 가는 방향을 찾을 수 없었다. [도보 연결 계약](../../product-contracts.md)과 [기존 결정](../../decisions/2026-11-13.md)에 따라 이미 존재하는 Black Root Altar 북쪽→Lantern Trail 도로를 지도에도 표시한다. 원인이 명확한 표시 누락 수정이며 새 이동 규칙을 도입하지 않는다.

## 변경

`CampaignMapScope.connections`가 실제 `CampaignBounds.ends`에서 인접 경계의 양 끝과 목적지를 계산한다. 월드맵/로비 지도는 해당 도로까지 지도 범위를 확장하고, 다섯 에픽의 왕복 8방향 연결선·영문 목적지·선행 완료 전 잠금/완료 후 출발 지역을 표시한다. 목적지 버튼은 인접 에픽 지도와 도착 지역을 선택한다. 지도 보기와 서버 입장 자격은 별개다. 기존 서버 권위·보상·저장·세계 배치는 그대로다.

Deepwood에서는 `↑ GLOAMWOOD · MAP`과 `OPEN · Walk from Black Root Altar`가 보인다. 전투 지도 하단에도 북쪽 길 안내를 추가한다. 지도의 경계 버튼은 다음 지도 조회이며 캐릭터 이동 요청을 보내지 않는다.

변경 범위: `src/client/{DeepwoodMap,DeepwoodMapCanvas,LobbyAtlas}.luau`, `src/shared/{CampaignMapScope,K0Text}.luau`, 관련 후보 검증 스크립트/증거. 기존 미커밋 자산 삭제·임시 파일은 제외한다.

## 검증

- [후보 Studio 로그](focused-native.log): 격리 PlaceId=0, 플레이어0, 기존 `0.107.3` 호스트에 [입력 해시](inputs.json)의 5개 소스를 주입. Shared/Client Luau 컴파일 통과. 실제 GUI 생성, 44구역 지리·랜드마크·플레이어 표시 회귀와 왕복8연결의 개수/목적지/지도 내부 좌표/해금 전후 상태를 포함해 3,073검사 통과.
- [진행 이관](reorder.log) 1,870검사, [선택 사건/5지도 범위](optional.log) 6,280검사 통과.
- 실행: `python3 tools/prepare-epic-map-connections-native.py` 후 `run-in-roblox --place builds/0.107.3/TheLastThrone-0.107.3.rbxlx --script /tmp/tlt-map-connections-native.luau`.
- [전체 지도 통합 후보 로그](native.log)는 별도 기존 `cartography-native`의 `compact map retains curved roads GW-03` 항목에서 실패했다. [주입 없는 기존 0.107.3 재현 로그](baseline-native.log)에서도 같은 항목이 실패했다. 이번 변경 이전부터의 통합 검사 결함이며 연결 전용 검사 통과와 구분한다.

## 미검증·다음 담당

고정 빌드 생성·Roblox 게시·게시 클라이언트·실제 버튼 클릭/화면 수용·모바일 실기기는 미검증이다. 빌드를 만들지 않아 VERSION/태그를 변경하지 않았다. QA/다음 릴리스 담당은 실제 클릭으로 에픽 지도 왕복, 해금 전 조회/입장 차단, 작은 화면의 표식 가독성, Black Root Altar 북쪽 실제 보행을 확인한다. 부모 에픽 티켓/사용자 수용은 완료 처리하지 않는다.
