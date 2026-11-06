# 스토리4 사망 후 스토리1 복귀 수정

2026-11-05 · TLT-005/050/057/061/084 · ENG → QA · 로컬 소스 수정·미게시.

사용자는 스토리4에서 사망한 뒤 처음 시작점으로 돌아갔다고 확인하고 수정을 요청했다. 프로젝트 제작 스킬에 따라 기존 구현의 명확한 결함 수정으로 처리하며 별도 기능 조사는 생략했다.

원인: `InventoryService.storyState`가 `Tutorial`에서만 원정 저널을 투영했다. 사망 직후 `Respawning`에서는 개인 영구 저널을 반환하여 `expeditionMission`이 사라졌다. 부활의 실제 `init.server` 위치 해석→`DeepwoodService.destination`은 원정이 존재할 때 현재 임무 대신 최초 입장 `missionId`로 대체하므로 DW-01로 복귀했다. `LoadingTutorial`의 초기/재생성에도 같은 불일치가 있었다.

수정: `Tutorial`·`Respawning`·`LoadingTutorial`에서 같은 서버 원정 투영을 사용한다. 스토리4까지 진행했다면 사망 후 스토리4의 기존 안전 시작 체크포인트로 복귀한다. 스토리 중간의 신규 부활 지점을 추가한 변경은 아니다. 원정ID·재도전 저널·완료 목표·보상·사망XP·로비의 영구 진도 표시와 트레이닝 부활 계약은 유지한다. 이전 사용자 Blender 변경·생성 증거·첨부는 제외한다.

검증:

- `lua tests/story-respawn.spec.lua`:28 PASS. 실제 계정 규칙으로 DW-01 입장→스토리3완료→스토리4 첫 목표 완료 fixture를 만들고 실제 InventoryService 투영·부트스트랩 위치 resolver·Story destination 본문을 모의 월드와 실행한다. 세 생명 상태에서 DW-04 부활/목표 보존, 고의 DW-01 재도전과 영구 진도 차이, 로비·트레이닝 분리를 확인했다.
- `/tmp/tlt-story-respawn-before.lua`: 수정 전 조건으로 되돌린 모듈 사본을 읽는 동일 회귀 검사는 `Respawning retains current story projection`에서 기대대로 실패했다. 원본 파일은 수정하지 않았다.
- `lua tests/k0-spawn.spec.lua`: PASS. 모의 생명주기4플레이어·지연/재시도·최신 이동 요청·늦은 사망·재생성 검사.
- `lua tests/k0-hero-session.spec.lua`:104 PASS.
- `lua tests/story-region-handoff.spec.lua`:52 PASS.
- `lua tests/story-lobby-resume.spec.lua`:32 PASS.
- `lua tests/story-continuation.spec.lua`:1,017 PASS.
- `lua tests/death-xp-penalty.spec.lua`:3,575 PASS.
- `/private/tmp/td233-luau/luau-compile src/server/Inventory/InventoryService.luau`: PASS.
- `git diff --check`: PASS.

순수 Lua/대역 검사이며 실제 엔진 배치·Studio·게시 클라이언트/실제 계정/실기기·다인 검증은 수행하지 않았다. 빌드·Roblox 게시·릴리스 태그 없음, VERSION 유지. 다음 담당 QA는 새 게시본에서 스토리1로 출발해 스토리4 중간에서 사망→스토리4 안전 시작점·완료 목표 유지·다음 목표 안내와 후반 에픽/재도전을 확인한다. 부모 티켓 In Progress 유지.
