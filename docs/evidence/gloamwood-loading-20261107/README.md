# Gloamwood 로딩 배경 추가 · 2026-11-07

- 작업: TLT-028/057/065/084 / ENG / 소스 연결·Studio 검증 완료, 미게시. 부모 티켓 상태는 유지한다.
- 사용자 요청: `gloamwood-environment` 컨셉 사진도 로딩페이지 썸네일로 추가한다. 기존 지역 이동 로딩 배경 목록의 네 번째 이미지로 연결한다. Experience 검색/상세 페이지 썸네일 변경 요청으로 해석하지 않는다.
- 변경: `src/client/TravelLoadingScreen.luau`에 `rbxassetid://104518259187897`을 추가한다. 기존 세 이미지·무작위 선택·Crop·어두운 오버레이·영어 `LOADING...`·도착 준비 조건을 보존한다.
- 원본: `assets/concepts/2026-10-30-gloamwood-v1/gloamwood-environment.png`, SHA-256 `c88cb3cefea6ec4951aa191f828cadb084c3261d898ffa3e8d088d792e123cbf`. 직접 열람했으며 원본 픽셀/지역명은 그대로 재사용한다. 이미지 재생성·복제 파일 추가 없음. 단순 기존 자산 추가이므로 별도 게임성 조사/새 UI 설계는 없다.
- 자산 등록: 임시 로컬 HTTP 서버를 통해 Studio MCP `upload_image`가 위 이미지 ID를 반환했다. Studio에서 독립 ImageLabel에 `ContentProvider:PreloadAsync`를 실행해 `Enum.AssetFetchStatus.Success`를 확인했다.
- 엔진 검증: 실제 수정 모듈 소스를 임시 ModuleScript로 실행하고 `create(1..4)`의 기존/신규 이미지 ID·Crop·영어 로딩 문구 12검사 PASS. 임시 GUI/모듈은 제거했으며 열린 게임 소스·Place 게시를 변경하지 않았다.
- 로컬 검증: `lua tests/arrival-loading.spec.lua` → 192검사 PASS. `rojo sourcemap default.project.json --output /tmp/tlt-gloamwood-loading-sourcemap.json` 성공. `git diff --check` 통과.
- 미검증: 실제 게시 클라이언트의 이미지 권한/표시·Teleport·모바일 화면. 새 게임 빌드·VERSION 변경·게시·릴리스 태그는 수행하지 않았다.
- 다음 담당: ENG/QA, 후속 빌드/게시 후 실제 두 Place 이동 및 데스크톱/모바일 표시 확인.
