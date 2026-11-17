# 셀린느 지원 재검토

2026-11-17 · TLT-016/072/084 · 검토 결과 · ENG 후속 수정 필요

## 판정

0.113.3 로컬 Studio에서 동행과 전투 지원은 발동했다. 사이드 원정의 지원 시작과 동행 중 캠프 조작에서 결함 두 건을 재현했다. [지원 계약](../../companions-and-support.md)

| 재현 조건 | 기대 결과 | 관측 결과 |
| --- | --- | --- |
| DW-03을 완료한 영웅이 첫 체험을 남겨 둔 채 DW-Q1 사이드 원정의 지원 캠프에 접근. 빈 동료 슬롯 | 다음 메인 스토리에서 첫 체험 사용 | 동료 업데이트의 무료 체험 후보에 사이드 원정도 포함된다. 서버 거래 재현에서 활성 원정은 DW-Q1인데 지원 대상은 `main:4`가 되고 체험 사용이 기록됐다. |
| 같은 원정에서 체험 사용 완료, 잔여 2장, 캠프 초대 | 다음 메인 스토리에 쓸 2장 보존 | 서버 거래가 캠프 접근을 승인 근거로 사용해 2장에서 1장으로 차감했다. 실제 DW-04 원정의 식별자와도 다르다. |
| Elder Tree 캠프 NPC 바로 앞에서 활성 지원을 받는 영웅 옆에 동행 셀린느가 있음 | 휴식과 상세 보기 가능 | 캠프 도달 판정은 참이다. 클라이언트 표시 코드가 동행 모델을 우선해 캠프의 휴식·상세 프롬프트를 모두 껐다. 동행 모델에도 조작 프롬프트가 없다. |

## 검증 방법과 관측값

- 기준 산출물은 `builds/0.113.3/TheLastThrone-0.113.3.rbxlx`, SHA-256 `e496b9ab52bd5a8f4677a9b176a0690039864ec0fff49b521fde16cc7945d895`이다. 복사본에서 Studio를 구동했다.
- 로비 출발은 기존 `tests/selene-departure-native.luau` 25검사 통과. 모의 계정·플레이어 4개로 실제 모델 이동, 모험 동료 1명, 입장 시 1회 차감, 나머지 3명의 지원권 보존을 확인했다.
- 전투는 `tests/selene-support-native.luau`를 기반으로 현행 캠프 위치 입력과 스킨 구조에 맞춘 임시 검사에서 34검사 통과. 실제 CombatService와 Humanoid를 사용하고 전투 세션·플레이어 식별은 모의로 제공했다. 회복은 40/100에서 52/100, 보호막은 10에 만료까지 3초, 기절 해제는 Stunned에서 Idle로 전환됐다. 동료 업데이트를 연속 실행해 즉시 재시전하지 않는 것도 확인했다.
- 사이드 소비는 Lua에서 실제 AdventureRules.begin으로 DW-Q1에 입장하고 SupportPassRules.view의 story/scope와 서버 캠프 접근 조건으로 InventoryRules.supportPass의 Activate를 호출했다. 결과는 다음과 같았다.

```text
DW-Q1 · unused trial · target main:4 · credits 2 -> 2 · trial used · active true
DW-Q1 · used trial   · target main:4 · credits 2 -> 1 · active true
```

- 캠프 조작은 Studio에서 CampaignWorld.create(1), SeleneCompanion.create, NPCPresentation.create/update를 사용했다. 실제 캠프와 동행 모델, 모의 소유자·저널로 확인한 프롬프트 상태다.

| 상태 | 캠프 도달 | Invite | Rest | SupporterDetails |
| --- | --- | --- | --- | --- |
| 해금 후 휴식 중 | true | true | false | true |
| 같은 위치에서 동행 중 | true | false | false | false |

- Lua 원본 검사 중 영입 23, 지원권 30, 상세 정보 45검사를 통과했다. 기존 무료 체험·출발 검사 2개는 현행 필수 퀘스트를 생략해 StoryLocked로 중단됐다. 임시 사본에서 현행 필수 목표·퍼즐 해답과 체험 검사의 입장 레벨 조건을 맞춰 각각 28·26검사를 통과했다.

## 다음 담당

ENG는 사이드 원정의 신규 지원 활성화를 서버 거래와 자동 체험 후보 양쪽에서 차단하고, 동행 중 캠프 프롬프트를 사용할 수 있게 수정한다. QA는 두 재현 조건을 회귀 검사하고 게시 테스트 클라이언트에서 실제 계정의 구매·입장·재접속, 실제 파티와 기기별 조작을 확인한다. 이번 재검토에서 게시 클라이언트·실기기·사용자 수용은 미검증이다.
