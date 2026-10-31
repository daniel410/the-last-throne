# Gold / Diamonds 숫자 갱신 복구

- 작업: TLT-052/061/084 관련 사용자 결함 보고, 엔지니어 수정. 상위 티켓 수용 상태는 유지한다.
- 원인: `WalletDisplay`가 GUI Instance를 약한 키로 보관했다. Roblox에 부모가 있는 GUI도 Luau 래퍼가 수거되면 갱신 목록에서 빠질 수 있어 서버 잔액이 도착해도 초기 `—`에 머물렀다.
- 변경: 화면을 강한 참조로 등록하고 `Destroying`에서 해제한다. 로비와 전투 미니맵이 같은 수정 경로를 사용한다. 저장/잔액/상품 계약은 변경하지 않는다.
- 재현: 기존 0.47.0 로컬 Battle Studio Client에서 로비/전투 지갑 네 라벨 모두 `Gold  —` / `Diamonds  —`였다. `InventoryRequest` GetState를 요청하면 서버 응답은 `ready=true`, Gold=0, Diamonds=0인데 라벨은 갱신되지 않았다.
- 수정 검증: 같은 로컬 Place의 WalletDisplay만 변경하고 새 플레이 세션을 시작했다. 네 라벨 모두 `Gold  0` / `Diamonds  0`으로 갱신됐고, 이후 GetState 재요청에서도 유지됐다. Battle Place를 직접 실행한 영웅 미선택 Lobby 상태이므로 두 ScreenGui의 표시 여부와 정상 모험 진입 수용은 별도다.
- 네이티브 GUI 검사: `python3 tests/make_k0_source_probe.py --output-dir /tmp/tlt-wallet-retention --test-script tests/lobby-wallet-native.luau`로 격리 Place를 생성했다. 전체 소스 주입은 기존 별도 모듈의 Source 367,658자가 엔진 한도 200,000자를 초과해 실패했다. 같은 격리 Place에 WalletDisplay/LobbyWallet/TDInventoryTheme/LobbyText와 TDUI 두 정의만 주입한 `/tmp/tlt-wallet-retention/wallet-probe.luau`로 기존 `tests/lobby-wallet-native.luau`를 실행했다.
- 명령: `run-in-roblox --place /tmp/tlt-wallet-retention/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-wallet-retention/wallet-probe.luau`. 결과: 16개 통과, 실패 0. 미로드/실제 0/양수 잔액, 로비·전투 전환 및 표시 계약 확인. 기존 자산203785492 유형 경고는 남아 있다.
- 미검증: 게시된 클라이언트, 실기기, 장시간 메모리 부하. 게임 빌드·Roblox 게시·릴리스 태그는 수행하지 않았다. 현재 Studio의 로컬 WalletDisplay에도 수정 소스를 적용했다.
- 다음 담당: QA/사용자가 정상 로비 및 모험 화면에서 장시간 잔액 갱신과 시각 수용을 확인한다.
