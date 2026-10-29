# HP·스태미나 회복 조정 — 2026-10-28

- 작업 TLT-005/008: HP는 최대치의 초당 0.2%를 전투 중에도 서버가 회복한다. 최대 HP 1000 기준 초당 2이며 최대 체력 전체에 해당하는 회복량은 500초가 걸린다. 사망 상태는 회복하지 않고 최대치를 넘지 않는다.
- 물리 스킬 Stamina는 초당 15에서 6으로 줄였다. 물리 스킬 사용 후 기존 1초 지연, 최대 100, 무료 공통 액션 및 Mage MP 회복은 유지한다. 모두 시연 밸런스 시험값이다.
- `StarterCharacterScripts.Health`의 빈 서버 스크립트는 Roblox 기본 HP 자동 회복을 대체한다. 구현 근거: [Roblox Humanoid Health Regeneration](https://create.roblox.com/docs/reference/engine/classes/Humanoid#Health).
- 격리 Studio 서버 전투 소스 픽스처 400개 검사 통과. 네 직업의 HP·사망·최대치와 세 물리 직업의 Stamina 회복량·지연·최대치를 검사했다. 실제 플레이어 생성에서 기본 회복 중복 여부와 실기기 밸런스 체감은 별도 Play 검증이 필요하다.
