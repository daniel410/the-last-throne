# 지정 장비 삭제와 Common/Uncommon 고정 공격력

2026-11-09 · TLT-029/041/043/052/057/084 · 0.89.3: 사용자 지시로 Dawnforge 무기4종·Sentinel Gauntlets·Ruby Ring·Storm Pendant의 Rare/Epic14종 기존 보유분을 계정 로드 때 삭제한다. 잠금/강화/가방/창고/미수령/착용과 무관하며 다른 보유품·잔액·영수증은 유지한다. Common/Uncommon 공격 옵션의 숫자는 유지하고 %를 고정 공격력 포인트로 변경한다(Tempered3, Veteran4, 장갑/반지1). 물리/마법·기본/스킬·가방/상점/강화/영웅 표시를 일치시킨다. 강화 단계당 원래 수치3% 증가는 유지한다.

ENG → QA. 프로젝트 제작 스킬의 저장/검증 절차 적용. 사용자가 지정한 직접 데이터 변경이며 별도 신규 기능/밸런스 제안이 아니다.

삭제 정의는 구 저장을 먼저 검증하기 위한 decode-only tombstone으로 유지한다. `deleted` 장비는 효과 계산에서도 빈 수치로 처리하고, 실제 AccountStore의 세션 잠금 아래 upgrade/save에서 인스턴스를 제거한다. 구매/지급 중단은 기존 retired 검사를 재사용한다. 삭제된 착용 슬롯은 비며 대체품/자동 환급은 지급하지 않는다. 영수증 이력은 보존한다. 이 지시는 기존 2026-11-05의 해당14종 보유품 보존 지침보다 우선한다. 다른 은퇴 장비10종은 유지한다.

남은 사용 가능한 공격 장비 전부 Common/Uncommon이므로 `power` 집계는 이제 고정 포인트다. 삭제 Rare/Epic 공격장비의 보관된 수치는 런타임 효과가 없다. 새 고등급 공격 장비를 구현할 때 해당 단위 계약을 별도 정의해야 한다. 기존 장비 인스턴스/강화 수준은 재생성하지 않는다.

검증: [tests.log](tests.log), 9개 순수 Lua 검사 통과(삭제135, 고정공격86, 장착비교52, 스킬미리보기1392, 인벤토리271, 재료이관35, 은퇴장비486, 강화확률2869, 시작장비194). 실제 AccountStore 어댑터에 반복 콜백·저장 후 응답 유실·재접속을 주입해 삭제와 다른 재산 보존을 검증했다. 최초 새 fixture는 착용 Lv10 장비에 Lv1 영웅을 사용해 실패했고 올바른 Lv10 영웅으로 수정했다. 기존 스킬/비교 검사의 % 기대는 새 포인트 계약으로 수정했다.

`difficulty-enhancement.spec.lua`는 StoryLocked에서 실패한다. 변경 전 HEAD도 같은 위치/오류로 실패함을 별도 임시 소스에서 확인했다([baseline.log](baseline.log)). 이번 변경 통과로 보고하지 않는다.

미검증: 실계정 DataStore/게시 클라이언트/기기 화면과 전투 밸런스 수용. 실제 Roblox 게시·릴리스 태그 없음. QA는 재접속 삭제/빈 장착 슬롯·가방/상점/강화 pts·네 클래스의 공격/스킬을 확인한다. 다른 사용자 미커밋 자산은 보존하고 커밋에서 제외한다.

고정 소스 `9fb1c234ef3a6af36e497287e885f7f2967c9f06`를 origin/main에 푸시한 후 단일 빌드 **0.89.3 성공**. 산출물 `builds/0.89.3/TheLastThrone-0.89.3.rbxlx`, SHA256 `2d7839284bb7c2deb36af875ede862277adf7f9928369f09fc5166f3ae67df14`([빌드 기록](build.json)). `python3 tests/single-build.spec.py --artifact builds/0.89.3/TheLastThrone-0.89.3.rbxlx`: 역할10·도착로딩192·마운트/구성 PASS. `run-in-roblox --place builds/0.89.3/TheLastThrone-0.89.3.rbxlx --script docs/evidence/equipment-delete-flat-20261109/native.luau`: 고립된 Place에서 실제 모듈로 삭제135+고정공격86+표시단위3=224검사 PASS([로그](native.log)). GUI 렌더/실전 전투 조작이나 라이브 계정 검증은 아니다. 연결된 사용자 Studio에는 소스를 적용하지 않았다. 새 LFS 자산 없음.
