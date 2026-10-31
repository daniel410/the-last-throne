# 상점 연속 구매 복구 · 0.55.3

- 작업: 짧은 간격에 도착한 거래 요청을 서버가 응답 없이 버릴 수 있는 문제를 수정했다. 서버가 요청 ID를 포함한 Busy를 반환하고 클라이언트는 처리 중 거래의 동일 ID를 재시도한다. 저장 중 다른 거래는 막고 완료 후 다시 구매할 수 있다.
- 검증: `lua tests/starter-potions-and-shop.spec.lua` 172개 검사 통과(동일 포션 연속 구매, 금액 차감, 요청 재생 시 중복 방지 포함). 격리 Studio Edit의 `shop-affordability-native.luau` 14개 및 `potion-request-recovery-native.luau` 12개 검사 통과.
- 미검증: 실제 게시 클라이언트의 네트워크 지연·패킷 유실과 DataStore 운영 환경. 다음 담당: UI/네트워크 QA.
- 추가 회귀: `lua tests/economy.spec.lua` 42개 통과. `lua tests/store-split.spec.lua`는 기존 `blacksmith rejects shield` 기대가 현재 방어구 판매 요구와 충돌해 실패했으며 이번 변경과 무관한 기존 테스트로 남긴다.
