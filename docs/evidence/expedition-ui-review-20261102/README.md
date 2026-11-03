# 난이도 설정·배틀 진입 UI 검증 증거

2026-11-02 · TLT-028/029/041/050/052/061/073/084 · DES/ENG 리뷰 → ENG 수정 → QA

검토 기준 소스 `b9525cee41b950cf8741257dd68892bf28c2048a`의 ExpeditionView/HeroMenuChrome/TDInventoryTheme/LobbyPanelLayout 및 현재 작업 파일의 관련 ExpeditionService/LobbyCommerce다. 미커밋 TD 이동 변경은 수정/커밋하지 않았다. 게임 코드 변경·빌드·게시를 하지 않은 리뷰다.

## 실행 조건

- `python3 tools/review-expedition-ui.py`: 저장소의 실제 UI 모듈과 의존 소스를 묶어 `builds/expedition-ui-review.luau`를 생성한다. 기존 난이도 runner 생성기를 데이터 수집에 재사용하며 live 서비스는 실행하지 않는다.
- 생성 Luau를 Studio `0fc2283e-f042-4c81-8750-0422aee83559` / The Last Throne Battles / Edit에서 실행한다. fixture LocalPlayer/서버 snapshot과 실제 Roblox GUI 인스턴스를 사용한다. 첫 Parent는 CoreGui로 측정했으며, 화면 캡처에는 임시 ScreenGui만 StarterGui로 이동했다. live RemoteEvent·계정·게임플레이·Teleport는 호출하지 않았다.
- 루트1108×707 →844×390 →1108×707 파티 상태로 변경해 `AbsoluteSize`, `AbsoluteCanvasSize`, 버튼 위치/Active를 수집했다. 모바일은 **고정844×390 컨테이너**이며 실제 기기나 Studio Device Simulator 실행이 아니다. screenshot은 도구의1692×1080 출력으로 확대된 원본이며 모바일 캔버스 밖의 바닥은 테스트 컨테이너 밖이다.
- `metrics.json`: 원본 MCP 측정 결과. 데스크톱/모바일 panel800×510/800×366, scroll768×332/768×188, Solo y426/h48. 파티4인·Hell 잠김·전원 미준비 snapshot에서는 Launch y882/h48/Active=true다.
- `desktop.jpg`, `mobile-landscape.jpg`, `party.jpg`: 실제 ExpeditionView 렌더, 원본 TD 버튼 아틀라스 로딩 확인. 새 시안이나 최종 수용 미리보기가 아니다.
- TD `StatusWindowArtAssets`와 현재 공유 사본 SHA256 모두 `c6927fe3f15902818046f72f9d902e6aacfb38e9c6c5bddce4578dac9238163a`. `shellDetails` 이미지 `rbxassetid://126012242626142`, Studio `IsLoaded=true`.
- 종료 시 `_G.TLTExpeditionReview.gui:Destroy()`, `.signal:Destroy()`, `_G.TLTExpeditionReview=nil` 실행. StarterGui/CoreGui에 임시 GUI가 없는 것을 확인했다. 기존 사용자 Studio는 종료하지 않았으며 Play도 시작하지 않았다.

## 한계

실제 사용자 입력/연속 탭, 패드 포커스, live 파티 권한/계정, 서버 이동·네트워크 지연, safe area/기기 글자 크기는 미검증이다. 0.35초 제한의 무응답 경로는 코드 검토로 확인했고 live 입력으로 재현하지 않았다. 파티 fixture는 미준비/레벨 미달을 의도적으로 포함한 UI 상태이며 실제4인 접속 결과가 아니다. 권한 우회나 입장 제한 무효를 주장하지 않는다.

결과와 수정 우선순위는 [리뷰](../../reviews/expedition-ui-look-and-feel-review-2026-11-02.md)에 기록한다.
