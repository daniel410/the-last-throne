# TLT 리딤·메일

작업: TLT-047/049/084 부분 확장 · 2026-11-13 사용자 요청. 요구: TD의 리딤과 메일을 TLT에 추가하고 같은 코드의 중복 사용을 막는다.

## 사용자 동작

로비 `MENU > MORE`에 TD 원본 `mailbox`·`redeem` 아이콘과 공통 상세 창을 사용한다. `Mailbox (N)`은 미수령/미확인 공지 수다. 메일에는 발신자·제목·본문·첨부 보상을 표시하고 일반 공지는 `MARK AS READ`, 선물은 `CLAIM GIFT`로 저장한다. 리딤은 영문 대소문자·앞뒤 공백을 정규화한다. 같은 코드는 TLT **계정당 1회**이며 영웅별 지급이 아니다. 사용한 코드를 새 요청으로 제출하면 `AlreadyRedeemed`를 표시한다.

메일은 운영팀 → 플레이어 공지/선물 수신함이다. 플레이어끼리 보내는 메일·채팅·거래는 포함하지 않는다. 기존 Roblox 상품 영수증 처리기를 대체하지 않는다.

## 서버 운영 설정

정본은 `src/server/Lobby/DeliveryCatalog.luau`다. 클라이언트에 코드 목록을 복제하지 않는다. 기본값은 보상 없는 환영 공지와 빈 코드 목록이다. 사용자 승인 없는 실제 무료 보상·공개 코드는 만들지 않았다.

- `codes`: 정규화한 영문 코드 → `{rewards, startsAt?, expiresAt?, userIds?}`. 시간은 UTC Unix 초, `userIds`는 숫자 UserId를 키로 하는 true 집합이다. 시작 포함·종료 미포함이며 계정별1회다. 캠페인 공개 후 코드 재사용·보상/대상 변경은 금지한다.
- `mails`: `{id, title, body, sender, rewards, startsAt?, userIds?}` 목록. 영구 ID를 재사용하지 않는다. 선물 메일은 자동 만료/삭제하지 않는다. 발송된 선물의 내용·대상은 보존하고 새 발송은 새 ID로 추가한다. 현재 소스 기반 운영이므로 새 캠페인은 코드 배포가 필요하다. 운영 중 즉시 발송하는 관리 화면/외부 발송 API는 없다.
- `rewards`: `{gold?, diamonds?, items?}`. 아이템 배열은 `{definitionId, quantity}`다. 실제 카탈로그의 유효한 비은퇴 아이템만 지급한다. Gold/Diamonds는 TLT 계정 잔액이며 TD와 공유하지 않는다. 아이템은 기존 `Gear & Bag > Claims` 대기 공간으로 지급한다.

예시(비활성 문서 예제):

```lua
codes={EXAMPLE2026={rewards={gold=50,items={{definitionId='iron_ore',quantity=5}}}}}
```

## 저장·복구 계약

기존 TLT 계정 `account:<UserId>`의 `UpdateAsync`와 세션 token/epoch/lease를 재사용한다. `deliveries['code:<CODE>']` 또는 `deliveries['mail:<id>']`에 `{at, requestId}`를 보상과 **같은 키 갱신**으로 기록한다. 다중 키 거래가 아니다. `operationOrder`의96개 회전 기록과 분리해 사용 기록을 영구 보존한다. 클라이언트는 action/value/requestId만 전송하며 금액·첨부·수신 대상은 서버가 결정한다.

동일 요청 재시도는 기존 기록을 반환해 지급을 반복하지 않는다. 새 요청으로 사용한 코드/메일을 다시 제출하면 거부한다. 저장 불명 상태에서는 계정을 새 데이터로 만들지 않고 같은 요청·입력·서버 시각을 유지해 `CHECK SAVE`로 확인한다. 타 서버 세션은 기존 fence로 차단한다. 로드 실패·변조된 기록은 지급을 닫고 기존 데이터를 보존한다. 로비 밖 지급은 거부한다.

원장 상한2000개에 도달하면 기존 기록을 삭제하지 않고 신규 지급을 중지한다. 현재 서버 설정 캠페인 수는 작게 유지하며, 장기 운영 전 원장 분할/이관 및 메시지 페이지 처리를 별도 설계해야 한다. 사용자 입력은 최대64바이트, 코드 시도는 초당1회 제한한다. 유료 구매의 ProcessReceipt 및 TD 운영 데이터는 변경하지 않는다.

## 수용

[검증·미검증](../evidence/redeem-mailbox-20261113/README.md), [비교 조사](../research/2026-11-13-redeem-mailbox.md). TLT-047/049 전체 완료와 G3/G7 통과로 처리하지 않는다. 후속 QA는 게시 테스트 계정의 실제 저장/재접속·터치/패드 조작·모바일 가로 화면을 검증한다.
