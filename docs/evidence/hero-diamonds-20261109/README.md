# 영웅별 Diamonds 보상 · 0.92.0

2026-11-09 · TLT-027/041/050/052/057/084 · ENG → QA · 로컬 구현·미게시.

## 최신 지시와 동작

사용자가 다른 영웅으로 완료해도 보상하도록 지시했다. 이전의 계정당 난이도별1회 선택보다 이 후속 지시를 우선한다. **영웅·메인 스토리ID·난이도마다 최초3 Diamonds**, 신규 영웅35스토리×4난이도=420개·현재4클래스 전체1680개다. 다른 영웅은 각각 지급하고 같은 영웅의 같은 스토리/난이도 반복·사이드는 추가0이다. 다이아는 기존 공유 계정 지갑에 합산한다.

`wallet.heroClaims[heroId][storyId][mode]`에 영속 영수증을 저장한다. 영웅 소유권·메인ID·난이도·수령 여부를 확인하며 완료/잔액/영수증을 계정 단일 저장에서 함께 확정한다. Gold/XP/재료/장비/가격/난도·입장조건/TD 권리는 보존한다. UI의 퀘스트/잔액 부족/원정 상세 안내를 once per hero로 갱신했다. [경제 영향·비교 근거](../../research/2026-11-09-hero-diamonds.md).

## 기존 저장 이관

기존 `claims`/`difficultyClaims`는 지급 영웅 정보를 저장하지 않았다. 영웅 원장이 없는 계정은 해당 완료가 확인된 영웅ID 정렬 순서로 이미 지급한 몫을 한 영웅에게 연결한다. 이 연결 자체는 추가 지급하지 않는다. 이후 모든 영웅의 저널(Easy)·원정 완료(각 난이도)에서 미수령분만 복구한다. 원장을 만든 뒤에는 기존 계정 영수증을 다시 귀속하지 않는다. 기존 계정 영수증·지갑 소비잔액과 DW구수령2개를 보존하며 소급1개 보충 없음. 무지갑 저장도 과거DW2개 이관 후 영웅별 누락분을 복구한다.

예:4영웅이35×4를 완료했으나 계정 기준420개만 수령하고 잔액5인 저장은1260개 누락분을 추가해1265가 된다. 재접속/콜백 재실행으로 재지급하지 않는다. 상한에서는 누락분 영수증을 소진하지 않고 소비 후 다음 계정 로드에서 복구한다. 실제 게시 때 로비/배틀을 같은 새 버전으로 갱신하고 구 서버 writer를 교체해야 한다.

## 검증

- [관련12개 회귀](regressions.json): **20,502 PASS**, 모두 종료0. 핵심 `tests/difficulty-diamonds.spec.lua` **3,128 PASS**는 실제4클래스×35스토리×4난이도=1680 지급, 같은 영웅 중복0, 미소유 영웅/잘못된 영수증 거부, 기존 계정420 몫 보존·다른 영웅1260 누락분, 소비 후 로드/상한·UpdateAsync 응답 불명·Hard 마지막 완료 저장 재시도/재접속을 확인했다.
- 기존2영웅 Easy·무지갑 DW2개 이관/누락분·경제·Gold교환·초기화권·캠페인 순서/확장·완료 보상·난도/미리보기 회귀 포함. 이전 작업에서 확인한 변경 전 실패 `difficulty-enhancement.spec.lua`는 그대로 별도 후속이며 이번12개 통과에 포함하지 않았다.
- `python3 scripts/simulate_story_progression.py --output /tmp/tlt-hero-diamonds-progression.json` 종료0·정본 미수정. `git diff --check` 통과.
- [격리 UI 사전 검증](preflight-native.log): 기존0.91.0 Place에 현재 관련 모듈만 주입, **규칙7,564 + GUI39 PASS**. 데스크톱1280×720/모바일가로844×390·667×375에서4모드 once per hero 문구/텍스트 경계와 사이드 제외를 검증했다. 초회 장시간 격리 테스트는 Studio watchdog으로 중단해 기록을 보존했고, 테스트 배치 사이 yield를 추가한 뒤 통과했다. 제품 지급 로직에 대기/시간 의존성을 추가하지 않았다.

## 한계와 인계

실계정/라이브 DataStore·협동·게시 클라이언트·실기기 입력·경제/사용자 수용은 미검증이다. 사용자 Studio·Place 게시·릴리스 태그는 변경하지 않는다. QA는 영웅A Easy3→영웅B Easy3→각 영웅 Hard3→같은 영웅/난이도 반복0과 기존 계정 누락분·저장/재접속·가격 보존을 확인한다. 상위 티켓 In Progress 유지. 기존 사용자 모델/컨셉/무기/아이콘/프로젝트의 미커밋 변경은 제외·보존한다.


## 고정 빌드·원격 마감

소스 `c18bac22fe3f10010c78f639fc6dfca04977d0ff`를 origin/main에 푸시한 뒤 `python3 tools/build-game.py --source c18bac22 --record docs/evidence/hero-diamonds-20261109/build.json`으로 **0.92.0 성공**. [빌드 기록](build.json), 산출물 `builds/0.92.0/TheLastThrone-0.92.0.rbxlx`, SHA256 `6ab8967406e2b1530a968e1bbb2a6def9f3d40e6e3d7dbc5dd4a4e6429f2f0d9` 재확인. 새 LFS 자산/참조 LFS 입력 없음.

다른 장비 작업이 같은 저장소에서 별도 커밋됐으므로 마지막 검증은 위 소스 커밋의 src/tests/tools를 `/tmp`에 추출해 실행했고 관련12개20,502검증이 모두 통과했다. `python3 tools/prepare-hero-diamonds-native.py --fixed-build`도 이 고정 소스에서 생성했다.

`run-in-roblox --place builds/0.92.0/TheLastThrone-0.92.0.rbxlx --script /tmp/tlt-hero-diamonds-native.luau`: **7,564 규칙/저장 +39 GUI=7,603 PASS / 종료0**. [엔진 로그](native.log). 변경 공통/클라이언트·계정 reducer의 고정 Place 원문 일치도 확인했다. 격리 프로필/저장 모형 및 실제 GUI 텍스트 경계 검증이며 실계정/라이브 DataStore/실기기 수용과 구분한다.

고정 빌드/엔진 증거를 후속 커밋으로 같은 main에 푸시한다. 실제 게시/릴리스 태그 없음.
