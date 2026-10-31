# TLT 로비 재화 표시 · 0.42.1

사용자 요청: 로비에서도 Gold/Diamonds 표시. 기존 LobbyCommerce 지갑은 상점·파티 Remote 대기 뒤 생성되고 DisplayOrder48로 가방60 아래에 있었다. 명확한 표시/초기화 결함 수정으로 별도 외부 조사는 생략한다.

로비 지갑을 독립 ScreenGui70으로 분리한다. 상점 초기화 전에 생성하고 로비 로딩/복귀에도 유지한다. InventoryState 구독 후 서버 GetState를 요청하며 미로드 잔액은 —, 실제 0은 0으로 표시한다. 전투/트레이닝에는 기존 전투 지갑을 사용한다. 공유 표시 크기208×56/최대17pt를 유지한다. TD 지갑·저장·상품은 변경하지 않는다.

검증 범위: 실제 Roblox GUI 생성자, 계정 잔액 렌더링, 로비/전투 전환 및 중첩 순서. 실제 기기 픽셀/게시 클라이언트/라이브 계정은 미검증. 로컬 빌드이며 Roblox 게시와 릴리스 태그는 포함하지 않는다. 다음 담당: 실제 클라이언트 수용 QA.

검증 결과: 고정 소스 `8dfe627`에서 Lobby/Battle0.42.1 빌드 성공. 두 산출물의 LobbyWallet/LobbyCommerce를 Git 소스와 대조했다. `run-in-roblox --place builds/0.42.1/TheLastThrone-Lobby-0.42.1.rbxlx --script tests/lobby-wallet-native.luau`:16개 통과. 미로드/실제0/양수 재화, 초기/로딩/복귀, 전투·트레이닝 숨김, 창 순서·공유 글자크기 확인. 기존203785492 자산 유형 경고는 보존했다. [빌드와 해시](build.json) · [로그](native.log) · [소스 대조](source-verification.json).
