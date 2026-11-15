# 난이도별 캠페인·초회 보상 분리 검증

2026-11-15 · TLT-050/061~065/084 · ENG/PLAN → QA. 로컬 구현·빌드·엔진·Studio Play 검증. 게시/실계정 저장·실기기·사용자 수용은 미검증이며 상위 티켓을 Done으로 변경하지 않는다.

## 요구와 구현

사용자는 Hard 등 새 모드가 이전 모드의 퀘스트/에픽 완료를 가져오지 않도록 지시했고, 추가 확인으로 초회 XP·Gold·아이템도 각 난이도 최초 완료에 지급하도록 확정했다. [현재 사양](../../production/campaign-mode-progress-2026-11-15.md)·[결정](../../decisions/2026-11-15.md)·[Diablo/WoW/Roblox 조사](../../research/2026-11-15-mode-campaign-progress.md).

기존 구현은 `hero.deepwood`를 공통 진도와 초회 수령 판정에 사용했다. 서버에 `modeJournals`·`modeRewardClaims`·`runsByMode`를 추가해 Easy/Hard/Insane/Hell의 본편·선택 퀘스트·부분 목표·에픽·모드 왕복 체크포인트와 확정 처치를 분리했다. 명시적으로 시작한 재플레이도 그 모드의 체크포인트를 유지한다. 난이도 버튼·완료 표시·첫 보상 미리보기·기본 이어하기·개인/파티 입장·원정 내 다음 스토리·로비 선택 퀘스트 보고가 같은 진도를 사용한다. 비전투 본편도 각 모드에서 재개할 수 있다.

초회 지급은 기존 단일 계정 트랜잭션에서 모드별 수령 기록과 XP/Gold/아이템을 함께 저장한다. 아이템 지급ID에 난이도를 포함하고 반복 완료 보상과 겹쳐 지급하지 않는다. 이전 완료/영웅별 지급 영수증에서 확인 가능한 모드 진도를 이관하며, 구 순서의 실제 Easy 완료/접근과 부분 목표를 보존한다. 원본 공통 이력과 잔액/보유품/영웅 성장·지원권은 삭제하지 않는다. 이미 받은 보상의 차액을 소급 지급하지 않는다. Hard 개방·Insane/Hell의 동일 임무 이전 난이도 조건, 전투/XP 규칙17, Diamonds 3/5/7/10은 유지한다. TD는 변경하지 않았다.

## 고정 빌드와 정적 검증

- [빌드](build.json): **0.109.0**, 입력 `ab9e2d4b5c640079e166bc83673f018d9d304d44`. 단일 산출물 `builds/0.109.0/TheLastThrone-0.109.0.rbxlx`, SHA256 `b8ff03ea4cdf1da55f8053b74a96c2f1e305960af65521c27706173ed9992ae2`. 버전/소스를 먼저 커밋·푸시한 뒤 `python3 tools/build-game.py --source ab9e2d4b --record docs/evidence/campaign-mode-progress-20261115/build.json`으로 생성했고 해시를 재확인했다.
- [순수 Lua 모드 검사](mode-progress-tests.log): **4,621건 통과**. 4난이도×35본편 전체, 모드별 DW-Q1, 다른 모드 저널 불변, 에픽 종료, 초회 Gold/장비, 실제 Lv10의 XP와 Diamonds, 재플레이, 부분 진도/처치 복원, 이관/재로드, 원정ID 거부, 손상 저널, 불명 응답 및 동시 서버 임대 거부를 검증한다.
- [회귀 9개](source-regressions.json): inventory 276, economy 38, difficulty-diamonds 3,180, all-epic-diamonds 1,099, lobby-side-quests 539, expedition-store 43, hard-unlock 56, expedition-presentation 24, story-lobby-resume 33 통과. 로비 선택 퀘스트 검사는 해당 난이도의 선행을 이미 완료한 명시적 fixture로 갱신했고, 구 우발 재플레이와 신규 명시적 재플레이를 구분했다.
- [기존 검사 실패](existing-continuation-failure.json): story-continuation의 52행 `StoryLocked`는 변경 전 `eb3c4e7d`에서도 동일하게 실패한다. 이 파일의 전체 통과를 주장하지 않는다. 새 검사는 실제 필수 확장/전투 목표를 포함해 모든 모드의 35본편 연속 완료를 별도로 검증한다.
- [산출물 검사](artifact-check.log): 역할10·도착 로딩283·실제 프로젝트/산출물 검사 통과. `git diff --check` 통과.

