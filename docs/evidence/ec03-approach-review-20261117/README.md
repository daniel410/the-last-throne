# TLT-063 · EC-03 접근 장면 검토

2026-11-17 UTC. 리서치·맵 구현·환경 아트·환경 모델링 역할을 순차 수행했다. 이번 산출물은 재현 가능한 접근 검토 도구와 화면 증거다. 게임 지형·시설·개인 진행 소스는 변경하지 않았다. 빌드·버전 증가·게시·태그 없음. G5 미완료.

## 조건·재현

직전 검증 빌드 **0.111.30 / 737d79560e5f15fecfbd4c6ce88ed1ab556baa51**의 로컬 QA XML `/tmp/tlt-ec03-apron-final.rbxlx`를 별도 Studio PID10742/Edit/PlaceId0에서 열었다. 기존 사용자 Studio는 건드리지 않았다. BaseScript를 비활성화하고 [직전 verify.luau](../ec03-quarry-shoulders-20261117/verify.luau)를 실행했다. `_G.ShoulderStatus.ok=true`, EC 월드 생성·고정 소스 대조·구문·기존/Easy 경로 검사가 통과했다. 새 이동/플레이 수용으로 중복 집계하지 않는다.

[검토 스크립트](../../../tools/qa/review-ec03-approach.luau)를 `_G.ECReviewGoal='supports'`, 이어서 `'miners'`로 각각 실행했다. CampaignContent의 변환된 좌표와 DeepwoodNavigation 안내 폴리라인을 역으로20stud 따라 접근점을 구한다. 발밑 기준 focus+4.5, 줌24/피치30도 후보를 AdventureCamera.constrain에 통과시킨다. 실제 플레이어 카메라가 아니라 **Edit 궤도 근사**다. 지형/바닥 카메라 충돌 규칙만 실제 모듈을 재사용한다.

3초 대기 후 위치 오차 .01/방향 dot .99999 검사 통과. 첫 시도 Focus 고정 검사는 실패했다. Studio가 Focus 거리를 자동 정규화하는 것을 확인해 요청/관측 Focus를 모두 기록하고 위치·방향 검사는 유지했다. 3초는 Terrain 렌더 완료 보장이 아니다. 이어 override 없는 screen_capture 촬영. [측정값](results.json). 측정 viewport1330×908과 캡처1581×1080은 같은 종횡비의 다른 해상도이므로 픽셀값을 직접 혼용하지 않는다.

## 화면·판단

- [지지대 접근](supports.jpg): 목표 중심은 화면 안, 첫 고체 ray 적중 없음. 작은 목제 표식과 넓은 바닥이 전경을 차지한다. 광산 시설은 측면/원경에 있어 보강 사건과 시설의 연결이 약하다.
- [광부 구조 접근](miners.jpg): 목표 중심은 화면 안, 첫 고체 ray 적중 없음. 넓은 바닥과 독립 기둥이 먼저 읽힌다. 개인 NPC/HUD 투영이 없는 장면이므로 실제 구조 NPC의 가림/가독성 결함으로 확정하지 않는다.

ray는 충돌 가능한 고체만 검사하므로 장식·투명도·실제 목표 형상 가시성을 증명하지 않는다. 중심이 화면 안이라는 사실 역시 사용자 가독성 통과가 아니다. 두 화면은 다른 목표의 비교이며 지형 변경 전후 A/B가 아니다.

## 다음 제작 인계

ART/ENG/QA: 실제 Play에서 영웅·HUD·개인 구조 투영을 포함한 같은 두 접근 장면을 먼저 대조한다. 이후 `StoryPropAssignments`의 EC-03 supports/MineBrace와 `RegionalConceptProfiles`의 BracedMineHead를 한 구조 공간으로 연결하는 대표 구간을 제작한다. 목표와 시설을 단순 이동하면 저장 좌표·전투/호위·장애물 계약에 영향을 주므로 현재 증거만으로 변경하지 않았다. 외곽 능선/작은 소품 증량 반복은 후순위다.

실제 영웅 조작·회피/전투·개인 투영·게시 클라이언트·실기기·1~4인+AI·스트리밍/성능·사용자 미술 수용은 미검증. [조사·제작표](../../research/2026-11-17-ec03-approach-review.md).
