# 칼데라 로딩 정지 수정 · 0.75.7

2026-11-05 · TLT-003/057/061/062/063/064/065/084 · ENG → QA

사용자 제보: 로비에서 칼데라 에픽으로 배틀 시작 후 로딩 화면이 끝나지 않음.

## 원인과 변경

게시 기준 0.75.5의 격리 Studio에서 `CampaignWorld.create(3)`을 실행한 결과 EC-01 시작 지점은 존재하지만 Enabled=false였다. SpawnService의 isSafeSpawnAvailable/requestSpawn은 활성화된 SpawnLocation만 허용한다. HeroSession 전환은 SpawnFailed가 되고 ArrivalLoading은 Tutorial/SpawnReady를 기다리므로 화면이 유지되는 코드 경로를 확인했다. 제보 계정의 실제 서버 상태나 게시 이동 자체를 재현한 것은 아니다.

EmberCalderaWorld/FrozenValeWorld/LateEpicWorld의 체크포인트를 Deepwood와 동일한 Enabled=true로 수정한다. 권한·원정 검증, 서버의 명시적 목적지 선택, SpawnService 안전 검사, 로딩 완료 조건은 유지한다. 설원·칼데라·어두운 숲·묘지의 같은 결함을 함께 수정한다. 데이터·보상·TD는 변경하지 않는다. 명확한 결함 수정이므로 별도 사례 조사는 생략한다.

## 검증

- 기존 0.75.5 단일 파일을 연 PlaceId=0/플레이어0 격리 Edit Studio에서 수정한 세 모듈의 실제 소스와 새 모듈 캐시로 검사했다. `tests/regional-spawn-native.luau`: 5에픽 44체크포인트, 활성화/Workspace 소속/SpawnLocation 타입과 충돌 바닥, 총93검사 PASS. 실제 Player의 로드나 Teleport 검증은 아니다.
- 첫 엔진 검사 때 이전 진단에서 생성한 칼데라가 남아 Deepwood의 기존 월드 복구 경로가 실패했다. 격리 생성 월드를 정리하고 fresh fixture 조건을 추가한 뒤 전체93검사 PASS. 해당 기존 월드 복구 경로의 변경은 이번 범위에 포함하지 않는다.
- `tests/battle-startup-native.luau`에 생성된 모든 체크포인트의 SpawnService 자격 검사를 추가했다. 이 전체 서버/플레이 수명주기 스위트는 이번에 실행하지 않았다.
- `lua tests/k0-spawn.spec.lua`: 스폰 수명주기/재시도/경합/재스폰 PASS.
- `lua tests/battle-startup.spec.lua`:223 PASS.
- `lua tests/arrival-loading.spec.lua`:108 PASS.
- `lua tests/story-respawn.spec.lua`:28 PASS.
- `lua tests/ember-caldera.spec.lua`:600 PASS.
- 수정 월드3개·새 엔진 테스트 Luau 컴파일 PASS.

## 빌드와 후속

VERSION 0.75.6→0.75.7, 소스 fea088795b6c0f130036b6143f9aac80657e1bfe의 단일 Rojo 빌드 성공. build.json에 해시를 기록했다. `python3 tests/single-build.spec.py --artifact builds/0.75.7/TheLastThrone-0.75.7.rbxlx` PASS(로딩108검사 포함), 산출 XML의 수정 월드3개가 소스와 바이트 일치함을 확인했다. 로컬 수정·미게시, 릴리스 태그 없음. 기존 사용자 Blender/첨부/미추적 검토 파일은 제외한다.

다음 QA는 게시된 테스트 Lobby→Battle에서 EC-01 직접 진입과 재접속, FV/GW/HG 진입, 느린 네트워크·실기기·다인, 배틀→로비 복귀를 확인한다. 실제 클라이언트·Teleport·사용자 수용 미검증이므로 부모 티켓은 완료 처리하지 않는다.
