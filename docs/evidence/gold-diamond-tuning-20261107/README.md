# Gold·Diamonds 보상 조정 · 0.82.2

2026-11-07 · TLT-027/041/050/052/057/084 · ENG/QA → QA · 사용자 승인 구현·현재 Studio 적용·미게시.

## 변경과 근거

사용자가 반복 완료Gold20%감소·Deepwood 첫 클리어Diamonds2→3안을 승인했다. 기존 [경제 검토](../../research/2026-11-06-weapon-enhancement-gold-review.md)의 전투→Gold/재료→장비 성장 원칙과 소비 대비 유입 문제를 재사용한다. 이전 대화에서 [Diablo III 공식 장인 가이드](https://us.diablo3.blizzard.com/en-gb/artisan/blacksmith/)의 Gold/재료 투자 순환을 재확인했다. 비교 게임 수치나 신규 소비처를 도입하는 작업이 아니다.

- `Difficulty` 신규 원정 규칙11: 반복 완료Gold만 기존 난이도/레벨 보정 후 정수금액×4/5 내림. 표가 없는 Gloamwood/사이드의 기존 대체예산에도 적용한다. 원정 규칙1~10과 재접속/같은 영수증 재시도는 기존 보상을 유지한다.
- DW-05 Easy 반복: 완료135→108, 처치164 유지, 총299→272Gold. 총수입 전체를20% 줄이는 변경은 아니다.
- `EconomyCatalog.storyDiamonds`: 미수령 Deepwood7개 메인 첫 완료당 계정1회2→3(신계정 전체14→21). 다른 지역·사이드·반복·같은 스토리를 다른 영웅으로 완료하면 추가Diamonds0.
- 기존 지갑/수령 플래그/소비잔액은 보존하고 소급 보충하지 않는다. 지갑이 없는 과거 저장의 완료 기록 이관은 당시2Diamonds를 유지한다. 이후 새로 완료하는 미수령 스토리만3개다.
- 첫 완료Gold·처치Gold·XP·재료·전투/성장·가격/환율·강화25Gold·TD 지갑/권리는 유지한다. Diamonds→Gold 환전1:50 유지로 새계정의 추가7Diamonds는 최대350Gold 환전 여지가 있다. 실제 경제 효과는 측정 대상이다.
- 표시 UI는 기존 `Difficulty.completion` 데이터를 공유하므로 신규 원정 미리보기와 지급을 함께 갱신한다. 새 화면·문구는 추가하지 않는다.

## 검증

- [관련7개 Lua 결과](regressions.json): **6,573 PASS**. 신규 조정1,892·경제42·난도2,661·미리보기22·출발42·원정저장43·캠페인이관1,871. 전지역/난이도의 완료 보상·처치/전투 보존, 새/기존 지갑·중복/소비잔액·미수령 구분과 실제 계정 reducer/저장 재시도 회귀를 포함한다.
- 변경 전 Git `Difficulty`를 `/tmp`에 추출해 규칙1~10×전체 스토리×4난이도 **16,920 보상필드 동일** 확인.
- 현재 TLT Studio70829337938054 Edit: 세 모듈의 기존 소스가 변경 전 Git과 일치함을 확인하고 새 소스 문법 검사 후 동기화했다. `ServerStorage.TLTBeforeGoldDiamondTuning20261107`에 백업. 별도0.79.7 Studio·모델/이미지·실계정·DataStore·게시에는 접근/변경하지 않았다.
- 고정 빌드와 Luau 엔진 검증은 아래 마감 기록에 연결한다. 일반 빌드이며 실제 Roblox 게시·릴리스 태그는 없다.

## 한계와 인계

실제 계정/클라이언트·실기기·협동·플레이시간당 순Gold/다이아소비·사용자 수용은 미검증이다. QA는 기존 진행 원정의 구보상, 신규 원정 표시/지급, 첫 클리어3Diamonds와 재접속/다른 영웅 중복0, 환전 후 순유입을 확인한다. 부모 티켓은 In Progress로 유지한다.

## 고정 빌드 마감

소스 `dbe01cd7b8fc070348d4f819757fd8288b9218c1`를 origin/main에 푸시한 뒤 단일 빌드 **0.82.2 성공**. [빌드 기록](build.json)의 산출물 SHA256 `2536b8eb10431fc1a983211fc263013e86818d27a15b7b579c15ee449c859c0c`을 재확인했다.

`python3 tools/prepare-gold-diamond-native.py` → `run-in-roblox --place builds/0.82.2/TheLastThrone-0.82.2.rbxlx --script /tmp/tlt-gold-diamond-native.luau`: **4,617 PASS / 종료0**. 고정 Place의 세 모듈 원문 일치도 확인했다. [엔진 로그](native.log). 기존203785492 자산 타입 경고는 테스트 실패와 구분한다. 생성기를 재실행해 검증에 쓴 임시 runner와 바이트 일치 확인. 격리 계정/저장 모형이며 실계정·라이브 DataStore 검증이 아니다.

`python3 scripts/simulate_story_progression.py --output /tmp/tlt-gold-diamond-progression.json` 종료0. 기존 승인 XP/Gold 정본을 덮어쓰지 않았다. `git diff --check` 통과. 신규 LFS 자산 없음, 실제 게시·릴리스 태그 없음. 다음 QA는 위 실계정/기기 경제 수용을 담당한다.
