# 로비 출발 안내

2026-11-15 · TLT-053 / ENG·UI / 구현, 격리 엔진 검사 통과·게시 수용 미완료

사용자가 보고한 솔로/멀티 출발 후 로딩 화면까지 약3~5초 동안 상태를 알 수 없는 결함을 수정한다. 게임 규칙 변경 없이 기존 출발 잠금/저장 경계에 안내를 연결했으므로 별도 게임성 리서치는 수행하지 않았다. 제품 계약의 TD 공통 UI·서버 권위·실제 Teleport 수용 구분을 유지한다.

## 변경

- `AdventureStartingNotice`는 승인 TD `panel` 프레임·기존 색상으로 화면 중앙에 `ADVENTURE STARTING...` / `Preparing your adventure. You will travel shortly.`를 표시한다. 기존 로비 메뉴와 독립된 ScreenGui와 입력 차단 배경을 사용한다. 로딩 화면 DisplayOrder10000 바로 아래9999다.
- 원정 메뉴 Solo/Launch와 영웅 Continue 요청은 클라이언트에서 즉시 표시한다. 요청 응답 상관관계와 기존 중복 입력 잠금을 유지한다.
- 서버는 모든 로컬 출발 참가자에게 첫 MemoryStore/저장 작업 전에 `TLTAdventureStarting`을 설정한다. 메뉴를 열지 않은 파티원도 표시한다. 검증 거절/예외·이동 재시도 소진 시 해제하며 실제 이동 중에는 유지한다. 클라이언트 로비 단계 종료 시 숨긴다.
- 권리·저장·파티 자격·TD 운영·로딩 원본 이미지는 변경하지 않았다. 신규 자산 없음. 복구 시 이번 코드 변경을 되돌릴 수 있으며 저장 스키마 변경은 없다.

## 검증

- [규칙/회귀 로그](rules.log): 출발 경계94·원정 준비42·이동 요청 식별8·도착 로딩291, 합계435검사 PASS. 실제 출발 경계 함수를 추출 실행해 솔로/4인 전원의 저장 전 표시, 성공 이동 유지, 검증 거절/예외 해제, 기존 Busy 보호를 확인했다. 저장/Teleport는 모의다.
- [격리 Studio UI 로그](native.log):20검사 PASS. 실제 UI 모듈로 요청 직후 표시·중복 요청 차단·무관 스냅샷 유지·거절/실패 해제·메뉴 닫힌 파티원 표시·로비 종료 정리,1108×707/844×390/667×375 카드 경계와 TD 프레임 재사용을 확인했다. Player 속성/서버 응답은 모의이며 실제 플레이어/Teleport 검사가 아니다.
- 재현: `python3 tools/prepare-adventure-starting-test.py`, `run-in-roblox --place <격리된 빈 로컬 Place.rbxlx> --script builds/adventure-starting-test.luau`. 빈 Place 없이 실행한 첫 시도는 도구의 미지원 오류로 중단됐다. 빈 로컬 Place를 지정한 재시도에서 위20검사를 통과했다.
- 변경 런타임5개·네이티브 검사1개 Luau 컴파일 PASS. 영웅 Continue의 중앙 요청 연결은 소스/컴파일 확인이며 실제 버튼 입력 검사는 미실행이다.

## 미검증·다음 담당

QA: 게시된 Lobby/Battle 실제 클라이언트에서 솔로와2~4인 시작→3~5초 준비 안내→Teleport 로딩 연결, 실제 저장 지연·이동 실패/재시도, 실기기 터치/패드·영어 가독성과 사용자 수용을 확인한다. 부모 TLT-053/G3는 완료 처리하지 않는다. Roblox 게시/릴리스 태그는 수행하지 않는다.

## 빌드·Git

0.110.21 입력 소스 `f23603720561dba80f33e1e94d96a3998fe49ac4`를 origin/main에 푸시하고 `git ls-remote`의 동일 커밋을 확인했다. `python3 tools/build-game.py --source f2360372 --record docs/evidence/adventure-starting-20261115/build.json` 성공. [입력·LFS 검사·산출물·해시](build.json). 산출물은 `builds/0.110.21/TheLastThrone-0.110.21.rbxlx`다. 기존 미커밋 모델/삭제 자산·첨부·미추적 증거는 작업 커밋과 빌드 입력에서 제외했다.

기존 `tests/single-build.spec.py --artifact ...`는 프로젝트 마운트·역할10검사 후 자체 임시 추출 목록에 `DeepwoodMusicPolicy`가 없어 중단됐다. [원래 실패 로그](build-check.log). 산출물의 Shared 전체 의존성을 임시 추출해 역할10·도착 로딩291검사를 통과했고, 변경 런타임5개의 실제 산출물 바이트가 고정 커밋과 일치함을 확인했다. [산출물 보완 검사](artifact-check.log). 기존 도구의 실패를 성공으로 바꾸어 기록하지 않았다. 고정 게임 빌드의 Studio 전체 플레이·게시 수용은 미검증이다. 검증 증거는 후속 문서 커밋으로 보존한다.
