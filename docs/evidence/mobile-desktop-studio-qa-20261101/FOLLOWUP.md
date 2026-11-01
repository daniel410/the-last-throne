# 상세 UI 후속 독립 QA — 0.58.11

TLT-028/031/052/084 · QA · 2026-11-01. **검사한 상세 UI·기본 메뉴 회귀 수용 Pass.** QA에 사용한 Studio 종료를 확인했다. 이전0.58.9의 시각 수용 Fail은 [기준선 보고](README.md)에 보존한다.

소스 `2088c723b931ff5c5e5c0cda9574b2e7ba8c1b7a`, 예정/확정 게임 버전0.58.11. 검사는0.58.9 격리 복제 Place에 **최종0.58.11 UI 모듈8개**를 설치한 실제 Studio Play client에서 수행했다. 게임 전체0.58.11의 정상 계정·월드를 실행한 것으로 확대하지 않는다. 수정된 UI8개 모두 Studio의 실제 Source와 고정 커밋 파일의 SHA256이 일치한다: [source 대조](followup-source-match.json). 전체 Lobby/Battle 빌드 결과는 통합 담당자의 [build.json](../detail-ui-layout-20261101/build.json)에 별도 기록한다.

## 검사 조건과 결과

- HD1080 desktop custom1280×720, TouchEnabled=false.
- iPhone7 가로 custom750×323, TouchEnabled=true, 실제 safe GUI750×265.
- iPhone13 가로844×390, TouchEnabled=true, 카메라750×390/safe GUI750×332. 디바이스·notch·GUI inset과 캡처의 물리 해상도를 구분한다.
- HD1080 desktop1920×1080도 왼쪽 아이콘 크기 검사용으로 실행했다. safe GUI1920×1022.
- 실제 `LobbyTopMenu.create`, `LobbyNavigation.create`, `K0Hud.create`, `HeroGrowthGui.create`를 사용했다. remote와 캐릭터 snapshot만 QA fixture다. battle 메뉴의 Hero는 실제 성장창, Settings는 fixture 표식 콜백에 연결했다. 공격·이동·전투 월드와 상점의 전체 동작 검사가 아니다.

| Q-ID | 실제 검사 | 결과 |
| --- | --- | --- |
| Q-MDS-R01 | desktop 기존 battle 메뉴→Hero | 미니맵 메뉴 열기와 실제 상세 상태 진입 성공. 기존 desktop 좌측 기사/8슬롯·우측 수치 구성 유지 | Pass |
| Q-MDS-R02 | desktop 포인트 입력 | STR+ 초안1/76→75/CONFIRM 활성, STR− 초안0/75→76/CONFIRM 비활성 | Pass |
| Q-MDS-R03 | desktop 닫기 | TLTProgressionOpen=false | Pass |
| Q-MDS-R04 | 750×323 첫 화면 | panel726×249/body702×193/내부 scroll529×97. STR/DEX/INT/VIT 2열4행을 처음부터 표시. 각 row257×46, +/-44×44. 마지막 행 bottom200, scroll bottom201 | Pass |
| Q-MDS-R05 | 844×390 첫 화면 | body702×260/내부 scroll529×164. 4스탯과 고정 확인/취소 표시 | Pass |
| Q-MDS-R06 | mobile Touch 초안 +/−/cancel | STR+ DRAFT+1/POINTS75/확인 활성, STR− DRAFT+0/POINTS76/확인 비활성; CANCEL DRAFT도76 복원 | Pass |
| Q-MDS-R07 | mobile 4탭과 초안 보존 | COMBAT의 DRAFT167.99→170.13(+2.14), GEAR8슬롯, EFFECTS SkillPreview1. 다시 POINTS에서 STR초안1/75 유지 | Pass |
| Q-MDS-R08 | 내부 스크롤·고정 탭 | EFFECTS 실제 wheel로CanvasPosition172 이동. 탭AbsolutePosition586,58 유지. 확인 버튼도 외부 고정 배치 | Pass |
| Q-MDS-R09 | mobile 원래 battle 기본 메뉴 | 메뉴 부모Minimap, 168×238 원래 설계크기/40×40 trigger 유지. scale.72의 실제 메뉴120.96×171.36, trigger28.8×28.8. 설정 아이콘101463603654402. Settings 콜백 표식/메뉴 닫힘, Hero로상세 진입 성공 | Pass |
| Q-MDS-R10 | mobile 로비 메뉴/닫기 | 기존 세로 메뉴→Hero→상세 닫기 성공, TLTProgressionOpen=false | Pass |
| Q-MDS-R11 | TD 크기 규칙과 RPG 왼쪽7아이콘 | mobile safe750×265: button/art64×48. desktop safe1280×662:102×102. safe1920×1022:171×203. 이미지ID/crop/7개 순서 유지, caption 표시 | Pass |
| Q-MDS-R12 | 기본메뉴 원본 보존 | LobbyTopMenu/K0Hud/BattleMinimap이042a567와 byte동일. 기본 메뉴 native94assertions(32+62) 통과. 왼쪽 아이콘 크기는 최신 사용자 지시 예외 | Pass |
| Q-MDS-R13 | native8종 회귀 | 합계5271assertions 전부통과(아래 표). 실제 Play 입력과 별도 | Pass |

