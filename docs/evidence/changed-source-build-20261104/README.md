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
- 산출물/소스 커밋/자산 해시는 빌드 후 `build.json`에 기록한다. 산출물 내부 변경 소스 일치는 빌드 후 별도 확인한다.
- 이번 작업에서 Studio 네이티브 모션/무기 테스트·실제 렌더·실제 Experience 이동·실기기/4인+AI는 실행하지 않았다. 과거 로컬 로그를 이번 소스의 통과 증거로 사용하지 않는다.
- Roblox 미게시·릴리스 태그 없음. 상위 구현 티켓의 수용 상태는 갱신하지 않는다.

다음 담당: QA — 이 단일 파일의 로비/배틀 실행·모션/무기 표시·게시된 테스트 Experience 간 이동 확인.
