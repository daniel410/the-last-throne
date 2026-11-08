# 초기화권 각100 Diamonds · 0.82.3

2026-11-07 · TLT-041/043/047/052/057/084 · ENG/QA → QA · 사용자 확정 구현·Studio 적용·미게시.

사용자 지시로 스탯·스킬 초기화권 각각50→100 RPG Diamonds로 변경했다. 기존 초기화권 상품/사용 설계를 재사용하고 지정된 가격만 조정하므로 별도 게임성 조사는 수행하지 않았다.

- `EconomyCatalog`의 두 상품 가격과 `assets/economy/item-catalog-v1.json` 가격을100으로 일치시켰다. 상점 표시·구매 가능 상태와 서버 차감은 동일 카탈로그를 사용한다.
- 안정 상품ID·보유권·잔액·기존 영수증·언제든 사용·2단계 확인·투자0 미소비·반환 포인트 규칙을 보존한다. 영수증 재시도는 가격 검사 전 기존 결과를 복구하며 소급 추가 차감하지 않는다.
- 최신 결정을 상품 사양·결정표·README/plan/backlog에 연결했다. 과거50다이아 기록은 당시 증거로 보존한다. 부모 티켓은 In Progress다.

## 검증

- `lua tests/reset-tickets.spec.lua`:316 PASS. 네 클래스/두 권의100차감·99잔액 구매거부·구매/사용 재시도·저장 응답유실/재접속·전투 중 포인트 반환.
- `lua tests/economy.spec.lua`:42 PASS.
- `lua tests/inventory.spec.lua`:271 PASS.
- TLT Studio70829337938054 Edit에서 이전 소스를 확인한 뒤 가격 한 곳을 수정하고 문법 검사를 통과했다. 백업 `ServerStorage.TLTBeforeResetPrice10020261107`. 별도0.79.7 Studio는 변경하지 않았다.
- `git diff --check`:PASS. 신규 LFS 자산 없음. 실제 Roblox 게시·릴리스 태그 없음.

고정 소스/빌드/엔진 결과는 아래 마감 기록에 추가한다. 실제 계정·DataStore·기기/사용자 수용은 미검증이며 QA 후속이다.
