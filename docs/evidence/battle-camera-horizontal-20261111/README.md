# 배틀 카메라 수평 시선 복구

2026-11-11 · TLT-005/061/084 · ENG → QA · 소스 수정·격리 Studio 검사 통과

사용자는 배틀 시선이 머리 위 각도에서 멈추는 문제를 보고하고 수평까지 내릴 수 있도록 요청했다. `AdventureCamera.constrain`의 최소 피치22도가 원인이므로0도로 변경했다. 최대72도, 줌6~32studs, 지면·구체 충돌 보정은 유지한다. 이 보정은 기존과 같이 Tutorial 단계이면서 Training 경로가 아닌 생존 배틀 카메라에 적용된다. 명확한 제한값 결함 수정으로 별도 게임성 리서치는 수행하지 않았다.

변경: `src/client/AdventureCamera.luau`, 기존 `tests/adventure-camera-zoom-native.luau`, 이 검증 기록. 기존 미커밋 변경은 포함하지 않는다.

## 검증 조건과 결과

- 별도 로컬 빈 Place(`/tmp/tlt-audio-empty.rbxlx`)에서 `run-in-roblox --place /tmp/tlt-audio-empty.rbxlx --script /tmp/tlt-horizontal-camera-native.luau` 실행. 실제 카메라 소스와 실제 Shared 의존 모듈21개를 임시 ModuleScript로 구성하고 기존 테스트의 카메라 경로만 격리 경로로 치환했다. 기존 Edit/Play 세션에는 적용하지 않았다.
- 결과: `{"failures":[],"kind":"ADVENTURE_CAMERA_ZOOM_NATIVE","pass":true,"checks":15}`. 단계별 줌 한계, 가까운 줌/최대 거리, 벽 충돌, 아래쪽 입력의 수평 제한, 거리6/18/32의 수평 시선, 위쪽72도 제한, 수평에서 벽 충돌을 통과했다.
- 최초 실행은 실행기의 빈 Place 인수 필수 제약으로 중단, 다음 실행은 격리 의존 모듈 누락으로 중단됐다. 빈 Place를 명시하고 동적 로더 의존까지 포함한 최종 실행이 위 결과다. 제품 코드 결함을 검사 실패로 숨기지 않았다.
- `git diff --check` 통과.

미검증: 실제 마우스/터치/패드 입력, 모든 지역 지면·차폐, 게시 클라이언트·실기기·사용자 수용. 빌드·버전 증가·Roblox 게시·릴리스 태그는 수행하지 않았다. TLT 부모 티켓/게이트 완료로 처리하지 않는다.

다음 담당: QA. 다음 빌드에서 배틀에 진입해 시선이 수평까지 내려가는지, 경사면·벽 근처 충돌과 각 입력 장치를 확인한다.
