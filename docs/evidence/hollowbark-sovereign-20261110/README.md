# Gloamwood Hollowbark Sovereign 추가

2026-11-10 · TLT-065/032/033/057/084 · ENG/PLAN → QA · 0.96.0 · 구현·로컬 검증/미게시.

사용자 요청에 따라 TD의 신규 HollowbarkSovereign을 Gloamwood의 네 번째 보스로 가져왔다. GW-06 One Brave Step의 `rear_guard`에서 Finn과 정찰대가 탈출하는 동안 마지막 wave에1개 등장한다. GW-04 Ancient Hollowbark·GW-05 Venomcoil King·GW-07 Widow Queen은 유지한다. 기존 스토리35개·장별7개·목표ID·선행 조건·완료 기록·고정XP/Gold/Diamonds는 변경하지 않는다. 완료된 GW-06은 다시 요구하지 않고, 미완료/재플레이의 기존 후위 전투에 보스가 추가된다.

원천: TD `assets/models/hollowbark-sovereign-v1` 작업트리의 최종14stud 패키지를 복사했다. TD HEAD만으로 원천 파일 상태를 주장하지 않으며 [manifest](../../../assets/models/hollowbark-sovereign-td-v1/manifest.json)에 커밋과 파일별 SHA를 함께 고정한다. 원본 GLB·리깅 GLB·runtime XML 바이트 exact,2,484tri·10본·HasSkinnedMesh/facing 유지. 기존 Gloamwood8종 binary는 바꾸지 않고 별도 ServerStorage template을 추가했다. 모델의14stud에 TLT 기본 boss1.3배를 다시 곱하지 않는다. Blender 가져오기/렌더/재질 변경은 수행하지 않았고, TD Standard 비교 증거와 TLT 실제 Roblox 조명 수용은 구분한다.

Idle/Walk는 TD 전용 클립, 공격/피격 등 나머지8클립은 TLT Ancient Hollowbark의 동일10본 로컬 델타 재사용이다. 전용 신규 공격 애니메이션을 제작했다고 보고하지 않는다. 물리4패턴 Sovereign Strike / Royal Root Lanes / Crowned Branch Sweep / Sovereign Root Ring을 기존 서버 예고·판정·공격 순환·블록/회피·보스 튜닝에 연결한다. 전투 속도/공격 거리와 계수는 기존 엔트 계열 기준이다. [리서치·선택 근거](../../research/2026-11-10-hollowbark-sovereign.md).

기존 Silkweaver2개를 남겨 기존 인원별 처치 영수증 번호·처치 보상을 보존하고 마지막 번호에 보스를 추가한다. 새 보스 처치에는 현행 서버 boss 처치 보상/드롭 규칙을 적용하므로 해당 전투의 총 처치 수/처치 보상은 늘어난다. TD의 W40 HP/Gold/왕좌 피해를 RPG로 복사하지 않는다. 기존 완료 보상·재화·아이템 지급 계약은 유지한다.

[권한 확인 기록](permissions.json): Dashboard에서 Mesh105839711981589·Image139387289433234의 Restricted를 확인하고 TLT10773575153 사용 권한을 저장했다. 각각 재조회에서 Already added를 확인했다. 전체 허용 Experience 목록은 제품 UI가 숨겨 전수열람을 주장하지 않는다. 공개전환·재업로드·TD 소스/진행 변경·Place 게시는 하지 않았다.

검증 [명령/결과](checks.log): 신규 보스/모션12,687검사(1~4인 단일보스/마지막wave/기존 영수증 번호·보상/35장 완주/구완료 재개방·중복보상0/10클립의41샘플·유효본·유한수), 자산 해시/skin/본/삼각형/14stud/두 프로젝트 바인딩 PASS. 적패턴3,717, 캠페인 이관1,870, 확장7,698, 완료보상1,416, 늦은 에픽 원정732, 기존23종 크기 회귀 PASS. 보스 튜닝330,382검사 PASS. 런타임10파일 luau-compile PASS. `git diff --check` PASS. 승인 보상 시뮬레이션은 `/tmp/tlt-sovereign-progression.json`에 실행하며 정본을 덮어쓰지 않았다.

기존 `late-epics.spec.lua`는 수정 전 HEAD의 src/검사를 별도 임시 디렉터리에 추출해도 `DW-01:exp_1` 선택 확장 목표를 무조건 진행하려다 실패한다([baseline](baseline.log)). 이번 변경에서 이를 전체통과로 보고하지 않는다. 새 보스 검사는 실제 필수 본편을 완주하며 확장 목표는 별도 기존7,698검사로 검증했다.

미검증: Studio MCP의 연결 문서0건으로 실제 TLT clone/스킨 표면·TLT 조명·메시/텍스처 로드·이동/공격 접점·모바일/4인+AI 성능·실제 계정 수용은 미실행. 원천 TD의 native skin 증거를 TLT 통과로 대체하지 않는다. 다음 QA는 GW-06 일반/재플레이·기존 완료 저장·1~4인·보스 경고/회피/타격·퇴로/카메라와 실제14stud 크기를 확인한다. 부모 티켓은 In Progress 유지. 빌드 결과는 build.json에 별도 기록하며 게임 게시/릴리스 태그는 수행하지 않는다.
