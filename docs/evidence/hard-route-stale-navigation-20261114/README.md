# 하드모드 이전 원정 좌표 잔류 수정

2026-11-14 · TLT-050/084 · ENG → QA. 로컬 구현·빌드·Studio 검증. 게시/실기기/사용자 수용은 미검증이며 상위 티켓을 Done으로 변경하지 않는다.

## 원인과 수정

사용자는 Hard에서 네비가 안내한 `Route 2 / 6` 위치에 도착해도 적이나 상호작용 대상이 없어 진행할 수 없다고 보고했다. 같은 영웅으로 원정을 다시 시작하면 이전 교전은 정리 유예 동안 서버에 남는다. 기존 `DeepwoodService.encounterState`는 영웅ID만 확인해 이전 원정의 위치·웨이브를 새 원정에 전송했다. 서버의 생성 조건은 현재 원정ID를 확인하므로 옛 목적지에 도착해도 해당 교전을 시작하지 않는다. 같은 목표의 새 교전까지 있으면 테이블 순회 순서에 따라 옛 상태가 덮어쓸 수도 있었다.

0.107.8 실제 Studio Play에서 동일 영웅의 새 Hard 원정이 처치 기록 없이 시작됐는데도 이전 교전의 wave 2/remaining 2가 투영되는 것을 확인했다. 별도 회귀는 이전 원정을 첫 무리 처치 후 waiting 상태에 남긴 뒤 새 원정을 생성해, 수정 전 `new run hides the old run encounter before its first approach`에서 실패한다. [수정 전 로그](native-before.log).

서버 투영을 영웅ID와 현재 원정ID가 모두 일치하는 교전으로 제한했다. 원정 없는 기존 교전은 nil ID끼리의 기존 비교를 유지한다. 적 생성·처치·보상·저장 원천, 입장 조건, 몬스터/아이템 수, TD는 변경하지 않는다. 변경 파일은 서버 서비스, 실제 런타임 회귀, 빌드 VERSION 및 이 증거/상태 링크다. 원복은 해당 수정의 일반 revert 커밋으로 수행하며 계정 데이터는 삭제하지 않는다.

## 검증

- [빌드](build.json): **0.107.9**, 소스 `1245bd82243d9e1cc01c423c1f3ca1363dd94afd`. `python3 tools/build-game.py --source 1245bd82 --record docs/evidence/hard-route-stale-navigation-20261114/build.json`. 단일 산출물 `builds/0.107.9/TheLastThrone-0.107.9.rbxlx`, SHA256 `d604555ba971541ddee401ec11e0872827c31171ffa171ddd08d86639bfb3276`.
- `python3 tools/prepare-campaign-combat-routes-native.py --runtime-only` 후 고정 산출물에 `run-in-roblox` 실행. 15개 관련 모듈 소스 일치와 전체 Luau 문법 검사 후 **823 검사 통과**. 새 Hard 재입장 시 이전 위치 숨김, 실제 Journal의 새 첫 목적지, 옛 교전과 새 교전 공존, 새 첫 적 생성, 원정 유실 시 이전 상태 숨김을 포함한다. 기존 처치 중복 방지·저장된 처치 복구·파티·늦은 도착·개인 리스폰 회귀도 유지한다. [고정 빌드 로그](native-fixed-build.log).
- `python3 tests/single-build.spec.py --artifact builds/0.107.9/TheLastThrone-0.107.9.rbxlx`: 역할 10·도착 로딩 283·실제 산출물 검사 통과.
- 순수 Lua: hard-unlock 56, campaign-combat-routes 77,381, story-lobby-resume 33 통과. story-respawn의 fixture nil 순회와 story-continuation의 52행 StoryLocked는 수정 전 기준 소스에서도 동일하게 실패한다. 전체 정적 검사가 통과했다고 보고하지 않는다. [검사 로그](source-tests.log)·[기준 소스 대조](baseline-failures.json).
- 실제 Studio Play: Easy 첫 무리를 처치하고 같은 Knight로 로비 복귀 → Hard 새 출발. 이전 교전 투영은 비어 있고 클라이언트 네비 앵커가 새 첫 목적지 `(-1595, 0, -823)`를 가리킨다. 첫 무리 처치 후 두 번째 목적지 `(-1550.75, 0, -695.45)`에서도 wave 2/remaining 2/active true를 확인했다. [관측 JSON](play-verification.json)·[격리 서버 프로브](play-probe.luau). 출발은 정상 클라이언트 원격 요청이며 이동은 QA 서버 재배치, 처치는 Humanoid.Health=0 주입이다. 일반 조작으로 전투/보행을 완주한 증거로 취급하지 않는다.

## 남은 수용과 다음 담당

수정본은 로컬 빌드이며 Roblox 게시·릴리스 태그는 만들지 않았다. QA/사용자는 0.107.9에서 Easy 진행 도중 로비로 돌아와 Hard를 새로 시작하고 네비를 따라 첫/다음 교전을 확인한다. 같은 난이도 재시작·파티 재입장과 실계정 저장/재접속·게시 클라이언트·실기기는 후속 수용이다. 사용자 자산의 기존 미커밋 변경은 보존했다.
