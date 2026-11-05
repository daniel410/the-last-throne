# 변경 소스 통합 빌드 — 0.73.2

작업: TLT-003/005/057/084 · ENG · 사용자 요청: 현재 변경된 내용을 포함한 최신 빌드.

## 포함 범위

- 기존 미커밋 런타임 소스 전체: 드워프 대각선 도끼 공격 클립·R6 후속 동작·도끼 장착 방향, 다이브 후 착지 회피 모션.
- 로비 TD 이동 안내·저장/이동 상태 표시·설정 기반 목적지·이동 실패 콜백 토큰 구분.
- 새 필수 모듈 `K0DwarfDiagonalClip`·`TravelAttempt`, 관련 기존 테스트 변경과 클립 JSON/저작·내보내기 도구를 소스에 고정한다.
- 검토용 이미지·과거 몬스터 증거·Blender 백업·첨부 파일은 로컬에 보존하며 이번 빌드 입력/커밋에서 제외한다.

## 검증과 한계

- `lua tests/dodge-double-tap.spec.lua`: 983검사 PASS.
- `lua tests/travel-attempt.spec.lua`: 8검사 PASS.
- `lua tests/place-role.spec.lua`: 10검사 PASS.
- `lua tests/arrival-loading.spec.lua`: 108검사 PASS.
- `python3 tests/single-build.spec.py`: 프로젝트 마운트/호환 사본 PASS.
- `git diff --check`: PASS.
- 빌드 명령: `python3 tools/build-game.py --source HEAD --record docs/evidence/changed-source-build-20261104/build.json`.
- 실제 Rojo 빌드 PASS. 소스 커밋 `3360af8ae95ee21a9529a810ea526a6366604b67`. [빌드/LFS 기록](build.json) · [검증 기록](validation.json).
- 산출물 `builds/0.73.2/TheLastThrone-0.73.2.rbxlx`: 13,141,552 bytes, SHA-256 `0d7fff65a2cd82036b39af5eb220ba5a3c81cdc870b308ef136fc7735278e010`.
- 실제 XML에 변경 런타임 소스 11개가 커밋과 정확히 일치함을 확인했다. 미커밋 런타임 소스 없음.
- `python3 tests/single-build.spec.py --artifact builds/0.73.2/TheLastThrone-0.73.2.rbxlx`: 조기/서버 모듈·설정 일치, 실제 산출물의 역할10/로딩108검사 PASS.
- 이번 작업에서 Studio 네이티브 모션/무기 테스트·실제 렌더·실제 Experience 이동·실기기/4인+AI는 실행하지 않았다. 과거 로컬 로그를 이번 소스의 통과 증거로 사용하지 않는다.
- 빌드 시점에는 미게시였으며, 아래 후속 게시 결과를 따른다. 상위 구현 티켓의 수용 상태는 갱신하지 않는다.

다음 담당: QA — 이 단일 파일의 로비/배틀 실행·모션/무기 표시·게시된 테스트 Experience 간 이동 확인.

## 첫 게시 시도 결과 (후속 재시도로 해결)

사용자 게시 요청으로 두 RPG Place 게시를 시도했으나 **두 곳 모두 미게시**다. 0.73.2는 Studio MCP 목록에 별도 인스턴스로 확인됐지만 CUA가 종료된0.73.1 인스턴스의 빈 창/비활성 메뉴에 고정됐다. bundle/path 재연결과 CUA 세션 초기화로도 복구되지 않았다. 게시 버튼 실행 전 차단됐으며 파일 해시는 보존됐다. [시도 기록](publication-attempt.json). 게시/릴리스 성공으로 보고하지 않으며 태그를 만들지 않았다. 다음 단계는 Studio 창을 모두 닫고0.73.2만 다시 연 뒤 로비/배틀 게시 및 게시 버전 확인이다.

## 강제 종료 후 게시 성공

사용자의 강제 종료·재게시 지시로 Activity Monitor에서 Studio3개 프로세스를 강제 종료하고 Finder에서0.73.2만 다시 열었다. 같은 파일을 기존 Experience10773575153의 로비70829337938054·배틀129388473517823에 각각 Publish As로 게시했다. 로비는 자산 사용 권한 안내에서 Grant Permissions and Publish를 실행했다. 로비의 테스트 준비/제한 접근 화면과 배틀의 Successfully published!/Private 화면을 확인했다. 두 번의 Studio PublishSuccessful 로그는 [선별 로그](publication-studio.log)에 보존했다. [게시 결과](publication.json).

게시 시각은 UTC2026-11-05 04:28:12(로비),04:29:05(배틀), Toronto2026-11-04 23:28:12/23:29:05다. Roblox 숫자 버전은 조회하지 못했으며 로컬 파일 Edit 세션의 PlaceVersion0을 게시 버전으로 보고하지 않는다. Studio 스크립트 자산 버전 이력 업로드에HTTP429가 있었지만 Place 게시 자체는 두 곳 모두 성공으로 반환됐다. 실제 게시 클라이언트 플레이·왕복 이동·실기기는 후속 QA다.

검증된 빌드 소스3360af8에 주석 태그v0.73.2를 생성·푸시한다. TD Place/공개 범위는 변경하지 않았다.
