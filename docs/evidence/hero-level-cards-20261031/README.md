# 로비 영웅 카드 크기와 레벨

- 작업: 사용자 요청에 따른 로비 UI 조정 (별도 백로그 ID 없음).
- 변경: 선택창 최대 크기를 900×560에서 800×510으로 축소했다. 영웅 상태에 각 영웅의 서버 저장 성장 레벨을 포함하고 생성된 카드에 `LEVEL n`을 표시한다. 성장 정보를 읽을 수 없으면 `LEVEL —`, 생성 전에는 `NEW HERO`를 표시한다. 세션 전용 영웅의 초기 레벨은 1이다.
- 근거·관찰: Roblox의 [적응형 UI 지침](https://create.roblox.com/docs/production/publishing/adaptive-design)은 화면 크기에 맞춰 패널을 조정하고 텍스트 가독성을 유지할 것을 권한다. 이 작업은 기존 2/4열 및 스크롤을 유지한다. 크기별 실제 사용성은 검증이 필요하다. 확인일 2026-10-31.
- 검증: `python3 tests/make_k0_source_probe.py --output-dir /tmp/tlt-hero-level-ui --test-script tests/k0-resource-ui-native.luau`와 생성된 fixture를 `run-in-roblox`로 실행해 4,811개 통과. 서로 다른 영웅 레벨, 정보 미수신, 생성 전과 갱신을 확인했다. 같은 방법으로 `tests/k0-hero-lobby-native.luau` 실행 시 영웅별 저장 레벨 사례 41개는 통과했고, 전체 265개 검사 중 기존 전투 재진입 기대값 한 건이 실패했다. 기존 소스도 전투 중 `StartTutorial`을 허용해 해당 테스트의 `WaitForLobby` 기대와 다르며 이번 변경 범위 밖이다.
- 제한: 실제 사용자 계정 저장/재접속, 시각 렌더 및 실기기 확인은 미실행이다. 기존 자산 `203785492` 유형 경고가 있다. 빌드와 게시는 수행하지 않았다.
- 다음 담당: QA가 실제 저장된 서로 다른 레벨의 영웅과 화면 크기별 배치를 확인하고 재진입 테스트 기대를 검토한다.
