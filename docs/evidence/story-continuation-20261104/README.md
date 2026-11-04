# 동일 에픽 스토리 자동 진행 복구 · 0.69.5

2026-11-04 · TLT-061/057/084 · ENG → QA · 로컬 수정·미게시.

## 원인과 수정

스토리2 완료 후 원정의 `missionId`는 입장 임무에 고정되어 있었다. `AdventureRules.projection`의 `expeditionMission`과 이벤트 검사도 같은 ID만 허용하여 다음 스토리 목표/대화와 저장이 차단됐다. 완료 카드도 개별 임무 종료로 해석해 로비 복귀만 안내했다.

- Easy 초회 본편은 저장된 메인 진도를 바탕으로 동일 에픽 다음 스토리를 연다. 기존 완료 원정도 별도 마이그레이션/보상 재지급 없이 투영하므로 DW-02 완료 저장에서 DW-03의 Selene 대화를 시작할 수 있다. 처음 선택한 임무ID/원정ID는 입장·재접속 검증을 위해 유지한다.
- 다음 목표 추적·리스폰·지역 경계 복귀를 현재 스토리에 맞춘다. 같은 에픽을 끝내면 로비를 통해 다음 지역에 입장한다. 재도전/상위 난이도/선택 임무는 개별 임무를 유지한다.
- 각 이어지는 스토리의 초회 보상·난이도 완료·강화 재료/상자 진도를 저장하며 저장 응답 유실 재요청은 중복 지급하지 않는다. 이어지는 스토리의 처치/재료 지급ID에 스토리ID를 붙여 같은 원정 안에서 충돌하지 않게 한다. 원래 입장 스토리의 기존 지급ID는 보존한다.
- Selene 지원권의 현재 스토리/범위도 이어지는 스토리를 사용한다. 완료 시 지원 종료, 다음 스토리의 캠프 명시적 초대에만1 credit 소비를 유지한다. 자동 갱신은 없다.
- 파일 범위: AdventureRules/StoryCompletion/SupportPassRules, DeepwoodService/DeepwoodRegionAccess, 회귀 테스트와 VERSION·관련 기록. 기존 미커밋 무기/회피/원정 이동 수정은 스테이징·고정 빌드에서 제외한다. 명확한 결함 수정으로 별도 비교 리서치는 생략했다.

## 검증

순수 Lua 트랜잭션/투영 검사이며 Roblox 엔진 실행이나 실제 DataStore 시험과 구분한다.

| 명령 | 결과 |
| --- | --- |
| `lua tests/story-continuation.spec.lua` | 654 PASS:5에픽35스토리를 에픽별 하나의 원정으로 진행, DW-02 직접 입장/완료 저장→DW-03 대화 저장, 재접속 입장 멱등성, 중복 이벤트/보상, 건너뛰기/다른 원정 거부, 스토리별 재료 지급, 지원권 종료/명시적 재초대, 재도전/상위 난이도/에픽 경계 |
| `lua tests/support-passes.spec.lua` | 30 PASS |
| `lua tests/story-completion.spec.lua` | 356 PASS |
| `lua tests/difficulty-enhancement.spec.lua` | 125 PASS |
| `lua tests/late-epics-adventures.spec.lua` | 186 PASS |
| `lua tests/deepwood-progress.spec.lua` | 최종570 PASS |
| `lua tests/deepwood-quests.spec.lua` | 31 PASS |
| `lua tests/expedition-departure.spec.lua` | 42 PASS |
| `lua tests/expedition-store.spec.lua` | 43 PASS |

`/private/tmp/td233-luau/luau-compile`로 수정한 Luau5모듈 컴파일 PASS. Lobby/Battle `rojo sourcemap`과 `git diff --check` PASS. 고정 소스 `09758d24b5613d8daee38a5a327e92068e7512e6`의0.69.5 Lobby/Battle 빌드 모두 PASS. `python3 tools/build-regional-caster-freeze.py --source 09758d24b5613d8daee38a5a327e92068e7512e6 --record docs/evidence/story-continuation-20261104/build.json`으로 실행했으며, [버전/입력/LFS/산출물 해시](build.json)를 기록하고 두 산출물의 SHA256을 다시 검증했다. 소스 커밋은 origin/main 푸시 후 원격 SHA 일치를 확인했다. 이번 변경에는 신규 LFS 자산이 없다.

## 미검증·다음 담당

Studio 연결 목록이 비어 있어 실제 엔진·정상 조작으로 DW-02 최종 도착→완료 카드→DW-03 Selene 대화 전체 경로는 미검증이다. 게시/실제 DataStore 재접속·4인 파티 동기화·터치/패드/실기기도 미검증이다. Roblox 게시·릴리스 태그는 수행하지 않는다. QA가 새 빌드의 실제 조작과 게시된 테스트 환경의 재접속을 확인한다. 상위 티켓 In Progress 유지.
