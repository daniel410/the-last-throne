# 기존 아이템 등급 상세 표시 수정

2026-11-04 · TLT-028/029/043/052/084 · 0.69.3 · ENG/DES → QA

기존51품목의Common/Uncommon/Rare 분류를 보존하고 기본 장비Common을명시했다. ItemRarity 공유 표시 정의와 InventoryText의영어 키를추가해 일반/창고 상세에서 등급명을 항상 표시한다. 일반 상세의DETAILS 전용 등급행을 대체하며 TD 원본 프레임/아이콘/버튼은 유지한다. [51품목 분류표](../../production/existing-item-rarity-2026-11-04.md).

검증:

- Git HEAD의기존 ItemCatalog와 수정본을Lua에서모든 필드 재귀비교: 완전동일 PASS. 기존33장비·전체51아이템ID/이름/수치/희귀도/제약 보존.
- 51개 등급 참조와6개 표시 키·Unknown fallback 검사 PASS.
- `/private/tmp/td233-luau/luau-compile`로 InventoryGui/ItemCatalog/ItemRarity/InventoryText 네 파일 컴파일 PASS. 첫 일반Lua 구문 검사 시 기존Luau `+=` 구문에서 실패하여 실제Luau 컴파일러로 확인했다.
- `lua tests/inventory.spec.lua` 271검사, `lua tests/equipment-impact.spec.lua` 44검사, `lua tests/enhancement-probability.spec.lua` 2,857검사(90,000경계 포함), `lua tests/item-shop-categories.spec.lua` PASS.
- 작업 범위 staged diff 공백/충돌 검사. 고정 소스 `585eaafbda4a496ff65320164753cd41ebd909ee`의0.69.3 Lobby/Battle 빌드 모두 성공. 명령·LFS 확인·경로·SHA256은 [build.json](build.json), 재현 도구는 [build.mjs](build.mjs)에 기록했다. 다른 미커밋 코드는 빌드에서 제외했다.

Studio 연결 목록이 비어 있어 실제GUI 렌더/화면 치수·터치/패드·게시 저장/이동 검증은 미실행이다. 구현/정적 검사와 미술 수용을 구분한다. Studio 세션을 열거나 종료하지 않았다. 실제Roblox 게시/릴리스 태그 없음. 신규120장비등록·세트/MP/보스드롭은 이번 범위가 아니다. 다음 담당 QA/DES.
