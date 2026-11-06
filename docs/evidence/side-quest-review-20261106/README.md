# 사이드 퀘스트 전체 리뷰

2026-11-06 · TLT-050/061~065/084 · ENG/QA 자체 검사 → 실플레이 QA · 0.78.7 · 로컬/미게시

사용자의 전체 리뷰 요청으로 정본 `CampaignContent`에 등록된 **12개 사이드 퀘스트·44목표·11전투**를 검토했다. Deepwood/설원/화산에 각각4개이며 어두운 숲/묘지에는 현재 등록된 사이드 퀘스트가 없다. 미구현 콘텐츠를 검증 완료로 세지 않는다. 기존 보고/보상/스토리 해금·안정ID·영어·TD 룩앤필 계약을 유지하며 원인이 명확한 안내 결함만 수정했다.

## 발견과 수정

1. **선행0.78.4 진행 차단 수정 유지:** 수동 프롬프트를 숨기는 battle 목표를 서버 근접 스캔에서 제외했던 문제. 선택 전투9개는 자동 진입, `marsh_slimes`/`quarry_slimes`2개는 기존 수동 `Begin encounter` 경로다. 전체11개를 엔진에서 시작/완료했다.
2. **P2 / 현장 발견8개에 잘못된 NPC 안내:** Frozen Vale/Ember Caldera의 `discoveryOnly` 요청 카드가 `Elder Tree Outpost`와 `FIND QUEST GIVER`를 표시하고 추적도 `Speak with ...`를 안내했다. 실제로는 현장 단서를 읽는 계약이다. 카드에 해당 지역·`FIND CLUE`, 추적에 첫 조사 목표·단서 읽기 후 ACCEPT/LATER를 표시한다. Deepwood NPC요청3개와 숨겨진 늪지 발견은 기존 계약을 유지한다.
3. **P2 / 본편 완결 뒤 사이드 완료 오표시:** 메인35 완료 후 사이드 원정을 완료하면 `EPIC 5 COMPLETE`로 떨어졌다. 해당 원정의 완료 여부를 먼저 확인해 `SIDE QUEST COMPLETE`와 로비에서 다음 모험 선택을 안내한다. 메인 미완결 시 다음 에픽/스토리 안내도 유지한다.

2번은 실제 네이티브 TD 퀘스트 카드의8개 단서/3개 NPC 구분과 지역 안내를 확인했다.3번은 수정 전 회귀 실패를 재현하고 수정 후 규칙/엔진 검증을 통과했다. UI 레이아웃·프레임·아이콘·경제·성장·저장/서버 권한은 변경하지 않았다.

## 퀘스트별 결과

`Main`은 해당 사이드 **독립 원정의 진입에 필요한 완료 메인 수**다. 현장 발견 시점과 보고 가능 시점을 구분한다. 모든 행은 규칙 검사와 실제 월드 노드/서비스 큐 경로 통과이며 실제 사람의 플레이 수용은 아니다.

| ID | 영어 제목 | Main | 목표 | 엔진 생성 적 | 결과 |
| --- | --- | ---: | ---: | ---: | --- |
| DW-Q1 | Supplies in the Marsh | 2 | 3 | 12 | 조사·선택 슬라임·보고 PASS |
| DW-Q2 | The Stolen Food | 4 | 5 | 49 | NPC보고·Goblin King/선행 웨이브 PASS |
| DW-Q3 | Quarry Below the Falls | 5 | 5 | 55 | 선택 슬라임·King Ogre/선행 웨이브·NPC보고 PASS |
| DW-Q4 | Remnants of the Red Battlefield | 7 | 4 | 67 | Enraged Warlord/선행 웨이브·NPC보고 PASS |
| FV-Q1 | A Name in the Snow | 8 | 3 | 0 | 발견·회수·보고 PASS |
| FV-Q2 | Frostfang Supply Cave | 10 | 3 | 1 | 발견·수호자·보고 PASS |
| FV-Q3 | Blue Lake Return Route | 11 | 3 | 1 | 발견·수호자·보고 PASS |
| FV-Q4 | Ancient Glacier Watch | 14 | 3 | 1 | 발견·수호자·보고 PASS |
| EC-Q1 | A Worker's Lost Mark | 15 | 3 | 0 | 발견·기록·보고 PASS |
| EC-Q2 | Ember Raider Nest | 17 | 4 | 1 | 발견·보스·확보·보고 PASS |
| EC-Q3 | Volcano Shaman Altar | 18 | 4 | 1 | 발견·보스·확보·보고 PASS |
| EC-Q4 | Caldera Titan Basin | 21 | 4 | 1 | 발견·보스·확보·보고 PASS |

