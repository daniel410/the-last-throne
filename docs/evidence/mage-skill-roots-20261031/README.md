# 마법사 기본 마법 기반 기술의 피해 반영

2026-10-31 · TLT-008/015/042/052/056/084 · ENG → QA

사용자의 후속 요청에 따라 Mana Bolt·Water Ball·Gravity에 연결된 마법사 후속 공격 기술(`root` 1~3)의 피해 계수에도 기본 주문의 2배 강화를 적용한다. Lv5 Wind Lance, Lv10 Tidal Ring과 양 전직의 연결된 공격 기술에 반영된다. 무피해 Arcane Ward의 보호막, 별도 Lv80 궁극기(`root` 0), 지팡이 기본 공격과 다른 직업은 변경하지 않는다. 기존 1.4 주문 보정과 마법 공격력 계산·숙련·MP 비용을 유지하며 원본 `AdvancedSkills` 데이터를 변형하지 않는다.

Gravity 계열에 감속·범위·지속을 상속할지는 사용자 확인이 필요한 별도 효과다. 이 변경은 후속 기술의 기존 특수 효과를 그대로 유지한다. 기본 Gravity는 감속 70%·반경10·기본10초를 유지한다.

검증: `lua tests/skill-stat-preview.spec.lua` 1,298개와 `lua tests/hero-progression.spec.lua` 656개 통과. 0.58.5 Battle에 관련 변경 모듈을 주입한 격리 Studio fixture에서 `tests/k0-basic-attacks-native.luau` 1,010개 통과, 연결된 기술·궁극기별 서버 계수와 전투 회귀 확인. `tests/skill-stat-ui-native.luau` 3,000개 통과. 실제 기기·보스·다인·전직별 밸런스는 미검증이며 게시 게임에는 미반영. 다음 담당은 QA다.
