# 리셋권 언제든 사용 · 0.82.1

2026-11-07 · TLT-041/043/047/052/057/084 · ENG/QA · 로컬 수정·Studio 적용·미게시.

사용자가 로비 전용 사용을 취소하고 언제든 사용하도록 지시했다. 기존0.82.0의 상품 사양/조사는 유지하며 명시된 위치·전투 제한만 제거한다. 별도 게임성 조사 없이 사용자 지시를 적용한다.

## 변경

- 서버 `InventoryRules`에서 ResetPoints를 안전 상태 제한의 예외로 추가하고 atHub 검사를 제거한다. 소유권·영웅·아이템 버전·계정revision·데이터 유효성·미투자 미소비·한 거래의 권 소비/포인트 반환·영수증 재시도는 유지한다.
- 가방 사용 버튼은 safe/atHub 대신 계정 준비·대상 영웅·남은 투자·저장 대기 여부로 활성화한다. 전투 중에도2단계 확인하며 닫기/아이템 변경으로 취소한다.
- 상품/가방 영어 안내를 anytime, including combat으로 맞춘다. 각50다이아·구매 위치·공유 창고·투자 반환 범위·전직/해금/편성 보존은 변경하지 않는다. HP/MP/쿨다운 회복을 제공하지 않는다. 새 상품이나 데이터 스키마 변경 없음.

## 검증

- `lua tests/reset-tickets.spec.lua`: **316 PASS**. 네 클래스/두 권의 로비 밖 안전/전투 사용·정확한 반환/한 장 소비·미투자 거부·소유/버전/동시요청·저장 응답 유실/재접속 영수증 복구. 기존 로비 허용 여부와 별도로 unsafe/atHub=false를 명시해 검사한다.
- `lua tests/inventory.spec.lua`: **271 PASS**. 일반 장비/이동 제한 회귀.
- `lua tests/economy.spec.lua`: **42 PASS**. 가격/구매/재화 회귀.
- `lua tests/hero-progression.spec.lua`: **3711 PASS**. 성장 예산 회귀.
- 임시 Rojo Place의 `tests/reset-tickets-native.luau`: **38 PASS / 종료0**. 실제 Luau/TD GUI fixture에서 unsafe·atHub=false 사용 버튼 활성·두 번 확인 후 명령 제출·서버 소비/반환·상품의 combat 안내를 확인한다. [native-preview.log](native-preview.log). 기존203785492 자산 타입 경고는 검사 실패와 구분한다.
- 현재 TLT Studio70829337938054 Edit의4개 소스를 문맥 일치/문법 검사 후 반영. 기존 Studio 전용 변경 보존, 백업 `ServerStorage.TLTBeforeResetAnywhere20261107`.
- `git diff --check`: PASS.

## 인계·한계

실제 플레이어 원격/전투 중 화면 조작·피격 타이밍·DataStore·실계정/기기/다인은 미검증이다. native 검사는 private fixture이며 실제 플레이로 보고하지 않는다. QA는 전투 중 두 권의 사용과 현재 HP/MP·쿨다운 보존, 재접속을 확인한다. 기존 새 포인트 배분/장착 변경의 별도 안전 규칙은 이번 리셋권 사용 변경과 구분한다. 부모 티켓 In Progress 유지. 미게시·릴리스 태그 없음.

구현 소스 커밋 후 `python3 tools/build-game.py --source HEAD --record docs/evidence/reset-anywhere-20261107/build.json`으로 고정하고 동일 native를 재실행한다.
