# Gloamwood 에픽2 게임 적용 · 0.81.0

2026-11-07 · TLT-001/050/057/061~065/084 · ENG/QA · 로컬 구현·격리 엔진·현재 Studio 적용 / 미게시

사용자의 “게임에 적용해줘” 지시로 **Deepwood → Gloamwood → Frozen Vale → Ember Caldera → Haunted Graveyard** 순서를 적용했다. [승인 줄거리](../../production/five-epic-adventure-story-2026-10-30.md)와 [영어 연결 원고](../../production/gloamwood-second-story-2026-11-07.md)를 따른다. 새 기능 묶음으로 버전0.81.0을 예약하며 빌드 입력은 소스 커밋으로 고정한다.

## 변경과 저장 계약

- `CampaignContent`가 원본 제작 모듈을 복사해 현재 번호·에픽·목표/지역 입장 조건을 투영한다. 원본의 구순서 번호·레벨은 별도 메타데이터로 보존한다. DW/GW/FV/EC/HG ID·목표/단계 ID·35개 본편·12개 선택 퀘스트·고정 보상 정본을 유지한다.
- `CampaignStoryText`로 DW→GW, GW→FV, FV→EC, EC→HG, 최종 정찰대 합류의 영어 목표/대사/완료 안내를 연결한다. 지도·계속 진행·완료 안내·실제 월드 생성이 같은 순서를 사용한다. 지역 사이의 장거리 연결은 해당 에픽의 보행 지형/개인 차단벽으로 만들지 않는다.
- 저널v1을 검증한 뒤 계정 `UpdateAsync`의 기존 소유권/epoch 안에서v2로 이관한다. `main`은 새 순서의 연속 완료 지점이다. `legacyMain`/`legacyResume`은 구순서의 완료·해금·진행 중 한 스토리를 보존한다. 완료/부분 목표·선택·발견·탐색·재료/처치 영수증·Gold·장비·레벨을 지우거나 다시 지급하지 않는다. 기존 FV/EC 완료 영웅은 GW를 마치면 이미 완료한 지역을 건너뛴다.
- 영구 저널과 활성 원정 저널을 모두 이관하고, Selene 지원 계약의 숫자만 동일한 안정 스토리ID의 새 번호로 옮긴다. 계약ID·run 범위·잔여권·무료 체험 사용 여부는 보존한다. 구지역 재도전용 선행 완료 투영은 영구 기록에 합치지 않으며, 재도전 후에는 실제 미완료 GW로 복귀한다. 선택 퀘스트 재도전도 기존 해금을 보존한다.
- 새 원정은 규칙10이다. 일반/보스·지원 증원까지 GW의 Lv28~34를 **Lv12~18**로 낮춘다. FV는+7, EC는+7, HG는+4로 순서에 맞춘 시험 레벨을 사용한다. GW Easy 입장은Lv12이며 기존 FV/EC/HG 입장 레벨은 유지한다. 규칙1~9는 이전 레벨·에픽 보정·처치/완료 보상을 사용한다. 장비/재료 보상 경로는 서버가 선택한 적·임무 레벨을 따른다.
- 지역 번호에 묶였던 월드 생성·겨울 수호수 비살상·화산/숲 보스 바닥 패턴·NPC 지역 스코프·Selene 캠프 접근·개인 지역 게이트를 안정 지역ID/현재 접근 조건에 연결했다. GW/HG가 같은 완료 소품 폴더를 사용해 늦게 생성된 최종전 소품도 개인 완료 상태를 적용한다.

구버전 서버는v2 저널을 이해하지 못해 호환 거부한다. 소유권 fence를 우회하거나v1로 역변환해 덮어쓰지 않는다. 게시 시 로비/배틀을 동일한 고정 파일로 갱신하고 기존 서버의 원정/재접속을 확인해야 한다. 이번에는 실제 게시·라이브 DataStore 이관을 수행하지 않았다. 롤백이 필요하면v2를 읽는 전진 수정 빌드를 사용하며 과거 바이너리를 그대로 재게시하지 않는다.

## 검증

