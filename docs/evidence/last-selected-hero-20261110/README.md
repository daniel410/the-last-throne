# 로그인 시 마지막 영웅 복원

2026-11-10 · TLT-003/028/057/084 · ENG → QA · 0.95.5 · 구현/로컬 검증, 미게시.

로그인할 때마다 엘프가 선택된다는 사용자 보고의 원인은 HeroSessionService가 로드한 영웅을 ID순으로 정렬한 뒤 첫 영웅을 선택하고 선택 변경을 저장하지 않는 데 있다. 0.79.2의 복귀 heroId 힌트는 배틀→로비 이동만 해결했으며 일반 재접속에는 적용되지 않았다. 명확한 결함 수정으로 제작 스킬의 별도 조사 예외를 적용한다.

계정에 선택적 `lastSelectedHeroId`를 보존한다. 영웅 생성은 생성 트랜잭션에서, UI 선택은 기존 계정 fence의 트랜잭션 성공 후 선택을 확정한다. 같은 영웅 재선택은 쓰기를 생략하며 응답 유실 뒤 재처리해도 revision이 중복 증가하지 않는다. SaveUnknown/AccountBusy는 계정을 비활성화하고 기존 확정 선택을 유지한다. 미보유 영웅은 쓰기 전에 거부한다. 로그인 우선순위는 검증된 배틀 영웅 → 본인 소유 복귀 힌트 → 저장된 본인 소유 영웅 → 기존 ID순 첫 영웅이다. 배틀/복귀 선택과 서버 내부 입장 선택도 저장한다. 로드 실패를 신규 데이터로 대체하지 않는다.

과거 계정에는 마지막 선택 이력이 없어 이를 복구할 수 없다. 저장 필드가 없거나 유효하지 않은 경우에만 기존 기본값을 쓰며, 수정본에서 이후 선택/생성/도착이 저장된 후부터 재접속 복원이 적용된다. 기존 영웅·진행·아이템·재화·스키마 버전은 유지한다.

변경 범위: InventoryRules/InventoryService/HeroSessionService, 두 회귀 검사, VERSION과 상태/증거 문서. 기존 Blender 변경·삭제된 컨셉·로컬 산출물은 제외한다.

검증([명령/결과](checks.log)):

- `lua tests/last-selected-hero.spec.lua`: 21검사 PASS. 실제 reducer/AccountStore 및 InventoryService 함수 본문과 메모리 UpdateAsync 대역으로 생성·선택 저장·다른 서버 open·중복·미보유·실패·커밋 후 응답 유실 복구·기존 계정 보존을 실행했다.
- `lua tests/k0-hero-session.spec.lua`: 141검사 PASS. 실제 세션 서비스의 네 클래스 일반 로그인·UI snapshot·선택 변경→새 세션·실패 시 이전 선택 유지·미보유 거부·복귀 우선권·유효하지 않은 과거 선호값 fallback 포함.
- `lua tests/lobby-return-hero.spec.lua`: 27, `lua tests/story-lobby-resume.spec.lua`: 33, `lua tests/travel-attempt.spec.lua`: 8검사 PASS. 합계230검사.
- 변경 런타임3개 `luau-compile` PASS, `git diff --check` PASS.
- 수정 전 HEAD 본문으로 신규 회귀를 실행하면 각각 마지막 영웅 복원/생성 저장 기대에서 실패한다([기록](baseline.log)). 기존 `tests/inventory.spec.lua`는 수정 전후 동일하게 aggregate armor 기대5/실제8에서 실패한다. 이번 수정으로 기존 장비 수치/기대값을 바꾸지 않았으며 전체 suite 통과로 보고하지 않는다.

미검증: 실제 DataStore·게시 Roblox 클라이언트 로그인/종료/재접속·PC/모바일 화면. Studio 실행/적용·Place 게시·릴리스 태그는 수행하지 않는다. 다음 QA: 네 영웅 계정으로 엘프 외 영웅 선택→플레이→종료→재로그인 시 카드/초상/무기/다음 출발 영웅 유지, 배틀 복귀 후 재로그인 확인. 부모 티켓은 In Progress 유지.

빌드는 소스 고정 후 `python3 tools/build-game.py --source HEAD --record docs/evidence/last-selected-hero-20261110/build.json`으로 만들며 실제 결과를 추가 기록한다.
