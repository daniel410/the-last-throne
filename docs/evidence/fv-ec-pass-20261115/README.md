# TLT-062/063 · FV-07 → EC-01 낮은 연결 능선

2026-11-15. 맵 구현/환경 아트/환경3D/리서치 순차 수행. 구현 및 로컬 Studio 검증, G5 미완료.

최종 통합 빌드 **0.110.31**, 소스 **b1478977fc6c3be6bb6d443489d9a513b823a6e0**. `build-integrated.json`이 최종 입력 기록이며 `create-integrated.luau`로 소스 일치·전체 구문·장면 생성을 검증했다. 동시 작업 f35debee의 스토리 연결 바닥 수정을 병합했다. 이전 후보0.110.30/df290e1da2fd826e755ce4a91e1bed1803454747은 당시 증거로 보존한다. `build-final.json`에 입력·출력 SHA256/LFS 검증 기록. 0.110.29는 기초 연결 전 후보이며 `build.json`으로 보존한다. `rejected-high.jpg`는 baseline Studio에 주입한 높은 초기 시안으로 최종 빌드가 아니다.

[스토리 제작표·리서치·원본/파생 판단](../../research/2026-11-15-fv-ec-transition.md). OverlandTransitionBanks 신규 모듈, EpicWorldArt29에서 해당 연결부에만 호출. Native Rock 능선4·지하 받침4, 추가파트0. 거울 조사 확장 구역 예약으로2후보 제외. 기존 중앙96stud JourneyPass/서버Bounds/퀘스트/보상/저장과 TD 원본은 보존했다. 지형이 길 좌우 바깥으로 확장됐지만 새 통행 권한으로 취급하지 않는다.

## 재현 및 결과

RobloxStudio 바이너리 `-localPlaceFile <build> -task EditFile`로 로컬 PlaceId0/no players 장면을 연다. BaseScript를 끄고 Baseplate를 제거한 다음 `_G.PassWorld=require(game.ServerScriptService.Server.World.CampaignWorld).create()`를 실행한다. `source-check.luau`로 소스 일치, 전체 LuaSourceContainer를 loadstring으로 구문 검사했다.

카메라: CFrame.lookAt((-730,245,-11050),(-953,124,-11190)), Focus=(-953,124,-11190), FOV70, 기본 주간 조명. 별도 fresh Edit에서 before=0.110.28, after-integrated=0.110.31 (after.jpg는0.110.30 후보) 촬영. 같은 좌표의 조감이며 게임 플레이/실제 입력 카메라가 아니다. 장면 생성의 다른 배경 비결정성은 지형 효과로 해석하지 않는다.

![이전](before.jpg)
![최종 통합 이후](after-integrated.jpg)

1. `check.luau`: 길의 종방향4stud/횡방향4stud, 중심±44stud 23열, 총2093표본. 수직바닥 누락/기준높이0.6초과/3×5×3 Blockcast 차단 모두0. 전체96stud 중 바깥 가장자리4stud씩과 표본 사이는 연속 검증이 아니다.
2. `routes.luau`: 기존 스토리 교전 points 경로, GW/FV/EC/HG 총496목표24518표본. 차단/바닥/서버보정/안내/단차 모두0. 최종 통합에서 `easy-routes.luau`로 Easy worldPoints도529목표25427표본을 검사해 같은 실패0을 확인했다.
3. `walk.luau`: 검사/캡처 이후 Run, 실제 R15 두 개가 중심±12stud에서357stud 길을 반대 방향으로 보행. 통합판 각11.016/11.017초 도착, 점프0. 서버 게이트/보정 로직은 이 물리보행에 붙이지 않았으므로 보정0이라는 별도 주장은 하지 않는다. 이어 Stop. `results-integrated.json`이 최종 통합판 엔진 반환값이며 `results.json`은0.110.30 후보 기록이다.

미검증: 플레이어 입력·전투/회피·낮은 시점 카메라/카메라 충돌·전체 폭 비스듬한 실제 횡단·재접속/실제 스트리밍·게시 클라이언트·기기/다인 성능·미술 수용. 배경 평지/다른 지역 하늘 공백과 연결부 눈 바닥은 여전히 남아 있다. 게시/태그 없음.

다음 담당 DES/QA: 실제 로컬 플레이와 게시/기기 수용에서 능선이 목표와 전투 예고를 가리지 않는지 확인한다. 구현 커밋과 마감 증거는 작업브랜치 및 origin/main에 반영한다.
