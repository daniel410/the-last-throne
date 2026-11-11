# 로비 장비 착용 즉시 반영 수정

2026-11-11 · TLT-043 · 소프트웨어 엔지니어 · 소스 수정/로컬 회귀 통과, 엔진·게시 수용 대기.

## 원인·변경

구매품을 가방에서 `Equip`하면 서버 프로필은 새 장비로 확정되지만 `InventoryService`는 전투 상태만 갱신했다. 로비에는 전투 상태가 없으므로 `CombatService.refreshEquipment`가 반환하고, 로비 외형 속성은 `HeroSessionService.changed`가 다시 호출될 때까지 이전 장비였다. 스크린샷의 Mage 로비에서 새 장비 착용 후 이전 외형이 남는 증상에 대응한다.

`InventoryService`의 저장 성공 분기에서 `Equip`/`Unequip`도 기존 `heroSession.refresh`를 호출한다. 확정 프로필을 대입한 뒤 기존 로비 외형 경로가 무기·방패·머리·상의·장갑·신발 속성을 다시 발행하며, 기존 외형 모듈의 속성 변경 구독을 사용한다. 실패/불명 저장 분기에서는 외형을 갱신하지 않는다. 구매만으로 자동 착용하지 않으며, 소유권·가격·장착 자격·저장 규칙은 유지한다.

## 검증

- `lua tests/equipment-lobby-refresh.spec.lua`: **35검사 통과**. 실제 인벤토리 요청 처리·장비 reducer·로비 속성 발행 함수 본문을 실행한다. 전투 갱신이 아무 일도 하지 않는 로비를 재현하고, Mage 무기/모자/로브/장갑/신발 구매→장착→해제→재장착, 중복 요청, 구버전 거부, 저장 실패 시 기존 외형 유지를 검사한다. 저장 adapter·캐릭터·이벤트는 테스트 대역이다.
- 수정 전 `HEAD`의 `InventoryService`를 `/tmp/tlt-inventory-before-equip.luau`에 추출해 `lua tests/equipment-lobby-refresh.spec.lua /tmp/tlt-inventory-before-equip.luau` 실행: 첫 `mage_weapon_fine` 장착 직후 외형 검사가 **예상대로 실패**했다.
- `lua tests/inventory.spec.lua`: **274검사 통과**.
- `lua tests/k0-hero-session.spec.lua`: **141검사 통과**.
- `lua tests/last-selected-hero.spec.lua`: **21검사 통과**.
- 연결된 Studio `TheLastThrone-0.103.5.rbxlx`의 서버 구조만 읽었다. 격리 회귀 실행은 `loadstring() is not available`로 실행하지 못했다. 이 시도를 엔진 통과로 계산하지 않는다. 열린 게임의 스크립트·플레이어·저장 데이터는 수정하지 않았다.

## 미검증·다음 담당

새 빌드·Roblox 게시·릴리스 태그 없음. Studio 실제 장착/메시 교체, 게시 클라이언트·실계정 재접속·모바일·사용자 수용은 미검증이다. 다음 담당 ENG/QA는 수정 소스를 포함한 빌드에서 로비 구매→가방 Equip/Unequip 즉시 외형 반영과 전투 진입 후 동일 장비 유지, 재접속 후 저장 상태를 확인한다. 전체 TLT-043/G3 완료를 선언하지 않는다.
