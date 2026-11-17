# 원정 재개 규칙 버전 불일치 수정

2026-11-16 · TLT-053 / ENG / 소스 수정·격리 검사, 게시 클라이언트 수용 미완료.

## 결함과 변경

Creator Dashboard의 TLT 오류 보고서에서 11월16일20:04 현지 시간 Client/Error 1회, `Server Kick Message: Your expedition could not be verified. Rejoin from the Dawnspire lobby.`를 확인했다. 웹 로그에는 계정의 저장 규칙/실패 이유가 없어 해당 계정의 원인을 단정할 수 없다. 코드 추적과 격리 실행에서 같은 추방 분기를 일으키는 버전 불일치를 재현하고 수정했다. 별도 게임성 변경/리서치 없이 결함을 수정했다.

로비 `startRunLocked`는 항상 최신 `Difficulty.version=19`로 서버 입장 기록을 만들었다. 도착지 `AdventureRules.begin`은 진행 중인 기존 스토리의 규칙1~18을 보존한다. 따라서 저장 성공 뒤에도 `Difficulty.verifyRun`에서 입장 기록과 영웅의 `balanceVersion`이 달라져 추방된다.

- `AdventureRules.departureVersion`은 계정 사본의 이관/현재 모드 저장/이어할 스토리를 도착지와 동일하게 해석한다. 공통 `pinnedRun` 판정으로 실제 저장과 출발 계획의 차이를 방지한다.
- 서버는 참가 영웅의 보존 버전으로 입장 기록을 만든다. 기존 체크포인트·진도·보상/적 규칙·재화·영수증은 변경하지 않는다. 신규 영웅/다른 스토리는 최신 규칙을 사용한다.
- 참가자 버전이 다르면 `PartyRulesMismatch` 영문 안내로 저장/출발 전에 거절하고 파티를 forming으로 되돌린다. 공통 전투 규칙이 다른 영웅을 같은 서버에 보내거나 기존 원정 보상을 최신 수치로 강제 변경하지 않는다.
- 서버 승인 티켓·소유권·버전 검증은 유지한다. TD 운영/저장/상품/Place는 변경하지 않았다. 기존 미커밋 자산과 삭제 파일은 스테이징·빌드 입력에서 제외했다.

## 검증

- [Lua 회귀](rules.log): 원정 재개 규칙, 출발 준비, MemoryStore, 출발 안내, 난이도별 진도/이관/레거시 재개, 골드, 도착 로딩을 실제 순수 모듈로 실행한다. 원정 재개 전용183검사는 규칙1~19·최신 기록 불일치 재현·수정 후 저장/입장 일치·중복 도착·신규 솔로/파티·동일/혼합 버전 파티·다른 활성 난이도를 포함한다. 전송/저장은 모의이며 라이브 데이터를 읽거나 수정하지 않는다.
- [격리 Studio Luau](native.log):61소스 컴파일, 재개183·출발42·스토어43·출발 안내94검사 PASS. 실제 `startRunLocked` 소스를 추출 실행하고 실제 계정 규칙으로 도착지 저장 결과를 검증한다. `python3 tools/prepare-expedition-resume-native.py` → `run-in-roblox --place /tmp/tlt-adventure-starting-empty.rbxlx --script /tmp/tlt-expedition-resume-native.luau`. 빈 로컬 PlaceId0, 실제 Player 없음. 기존 열린 게임 수정 없음.
- 첫 격리 실행은 테스트 환경의 Lua `_G`와 Studio 전역 환경 차이로 중단됐다. [초기 하네스 실패](native-harness-initial.log)를 보존하고, 생성기에서 `getfenv()`를 사용하도록 수정한 재실행이 위 결과다. 제품 결함으로 분류하지 않는다.

## 빌드·복구·다음 담당

버전0.111.29의 소스 `37bb62f470facc1212ad351a4afba8d6e3927b35`를 origin/main에 푸시하고 원격 커밋 일치를 확인한 뒤 단일 빌드를 생성했다. `builds/0.111.29/TheLastThrone-0.111.29.rbxlx` 생성 성공. [산출물 검사](artifact-check.log)에서 변경 런타임3개가 고정 입력 커밋과 바이트 단위로 같고 산출물 SHA-256이 빌드 기록과 일치함을 확인했다. 입력 커밋·산출물·SHA-256·결과는 [고정 빌드 기록](build.json)에 기록한다. Roblox 게시와 릴리스 태그는 이번 수정 작업에서 수행하지 않는다.

QA/다음 게시 담당: 동일 빌드를 TLT Lobby/Battle에 게시 후, 규칙1~18 진행 중 영웅의 Continue→실제 Teleport→배틀 입장→목표 진행→복귀/재접속을 확인한다. 신규 영웅/같은 버전2~4인과 혼합 버전 출발 차단도 확인한다. 게시 테스트 클라이언트·실기기·실제 저장 지연/동시 서버·사용자 수용은 미검증이며 TLT-053/G3 완료로 처리하지 않는다. 이미 실행 중인 서버/기존 생성 원정 기록에는 소스 수정이 소급 반영되지 않으므로 게시 후 새 로비에서 출발해야 한다. 복구는 이번 소스 변경을 되돌려 재빌드/게시하며 계정 데이터 복원이나 재화 보정은 필요 없다.
