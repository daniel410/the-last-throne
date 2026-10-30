# 0.40.2 게시 요청 · 진행 보류

2026-10-30 · TLT-021/053/084 · 사용자 게시 승인 있음. **전투 Place는0.40.2 게시 완료, 로비는 자산 권한 승인 대기로 미완료**다. 두 Place 릴리스가 끝나지 않아 태그를 만들지 않았다.

게시 후보는 [검증한0.40.2](../deepwood/places-0400/build.json)의 원본 산출물이다. 재빌드/덮어쓰기를 하지 않았고 두 파일의 SHA256 일치를 재확인했다.

| 대상 | Place ID | SHA256 |
| --- | --- | --- |
| RPG Lobby | 70829337938054 | 570c1e0108457b0e12435db916aa0a7fe19352eedbee78edcffd39bf9983ea71 |
| RPG Battle | 129388473517823 | 5d103a26bf2ed2fbaf200289b1a96c98e5cba3762dfc5433a9f5467f8106354f |

Experience10773575153의 기존 두 Place를 갱신할 승인이다. 공개 접근 범위 변경이나 TD Place 갱신은 범위에 없다. 게시 전 소스 커밋은0a04d7b98e07e8b0c4eb99d7e7330e90d2273d46이다.

## 현재까지 확인

- Studio MCP는 정확한0.40.2 Battle 문서에서 ServerRole=Battle, 독립 RPG Experience/두 Place ID, 새 지형/보스 배지/잔액 모듈, 검토용 생성 월드/Script가 없음을 확인했다.
- Studio UI는 이전0.37.2 문서에 연결돼 있었다. 파일 열기로 최신 Battle 문서를 열었지만 창 제어가 해당 문서로 따라가지 못했다. 기존0.37.2 문서의 미저장 상태는 `/private/tmp/tlt-studio-preserved-before0402.rbxl`로 별도 보존한 뒤 닫았다. 완료한 `/tmp/tlt-map-preview.rbxlx`와 `/tmp/tlt-ground-preview.rbxlx`의 합성 검토 창만 종료했다.
- [공식 AssetService API](https://create.roblox.com/docs/reference/engine/classes/AssetService)에서 PlaceId와 SaveWithoutPublish=false 지원을 확인하고 정확한 로컬 Battle 문서에서 시도했다. 결과는 `Game:SavePlace can only be called from a server script, aborting save function` / success=false였다. 이 시도로 게시되지 않았다. 런타임 생성 장면을 검증된 파일 대신 게시하거나 API 보안 설정을 변경하는 경로는 사용하지 않았다.
- 다른 TD 작업 창을 최소화하려던 UI 동작은 자동 승인 검토에서 창 닫기/미저장 내용 손실 위험으로 거부됐다. 그 창을 닫거나 변경하지 않고 창 선택 경로로 전환했다.
- 최신0.40.2 Studio 창을 사용자가 앞으로 선택해 주면 해당 문서에서 Publish As를 이어서 실행하고, Creator Dashboard의 Show published only 버전·접근 범위를 확인한 뒤 기록과 태그를 마감한다. 게시 승인을 다시 요청하는 단계가 아니다.

다음 담당 ENG/QA: 정확한0.40.2 Battle→Lobby 게시, 각 게시 버전 확인, 두 원본 파일 해시 재확인, 검증 소스에 주석 있는v0.40.2 태그 및 커밋/푸시. 실제 클라이언트·왕복/다인/실기기 수용은 로컬 검증과 구분한다.

## 2026-10-30 재시도: 전투 게시 / 로비 대기

사용자가 모든 Studio 창 강제 종료를 명시적으로 요청해 RobloxStudio 프로세스를 종료했다. 이후 검증된 Battle 파일만 새로 열고 Publish As → The Last Throne → The Last Throne Battles를 선택했다. Studio의 자산 권한 안내를 거쳐 비공개 테스트 준비 화면을 확인했다. Creator Dashboard의 **Show published only**에서 Battle Place `129388473517823`의 **버전4, 18:04 America/Toronto** 게시를 확인했다. 이 게시 작업에 앞서 파일 SHA256은 위 값과 일치했다.

이어 검증된 Lobby 파일을 새로 열고 같은 Experience의 The Last Throne 시작 Place `70829337938054`를 선택했다. Studio에서 대상 Experience에 일부 자산 사용 권한이 필요하다고 안내하며 **Grant Permissions and Publish**를 표시했다. 자동 승인 검토는 게시뿐 아니라 자산 사용 권한 부여가 포함되며 대상 자산과 권한 범위의 명시적 승인이 없다는 이유로 해당 버튼 클릭을 거부했다. 권한을 우회해 부여하지 않았다. Studio 안내는 개별 자산 목록을 표시하지 않았으므로 구체적인 자산 ID/수는 미확인이다. 대시보드에서 Lobby 최신 버전은 기존 **17, 12:42**이며 새 게시를 확인하지 못했다.

다음 단계: 사용자가 해당 자산 사용 권한 부여를 명시적으로 승인하면 남은 Lobby 게시를 진행하고 Dashboard의 게시 버전·비공개 상태를 확인한다. 둘 다 게시된 이후에만 소스0a04d7b에 릴리스 태그를 생성한다. 실제 게시 클라이언트 동작은 아직 미검증이다.
