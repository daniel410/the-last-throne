# HP/MP 자연 회복 제거·무료 보급 계정1회

> **후속 결정:** [0.75.14 MP 자연 회복 복구](../mana-regen-restored-20261105/README.md). 아래0.75.13 기록은 당시 상태로 보존하며 HP 자연 회복 제거·무료 보급1회 제한은 계속 유지한다.

2026-11-05 · TLT-027/029/041/043/050/052/057/084 · ENG → QA · 0.75.13 로컬 구현·미게시, 부모 티켓 In Progress.

사용자는 HP/MP 자동 자연 회복 제거를 요청했고 이어 게임 시작 때 최초 보급 외 무료 보급 중단을 요청했다. [직전 원인 리뷰/비교 조사](../../research/2026-11-05-gold-potion-pressure-review.md)를 재사용하며 이번 값은 새 밸런스 제안이 아닌 사용자 지시 반영이다.

## 변경

- `CombatService.stepPlayer`에서 전투/비전투 HP/MP 자연 회복 루프를 제거했다. Config의 HP회복률·MP회복률·Mage/Elf배율·회복 대기와 시전/캐릭터의 회복 타이머도 제거했다. Roblox 기본 HP 회복을 막는 `src/character/Health.server.lua`는 유지한다.
- 물약, Selene/기술 회복·보호막, 레벨업 HP/MP 전회복, 새 캐릭터 스폰의 가득 찬 초기 자원은 별도 기능으로 유지한다. 레벨업 보너스를 없앤 변경으로 보고하지 않는다. Stamina나 스킬 MP비용/쿨다운도 변경하지 않았다.
- 무료 물약·Tempered 무기/추가 방어구/장신구 키트·Iron Ore24/Soft Hide8은 **계정의 첫 영웅 생성1회**만 지급한다. 첫 HP물약은 Small3/Medium2/Large1/XL1, 총7개/명목2400HP다. 첫 영웅이 Mage면 MP도 같은 개수7개를 지급한다. 기존 미수령 Small HP5개 추가 지급은 중단했다.
- 후속 영웅은 자기 클래스 Training 기본 무기, 기사는 Training Shield만 지급한다. 첫 키트의 계정귀속 물품은 기존 창고/이동 계약으로 공유할 수 있으며 후속 영웅의 물약은 구매 가능하다. 기본 무기 지급을 반복 물약/성장 보급과 구분한다.
- `starterSuppliesClaimed` boolean을 영웅/아이템과 같은 계정 키에 저장한다. 이전 계정에 영웅이 있으면 이미 수령한 것으로 처리하고 마이그레이션한다. 새 영웅/재접속에서 재지급하지 않으며 boolean은 프로필 검증에 포함한다. 기존 보유·미수령 아이템/강화/영수증을 회수하지 않는다. 퀘스트·처치·로그인 보상과 Selene 첫 지원 체험은 아이템 보급과 별개로 유지한다.
- 기존 골드 리뷰 계산기의 자연HP회복 출력도0으로 갱신했다. 이전 리뷰 TSV는0.75.12의 역사적 증거로 보존하고 보고서에 후속 변경을 명시했다.

## 검증

[순수 검사 기록](tests.log):10개 스위트 총4515 PASS. 기본 전투 규칙125, 초기보급/상점308, 인벤토리271, 경제42, 성장656, 지원권30, Selene체험28, 로그인73, 난이도/강화125, 강화확률2857이다. 첫4클래스별1회 지급, 이후12개 클래스 순서 조합의 무보급·기본 무기, 기존 계정·소진 후 수령표시·재접속·구매/저장 불명 응답/권리 보존을 검사했다. 인벤토리의 pending 사용/용량 검사는 신규 보급을 기대하지 않고 명시적 기존 보상 fixture를 사용한다.

`tests/k0-basic-attacks-native.luau`의 실제 CombatService 소스 복제/내부 진입점 노출 fixture를 로컬 PlaceId0·Player0에서 `run-in-roblox`로 실행했다. 네 클래스 Idle/Block에서 각각 합성60초 동안 HP가 변하지 않고, Mage 시전 후/전직 Magic Archer의 MP도60초 동안 변하지 않는 것을 확인했다. 거의 가득 찬 HP는 Humanoid float32 저장값을 기준으로 비교했다. 물약8종 회복·상한과4클래스 레벨업 회복도 유지했다. **해당8개 사례/109검사 PASS**. [비교 요약](comparison.json), [변경 후 전체 결과](current-native.json), [변경 전 대조](baseline-native.json).

전체 native 스위트는 변경 후1051검사를 시도했으나 **19개 사례 실패가 남아 전체 PASS는 아니다**. CombatService/K0Config/테스트를 변경 전 소스로 바꾼 동일 격리 fixture에서도1047검사 중 **같은19개 사례가 실패**했다. 실제 실패 ID 집합이 같음을 자동 비교했다. 표적/발사체/타격 시점/이전 적 복귀HP 기대 등이 포함되며 이번 자연 회복 제거의 신규 실패로 분류하지 않는다. 원인 수정/현행 사양에 맞는 테스트 정비는 후속이며 실패를 숨기려고 기대값을 바꾸지 않았다.

fixture 준비는 `tests/make_k0_source_probe.py --output-dir /tmp/tlt-no-passive-regen --test-script tests/k0-basic-attacks-native.luau`의 기존 생성기를 사용했다. 현재 src/loading 매핑과200KB를 넘는 비관련 적 클립3개(FrozenValeClips/EmberCalderaClips/K0EnemyClips)는 기존 전용 준비기와 같은 필터로 제외했다. 관련 CombatService/Config 원본은 대체하지 않았다. 실행 명령은 `run-in-roblox --place /tmp/tlt-no-passive-regen/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-no-passive-regen/source-probe.luau`다. 런타임 Player/RemoteEvent 전송·게시 환경/실제 시간 플레이 수용 검사가 아니다.

`git diff --check` 통과. 입력 소스/VERSION 커밋 `24b92f4db81ddf44c437a1d86cf0d03488a678b3`을 먼저 푸시한 뒤 `python3 tools/build-game.py --source 24b92f4 --record docs/evidence/no-passive-regen-20261105/build.json`으로0.75.13 단일 빌드에 성공했다. [기록](build.json)에 소스 커밋/산출물 해시/결과를 남겼다. `python3 tests/single-build.spec.py --artifact builds/0.75.13/TheLastThrone-0.75.13.rbxlx`의 역할10/로딩108·실제산출물 검사 PASS. [산출물 원본 대조](artifact-check.json)는 핵심3모듈의 Source가 고정 커밋과 바이트 일치함을 확인했다. XML Source는 string 태그이므로 ProtectedString 태그를 기대한 첫 대조 스크립트는 실패했으며 실제 태그를 읽도록 교정한 후 통과했다. 새 빌드는 미게시이며 릴리스 태그 없음.

## 한계와 인계

골드 소비·물약 구매/유효회복·MP 고갈·본편 솔로 완결·실계정/실기기/4인+AI 수용은 미검증이다. 물리 클래스와 Mage/마법궁수의 물약 의존도가 달라지므로 다음 PLAN/QA는 같은 장비·레벨·난이도에서 물약 사용/구매, 다운/사망, 클리어시간을 측정한다. 최신 몬스터 강화 및 이번 변경의 게시 후 수용은 별도다. TD 운영·DataStore·실상품·Place 게시·Git 릴리스 태그는 변경하지 않는다.