DW-Q1은Main0 발견/Main2 보고, FV-Q1은Main7 발견/Main8 보고, EC-Q1은Main14 발견/Main15 보고다. 독립 원정은 `Difficulty.requiredMain`에서 보고까지 가능한 시점에만 허용하는 기존 계약이며 조기 발견의 보고 대기는 결함으로 세지 않았다. 고정 사이드 XP/Gold0과 별도 처치/난도 재료 보상을 보존한다. 설원·화산 보스의 선행 일반 웨이브 유무는 정본 적 정의에 따르며 이번 리뷰로 새 웨이브를 추가하지 않는다.

## 검증과 재현

- `lua tests/side-quest-review.spec.lua`: **1610개 PASS**. 모든12개를 실제 계정 규칙으로 첫 Easy·Easy재도전·전투 퀘스트 Hard/Insane/Hell까지 완료. 목표마다 새 runId로 재진입하여 이어하기 확인. 조기보고/다른run 거부·중복 이벤트 무보상/무revision·개인 본편 보존·반복 완료·지역 해금/연결/지면·보스 마지막 단독 웨이브 확인. 비전투2개는 상위 전투 난도 거부 확인.
- `lua tests/side-quest-guidance.spec.lua`: **77개 PASS**. 프로덕션 `Journal.guidance` 추출, 현장 발견/NPC 구분·수락 후 목표·훈련 제외 확인.
- `lua tests/side-quest-battle-start.spec.lua`:1029개 PASS. 선택9/메인64개 자동 전투 진입/차단 회귀.
- `python3 tools/assemble-side-quest-review-test.py` → `run-in-roblox --place builds/0.78.6/TheLastThrone-0.78.6.rbxlx --script /tmp/tlt-side-quest-review-native.luau`: 최종 실행 exit0·**739개 PASS**. 기존 로컬 빌드의 실제3지역 월드와 TD 모델·Humanoid·프롬프트 노드, 최신 서비스 소스와 수정 Log/Book 주입.189개 적 생성·서비스 사망 처리/중복 무시·44목표의 이벤트 큐·12보고·수정 카드 확인. [엔진 결과](native.json).
- 기존 회귀12개(`deepwood-quests/progress/encounter-balance/bosses`, `frozen-vale`, `ember-caldera`, `late-epics/adventures`, `difficulty-enhancement`, `journal-missing-target`, `story-completion`, `battle-startup`)도 모두 PASS. [전체15개 명령/결과](checks.json).
- 변경 런타임3파일·네이티브 fixture `luau-compile`, `git diff --check`: PASS.

## 검증의 한계와 다음 담당

네이티브 검사의 플레이어/계정 저장/입력·combat 등록은 대역이며 실제 Humanoid의HP를0으로 만든 뒤 **프로덕션 서비스 사망 처리**를 호출한다. 실제 공격 명중·전투AI·정예 패턴/설원 진정·죽음/전멸 재시도·다인 기여·live DataStore·실제 앱/실기기를 증명하지 않는다. 입장은 실제 `AdventureRules.begin` 자동 수락 경로이며 현장 ACCEPT/LATER 버튼의 실제 클릭은 이번 엔진 fixture에 포함하지 않는다. 기존 수락/SaveUnknown복구31검사와 정본 권한을 별도로 재검증했다.

최종 엔진 실행은 기존203785492의asset-type 경고만 발생했다. 앞선 검사1회에서는76744758708627 메시 다운로드 실패가 있었으므로 원격 자산의 항상 성공/최종 미술 수용으로 해석하지 않는다. 최종 테스트용0.78.6 Studio 프로세스가 종료된 것을 확인했으며 다른 기존 Studio 세션은 건드리지 않았다.

다음 QA는 게시된 테스트 클라이언트에서 각12개의 수락/추적→현장 이동→실제 전투/선택 목표→보고/재접속을 PC·터치·패드, 솔로/다인으로 수행한다. 독립 QA·사용자 수용 전이므로 부모 티켓 In Progress를 유지한다. Place게시·태그·TD운영 변경은 수행하지 않는다. 사용자의 Blender 미커밋/미추적 파일은 보존한다.

단일 빌드 **0.78.7 성공**. 입력 소스 `21a8d548a48392b23343912afa737aca8360a821`, SHA-256 `a6d0505cdf9c2c97cfcf7fbbf52dec53d07d985e38df1ed7869a278730582431`, 13,287,263bytes. 산출물 XML에서 변경3개 모듈의 소스 일치를 확인했다. [빌드 기록](build.json). 소스 origin/main 푸시 성공, 게시/릴리스 태그 없음.
