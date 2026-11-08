# 베테랑 무기 공격력 보너스 조정

2026-11-07 · TLT-027/029/041/052/084 · ENG → QA · 부모 티켓 In Progress.

사용자 지시로 `src/shared/ItemCatalog.luau`의 네 클래스 Veteran’s 무기 기본 `power`를18에서4로 변경했다. 무강화 공격력 보너스는4%이며 강화는 기존 비율로 별도 적용한다. 기존 보유품도 `InventoryRules.stats` → `Enhancement.stats`에서 현재 정의로 재계산한다. 안정ID·소유권·강화단계·Lv5 자격·Gold/Diamonds 가격·무료 Tempered 무기3%는 유지한다. 저장 이관이나 live DataStore 쓰기는 없다.

검증:

- `lua tests/starter-gear-balance.spec.lua`:198 PASS.
- `lua tests/economy.spec.lua`:42 PASS.
- `lua tests/inventory.spec.lua`:271 PASS.
- `lua tests/difficulty-enhancement.spec.lua`:151 PASS.
- Lua 직접 확인: 네 클래스의 기존 형식 `definitionVersion=1` 장착 인스턴스를 Veteran 정의로 계산하고 복사/복원했다. 무기4%+장갑1%+반지1%=6%가 장착/복원 모두 일치했다.
- `git diff --check`:통과.

소스 조정·미빌드·Studio 미적용·미게시이며 VERSION은 변경하지 않았다. 실행 중인 구버전 서버와 실제 계정/기기에서의 반영은 미검증이다. QA는 새 빌드 적용 후 기존 보유/강화 무기의 표시와 전투 피해를 확인한다. 다른 작업의 미커밋 월드/자산 변경은 포함하지 않는다.
