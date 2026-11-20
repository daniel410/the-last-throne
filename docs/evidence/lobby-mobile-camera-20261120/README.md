# 모바일 로비 PLAY 버튼 가림 수정

2026-11-20 · TLT-005/084 후속 · ENG → QA · 0.114.24

사용자 가로 화면에서 PLAY 버튼이 마법사를 가렸다. [기존 최소 줌 24 studs 조정](../lobby-camera-20261114/README.md) 뒤에도 짧은 화면에서는 카메라 중심과 버튼이 가까웠다. 터치 로비에서 버튼이 표시될 때 장비를 포함한 캐릭터 모델의 화면상 하단과 버튼 윗선을 비교하고 필요한 만큼 카메라를 아래로 돌려 영웅을 화면 위쪽에 둔다. 카메라의 원래 자세는 다음 프레임의 이동·회전 입력 처리 전에 복원한다. 버튼 좌표와 카메라 투영은 Core UI 안전 영역을 기준으로 맞췄다. [Roblox Camera API](https://create.roblox.com/docs/reference/engine/classes/Camera#ScreenPointToRay)

## Studio 검증

`python3 tools/build-game.py --source 8be084f9 --record <기록.json>`으로 고정 소스에서 빌드했다. Roblox Studio 0.748.0.7481526의 로컬 Play에서 기존 영웅 생성·선택 요청으로 테스트 캐릭터를 준비했다. 화면 방향은 가로(`LandscapeLeft`), HUD는 `CoreUISafeInsets`다. 화면 높이와 버튼 위치는 실제 Client에서 읽었다. [빌드 해시·원시 측정](studio.json)

| 프리셋과 Client 뷰포트 | 영웅 | 모델 하단과 PLAY 버튼 사이 최소 간격 |
| --- | --- | --- |
| iPhone 17 Pro · 750 × 381 | Mage | 11.85 px |
| Galaxy A06 · 705 × 338 | Knight, Elf, Dwarf, Mage | 10.52 px |

각 영웅의 기본 카메라와 24/32 studs에서 -10°/25°/50°/80°를 조합한 8가지 카메라 자세를 확인했다. 렌더 프레임에서 보정 직전과 직후에 보이는 캐릭터 파트의 모서리를 투영해 간격을 측정했다. 모바일 45개 표본에서 버튼과 캐릭터가 겹치지 않았으며 카메라 위치와 초점의 이동량은 0이었다. [iPhone 화면](iphone-17-pro.jpg) · [Galaxy 화면](galaxy-a06.jpg)

Studio의 가상 포인터로 PLAY 버튼을 눌러 모험 메뉴가 열리고 HUD가 숨는 것을 확인했다. 메뉴 닫힘은 Studio에서 패널의 표시 상태를 변경해 재현했다. HUD가 다시 나타나면 카메라 보정이 복귀했다. Scriptable 카메라와 데스크톱 기본 뷰포트(1614 × 908)에서는 보정 전후 자세가 같았다. 기존 카메라 줌·충돌 엔진 검사 15개를 통과했다. Play를 종료하고 Studio 뷰포트를 기본값으로 복원했다.

**남은 수용** Roblox 게시 및 게시 클라이언트, 실기기 터치 회전·핀치·이동과 사용자 화면 확인. 다음 담당은 QA다.
