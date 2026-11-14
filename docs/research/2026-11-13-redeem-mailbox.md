# 리딤·메일 비교 조사

2026-11-13 확인 · TLT-047/049/084 · 조사 질문: TD의 코드 수령·운영 공지를 TLT에 어떻게 연결하고 중복 지급을 막을까?

- Diablo IV 출시 프로모션(2023년 역사적 사례): [공식 안내](https://news.blizzard.com/en-us/article/23954936/diablo-iv-launch-twitch-drops-earn-the-primal-instinct-mount)는 캠페인 코드 알림과 Battle.net 계정의 코드 교환을 안내한다. 계정/캠페인에 연결된 수령 UX를 참고한다. 현행 시즌 보상·기간/금액으로 일반화하지 않는다.
- World of Warcraft: [Blizzard 공식 고객지원 안내](https://us.forums.blizzard.com/en/wow/t/spotlight-on-game-master-help/1393287)는 지원 답변을 게임 내 우편으로 전달하고 메일 복구 경로를 제공하는 사례를 설명한다. 서비스별 현재 만료 일수·현행 패치 수치는 미검증이다. 계정 공지와 보상 수령을 같은 수신함에서 확인하는 원리를 참고하되 플레이어 간 송금·우편 거래는 보류한다. 지원 문서 직접 조회는 로그인 리다이렉트로 실패해 수명 정책 근거로 사용하지 않았다.
- Roblox 보완 사례: 동일 작업공간 TD `RedeemCodeUI.lua`, `MailboxUI.lua`, `UIController.lua`를 읽어 MORE 메뉴·공통 아이콘·코드 입력·메일별 수령을 확인했다. 직접 플레이 결과가 아니다. [현재 원본 해시](../evidence/redeem-mailbox-20261113/source-provenance.json)를 기록했다.
- 기술 근거: [Roblox Data stores](https://create.roblox.com/docs/cloud-services/data-stores)는 여러 서버의 동일 Experience 저장 접근과 UpdateAsync 갱신을 설명한다. TLT는 이미 존재하는 단일 계정 저장/세션 fence를 재사용한다.

적용 판단: TD와 같은 룩앤필에 TLT 전용 운영 메일·계정당1회 코드를 연결한다. TD의 별도 기록/지갑 경로를 복사하면 지급과 사용 표시가 분리될 위험이 있어, TLT의 보상·영구 수령 기록을 한 계정 갱신으로 처리한다. 보상 숫자·무료 배포는 기존 경제 결정을 바꾸지 않고 비활성 설정으로 제공한다. 사용자 간 우편은 거래·필터링·별도 복구 비용 때문에 이번 요청 범위에 넣지 않는다.

최소 실험/지표: 코드 정규화·계정당 중복 차단, 타 서버 세션, 저장 응답 유실/재접속 뒤 잔액과 아이템 증가가 정확히1회인지 검증한다. UI는 메뉴 진입·메일 본문 스크롤·중복 제출 설명·저장 대기 재시도를 QA가 실제 화면/기기에서 확인해야 한다. 이번 조사에서는 외부 게임 직접 플레이·인기도/매출 인과를 검증하지 않았다. 다음 담당은 TLT 엔지니어·UI QA다.