## 엔진과 실제 플레이

`python3 tools/prepare-campaign-mode-progress-native.py`로 생성한 검증기를 **정확한 0.109.0 산출물을 연 격리 Edit DataModel**에서 실행했다. 관련10개 모듈 Source 일치와 전체 Luau 문법 검사를 선행한다. 모드 검사4,621·실제 교전/네비 수명 검사823, **합계5,444건 통과**. 검사용 영웅1명의4모드 완료/선택 퀘스트/재플레이 포함 계정 JSON은115,162 bytes이며 최악 저장량·기기 성능 수용 수치로 취급하지 않는다. [고정 빌드 엔진 출력](native-fixed-build.json).

최초 `run-in-roblox` 자동 실행은 Studio 연결 시간 초과로 시작하지 못했다. [실행기 실패](native-launch-failed.log). 빌드는 성공했으며, 이후 Finder에서 동일 산출물을 열고 Studio MCP로 검증기를 실행해 위 통과 결과를 얻었다. 검증기는 장별 yield를 추가해 실제 Studio 주 스레드를 장시간 점유하지 않도록 했다. 게임 소스 변경은 없다.

같은 파일에서 실제 Play를 실행했다. 정상 클라이언트 요청으로 Knight 생성·출발/로비 복귀를 수행하고, 퀘스트 완료만 QA용 서버 `InventoryService.storyEvent` 호출로 주입했다. 실제 전투/보행 완주로 보고하지 않는다. [관측 JSON](play-verification.json)·[프로브](play-probe.luau).

| 관측 단계 | Easy / Hard 본편 진도 | XP 총량 | Gold | Diamonds | Fine 무기 수 |
| --- | --- | --- | --- | --- | --- |
| Easy DW-01 완료 | 1 / 0 | 1,898 | 10,150 | 5,003 | 1 |
| Hard DW-01 새 출발 | 1 / 0, Hard 목표 플래그 없음 | 1,898 | 10,150 | 5,003 | 1 |
| Hard DW-01 완료 | 1 / 1 | 2,184 | 10,300 | 5,008 | 2 |

클라이언트도 Hard/진도0/초회 미수령과 첫 교전 좌표를 수신했다. 실제 `ModeInsane` 버튼 클릭으로 미완료 DW-01이 선택되고 Hard 완료에 따라 입장 가능, Hell은 Insane 미완료로 잠긴 것을 확인했다. 실제 `ModeEasy` 클릭은 DW-02를 선택했고 `Solo` 클릭 뒤 Easy DW-02로 입장했다. Easy/Hard는 각각 진도1, Insane/Hell은 진도0을 유지한다. 테스트 후 Play를 중지했으며 임시 프로브를 원본 파일에 저장하지 않았다.

## 남은 수용·다음 담당

Roblox 게시·릴리스 태그·live DataStore는 변경하지 않았다. QA/사용자는 이 빌드에서 일반 입력으로 모드 전환·부분 퀘스트 복원·각 에픽 완료·초회/반복 수령과1~4인 파티를 확인한다. 게시 테스트 Experience 간 실제 이동, 실계정 저장/재접속·불명 응답, 실기기 성능과 전체 저장 상한은 후속이다. 상위 티켓의 수용 게이트는 유지한다. 롤백은 저장된 모드 진도/수령 필드를 삭제하지 않고 구 writer와의 호환성을 검토한 일반 커밋으로 수행한다. 사용자 자산과 동시 진행 전투/맵 작업은 별도 파일·커밋으로 보존했다.
