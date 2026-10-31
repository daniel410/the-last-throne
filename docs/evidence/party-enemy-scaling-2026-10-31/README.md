# 일반 적 파티 보정 시험

- 작업: 사용자 요청 / TLT-052/061 부분 구현. Deepwood 스토리 교전 일반 적의 HP를 전투 시작 시 적격 근처 인간 플레이어 1/2/3/4명에 따라 1/1.5/2/2.5배로 적용한다. 보스·공격력·개체 수·보상과 솔로 수치는 유지한다. 중도 합류·AI는 인원에 반영되지 않는다. [조사](../../research/2026-10-31-party-enemy-scaling.md).
- 검증: `lua tests/deepwood-encounter-balance.spec.lua` 3,111개 통과(일반 4계수·솔로·보스·공격력·보상·웨이브 포함), `lua tests/dwarf-stun-and-first-story.spec.lua` 57개 통과, `git diff --check` 통과.
- 미검증: Studio 실제 2~4인 서버, 중도 합류·이탈, AI 동료, 체감 난이도와 기기 성능. 다음 담당: QA. 빌드·게시 없음.
