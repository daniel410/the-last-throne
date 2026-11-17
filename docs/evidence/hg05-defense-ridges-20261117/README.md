# TLT-064 · HG-05 외곽 능선 후보

2026-11-17. **후보 보류, 본편 지형 개선 미완료.** 맵 구현·환경 아트·환경 모델링·리서치 역할 순차 수행.

| 스토리/원천 | 사건과 표현 | 구현/판정 |
| --- | --- | --- |
| Haunted Graveyard / HG-05 · CampaignStoryText HG-05 및 exp_2 | 서쪽·동쪽 외곽 방어 장치와 왕릉 진입. 개인 장치 파괴 상태를 선표현하지 않는 풍화 능선 | 기존 Slate/Rock Native Terrain 파생. 좌우5곳 중 모든 지역·확장·연결 예약+8stud를 피한2곳만 생성. 비교에서 작은 외곽 언덕으로 읽혀 넓은 평지/방어선 개선에 부족, 생산 소스 미채택 |

## 재현·검증

기존 0.113.2 QA 파일의 복사본 `/tmp/tlt-hg05-review.rbxlx`, 자체 Studio `17079c18-61c0-4c87-8b9a-a1ebabecfc5a`, Edit, PlaceId0. 현재 HEAD 전체 빌드 검증은 아니다. 스크립트를 끄고 CampaignWorld.create(5), 후보 ModuleScript를 World에 추가한 뒤 build(world.folder, HG05.center, HG05.size)를 실행했다. 새 BasePart/메시/텍스처0, FillBall4회. 사용자 Studio 수정 없음.

`before.png` / `after.png`는 같은 생성 월드에 후보만 추가한 동일 카메라·조명·상태의 원본 Studio 창 캡처다. 실제 게임 전투 카메라나 실기기 검증이 아니다. 디바이스 에뮬레이터 테두리가 있어도 실제 Samsung 기기 검증으로 취급하지 않는다. 카메라는 results.json에 보존했다. 첫 카메라는 도구 복원으로 하늘을 봐서 폐기 후 지연 Scriptable 설정으로 다시 캡처했다.

2개 능선 전부 Bounds.region/connection 예약 밖, 지형 상면 Rock 244.20/251.27stud 확인. [navigation.luau](navigation.luau) 엔진 검사: HG7장·105목표·4749표본·6연결에서 차단/지면누락/서버 위치보정 호출/안내/작은단차0. 첫 실행은 EC범위4를 남겨 존재하지 않는 월드를 조회해 실패, HG범위5로 고쳐 재실행한 결과다. 실제 Play·Easy·전투/회피·카메라 충돌·스트리밍·다인·기기·미술수용은 미검증. G5는 닫지 않는다.

## 다음 담당

MAP/ART: 외곽 구형 언덕 추가를 확대하지 않는다. HG-05 장치/관문/왕릉의 실제 좌표와 전투 예약을 한 도면에 겹쳐, 플레이 공간 안에 보이는 단차 있는 묘역 테라스와 방어 장치 기반부를 함께 재설계한다. 현 후보는 예약을 건드리지 않는 외곽 추가만으로 중심 평지를 개선할 수 없다는 비교 근거다. ENG/QA는 해당 설계의 정상/Easy·귀환·실제Play를 검증한다.

연구 근거는 [전용 기록](../../research/2026-11-17-hg05-defense-landscape.md). 빌드·VERSION·태그·게시 변경 없음.
