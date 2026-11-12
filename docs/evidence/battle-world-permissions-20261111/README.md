# 배틀 입장 서버 권한 오류 수정

2026-11-11 · TLT-053/087 · ENG · 로컬 수정/엔진 검증, 게시 클라이언트 수용 대기. G3/G7 및 부모 티켓 완료 판정은 아니다.

## 원인과 변경

사용자 화면의 `The adventure could not load. Return to the lobby and rejoin.`은 `ExpeditionService.admitArrival`에서 인증된 원정의 `previewWorld`가 예외를 반환할 때 발생한다. 게시 0.104.1 파일을 격리된 PlaceId0/플레이어0에서 실제 Battle 서버 Script로 실행했을 때 `The current thread cannot write 'CollisionFidelity' (lacking capability PluginOrOpenCloud)`로 동일 초기화 실패를 재현했다. 같은 파일을 플러그인 권한으로 직접 생성하면 통과해 기존 플러그인 기반 검사에서 누락됐다. [서버 재현](before-runtime.log).

[Roblox TriangleMeshPart 공식 문서](https://create.roblox.com/docs/reference/engine/classes/TriangleMeshPart)는 CollisionFidelity의 쓰기가 플러그인 권한이며 Studio에서 설정한다고 명시한다(2026-11-11 확인).

- `DeepwoodEnvironment`: 큰 나무 생성 중 금지된 CollisionFidelity 쓰기를 제거한다. 승인된 원본 메시의 충돌값을 복제하고 CanCollide/CanQuery 및 기존 트렁크 충돌체를 유지한다. 원본 자산·TD 운영·저장 데이터·입장 자격·보상 변경 없음.
- `init.server`/`ExpeditionService`: 월드 초기화 오류의 traceback 및 임무/Place를 서버 로그에 남긴다. 클라이언트에는 기존 영어 안내를 유지하며 티켓·계정 정보는 기록하지 않는다. 실패 시 입장 차단 및 재시도 시 실패 캐시는 유지한다.
- `battle-world-runtime-native`: 격리 파일의 실제 부트스트랩 Script에 검사 함수를 연결해 서버 권한으로 5에픽을 준비한다. 플러그인이 직접 월드를 만드는 검사를 대신하는 권한 회귀다. 실제 Player 입장·MemoryStore/Teleport 인증 수용을 대신하지 않는다.

## 검증

- 0.104.1에 변경 런타임3개만 주입한 후보: 실제 Battle 서버 Script **34검사 PASS**. DW/GW/FV/EC/HG 첫 임무의 맵·스토리·창고 초기화, 재호출 중복 생성 없음, 전투/스토리/원정/인벤토리 Remote, 나무 원본 충돌값 보존·캐릭터 Blockcast 충돌 확인. [후보 로그](candidate-runtime.log).
- Luau 컴파일: 변경 런타임3개와 새 native 검사 PASS. `git diff --check` PASS.
- Lua 소스 회귀: ArrivalLoading283검사, TravelAttempt8검사 PASS. 기존 `battle-startup.spec.lua`는 CampaignWorld의 StoryGateTemplates.prepare를 제공하지 않는 오래된 stub에서 실패했다. 관련 본체/기존 검사는 변경하지 않았으며 통과로 처리하지 않는다. [결과](source-checks.log).


- 고정 빌드 **0.104.2**: 입력 커밋 `8f387f6cb1244fe2f0b1f0cad4cf409879bee6e5`, `python3 tools/build-game.py --source 8f387f6cb1244fe2f0b1f0cad4cf409879bee6e5 --record docs/evidence/battle-world-permissions-20261111/build.json` 성공. 단일 파일 `builds/0.104.2/TheLastThrone-0.104.2.rbxlx`, SHA-256 `90cda90fba934381bf6b158c7613944b83423ca51871adc7679aa95f16ee1d90`. [빌드 기록](build.json).
- 실제 **0.104.2 산출물**에서 `run-in-roblox --place builds/0.104.2/TheLastThrone-0.104.2.rbxlx --script tests/battle-world-runtime-native.luau` 실행: 동일 **34검사 PASS**. [로그](runtime.log). PlaceId0에서 일부 기존 asset hash 경고가 있었으나 5에픽 초기화와 검사 완료를 확인했다.
- 실제 산출물의 변경3모듈이 고정 커밋과 바이트 일치함을 확인했다. 기존 `single-build.spec.py`의 산출물 전용 부분을 별도 실행해 역할10·ArrivalLoading283검사 PASS. [결과](artifact-check.log). 전체 검사는 기존 `default.project.json` ShadowMap / `battle.project.json` Voxel 차이로 시작 단계에서 실패했다. [실패](build-check.log). 이번 수정은 기본 단일 프로젝트에서 빌드했으며 기존 호환 사본 조명값은 변경하지 않았다.
- 넓은 충돌/동선 회귀를 추가 시도했으나 `run-in-roblox`가 내부 Rust assertion으로 종료해 결과를 얻지 못했다. [도구 실패](physics-tool-failure.log). 이 범위는 미검증이며, 위 서버 Script의 나무 실제 Blockcast6검사와 구분한다.

## 미검증과 인계

실제 게시 Lobby→Battle 왕복, 제보 계정/영웅의 원정 재입장, 저장/재접속·모바일 실기기·다인 성능은 미검증이다. 다음 QA는 수정 빌드를 로비·배틀에 함께 게시한 후 새 서버에서 실제 입장/재입장/로비 복귀를 확인한다. 아직 Roblox 게시/릴리스 태그를 만들지 않았다. 이번 빌드에는 기존 미커밋 전투 페이싱·클라이언트·공유 데이터·Blender/자산 작업을 포함하지 않는다.
