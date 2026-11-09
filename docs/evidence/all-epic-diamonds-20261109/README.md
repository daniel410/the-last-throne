# 모든 에픽 Diamonds 보상 · 0.89.0

2026-11-09 · TLT-027/041/050/052/057/084 · ENG → QA · 로컬 구현·미게시.

## 변경

사용자 요청으로 기존 Deepwood의 메인 스토리당3 Diamonds를 GW/FV/EC/HG에도 적용했다. 다섯 지역 각각21개·35스토리 신규 계정 총105개. 고정 메인ID만 허용하며 사이드/프롤로그·다른 영웅·반복·난이도 재완료는 추가0이다. Gloamwood의 별도 XP/Gold 완료 지급 경로도 공통 Diamonds 처리를 거친다.

기존 완료 네 지역은 저장 저널의 미수령ID를 계정 로드 때 한 번 지급한다. 여러 영웅의 같은 스토리도 한 번만 지급하고 지갑 잔액/영수증을 함께 저장한다. 기존 Deepwood2개 수령분과 구저장 DW 이관2개는 유지한다. Gold/XP/재료/아이템/가격/TD 지갑·권리를 보존한다. 잔액 상한에서는 영수증을 남기지 않아 소비 후 재로드 시 복구한다. 과거35개 완료·Deepwood잔액2인 예시는84개를 추가해86이 된다.

퀘스트 보상 설명에3 Diamonds once per account를 추가하고 잔액 부족의 낡은2개 안내를 수정했다. [경제/비교 근거](../../research/2026-11-09-all-epic-diamonds.md).

## 검증

`lua tests/all-epic-diamonds.spec.lua`: 1086 PASS. 실제 계정 reducer로 두 영웅35스토리 완료, 모든 지역 반복 원정, 매 단계 재시도, 사이드/잘못된ID 제외, 기존 완료/무지갑 이관, 소비 후 재로드, UpdateAsync 콜백 재실행·저장 후 응답 불명·재접속·상한 후 복구를 확인했다.

[관련11개 회귀](regressions.json): 총17,374 PASS·모두 종료0. 경제/난도/완료 보상/캠페인 순서·확장/미리보기/초기화권·Gold교환 포함. Lua 검증은 실제 계정/라이브 DataStore 증거가 아니다.

`python3 scripts/simulate_story_progression.py --output /tmp/tlt-all-epic-diamonds-progression.json` 종료0, 정본 미수정. `git diff --check` 통과.

## 한계와 인계

실제 계정/클라이언트·기기·협동·사용자 경제 수용은 미검증이다. QA는 게시 테스트 환경에서 네 지역 초회3개/기존 완료 복구/다른 영웅 중복0/로그인 재시도/상점 소비 후 잔액 보존을 확인한다. 확장 영수증은 이전 DW전용 검증 코드가 읽지 못하므로 실제 배포 때 로비·배틀을 같은 버전으로 갱신하고 구 서버를 교체해야 한다. 현재 Studio와 Place 게시·릴리스 태그는 변경하지 않는다. 부모 티켓 In Progress 유지.
