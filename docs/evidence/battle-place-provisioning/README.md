# 전투 Place 생성 재시도

2026-10-30 · OPS-STUDIO-RESTART / TLT-021/053/084 · ENG/DIR → 사용자 권한 승인 → ENG/QA.

사용자 요청으로 열려 있던 Studio 프로세스들을 강제 종료하고 The Last Throne만 다시 열었다. 재실행 대상은 Experience `10773575153`, 시작 Place `70829337938054`이며 TD 설정/Place는 변경하지 않았다. 소스와 기존 빌드는 보존했다.

## 확인한 결과

1. 이전의 잘못된 Studio 창 선택 문제가 해소되어 RPG의 File → Experience Settings → Security에 접근했다.
2. 앞서 승인받은 Studio API 접근을 잠시 켜고 Save했다. 실제 Run 서버에서 Place/Experience ID를 검사하고 `AssetService:GetGamePlacesAsync()`로 동명 Place를 먼저 찾은 뒤 `CreatePlaceAsync`를 한 번 호출했다.
3. Roblox 응답은 `Game:CreatePlace received and error: HTTP 403 (Forbidden).`이었다. 최초의 API 비활성 오류와 구분한다. 403의 세부 원인은 확인되지 않았다.
4. Run을 정지하고 임시 API 접근을 다시 끈 뒤 Save했다. 설정을 다시 열어 **OFF·Save 비활성**을 확인했다. 생성용 Script는 Run 안에서만 만들었고 종료 시 제거되며 편집/게시 소스에 넣지 않았다. 명령창도 비웠다.
5. 기존 검증 Battle `0.37.1` 파일을 열고 **Save to Roblox As → The Last Throne → Add as a new place → Create**를 실행했다. 시작 Place 덮어쓰기는 선택하지 않았다.
6. Roblox가 `Some assets need permission to load`와 **Grant Permissions and Publish**를 표시했다. 자동 승인 검토가 자산 권한 변경의 대상·범위·수신자에 대한 별도 사용자 승인이 없다는 이유로 클릭을 거부했다. 우회하지 않았고 The Last Throne에서 포함 자산을 사용하도록 허용할지 사용자에게 물었다.
7. Creator Dashboard의 RPG Places에서 여전히 시작 Place 하나만 확인했다. 새 전투 Place ID·저장/게시 성공은 아직 확인되지 않았다. `battlePlaceId=0`, 게임 버전 `0.37.1`을 유지한다.

![임시 Studio API 접근 OFF 복구 확인](studio-api-restored.png)

![현재 승인 대상: 자산 사용 권한 부여 및 게시](asset-permission-request.png)

## 검증 범위와 다음 작업

프로세스 종료와 RPG 재실행·설정 저장/재열기·Run 서버 오류·직접 저장 흐름·Dashboard 목록을 관찰했다. Studio 강제 종료 뒤 MCP 전송 연결은 끊겼으며 재연결 호출도 실패해 네이티브 UI로 계속했다. 이 기록은 게임 빌드/릴리스나 실제 게시 클라이언트 수용 결과가 아니다.

승인 후 같은 경고창에서 자산 권한 부여/저장을 완료하고 RPG 소속과 새 ID를 다시 확인한다. 최대4명 설정, ExpeditionConfig 반영, 새 MICRO 버전·소스 커밋·고정 Lobby/Battle 빌드와 필요한 검증, 각 RPG Place 게시가 이어져야 한다. 실제 클라이언트 솔로 왕복·2~4인·타 로비·리조인은 별도 수용이다. API 접근은 이미 OFF이며 다시 켤 필요는 현재 없다. TD 전투 Place를 RPG에 이동시키지 않는다.
