# 모바일 로비 카메라 복원과 하단 HUD 축소

2026-11-20 · TLT-005/084 후속 · ENG → QA · 0.114.31

사용자가 모바일 로비 카메라 흔들림을 보고했다. [0.114.24의 프레임별 보정](../lobby-mobile-camera-20261120/README.md)을 제거하고 기존 로비 카메라 동작을 복원했다. 터치 가로 화면에서 PLAY 영역은 154 × 44 px, 영웅 버튼은 48 × 44 px, XP 바는 108 × 8 px로 조정했다. XP 바와 레벨·XP 수치를 영웅 아이콘 오른쪽으로 옮겨 PLAY를 기존 모바일 레이아웃보다 아래로 85 px 내렸다.

Rojo 7.7.1에서 `python3 tools/build-game.py --source 0be3eb42 --record <기록.json>`으로 빌드했다. 산출물 `builds/0.114.31/TheLastThrone-0.114.31.rbxlx`의 SHA-256은 `0b32897263b7c69f4bb60ed7bbb6627e3ba4bdfbcba36ac0ae151136e7c6ef02`다.

macOS Roblox Studio 0.748.0.7481526의 로컬 Play에서 `LandscapeLeft`와 `CoreUISafeInsets`로 검증했다. 기본 카메라에서 마법사 모델의 화면상 하단과 PLAY 버튼 사이가 Galaxy A06(705 × 338)에서 6.14 px, iPhone 17 Pro(750 × 381)에서 42.17 px였다. 영웅이 없는 로비의 안내, 네 영웅이 보이는 상태의 레벨·XP 표시, PLAY로 모험 패널 열기를 확인했다. 기존 로비 HUD 엔진 검사 524개와 카메라 줌·충돌 검사 15개가 통과했다. Play를 종료하고 Studio를 기본 뷰포트로 복원했다. [Galaxy 캡처](galaxy-a06.jpg) · [측정값](studio.json)

## Roblox 게시

사용자 요청으로 0.114.31 단일 빌드를 기존 비공개 Experience `10773575153`의 배틀과 로비에 게시했다. Studio 로그의 대상 ID와 `PublishSuccessful`, 비공개 상태를 확인했다. 게시에 필요한 게임 자산 사용 권한은 같은 Experience에 연결했다. 게시 전후 로컬 빌드 SHA-256이 일치했다.

| 대상 | Place ID | 게시 성공 시각 (EST) |
| --- | --- | --- |
| The Last Throne Battles | `129388473517823` | 2026-11-20 19:55:38 |
| The Last Throne | `70829337938054` | 2026-11-20 19:57:46 |

릴리스 태그 `v0.114.31`의 대상은 빌드 소스 `0be3eb421517bb136d271d1b558c6677b5aa721e`다. 복구 비교 기준은 [이전 게시 0.114.25](../monster-phase-loading-20261120/README.md)다.

**남은 수용** QA의 게시 클라이언트 및 실기기 이동·회전·핀치 평가와 사용자 구도 확인. Roblox 내부 Place 버전 번호는 미확인이다.
