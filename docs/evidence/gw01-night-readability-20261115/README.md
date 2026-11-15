# TLT-065 / GW-01 밤 단서 가독성

2026-11-15 · 구현/Studio 검증 · G5 미완료.

## 제작표·범위

| epic/story | 원천·사건 | 표현·위치 | 전후·플레이 목적 |
| --- | --- | --- | --- |
| 2 / GW-01 exp_1 | CampaignStoryBeats의 북쪽 화물 바퀴와 거미줄로 향하는 정찰대 발자국, campaign-context-review-2026-11-10 GW-01 | 기존 ScoutsTrailEvidence 발자국10쌍만 밝은 압착 토양으로 변경 | 밤에 두 흔적을 구별. 진행 전후 상태 없는 기존 지면 흔적이며 새 사건을 추가하지 않음 |

GloamwoodTrailEvidence v3. 기존 기본 Sphere SpecialMesh 파생; 발자국20파트의 색·재질만 변경했다. 바퀴14/총34파트, 위치·형태·투명도·접지·streaming 모델·거리 속성 유지. 추가 파트/조명/외부 자산0. TD 원본과 플레이 바닥·지형·수목·진행·저장·보상 변경 없음. [조사·후보 선택](../../research/2026-11-15-gw01-night-readability.md).

## 고정 빌드·검증

0.110.8 / df8a0dac57b5355ad8f6833113bc3db0cef04ec4. [빌드 기록](build.json). `python3 tools/build-game.py --source HEAD --record docs/evidence/gw01-night-readability-20261115/build.json`.

격리 `/tmp/tlt-gw01-night-fixed.rbxlx`, PlaceId0/플레이어0 Studio Edit에서 BaseScript를 끄고 Baseplate를 제거한 뒤 실제 CampaignWorld.create(2)를 생성했다. 후보 소스 주입 없이 고정 모듈 원문 일치·구문 확인. 재현: `python3 tools/prepare-gw01-night-native.py`로 생성된 Luau를 해당 격리 Studio Edit에서 실행한다. [입력 해시](inputs.json), [엔진 결과](results.json).

- 조사 흔적11,213검사 통과:34접지/20발자국/14바퀴, 둥근 형상·비충돌/쿼리/터치·재질 분리, 재적용·기존 기하물리/챕터 불변, void/경사 거부.
- 기존 points105목표5,196표본, Easy worldPoints117목표5,491표본:차단·바닥·보정·안내·단차0. Humanoid 보행이나 전체 에픽/전투 회귀를 실행한 것은 아니다.

## 동일 조건 비교

[이전](before.jpg) / [변경](after.jpg). 고정0.110.8 동일 월드에서 발자국20파트의 색/재질만 이전값 RGB72·78·86/Ground로 토글해 before를 촬영하고 최종값으로 복원했다. Terrain/소품 재생성 없음. after는 최종값 복원 전 고정 빌드 검사 직후 화면이다. 화면 변화가 작았던 색상/독서등 후보는 최종 빌드에 포함하지 않았다.

런타임 DeepwoodAtmosphere.update('Gloamwood') 적용, ClockTime0. FOV70, 카메라(-1328,74,-4059)→focus(-1340,58.5,-4078), 거리약27.3stud. 실제 AdventureCamera.constrain을 통과한 게임 줌 범위의 Edit 재현이며 실제 영웅/자동 궤도 조작이나 게시 클라이언트 화면은 아니다. 두 화면에서 밝은 발자국과 어두운 화물 흔적의 방향 분리를 확인했다. 최고 품질·전체 미술 수용을 의미하지 않는다.

## 미검증·다음 담당

실제 클라이언트의 카메라 회전·회피/전투 중 판독, 모바일/패드·스트리밍·다인 성능·사용자 미술 수용 미검증. G5 유지. 다음 DES/QA는 실제 캐릭터로 exp_1 접근/회전/저사양 판독을 확인한다. 맵 담당은 큰 평지/직선 경계/과도한 반복과 지면 연결을 검토한다. 이번 흔적·수목·능선을 다시 증량하지 않는다. 게시·릴리스 태그 없음.
