# HashMap 장애에 대한 원정 저장 경로 수정

2026-11-16 · TLT-053 / ENG · 원인 확인·구현/격리/실제 API 검사, 게시 클라이언트 수용 후속.

## 확인한 실패

사용자가0.111.29/30의 DW-01과 GW-06 솔로 출발에서 같은 안내를 보고했다. 0.111.30 진단 후 Creator Dashboard에서 **Place를 로비70829337938054로 선택**하자 HashMap.Get142회·HashMap.Update51회와 createRun 중단 warning을 확인했다. 이전에는 배틀 필터가 선택되어 현재 로비 오류가 보이지 않았다. [실제 로그와 API 검사](platform.log).

Studio의 실제 API 검사에서도 기존 HashMap과 새 이름의 빈 HashMap 모두 InternalError였으며 SortedMap 읽기/쓰기/조건부 갱신은 성공했다. 이는 관찰한 HashMap 경로의 실패이며 Roblox 전체 장애나 계정 손상을 입증하지 않는다. 공개 상태 페이지에서 이 장애의 공식 확인을 확보하지 못했다. [공식 MemoryStore 계약](https://create.roblox.com/docs/cloud-services/memory-stores/best-practices)은 HashMap/SortedMap 양쪽의 UpdateAsync 원자적 갱신을 지원한다. 계정 DataStore는 변경하지 않는다.

## 변경과 권한 보존

- 신규 원정/파티의 서버 생성ID에 `sm2_`를 붙이고 **모든 신규 키를 고정 SortedMap `TLT_Expedition_v2`**에서 다룬다. 선택/출발/도착/재접속이 ID로 같은 원본을 선택한다. 실패/불명 쓰기를 다른 저장소로 재전송하지 않으며, 기존 HashMap 기록을 새 저장소로 복제하지 않는다.
- 기존 접두사 없는 원정은 기존 `TLT_Expedition_v1` HashMap에서만 읽고 갱신한다. 새 원정 capability가 없으면 기존 rejoin을 조회할 수 있다. 새 원정 조회 실패/종료 표시는 빈 기록으로 취급하지 않고, 새 원정 완료 후 옛 capability를 다시 노출하지 않는다.
- 도착지에서 기존 HashMap 티켓은 **이미 저장된 같은 원정의 재개만** 허용한다. 낡은 staged 출발이 새 SortedMap 원정의 저장 체크포인트를 되돌리지 않도록, 새 journal 초기화는 `sm2_` 원정으로 제한한다. HashMap 장애 중 옛 원정의 REJOIN은 여전히 실패할 수 있으나 저장 진도는 유지되며 새 로비의 Continue/Solo는 새 경로를 사용한다.
- 기존 forming 파티는 새 목록에서 제외하고 Join은 PartyChanged로 거절한다. 새 로비에서 파티를 다시 구성한다. 기존 원정/재화/영웅/보상 규칙/영수증/티켓/소유권 검증은 삭제하거나 완화하지 않는다. 기존 원정 규칙 버전 보존 수정도 유지한다.
- 현재 출발 단계는 기존과 같이 원정 생성→pending capability→프로필 저장/임대 해제→Teleport이며, 목적지의 영속 begin 이후 capability를 승격한다. 여러 키를 원자 거래라고 간주하지 않는다. 이전 서버가 기존 HashMap을 사용하는 동안 새 원정의 키를 공유하지 않는다.

## 검증

- [Lua 회귀](rules.log): 고정 backend34·규칙 재개183·원정 준비42·스토어43·출발 안내94, 총396검사 PASS.
- [격리 Studio Luau](native.log): 63소스를 컴파일하고 위396검사 PASS를 확인했다. 의도한 오류 주입 warning은 실제 장애 증거와 구분한다.
- backend34검사는 HashMap 전체 장애 중 신규 출발/티켓 승인, 서버 소유 lease/다른 유저/위조 티켓, 기존 checkpoint 보존, 저장 성공 후 승격 응답 유실, 현재 조회/쓰기 불명 때 옛 저장소로 우회 금지, 취소된 신규 준비 후 기존 rejoin 보존, 종료 후 옛 권리 재노출 차단을 포함한다. 실제 Service의 도착 블록을 추출해 legacy staged 티켓이 journal을 덮지 않고 검증된 기존 원정은 재개하며 신규 staged 원정만 begin함을 확인한다.
- [실제 API 검사](platform.log): TLT universe에서 임시 QA 키로 SortedMap 생성·읽기·조건부 갱신·정리 및 실제 ExpeditionStore의 생성/stage/admit/위조 거절/서버 소유 fence/잘못된 취소 거절을 확인했다. 만료15초를 사용하고 검사 후 QA 키를 제거했다. 사용자 계정/기존 원정은 수정하지 않았다. Studio Edit API 검사는 실제 Player/프로필 저장/게시 Teleport 검사가 아니다.
- 실행: `python3 tools/prepare-expedition-resume-native.py`, 빈 로컬 Place에서 `run-in-roblox --place /tmp/tlt-adventure-starting-empty.rbxlx --script /tmp/tlt-expedition-resume-native.luau`.

## 전달과 미검증

0.111.31의 입력 커밋/단일 빌드는 build.json, 실제 게시 결과는 publish.json에 기록한다. 신규 Lobby/Battle 둘 다 동일 빌드를 사용해야 한다. 구 서버에서 생성된 원정ID는 새 저장소로 자동 복사하지 않는다.

사용자/QA: 새 로비에서 DW-01 또는 GW-06 Solo→실제 로딩/배틀→목표 진행→복귀/재접속, 파티2~4인 재구성/출발과 다른 서버 소유 거절을 확인한다. 실제 게시 클라이언트·실기기·플랫폼 HashMap 복구 후 구 원정 REJOIN·신구 서버 혼재/복구 리허설은 미검증이다. TLT-053/G3 완료로 처리하지 않는다. 되돌릴 때 backend만 자동 전환하지 않는다. `sm2_` 원정이15분간 유지될 수 있으므로 구 빌드로의 일괄 복원은 진행 중 새 원정의 REJOIN을 일시 중단시킬 수 있다. 계정 journal은 남으며 Continue로 재개한다.


## 0.111.31 게시와 후속

입력 소스 `24c4b643325a4c50a6cb1d0a73fe789a95aa73dd`의 origin/main 일치 후 단일 빌드를 생성했다. [빌드](build.json)·[산출물3모듈/해시 일치](artifact-check.log). 동일 파일을 TLT 로비103(21:17)·배틀31(21:18 America/Toronto)에 게시했고 웹 Show published only에서 확인했다. [게시 기록](publish.json). 릴리스 주석 태그 v0.111.31은 실제 입력 소스를 가리킨다. Private·TD 유지, 파일 해시 불변. 기존0.111.30 Studio 세션은 별도 로컬 rbxl로 보존 후 닫았다.

사용자에게 새 로비에서 START SOLO ADVENTURE를 재시도하도록 요청했다. 현재 이 증거는 API/격리 회귀/게시 성공이며 실제 사용자 배틀 입장 결과는 아직 미확인이다. 구 서버는 기존 HashMap 경로를 계속 사용하므로 재접속 때 게시 로비103 이상인지 구분해야 한다.