MCP mouse가 시뮬레이터에서 UIS `Touch`로 전달됨을 InputBegan에서 확인했다. 클릭·scroll 뒤0.2~0.3초 안정화한 뒤 결과를 조회했다. 즉시 읽으면 이전 프레임이 반환되어 첫 탭 조회에 오류가 있었지만 안정화 재검증으로 판정했다. 원래0.58.9 엔진 ModuleScript require cache가 남아 첫landscape검사가1번 실패했으며 전체 Client 폴더를 clone해 인스턴스/캐시를 초기화하고 모든 native 검사를 다시 실행했다. 최종 실패0이며 원인을 소스 결함으로 세지 않았다.

## Native 상세

| 파일 | assertions | 결과 |
| --- | ---: | --- |
| tests/mobile-landscape-details-native.luau | 972 | Pass |
| tests/mobile-menu-stats-native.luau | 920 | Pass |
| tests/lobby-navigation-grid-native.luau | 180 | Pass |
| tests/skill-stat-ui-native.luau | 3000 | Pass |
| tests/lobby-panel-size-native.luau | 100 | Pass |
| tests/lobby-top-menu-native.luau | 32 | Pass |
| tests/battle-menu-native.luau | 62 | Pass |
| tests/lobby-navigation-icon-native.luau | 5 | Pass |

[도구 결과](followup-native-results.json). skill-stat 도구 반환값은nil이며 콘솔에 `SKILL_STAT_UI_NATIVE {checks:3000,failures:[],pass:true}`가 출력되어 따로 확인했다. native는4클래스×4섹션/3본문 크기·고정retry·협폭fallback·영어 텍스트 실측·기본메뉴 기하를 포함하며 실기기 검증과 구분한다.

60개 기본 메뉴/아이콘 객체의 exploratory snapshot도 보존했다. 비활성 ScreenGui는 기기 전환 직전 AbsolutePosition/UIScale가 남을 수 있어 전체60개 absolute 값이 같다고 주장하지 않는다. 비교 가능한 local Position/Size/parent/icon/crop은 동일했고, 최종 기본UI 보존 판정은042a567 byte동일과 재실행 native 및 실제 메뉴 입력/캡처로 확인했다.

## 시각 재검증과 증거

기준선 F-01은750×323/844×390에서 **Verified**: 화면에4배분 행과 고정 확인 버튼이 들어간다. 기준선 F-02는 게임에서 TD 프레임·버튼·좌측 기사 초상·compact2열 배분으로 **Verified**. HTML을 실제 게임으로 대체 보고하지 않고 아래 실제 Play 캡처로 판단했다.

- [750×323 상세 POINTS](followup-mobile-750x323-points.png)
- [844×390 상세 POINTS](followup-mobile-844x390-points.png)
- [750×323 로비 아이콘](followup-mobile-750x323-lobby.png)
- [1920×1080 로비 아이콘](followup-desktop-1920x1080-lobby.png)
- [1280×720 기존 배틀 HUD](followup-desktop-1280x720-battle.png)
- [750×323 기존 배틀 HUD](followup-mobile-750x323-battle.png)

HUD fixture는 정상 전투 controller의 `setHints`/HP/MP/스킬 갱신을 연결하지 않았으므로 캡처에 빈 스킬·키보드 힌트·잔액—가 있다. 이것을 실제 게임의 입력모드·저장·재화 결함으로 판정하지 않았다. 임시 하늘 배경은 월드 실행을 격리했기 때문이다.

## 종료와 미검증

공식 `StopSimulationAsync()` 성공 → `Game Stopped` → Edit 상태 확인 → QA PID78838 TERM 요청 →3초 후 잔류하여, **자체 임시fixture 외 사용자 미저장 작업이 없음을 확인하고 해당 PID만 KILL** → 프로세스 소멸 및 Studio 연결 목록에서 QA ID 소멸 확인. 원본 RPG Studio와 다른 작업의 Studio는 남겨 두었다. [shutdown.json](shutdown.json).

미검증: 게시된 클라이언트/실제 모바일·PC 기기/정상 계정 저장/상점 거래/실제 battle월드/성능·열·다인플레이. 전체 구현 티켓이나 릴리스 게이트를 닫지 않는다. 다음 담당은 통합 엔지니어(선택 커밋·푸시), 실기기·게시 클라이언트 QA다.