| 명령/환경 | 결과와 범위 |
| --- | --- |
| `lua tests/campaign-reorder.spec.lua` | **1,850 PASS**. 구순서0~35 완료/부분 진행·탐색/선택 수주·잘못된 저장 거부·저장 후 응답 유실·재오픈 멱등·실제 계정 reducer의35본편/보상 재요청·구지역/선택 재도전·Selene 권리 보존 |
| 관련49개 `tests/*.spec.lua` Lua 실행 | **47 PASS / 2 기존 실패**. [전체 결과](regressions.json). `enhancement-probability.spec.lua:25`와 `reward-materials.spec.lua:39`의 기존 아이템nil 참조는 변경 전 `9a5e63e`에서도 재현했다. 해당 테스트와 강화 기능은 이번 범위에서 수정하지 않았다. 기존의 구순서 고정 fixture는 새 순서로 갱신했다. |
| 구소스9a5e63e와 현소스의 규칙1~9 비교 | **3,384행 완전 일치**.47임무×4난도×1/4인×9규칙의 실제 유한 웨이브·적 HP/피해/레벨·처치/완료/재료 보상 비교. [행 수·SHA256](pinned-rules.json) |
| `python3 tools/prepare-campaign-reorder-native.py` → `rojo build default.project.json -o /tmp/tlt-campaign-reorder-final-review.rbxlx` → `run-in-roblox --place /tmp/tlt-campaign-reorder-final-review.rbxlx --script /tmp/tlt-campaign-reorder-native.luau` | **종료0**, 실제 Roblox 모듈에서 계정 검사1,850 PASS + 월드/전투 연결 **916 PASS**. 다섯 에픽·44지역·활성 스폰·실제 목표 생성·겨울 판정/화산 패턴 유지·규칙9/10의 서버 모델 속성/보상 확인. [로그](native-review.log) / [결과](native-review.json) |
| 현재 TLT Studio70829337938054 / Edit·RunService 실행 아님 | 관련22소스 문법 검사·갱신·쓰기 일치 확인. 기존21소스는 Git 이력의 알려진 소스임을 확인하고 `ServerStorage.TLTBeforeCampaignReorder20261107`에 보존했다. 신규 `CampaignStoryText` 추가. 다른 Studio0.79.7은 변경하지 않았다. 복제한 실제 CampaignContent 로드로 DW/GW/FV/EC/HG 순서·GW 완료 안내 확인. 저장/게시 호출 없음. |
| 필수 전투만 사용하는 Easy 솔로 XP 계산 | 모든 임무 입장 조건 충족. Deepwood 종료Lv12 → GW 종료Lv16 → FV 종료Lv24 → EC 종료Lv33 → HG 종료Lv43. 구매·지원·선택 퀘스트·반복 파밍 없이 입장 가능함을 검사했으며 실제 전투 난도·Lv80 성장 수용을 뜻하지 않음. |
| `git diff --check` | PASS. 기존 Blender 변경·이미지 삭제·로컬 첨부/생성 파일 제외. 보상 JSON과 기존 모델/텍스처는 무변경. |

엔진 로그의 기존 `rbxassetid://203785492` 타입 불일치 경고는 남아 있으며 검사 실패로 숨기지 않는다. 신규 모델/자산 업로드는 없다. 이번 순서 변경은 기존 [Diablo II 비교](../../research/2026-11-07-gloamwood-story-order.md)의 구조→단서→길 개방 원리를 적용하며 다른 게임의 자산이나 규칙을 복제하지 않는다.

## 고정 빌드와 남은 수용

빌드 입력/산출물/SHA256은 마감의 `build.json`에 기록한다. 원격 소스 커밋 고정 후 `python3 tools/build-game.py --source HEAD --record docs/evidence/campaign-reorder-20261107/build.json`을 실행한다. 실제 Roblox 게시·릴리스 태그는 이번 작업에 포함하지 않는다.

정상 전투 전 구간 완주·실제 계정 이관·게시된 로비/배틀 Teleport·재접속·실기기/4인+AI1·거미 여왕 전투 난도·두 숲의 차이/목적지 이해도는 미검증이다. GW 출구의 설산 노출은 현재 영어 서술이며 별도 신규 배경 연출을 제작하지 않았다. 최종Lv80 성장/전직 도달 속도·드롭/경제·수치 밸런스는 후속 수용 대상이다. 다음 QA는 고정 파일에서 이 항목들을 확인하며 부모 티켓을 Done으로 바꾸지 않는다.

## 고정 빌드 마감 결과

소스 `7ef7b8141f3ac946b31d78ddb1abc3c3de5c330c`을 origin/main에 푸시한 뒤 빌드 성공. 단일 파일은 `builds/0.81.0/TheLastThrone-0.81.0.rbxlx` (14824159bytes), SHA256 `09b3d62e54fd4a52045f5a58f75b443dada21d670ab6e6e578a2051d6fa569dc`이다. [빌드 기록](build.json). 같은 고정 파일에서 계정/진행 **1,850 PASS + 실제 월드/전투 연결916 PASS·종료0**를 재확인했다. [고정 빌드 로그](native-fixed-build.log) / [결과](native-fixed-build.json). 기존 자산 타입 경고는 로그에 보존했다. 실제 Place 게시·릴리스 태그는 없다.
