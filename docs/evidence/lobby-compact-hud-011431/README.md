# 모바일 로비 카메라 복원과 하단 HUD 축소

2026-11-20 · TLT-005/084 후속 · ENG → QA · 0.114.31

사용자가 모바일 로비 카메라 흔들림을 보고했다. [0.114.24의 프레임별 보정](../lobby-mobile-camera-20261120/README.md)을 제거하고 기존 로비 카메라 동작을 복원했다. 터치 가로 화면에서 PLAY 영역은 154 × 44 px, 영웅 버튼은 48 × 44 px, XP 바는 108 × 8 px로 조정했다. XP 바와 레벨·XP 수치를 영웅 아이콘 오른쪽으로 옮겨 PLAY를 기존 모바일 레이아웃보다 아래로 85 px 내렸다.

Rojo 7.7.1에서 `python3 tools/build-game.py --source 0be3eb42 --record <기록.json>`으로 빌드했다. 산출물 `builds/0.114.31/TheLastThrone-0.114.31.rbxlx`의 SHA-256은 `0b32897263b7c69f4bb60ed7bbb6627e3ba4bdfbcba36ac0ae151136e7c6ef02`다.

macOS Roblox Studio 0.748.0.7481526의 로컬 Play에서 `LandscapeLeft`와 `CoreUISafeInsets`로 검증했다. 기본 카메라에서 마법사 모델의 화면상 하단과 PLAY 버튼 사이가 Galaxy A06(705 × 338)에서 6.14 px, iPhone 17 Pro(750 × 381)에서 42.17 px였다. 영웅이 없는 로비의 안내, 네 영웅이 보이는 상태의 레벨·XP 표시, PLAY로 모험 패널 열기를 확인했다. 기존 로비 HUD 엔진 검사 524개와 카메라 줌·충돌 검사 15개가 통과했다. Play를 종료하고 Studio를 기본 뷰포트로 복원했다. [Galaxy 캡처](galaxy-a06.jpg) · [측정값](studio.json)

## Roblox 게시

사용자 요청으로 0.114.31 단일 빌드를 기존 비공개 Experience `10773575153`의 배틀과 로비에 게시하는 작업을 시도했다. 게시 전후 로컬 빌드 SHA-256이 일치했다. Studio는 두 Place에 `PublishSuccessful`을 표시했으나, 각각 직후 스크립트 업로드 요청이 HTTP 429로 실패했다. 아래 시각은 Studio가 게시 성공을 표시한 시각이다.

| 대상 | Place ID | Studio 성공 표시 (EST) | 후속 스크립트 업로드 |
| --- | --- | --- | --- |
| The Last Throne Battles | `129388473517823` | 2026-11-20 19:55:38 | 19:55:41 HTTP 429 |
| The Last Throne | `70829337938054` | 2026-11-20 19:57:46 | 19:57:49 HTTP 429 |

릴리스 태그 `v0.114.31`의 대상은 빌드 소스 `0be3eb421517bb136d271d1b558c6677b5aa721e`다. 복구 비교 기준은 [이전 게시 0.114.25](../monster-phase-loading-20261120/README.md)다.

### 게시 로비 시작 장애

TLT-005/084 후속. 2026-11-20 20:16 EST에 macOS Roblox Player 0.748.0.7481526으로 시작 Place `70829337938054`에 직접 접속했다. 조인 로그의 Place·Experience ID와 핑을 확인했다. 사용자 화면과 같은 회녹색 배경과 Roblox 메뉴만 표시됐다. 캐릭터·로비 UI가 나타나지 않았고 클라이언트 개발자 콘솔에는 오류·경고가 0건이었다. Roblox Studio의 19:55 및 19:57 로그에서 `PublishSuccessful` 직후 `/publish/v1/Scripts`의 HTTP 429와 `Commit Failure: Publish Assets`를 확인했다.

같은 SHA-256의 0.114.31 로비 원본으로 20:19에 재게시를 시도했다. Roblox가 두 차례 `PlaceOngoingTeamCreateSession`으로 거부했다. 클라우드 로비의 Team Create 편집본은 Place 버전 114이며, Studio에서 읽은 스크립트 567개 모두 소스가 있었다. 클라우드 편집본의 버전과 플레이 서버가 실행한 버전의 일치는 확인되지 않았다.

**남은 복구 및 수용** ENG가 승인된 원본의 스크립트 게시 완료를 확인한 뒤 QA가 새 서버의 Roblox Player에서 로비 진입·영웅 표시·배틀 이동을 확인한다. 모바일 실기기와 사용자 수용은 후속이다.
