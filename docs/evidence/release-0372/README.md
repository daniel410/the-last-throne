# 0.37.2 두 RPG Place 비공개 게시

2026-10-30 · TLT-021/053/084 · ENG/DIR → QA. 사용자 **두 RPG Place에0.37.2 게시** 승인에 따라 실행했다.

| 대상 | Place ID | 게시된 Roblox 버전 | 현지 게시 시각 |
| --- | --- | --- | --- |
| The Last Throne 시작 로비 | 70829337938054 | 17 | 2026-10-30 12:42 America/Toronto |
| The Last Throne Battles | 129388473517823 | 3 | 2026-10-30 12:38 America/Toronto |

Experience10773575153 안의 정확한 기존 Place를 Publish As에서 각각 선택했다. Dashboard **Show published only**로 두 버전을 확인했고 Overview의 **Game access Private / Audience reach Private**를 다시 확인했다. 임시 Studio API 접근은 앞선 생성 작업에서 OFF로 복구한 상태다. TD Place/설정/잔액은 변경하지 않았다.

[접속](https://www.roblox.com/games/70829337938054/The-Last-Throne) · [고정 소스/산출물 SHA256와 관찰 범위](publication.json) · [이전 빌드 검증](../battle-place-provisioning/README.md). 빌드 소스는623f65aa8af8546290cee0a91947fd67de6d538c이며 게시 후에도 로컬 산출물 두 파일의 바이트/해시가 기존 기록과 일치했다. 새 빌드를 만들거나0.37.2를 다른 결과물로 덮어쓰지 않았다.

## 실제 Roblox 클라이언트 확인

게시된 로비 진입 → Knight 신규 생성/선택 → SOLO ADVENTURE → 저장 완료/서버 이동 → Deepwood의 Knight 장비·본편 목표·길 안내·Gold/Diamonds HUD 도착을 확인했다. 테스트 계정에 RPG Knight를 생성한 실제 저장 경로이며 TD와 분리되어 있다. 네이티브 자동 마우스 클릭은 닫기/Roblox 안내에서도 반영되지 않아 키보드 Backslash UI 탐색·방향키·Return으로 실행했다. 버튼 불능으로 처음 판단한 것을 교차 검증으로 정정했다. 사람의 마우스/터치 수용으로 간주하지 않는다.

로비 클라이언트 F9에서 error0, warning1: `DeepwoodJournal`54행의 없는 `DeepwoodRequest` 대기를 관찰했다. 공개 로비는 전투 월드를 만들지 않아 발생한다. 영웅 UI 연결 이후의 대기이며 실제 영웅 생성과 전투 이동을 차단하지 않았다. **경고 제거는 후속 ENG 수정 항목**이다. 증거 화면의 Roblox “Ready to playtest?” 안내는 플랫폼 안내로 게임 UI와 구분한다.

왕복·2~4인·타 로비 합류·리조인·저장 장애·모바일·20인 부하·정상 전투 전체 완주를 통과했다고 보고하지 않는다. 상위 티켓/전체 제품 수용은 미완료다. 다음 담당 QA는 실제 솔로 왕복부터 진행하고 ENG는 로비 저널의 전투 전용 신호 구독을 지연 초기화한다.

![로비 게시 버전17](lobby-published.png)

![전투 게시 버전3](battle-published.png)

![Private 유지](private-overview.png)

![실제 로비 Knight 생성](client-hero-created.png)

![실제 전투 서버 Deepwood 도착](client-battle-arrival.png)
