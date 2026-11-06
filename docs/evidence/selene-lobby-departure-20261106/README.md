# Selene 로비 동행·모험 자동 합류

2026-11-06 · TLT-016/028/043/057/061/072/084 · ENG → QA · 0.79.0 · 로컬 구현·미게시.

## 사용자 지시와 변경

사용자는 “로비에서부터 쫒아와야지”라고 요청했다. 지원권을 샀는데 다시 Deepwood 캠프를 찾아야 하는 사용 흐름을 바꾼다. 영입 해금한 영웅이 로비에서 지원권을 구매하면 기존 계정 거래에서 출발 선택 `supportPasses.departure`를 함께 저장하고, 기존에 산 credits도 로비의 선택 영웅으로 서버 전용 Prepare를 거쳐 준비한다. 최초 무료 체험이 남은 경우도 로비부터 동행할 수 있다. 과거 캠프 초대 의무보다 이번 사용자 지시가 우선한다.

로비에서는 TD 원본 파생의 기존 SeleneRepairedModels·SeleneVisual·SeleneFollow·클라이언트 스킨 모션을 그대로 재사용해 플레이어별 외형 동행1개를 만든다. 로비 외형에는 치유/보호/credits 소비가 없고, 계정 미확인/사망/영웅 교체/출발/퇴장 때 모델을 정리한다. 재접속도 계정에 저장된 선택으로 복구한다. NPC 상점의 Selene는 구매 창 진입점으로 유지한다. 기존 TD 상세창에 출발 준비 상태와 영어 이용 안내를 적용하며 새 UI 프레임/이미지는 만들지 않는다.

실제 모험에서는 확인된 플레이어/영웅/현재 메인스토리 scope·파티 동료 슬롯을 검사한 다음 Activate를 저장한다. 로비에서 저장한 출발 선택이 있으면 캠프 접근을 요구하지 않는다. 최초 무료 체험을 먼저 쓰며, 이후 한스토리권1개만 소비한다. 성공한 활성화에서 출발 선택을 지워 같은 모험의 다음 스토리로 자동 유료 갱신하지 않는다.4인도 기존 파티 전체AI1명이며 나머지의 선택과 이용권은 보존한다. 아직 도착/리스폰 컨텍스트가 없는 플레이어가 다른 출발 후보를 막지 않도록 확인된 컨텍스트만 자동 시작 후보에 포함한다. 사이드 원정 진입에는 자동으로 다음 메인 지원권을 소비하지 않는다.

캠프의 기존 휴식/재초대·동일 지원 스토리의 사망/재접속 무추가소비·메인 완료/Return to Lobby 종료·미사용권 보존·영입 해금·가격은 유지한다. Prepare/Activate는 클라이언트 RemoteEvent 액션으로 공개하지 않고 기존 서버 권위 InventoryService/AccountStore 경로를 사용한다. 저장불명은 같은 요청ID로 복구하고 성공 확인 전에는 로비 모델/지원권을 확정하지 않는다. 기존 스키마1에 선택형 필드를 추가하며 원본 진행/지갑을 초기화하지 않는다.

[제품 사양](../../companions-and-support.md) · [사용자 결정](../../decisions.md) · [비교 근거와 적용 범위](../../research/2026-11-06-selene-lobby-departure.md).

## 검증

- `lua tests/selene-departure.spec.lua`:26검사 PASS. 구매→로비선택→새 원정 scope에서 캠프 없이1회 소비, 기존권 준비/영입 차단/소유 검사/무료 체험/메인 완료 비갱신/사이드 소비 방지/실제 AccountStore 저장불명 재요청을 검사한다.
- 기존 회귀: support-passes30·selene-trial28·story-continuation1017·supporter-info45·selene-recruitment23·story-completion356·inventory271·story-lobby-resume32, 새26을 포함해 **1,828검사 PASS**. [명령과 결과](rules.log).
- `/private/tmp/td233-luau/luau-compile`: 런타임8개·네이티브 검사2개 컴파일 PASS. `git diff --check` PASS.
- `/tmp/tlt-selene-departure-candidate.rbxlx` 후보에서 `run-in-roblox --script tests/selene-departure-native.luau`: 실제 TD 모델·접지 이동·로비 서비스·전투 동료 서비스·지원권 reducer **20검사 PASS**.4개 로비 모델/기존권 자동 준비/움직인 영웅 추적/계정 미확인·사망·출발 정리/캠프에서1,000stud 떨어진 출발/4인 중1명 소비·다른3명 보존/완료 후 비갱신 포함. [로그](candidate-native.log). 플레이어·계정·치유 콜백은 모의이며 실제 네트워크/치유 전투 수용이 아니다.
- 별도 InventoryService 네이티브 검사의 첫 시도는 Studio 시작 시간 초과로 실행되지 않았다. [시작 실패](service-startup.log). 동일 명령 재시도도 같은 시작 시간 초과였으며 service-native.log에 기록했다. 고정 빌드 결과는 아래 마감 기록에 추가한다. 이 실패를 코드 검사 통과로 계산하지 않는다.

## 미검증과 다음 담당

실계정 구매 화면→로비 이동→게시된 각 테스트 Experience Teleport→동행의 전체 사용자 조작, live DataStore/실제 네트워크 단절, PC/모바일/패드·로비 다인 모델 비용·4인+AI 성능·최종 사용자 수용은 미검증이다. QA가0.79.0에서 이를 확인한다. 기존203785492의 asset type 경고는 후보 로그에도 남으며 이번 변경의 자산 업로드는 없다. TD 운영/기존 사용자 모션·첨부·미추적 증거는 변경 범위에서 제외한다. 부모 티켓은 In Progress, Roblox 게시/릴리스 태그는 수행하지 않는다.

## 빌드·Git 마감

입력 소스 `53ba9d6fc1a5a9350c20bffbaf5c7209904f63e9`와 VERSION0.79.0을 커밋·origin/main 푸시하고 `git ls-remote origin refs/heads/main`의 동일 SHA를 확인했다. `python3 tools/build-game.py --source HEAD --record docs/evidence/selene-lobby-departure-20261106/build.json`으로 단일 Lobby/Battle 산출물 빌드 성공. [정확한 입력·명령·해시](build.json). 새 LFS 자산은 없으며 기존 미커밋 모델 변경은 빌드 입력에 포함하지 않았다.

산출물 `builds/0.79.0/TheLastThrone-0.79.0.rbxlx`, SHA-256 `ddb7fd02b01481565822e93418552052b5bb2cfdb3df679f6b8adee74c4a1634`를 실제 바이트로 재확인했다. `python3 tests/single-build.spec.py --artifact builds/0.79.0/TheLastThrone-0.79.0.rbxlx`: role10·arrival-loading108·마운트/실제 산출물 일치 PASS. 고정본 자체의 엔진 실행은 미검증이며 앞선20검사는 후보에서 얻은 증거다. 게시/태그는 수행하지 않았다. 이 기록은 후속 증거 커밋으로 보존한다.
