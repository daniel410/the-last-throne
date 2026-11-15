# 난이도별 캠페인·초회 보상 분리 참고

2026-11-15 확인 · TLT-050/061~065/084 · PLAN/ENG → QA. 사용자 확정은 Easy/Hard/Insane/Hell의 퀘스트·에픽 진도 및 초회 XP/Gold/아이템 보상을 각각 분리하는 것이다. 아래 비교가 기존 제품 결정을 대신하지 않는다.

Diablo II의 공식 Arreat Summit은 다른 난이도의 퀘스트 아이템으로 다음 난이도 퀘스트를 완료할 수 없다고 설명하고, Nightmare에서 Den of Evil을 다시 완료해 보상을 받는 사례를 안내한다. **관찰:** 난이도 경계를 넘는 퀘스트 완료와 보상 권리를 분리한다. **적용:** 영웅·난이도·퀘스트를 완료/보상 키로 사용하며 이전 모드의 완료 플래그를 신규 모드에 복제하지 않는다. TLT의 Hard 개방과 Insane/Hell의 동일 임무 선행 조건은 기존 사용자 결정을 유지한다. [퀘스트 기본](https://classic.battle.net/diablo2exp/quests/basic.shtml)·[난이도](https://classic.battle.net/diablo2exp/basics/difficulty.shtml).

Diablo IV의 2.0 당시 공식 안내는 일반 난이도와 Torment 진입을 캠페인/Pit 등의 조건과 연결한다. **관찰:** 작품마다 난이도 해금 구조가 다르며, D4의 변경을 D2의 독립 퀘스트 반복과 동일한 규칙으로 취급할 수 없다. TLT에 새 해금/레벨 조건을 자동 추가하지 않는다. [공식 2.0 시즌 안내](https://news.blizzard.com/en-us/article/24140803/conquer-colossal-foes-in-season-of-hatred-rising).

World of Warcraft의 2024 Warbands 안내는 일부 진도를 계정 범위로 공유하고 퀘스트의 Warband 최초 추가 보상을 구분한다. **관찰:** 플레이 진도와 보상 최초 수령 범위는 명시적으로 정할 수 있다. **해석:** TLT에서는 사용자 지시대로 그 범위를 영웅+난이도로 정하고, 장비 소유/성장/재화와 퀘스트 완료를 같은 상태로 취급하지 않는다. WoW의 계정 공유 정책은 가져오지 않는다. [Warbands 공식 안내](https://news.blizzard.com/en-us/article/24061008/the-war-within-warbands-preview).

Roblox 공식 Data stores 문서는 여러 서버의 단일 키 갱신에 UpdateAsync를 사용하고 콜백에서 yield하지 않도록 안내한다. **적용:** 기존 계정 단일 키 트랜잭션에 난이도별 저널·초회 수령·아이템 지급을 함께 기록한다. 별도 키 네 개를 원자 거래로 간주하지 않는다. 기존 세션 펜스와 불명 응답 재시도를 유지한다. [공식 저장 문서](https://create.roblox.com/docs/cloud-services/data-stores).

비용은 영웅당 최대 네 저널·원정 체크포인트의 저장/복사량 증가와 구 공통 기록의 이관이다. 구 기록은 확정된 난이도별 완료/지급 영수증으로 분리하며 다른 난이도의 완료를 추정하지 않는다. 최소 수용은 Easy 부분 진행→Hard 시작 시 목표 미완료, 모드 왕복 후 각 부분 진도 복원, 네 난이도×35본편 및 선택 퀘스트의 독립 완료/초회 보상, 재시도·불명 저장·재접속 중 중복 지급 없음이다. 엔진/게시 클라이언트·실기기 수용은 구현 증거에서 구분한다.
