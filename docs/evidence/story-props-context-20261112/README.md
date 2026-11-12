# 스토리 물품 맥락·반복 수정 검증

2026-11-12 · TLT-037/057/061~065/084 · DES/ENG → QA · **0.104.13, 로컬 빌드·미게시**

[물품별 사양](../../production/story-props-2026-11-12.md) · [조사/판단](../../research/2026-11-12-story-prop-context.md).

사용자 DW07 화면의 야외 책상/책/잉크 문제와 전체 이야기의 물품 반복을 수정했다. 활동 종류/영문 키워드 추측을 제거하고 안정ID별 물품 지정표를 적용했다. 47개 이야기의 배치 가능한292단계에63종의 새/기존 소품을 연결하며, 별도 단일 목표 물품도 지정한다. 새 native 기하55개는 기본 형태47개+문양 변형8개다. 문서·약품·식량·정찰 장비·설원 신호·광산/냉각 장치·왕릉 결속을 형태로 구별한다. 포털 종료 프롬프트와4개 선택 조사 제목도 물품에 맞춘다.

목표/단계/선택ID·좌표·활동 모드·정답·서버 진행/저장·전투·보상은 유지한다. 실제 Crownheart 개인 장면을 정적 소품으로 복제하지 않는다. 확장 사건의 저장 상태 태그/원래 색, 광산/용광로 조작부의 개인 완료/원래 색 복구를 유지한다.

## 검증 조건과 결과

- `lua tests/story-prop-context.spec.lua`: 4,129검사 통과. 실제 전체 콘텐츠에서 지정 누락·존재하지 않는 참조·목표/단계 분류·가구 대체 금지·지역별 다양성·기하/문양 예산·핵심 사건의 물품 계약 검사.
- `lua tests/campaign-context-review.spec.lua`: 1,054검사·418저장 전이 통과. 원고 외 게임/지역/조건/보상 계약 보존.
- `lua tests/campaign-expansion.spec.lua`: 7,737검사 통과. 35본편/12선택·82사건/246확장 단계의 진행/복구.
- `lua tests/story-fun.spec.lua`: 1,761검사 통과. 기존 순서/정답·부분 진행 재개.
- 변경 Luau 소스/전용 엔진 검사 `luau-compile` 통과. [정적 로그](static.log).
- 실제 Studio 고정 빌드 검사: PlaceId0·플레이어0. 소스 주입 없이 변경 모듈7개의 Source가 작업 원본과 같은지 먼저 검사했다. 새55모델/543원본 파트·1,690검사 통과. 전체5에픽의 스토리 소품482모델/7,717파트·11,430검사 통과. 실제 캠페인 책상 배치0, 목표/단계 앵커 보존, 반복 월드 획득 중복 없음, 확장 사건의 저장 단계/원래 색, 밸브와 교체 보호 릴레이의 완료/색 복구를 확인했다. [최종 엔진 로그](final-native.log).
- 실제 편집 화면: [DW07 제단의 뿌리 봉인/명령서](dw07-roots-final.jpg). 최종 고정 빌드에서 촬영했으며 게임 HUD/플레이어 조작 증거는 아니다.

## 빌드와 재현

입력 소스 `bdbd6c02d8acde32feda58bbf198250ca2432db9`, 버전0.104.13. `python3 tools/build-game.py --source bdbd6c02 --record docs/evidence/story-props-context-20261112/build.json`. [빌드 경로/명령/SHA-256](build.json), [검사 입력 해시](inputs.json). 초기0.104.12는 직선 뿌리의 화면 검토 전 후보이며 [별도 기록](build-candidate-0.104.12.json)으로 보존한다. 최종 산출물을 덮어쓰지 않았다.

검사 명령: `python3 tools/prepare-story-prop-context-native.py --output /tmp/tlt-story-prop-fixed-verification.luau` → `/tmp/tlt-run-in-roblox-50316 --place builds/0.104.13/TheLastThrone-0.104.13.rbxlx --script /tmp/tlt-story-prop-fixed-verification.luau`. 기본 검사기의50312포트는 다른 작업이 사용해 [시작 실패](runner-port-conflict.log)했다. 기존 작업을 종료하지 않고 기본 실행 파일의 포트 상수만50316으로 바꾼 임시 사본으로 격리했다. 로컬 바이너리 사본은 게임 소스/배포물에 포함하지 않는다.

`--review` 화면 대기에서는 두 suite가 모두 통과한 뒤 다른 빈 QA Place가 열려 전역 Studio 플러그인이 그 Place에서 재실행되며 `Server is not a valid member`로 종료됐다([화면 검토 래퍼 로그](review-wrapper.log)). 이 래퍼 종료를 검증 통과로 계산하지 않았다. 최종 검사는 화면 대기 없이 같은 고정 빌드에서 별도로 실행했으며 종료0·`STORY_PROP_CONTEXT_FINAL_PASS`를 확인했다.

## 미검증·다음 담당

Studio의 기하/배치 검증은 실제 사용자 플레이나 미술 수용을 대신하지 않는다. 게시 클라이언트·실계정/재접속·PC/터치/패드 실조작·모바일/다인 성능·최종 미술 수용은 미검증이다. QA는 사용자 DW07 위치의 책상 제거, 문서/지도 습득과 포털4스위치의 접근/문양,5에픽의 물품과 설명 일치, 변경 손잡이와 확장 사건의 개인 저장 색 복원을 확인한다. 게시/릴리스 태그·부모 티켓/G5/G7 완료 처리는 하지 않는다.
