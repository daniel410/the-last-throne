# 난이도·원정 리뷰 R1~R3 코드 수정

2026-11-02 · TLT-027/029/041/043/044/045/052/061/073/084 · ENG → QA · 0.62.4

[리뷰](../../reviews/difficulty-enhancement-review-2026-11-02.md)의 세 결함을 수정했다. 출발 준비는 MemoryStore에 단일 pending 입장권을 저장하고 기존 재입장권/계정 활성 저널을 보존한다. 실제 도착 서버가 pending 입장권과 서버 manifest를 확인하고 계정의 새 원정을 멱등 저장한 뒤 새 재입장권으로 승격한다. 승격 응답 유실/서버 종료 시 로비에서 계정의 durable active runId로 pending 입장권을 선택해 재접속한다. 기존 입장권의 배틀 갱신은 pending을 보존하고, 후속 출발은 pending 하나를 교체해 오래된 도착을 차단한다. 계정과 MemoryStore를 다중 키 원자 거래로 취급하지 않는다. Studio 단일 서버 미리보기는 기존 직접 시작 경로를 유지한다.

FV-Q1/EC-Q1 원정은 필수 보고의 main8/15 조건까지 확인한다. 퀘스트 발견 조건/기존 보상은 변경하지 않았다. 탐색은 영웅 공통 정본을 유지하고 실제 storyState projection에서 원정의 접근 가능한 구역만 합쳐 지도에 보낸다. 원정 목표 저널/향후 지역은 보존한다. Easy 최소Lv1, Hell 무제한 반복 및 강화 비용/보상 정본은 유지했다.

## 검증

- `tests.log`: 관련13개 Lua 묶음 총6,508검사 통과. 신규 출발42검사는 run 생성 실패, 두 번째 멤버 transfer 실패, 입장권 저장 응답 유실, 도착 전 기존 체크포인트/목표/재입장권 보존, 도착 저장 후 승격 전 재접속, 중복 도착 저장 및 낡은 pending 거부를 포함한다.
- 난이도/강화111검사: 선택 퀘스트 두 종류의 차단/허용 경계 및 실제 완주, 초회/반복 탐색 projection·복사 격리·미해금 구역 숨김 포함.
- 네이티브 Luau 컴파일, Studio Edit 격리 runner: 실제 InventoryService의 탐색 저장→storyState 노출, 초회/반복 저장·강화/장착 능력치 및 TD 상세 UI/모바일 크기 검사 통과. 실제 사용자/월드/Live DataStore를 사용하지 않았다. 임시 GUI/실행 task 정리 완료. 사용자가 이미 열어 둔 Studio는 보존했다.
- `python3 scripts/simulate_story_progression.py --output /tmp/tlt-review-fixes/progression.json`: 승인 계산 최종Lv40/XP0, quest XP13,795, Gold19,652 유지.
- 빌드 소스·해시는 후속 `build.json`, `build.log`, Studio 결과 파일로 고정한다. 기존 미커밋 TD 이동/로비/애니메이션 변경은 이번 커밋과 빌드에 포함하지 않는다.

## 미검증·인계

실제 게시된 각 테스트 Experience의 Roblox 클라이언트 Teleport 실패/재접속, 실제 MemoryStore·DataStore 장애와 다인 동시성, 기기/밸런스 수용은 QA 후속이다. 코드/격리 테스트 통과를 전체 런타임 수용으로 보고하지 않으며 게시·릴리스 태그를 만들지 않는다. 과거 리뷰의 repro.lua/log는 당시 결함 증거로 보존하므로 수정 소스에서는 과거 실패 assertion이 더 이상 성립하지 않는다. 현재 회귀 검증은 tests/의 수정된 묶음을 사용한다.
