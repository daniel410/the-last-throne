# TD 지갑·상품·보상 writer 읽기 전용 감사

2026-10-28 · 역할: 총괄 디렉터 · 연결: TLT-021 부분 증거 / G0 조사 · 상태: 현행 로컬 소스 조사

## 1. 결론과 확인 범위

현행 TD는 `DiamondWallet`이 Diamonds 잔액·수령ID·구매ID·일부 TD 아이템/권리를 같은 프로필에서 갱신하고 `ReceiptDispatcher`가 Developer Product 영수증을 라우팅한다. 이 기반의 재사용을 먼저 검토할 수 있으나 **공통 지갑 구현·TD/RPG 연동·TLT-021 전체 완료의 증거는 아니다.**

조사 대상은 형제 저장소 `/Users/daniel/Workspace/project/roblox/throne-defense`의 현재 작업 파일이다. TD HEAD는 `22ff3be95a8e9d3c034d83d93b8c540a36070ac2`이며 조사 목록 중17개에 추적된 미커밋 변경이 있다. HEAD만으로 본문 관측을 재현할 수 없어 아래22개 파일의 SHA-256을 함께 고정했다. 파일 전체 또는 관련 호출/설정 구간을 정적으로 읽었으며, 모든 코드 경로를 실행하거나 모든 의존을 전수 검증한 것은 아니다.

이번 변경 파일은 이 감사 문서 하나다. TD 소스·라이브 DataStore·상품·Place·기존 잔액은 수정하지 않았다. 게시된 소스/서버·Creator Dashboard·실제 저장값은 조회하지 않았다. K0는 공통 지갑 쓰기 없이 독립 전투 실험으로 진행하고, 연동 활성은 별도 계약/검증 뒤 판단한다.

## 2. 실제 저장·영수증·구매 경계

| 영역 | 관측한 소스 위치/내용 | 후속 계약에서 보존할 것 |
| --- | --- | --- |
| 저장 진입 | `DiamondWallet.lua:102~126`의 `Persistence.mutate("diamonds", tostring(player.UserId), ...)`. `Persistence.lua:56~60`이 `GetDataStore("ThroneDefense_" .. scope)`를 호출 | 현재 로컬 코드상 저장소명은 `ThroneDefense_diamonds`, 키는 문자열 UserId. 실제 운영 배포/이름은 추가 확인 |
| 프로필 | `balance / claims / receipts / items / entitlements / features / version / revision`. items에는 continue/freeRolls와 timeScaleTickets/goldBoosts, 권리에는 유효시간 등이 있음 | 잔액만 복사한 새 RPG 프로필을 만들거나 기존 수령/구매/복구 기록을 버리지 않음 |
| 실패/불명 결과 | `Persistence.read/write/mutate`는 found/missing/unavailable·durable/unknown/transform_error/cancelled를 구분. mutate는 UpdateAsync 콜백 오류 시 취소하고 메모리 대체 실행 없음 | strict 결과를 유지. legacy get/set/update는 session_only fallback이 있어 성공 boolean만으로 영속 완료를 판단하지 않음 |
| 지갑 준비/표시 | `DiamondWallet.load`는 transact를 통한 초기화/복구, `getState`는 ready가 아니면 balance=nil. confirmed 권리와 소비 가능 잔액을 구분 | 불명/실패 로드를0으로 저장하거나 소비 가능 상태로 표시하지 않음 |
| 영수증 소유 | `ReceiptDispatcher.lua:52`의 ProcessReceipt 대입1개가 `src/Server` 검색에서 확인됨. ServerMain→LuckPotion.init→ReceiptDispatcher.init 경로 | 관련 Place 서버마다 호환 버전의 단일 라우터. ServerMain/LuckPotion의 “LuckPotion이 콜백 소유” 옛 주석과 실제 대입 위치를 구분 |
| 영수증 처리 | productReward가 양의 상품ID·정확히1개 일치·폐기 pass 충돌을 검사. 온라인 Player가 있어야 grantReceipt 호출. `robux:<PurchaseId>`에 productId를 지속 기록하고 durable 확인 뒤 PurchaseGranted | 같은 구매ID 재시도·Place 변경에도 한 번. 미설정/충돌/불명 응답은 NotProcessedYet. RPG 상품은 현재 라우터에 없음 |
| Diamonds 구매 | `DiamondWallet.purchase:361~400`이 서버 Config SKU/금액·요구 상태를 검사하고 `shop:<requestId>`로 차감/권리를 같은 프로필에 기록 | 클라이언트 가격/잔액 주장을 받지 않음. 요청ID·SKU·실제 지급 대상의 호환 계약 필요 |
| TD 전투 Gold 구매 | `GameManager.purchaseWithDiamonds:632~667`과 settleGoldPurchase가 runId·메모리 지급 확인·pending/delivered/refunded를 다룸 | TD의 임무 Gold 지급 계약이다. RPG Coins/장비 지급용으로 그대로 사용하지 않음 |
| 이동 장벽 | Persistence의 transferFrozen/active/failures와 freezeForTransfer, MatchCoordinator의 flush/지갑 ready 검사를 확인 | 현재 서버 메모리 장벽만으로 모든 Place·구버전 writer·RPG 세션의 차단을 증명하지 않음 |

