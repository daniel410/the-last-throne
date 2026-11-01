# 모바일·데스크톱 독립 Studio QA

> **최신 결과:** [0.58.11 후속 재검증](FOLLOWUP.md)은 상세 UI·기본 메뉴 회귀 Pass이며5271native assertions통과, QA Studio종료 확인. 아래는0.58.9 결함 기준선 기록이다.

TLT-028/031/052/084 · QA · 2026-11-01 · **시각 수용 Fail, 기능 검사 Pass**.

기준은 게임 0.58.9, 소스 `094412ec5d62b78fe94203728caf8517fcc87169`다. 게시하지 않았다. 최근 HTML 시안은 실제 게임 구현으로 취급하지 않았다. 제작자와 별도로 QA 역할 지침과 프로젝트 제작 스킬을 적용했다.

## 환경·격리

- 로비 빌드 SHA256 `34fa66765856721e0226d0c9748be863c4a234dcbc3b97afa0b4e1663149e0e3`를 `/tmp/TLT-MobileDesktopQA-0589.rbxlx`로 복제했다.
- QA Studio ID `0e4e362c-efbf-4559-8013-cc53ab0f243e`, PID `78838`. 원래 스크립트 3개를 임시 DataModel에서 비활성화하고, 저장소의 실제 `HeroGrowthGui`, `HeroStatsView`, `LobbyTopMenu`, 테마·공유 모듈을 실행했다. 원본 `src`는 수정하지 않았다.
- `tests/mobile-desktop-studio-qa-server.luau` / `tests/mobile-desktop-studio-qa-client.luau`가 임시 remote·Lv20 Knight·스탯76점·빈 가방을 제공한다. 실제 저장·전투·DataStore·게시·상품 지급 검사가 아니다. MENU의 Hero는 실제 성장 UI를 열고 다른 메뉴 목적지는 fixture 표식만 남긴다.
- 공식 `StudioDeviceSimulatorService`로 기기를 전환했다. HD1080에서1280×720, `TouchEnabled=false`; iPhone7 가로 custom750×323에서750×323, `TouchEnabled=true`; iPhone13 가로844×390에서 카메라 viewport750×390, 안전 GUI750×332, `TouchEnabled=true`. 출력 캡처는 기기 scale에 따라2배 해상도일 수 있다.
- 원래 Studio 창 viewport976×178에서 content 높이-22를 확인했으나 정상 기기 판정에서 제외했다. 고정 panel844×390 임시 실험도 최종 판정에서 제외하고 원래 비율·앵커로 복구한 뒤 정식 시뮬레이터로 재검사했다.
- macOS CUA가 별도 사용자0.58.5 창만 선택하여 디바이스 메뉴를 사용하지 못했다. 공식 simulator API를 QA 인스턴스에서만 사용했다.

## 검사 결과

사례20개: **Pass17 / Fail2 / Not Run1**. 아래 한 행이 한 사례다. 엔진 사례의 내부 assertion1435개는 사례 수와 별개다.

| Q-ID | 조건·검사 | 실제 결과 | 판정 |
| --- | --- | --- | --- |
| Q-MDS-01 | desktop MENU 열기 | 기존168×192 세로 메뉴, MobileLayout=false | Pass |
| Q-MDS-02 | desktop MENU→STATS | 실제 성장 UI, 기사 초상·8슬롯·우측 전투 수치 렌더 | Pass |
| Q-MDS-03 | desktop 스크롤 | CanvasPosition600으로 포인트 행 접근, body1204×456 | Pass |
| Q-MDS-04 | desktop STR+ | 초안+1, 잔량76→75, CONFIRM 활성 | Pass |
| Q-MDS-05 | desktop STR− | 초안0, 잔량75→76, CONFIRM 비활성 | Pass |
| Q-MDS-06 | desktop 닫기 | TLTProgressionOpen=false, 로비 메뉴 복귀 | Pass |
| Q-MDS-07 | mobile MENU | 2열4버튼368×136, safe GUI750×265 내부 | Pass |
| Q-MDS-08 | mobile MENU→STATS | 실제 Touch 입력으로 성장 UI 열림 | Pass |
| Q-MDS-09 | mobile COMBAT/POINTS/GEAR/EFFECTS | 선택 강조·해당 콘텐츠 생성; Gear 초상 IsLoaded=true | Pass |
| Q-MDS-10 | mobile STR+ | 초안+1, 잔량76→75, CONFIRM 활성 | Pass |
| Q-MDS-11 | mobile STR− | 초안0, 잔량75→76, CONFIRM 비활성 | Pass |
| Q-MDS-12 | mobile CANCEL DRAFT | STR/DEX/INT/VIT 초안 모두0, 잔량76 복원 | Pass |
| Q-MDS-13 | mobile section 이동 후 초안 | COMBAT→GEAR→EFFECTS→POINTS 뒤 STR+1 유지 | Pass |
| Q-MDS-14 | mobile 스크롤 | MCP wheel 후 실제 CanvasPosition 약100/200 이동; 행 접근 | Pass |
| Q-MDS-15 | mobile 닫기 | TLTProgressionOpen=false, 메뉴 다시 열림 | Pass |
| Q-MDS-16 | simulator 기기 전환 | desktop↔mobile 시 TouchEnabled와 메뉴 레이아웃 전환 | Pass |
| Q-MDS-17 | 기존 native 엔진 회귀 | `tests/mobile-menu-stats-native.luau` 1435 assertions, failures=[]; 4클래스·4섹션·5항목 배틀 메뉴의52px 높이·기존 desktop 복원 | Pass |
| Q-MDS-18 | 모바일 가로 상태 첫 화면 가독성 | 아래 F-01 재현. 750×323 POINTS에서 배분 행0개, 844×390에서는1개만 보임 | Fail |
| Q-MDS-19 | 최신 HTML 시안과 게임 일치 | 아래 F-02. 가로 sidebar/compact grid가 실제 게임에는 없음 | Fail |
| Q-MDS-20 | 실제 전투 서버 전체 배틀 메뉴 회귀 | 실제 K0Hud/전투세션 실행은 하지 않음. 공용5항목 binding 엔진 회귀만 Q-MDS-17에 포함 | Not Run |

