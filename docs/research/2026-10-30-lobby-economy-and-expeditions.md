# TD를 참고한 재화·무기 상점·원정 서버

2026-10-30 · TLT-003/011/016/017/021/028/041/044/045/047/049/050/053/084 · PLAN/ENG/DES → QA.
사용자 지시: Diamonds/Gold 도입, 로비 무기 매입/판매, 솔로·2~4인·리조인,20명 로비·서버 간 파티 합류·배틀 서버 구현.

## 확인한 원천

TD 소스는 커밋 `22ff3be95a8e9d3c034d83d93b8c540a36070ac2`을 읽기 전용으로 확인했다. `DiamondWallet.lua`는 확정 저장/영수증과 소비 권리를 관리하고, `CurrencySystem.lua`의 전투 Gold는 별도 의미다. `GlobalPartyStore.lua`/`GlobalMatchmaking.lua`는 자리를 임시 확보해 다른 서버의 파티원을 파티장 로비로 이동시킨 뒤 원정을 출발한다. `RejoinStore.lua`는 만료·소유 토큰을 가진 복구 상태를 관리하며 재화를 복사하지 않는다. 파일을 읽은 관찰이며 TD 게시 서버의 실제 다인 동작을 이번에 검증했다는 뜻은 아니다. TD 소스·Place·잔액은 변경하지 않았다.

[Roblox Teleport 가이드](https://create.roblox.com/docs/projects/teleport)는 서버의 TeleportAsync, GUID 기반 ReservedServerId, 이동 실패 처리와 게시 클라이언트 시험을 설명한다. 이번 설치 Studio에서도 ReservedServerId 속성을 읽을 수 있음을 확인했다. [MemoryStoreHashMap](https://create.roblox.com/docs/cloud-services/memory-stores/hash-map)은 Experience 공통 임시 상태와 한 키의 UpdateAsync 동시 갱신을 지원한다. 서로 다른 키의 갱신이 하나의 거래는 아니다. [Players.MaxPlayers](https://create.roblox.com/docs/reference/engine/classes/Players#MaxPlayers)는 Place 설정이며 런타임 입장 제한과 실제 게시 설정/수용을 구분한다.

## 채택

- 계정 Gold는 종전 영웅별 Coins/처치 Coins의 합을 한 번 이전하고 이후 지급·소비를 같은 RPG 계정 키에서 처리한다. 이전 저널의 누적 획득 기록은 보존한다. TD Gold와 잔액/저장을 공유하지 않는다.
- RPG Diamonds는 기존 본편 초회 완료당2개, 같은 본편은 계정당 한 번이다. 이전 완료도 한 번 이전한다. TD Diamonds·구매권·Robux 상품을 복사하지 않는다. 초회 XP/기존 일반 재화 지급 수치는 유지한다. 가격/추가 Diamonds 수치는 시험값이다.
- 로비 Armory의 Gold/Diamonds 무기 구매와 Gold 매각은 원자적 계정 갱신이다. 같은 요청의 재전송은 같은 결과를 복구한다. 다른 클래스 무기도 구매할 수 있지만 장착 자격은 기존 서버 검사를 따른다. 장착/잠금/스타터 무기는 매각하지 않는다.
- 공개 파티 목록에서2/3/4인 목표를 고른다. 다른 로비의 참여자는 임시 자리·회원 토큰 확인 후 파티장 로비에 모인다. 모두 같은 다음 본편·준비 상태여야 출발한다. 개인 진행을 호스트 것으로 덮어쓰지 않는다.
- 솔로/파티는 원정별 ReservedServerId·참여자별 티켓을 가진 전투 Place를 사용한다. 재화·아이템은 TeleportData에 넣지 않는다. 이동 전 대기 지급과 저장을 마감하고 계정 lease를 해제한다. 실패는 같은 목적지로 제한 재시도하고 출발 계정을 재개한다.
- 리조인은15분 동안 허가된 같은 영웅/원정으로 돌아온다. 실제 남은 전투 서버가 있으면 합류하며 서버가 사라졌으면 저장된 개인 체크포인트부터 재개한다. 적 HP/전투 전체 스냅샷을 영속 복원하는 기능과 구분한다. 의도적 로비 복귀는 리조인 권한을 종료한다.
-20명 로비/4명 전투의 서버 입장 제한, 별도 Lobby/Battle 빌드와 부트스트랩을 둔다. 실제 Place 연결/최대 인원/보안 접근 설정·게시 이동은 배포 증거가 있어야 완료로 판단한다. Studio에서는 접속 세션만 저장하고 같은 프로세스에서 원정을 미리 본다.

회원 인덱스와 파티 키는 별도라 토큰으로 현재 소유를 재검사하며, 오래된 좌석이 새 파티의 출발 자격이 되지 않게 한다. 원정 한 키의 소유 lease로 두 배틀 작업의 동시 입장을 막고 lease 갱신이 불명하면 전투 입력을 잠근다. 상점의 저장 불명·중복 매각·가방 초과·음수 잔액, 자리 초과·가짜 티켓·다중 출발·호스트 이탈·늦은 서버의 리조인 덮어쓰기부터 시험한다. 실제 다인/네트워크/재접속 수용은 후속 증거로 남긴다.