`src`의 `"diamonds"`, `ThroneDefense_diamonds`, `.balance` 대입과 지갑 함수 호출을 검색했다. 확인한 로컬 소스에서 직접 diamonds scope를 갱신하는 진입은 DiamondWallet이며, LoginCalendar의 잔액 변경도 DiamondWallet.transact 안에 있다. 검색 밖의 도구/다른 저장소·Place 스크립트·운영 복구 도구·구버전까지 writer가 없다는 증명은 아니다.

### 실제 보상/소비 호출자

| 호출자와 관측 위치 | 지갑 작업·지속 ID/권리 | 다른 저장 경계 |
| --- | --- | --- |
| LoginCalendar:113~133 | transact 안에서 `login:<UTC day>`·잔액·login feature를 함께 저장 | 별도 login 기록을 후속 갱신. 지급 원본과 표시/진행 기록의 복구 검사 필요 |
| DailyQuest:248~285 | grantClaim `quest:<date>:<questId>` | quests 진행을 strict read/flush 후 확인하고 claimed 기록 후속 갱신 |
| BattlePass:280~315 | grantClaim `bp:<season>:free:<tier>`, Diamonds·luck/freeRolls/timeScaleTickets/continue | battlePass 진행/수령 projection은 별도. 현행 free 경로와 기존 premium 권리를 혼용하지 않음 |
| RedeemCode:47~60 | grantClaim `code:<normalized code>`, 기존 필드명 entry.gold | redeem 기록 별도. gold라는 필드명만 보고 TD 전투 Gold로 해석하지 않음 |
| Mailbox:169~183 | grantClaim `mail:<mailId>`, selected.gold→Diamonds와 luck | mail의 claimed 기록 별도. 메일 생성/만료/현재 보상 정책도 TD 전용 |
| ReturnMissions:208~219 | 지속 pendingRewards를 읽어 grantClaim `return:<key>`와 luck 후 대기 제거 | returnMissions outbox와 지갑 사이 확인/재처리 경계 |
| GameManager:879~887, MapClearRewards:49~58 | 완료 runId로 recordMapClear→settleMapClear, `mapclear:<run>` | 메모리 unrecorded/지갑 mapClearPending/confirmed를 구분. 첫 지속 기록 전 서버 소멸은 별도 검증 범위 |
| GameManager·NetServer·ContinueInventory | shop / boost / retry / timescale ID로 구매·부스트·부활 예약/확정/환급 | TD 임무/시간권/기존 continueitems와 연동. RPG 리셋권/장비 계약 아님 |
| WeeklyLeaderboard·AfkGold | WeeklyLeaderboard는 Mailbox 경유 보상 흐름이 있고, AfkGold는 현행 ended 응답만 보냄 | “과거 AFK 보상 모듈”이 현재 신규 Diamonds writer라는 가정 금지 |

## 3. 현행 로컬 상품 설정

| 설정 | 현재 파일에서 읽은 값 | 확인 의미 |
| --- | --- | --- |
| DIAMOND_PACKS | 100/500/1,200 Diamonds 팩의 productId가 모두0 | 현행 라우터에서 판매/지급 가능한 양의ID로 등록되지 않음 |
| LUCK_POTION | productId=0·durationSec=1,800·표시용99Robux | 실제 Dashboard의 상품·판매 상태/가격은 미확인 |
| BATTLE_PASS | PREMIUM_PRODUCT_ID=0, 라우터는 retired pass product를 거부 | 기존 확인된 pass 권리와 신규 판매를 별도 보존/판단 |
| DIAMOND_SHOP | time_scale_ticket=25, double_gold_boost=50, gold_100=10, continue_item=50 Diamonds | TD 로컬 카탈로그 관측값. RPG 상품 가격/성능의 승인값이 아님 |
| SUPPORTER_PASS | id=0, 별도 SupporterPass의 플랫폼 소유권 경로 | Developer Product 지갑 라우터와 별개인 외형 pass 경계 |

