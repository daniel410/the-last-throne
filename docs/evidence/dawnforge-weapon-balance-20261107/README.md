# Dawnforge 무기8종 하향

2026-11-07 · TLT-027/029/041/052/084 · ENG → QA · 부모 티켓 In Progress.

사용자 “Dawnforge도 전부 낮춰줘”에 따라 네 클래스 Rare4종·Epic4종을 조정했다. 별도 목표 수치가 없어 직전 베테랑4%를 기준으로 적용했다. Rare 기본 공격력24%→4%, Epic 약26.0339%→4%다. Epic 생성 시 무기는 기본값을 그대로 사용한다. Sentinel·구형 장신구 수치는 이번 범위에 포함하지 않는다.

기존 정의ID/소유권/강화단계/Lv10 자격·판매 차단·상자 선택 차단·신규 지급 차단은 유지한다. 기존 보유품은 현재 정의로 계산하므로 새 소스가 적용된 서버에서 하향된다. 강화+3의 공격력 보너스는4×1.09=4.36%다. live DataStore 쓰기나 아이템 삭제는 수행하지 않는다.

검증:

- `lua tests/retired-forge-equipment.spec.lua`:486 PASS.
- `lua tests/difficulty-enhancement.spec.lua`:153 PASS.
- `lua tests/economy.spec.lua`:42 PASS.
- `lua tests/starter-gear-balance.spec.lua`:194 PASS.
- Lua 직접 확인:8종 모두 기본4%·퇴역/상자 차단 유지·기존 버전 인스턴스 강화+3에서4.36% 확인.
- `git diff --check` 통과.

소스 수정·미빌드·Studio 미적용·미게시. VERSION 변경 없음. 실제 계정/클라이언트·실기기 수용은 QA 후속이다. 동시 진행 중인 재료 정리/자산 변경은 커밋에서 제외한다.
