# 원정 공통 출발 실패 진단

2026-11-16 · TLT-053 / ENG · 원인 미확정, 진단 패치.

## 사용자 보고와 확인 범위

0.111.29 게시 뒤 사용자가 로비의 START SOLO ADVENTURE에서 로딩으로 전환되지 않고 `The party service is unavailable. Wait and refresh; your progress is safe.`가 나온다고 보고했다. 스크린샷은 Easy GW-06 One Brave Step과 DW-01 The Missing Supply Convoy 양쪽이다. 첨부는 로컬 대화 첨부로 보존하며 중복 자산을 커밋하지 않는다.

이 문구는 `NetworkUnavailable`의 공통 안내다. `startRun`이 예외를 숨기거나 `ExpeditionStore`의 MemoryStore read/update가 실패할 때 동일하게 반환하므로, 문구만으로 어느 호출이 원인인지 판단하지 않는다. 기존 규칙1~19 버전 불일치 수정과 현재 공통 출발 실패를 구분한다.

- 현재 Studio의 실제 0.111.29 모듈에 `departureVersion`과 출발 호출이 있음을 확인했다. 실제 require 후 신규 영웅의 계산19는 성공했다.
- 실제 `TeleportOptions.ReservedServerId` GUID 설정은 성공했고, [공식 계약](https://create.roblox.com/docs/reference/engine/classes/TeleportOptions)도 developer-supplied GUID 경로를 명시한다. 과거 AccessCode 경로로 추측 변경하지 않았다.
- Studio의 RPG 테스트 DataStore 읽기는 `StudioAccessToApisNotAllowed`로 거절됐다. 별도 Open Cloud GET도403권한 부족이었다. 설정을 바꾸거나 우회하지 않았으며 사용자에게 MCP의 읽기 권한 선택을 요청했다. 라이브 데이터 읽기/쓰기 성공은 없다.
- 웹에서 확인한 오류는 이전 배틀의 원정 검증 추방2회, 최초V28이며 현재 출발 실패의 상세 원인은 확인되지 않았다.

## 변경과 검증

출발의 `pcall`을 `xpcall`/traceback으로 바꿔 `[Expedition] Departure exception`을 남긴다. MemoryStore read/update 실패는 `run/rejoin/party/member` 키 종류와 오류를 남기며 키 본문·입장 ticket은 출력하지 않는다. 원정 준비는 createRun/stageOffer/prepareTransfer 중 중단 단계를 기록한다. 기존 반환 코드·출발 승인·티켓·저장 실패 시 정지/복구·TD 격리는 유지한다. 원인 미확정 상태에서 데이터·성장·입장 규칙을 추가 변경하지 않았다.

- [Lua 회귀](rules.log): 출발94·스토어43·원정준비42·버전재개183, 총362검사 PASS.
- [격리 Studio](native.log):61소스 컴파일·동일362검사 PASS. 주입한 저장 오류/응답 유실/출발 예외에 단계·traceback이 남고 최종 PASS임을 확인한다. 로그 안의 warning은 의도한 장애 주입이며 실제 Roblox 장애 증거가 아니다.
- `python3 tools/prepare-expedition-resume-native.py` → `run-in-roblox --place /tmp/tlt-adventure-starting-empty.rbxlx --script /tmp/tlt-expedition-resume-native.luau`.

## 전달과 미검증

0.111.30은 장애의 근본 수정 완료가 아니라 실제 원인 수집용이다. 입력 커밋·산출물/해시는 build.json, 실제 게시 결과는 publish.json에 별도 기록한다. 실제 저장 기록/서버 오류를 확보한 뒤 재현→근본 수정→실제 게시 클라이언트 재검증으로 이어간다. TLT-053/G3는 미완료다. 새 로비 서버에서 솔로 출발을1회 실행하고, 오류가 지속되면 새 `[Expedition]` 서버 warning의 단계/호출 오류를 확인한다. 게시·실제 재현·원인 확정·수용을 서로 구분한다.


## 0.111.30 진단 게시

입력 소스 `1f310e4df1650ea18dd617e299cf88d51706e38f`의 origin/main 일치를 확인하고 고정 빌드를 생성했다. [빌드 기록](build.json)·[산출물3모듈/해시 확인](artifact-check.log). 동일 파일을 TLT 로비102(20:52)·배틀30(20:53 America/Toronto)에 게시했고, Creator Dashboard에서 Show published only를 켜 각 최신 버전을 확인했다. [게시 기록](publish.json). Private 유지, TD 미변경, 새 게임성/자산 없음. 릴리스 주석 태그 v0.111.30은 위 입력 소스를 가리킨다.

사용자에게 게임을 완전히 종료한 뒤 새 로비에서 START SOLO ADVENTURE를1회 실행하도록 요청했다. 아직 사용자 재현 결과와 새 서버 오류가 없으므로 근본 원인/수정 완료를 주장하지 않는다. 후속은 해당 warning 또는 허용된 읽기 권한으로 실제 실패 원천을 확인하고 수정하는 것이다. UI 연결이 이전 Studio를 우선 선택해0.111.29 미저장 세션은 publish.json의 로컬 백업으로 별도 보존한 뒤 닫았고 원본 빌드를 덮지 않았다.
