# 배틀 입장 지역 지연 생성

2026-11-17 · TLT-040/087/battle-loading · ENG · 소스/격리 Studio 검증, 미게시

## 변경과 근거

사용자는 배틀 입장이 느리다고 보고했고, 입장할 에픽만 먼저 생성하는 개선을 요청했다. 기존 `previewWorld`는 에픽 N 입장 전에 1~N 지역을 순서대로 만들었다. 현재는 승인된 목적지 에픽 하나만 생성한다. 원인이 확인된 초기화 결함 수정이며 게임성·보상·입장 자격은 변경하지 않는다. [Roblox 공식 성능 안내](https://create.roblox.com/docs/performance-optimization/improve)와 [스트리밍 설명](https://create.roblox.com/docs/workspace/streaming)을 2026-11-17 확인했다. 기존 StreamingEnabled와 ServerStorage 자산 배치를 유지한다.

- 이전 지역은 해금된 왕복 길 쪽으로 실제 이동하여 기존 스트리밍 반경384stud에 접근할 때 준비한다. 정지한 스폰/새 캐릭터/영웅 변경/큰 순간이동은 준비를 시작하지 않는다. 서버가 해당 난이도의 실제 이야기 접근 권한을 확인하며, 같은 지역의 동시 요청은 합쳐 처리한다.
- 다음 에픽을 여는 스토리 저장 확인 후 준비하는 기존 경로와 완료 지역 체크포인트의 필요 시 준비/재승인 경로는 유지한다. 이미 생성한 지역은 재사용하고 공통 world 테이블·기존 스폰/노드/지역을 보존한다.
- 준비 중인 지역은 스폰 오브젝트가 일부 생겨도 진입할 수 없다. 에픽 준비 및 왕복 길 BuildComplete를 확인하고 기존 안전 위치로 복귀시킨다. 미완성 길의 수학적 바닥을 안전 위치로 저장하지 않는다. 생성 실패는 기존 admission 실패 처리와 부분 지형 재사용 금지 동작을 유지한다.
- 현재 에픽의 장식/충돌/퀘스트는 완성된 뒤 입장한다. 이번에는 장식 생성 순서를 바꾸거나 캐릭터 준비·스트리밍·카메라·바닥 확인을 생략하지 않았다.

## 계측

서버 Workspace의 `TLTWorldBuildEpic`은 진행 중 에픽, `TLTEpic<N>BuildSeconds`는 지역 생성·창고·스토리 서비스 연결 시간을 기록한다. `[CampaignLoading]` 로그에도 남긴다. 실패 시 진행 중 에픽 값은 진단을 위해 남는다.

클라이언트 LocalPlayer의 `TLTArrivalDestinationSeconds`, `TLTArrivalAppearanceSeconds`, `TLTArrivalStreamedSeconds`, `TLTArrivalReadySeconds`는 로딩 덮개 설치부터 각 조건을 처음 관찰할 때까지의 누적 시간이다. 캐릭터가 교체되면 첫 관찰과 최종 Ready 사이에 재준비가 포함될 수 있다. 서버 시계와 합산하거나 Teleport 전체 시간으로 해석하지 않는다. 저장 데이터/서버 권한에 사용하지 않는 로컬 진단값이다.

## 검증

[측정 원본](measurements.json). 기준 소스는 `82cb6e22995775931b81f81bbdc627bb6741727f`, 동일 0.113.6 파일의 격리된 PlaceId=0 Studio 사본에서 시험했다. 원본 게시 창은 수정하지 않았다.

- 서로 다른 fresh Edit 사본에서 순차로 측정한 단일 샘플: 에픽5 입장용 기존1~5 생성 **32.099초 / 70,954인스턴스**, 에픽5 단독 **3.425초 / 10,570인스턴스**. 지역 생성 약89.3% 감소이며 네트워크·계정 읽기·클라이언트 다운로드·전체 입장 시간/P95를 측정한 수치가 아니다.
- 에픽5 생성 후4→3→2→1 역순 추가: 동일 world 테이블과 HG 스폰 유지, 최종 **70,954인스턴스**, 왕복4연결로 완성, 재생성으로 인스턴스가 증가하지 않음.
- 실제 Battle 역할 Play 서버의 `previewWorld('HG-01')` 경로: 에픽5만 준비, 스토리 Remote와 HG 창고 초기화 성공, 스크립트 오류0. 약3.312초. QA 전용 BindableFunction으로 내부 진입점을 호출했으므로 일반 계정 admission/실제 Teleport/캐릭터 입장 수용으로 간주하지 않는다. QA 훅은 종료 후 제거했고 저장소 소스에는 추가하지 않았다. PlaceId=0에서 자산 NetFail 경고가 있었으며 외형 다운로드 성공으로 보고하지 않는다.
- 전체545 Luau 소스 컴파일, 순수 Lua 접근 정책67·도착 덮개/계측326·완료 지역 체크포인트8,349·길 안내8,791검사 통과. 신규 엔진 테스트는 실제 admission 함수의 에픽1~5 단독 생성·동시 요청·실패와 왕복8방향의 미완성 길/지역 차단을 포함한다. 최종 엔진 검사 결과는 측정 원본에 기록한다.

재현: `lua tests/campaign-streaming.spec.lua`, `lua tests/arrival-loading.spec.lua`, `lua tests/checkpoint-travel.spec.lua`, `lua tests/campaign-navigation-route.spec.lua`. 엔진 검사는 최신 프로젝트 소스/자산이 적용된 **캠페인이 없는 격리 PlaceId=0 Edit**에서 `tests/campaign-loading-native.luau`를 실행한다. 일괄 생성은 task.spawn으로 실행하고 완료 결과를 확인한다. 운영 Place나 사용자 작업 중인 씬에서 실행하지 않는다.

## 미검증·다음 담당

빌드/Roblox 게시/태그는 이번 소스 개선 작업에서 수행하지 않았다. 게시 클라이언트의 실제 입장·재접속·4인 동시 이동·모바일 메모리·반복 측정/P95·물리 보행은 후속 QA이며 TLT-087/G7 완료로 표시하지 않는다. 서버 전체의 지역 생성 직렬화는 유지되므로 다른 지역을 생성 중인 서버에서는 새 요청이 기다릴 수 있다. 에픽1 자체 생성 시간과 캐릭터 자산 다운로드는 이번 최적화가 직접 줄이지 않는다. 다음 담당은 릴리스 및 실제 플레이 QA다.
