# 0.40.2 게시 요청 · 진행 보류

2026-10-30 · TLT-021/053/084 · 사용자 게시 승인 있음. 현재 **게시 성공을 확인하지 못했으며 미게시 상태**다. 릴리스 태그를 만들지 않았다.

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
