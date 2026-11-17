# TLT-063 · EC-03 광산 작업 공간

2026-11-17. 제작 스킬의 리서치·맵 구현·환경 아트·환경 모델링 역할을 순차 수행했다. 소스 기준 813e0d65391d133a68576f31748a862f033b250d. 게임 빌드/버전/게시/태그 없음. G5 미완료.

## 제작표와 변경

| 에픽/스토리 | 원천·사건 | 공간 표현 | 상태·플레이 목적 |
| --- | --- | --- | --- |
| Ember Caldera / EC-03 | CampaignContent EC-03, StoryPropAssignments supports/MineBrace, RegionalConceptProfiles BracedMineHead. 광산 지지 후 광부와 Orik 구조 | 기존 입구 앞 z=10에 보강 틀, 기존 z=-2 입구와 종방향 보로 연결. 운반 궤도를 둘러싼 12stud 깊이 작업 공간 | 영구 보강 시설이다. 개인 구조 완료를 표현하지 않는다. 중앙 개방부와 기존 목표·저장·보상 유지 |

RegionalArchitecture v9. 기초2/기둥2/종방향 보2/결속띠4/가로 보1, 총11파트 추가로 56→67파트. 새 메시·텍스처·광원·루프 없음. 기존 Template/TD 원본은 유지한 저장소 자체 네이티브 파생이다. Blender를 사용하지 않았다. 실제 입구와 먼 supports/miners 목표 사이의 공간 연결은 아직 해결하지 않았으며 이번 변경을 그 수용 완료로 간주하지 않는다.

## 검증과 화면

`/tmp/tlt-ec03-apron-final.rbxlx`의 격리 복사본을 자체 Studio PID58581/Edit/PlaceId0/플레이어0에서 열고 BaseScript를 비활성화했다. [verify.luau](verify.luau)는 후보 소스를 포함한 복제 모듈을 실제 Architecture.build로 생성한다. 구문·11파트 anchored/비충돌/query/touch off·양수 크기·기존56파트의 이름/Size/CFrame/Material/Color/CanCollide·전체 bbox 위치/크기 불변 통과. [결과](results.json). 전체 최신 빌드나 이동 sweep은 아니다.

[비교 화면](comparison.jpg)은 왼쪽 기존, 오른쪽 후보다. 동일 Slate 검사면과 ClockTime12/Brightness2/Ambient155, 카메라(-8,190,73)→(-15,159,-2)에서 촬영했다. 같은 화면의 서로 다른 표시 위치이며 실제 EC 조명/게임 카메라는 아니다. 첫 촬영은 Studio 카메라 반영 실패로 제외하고 screen_capture의 명시적 카메라로 재촬영했다. 장면의 입체적 보강 공간은 확인했지만 개인 NPC/HUD 가독성은 판단하지 않았다.

미검증: 최신 월드 실제 배치·Play 이동/전투/회피·supports→miners 개인 상태·게시 클라이언트·기기/스트리밍·1~4인+AI 성능·미술 수용. 다음 담당 ENG/ART/QA는 고정 빌드의 실제 Play에서 supports→miners를 대조해야 한다. 작은 소품 증량으로 이 수용을 대신하지 않는다.

## 리서치

[조사 기록](../../research/2026-11-17-ec03-working-bay.md). 기존 공식 사례를 재확인했고 아래 적용은 제작 해석이다. 다른 게임의 자산/규칙을 가져오지 않았다.
