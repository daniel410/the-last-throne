# 장신구 자동 슬롯 장착

2026-11-05 · TLT-028/043/052/084 · ENG/DES → QA · 로컬 구현·미게시.

가방 Accessory1/2 선택 버튼을 제거해 EQUIP 한 번으로 장착한다. 동일 고유그룹 교체→빈1/2슬롯→둘 다 찼으면1번 순서다. 교체품 이름/가방 복귀 안내·실제 능력치를 표시한다. 가방/상점 미리보기와 서버가 `EquipmentSlotRules`를 공유한다. 이전 명시적 유효1/2요청은 호환 유지하며 새 UI는 slot을 지정하지 않는다.

8슬롯·소유권·클래스/레벨·안전 상태·고유그룹·용량·버전·저장 멱등성을 유지한다. 같은 요청 재시도에서 다시 슬롯을 골라 교체하지 않는다. TD 원본 프레임·버튼·아이콘·기본 배치는 유지하고 사용자 Blender/첨부/별도 증거는 제외했다. [조사·판단](../../research/2026-11-05-accessory-auto-equip.md)과 상세 사양·결정표·AGENTS를 갱신했다.

검증:

- `lua tests/accessory-auto-equip.spec.lua`:77 PASS. 빈 두 칸/한 칸·고유그룹2번 우선·둘 다 참/첫 칸 교체·가방 가득찬 교체/보존·미리보기와 실제 장착 후 능력치 일치·멱등 재요청·오래된revision/전투 차단·영웅별 격리.
- `lua tests/inventory.spec.lua`:271 PASS. 소유/용량/스택/귀속·구 요청 호환/고유그룹·저장 복구.
- `lua tests/equipment-impact.spec.lua`:44 PASS.
- `lua tests/economy.spec.lua`:42 PASS.
- `lua tests/enhancement-probability.spec.lua`:2,857 PASS, 내부90,000확률 경계 포함.
- `lua tests/retired-forge-equipment.spec.lua`:486 PASS.
- `/private/tmp/td233-luau/luau-compile`로 변경6개 Luau 파일 컴파일 PASS.
- `git diff --check`: PASS.

합계3,777개 순수 Lua 검사다. Studio 연결은 TD Place만 있어 수정/실행하지 않았다. 실제 UI 렌더/클라이언트 입력·저장/재접속·PC/모바일/패드·사용자 시각 수용은 미검증이다. 빌드·Roblox 게시·릴리스 태그 없음, VERSION 유지. 다음 QA는 RPG 격리 빌드에서1/2선택 부재·장착 활성·교체 대상/수치·서버 응답과 가방 보존을 확인한다. 부모 티켓 In Progress 유지.
