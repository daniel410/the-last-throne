# 실제 앱 배틀 로딩 정지 대응

2026-11-06 · TLT-003/028/057/084 · ENG → QA · 0.79.3 · 로컬 수정·미게시.

사용자는 Roblox 앱의 로비→배틀 이동에서 로딩 화면이 끝나지 않았다고 확인했다. 현재 연결된 Studio는 TD이므로 읽기 목록 확인 외 해당 Place를 수정하지 않았다. 현재 컴퓨터의 실행 앱 목록에는 Roblox 플레이어가 없어 제보 순간의 캐릭터/서버 상태를 직접 읽지 못했다. 이번 제보의 정확한 지역·게시 버전·서버 실패 지점은 미확정이다.

## 확인한 결함과 수정

1. 확인 가능한 로컬 Roblox 플레이어 로그 `0.745.0.7451137_20261106T141054Z_Player_c9363_last.log`에는 LobbyHeroDock118/121의 `attempt to index boolean with 'level'` 오류31건이 있다. 해당 시간대의 이전 앱 기록이며 이번 제보 서버와 동일하다는 증거는 없다. 현재 소스에서도 inventory.ready=false이면 and 연산 결과 hero/g가 false인데 g~=nil은 true가 되어 g.level을 읽는 결함을 재현했다. 준비되지 않은 hero는 nil로 정규화하고 progression의 table 타입을 확인한다. 저장/로드 중에도 UI 상태 갱신을 중단하지 않고 준비된 같은 영웅의 성장만 표시한다. UI 원본/배치·영웅 소유권·레벨 데이터는 변경하지 않는다.
2. ArrivalLoading은 현지 바닥 레이캐스트·GameplayPaused·카메라·전투UI/잠금 조건을 먼저 통과해야 RequestStreamAroundAsync를 호출했다. 스트리밍 요청 이후에만 현지 바닥이 도착하는 fixture에서 무한 대기를 재현했다. 서버가 확정한 최종 생존 캐릭터/SpawnReady에서 먼저 주변 스트리밍을 요청하도록 순서를 바꾼다. 완료 뒤에는 기존 전투UI·이동 잠금·카메라·GameplayPaused·실제 바닥·연속3프레임 검사를 모두 유지한다. 임시 BattleArrival/Baseplate를 바닥으로 인정하거나 시간 경과만으로 커버를 제거하지 않는다. 실패 재시도와 캐릭터/위치 변경 fencing을 유지한다.

명확한 결함 수정으로 프로젝트 제작 스킬의 별도 게임성 조사 예외를 적용한다. 최신 공식 [TeleportOptions](https://create.roblox.com/docs/reference/engine/classes/TeleportOptions)와 [비공개 서버 이동](https://create.roblox.com/docs/projects/teleport-private-servers)을 확인했다(2026-11-06). 현재 ReservedServerId/GUID 사용은 공식 계약에 해당하므로 추정으로 이전 ReserveServerAsync 방식으로 되돌리지 않는다. 서버 티켓·DataStore/MemoryStore·보상·TD는 변경하지 않는다.

## 검증

- 새 검사를 수정 전 HEAD 소스로 실행하면 영웅UI는 boolean 인덱싱으로 실패하고, 현지 바닥 지연 로딩은 제한 프레임 내 종료하지 못해 실패한다.
- `lua tests/lobby-hero-progress.spec.lua`: 실제 성장 표시 본문8검사 PASS. inventory=false 준비 상태/동일ID/이전 영웅ID/누락·확정 레벨과XP·빈 계정 확인.
- `lua tests/arrival-loading.spec.lua`: 실제 ReplicatedFirst192검사 PASS. 배틀/복귀 로비의 요청 의존 바닥 수신·느린 UI/이동 잠금·비동기 요청 실패/준비 철회와 기존 초기 로딩 검사를 포함한다.
- `lua tests/battle-startup.spec.lua`:223 PASS. `lua tests/k0-spawn.spec.lua`:4플레이어 수명주기/재시도/경합/재스폰 PASS. `lua tests/lobby-return-hero.spec.lua`:27 PASS. `lua tests/k0-hero-session.spec.lua`:121 PASS. 총571수치 검사와 별도 스폰 수명주기 PASS.
- `/private/tmp/td233-luau/luau-compile`: 변경 런타임2개·확장 native UI 검사 컴파일 PASS. `git diff --check` PASS. native UI 검사에 ready=false→준비복구 경로를 추가했다. 정의만으로 엔진 PASS를 주장하지 않는다.

## 미검증과 인계

실제 게시된 Lobby→Battle 이동·제보 계정/지역·모바일 실기기·1~4인 파티 수용은 미검증이다. 다음 QA는 새 빌드의 각 게시 테스트 Place에서 느린 네트워크·파티 지연 합류·배틀→로비 영웅선택 유지와 재출발을 확인한다. 원인 후보 두 경로의 로컬 재현/수정이며 이번 사용자 멈춤의 단일 원인을 확정하지 않는다. 부모 티켓 In Progress 유지. Roblox 게시/릴리스 태그·운영 DataStore 수정은 수행하지 않는다. 기존 사용자 Blender·첨부·미추적 파일은 포함하지 않는다.

격리 Studio UI 추가 검증: 기존0.79.2 산출물의 LobbyHeroDock/ArrivalLoading 소스만 후보로 바꾼 `/tmp/tlt-loading-fix-candidate.rbxlx`에서 `run-in-roblox --place /tmp/tlt-loading-fix-candidate.rbxlx --script /tmp/tlt-loading-fix-native.luau` 성공. wrapper는 저장소 `tests/lobby-hero-dock-native.luau`를 실행해 반환 보고를 출력한다. 실제 엔진 GUI66검사 PASS([로그](native-ui.log)): ready=false 처리·복구, 선택 표시·영웅 변경·XP,4개 화면크기/잠금·상세창 억제 유지. 스트리밍/Teleport의 실제 앱 재현이나 시각 최종 수용은 아니다. 기존 자산203785492 타입 경고1건이 있었으나 UI 검사는 완료됐다.

스트리밍 API 근거: [Player.RequestStreamAroundAsync](https://create.roblox.com/docs/reference/engine/classes/Player#RequestStreamAroundAsync), 확인2026-11-06. 순서 변경의 교착 재현은 위 실제 소스 fixture의 실험 결과이며 공식 문서가 이번 사용자 서버의 원인을 입증하는 것은 아니다.

고정 소스 `24c695a69850d0d802d661f9c0035fa7c2177a68`와 VERSION0.79.3을 origin/main에 푸시한 뒤 `python3 tools/build-game.py --source HEAD --record docs/evidence/battle-loading-stall-20261106/build.json` 성공. 단일 산출물 `builds/0.79.3/TheLastThrone-0.79.3.rbxlx`, SHA-256 `c53119df81678f0723d0efa2ac38b58b9867cb0604e8c78b4a5527fdd6ff0e18`. `python3 tests/single-build.spec.py --artifact builds/0.79.3/TheLastThrone-0.79.3.rbxlx`에서 실제 산출물 역할10/로딩192·프로젝트 구성 검사 PASS([로그](build-check.log)). [정확한 빌드 입력/해시](build.json). 신규 LFS 업로드는 없으며 기존 미커밋 자산은 빌드에 포함하지 않았다. Roblox 미게시·릴리스 태그 없음.
