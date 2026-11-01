# Gravity 기반 후속 기술 효과 상속

- 작업 ID: Gravity 파생 기술 피해·효과 반영, 2026-11-01.
- 사용자의 확인에 따라 Mage 기본 Gravity에 연결된 후속 공격 기술에 기존 피해 2배와 함께 이동속도 70% 감소를 적용한다. 기본 지속시간은 10초이며 숙련 등급마다 0.2초 증가한다. 여러 번 적중하면 마지막 적중부터 지속시간을 갱신한다.
- 대상 기술의 범위는 최소 10스터드로 확장하고 원래 더 넓은 범위와 대상 수는 유지한다. 기본 Gravity처럼 보스에도 감속을 적용한다. 감속은 기절이나 공격 중단이 아니다. 무피해 Arcane Ward와 별도 궁극기는 제외한다. 기존 Mage/Elf MP 회복과 다른 계열 효과는 변경하지 않는다.
- 적용 근거: 기존 [마법사·엘프 밸런스 조사](../../research/2026-10-31-mage-elf-balance.md)와 사용자 확정 수치를 따른다. Roblox의 [핵심 게임 루프](https://create.roblox.com/docs/production/game-design/core-loops)와 [서버 방어 설계](https://create.roblox.com/docs/scripting/security/defensive-design)를 참고하여 서버에서 효과를 확정하고 스킬 미리보기에도 표시한다.
- 검증: `lua tests/skill-stat-preview.spec.lua` 1,368건, `lua tests/hero-progression.spec.lua` 656건 통과. 기존 배틀 테스트 장소에 수정 모듈을 주입한 임시 격리 시험 장소에서 `run-in-roblox --place /tmp/tlt-gravity-inherited-probe.rbxlx --script tests/k0-basic-attacks-native.luau` 1,039건 및 같은 장소의 `tests/skill-stat-ui-native.luau` 3,000건 통과. 파생 기술별 감속과 지속, 범위 경계, 보스 및 회복을 포함한다.
- 한계 및 다음 담당: 실제 게시 클라이언트·모바일 기기와 전투 밸런스는 검증하지 않았다. 별도 빌드나 Roblox 게시를 하지 않았다. QA에서 실제 플레이와 밸런스를 확인한다.
