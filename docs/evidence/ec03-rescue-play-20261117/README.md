# TLT-063 · EC-03 구조 전체 동선 실제 Play

2026-11-17. 맵 구현·환경 아트·환경 모델링·리서치·QA를 순차 수행. 이번 산출물은 기존 공간의 플레이 검증과 재현 도구다. 지형/시설 재배치 구현은 하지 않았다. G5와 최고 품질 목표는 미완료다.

## 조건·재현

이전 실행의 고정 빌드0.113.2/e1f9360c를 사용했다. [build.json](build.json)과 [fixture.json](fixture.json)은 원래 실행 기록의 사본이며 이번 신규 빌드 기록이 아니다. 현재 HEAD 전체를 검증한 것이 아니다. `/tmp/tlt-ec03-play-latest.rbxlx`, PlaceId0, 별도 자체 Studio455d186c, Solo Easy/기사Lv80/23장 선행·mine_guards 완료 메모리 fixture. 인공 초기조건은 정상 성장·저장 수용 증거가 아니다. 운영 데이터/TD 수정 없음.

기존 `tools/qa/ec03-play.client.luau`로 정상 Configure/Solo 입장. `tools/qa/ec03-rescue-walk.client.luau`의 Navigation→Humanoid:MoveTo를 사용하고, 지지대 실제 ProximityPrompt InputHoldBegin/End로 보강했다. 첫 F 입력 시도에는 상태 변화가 확인되지 않아 성공으로 집계하지 않았다. 전투는 `tools/qa/ec03-rescue-combat.client.luau`의 정상 K0Action Attack 요청과 추가 Skill2 요청(5초 간격)을 사용했다. 적/영웅 수치·체력·피벗·WalkSpeed는 변경하지 않았다. 전투 이동 대기 시 encounters.position으로 ECWalk를 호출해2·3경로로 이어갔다.

[evacuation.executed.luau](evacuation.executed.luau), [start-escort.executed.luau](start-escort.executed.luau), [follow.executed.luau](follow.executed.luau)를 순서대로 실행했다. Orik 목적지에 먼저 도착하면 NPC가 대기하므로 마지막 코드는 실제 actorPosition의8stud 이내로 동행한다. 각 실행은 비동기며 done 상태를 기다린다. Stop 후 자체 Studio PID44120만 종료했고 사용자 Studio2개는 보존했다.

## 결과와 한계

[results.json](results.json): supports=true/1단계, worm=true/3경로, exp_1=true/3단계, miners=true/2단계를 서버 DeepwoodState로 확인했다. [세 번째 전투](third-route.png), [출구 완료 뒤 다음 목표](safe-exit.png)는 실제 Custom 카메라/HUD 화면이다. Orik 완료 후 actorProjection은 비었다. 다인 개인별 분리/재접속 복구 증거는 아니다.

- 2경로 이동15.334초·점프0, 3경로 이동18.132초·점프 상태 표본1회. 적과 이동이 겹쳐 원인은 확정하지 않았다. 표본간15stud 초과 불연속0은 서버 보정 계측값과 다르다.
- 확장 첫 접근은35초 제한으로 실패했다. 안내 경로의 이미 도달한 중간 꼭짓점까지 거리0.86stud에서 path[2]를 반복 지정한 테스트 코드 문제였다. 도달한 꼭짓점을 건너뛰고 제한90초로 수정해 남은4.400초에 도착했다. 지형 차단 결함으로 단정하지 않는다. 실패와 재시도 모두 결과에 보존했다.
- 광차·난간·표식3조작 완료. Orik에게서 먼저 멀어지자 실제 대기 상태를 확인했다. 되돌아가 실제 NPC 동행43.432초 후 완료, 점프0·위치 불연속0. 이 시간은 전체 호위 시작부터가 아닌 마지막 동행 코드의 실행 시간이다.

## 서사→공간 제작 인계

실제 경로는 보강(157,-12604)→worm(242,-12644)/(133,-12701)/(25,-12793)→광차(186,-12936)→난간(217,-13058)→표식(251,-12949)→Orik(297,-12694)→보강 경유(237,-12704)→출구(327,-12544)다. 좌표는 X/Z stud, 이번 Easy 변형이다. 기존 먼 시설의 외곽 장식보다 이 구조 궤적을 기준으로 채굴면과 하중 지형을 다시 배치해야 한다. 다음 ART/ENG는 supports 주변부터 기존 BracedMineHead의 안전 후보 위치를 탐색하고 원래/Easy 두 경로·전투/회피 예약·NPC22stud 동행 범위를 보존하는 대표 공간1개를 제작한다. 크기만 늘린 이전 후보 재적용과 작은 소품 증량은 반복하지 않는다.

## 공식 비교 자료

2026-11-17 본문 재확인: [Diablo IV 개발판2022 환경](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)의 재료·건축·역사로 공간을 설득하는 접근, [WoW Retail The War Within2024](https://news.blizzard.com/en-us/article/24125258/explore-the-zones-and-dungeons-of-the-war-within)의 지하 산업 지역, [Lost Ark 글로벌 Elgacia2023](https://www.playlostark.com/en-gb/news/articles/elgacia-release-notes)의 장소와 서사 구분을 비교했다. 직접 플레이/현행 패치 비교가 아니다. 기존 [리서치](../../research/2026-11-17-ec03-load-mass-candidate.md)를 재사용한다. TLT 해석은 구조 사건과 지질/시설의 인과를 실제 카메라에서 읽히게 하는 것. 적용 비용·위험은 전투 가림·충돌·접지이며 대표1구간/같은 카메라/두 동선 검사 후 채택한다. 기존 목표·보상·권위 계약은 유지한다.

미검증: 새 형상·전후 비교·게시 클라이언트·실기기·다인/성능/스트리밍·저장/재접속·사용자 미술 수용. 신규 빌드/버전/게시/태그 없음. 다음 담당 ART/ENG는 위 좌표와 동행 범위로 실제 재배치를 구현하고 QA가 검증한다.
