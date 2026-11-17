# TLT-063 · 최신 소스 실제 Play 광산 연결 감사

2026-11-17. 맵 구현·환경 아트·환경 모델링·QA 순차 수행. 상태: 검증 도구와 증거 추가. 이번 실행은 지형/소품 형상 개선을 구현하지 않았으며 G5/사용자 품질 목표는 미완료다.

## 입력·재현

0.113.2 / e1f9360c6569e1422941b558c33341b79b2da620. [고정 빌드](build.json)의 모든 LFS 입력을 빌드 도구가 해시 검증했다. 기존0.113.1 이후 광산 보강 소스를 포함하는 최신 고정 소스다. PlaceId0, Studio0.747, 로컬1인 Client/Server Play. [fixture](fixture.json)는 InventoryService에만 Studio/PlaceId0 한정 메모리 기사Lv80와23장 선행·mine_guards 완료를 준비한다. 선행 정상 성장/전투 완주 증거가 아니다. 정상 Configure/Solo 요청으로 Easy EC-03 입장, 실제 HUD/영웅/Custom 카메라 사용. 운영 데이터·TD 변경 없음.

`python3 tools/prepare-ec03-play-fixture.py --artifact builds/0.113.2/TheLastThrone-0.113.2.rbxlx --output /tmp/tlt-ec03-play-latest.rbxlx --record <fixture.json>` 후 별도 Studio에서 Play. `tools/qa/ec03-play.client.luau`를 Client 실행한다. 결과는 `_G.ECPlayRun`. 보행에는 PlayerModule controls를 잠시 비활성화하고 실제 Navigation.route→Humanoid:MoveTo를 사용했다. WalkSpeed/피벗/점프를 조정하지 않았다. 지지대 도착 후 실제 F키900ms. GetState 서버 응답과27파트 개인 색상을 회수했다. 이어 [실행 보행 코드](worm-walk.executed.luau)로 worm 입구까지 이동했다. 엔진 검사 후 Stop, 저장 없이 자체 Studio 종료. 사용자 Studio는 조작하지 않았다.

## 결과

[측정](results.json). 스폰→supports6.134초 도착, supports→worm5.828초 도착, 각 점프0/표본간15stud 초과 위치 불연속0. 후자는 서버 보정 콜백 계측값이 아니다. 실제 지지대 F조작으로 서버 flags/activities1을 확인했고 BraceHandle만 청록 완료색으로 투영됐다. 지역 제목은 EMBER CALDERA / THE GREAT FURNACE다. worm 입구에서 Route1/3·적6체 교전 HUD와 피해를 관찰했다. 전투 완료/Orik 구출은 수행하지 않았다.

[실제 Play 화면](worm-approach.png)은 뒤쪽 광산 채굴면·시설과 평지의 구조/전투 사건이 분리되어 읽히는 문제의 기준 화면이다. 스폰→지지대에서는 작은 가압 지지대가 작업대 같은 독립 실루엣으로 보였다(이 첫 화면은 대화 도구에서 관찰했으며 파일 보존 없음). 현 지형이 최고 품질이라고 판정할 근거가 없다. 소품 증량보다 사건과 채굴면의 큰 공간 연결을 우선한다.

| epic/story · 원천 | 사건·현재 표현 | 다음 대표 제작 범위 · 수용 |
| --- | --- | --- |
| EC-03 / EmberCalderaContent supports | 균열 지지대 보강 / 작은 독립 shore | 목표/상호작용 좌표 유지, 주변 채굴면·하중 실루엣으로 지지 목적이 읽히는 비충돌 후보를 제작. 전후 같은 실제 카메라 비교 |
| EC-03 / worm | 구조 터널 방어 / 넓은 평지 교전, 먼 광산 | 전투 예약 바깥에 채굴 지형의 옆 실루엣을 연결하는 대표 후보. 길목/회피·원래/Easy 경로·투영/질의 보존 |
| EC-03 / miners | Orik 구조 후 대피 / 이번 미검증 | 먼저 정상 worm3경로와 exp_1 완료 후 Orik 실제 escort·개인상태·출구 시야 확인. 후보 수용 전에 필수 |

다음 ENG/ART/QA는 위 miners 검증을 마치고 대표 채굴면 후보1개만 제작·비교한다. 기존 입구 지지대·잔석의 세부 증량과 근거 없는 바닥 평탄화를 반복하지 않는다. 게시/실기기/멀티·성능/스트리밍/미술 수용은 미검증. 콘솔에 기존 일부 오디오 Asset type mismatch가 관찰됐으며 이번 맵 검증 통과 범위에 오디오를 포함하지 않는다. 게시/태그 없음.

## 리서치

2026-11-17 공식 본문 재확인: [Diablo IV 개발판2022 환경](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)의 재료·건축·역사에 의한 설득력, [WoW Retail The War Within2024](https://news.blizzard.com/en-us/article/24125258/explore-the-zones-and-dungeons-of-the-war-within)의 지하 산업 공간, [Lost Ark 글로벌 Elgacia2023](https://www.playlostark.com/en-gb/news/articles/elgacia-release-notes)의 장소별 서사 정체성을 비교했다. 현행 밸런스 비교/직접 플레이가 아니다. TLT 적용은 구조 지점과 광산 지형의 인과를 실제 카메라에서 읽히게 하는 해석이며, 외부 자산/규칙을 복제하지 않는다. 비용·위험은 큰 지형의 전투 가림/접지/충돌이다. 따라서 먼저 비충돌 대표 후보로 비교하고 기존 서버 목표·보상·TD 계약은 유지한다.
