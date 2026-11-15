# MISSIONS 재플레이 안내 보완

- 작업ID: `TLT-053/missions-help` · 원정 선택 UI 후속 결함 수정.
- 요청/근거: 사용자가 완료한 퀘스트 목록을 다시 수행해야 하는 미션으로 오해했고, 화면 내 설명을 요청했다. `ExpeditionPresentation.missions`는 완료 여부와 관계없이 전체 장을 투영하며 `AdventureRules.begin`은 완료한 장을 재플레이할 수 있다.
- 변경: `ExpeditionText.MissionsHelp` 영어 키와 `ExpeditionView`의 MISSIONS 목록 상단 안내. 스토리 퀘스트 선택 목록·완료 퀘스트의 선택적 재플레이·반복 보상·영웅당 최초 퀘스트 보상 1회를 명시한다. 기존 TD 테마의 자동 줄바꿈을 사용하고 높이는 `AutomaticSize.Y`로 조정한다.
- 범위: 위 두 소스 파일과 이 기록. 기존 사용자 자산 변경은 제외한다. 안내 누락의 명확한 결함 수정이므로 별도 게임성 리서치는 수행하지 않았다.
- 정적 검증: `/tmp/td233-luau/luau-compile src/client/ExpeditionView.luau src/shared/ExpeditionText.luau` 종료 코드 0. `git diff --check` 통과.
- 미검증: Studio 렌더링·게시 클라이언트·모바일 실기기·사용자 수용. 게임 빌드/Roblox 게시를 수행하지 않았으며 VERSION과 릴리스 태그는 변경하지 않았다.
- 다음 담당: ENG/QA가 다음 빌드에서 데스크톱 및 모바일 가로의 MISSIONS 탭을 열어 안내 잘림·목록 스크롤·퀘스트 선택을 확인한다. 관련 상위 티켓의 수용 완료로 처리하지 않는다.
