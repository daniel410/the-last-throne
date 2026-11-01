# Lv5 Wind Lance 4번 슬롯 저장 복구

2026-11-01 · TLT-013/052/054~056/084 · ENG → QA · 0.58.24 로컬 수정

사용자 재현: Mage Lv5, Wind Lance 선택 후4번 슬롯을 눌러도 저장되지 않음. 슬롯/학습 계약은 정상이며 별도 기능 리서치가 필요 없는 결함 수정이다.

## 확인한 결함과 수정

- 편성 요청 직전 서버 XP가 계정 revision을 올리면 기존 요청은 `Changed`로 거절된다. 실제 GUI는 이 결과를 일반 필드 안내로 덮어썼다. 확정 거절된 SetSkillSlot만 최신 snapshot의 같은 영웅/슬롯/스킬로1회 재시도한다. 재시도도 서버의 레벨·안전·중복·revision 검증을 통과해야 한다.
- 더 최신 상태를 먼저 받은 경우 이전 revision의 확인 응답 전체를 버려 pending이 남았다. 이제 상태는 역행시키지 않고 일치하는 요청의 응답은 처리한다.
-2초마다 동일 snapshot도 전체 버튼을 파괴/재생성했다. 동일 상태 폴링은 다시 그리지 않아 누르기/떼기 사이 버튼 소실을 방지한다. 안전/로드 상태 변경은 즉시 갱신한다.
- 성공/오류 문구를 일반 안내로 덮지 않는다. `SaveUnknown`은 원래 요청을 유지하고 자동으로 새 요청을 만들지 않는다. 스탯 배분/전직은 자동 재시도하지 않는다.

## 검증

| 명령/조건 | 결과 |
| --- | --- |
| `lua tests/hero-progression.spec.lua` |656개 통과 |
| `lua tests/advanced-skills.spec.lua` |1,435개 통과 |
| `lua tests/inventory.spec.lua` |271개 통과 |
| 기존 소스 + 동일 GUI/계정 규칙 fixture | 동일 폴링 버튼 소실 및 늦은 Changed 미복구 각각 실패 재현. [폴링](before-poll.log), [충돌](before-conflict.log) |
| `run-in-roblox --place builds/0.58.23/TheLastThrone-Battle-0.58.23.rbxlx --script /tmp/tlt-loadout-recovery-native.luau` | 최종 HeroGrowthGui 소스 주입, [13개 통과](native.log). Lv5 Wind Lance→슬롯4 서버 규칙 저장, XP 경합, 최신 응답 선도/늦은 거절, 재시도1회 제한, 결과 문구 보존, unsafe/unknown 차단 |
| `git diff --check` | 통과 |

Native fixture는 실제 HeroGrowthGui 생성자·InventoryRules를 쓰며 Player/전송은 대역이다. 수신 응답과 send 함수를 fixture seam으로 호출했으며 실제 마우스/터치·라이브 DataStore·재접속·게시 클라이언트 검증을 뜻하지 않는다. 초기 최종 재실행1회는 다른 run-in-roblox가 쓰던50312 포트 충돌로 시작 실패했으며 포트 해제 후 재실행 통과했다. native 로그의 기존203785492 자산 유형 경고는 이번 수정과 별개다. 실행 도구가 생성한 별도 QA Studio 세션은 종료했으며 기존 사용자 Studio는 편집하지 않았다.

빌드는 입력 커밋 고정 후 [build.json](build.json)에 버전·소스·도구·산출물 해시를 기록한다. 기존 다른 작업의 미커밋 파일은 빌드/커밋에서 제외한다. 게시·릴리스 태그는 생성하지 않는다. 다음 QA는 게시 후 실제 Lv5 Mage로 SKILLS→Wind Lance→슬롯4 저장/전투4번 사용·재접속 유지를 확인한다. 상위 티켓은 미완료를 유지한다.
