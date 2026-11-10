# Roblox 앱 장비 아이콘 미표시 조사

TLT-028/029/052/057/084 · 2026-11-09. 사용자가 대장간·기어·가방의 무기/장비 새 아이콘이 Roblox 앱에서 보이지 않는다고 확인했다.

## 확인된 결과

- 열린 로컬 고정 빌드0.95.1의 Studio 플레이에서 대장간을 직접 열어 Tempered Axe 새 아이콘 표시와 ImageLabel.IsLoaded=true를 확인했다. 로컬 Studio 검증이며 게시 앱 결과를 대신하지 않는다.
- 실제 ImageLabel 인스턴스로48개 새 아이콘+기존 재료2개를 PreloadAsync 검사하여50개 모두 AssetFetchStatus.Success. 비활성 진단 GUI에서는 IsLoaded=false이므로 이 검사만으로 시각 수용을 선언하지 않는다. 진단 GUI를 제거하고 직접 시작한 플레이 세션을 종료했다.
- 문자열 ContentId만 전달한 초기 검사는 Failure였다. 실제 ImageLabel 검사와 결과가 달라 원인 증거에서 제외했다.
- 게시 기록상0.95.0 로비75/배틀18에 새 아이콘을 포함한 소스가 게시됐다. 당시 Grant Permissions and Publish는 수행했으나48개 스크립트 참조 이미지의 개별 Experience 권한과 게시 클라이언트 로딩은 검증되지 않았다.
- Open Cloud의 TLT 한정 Use 권한 요청을 대표 이미지83463381365228에 시도했으나 `asset-permissions:write` 미허용으로 토큰 발급 단계에서 거부됐다. 외부 변경은 발생하지 않았다. 다른 경로로 권한 제한을 우회하지 않았다.

## 준비한 복구 범위

[permission-request.json](permission-request.json)은 현재 ItemSpriteAtlas의 무기16개·방어구/방패/클래스별 투구32개를 중복 없이 추출한48개 요청이다. Universe10773575153에 Use만 연결하며 All/Open Use, TD, 이미지 소유권·수치·보유품은 변경하지 않는다. 아직 실행하지 않았다.

다음 담당: 연결 권한 허용 후 엔지니어가 배치 요청의 성공/실패48개를 확인하고 실제 게시 Roblox 앱에서 대장간·기어·가방을 재검증한다. 현재 원인은 미확정이며 Experience 이미지 사용 권한 누락을 우선 점검한다. 게임 코드/빌드/게시/태그 변경 없음.

공식 근거: [Roblox Assets API](https://create.roblox.com/docs/cloud/reference/features/assets), `PATCH /asset-permissions-api/v1/assets/permissions`, scope `asset-permissions:write`, Universe/Use 지원. 2026-11-09 Studio http_get 문서 확인.

## 2026-11-10 권한 업데이트 후 재검토

TLT-028/029/052/057/084. 사용자 권한 업데이트 안내 후 Studio를 새로 실행하고 고정 빌드0.95.4를 열어 재연결했다. `rbx-permissions`/`rbx-open-cloud-usage` 지침을 읽고, 변경 없는 GET `/cloud/v2/universes/10773575153`에 `asset-permissions:write`, `universe:read` scope를 요청했다. 결과는 토큰 발급 단계에서 **Scope 'asset-permissions:write' has not been granted**였다. PATCH는 보내지 않았으며 외부 권한 변경은 없다. MCP 설정은 place별이므로 사용자가 변경한 창과 현재 연결의 설정 일치 여부는 미확인이다.

Python으로 현재 ItemSpriteAtlas의 무기16·방어구24·투구 변형8개를 추출하고 permission-request.json의48개와 집합 일치를 검증했다(PASS). Universe10773575153/Use 요청을 유지한다. 이미지 ID 오류나 코드 결함은 이번 검사에서 확인하지 못했으며 임의 교체하지 않았다. 게임 소스/VERSION/빌드/게시/태그 변경 없음.

사용자에게 현재 Studio의 Assistant Settings → MCP Permissions → Publish & manage assets → asset-permissions:write 확인을 요청했다. 허용 뒤 재프로브→48개 배치 요청→응답별 성공/실패 확인→게시 Roblox 앱의 대장간/기어/가방 표시 확인이 남았다. Roblox 앱은 홈 화면까지만 확인했고 게임 내 아이콘 검증은 미실행이다. 현재 검증용 Studio는 권한 설정 확인을 위한 사용자 인계 상태로 열어 두었다. 다음 담당: 사용자 설정 확인 후 엔지니어/QA.
