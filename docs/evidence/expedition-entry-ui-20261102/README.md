# 난이도 설정·배틀 진입 UI 수정

2026-11-02 · TLT-028/029/041/050/052/061/073/084 · ENG/DES → QA · 0.62.5 · 로컬 시험판·미게시

[UI 리뷰](../../reviews/expedition-ui-look-and-feel-review-2026-11-02.md)의 UI-R1~R5를 수정했다. 출발/준비/재입장은 스크롤과 분리한 고정 하단에 배치하고,4모드는 수평48px로 유지했다. 짧은 가로 화면은 제목/요약/탭의 여백을 별도로 조정한다. 상세/임무/파티 탭으로 정보와 동작을 나눠 긴 목록을 열어도 주 행동을 유지한다. 로비·배틀의 기본 메뉴/아이콘 배치는 변경하지 않았다.

서버 `ExpeditionPresentation`이 실제 규칙에서 임무 이름·지역·첫 목표·최소레벨·필수 본편·이전 난이도·위험 배수·초회/반복 보상·Lv80 XP 상한·강화 재료/장비 상자 진도를 계산한다. Hell 반복과 초회 보상 기수령을 설명하며 보상/전투 수치를 변경하지 않았다. 위험 배수는 레벨/인원 효과와 별도인 시험 수정자로 설명한다. 모드별 지역 대표 이미지는 새로 만들지 않고 승인된 TD 지도 아이콘을 사용한다.

파티의 각 멤버를 로컬 실제 선택 영웅/계정·출발 roster와 대조하고, 미도착·레벨·이전 난이도·스토리·미준비 원인을 보낸다. 현재 roster와 성장 상태가 바뀌면 준비를 재확인한다. 전체 도착/자격/준비와 정원을 충족할 때 방장의 출발 버튼이 활성화된다. 최종 서버 freeze/자격 검사는 유지하고 파티 변경은 다른 로컬 멤버에게도 즉시 전송한다.

클라이언트는 requestId로 응답을 대조하고 미확정 명령 중 다음 요청을 보내지 않는다. 서버0.35초 제한은 Busy ack를 보내며 UI는 동일 requestId의 GetState로 확정 상태를 다시 읽는다. 응답 유실 시 실제 Solo/Launch를 재전송하지 않고 GetState만 반복 확인한다. 늦은 과거 ack는 새 선택을 되돌리지 못한다. 성공한 명령의 nil 오류를 Lua의 `and/or` 식이 NetworkUnavailable로 바꾸던 기존 오류도 수정했다.

TD 원본 panel·제목 plaque·닫기·영웅 초상·SelectionCheck를 재사용하고, 잠긴 모드는 shellDisabled/LOCKED, 출발은 녹색 shellUpgrade로 구분했다. 잠긴 모드를 눌러 조건/보상을 살펴볼 수 있으나 입장 버튼은 비활성이다. 원본 레지스트리/권한을 재정의하거나 TD 소스를 수정하지 않았다.

## 검증

- `tests.log`: 관련14개 Lua 묶음 총6,525검사 통과. 신규17개는 입장·보상 projection, 파티 레벨/선행/미도착/미준비/정원·상태·성장 변경과 서버 capability 비노출을 확인한다.
- `tools/prepare-expedition-entry-test.py`: 실제 GUI/네트워크 handler + fixture 서비스/시계/메모리 map으로67검사. PC1108×707·844×390·667×375의 고정 출발/44px 터치/난이도 행/잠긴 caption 레이어, 빠른 두 번째 명령 차단, 오래된 ack 거부, Busy→동일ID GetState 복구, full mission list, Hell/Lv80 보상, 멤버별 이유와 전원 준비 출발, 미설정/이동/저장 상태를 검증한다. 성공 Configure의 정상 ack·서버 rate-limit 응답·파티 변경 전파도 실제 handler로 확인한다.
- `tools/prepare-difficulty-native-test.py`: 기존 실제 InventoryService 저장·초회/반복·탐색·강화·장착 능력치/상세 UI를 격리 실행한다.
- 네이티브 Luau 컴파일 및 성장 정본 계산: 최종Lv40/XP0, quest XP13,795·Gold19,652 유지.
- 소스 `baf073c356a5ca701347f463da3324dec015a785`을 git archive로 격리해 Lobby/Battle Rojo7.7.1 빌드 모두 성공했다. `build.json`에 산출물 크기/SHA256, `build.log`에 명령/출력, `studio.json`에 동일 고정 소스의67개 UI/handler 검사와 기존 InventoryService 회귀 결과를 기록했다. 변경5모듈 컴파일 및 presentation17검사도 고정 소스로 재확인했다. 캡처는 실제 UI fixture 렌더이며 모바일은 고정 컨테이너, 실제 기기/시뮬레이터 결과가 아니다.

## 미검증·인계

QA 후속: 게시된 각 테스트 Experience의 실제 파티·Teleport/저장 장애·재접속·지연/연속 탭, 모바일 safe area/글자 크기·패드 포커스, 사용자 미술/사용성 수용. 현재 고레벨 본편/장비와 최종 밸런스 범위를 확대하지 않았고 상위 티켓 완료·게시·릴리스를 선언하지 않는다. 기존 다른 작업의 TD 이동/로비/몬스터/애니메이션 미커밋 변경은 이번 커밋과 고정 빌드에서 제외한다.

## 화면과 정리

- [PC](desktop.jpg): Easy/Lv1·잠금3모드·고정 녹색 출발·원본 TD 프레임/선택 체크.
- [모바일 가로](mobile-landscape.jpg):844×390 고정 컨테이너.4모드와44px 출발이 동시에 보인다. 화면 밖 바닥은 테스트 캔버스 밖이다.
- [파티](party.jpg): 방장Lv80 Hell 자격 충족·동료Lv1/미준비 fixture. 멤버 행의 Reach Lv80과 비활성 고정 출발을 확인했다. 실제2인 네트워크 접속 증거가 아니다.
- 검증 중667×375의 본문 높이와 잠긴 버튼 텍스트 레이어 문제를 발견해 수정한 뒤 전체67검사를 다시 통과시켰다.
- 테스트 후 임시 ScreenGui/BindableEvent와 전역 fixture를 제거했고 StarterGui에 임시 화면이 없는 것을 확인했다. 기존 사용자 Studio는 Edit 상태로 보존했다. 이번 작업의 신규 LFS 파일은 검증 캡처3개다.
