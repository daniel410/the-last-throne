# 대장간 Diamonds 판매 구현 검토

2026-11-05 · TLT-028/029/043/046/057/084 · RESEARCH/ENG → QA

[기존 대장간 조사](2026-10-31-blacksmith-and-td-icon.md)의 분류 및 구매/착용 자격 분리를 재사용한다. 당시 Gold 전용 판매 제안은 최신 사용자의 Rare/Epic Diamonds 전용 지시로 대체한다. 외부 게임 가격을 환산하지 않고 기존 서버 거래와 확정 품목 판매를 확장한다.

2026-11-05 [Roblox 공식 client-server boundary](https://create.roblox.com/docs/scripting/security/client-server-boundary)를 다시 확인했다. 서버가 클라이언트 데이터의 맥락/권한/값을 검증하고 상점 잔액을 확정하는 계약을 따른다. 적용은 UI/서버의 상점 허용 함수 공유, Rare/Epic Gold offer의 서버 거부, offerId별 가격/통화 고정이다. 외부 문서가 본 게임의 가격/경제/실계정 저장을 검증한 것은 아니다.

첫 구현은 기존 Rare12종의 Gold SKU 중단·Diamond12종과 그 기본품의 Epic12종 추가다. MP/세트 효과가 미구현인40계열 아트 제안을 즉시 판매하면 명세와 실제 성능이 어긋나므로 별도 작업으로 남긴다. 수용 조건은 Gold 대체 결제0, 중복 차감0, 만석/잔액 부족 차감0, 기존 품목 정의 변경0, 기존 상자 권리 보존이다. UI/기기·경제의 최종 수용은 실플레이에서 확인한다.
