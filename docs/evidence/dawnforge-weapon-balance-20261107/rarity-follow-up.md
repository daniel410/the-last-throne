# Dawnforge Rare5%·Epic6% 후속

2026-11-07 · TLT-027/029/041/052/084 · ENG → QA · 부모 티켓 In Progress.

사용자 지정으로 Dawnforge 네 클래스 Rare4종의 기본 공격력 보너스는5%, Epic4종은6%로 변경했다. 직전 양쪽4%보다 우선한다. 기존 보유품도 새 소스 적용 후 현재 정의로 재계산한다. 강화단계/비율·안정ID·Lv10 자격·소유권·퇴역/신규 획득 차단은 유지한다. Veteran 무기는4%를 유지한다. live DataStore 쓰기는 없다.

검증:

- `lua tests/retired-forge-equipment.spec.lua`:486 PASS.
- `lua tests/difficulty-enhancement.spec.lua`:153 PASS.
- `lua tests/economy.spec.lua`:42 PASS.
- `lua tests/starter-gear-balance.spec.lua`:194 PASS.
- Lua 직접 확인:8종의 기본5%/6%·퇴역/상자 차단 상태, 기존 버전 인스턴스 장착 및 복사/복원 후 서버 합산 일치. 강화+3 무기만의 보너스는 Rare5.45%·Epic6.54%다.
- `git diff --check`:통과.

소스 반영·미빌드·Studio 미적용·미게시. VERSION 변경 없음. 실제 계정/게시 클라이언트·실기기는 QA 후속이다. 다른 진행 중인 로비/자산 변경은 포함하지 않는다.
