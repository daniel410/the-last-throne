# Studio 테스트 초기 재화 복구

2026-11-16 · TLT-045/041/084 · 최신 사용자 지시: 테스트 초기 재화를 남긴다. [현재 계약](../../production/gold-rewards-2026-11-16.md#studio-초기-재화)을 따른다.

`StudioTestRules.new`의 신규 시험 지갑 지급을 복구했다. Studio 전용 래퍼를 사용하는 신규 프로필에만 적용하며, 운영 기본 프로필·기존 잔액·재접속 시 잔액은 유지한다. 골드 감액 규칙19와 지급 함수는 변경하지 않았다.

## 검증

- `lua tests/studio-test-defaults.spec.lua`: [통과](tests.log). 신규 Studio 지급,4클래스/Lv10, 기존 지출 후 잔액·재접속 보존, 운영0잔액 분리를 확인했다.
- 감액 소스4개(`GoldRewardTuning`, `Difficulty`, `DeepwoodEncounterBalance`, `InventoryRules`)가 변경 전 커밋과 바이트 단위로 일치함을 확인했다.
- VERSION0.111.14 고정 빌드·격리 Studio 검증 결과는 후속 기록한다. 완료 전 엔진 통과로 간주하지 않는다.

게시·실제 입력/실기기·실계정 저장 수용은 미검증이며 Roblox 게시/릴리스 태그는 만들지 않는다. 다음 담당은 QA/사용자다. 상위 티켓 완료 처리 없음.
