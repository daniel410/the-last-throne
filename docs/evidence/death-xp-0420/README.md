# 0.42.0 사망 XP 패널티

2026-10-31 · TLT-005/015/028/050/052/084 부분 구현 · ENG → QA

모험 사망 때 현재 레벨의 모은XP10%를 올림 차감한다. 예:Lv2에서40XP를 모았다면4XP를 잃고36XP가 남는다. 누적 표시는140→136이며 Lv2·스탯·스킬·장비·Gold는 그대로다. XP0/Lv80은손실0, 트레이닝은저장 차감 없이0손실이다.10%는 사용자 미지정 배율에 대한 시험 선택이다. [조사/판단](../../research/2026-10-31-death-xp-penalty.md).

서버의 실제HP0+Died·현재 생명/영웅 검증 경로에서 한 번 호출한다. 저장은 기존 계정 성장 큐/lease와 같은 트랜잭션이며 requestId별 실제 xpLost 영수증을 기록한다. 같은 사망/SaveUnknown 재시도는 이중 차감하지 않는다. 클라이언트 성장 Remote에서는 이 action을 받지 않는다. 죽음/부활 중 별도 HUD 안내로 확인 중→실제 -nXP와 레벨 보호, 트레이닝 제외를 표시한다. 일반 퀘스트 피드백이 이 창을 덮어쓰지 않는다.

## 사전 검증

- `lua tests/death-xp-penalty.spec.lua`:3,575개 통과. Lv1~80/0·소량·상한 부근 XP/올림/누적 바닥·레벨/포인트 보호·트레이닝/클라이언트 차감 거부·영수증/SaveUnknown 재시도.
- `lua tests/k0-hero-session.spec.lua`:99개 통과. 실제 생명 경로에서 모험 사망1회/중복 방지와 트레이닝 예외 인계, 기존 전환/영웅 분리.
- `lua tests/hero-progression.spec.lua`:656개 통과. `lua tests/inventory.spec.lua`:265개 통과.
- 이전0.41.5 별도 로컬 엔진에7개 게임 소스를 주입: `tests/death-xp-service-native.luau`15개 및 `tests/k0-resource-ui-native.luau`4,808개 통과. 실제 성장 큐/세션 저장·커밋 후 응답 유실 주입/동일ID 복구·트레이닝0·종료 flush/재open·정확한 손실 메시지·기존HUD/슬롯/XP 회귀. [사전 로그](prebuild.log). Player/원격 publish는 대역이다.

새 MINOR0.42.0을 예약했다. 다른 진행 중 엘프 활 파일은 포함하지 않고 Git에 고정된 입력만 빌드한다. 고정 소스 `ca5de04`에서Rojo7.7.1로Lobby/Battle0.42.0 빌드를 성공했다. [정확한 명령/소스 커밋/바이트/해시](build.json). Git 커밋을별도 임시 폴더로 추출했으며 두 산출물의7개 변경 모듈이 입력과 같은지 확인했다. [소스 대조](source-verification.json).

## 최종 빌드 검증

- `tests/death-xp-service-native.luau`:**15개 통과**, 실제 큐/세션 adapter·커밋 후 응답 유실/같은ID 복구·4XP 손실·트레이닝 면제·신규 보상 후 이전 영수증 재전송·종료 flush와재open 때6XP 한 번 차감.
- `tests/k0-resource-ui-native.luau`:**4,808개 통과**, 확인 중에 미확정 숫자를 표시하지 않음·실제 손실4XP/레벨 보호·트레이닝0안내·기존XP/스킬/HUD 회귀.
- `tests/battle-bootstrap-native.luau`:**10개 통과**, 최종 Battle 시작/캠페인·필수 원격/4인 계약.
- `lua tests/advanced-skills.spec.lua`:**1,435개 통과**.

[최종 큐/UI 로그](native.log) · [서버 시작 로그](bootstrap.log) · [검증 요약](verification.json). 명령은 최종 Battle에 `--script tests/death-xp-service-native.luau`, `tests/k0-resource-ui-native.luau`, `tests/battle-bootstrap-native.luau`를 사용한다. 앞의 두 검사는 임시 runner `/private/tmp/tlt-0420-native.luau`로순서대로 실행했다. 기존203785492 자산 유형 경고를 보존했으며 위 검사는 통과했다.

초기 순수 Store 검사는 fixture 데이터를심을 때 lease를 빠뜨려 AccountBusy가 발생했다. fixture의 lease/epoch 보존을 고쳐3,575개를 통과했으며 게임 저장 코드는 이 문제 때문에 변경하지 않았다.

 실제 게시 계정·최초 영속 기록 전 서버 강제 종료·기기/정상 플레이 수용은 미검증이다. 영속 이벤트 아웃박스는 추가하지 않았으며 정상 종료는 기존 flush를 사용한다. 상위 티켓은 미완료다. Roblox 게시·릴리스 태그는 이번 작업 범위에 포함하지 않는다.
