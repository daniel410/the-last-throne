# 서버 이동 로딩 배경 · 2026-10-31

- 작업: 기존 `loading-screens-v1` 세 이미지를 Roblox 이미지로 등록하고 로비·전투 클라이언트에서 이동 전에 `SetTeleportGui`로 로딩 화면을 등록한다. 전투 Place 하나가 세 지역을 제공하므로 이동할 때 실행 중인 지역을 주장하지 않고 세 이미지를 무작위로 선택한다. 영어 `LOADING...`과 어두운 배경을 제공한다. TD 별도 Experience 이동은 Roblox 제한상 이 GUI 적용 대상이 아니다.
- 이미지 ID: Deepwood `125359077730192`, Frozen Vale `119442635735506`, Ember Caldera `125067552170259`. 이미지 원본·해시는 `assets/marketing/loading-screens-v1/README.md` 참조. 이미지 등록 계정은 현재 Studio 사용자다.
- 근거: [Roblox 이동 가이드](https://create.roblox.com/docs/projects/teleport) 및 [TeleportService](https://create.roblox.com/docs/reference/engine/classes/TeleportService)는 서버 호출 전에 클라이언트에서 GUI를 설정하고 실제 게시된 클라이언트에서 테스트하도록 안내한다. 기존 `docs/research/2026-10-30-lobby-economy-and-expeditions.md`의 이동 경로와 복구 계약을 유지한다.
- 검증: `git diff --check`, Rojo sourcemap 생성 성공. Studio 클라이언트에서 동일한 GUI 생성 코드로 세 ID·Crop·영문 문구를 확인했다. `ContentProvider:PreloadAsync` 최초 시도는 세 이미지 모두 실패했으나 이후 재시도에서 세 이미지 모두 `Success`를 반환했다. 네트워크·권한·심사 상태는 다른 환경에서 달라질 수 있다.
- 미검증: 실제 게시된 두 Place 간 이동·재시도·다인·모바일 화면·대상 Experience의 이미지 권한. Studio에서 Teleport 자체는 검증할 수 없다. 빌드/게시하지 않았으며 다음 담당은 엔지니어링·QA다.
