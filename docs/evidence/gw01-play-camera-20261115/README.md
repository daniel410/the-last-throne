# TLT-073 / GW-01 로컬 Play 수용 후속

2026-11-15 · QA·엔지니어 순차 수행. 기존 TLT-065 맵 증거에서 인계받은 GW-01 검증이며 티켓/G5 완료가 아니다.

## 확인한 문제와 변경

0.110.8의 GW-01 실제 Play 화면에서 미니맵은 Lantern Trail, 조명은 Gloamwood인데 상단 제목은 DEEPWOOD / THE BLACK ROOTS였다. K0Hud.setStory가 Frozen Vale/Ember Caldera만 분기하고 나머지 지역을 Deepwood로 처리했다.

0.110.9 / 66ca93409379c5788229153b75996894d893bc27에서 StoryHeading.resolve를 연결했다. Gloamwood와 Haunted Graveyard를 포함한 지역명과 부제는 기존 CampaignContent.epics 정본을 사용한다. Deepwood 기존 부제·훈련/알 수 없는 지역 fallback은 유지한다. 새 게임 문구/서사·맵 기하·진행·보상·TD 원본 변경 없음. 원인이 명확한 결함이므로 별도 신규 게임성 리서치는 하지 않았다.

## 환경과 재현

[고정 빌드](build.json), [fixture](fixed-fixture.json), [입력 해시](inputs.json). macOS Roblox Studio 0.747.0.7471481, PlaceId0, 로컬 1인 Play의 실제 Client/Server. InventoryService의 기존 Studio 메모리 어댑터를 사용한다. QA 기사 Lv80, Deepwood 선행/GW-01 maeve·trail만 완료한 임시 상태이며 정상 성장·전투 완주를 입증하지 않는다. 운영 DataStore/TD/게시·Teleport 검증 아님.

`python3 tools/prepare-gw01-play-fixture.py --artifact builds/0.110.9/TheLastThrone-0.110.9.rbxlx --output /tmp/tlt-gw01-play-fixed.rbxlx --record <record.json>`로 격리 파일을 만든다. 입력 빌드를 덮어쓰지 않으며 수정된 소스가 InventoryService의 Studio/PlaceId0 한정 영웅 seed 하나뿐인지 검사한다. 별도 재생성 SHA256이 같음을 확인했다. 게임 빌드는 재빌드하지 않았다.

격리 파일을 Play한 뒤 tests/gw01-play-camera.client.luau를 Client execute_luau에 **직접 코드로** 실행한다. 테스트는 Configure/Solo 실제 remote 입장, 실제 Humanoid 보행, 실제 HUD, Custom 카메라를 사용한다. 자동 보행 중 PlayerModule controls만 잠시 비활성화하며 종료/실패에 복구한다. 시작/도착 순간이동이나 WalkSpeed 변경 없음. fixture 준비 외 생산 코드 주입 없음.

## 결과

[0.110.8 결과](baseline-results.json), [0.110.9 결과](results.json), [지역 제목12검사](heading.json).

