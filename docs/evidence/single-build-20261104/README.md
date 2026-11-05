# 단일 로비·배틀 빌드 — 0.73.1

작업: TLT-003/057/084 · ENG · 사용자 지시: TD처럼 한 빌드 파일로 두 Place 업데이트.

## 변경과 근거

- `PlaceRole.resolve`가 ExpeditionConfig의 실제 Lobby/Battle ID로 판별한다. 서버 초기화와 ReplicatedFirst 로딩에서 같은 모듈/설정을 사용한다. 조기 로딩은 ReplicatedStorage를 기다리지 않도록 ReplicatedFirst에도 원본을 마운트한다.
- 게시된 알 수 없는 Place에서는 초기화를 중단한다. Studio의 로컬/미등록 Place는 기본 Lobby다. Edit 모드에서 Workspace에 문자열 속성 `TLTStudioRole=Battle`을 추가한 뒤 Play하면 배틀 대기 경로를 시험한다. 등록된 Place ID는 Studio에서도 속성보다 우선한다. 배틀 입장 티켓/서버 검증은 그대로다.
- 초기 카메라 최대 거리는 서버 역할로18/22를 적용한다. 기존 AdventureCamera의 실제 플레이22 정책은 보존한다.
- `default.project.json`이 기본 입력이다. `battle.project.json`은 기존 자산 준비 도구 호환용 동일 내용 사본이며 별도 배틀 산출물을 만들지 않는다.
- `python3 tools/build-game.py --source HEAD --record <기록.json>`은 커밋 소스/LFS 해시를 고정하고 `builds/<VERSION>/TheLastThrone-<VERSION>.rbxlx` 하나를 만든다. 기존 freeze 명령은 호환 진입점이다. 같은 출력 파일은 덮어쓰지 않는다.
- 같은 파일을 Lobby70829337938054와 Battle129388473517823에 각각 게시한다. Place 정원·접근 정책은 기존20/4와 별도 설정을 유지한다.

비교 근거: TD `src/Server/MatchContext.lua`의 런타임 PlaceId 판별과 `docs/dev-runs/2026-11-04-2210-single-game-build.md`의 단일 파일 정책을 읽었다. 제품/UI/밸런스 변경이 없는 빌드 경로 통합이다. Roblox 공식 [DataModel.PlaceId](https://create.roblox.com/docs/reference/engine/classes/DataModel#PlaceId)를2026-11-04 확인했다.

## 검증과 한계

- `lua tests/place-role.spec.lua`:10검사 PASS. 실제 두 ID·Studio 기본/배틀·알 수 없는 운영 Place/TD Place 거절·잘못된 Studio 속성 거절.
- `lua tests/arrival-loading.spec.lua`:108검사 PASS. 실제 역할 모듈을 연결하고 로비/배틀·도착 GUI 유무·스트리밍 실패/준비 회귀를 모의 실행한다.
- `python3 tests/single-build.spec.py`:프로젝트의 동일성·조기 로딩 마운트 PASS.
- 고정 커밋의 실제 Rojo 빌드와 출력 XML 검증은 `build.json`/후속 기록에 남긴다.
- Studio/게시 클라이언트·실제 Teleport·모바일/4인+AI는 미검증이다. 이번에는 게시/릴리스 태그를 만들지 않는다. 부모 티켓 수용 상태는 유지한다.
- 기존 미커밋 모션·무기·포탈 작업은 보존하고 소스 커밋/빌드에 포함하지 않는다.

다음 담당: QA가 동일 파일을 두 테스트 Place에 게시한 후 로비→배틀→로비 및 도착 로딩을 실제 클라이언트에서 확인한다.