실상품ID가 로컬 파일에서0이라는 사실은 실제 운영 게임에 상품/구매자가 없다는 증거가 아니다. 게시된 버전·운영 설정·기존 구매/수령·수동 복구 이력을 TLT-021에서 대조해야 한다.

## 4. 공통화 전에 분리할 TD 정책

`DiamondWallet.transact`는 단순 잔액 커널 외에 다음 TD 정책을 실행한다. **RPG 서버에서 현행 모듈을 직접 require해 “공통 지갑 완료”로 취급하지 않는다.**

- Config.REWARD_POLICY_VERSION=3과 migrateRewardPolicy가 TD의 미수령 구 정책을 현재 정책으로 바꾸고 mapClearPending을 현재 보상 상한에 맞춘다. RPG 접속이 TD의 보상 정책 이관을 새로 주도해서는 안 된다.
- timedBoostMigration이 기존 doubleGold/doubleSpeed 권리 각각을 시간권10개 보상으로 옮기고 해당 필드를 비운다. 현재 TD 정책/확인된 이관 이력을 보존하되 RPG가 재보상/재이관을 만들지 않도록 한다.
- TD 지갑에는 부활권·무료 소환·시간 부스트·pass·로그인/맵클리어 feature가 함께 있다. 공통 Diamonds와 명시된 공통 권리만 RPG 어댑터로 노출하고 TD 전용 효과·RPG 캐릭터/장비/Coins는 분리한다.
- claim namespace가 `login:`, `quest:`, `bp:`, `code:`, `mail:`, `return:`, `mapclear:`다. RPG 전용 보상을 같은 키 의미로 재사용하지 않는다. 공동 이벤트는 양 게임이 같은 공통 수령ID·기간·조건을 합의하고, 전용 보상과 구분한다.
- 전체 캐시를 오래된 writer가 덮거나 다른 Place가 legacy API로 같은 scope를 쓰는지 현재 조사만으로 확정하지 못했다. 새 version 필드만 추가하면 구 writer가 자동 차단된다고 가정하지 않는다.

이 항목은 재사용/이관 설계를 위한 경계 관측이다. 후보 결함의 재현·보안 스캔·운영 장애 판정 결과는 아니다.

## 5. 안전한 후속 계약과 인계

| 다음 작업 | 담당·필요 증거 | 통과 전 제한 |
| --- | --- | --- |
| TLT-021 전수 감사 보완 | ENG·QA·DIR: 실제 Experience의 모든 Place/배포 소스 버전·저장 경로·제품ID·이관/복구 도구·구 서버 writer 목록 | 이번22파일 조사를 전체 감사 Done으로 표시하지 않음 |
| TLT-022 공통 지갑 설계 | ENG·PLAN: 기존 키/잔액/claim/receipt를 보존하는 단일 권위 커널·TD 어댑터·RPG 어댑터·walletContractVersion·허용 작업/ID | 잔액 복사/합산·RPG 캐릭터별 Diamonds 사본·구/신 지갑 이중 쓰기 금지 |
| TLT-049 상품/지급 | ENG·QA: 모든 관련 Place의 단일 영수증 라우터와 기존 상품 보존, RPG pending grant의 지속 권리·고정 instanceId·같은 PurchaseId 재처리 | 구매 UI 종료·메모리 큐만으로 지급 완료 금지 |
| RPG 다중 키 거래 | ENG·QA: 지갑 차감/outbox→대상 권리1회 적용→원천 확인, 모든 중간 지점 종료/불명 응답/경합 후 복구 | 한 키 UpdateAsync를 지갑+캐릭터+창고 전체 원자적 거래로 확대하지 않음 |
| TLT-023/024 호환 도입 | ENG·QA: TD 시작/전투/기타 Place 호환 버전·구 writer 정리·기능 차단/복구·게시된 테스트 클라이언트 왕복 | 운영 공통 소비/지급·RPG 포탈 활성은 미실행으로 유지 |
| 회귀/불변식 수용 | QA: 잔액100에서 TD/RPG 각80 동시 소비→한 성공/20, 같은 영수증/claim1회, 차감-지급 중단·TD 기존 성장/권리 보존 | 정적 소스 관측이나 Studio만으로 통과 금지 |