입력은 MCP mouse가 simulator에서 `UserInputService.InputBegan`의 **Touch**로 전환되는 것을 기록했다. 스크롤·클릭 뒤0.2~0.3초 `task.wait`로 레이아웃을 안정화한 후 조회했다. 즉시 조회는 이전 프레임을 반환할 수 있어 최종 판정에서 제외했다. 일부 행 접근에는 fixture가 CanvasPosition을 설정했으며 이것을 실제 스와이프 검증으로 세지 않았다. 실제 wheel 이동은 별도로 Q-MDS-14에서 확인했다.

## 결함

**F-01 · 심각도 Major / 우선순위 P1 · 가로 화면인데 세로 카드가 대부분 숨는다.**

재현: iPhone7 가로750×323 → MENU → STATS & SKILLS → POINTS. 패널726×225, 콘텐츠702×123, CanvasSize762다. 제목·상위 탭·하위 탭·하단 메시지가 높이를 사용하여 처음에는 AVAILABLE STAT POINTS만 보이고 STR 배분 행조차 보이지 않는다. iPhone13 가로844×390에서도 패널726×292/콘텐츠702×190, 첫 STR 행1개만 보이고 효과 설명이 아래에서 잘린다. COMBAT도 첫 수치1개만 보인다. 스크롤하면 접근은 가능하지만 짧은 가로 화면에 맞춘 상태 요약으로 수용하기 어렵다. 모든4스탯과 확인 버튼을 볼 때 반복 스크롤이 필요하다. [750×323 POINTS](mobile-750x323-points.png), [844×390 POINTS](mobile-844x390-points.png), [COMBAT](iphone13-combat.png).

다음 담당: 디자인/엔지니어. 가로 화면의 요약·배분 행을 압축하고 탭·제목·하단 안내 높이를 재배치한 뒤 동일기기 독립 재검증 필요. 아직 Verified 아님.

**F-02 · 심각도 Moderate / 우선순위 P2 · 사용자에게 보여 준 시안과 실제 게임의 배치가 다르다.**

`.codex-attachments/visualizations/mobile-landscape-td-preview.html`은 가로 hero sidebar와 compact stat grid를 보여 주지만0.58.9는 COMBAT/POINTS/GEAR/EFFECTS 각각을 큰 세로 카드로 렌더링한다. TD 프레임·버튼·기사 초상은 실제로 로드되었지만 HTML 시안의 가로 구성은 반영되지 않았다. HTML 재현 화면과 게임 캡처를 동일 구현으로 보고할 수 없다. 다음 담당: 디자인/엔지니어, 실제 런타임에 적용 후 QA.

## 증거와 한계

[desktop1280×720](desktop-1280x720.png) · [mobile2열 메뉴](mobile-750x323-menu.png) · [EFFECTS](mobile-750x323-effects.png).

출력 로그에 기존 `rbxassetid://203785492` Asset type mismatch가3회 있었다. 전체 PlayerGui 기준 게임 시작 화면의 자산 완전 로드를 입증하지 않으며, 이번 범위에서 TD 버튼·기사 초상은 캡처/IsLoaded로 확인했다. 전투 월드·다른 클래스의 실제 Play 초상·실기기·게시된 클라이언트·정상 계정 저장·성능·Not Run 사례는 미검증이다. native 엔진 검사를 실제 플레이 완주나 모바일 실기기 수용으로 확대하지 않았다.

## Studio 종료

`StopSimulationAsync()` 성공 → Play 중지 `Game Stopped` → Studio mode `Edit` 확인. 임시 변경은 테스트 fixture뿐이며 원본 게임 파일에 저장하지 않았다. 종료 프로세스와 연결 목록 확인 결과는 `shutdown.json`에 기록한다. 사용자/다른 작업의 Studio 인스턴스는 종료 대상에서 제외했다. 통합 담당자가 선택 커밋·푸시한다.
