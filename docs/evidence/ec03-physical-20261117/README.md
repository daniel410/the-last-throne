# TLT-063 · 광산 시설 접합부 물리 보행 감사

2026-11-17. 맵 구현·환경 아트·환경 모델링 역할 순차 수행. 상태: QA 증거 보강, 맵 형상 변경 없음. G5와 사용자 최고 품질 목표 미완료.

## 범위와 결과

이전 진입로 후보의 Slope 거부를 실제 통행 장애로 확대 해석하지 않도록 검증했다. 광산 궤도 끝 `(372.609,142,-12494.940)`에서 ApproachPosition `(242.150,140,-12644.400)`까지 약198.398stud 직선의 중앙/좌우3stud를 약0.496stud 간격으로 검사했다. 1,203표본 모두 지면을 검출했다. 중앙선 접합은 Terrain에서 BasaltGround로 완만하게 이어지며 중앙 인접 높이차 최댓값은 results.json으로 재계산할 수 있다. 폭 전체 연속 지형을 증명하는 검사는 아니다.

같은 장면에서 R15 두 기체를 생성하고 Run 물리에서 WalkSpeed16, 점프 비활성, 직접 MoveTo로 왕복했다. 출발 이후 피벗 이동/텔레포트 없이 출구 방향12.316초·귀환12.319초, 목표 수평거리1.546/1.574stud로 도착했다. 점프0·6초 정지 없음. 스토리 접근 권한 게이트는 호출하지 않았다. 게임 영웅의 교정0이나 정상 퀘스트 수행으로 보고하지 않는다.

이 장면에서는 통행 장애가 재현되지 않았다. 따라서 접합부를 평탄화하거나 경사 허용치를 바꾸지 않았다. 진입로 후보의 엄격한 시각 접지 기준 실패는 이전 기록 그대로 유효하며, 물리 보행 통과와 별개다.

## 재현과 입력

[검사 소스](../../../tools/qa/ec03-facility-walk.luau), [측정·이동 궤적](results.json), [입력 해시](inputs.json). 기존 ec03-access QA 사본의 `_G.AccessWorld`와 `_G.AccessStatus`를 사용한다. PlaceId0/플레이어0을 강제하며 BaseScript 비활성인 격리 장면에서만 실행한다. 검사 후 RunService:Stop 실행. 저장하지 않았다. 사용자 0.111.33 Studio는 조작하지 않았다.

이 사본은 이전 shoulder QA에 RegionalArchitecture v9와 진입로 후보를 overlay한 장면이다. 최신 소스 전체 빌드가 아니다. 실제 실행본과 저장본의 차이는 결과 assert 추가뿐이며 두 해시를 남겼다. JSON 완결·양방향 도착·지면401×3표본은 Python으로 재검사했다. 최종 assert를 추가한 전체 스크립트는 엔진 재실행하지 않았다.

## 리서치와 다음 제작 판단

2026-11-17 공식 본문 재확인: [Diablo IV 개발판2022 환경 아트](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)는 재료·건축·지역 역사에 의한 설득력, [WoW Retail The War Within](https://news.blizzard.com/en-us/article/24125258/explore-the-zones-and-dungeons-of-the-war-within)은 지하 지역과 시설, [Lost Ark 글로벌 Elgacia2023](https://www.playlostark.com/en-gb/news/articles/elgacia-release-notes)는 도시·정원·성산의 장소 구분을 설명한다. 현행 패치 수치 비교가 아니다.

제작 해석: 지금 병목은 입구 통행 자체로 확정할 수 없으며 시설과 구조 사건의 시각·플레이 연결을 실제 영웅 시점에서 먼저 확인해야 한다. 비용은 임시 R15 2체와 검사뿐, 영구 자산/파트 추가0. 외부 자산 수입 없음. 다음 ENG/ART/QA는 최신 고정 빌드 실제 Play에서 supports→worm→miners를 영웅/HUD/개인 투영과 함께 대조하고, 그 결과로 대표 지형 재구성 범위를 정한다. 기존 입구 소품 증량이나 근거 없는 접합 수정으로 대체하지 않는다.

미검증: 실제 영웅·공격·카메라/HUD·개인 구조 상태·서버 권한/진도·저장·게시 클라이언트·실기기·멀티·스트리밍·성능·사용자 미술 수용. 새 빌드/버전/태그/Roblox 게시 없음.