설계 상세는 [기술 제작 계획](../../production/engineering-plan.md), [Experience 계약](../../experience-integration.md), 실행 상태는 [백로그](../../../backlog.md)를 따른다. 다음 담당은 ENG이며 QA가 현재 로컬 파일과 실제 배포/계정 fixture를 구분해 독립 확인한다. 통합 담당자가 이 문서와 나머지 작업을 검토해 커밋·푸시한다.

## 6. 재현 방법·미검증 범위

실행한 작업은 `rg` 소스 검색, 관련 파일 읽기, `git rev-parse HEAD`·선별 `git status`, Python hashlib의 SHA-256 계산이다. Lua/Studio 실행·DataStore 호출·구매/영수증·동시성/장애 주입·Teleport·라이브/테스트 환경 배포를 수행하지 않았다. 소스 정의/주석과 실제 게시/실행 결과는 별개다.

대표 재현 검색:

```text
rg -n --glob '*.lua' 'ProcessReceipt\s*=|DiamondWallet|GetDataStore|SetAsync|UpdateAsync' src/Server
rg -n --glob '*.lua' '"diamonds"|ThroneDefense_diamonds|\.balance\s*[+\-]?=' src
rg -n 'DIAMOND_|REWARD_POLICY_VERSION|PREMIUM_PRODUCT_ID|LUCK_POTION|PLACE_ID' src/Shared/Config.lua
```

| 미확인 | 왜 남는가 / 다음 확인 |
| --- | --- |
| 모든 Place·구버전·실행 서버 | 로컬 default.project.json은 src/Server 참조만 확인. 각 게시본·서버 교체 증거는 없음 |
| 실제 Experience/Place 연결 | Config의 Lobby/Battle ID는 로컬 설정. RPG 목적지·같은 Experience 소속·운영 적용 미확인 |
| 실제 잔액·이관·구매권/환불·RPG 상품 | 라이브 값을 조회하지 않았고 상품ID/판매 상태·기존 구매자의 권리를 확인하지 않음 |
| 모든 writer/외부 도구 | 검색 범위 밖의 다른 저장소·운영 복구/배치 도구·Place 전용 스크립트는 미확인 |
| 데이터/원장 크기·보존/성능 | claims/receipts/pending 증가·동시 경합/쿼터·장기 기록의 실제 측정 없음 |
| 동일ID·불명 응답·구 서버·다중 키 복구 | 코드상 의도만 관측. 테스트 fixture와 실제 환경의 중단/재시도 검증 필요 |

## 7. 읽은 파일 스냅샷

아래 지문은 관측일의 실제 로컬 바이트다. 추후 TD 변경 시 다시 대조하며 해시 일치만으로 소유권·안전·배포·실행 수용을 보장하지 않는다.

