# 전투 Place 생성 재시도

2026-10-30 · OPS-STUDIO-RESTART / TLT-021/053/084 · ENG/DIR → 게시 승인 → ENG/QA.

사용자 요청으로 열려 있던 Studio 프로세스들을 강제 종료하고 The Last Throne만 다시 열었다. 재실행 대상은 Experience `10773575153`, 시작 Place `70829337938054`이며 TD 설정/Place는 변경하지 않았다. 소스와 기존 빌드는 보존했다.

## 확인한 결과

1. 이전의 잘못된 Studio 창 선택 문제가 해소되어 RPG의 File → Experience Settings → Security에 접근했다.
2. 앞서 승인받은 Studio API 접근을 잠시 켜고 Save했다. 실제 Run 서버에서 Place/Experience ID를 검사하고 `AssetService:GetGamePlacesAsync()`로 동명 Place를 먼저 찾은 뒤 `CreatePlaceAsync`를 한 번 호출했다.
3. Roblox 응답은 `Game:CreatePlace received and error: HTTP 403 (Forbidden).`이었다. 최초의 API 비활성 오류와 구분한다. 403의 세부 원인은 확인되지 않았다.
4. Run을 정지하고 임시 API 접근을 다시 끈 뒤 Save했다. 설정을 다시 열어 **OFF·Save 비활성**을 확인했다. 생성용 Script는 Run 안에서만 만들었고 종료 시 제거되며 편집/게시 소스에 넣지 않았다. 명령창도 비웠다.
5. 기존 검증 Battle `0.37.1` 파일을 열고 **Save to Roblox As → The Last Throne → Add as a new place → Create**를 실행했다. 시작 Place 덮어쓰기는 선택하지 않았다.
6. Roblox가 `Some assets need permission to load`와 **Grant Permissions and Publish**를 표시했다. 자동 승인 검토가 자산 권한 변경의 대상·범위·수신자에 대한 별도 사용자 승인이 없다는 이유로 클릭을 거부했다. 우회하지 않았고 The Last Throne에서 포함 자산을 사용하도록 허용할지 사용자에게 물었다.
7. 사용자가 대상 Experience의 자산 사용 권한 부여/진행을 명시적으로 승인했다. 같은 창에서 진행한 뒤 Studio와 Dashboard에서 새 Place `129388473517823`을 확인하고 **The Last Throne Battles**로 이름/설명을 저장했다. 최대 방문 인원4·Secure within Universe only를 저장/재열기로 확인했다. 기존 시작 Place는 유지했다. 새 Place 버전1/2는 저장본이며 Published Version 표시는 없다.
8. `ExpeditionConfig`에 새 ID를 연결하고 VERSION을0.37.2로 증가했다. 소스 커밋 `623f65aa8af8546290cee0a91947fd67de6d538c`을 원격에 푸시/일치 확인 후 Git archive에서 빌드했다.
9. 검증된0.37.2 Battle을 File → Publish As → The Last Throne 대상으로 준비했다. 자동 승인 검토가 실제 게시의 명시적 승인이 필요하다는 이유로 클릭을 거부했다. 우회하지 않고 로비70829337938054·전투129388473517823 두 Place의0.37.2 게시 승인을 사용자에게 요청했다. 이후 사용자가 두 Place 게시를 승인했고 [실제 게시 기록](../release-0372/README.md)처럼 완료했다.

![임시 Studio API 접근 OFF 복구 확인](studio-api-restored.png)

![현재 승인 대상: 자산 사용 권한 부여 및 게시](asset-permission-request.png)

## 검증 범위와 다음 작업

프로세스 종료와 RPG 재실행·설정 저장/재열기·Run 서버 오류·직접 저장 흐름·Dashboard 목록을 관찰했다. Studio 강제 종료 뒤 MCP 전송 연결은 끊겼으며 재연결 호출도 실패해 네이티브 UI로 계속했다. 이 기록은 게임 빌드/릴리스나 실제 게시 클라이언트 수용 결과가 아니다.

## 0.37.2 빌드와 검증

[Lobby](../../../builds/0.37.2/TheLastThrone-Lobby-0.37.2.rbxlx) · [Battle](../../../builds/0.37.2/TheLastThrone-Battle-0.37.2.rbxlx) · [해시/메타데이터](0372-build.json) · [LFS 입력5개](0372-inputs.json). Rojo7.7.1 빌드 둘 모두 종료0. Git archive는 현재 LFS 내보내기 설정으로 실제 자산을 포함하므로 `git show <commit>:<path>` 포인터의 SHA256와 고정 폴더의 실바이트를 대조했다. 최초 검증 스크립트가 archive를 포인터 텍스트로 가정해 실패한 뒤 실제 방식에 맞게 수정했다. 빌드 자체 실패나 산출물 덮어쓰기는 없다.

| 명령/조건 | 결과 |
| --- | --- |
| `lua`로 고정 목적지/Experience/20·4인 설정 검사 | PASS |
| 두 rbxlx의 ExpeditionConfig·ServerRole XML 대조 | PASS, 같은 새 ID와 올바른 Lobby/Battle 역할 |
| `run-in-roblox --place <Battle> --script tests/battle-bootstrap-native.luau` | 종료0·10개 통과, [로그](0372-battle.log) |
| 같은 실행기 + Lobby + `tests/lobby-services-native.luau` | 종료0·132개 통과, [로그](0372-lobby.log) |
| 같은 실행기 + Lobby + `tests/expedition-service-native.luau` | 종료0·13개 통과, [로그](0372-expedition.log) |

실제 Teleport/Player 명단은 이 검사에서 대역이다. 설정 이외 시설·전투 구현은0.37.1과 같으며 기존 실제 Player 시설 검증을 재사용한다. 기존203785492 자산 타입 경고는 남아 있다. 게시용 Studio에서 TexturePack 자동 업로드429 경고3개가 관찰됐으며 명시된 제한 해제 시각은2026-10-30 14:37:43Z다. 실제 게시 클라이언트의 PBR 시각 수용은 별도다.

![저장된4인 전투·서버 이동 입장 제한](battle-place-access.png)

후속 사용자 승인으로 두 Place 게시를 완료했다(로비17·전투3·Private). 실제 클라이언트 Knight 생성→솔로 전투 서버 도착까지 확인했으며 [게시 증거](../release-0372/README.md)에 기록했다. 왕복·2~4인·타 로비·리조인은 별도 수용이다. API 접근은 이미 OFF이며 다시 켤 필요는 현재 없다. TD 전투 Place를 RPG에 이동시키지 않는다. 상위 티켓은 완료 처리하지 않는다.
