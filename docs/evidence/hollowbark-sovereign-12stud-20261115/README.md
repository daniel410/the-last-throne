# Hollowbark Sovereign 12stud 조정

작업: TLT-065/032/033/057/084 후속 · 2026-11-15 · ENG → QA · 소스 수정·로컬 검사 완료.

사용자가 기존 14stud 크기를 12stud로 줄이도록 요청했다. `src/server/World/StoryMonsterSizing.luau`의 HollowbarkSovereign 시각 배율을 `1`에서 `12/14`로 변경했다. `GloamwoodAppearance.attach`가 원본 높이·스킨 모델·hover에 이 배율을 적용한다. TD 원본 GLB/XML·해시·애니메이션, 서버 게임플레이 rig 배율1, 공격 거리·피해·보상은 유지한다. [현재 자산 설명](../../../assets/models/hollowbark-sovereign-td-v1/README.md).

검증 환경: 로컬 Lua/Python. 다음 검사 모두 통과했다.

- `lua tests/hollowbark-sovereign.spec.lua`: 12,687검사. 원본 높이14 × 시각 배율 = 12stud, gameplay rig 배율1, 기존 GW-06 등장·진도·보상 회귀.
- `python3 tests/hollowbark-sovereign-assets.spec.py`: 원본 해시·14stud 템플릿·스킨·10본·양쪽 프로젝트 연결 보존. 출력의 14stud는 원본 템플릿 높이이며 TLT 표시 높이는12stud다.
- `python3 tests/story-monster-sizing.spec.py`: 기존23종 크기 회귀 통과.
- `git diff --check`: 통과.

미검증: Studio 실제 스폰/스킨·공격 접점·카메라, 게시 클라이언트, 실기기, 사용자 수용. 빌드·Roblox 게시·릴리스 태그는 수행하지 않았다. 상위 티켓/게이트 완료 상태는 변경하지 않는다.

다음 담당: 빌드/QA 담당자가 새 빌드의 GW-06 마지막 후위 전투에서 `TdMonsterTargetHeight=12`와 실제 외형·지면 접점·공격 가독성을 확인한다.