| TD 상대경로 | SHA-256 |
| --- | --- |
| [default.project.json](../../../../throne-defense/default.project.json) | `6bf773a8306b10cfaeddba5f5f826665b7b8a9d6177dff1fe021174c35a28f47` |
| [src/Shared/Config.lua](../../../../throne-defense/src/Shared/Config.lua) | `139287b9f57cc6aeb1cb2ba9ff5b57e1fd3690cba8d0a50fc276fe117181b8d0` |
| [src/Server/Persistence.lua](../../../../throne-defense/src/Server/Persistence.lua) | `7313974bcc06197e7163ce779c87e748f1db897e03b59d8a6a02a8b69b5e75cc` |
| [src/Server/DiamondWallet.lua](../../../../throne-defense/src/Server/DiamondWallet.lua) | `e22546aba78e063a0c69b31afce6f9257d4e5d91194d61c3b2f3f583f9ba3a07` |
| [src/Server/ReceiptDispatcher.lua](../../../../throne-defense/src/Server/ReceiptDispatcher.lua) | `421fa1f8283ba2dfd9d266660a74f7470e35689df9e639130bbc9ca05e75a93f` |
| [src/Server/LuckPotion.lua](../../../../throne-defense/src/Server/LuckPotion.lua) | `78e7fe2e4eef02936257c7e730d5ecad98e59e0b32650e87fbe8169ca500c385` |
| [src/Server/ServerMain.server.lua](../../../../throne-defense/src/Server/ServerMain.server.lua) | `9b2cbb722551388c3142a1bca7f6c05208405d104cbbd65ba100c2fc09ace34d` |
| [src/Server/GameManager.lua](../../../../throne-defense/src/Server/GameManager.lua) | `358a0d7a8b823043bd952d71d7478ccc9738aa1608cb8cd02e181e4f18bac79f` |
| [src/Server/MapClearRewards.lua](../../../../throne-defense/src/Server/MapClearRewards.lua) | `fd82b0c76f7e3ee58936c1ef93020ba105fed06fb8f5748a64b66caf31d5c16f` |
| [src/Server/LoginCalendar.lua](../../../../throne-defense/src/Server/LoginCalendar.lua) | `50f88a5bb412f5f92969d658f15152f56e6d1261cab43a7844db034aae370c4e` |
| [src/Server/DailyQuest.lua](../../../../throne-defense/src/Server/DailyQuest.lua) | `25da789dcd4d684a8dcc301b3af7c84e2de31c1cbd91d00e7ae38265fcd2edc4` |
| [src/Server/RedeemCode.lua](../../../../throne-defense/src/Server/RedeemCode.lua) | `787ece6c8182144d26430c494ae17e5d7711fc91a51bb15d92f6b1325ceef7f0` |
| [src/Server/Mailbox.lua](../../../../throne-defense/src/Server/Mailbox.lua) | `27225bdc536150ec9748d5726b2794305dc00c3706719c3a1e183d40decb6ea5` |
| [src/Server/ReturnMissions.lua](../../../../throne-defense/src/Server/ReturnMissions.lua) | `ff86c5f52f3a31365389713e438f184c593960c5903193c1cf9e3c6fcb4c0986` |
| [src/Server/BattlePass.lua](../../../../throne-defense/src/Server/BattlePass.lua) | `af09e73ee9e02c9c8a9e6f6ffa92ee3b74965550c4a6b46b477da190691a613b` |
| [src/Server/ContinueInventory.lua](../../../../throne-defense/src/Server/ContinueInventory.lua) | `4bf3ea31b1c15c2092a5aebac53c6e607f7c6f81cf170c035de37ad5cc7a2eb8` |
| [src/Server/NetServer.lua](../../../../throne-defense/src/Server/NetServer.lua) | `196d0522805ef6c6f7eb89de7c4ac19339945307128c98d5ed2c54384637bf73` |
| [src/Server/WeeklyLeaderboard.lua](../../../../throne-defense/src/Server/WeeklyLeaderboard.lua) | `9aa2c6eea61859c6b590a53dd3e8592675be40d7e2ce87154dbac72fb7b1fa45` |
| [src/Server/GamepassSystem.lua](../../../../throne-defense/src/Server/GamepassSystem.lua) | `a2897e4c1f4a853166c001d807f99e160dc8bd9b16c2c35011239ad57532ed84` |
| [src/Server/SupporterPass.lua](../../../../throne-defense/src/Server/SupporterPass.lua) | `5dababecfe951014b92a945ee84fbc5e6c921d7e97cc96a026163fb9afab3f10` |
| [src/Server/AfkGold.lua](../../../../throne-defense/src/Server/AfkGold.lua) | `3f005ada19b56b50563d32c2834ed2f0c1dc456f92af9af302d8c73ab3d3febd` |
| [src/Server/MatchCoordinator.lua](../../../../throne-defense/src/Server/MatchCoordinator.lua) | `82ea0c9848974ff22e3101dc45f82ff4ffc3025bd32ae84c4c36bd5cce511758` |

## 8. 작업 보고

- 작업: TLT-021 부분 조사 / director / 로컬 소스 감사 문서 작성.
- 변경: `docs/evidence/k0/td-wallet-audit.md` 한 파일. 문서 언어 한국어, 게임용 새 문자열/코드는 작성하지 않음.
- 검증: 최종 문서 상대링크25개 모두 존재, SHA22행을 현행 원본과 재대조해 불일치0, 코드 펜스2개로 짝 일치. 호출/설정 구간은 정적 대조이며 상세 실행 검증은 위 미검증으로 유지.
- 다음 담당: ENG의 전수 writer/배포/상품 감사와 공통 계약 초안, QA의 독립 fixture/TD 회귀 계획. 커밋·푸시는 통합 담당자가 수행.
