# 기본 상시 길 안내

2026-10-29 · TLT-028/031/050/052/061/084 · ENG/DES → QA

사용자 요청: 지금은 네비게이션을 기본으로 항상 켠다. 현재 구현은 자동 목표 추적이며 수동 활성화 입력은 없다. 이번 변경은 목표7studs 이내 자동 숨김을 제거하고12studs 이내에서 첫 화살표를 목표 위치에 유지한다. 목표와 플레이어 위치가 같아도 방향 벡터가 유효하다. 활성 목표 전환/완료는 기존 서버 진행을 따른다. 훈련장·사망·활성 목표 없음에는 숨긴다. 지형 스트리밍으로 바닥이 없으면 해당 바닥 화살표는 숨기고 기존 목표 표식을 유지한다.

## 사례 조사

확인일2026-10-29. 아래는 공식 문서 열람이며 직접 플레이 검증이 아니다. 게시/갱신일과 정확한 클라이언트 버전은 문서에서 확인하지 못했다. 인기 순위를 주장하지 않고 퀘스트 탐색 UX의 비교 사례로 선정했다.

- [ESO 공식 탐험 가이드](https://www.elderscrollsonline.com/en-gb/newplayerguide/questing): 선택한 퀘스트 목표를 나침반과 추적기에 표시한다. PC/콘솔 입력을 설명한다.
- [ESO 공식 지원](https://help.elderscrollsonline.com/app/answers/detail/a_id/60404/~/quest-tracker---the-elder-scrolls-online): 자동 퀘스트 추적 설정은 기본 Off이며 On으로 바꿀 수 있다. 선택 목표 안내와 신규 퀘스트 자동 등록은 별개다.
- [Guild Wars 2 공식 초보 가이드](https://www.guildwars2.com/en/new-player-guide/): 우측 상단 콘텐츠 안내가 다음 행동/방향을 알려 주고 나침반 미니맵의 초록 별/원으로 스토리 목적지를 표시한다.

해석: 목표 설명과 방향 표식을 함께 제공하면 이동 후 무엇을 해야 하는지도 전달할 수 있다. 위 출처는 바닥 안내선을 항상 켜는 동작을 입증하지 않는다. Roblox 타 RPG의 최신 기본 설정은 검증하지 않았으며 추정하지 않는다.

적용: 현재는 사용자 결정대로 자동 추적+바닥 안내+목표 표식을 유지한다. 후속 선택지는 설정에서 안내선 표시 여부를 제공하는 것이지만 이번에는 설정 UI를 추가하지 않는다. 제작 비용은 낮으며 가까운 화살표가 상호작용 오브젝트를 가리는지 PC/터치/패드에서 확인해야 한다. 최소 수용은 먼 목표·접근·도착·목표 교체에서 안내 유지, 목표 없음·사망·훈련장 숨김이다. 길 찾기 시간과 목적지 도착 후 상호작용 지연의 개선 여부는 실제 사용자 플레이로 후속 측정한다.

## 검증과 한계

`tests/navigation-always-on-native.luau`는 실제 Roblox Heartbeat/Part/Raycast에 LocalPlayer 대역을 주입해60/10/6/1/0studs의 화살표 표시, 목표 없음/훈련장/사망 숨김을 검사한다. 게임 빌드·게시·실기기·실제 사용자 수용과 구분한다. 기존 미커밋 서버/퀘스트 작업은 이번 커밋에 포함하지 않는다. 상위 티켓은 In Progress다.

실행: `python3 tests/make_k0_source_probe.py --output-dir /private/tmp/tlt-navigation-always-on --test-script tests/navigation-always-on-native.luau` 후 `run-in-roblox --place /private/tmp/tlt-navigation-always-on/tlt-k0-qa-empty.rbxlx --script /private/tmp/tlt-navigation-always-on/source-probe.luau`. 결과 exit0, `NAVIGATION_ALWAYS_ON PASS: 5 distances, no target, training, death`. 기존203785492 자산 종류 경고가 있었으며 검사 실패는 없었다. `git diff --check` 통과. 게임 빌드를 생성하지 않아 VERSION/릴리스 태그는 변경하지 않았다.

## 후속 적용: 선택형 끄기 옵션

사용자의 “그래 적용해줘” 요청으로 전체 지도(M/터치 지도 버튼) 하단에 `Navigation Trail: ON/OFF` 버튼을 추가했다. 기존 별도 설정 화면이 없어 지도에서 길 안내를 제어하도록 배치했다. 기본ON,44px 높이의 선택 가능한 버튼이다. OFF는 바닥 화살표만 숨기며 목표 표식·목표 설명·지도 목표는 기존 경로 그대로다. `TLTNavigationEnabled` 클라이언트 표시 속성을 사용하므로 같은 접속의 리스폰/영웅 전환에는 유지되며 재접속은 기본ON이다. 계정 영구 저장은 추가하지 않는다. 서버 진행/보상은 변경하지 않는다.

검증: `python3 tests/make_k0_source_probe.py --output-dir /private/tmp/tlt-navigation-toggle-ui --test-script tests/navigation-always-on-native.luau` 후 `run-in-roblox --place /private/tmp/tlt-navigation-toggle-ui/tlt-k0-qa-empty.rbxlx --script /private/tmp/tlt-navigation-toggle-ui/source-probe.luau`. 최초 실행은 샌드박스의 플러그인 파일 생성 제한으로 실패했고 권한을 적용한 재실행은 exit0/PASS였다.5개 거리·OFF/ON 시각 파트·목표 없음/훈련장/사망 숨김, 지도 버튼 기본ON/속성 변경에 따른OFF/ON 문구·44px/Selectable 검사를 통과했다. 기존203785492 자산 종류 경고가 있었다. 실제 클릭/터치/패드 입력·실제 화면 겹침·게시/실기기 수용은 미검증이다. 게임 빌드가 아닌 격리 소스 fixture이므로 VERSION/릴리스 태그를 생성하지 않았다. 다음 담당 QA가 실제 지도에서 입력과 작은 화면 배치를 확인한다.
