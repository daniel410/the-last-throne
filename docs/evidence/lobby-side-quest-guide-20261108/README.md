# 로비 NPC 사이드 퀘스트 적극 추천 구현

2026-11-08 · TLT-028/031/041/050/052/057/084 · 0.84.0 · ENG/DES/RES → 실제 계정/기기 QA · 미게시

## 플레이어에게 생기는 변화

Tessa에 F/패드X/터치 대화 프롬프트를 추가했다. 신규/미수락은 `!`, 보고 가능은 `?`, 진행 중은 `…`를 선택 영웅별로 표시한다. NPC 상호작용은 일반 인사 대신 추천 의뢰1개/전체 목록·부탁 이유·남은 행동·실제 보상 창을 연다. 숨은 의뢰는 현장 소문만 제공하고 발견/수락/전투를 자동 달성하지 않는다. 기존 사이드12개만 사용하며 GW/HG에 없는 의뢰를 생성하지 않는다.

귀환/접속 때 새 안내 묶음을1회 알리고 Find Tessa/Later를 제공한다. 안내 확인은 영웅별 최대12키의1/2상태로 저장해 재접속 반복을 억제하며 미수락 표식은 유지한다. 새 보고 상태는 다시 알린다. 위치 찾기는 Dawnspire 안내도·금색 선·기존 지도 Tessa 바로가기와 최대30초의 개인 강조/거리 표시를 사용한다. 지도에서 NPC로 자동 이동/텔레포트하지 않는다.

12개 보고 목표의 명시적 허용표를 검토해 현장 필수 목표/기존 보고 선행을 만족한 경우에만 Tessa 근처에서 보고한다. 초회는 기존 InventoryRules.story, 활성 원정/반복은 AdventureRules.event로 같은 지급/원정 정산/영수증을 사용한다. 저장불명은 동일 명령으로 복구하고 확정 스냅샷으로 버튼 대기를 해제한다. 기존 규칙/보상/다음 본편 Continue·인간4인/현재AI1·권리/보유품은 유지한다.

## 구현 경계와 보존

- `LobbySideQuests`는 입장 가능·현장 발견·개인/활성 원정·추천/표식·알림 확인·명시적 보고를 정의한다. 클라이언트의 보상/완료 주장·주요 스토리 보고·낡은 원정ID를 거부한다.
- `InventoryService.sideQuest`는 기존 계정 lease/UpdateAsync 경로를 사용한다. 선택 영웅/로비/이동 잠금, 저장불명 동일 작업 복구·계정 이동 펜스를 검증한다. 보고의 초기 거리/생존/스폰 권한은 NPCService/FacilityAccess가 확인한다.
- `sideQuestNotices`는 선택적 필드다. 기존 스키마/기존 계정은 그대로 읽으며 잘못된 로드를 신규 프로필로 대체하지 않는다. 확인 기록과 보상/완료 권리는 별개다.
- `LobbySideQuestGuide`는 기존 TD 테마로 스크롤 카드/44px 액션·패드 포커스/닫기·소형 화면 레이아웃·개인 Billboard/강조를 구성한다. 실패/로드 대기/영웅 변경 시 잘못된 표식/이전 알림을 숨긴다.

## 검증

- `lua tests/lobby-side-quests.spec.lua`: **539 PASS**.12개 초회/활성 원정/반복의 현장 보고와 동일 결과, 보고 전 선행 차단·구원정ID·중복 요청·영웅 구분·확인 후 표식 유지·새 보고 알림·스냅샷 정산·UpdateAsync 콜백 반복/응답 유실을 검사했다. 전투 의뢰의 Hard/Insane/Hell은 규칙1로 고정한 기존 원정의 실제 지급과 비교했다.
- `lua tests/inventory.spec.lua`: **271 PASS**, 소유/용량/스택/중복/귀속·계정 복구 회귀.
- `lua tests/side-quest-review.spec.lua`: **1,610 PASS**, 기존12개/44목표/11전투/선택2 목표 진행·이어하기·난도 회귀.
- `lua tests/quest-completion-rewards.spec.lua`: **1,416 PASS**, 기존47개 지급/19개 누락분·계정/가방/저장 복구 회귀.
- `lua tests/campaign-reorder.spec.lua`: **1,871 PASS**, 기존 순서/저널·필수 경로/보상 유지, 산술 최종Lv44.
- `python3 tools/prepare-lobby-side-quests-native.py` + `run-in-roblox --place <로컬 산출물> --script /tmp/tlt-lobby-side-quests-native.luau`: 격리 placeId0·접속자0에서 실제 변경 모듈 Source 일치/문법·TD GUI·표식/지도·보고 상태·로드 실패·로비 외 숨김·실제 NPCService 소스의 가짜 전송/거리/주입 차단을 검사했다. **85 PASS**(800×510 / 726×299 / 270×510 생성/텍스트 검사 포함). 최종 고정 빌드도 같은 검사를 다시 실행해 마감 기록에 추가한다. 기존203785492 자산종류 경고1개는 이번 변경과 무관하며 검사 통과와 구분한다.
- `git diff --check`/선별 스테이징 검사. 사용자 Blender/삭제 컨셉/미추적 증거는 제외한다.

## 빌드와 남은 검증

새 기능 묶음으로 VERSION을0.83.7→0.84.0으로 올린다. 입력 소스 커밋/단일 파일/해시/성공은 build.json에서 고정한다. 실제 릴리스 태그·Roblox 게시·live DataStore 변경은 하지 않는다. 사용자 Studio는 플레이 상태로 확인되어 현재 세션을 중단하거나 핫패치하지 않았다. 격리 엔진 검사와 현재 플레이 세션 적용을 구분한다.

실계정 저장·실제 PC/터치/패드 입력·멀티플레이·게시 테스트 이동/귀환·30초 인지 목표·최종 미술/가독성 수용은 미검증이다. 다음 QA는 새 빌드의 신규/중간 진행/기존 완료·영웅 전환·실제 보고/재접속과 NPC를 스스로 찾는지 확인한다. 부모 티켓은 미완료다. 근거: [최신 계획](../../production/lobby-side-quest-npc-2026-11-07.md), [구현 조사](../../research/2026-11-08-lobby-side-quest-guide.md).

## 고정 빌드 마감

소스 `fa4064e3954a19bcd5803e30d1a5752f8af3f0d0`를 origin/main에 푸시하고 단일 빌드 **0.84.0 성공**. [build.json](build.json)의 `builds/0.84.0/TheLastThrone-0.84.0.rbxlx`, 15,027,335bytes·SHA256 `b0dcfcfd1b912c9056e59682a58e140bf9645c9ee161d6336a8051de51549bb5`를 재확인했다. 빌드 도구가 마운트된 LFS 입력을 해시로 검증했다.

고정 산출물에서 변경10개 모듈 Source 일치/문법 검사 뒤 **엔진85검사 PASS**. [native.log](native.log)·[기계 판독 결과](native-result.json). `python3 tests/single-build.spec.py --artifact builds/0.84.0/TheLastThrone-0.84.0.rbxlx`도 역할10/도착 로딩192·프로젝트/별칭·실제 파일 검사 PASS. [순수 회귀5종](regressions.json)의5,707검사와 구분한다. 현재 플레이 중인 사용자 Studio·Roblox 게시·live DataStore·릴리스 태그 변경 없음.
