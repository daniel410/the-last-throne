# 0.41.3 적 밀도·전투 강도·머리 위 레벨

2026-10-31 · TLT-005/028/052/061/073/084 부분 구현 · ENG → QA

일반 적·보스 증원3배, 일반 HP/공격력1.5배, 보스 HP1.35배/공격력1.25배를 시험 적용한다. 기존 서버 StoryLevel을 HP 왼쪽에 Lv.n으로 표시하며 훈련 적 기본은Lv1이다. 기존5종 보스는 각1명, 파티HP 배율과 공격 예고·무적/블록 판정은 유지한다.

본문/선택전/증원 전체 명세는82명→236명이다. 첫 고블린2명→6명, 샤먼왕의 초기9호위+보스1과 두 차례9증원을 모두 누적하면28명이다. 일반 웨이브는 최대18명으로 분할하며 기존 거리/활성 사건/유한 증원/정리 계약을 유지한다. 증원 중첩의 실기기 성능은 후속이다. 전체 교전의 기존 처치XP/Gold를 나눠 지급하므로 밀도 상승이 총 보상을3배로 만들지 않는다. 스토리 보상 정본은 변경하지 않았다.

영웅 누적XP·가독성·안전한 필드 스킬 편성·직선 안내의 앞선 커밋을 이번 시험 빌드 입력에 포함한다. 별도 작업 중인0.41.2 드워프 모션 경로와 버전 충돌을 피하려고0.41.3을 예약했다. 다른 작업의 미커밋 모션 원본/스크립트는 빌드 입력에서 제외한다.

[공식 자료 비교·적용 판단/후속4단계 난이도](../../research/2026-10-31-enemy-density-and-difficulty.md). 난이도 메뉴/설정은 후속이며 Easy/Hard/Insane/Hell은 이름/역할 후보만 기록했다.

## 검증 상태

- `lua tests/deepwood-encounter-balance.spec.lua`:1,312개 통과. 전체 구성·보스1명·양의 정수 분배/XP·Gold 총합 보존·기존 레벨과1~4인 HP/피해 증가.
- `lua tests/deepwood-bosses.spec.lua`:96개 통과.
- `lua tests/hero-progression.spec.lua`:656개 통과. 누적XP와 기존 저장/성장 계약.
- 고정 소스 `cdf5391` / Rojo7.7.1의0.41.3 Lobby·Battle 빌드 성공. [명령/입력 커밋/바이트/해시](build.json). Git 커밋만 별도 임시 폴더로 추출했으며, 두 산출물의 주요11개 모듈과 기존 모션 소스를 고정 커밋과 대조했다. [결과](source-verification.json).
- `tests/deepwood-service-native.luau` / 최종 Battle: **3,919개 통과**, 실제6명 첫교전·5보스/증원·레벨/HP 인접 배치·서버 진행·중복 처치·첫교전XP36/Gold10 보존. [로그](service.log).
- `tests/k0-resource-ui-native.luau` / 최종 Battle: **4,804개 통과**, 영웅 창/HUD의 누적XP0/99/100/240/84925 표시·폭 실측과 기존 스킬/모바일 UI 회귀. [원시 로그](ui-world-first-failed.log).
- `tests/deepwood-places-native.luau` / 최종 Battle: **405개 통과**, 지형/장소와 훈련Lv1·지연 레벨17 갱신·보스/일반 전환·HP와 이름/레벨 분리·피격/사망 표시. [최종 로그](places.log).
- `tests/k0-build-smoke.luau` / 최종 Lobby: **542개 통과**, 전체 모듈 로드·기본 전투/체력바·4종 사망/리스폰·실제 메시/텍스처 로드. 런타임 오류0. [최종 로그](smoke.log).
- `lua tests/deepwood-progress.spec.lua`:570개 통과. `lua tests/deepwood-quests.spec.lua`:31개 통과.

UI/장소 묶음의 첫 실행은 UI4,804개를 통과한 뒤 기존96px 전체 바 폭을 가정한 장소 검사에서 실패했다. HP 자체96px는 보존하고 왼쪽 레벨44px가 추가돼 전체140px가 되는 새 계약으로 검사만 수정해 최종405개를 통과했다. 게임 소스/산출물은 재빌드하거나 덮어쓰지 않았다. 최초 XML 소스 확인 스크립트는 Source를 ProtectedString으로만 찾아 중단했으며, 실제 Rojo string Source도 읽도록 수정한 대조에서11개 모듈이 일치했다. 기존203785492 자산 유형 경고를 보존한다.

엔진 검사에서는 Player/계정/입력은 대역이며 실제 소비자 플레이 수용과 구분한다.

실제 계정 저장·낮은 레벨 영웅 정상 완주·게시 클라이언트·실기기/4인 성능·최종 사용자 난이도/레벨 표시 수용은 미검증이다. 상위 티켓은 미완료로 유지한다. Roblox 게시와 릴리스 태그는 이번 범위에 포함하지 않는다.

스모크 첫 시도는 로비 생성을 요구하는 검사를 Battle에 실행했고, 월드 생성 직후 Remotes 초기화 전에 조회해 실패했다. [최초 로그](smoke-first-wrong-role.log). 게임 소스 변경 없이 검사가 K0Action 생성을최대30초 기다리게 하고 올바른 Lobby에 실행해542개를 통과했다. 시작 시 Studio MaterialManager의 profile 주석 메시지는 원시 로그에 보존됐으나 수집된 게임 런타임 오류는0이다. [검증 요약](verification.json).
