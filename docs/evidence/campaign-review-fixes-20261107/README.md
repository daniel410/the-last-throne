# 본편 순서 개편 리뷰3건 수정 · 0.81.1

2026-11-07 · TLT-001/050/057/061~065/084 · ENG/QA · 로컬 구현·현재 Studio 적용·격리 엔진 검증 / 미게시

사용자가0.81.0 코드 검토의3개 결함을 수정하도록 요청했다. 기존 완료 기록·아이템·보상·Selene 권리·스토리ID와 전투/성장 수치는 유지한다. 원인이 확인된 결함 수정이며 별도 기능 리서치나 밸런스 변경은 수행하지 않는다.

## 수정

1. **P1 / EC→GW 저장 재시도:** `AdventureRules`가 원정별 `completedChapters` 영수증을 기록·검증한다. 스토리 번호가 출발 지역보다 작아도 그 원정에서 완료한 목표의 재전송은 보상/버전 변경 없이 같은 결과를 돌려준다. 기존 영수증 필드가 없는 저장은 허용하고 기존 정방향 재시도 호환도 유지한다. 다른 runID·처리하지 않은 과거 지역·미완료 지역을 위조한 영수증은 거부한다.
2. **P2 / 완료 지역의 지도 잠김:** `CampaignMapScope.progress/status`가 `main`의 연속 번호 대신 실제 `clears`와 진행 자격으로 완료 수/상태를 계산한다. `DeepwoodMap.refreshEpic`의 진행률과 배지를 같은 경로로 연결한다. `main=7`이어도 기존 설원·칼데라는7/7 완료, 미완료 GW는0/7 현재로 표시한다. 칼데라4스토리 완료/5번째 진행 상태와 첫 스냅샷 이전의 빈 상태도 처리한다.
3. **P2 / 옛 묘지 안내:** `CampaignStoryText`가 단일 단계 목표를 개정할 때 상위 목표의 제목/대사와 그 목표 하나를 가리키는 퀘스트 단계 제목도 함께 갱신한다. GW-07 Tali 목표는 HUD/단계/퀘스트 단계 모두 `Ask Tali where the convoy went`이며 설원행 대사를 사용한다. 여러 단계를 가진 목표의 상위 제목은 마지막 단계 제목으로 덮어쓰지 않는다.

## 검증

| 명령/조건 | 결과 |
| --- | --- |
| 새 `tests/campaign-reorder.spec.lua`를 구소스d86930f에서 실행 | `backward completion retry recovers exact frontier` 실패로 이전 결함 재현. [기준선 로그](baseline-regression.log) |
| `lua tests/campaign-reorder.spec.lua` | **1,871 PASS**. 기존1,850검사 + 응답1회 유실/3회 유실→SaveUnknown→재시도·보상/아이템/리비전 불변·위조/다른 원정 거부·비연속 완료 지도·Tali 상위/단계/퀘스트 단계 안내 회귀 |
| 관련49개 Lua 검사 | **47 PASS / 2 기존 실패**, [전체 결과](regressions.json). 강화 테스트 `enhancement-probability.spec.lua:25`, `reward-materials.spec.lua:39`의 기존nil 참조는0.81.0과 동일하며 이번에 해당 기능/테스트는 변경하지 않음. |
| `python3 tools/prepare-campaign-reorder-native.py` → `rojo build default.project.json -o /tmp/tlt-campaign-review-fixes.rbxlx` → `run-in-roblox --place /tmp/tlt-campaign-review-fixes.rbxlx --script /tmp/tlt-campaign-reorder-native.luau` | **종료0 / 계정·진행1,871 + 엔진929 PASS**. 실제 `InventoryService.storyEvent` 본문과 계정 store로3회 응답 유실 후 `valid=false/storyPending` → 재시도 → `valid=true/pending해제/main=8` 확인. 실제 `DeepwoodMap.refreshEpic` 본문·Roblox GUI 객체·기존 TD 테마로 칼데라7/7/완료 배지 확인. 기존5지역/44스폰·목표·규칙9/10 전투/보상 연결 회귀 포함. [로그](native-review.log) / [결과](native-review.json) |
| 현재 TLT Studio70829337938054 / Edit | 변경4소스가 알려진 Git 이력과 일치함을 확인한 뒤 문법 검사·소스 동기화. `ServerStorage.TLTBeforeCampaignReviewFixes20261107`에 기존4소스 보존. 다른0.79.7 Studio·모델·이미지·라이브 저장·게시는 변경하지 않음. |
| `git diff --check` | PASS. VERSION은 MICRO 증가0.81.1. 보상 JSON·전투 규칙10·저널v2·난도/성장 수치는 무변경. |

기존 자산203785492 타입 경고는 엔진 로그에 남아 있으며 검사 실패와 구분한다. GUI 검증은 실제 표시 함수/엔진 속성 검사이며 사람의 화면 관찰·터치/패드·실기기 수용을 대신하지 않는다.

## 빌드·인계

검증 소스를 커밋·푸시해 고정한 뒤 `python3 tools/build-game.py --source HEAD --record docs/evidence/campaign-review-fixes-20261107/build.json`으로 단일 파일을 만든다. 같은 고정 파일의 재검증 결과·소스 커밋·SHA256은 마감 기록을 따른다. 실제 Place 게시와 릴리스 태그는 수행하지 않는다.

다음 QA는 게시된 테스트 계정에서 기존 칼데라 진행·GW 완료 응답 유실/재접속·지도 완료 표시·Tali 안내를 확인한다. 정상 전투 완주·실기기/협동·Lv80 성장 수용은 기존 후속으로 유지하며 부모 티켓을 Done으로 바꾸지 않는다.
