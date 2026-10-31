# 새 스킬 해금 축하 안내 · 0.58.0

- 작업 ID: TLT-005/032/033/084 부분 구현. 서버 확정 성장 스냅샷에서 실제 해금된 스킬을 감지해 이름과 편성 안내를 짧은 확대 효과와 함께 표시한다. 궁극기는 별도 버튼 안내를 사용하고 여러 스킬은 순서대로 표시한다. 최초 로딩·영웅 전환·이전/중복 응답은 새 해금으로 오인하지 않는다. [조사](../../research/2026-10-31-skill-unlock-notice.md).
- 검증: 격리 Studio Edit `tests/skill-unlock-notice-native.luau` 10개 검사 통과(공통 스킬, 연속 해금, 중복/역순 응답, 영웅 전환 및 최종 전직). `lua tests/advanced-skills.spec.lua` 1,435개, `lua tests/hero-progression.spec.lua` 656개 통과.
- 미검증: 게시 클라이언트·실기기에서 실제 레벨업/전직 화면, 사운드와 사용자 시각 수용. 별도 신규 소리는 적용하지 않았다. 다음 담당: 성장 UI/QA.
