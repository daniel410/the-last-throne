# 3인 파티 시작 실패 조사

2026-11-16 · TLT-053 / ENG · 사용자 장애 보고, 실제 조건 확인 중. 런타임 수정/새 빌드 없음.

사용자가0.111.31 게시 뒤 3인 파티의 시작 실패를 보고했다. 아직 버튼 비활성/오류 코드/준비·진도·규칙 버전의 실제 조합을 확인하지 못했다. 웹 로비 오류 보고서를 새로 조회했으나 당시 표시된 항목은 이전 HashMap 실패 기록뿐으로, 이번 시도의 새 예외를 확보하지 못했다. 실패 원인을 확정하거나 실제 파티 시작 성공을 주장하지 않는다.

## 재현 검사

`tests/party-launch-native.luau`는 고정0.111.31 Place 사본을 빈 로컬 Edit 세션에서 열어 실제 ExpeditionService를 복제해 호출한다. 플레이어·계정 전송·Teleport는 모의이며, 실제 Store/Backend/Presentation/AdventureRules/영웅 생성·자격 로직을 사용한다. 저장 전 전원 잠금과 UI용 파티 projection도 검사한다. 주기 task는 꺼서 사용자 서버·실제 계정에 접근하지 않는다.

실행:

```text
cp builds/0.111.31/TheLastThrone-0.111.31.rbxlx /tmp/tlt-party-launch-011131.rbxlx
run-in-roblox --place /tmp/tlt-party-launch-011131.rbxlx --script tests/party-launch-native.luau
```

[격리 실행 결과](baseline-native.log):135검사 PASS.

- 같은 조건의2/3/4인: 전원 참가→한 명 미준비 시 버튼/서버 거절→마지막 Ready 후 launchAllowed→비리더 거절→리더 시작 시2/3/4명 전원 저장 준비1회 및 같은 예약 배틀로 개별 티켓 이동 요청.
- 출발 준비 중 영웅 변경 차단·저장 전 전원 출발 안내·정상 출발 뒤 전송 잠금 유지.
- 혼합 규칙17/19의3인: 모두 Ready/현재 자격은 충족해도 `PartyRulesMismatch`, 저장/이동0회가 재현된다. 현재 projection은 이 조건을 launchAllowed에 반영하지 않고 서버 시작에서 거절하므로 해당 조합이면 사용자가 버튼을 누른 뒤 거절된다.

이 결과는 실제 사용자의 세 영웅을 재현한 것이 아니다. 실제 화면의 오류/조건이 `PartyRulesMismatch`인지, 미준비/진도/레벨/미집결인지, 출발 후 API 실패인지 확인해야 한다. 서로 다른 보존 규칙을 강제로 합치거나 저장 진도를 덮는 임시 변경은 수행하지 않았다. 기존 파티 요구/선행/권리/TD 격리는 유지한다. 이번 조사와 검사 추가는 문서/테스트 변경이므로 VERSION/릴리스 태그/Roblox 게시를 만들지 않는다.

다음 담당: 사용자/QA는 PARTY 탭의3명 준비/입장 조건과 아래 오류 문구를 확인한다. 엔지니어는 그 조건을 동일한 격리 fixture로 재현한 뒤 필요한 런타임 수정과 실제 게시 클라이언트 재검증을 수행한다. TLT-053/G3는 미완료다.
