# 영웅 선택창과 지갑 겹침 수정

- 작업: 사용자 요청에 따른 로비 UI 결함 수정 (별도 백로그 ID 없음).
- 변경: 영웅 선택창의 최대 크기를 1100×660으로 줄이고 지갑 아래에 상단 공간을 확보했다. 작은 화면의 기존 카드 스크롤을 유지한다.
- 검증: `python3 tests/make_k0_source_probe.py --output-dir /tmp/tlt-hero-panel-probe --test-script tests/k0-resource-ui-native.luau` 후 `run-in-roblox --place /tmp/tlt-hero-panel-probe/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-hero-panel-probe/source-probe.luau` 실행. GUI 생성과 상태 검사 4,808개 통과, 실패 0. 기존 자산 203785492 유형 경고가 출력됐다.
- 제한: 격리 GUI 검사이며 실제 화면 렌더링, 실기기 및 게시 클라이언트의 시각 수용은 미검증이다. 게임 빌드와 게시는 수행하지 않았다.
- 다음 담당: QA/사용자가 실제 화면 크기에서 지갑과 영웅 선택창의 배치를 확인한다.
