# Selene 외형 깨짐·동작 교정

TLT-016/057/061/072/084 · 2026-11-03 · 로컬0.63.1 · 미게시

기존6분할 모델의 후드 방향/얼굴·몸통 접합·떨어진 소매/발 조각을 실제 Roblox 화면에서 확인했다. AI 분할본을 다시 조립하는 대신 온전한 TD Nun3메시 원본으로 되돌린 뒤15뼈 스킨을 제작했다. 승인된 얼굴·백금색 로브·가방·랜턴 외형을 보존하고 스킨으로 머리/로브/발을 움직인다. 시전 팔 회전은 기존0.72rad 단일 어깨 회전에서 어깨0.42+팔꿈치0.27rad로 나누고 부드럽게 복귀한다. 랜턴 팔의 보행 반동을 줄이고, 치유 출발점은 변형된 손바닥 좌표를 추적한다.

- 원본·후보·Blender14포즈: [제작 기록](../../../assets/animations/selene-repair-v1/README.md).
- 새 개인 자산3메시/15뼈·보존 원형2,989삼각형: [런타임 출처/해시](../../../assets/shared/selene-repaired/manifest.json).
- [기존 실제 Roblox 외형](before-native-overview.jpg) · [기존 보행 포즈](before-native-walk.jpg). 정지 비교의 화면 왼쪽이 손상된6분할 모델이며 반대쪽은 기존 TD3메시다.
- GLB 표면/UV 소수4자리 대조·동일 텍스처 해시·정규화 가중치 검사 PASS. 네이티브 예비 검사: 뼈/가중치7,866 + 추종/효과361 + 크기17 PASS, 영입 계약 Lua23 PASS.

새 업로드 GLB의 이미지가 Roblox에서 얼굴/장식과 맞지 않아 기존 TD 정본 텍스처113363552204383을 재사용했다. 신규 메시/스킨과 기존 텍스처를 조합한 실제 렌더를 확인한다. 업로드 미리보기만으로 검증을 대체하지 않는다. 원본과6분할 보관 자산은 남기며 게임 선택은 새 SeleneRepairedModels만 사용한다.

[실제 전후/모션 갤러리](index.html) · [치유 정면](heal-front.jpg) · [보행 정면](walk-left-front.jpg)

## 최종 검증

- 소스 `bf20711c68bd636b4a5eb7683372f660977b67ac`, 버전0.63.1. [빌드 명령·해시](build.json)의 Lobby/Battle 모두 성공했다. 기존 사용 버전을 덮어쓰지 않았다. 고정 입력의 LFS13파일을 커밋 포인터의 SHA-256/크기와 별도로 대조해 PASS.
- `python3 tools/check-selene-repair.py`: GLB 표면/UV·텍스처·가중치 PASS.
- `python3 tools/assemble-selene-repair-suite.py --output /tmp/tlt-selene-final-suite.luau`로 조립한 스위트를 **최종 Battle0.63.1 파일**에서 Studio MCP Execute Luau로 실행. 뼈/실제 업로드 가중치7,866 + 추종/효과361 + 크기17 + 소스 일치3 = **8,247 PASS**. [원시 결과](native.json).
- `lua tests/selene-recruitment.spec.lua`:23 PASS. 저장/결제/동행 계약의 변경을 포함하지 않는다.
- Studio 로컬 Run/Heartbeat에서 대기·보행2위상·치유·보호·정화의 정면/측면12장을 촬영했다. 서버 이벤트/시간을 통제한 검토용 모델이며 실제 전투 관찰과 구분한다. 게임 경로는 기존 RenderStepped다.
- 자동 CLI 실행은 기존 Studio 플러그인 연결과 충돌해 시작 실패했다([실패 로그](cli-launch-failed.log)). 빌드 실패는 아니며 Studio에서 최종 파일을 직접 열어 소스 일치와 네이티브 스위트를 검증했다. 별도 Play 시작도 Edit에서 전환되지 않아 대기를 취소했다. **실제 Client 데이터모델 실행은 미검증**이며 Run 렌더 증거로 대체하지 않는다.

 서버 HP·지원 자격·골드/구매·동행 한도·경로 권위는 변경하지 않았다. 게시 클라이언트·실기기·다인 스트리밍/성능·경사면 미술 수용과 최종 사용자 미술 수용은 미검증이다. 다음 담당자는 QA/디자인이며 상위 티켓은 완료 처리하지 않는다.
