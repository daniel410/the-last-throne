# 로비·전투 줌아웃 확대

2026-11-09 · TLT-028/050/061/084 · ENG → QA · 0.93.2

사용자 요청에 따라 로비·전투 최대 카메라 거리를22→32studs(약45% 확대)로 변경했다. 최소6studs, 회전각22~72도, 구체 충돌/지면 보정, 사망/연출 카메라 권한은 유지한다. AdventureCamera와 서버 초기화, 단일 빌드/호환 프로젝트의 StarterPlayer 값을32로 맞춰 초기18studs와 클라이언트22studs의 불일치도 없앴다.

## 근거와 적용

기존 [카메라 조사](../../research/2026-10-30-grounded-deepwood.md)를 재사용했다. 2026-11-09 [Roblox 공식 StarterPlayer 문서](https://create.roblox.com/docs/reference/engine/classes/StarterPlayer#CameraMaxZoomDistance)의 거리 설정 경로를 재확인했다. [Diablo IV 개발자 설명(2024-03-21)](https://us.forums.blizzard.com/en/d4/t/camera-will-now-zoom-out/154838/45)은 Standard/Far 선택과 확대 시 표시량·성능 검증 필요성을 설명한다. 현행 패치 수치로 취급하지 않는다. 본 게임은 자유 줌을 유지해 최대값만 확대하며 별도 메뉴는 추가하지 않는다. 최소 실험은32studs 끝점·가까운 줌·벽 충돌·회전 검사이며, 실기기 가독성과 성능은 후속 수용 항목이다.

## 검증

- Studio `The Last Throne`(placeId70829337938054) Edit에서 카메라/서버의 해당 줄만 변경하고 StarterPlayer 최대32·최소6을 확인했다.
- `tests/adventure-camera-zoom-native.luau`를 Edit에 맞게 실행: 격리 가드를 IsEdit로 교체하고 모듈 복제본을 require하여 캐시 영향을 배제했다. 편집 상태에 잔류 Player1개가 있어 원본 가드의 첫 실행은 중단됐으며, 최종10검사 모두 통과(상태별 최대값·최소값·거리32·가까운 줌·벽 충돌·피치). 원격 임시 지형과 모듈 복제본은 제거했다.
- 기존 Deepwood 통합 테스트의 최대거리 기대를32로 갱신했으나 전체 월드 테스트는 재실행하지 않았다. 새 테스트 파일은 추가하지 않았다.
- 빌드 결과·고정 소스·산출물 SHA256은 build.json에 기록한다.

미검증: 실제 휠/핀치/패드 끝점, 모든 지역의 차폐, 실기기 FPS/가독성, 게시 클라이언트. 다음 담당 QA는 새 빌드로 확인한다. 다른 Studio Play 세션은 재시작/변경하지 않았다. Roblox 미게시·릴리스 태그 없음. 부모 티켓 완료로 처리하지 않는다. 기존 미커밋 자산/다른 UI 작업은 포함하지 않는다.
