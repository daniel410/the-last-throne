# TLT-028/031/061 — 선택 영웅 식별

2026-11-02 확인. 사용자 요구는 작은 체크에 의존하지 않는 선택 피드백, 클래스/레벨 문구, 무기 외형이다.

- Roblox 공식 [UI/UX design](https://create.roblox.com/docs/production/game-design/ui-ux-design): Spellbound RPG의 선택 전후 아이템 버튼과 시각 피드백 사례. [버튼 문서](https://create.roblox.com/docs/ui/buttons)는 버튼 외형 변화로 피드백을 제공하는 방식을 설명한다. 문서 열람이며 직접 플레이는 아니다.
- RPG 비교: Guild Wars2 공식 [Wardrobe 소개](https://www.guildwars2.com/en/news/miniatures-and-finishers-in-your-account-wardrobe/)는 현재 장비와 외형 선택의 구분을 명확히 하는 목적과 전신 미리보기를 설명한다. 해당 소개만으로 현재 캐릭터 선택 화면에서 무기가 표시된다고 추정하지 않는다.

적용 판단: 색 변화와 함께 SELECTED 문구·금색 이름표를 중복 제공하고, 서버 확정 클래스와 기존 무기를 로비 외형에 연결한다. 새 자산 제작 없이 기존 TD 초상을 유지해 비용을 줄인다. 선택 전 저장 지연에는 기존 busy 상태를 유지한다. 최소 시험은4클래스 전환, 이전 XP 가림,4뷰포트 경계·입력 잠금·로비 전투 불가다. 시각 식별성은 실제 화면 사용자 수용이 필요하다.
