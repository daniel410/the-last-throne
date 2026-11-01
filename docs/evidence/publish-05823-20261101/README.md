# TLT-084 — 0.58.23 게시

2026-11-01 · ENG/DIR → QA · 사용자 요청: Studio 강제 종료 후 최신 빌드 게시.

기존 RobloxStudio 프로세스를 강제 종료하고 0.58.23 고정 산출물을 다시 열어 기존 The Last Throne Experience(10773575153)에 Publish As로 게시했다. 소스는 `04b51272addb939cc452dce18f61c3e50f4b2594`이며 두 파일 SHA-256이 [원본 빌드 기록](../td-menu-list-20261101/build.json)과 일치했다. 재빌드하지 않았고 미커밋 변경을 포함하지 않았다.

| 대상 | Place ID | 게시 버전 | 현지 시각 |
| --- | --- | --- | --- |
| Lobby | 70829337938054 | 21 | 2026-11-01 12:15 America/Toronto |
| Battle | 129388473517823 | 7 | 2026-11-01 12:16 America/Toronto |

Creator Dashboard의 Show published only를 켜서 현재 게시 행을 각각 확인했다. `lobby-published.png`, `battle-published.png`와 AX 기록이 증거다. Manage Audience의 ready to test와 기존 제한된 접근 범위를 확인했다. 공개 범위와 TD 게시본은 변경하지 않았다. 게시에 필요한 기존 자산 사용 권한 안내를 적용했다.

## 검증과 한계

- Python SHA-256 검사: Lobby/Battle 모두 빌드 기록과 일치.
- Studio Publish As 및 Dashboard Show published only: Lobby21/Battle7 확인.
- Studio 스크립트 자산 업로드 로그에 HTTP429가 발생했다. Place 게시 이력은 확인됐으나 개별 스크립트 업로드 완결·게시 클라이언트 동작은 미검증이다. 해당 진단만 추출한 `script-upload-warnings.txt`를 보존했다.
- 원격 Place 바이트가 로컬 파일과 동일하다고 주장하지 않는다. 실제 클라이언트 전투·저장·Teleport·모바일/게임패드/다인 수용은 후속이다.
- 복구가 필요하면 기존 Lobby20/Battle6을 Dashboard에서 복원한 뒤 Studio에서 게시한다.

주석 태그 `v0.58.23`은 실제 빌드 입력 커밋을 가리킨다. 이 게시 기록은 전체 출시 게이트 완료가 아니다. 다음 담당 QA: 게시된 테스트 클라이언트에서 스크립트 동작과 Lobby↔Battle 이동·저장을 검증한다.
