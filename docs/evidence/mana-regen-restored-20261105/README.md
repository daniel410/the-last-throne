# MP 자연 회복 복구

2026-11-05 · TLT-008/015/027/050/052/057/084 · ENG → QA · 0.75.14 로컬 구현·미게시.

디아블로 회복 비교 뒤 사용자는 MP 자연 회복을 다시 복구하라고 지시했다. [공식 자료 조사](../../research/2026-11-05-diablo-reference-and-recovery.md)는 HP/자원을 구분하는 배경 근거이며, 이번 회복 속도는 디아블로 수치를 복사한 것이 아닌 기존 TLT 계약 복구다.

## 변경

- 서버 MP 회복과 Config의 기본0.15%/초·Mage/Elf2배·마법 기술 사용 후1초 대기를 복구했다. Mage 최대MP100은 초당0.30, 첫 전직 Magic Archer 최대MP80은 초당0.24다. 최대MP와 INT/레벨 성장에 비례하며 `setMana`로 상한을 지킨다.
- 마법 기술의 확정 MP차감 시 회복 대기를 갱신하고, 캐릭터 상태 생성 때 회복 시각을 초기화한다. 시간경과 샘플은 기존처럼 프레임당0.25초까지로 제한한다. 사망한 영웅은 회복하지 않는다.
- HP 자연 회복은 복구하지 않는다. 기존 HP 기본회복 차단 Script, 무료 보급 계정 최초1회/추가 미수령HP5개 중단, 물약/레벨업/Selene 회복·스킬MP비용/쿨다운과 MP해금 조건은 유지한다. MP 없는 Knight/Dwarf/미전직 Elf에게 새 MP를 만들지 않는다.
- 공통 지침·리서치 역할·스탯 문서·결정표와 진입 요약을 최신 결정으로 갱신하고, 이전 HP/MP 동시 제거/디아블로 첫 조사에는 후속 결정 링크를 붙였다. 역사적 증거는 덮어쓰지 않았다.

## 검증

- [순수 검사](tests.log): 전투 규칙125, 초기보급/상점308, 영웅 성장656 PASS.
- `tests/k0-basic-attacks-native.luau`: 기존 격리 Source fixture를 `/tmp/tlt-mana-regen-restored`에 생성하고 `run-in-roblox --place /tmp/tlt-mana-regen-restored/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-mana-regen-restored/source-probe.luau` 실행. 비관련 loading/대형 적 클립 제외 방식은 [앞선 fixture](../no-passive-regen-20261105/README.md)와 같다.
- **관련8개 사례/111검사 PASS**: Mage 실제 시전MP차감/대기/회복량/상한/사망, Magic Archer 회복량/대기/상한/HP미회복, 네 클래스 Idle/Block HP미회복, 물약8종 회복·상한, 레벨업 회복 보존. [소스 해시·비교](comparison.json).
- 전체 native는1053검사 중 **기존 동일19개 사례 실패가 남아 전체 PASS는 아니다**. 바로 전0.75.13 및 변경 전 대조와 실패ID집합이 같음을 자동 확인했다. 표적/투사체/구형 전투 기대값 관련 잔여 한계는 별도이며 이번 변경 때문에 신규 실패가 늘지 않았다. [전체 결과](native.json).
- 로컬 PlaceId0·플레이어0, 실제 CombatService/Humanoid와 합성 시각/신원 fixture다. 실제 Player/네트워크/클라이언트/기기 검증으로 해석하지 않는다. `git diff --check` PASS.

VERSION0.75.14와 입력 소스 `c8b0492698bcb1e318ed8c1c65859ff1c072b9c3`을 먼저 커밋·푸시한 뒤 `python3 tools/build-game.py --source c8b0492 --record docs/evidence/mana-regen-restored-20261105/build.json`으로 단일 빌드에 성공했다. [빌드 기록](build.json)에 고정 소스/산출물 해시를 보존했다. `python3 tests/single-build.spec.py --artifact builds/0.75.14/TheLastThrone-0.75.14.rbxlx`: 역할10/로딩108·실제산출물 검사 PASS. [핵심2모듈 Source 대조](artifact-check.json)에서 고정 소스와 바이트 일치를 확인했다. 게시/릴리스 태그 없음.

미검증: 실전 MP고갈·기술 사용 리듬/물약 구매/골드 소비·실계정/실기기·4인+AI·최종 밸런스 수용. 다음 PLAN/QA는 같은 레벨/장비에서 복구 전후 기술 사용률·자원 부족 시간·MP물약 사용/구매·보스전 시간을 비교한다. 부모 티켓은 In Progress를 유지한다.
