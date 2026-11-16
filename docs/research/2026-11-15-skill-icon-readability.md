# 스킬 아이콘 식별성 참고

TLT-057/059 · 2026-11-15 · 실제 플레이 조사가 아닌 공식 자료 확인과 프로젝트 컨셉 대조다.

이번 문제는 같은 계열의 스킬들이 공통 도형/약어로 표시되어 개별 동작을 구분하기 어려운 점이다. 사용자의 후속 지시로 검신은 일직선으로 유지하고, 승인된 Skill Tree 그림의 작은 노드 심볼을 시각 기준으로 다시 고정했다.

- Diablo IV의 [2021년 12월 개발자 설명](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021)은 기술 정체성과 전투 가독성, 강도별 시각 위계를 설명한다. 출시 전 VFX 철학을 참고하며 현행 패치의 수치/아이콘 사양으로 해석하지 않는다. 우리 적용은 단일 투사체·부채꼴·반복·보호를 색 이외의 형상으로 구분하고, 궁극기에 더 큰 중심 형상을 주는 것이다.
- WoW Retail Dragonflight 사전 패치의 [공식 UI 소개](https://worldofwarcraft.blizzard.com/en-gb/news/23837944/get-into-the-grid-of-things-with-the-updated-ui-and-hud)는 기존 시각 정체성을 보존하는 UI 갱신 방향을 설명한다. 검색 결과의 공식 본문 발췌를 확인했으며 전체 페이지 접근은403이었다. 우리 해석은 TD 셸·키·잠금·남은 시간 표시를 보존하고 스킬 그림만 공통 ID로 연결하는 것이다. 현재 WoW 패치/직업 동작을 조사한 것으로 간주하지 않는다.
- Roblox [ImageLabel](https://create.roblox.com/docs/reference/engine/classes/ImageLabel)과 [ContentProvider](https://create.roblox.com/docs/reference/engine/classes/ContentProvider)는 실제 이미지의 표시/로딩 상태 확인 근거다. 이번 등록은 독립 이미지 ID를 사용하며 UI 컨셉의 글자나 숫자를 게임 데이터로 추출하지 않는다.

타 게임의 이미지·문구를 복제하지 않고 프로젝트 승인 컨셉을 이미지 생성에 직접 제공한다. 전체 메뉴/영웅 초상 대신 작은 스킬 심볼을 참조하도록 지정했다. 무기 재질의 세부 묘사보다 굵은 실루엣·밝은 외곽·남색 여백을 우선한다. 성광/불/냉기/바람/물/번개/자연은 현재 기술 효과에 맞춘다. 기존 수치·서버 판정·성장·TD Experience를 변경하는 제안은 없다.

제작 비용은128개 PNG와 등록 ID, 관리 프롬프트다. 위험은 작은 크기에서 비슷한 기술의 혼동, 검신과 곡선 궤적의 합성, 로딩 지연이다. 검은 곧은 기준 이미지를 추가 제공하고 궤적을 분리한다. 전체 ID/원본 해시·중복·UI 연결을 검사하고40/64px 비교표와 실제 Studio 로딩을 확인한다. 실기기에서의 식별 속도와 사용자 미술 수용은 별도 후속이다. 다음 담당은 디자인/QA다.
