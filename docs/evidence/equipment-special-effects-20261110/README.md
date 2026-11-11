# 장비 특수 효과 확장 검증

> **같은 날 후속 수정:** 아래 당시 기록의 기존 인벤토리 실패를 해결했다. 최신 방어 합계·Traveler 시작 무기에 맞춰 테스트를 수정했고, 인벤토리274개를 포함한10묶음6219검사가 모두 통과했다. [수정·검증 기록](../inventory-fixture-fix-20261110/README.md). 아래 실패 로그는 원래 작업 당시의 증거로 보존한다.

2026-11-10 · TLT-027/029/041/044/052/057/084 · ENG → QA/PLAN · 0.97.0

사용자 지시에 따라 단일 기본 옵션+선택형 특수 효과 계약과 서버/미리보기·가방/상점/강화 표시를 구현했다. [상세](../../production/equipment-special-effects-2026-11-10.md). 기존 활성 장비에는 효과를 임의 배정하지 않아 기본 수치·보유품·강화·가격/영수증·저장 스키마를 유지한다. 기존 에픽 장비를 복원하거나 신규 지급하지 않는다. 별도 작업의 미커밋 자산은 제외한다.

순수 Lua 신규 효과277, 장착 비교52, 고정공격110, 장비가족458, DEX130, 스킬1392, 강화2869, 은퇴486, 삭제171 = **5945검사 PASS**. [명령/결과](tests.log). 신규 검사는 범위별 적용, 가산/상한, 특정 기술, 전 클래스/전직/궁극기 미리보기, 부적합 정의 거부, 인스턴스 효과 무시, 장착/교체/보관/다른 영웅, 강화 불변을 검증한다.

기존 `lua tests/inventory.spec.lua`는 방어 집계 기대5/실제8로 실패했다. 변경 전 `22d8753b4132ff10c2090fa34304fbe04e70f28b`의 src/tests만 임시 archive한 기준에서도 같은 위치·오류를 재현했다([baseline.log](baseline.log)). 기존 장비 밸런스 기대 불일치이며 이번 변경 통과로 보고하지 않는다. 게임 수치나 관련 없는 테스트를 바꾸어 숨기지 않았다.

고정 소스 `072a9dbb4504a7005133673ae72f6860835b504b`를 origin/main에 푸시 후 `python3 tools/build-game.py --source 072a9dbb --record docs/evidence/equipment-special-effects-20261110/build.json`으로 단일 빌드 **0.97.0 성공**. 산출물 `builds/0.97.0/TheLastThrone-0.97.0.rbxlx`, SHA256 `5863e119e80901d672ba4656adb56c48c6209097eadc7f6e78d098e62e7fe686`([기록](build.json)). `python3 tests/single-build.spec.py --artifact builds/0.97.0/TheLastThrone-0.97.0.rbxlx`: 역할10/도착로딩192·마운트/실제구성 PASS.

`run-in-roblox --place builds/0.97.0/TheLastThrone-0.97.0.rbxlx --script tests/equipment-special-effects.spec.lua`: **289검사 PASS**([로그](native.log)). 위277계산 검사에 실제 클라이언트모듈6개/CombatService 로딩7검사, 폭400/900 강화카드 설명·높이4검사, 상점효과1검사를 추가했다. 테스트 전용 메모리 카탈로그에 효과를 넣고 복원했으며 저장/실제 상품/게임 카탈로그를 수정하지 않았다. 실제 플레이어의 서버 타격·조작/시각 캡처 수용을 뜻하지 않는다. 연결된 사용자 Studio에는 소스를 적용하지 않았으며 Roblox 게시/릴리스 태그 없음. 새 LFS 자산 없음. 미검증: 실전 서버의 최종 피해/네트워크, 실제 계정·기기·시각 수용/밸런스. 상위 티켓은 완료 처리하지 않는다.
