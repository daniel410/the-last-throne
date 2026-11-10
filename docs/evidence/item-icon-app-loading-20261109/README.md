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
