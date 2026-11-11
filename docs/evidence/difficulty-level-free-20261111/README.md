# Hard/Insane/Hell 레벨 제한 제거

2026-11-11 · TLT-027/028/050/084 · ENG → QA. 상태: 소스 구현·순수 Lua 검증 완료, 엔진/게시 수용 대기. 상위 티켓/게이트 완료 처리 없음.

## 변경과 근거

최신 사용자 요청 “하드, 인세인, 헬모드 레벨 제한없애줘”를 적용한다. 공통 `Difficulty.requiredLevel`에서 상위 모드의 요구 레벨을0(조건 없음)으로 반환한다. 따라서 기존30/60/80과 임무별 하한이 솔로·파티·도착/재접속 검사에서 더 이상 적용되지 않는다. 선택 UI는 요구 레벨0인 모드의 Lv 표시를 생략한다.

스토리 선행·같은 임무의 이전 난이도 클리어·비전투 임무 제한, 영웅 소유/준비/원정 식별 검사는 유지한다. Easy 입장 하한과 적 레벨·피해/HP·보상·저장 버전14는 변경하지 않는다. [입장 사양](../../production/difficulty-rewards-and-entry-plan-2026-11-02.md#2-난이도와-입장-조건) · [비교 조사](../../research/2026-11-11-difficulty-level-free.md).

## 검증 조건과 결과

저장소 루트, `/opt/homebrew/bin/lua`에서 실행했다. [실행 로그](tests.log).

| 검사 | 결과 |
| --- | --- |
| `lua tests/difficulty-level-free.spec.lua` | 633 통과: 전 전투 임무의 Lv1 자격·이전 클리어/스토리 거부, 버전1~14 입장/재접속, Easy/비전투 조건 |
| `lua tests/expedition-presentation.spec.lua` | 24 통과: 요구 레벨0 투영, Lv1+Lv80 혼합 파티, 4인 각 모드, 준비/이동/이전 클리어 거부 |
| `lua tests/expedition-departure.spec.lua` | 42 통과: 원정 출발 회귀 |
| `lua tests/difficulty-balance.spec.lua` | 2,665 통과: 적/보상·버전 호환 회귀 |
| `lua tests/difficulty-enhancement.spec.lua` | 입장 검사633개 통과 후 기존 Easy 스토리 완료 헬퍼에서 `StoryLocked` 실패 |
| 변경 전 `HEAD`의 Difficulty·종합 테스트를 /tmp 사본으로 실행 | 같은 Easy 스토리 완료 헬퍼에서 `StoryLocked` 재현. 이번 변경 전부터 존재한 실패로 분리 |
| `git diff --check` | 통과 |

독립 검사4개 총3,364건 통과. 종합 테스트 전체가 통과했다고 간주하지 않는다. 기존 실패의 재현은 `git show HEAD:src/shared/Difficulty.luau`와 `git show HEAD:tests/difficulty-enhancement.spec.lua`로 /tmp 사본을 만든 뒤, 종합 테스트의 `dofile('src/shared/Difficulty.luau')`만 원본 사본으로 연결해 수행했다. 다른 런타임 파일은 작업 중 변경하지 않았다.

## 미검증과 다음 담당

게임 빌드·Roblox 게시를 수행하지 않았으며 VERSION/릴리스 태그를 만들지 않았다. Studio 실제 UI 표시·Teleport/게시 클라이언트·실계정 저장/재접속·실기기·낮은 레벨의 전투 밸런스·사용자 수용은 미검증이다. QA는 이후 빌드에서 모드 버튼의 요구 레벨 제거와 조건 충족 Lv1 파티의 실제 출발/도착/재접속을 확인한다. 기존 종합 테스트의 확장 스토리 헬퍼 갱신은 별도 후속이다.
