# 두 발 몬스터 사망 반응 조사

2026-10-31 확인 · TLT-005/031/032/033/050/057/084 · 리서치/ENG/QA

기존 [몬스터 동작 조사](2026-10-31-deepwood-monster-motion.md)의 전투 반응 가독성 사례를 재확인했다. [God of War 전투 개발자 분석](https://blog.playstation.com/2022/10/04/game-developers-explain-what-makes-god-of-war-2018s-combat-tick/)은 적의 뚜렷한 자세 반응이 타격 피드백과 다수 대상 추적에 기여한다고 설명한다. 구체적인 사망 동작이나 지속 시간을 직접 검증한 사례는 아니다. [Roblox Humanoid 문서](https://create.roblox.com/docs/reference/engine/classes/Humanoid#BreakJointsOnDeath)는 사망 시 관절 분리가 기본 동작임을 명시한다. TD 원본 모델의 R6 파츠 구성은 `TdMonsterAppearance`와 기존 조사에서 확인했으며 완전한 스키닝 리그로 간주하지 않는다.

사용자 지정에 따라 두 발 적만 앞으로 쓰러지고 1초 이상 누운 뒤 사라지게 한다. 관절을 유지하고 충돌을 끄며 서버가 사망·보상을 즉시 확정한다. 로컬 리그의 분리 메시와 단일 메시 보스는 같은 전체 몸체 회전을 사용한다. 늑대·곰·슬라임·벌레는 제외한다. 시험 비용은 관절 유지·바닥 높이·시체 표현이며 경사지·대형 메시·다인/모바일 성능과 미술 수용은 실제 플레이에서 확인한다. 다음 담당은 전투 애니메이션/QA다.
