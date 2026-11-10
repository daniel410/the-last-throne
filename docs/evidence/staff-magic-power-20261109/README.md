# 지팡이 마법 공격력 표시

2026-11-09 · TLT-029/041/052/057/084 · ENG → QA · 0.95.2

사용자 요청으로 가방의 지팡이 공격력 비교를 Magic Power로 표시하고, 일반 공격과 공격 마법 모두에 교체/강화 수치가 적용됨을 안내한다. 상점 지팡이에도 같은 표시/설명을 적용한다. 영웅 스탯의 장비 공격 보너스를 physical / magic power로 명확히 표시한다. 추가 설명에 맞춰 지팡이 상점 카드와 모바일 스탯 안내 높이를 계산한다. TD 프레임/아이콘/버튼 원본은 유지한다.

기존 서버 계산은 이미 마법 공격력에 장비 power를 더한다. INT 1당 마법 공격력2/MP3, STR 1당 물리 공격력2, 레벨당 공격력3과 기존 스킬 계수/강화/가격/보유품/저장은 변경하지 않았다. 프로젝트 제작 스킬 적용. 기존 계약을 설명하는 표시 결함 수정으로 별도 게임성 리서치/수치 변경은 하지 않았다.

검증: `lua tests/equipment-flat-power.spec.lua` 110, `lua tests/skill-stat-preview.spec.lua` 1392, `lua tests/equipment-families.spec.lua` 458, `lua tests/copper-dexterity.spec.lua` 130: 총2090검사 PASS. `git diff --check` PASS. `tests/stat-investment-preview.spec.lua`는 기존 곱셈 장비공격 기대177.41과 현재 고정합산170이 달라 실패한다. HEAD의 src/shared와 해당 테스트만 임시 archive한 기준에서도 같은 실패를 재현했다. 이번 표시 수정과 무관한 기존 테스트 기대 불일치이며 수정 범위에 포함하지 않았다.

다른 미커밋 자산 수정/삭제/생성은 보존하고 커밋에서 제외한다. 실제 계정/게시 클라이언트·PC/모바일 시각 수용은 미검증이다. QA는 지팡이 교체/강화 전후 Magic Power·스킬 피해 증가와 설명 줄바꿈을 확인한다. Roblox 게시/릴리스 태그 없음.