| Q-ID | 조건·입력 | 실제 결과 | 판정 |
| --- | --- | --- | --- |
| GW-P01 | 실제 Configure/Solo, Easy GW-01, Studio session | 실제 기사/서버 스토리/HUD 로드 | Pass, 로컬 fixture 한정 |
| GW-P02 | 스폰→exp_1 step1 자동 Humanoid 보행 | 수정 전20.381초, 후20.434초 도착. 후153표본, 점프0, 표본간15stud 초과 위치 불연속0 | Pass. 불연속0은 서버 보정 callback을 계측한 값은 아님 |
| GW-P03 | 실제 runtime 상단 제목 | 수정 후 GLOAMWOOD / ONE BRAVE STEP | Pass. HG는 정본 함수 검사이며 실제 HG 입장 아님 |
| GW-P04 | 네 방향 카메라 CFrame을 설정한 뒤 실제 Custom 제어/AdventureCamera에 맡김 | 실제 거리12.5stud, 화면 안 발자국 중심1/20/20/2개 | 제한적 Pass. 화면 투영 수이며 가림·인지율 측정 아님. 요청 거리32는 기본 Roblox 줌이12.5로 유지했으므로32 회전 실험으로 보고하지 않음 |
| GW-P05 | 실제 도구 mouse scrollDown6 / scrollUp12 | Custom 거리31.9995 / 6.00008stud | Pass, 로컬 휠 줌 한정 |
| GW-P06 | 실제 F키800ms | Evidence0/3→1/3, 다음 단서 문구 갱신. 전후 빌드 모두 확인 | Pass, 조사1개 한정 |
| GW-P07 | 실제 R키 | K0DodgeSeq0→1, 복귀 Idle, HP1485 유지 | Pass, 비전투 단회 회피 한정 |
| GW-P08 | 도구 RMB240px/20px 드래그 | 실제 방향변화0도 | Not Verified. 합성 절대좌표 입력의 한계 가능성; 원인 미확정. 실제 마우스 회전 결함/통과로 단정하지 않음 |

results.json의 pass는 자동 입장/보행/제목/스크립트 회전 제한 검사 범위이며 GW-P08이나 전체 품질 게이트의 통과를 뜻하지 않는다. 상호작용/회피는 후속 별도 assertion을 실행했다.

[이전 Play 화면](before.jpg) / [수정 Play 화면](after.jpg): 서로 다른0.110.8/0.110.9 세션의 실제 HUD/캐릭터 화면이며 같은 카메라 A/B가 아니다. 수정 화면은 실제32stud 줌, 조사1/3·회피 후다. 주변 지형 차이나 축척 차이를 이번 HUD 변경 효과로 해석하지 않는다. 발자국 방향은 실제 밤 게임 화면에도 보이지만 가장 가까운 기본 시야에서는 영웅/화면 하단에 가려질 수 있다. 최종 가독성 수용은 후속이다.

## 실패·관측·인계

초기 fixture는 maeve 대화의 confirmed step 누락으로 ActivityIncomplete였다. [기록](initial-fixture-failure.json)과 최초 fixture를 보존하고 수정했다. 최신 클라이언트에서 loadstring 실행은 차단되어 첫 하네스 시작만 실패했다. 직접 Luau 실행으로 교정했다. 둘 다 게임 결함/검증 통과로 숨기지 않았다.

[수정 콘솔](console.log), [이전 콘솔](baseline-console.log): 양쪽에 같은13개 asset ID 경고가 있다(Traveler Coat 텍스처82286199708395, 오디오 유형 불일치 등). 이번 변경으로 해결하지 않았다. 수정 콘솔의 loadstring 오류는 위 테스트 실행 시도다. 영웅 외형·음향 전체 수용은 미검증이다.

실제 게시 클라이언트/실기기/스트리밍·다인 성능, 전투 중 판독·연속 회피·사용자 미술 수용은 Not Run. 실제 마우스 orbit도 Not Verified. 다음 DES/QA는 사람의 마우스/터치/패드에서 회전과 가림을 확인한다. 맵 담당은 실제 화면에 남는 큰 평지·직선 지면 연결을 다른 대표 구간에서 개선한다. 기존 발자국/수목/능선 증량이나 동일 로컬 보행만 반복하지 않는다. Roblox 게시·릴리스 태그 없음.

마감 통합: 동시 작업의 main 084eadf1(오디오/로딩 변경)을 일반 병합으로 보존했다. 해당 변경은 위 0.110.9 검증 입력66ca9340 이후이며, 통합 main 전체의 새 빌드/오디오 회귀를 수행한 것으로 보고하지 않는다. 이번 검증 대상 K0Hud/StoryHeading은 병합 전후 동일하다. 소유 QA Studio3개는 Play Stop·SIGTERM 후 남아 있어 기록 보존 뒤 해당 임시 파일 프로세스만 SIGKILL로 종료했다. 다른 Studio는 종료하지 않았다.
