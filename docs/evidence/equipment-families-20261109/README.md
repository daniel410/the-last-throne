# 장비4가족·MP 장비

2026-11-09 · TLT-029/041/052/057/084 · 0.90.0 · ENG→QA

[최신 사용자 사양/부위별 수치/가격승계/이관](../../production/equipment-four-tier-reorganization-2026-11-09.md). 이번 변경은 사용자가 범위와 옵션 규칙을 직접 지정한 데이터·연동 변경이며 별도 게임성 대안을 채택하지 않았다. 프로젝트 제작 스킬을 적용했다. 활성40장비+3장신구, 가족마다 단일 고정옵션, Traveler 신규 지급/착용, Copper+3/HP Charm유지/새MP Charm30을 연결했다. 신규 외형/이미지 업로드/미술 수용은 별도다.

순수 Lua12개 총4883검사 통과(`tests.log`): 장비458, 시작장비206, 고정공격112, 삭제171, 강화2869, 재료이관35, 초기화316, 지원권30, 상점분리14, 상점304, 비교52, 보급316. 기존 검사에서 직전 시작무기/옵션/상점수 기대가 바뀌는 부분만 최신 사양으로 수정했다. 새 장비 검사는 구 프로필 선검증/응답유실/재접속·잠금/강화/지급출처 보존·가방가득/미수령·낮은레벨 장착거절·실제상점 지급·MP강화/비교/자원미생성을 포함한다.

검증명령: `lua tests/equipment-families.spec.lua` 및 `tests.log`의 각 명령. 엔진 검증 fixture는 `tests/equipment-mana-native.luau`와 순수 테스트를 실제 모듈require로 연결한 `native.luau`다. 실제 계정/플레이어 조작/기기 UI/밸런스·경제/동시배포 구writer 수용은 미검증이며 부모 티켓을 완료 처리하지 않는다. Roblox 게시·릴리스 태그 없음. 기존 사용자 미커밋 Blender/컨셉 삭제/로컬 산출물은 보존하고 작업 커밋에서 제외한다.

고정 소스 `c037464b139913ea2ce05a78847d60df16985967`를 origin/main에 푸시 후 단일 빌드 **0.90.0 성공**. `builds/0.90.0/TheLastThrone-0.90.0.rbxlx` SHA256 `0d05cb4ae6cd59ef522d67335240fa016affe3547787c074c36c3a729a230695`. `python3 tests/single-build.spec.py --artifact builds/0.90.0/TheLastThrone-0.90.0.rbxlx`: 역할10/도착로딩192/프로젝트마운트·실제아티팩트구성 PASS. `run-in-roblox --place builds/0.90.0/TheLastThrone-0.90.0.rbxlx --script docs/evidence/equipment-families-20261109/native.luau`: 새장비458/시작장비206/고정공격112/삭제171/서버MP·UI모듈33=**980검사 PASS**(`native.log`). 합성 신원+실제 Humanoid로 production refreshEquipment를 호출해 장착 시 현재MP/HP 회복없음·반복갱신 회복없음·해제 시상한 제한·비MP영웅 자원미생성·복제된MP값 일치를 확인했다. UI5개는 모듈로딩 검사이며 실제 화면렌더/입력 수용은 아니다. 연결된 사용자 Studio에는 소스를 적용하지 않았고 Roblox 미게시다. 새LFS 자산 없음.
