# 기사·드워프 머리 장비 표시명 수정

TLT-028/057 · 소프트웨어 엔지니어 · 2026-11-11

사용자 보고: 기사·드워프 헬멧이 후드로 표시됨. 확인된 결함은 공용 머리 장비 카탈로그의 Hood 이름을 UI에서 클래스 구분 없이 사용한 경로다. 기존 3D/아이콘 매핑은 두 클래스 모두 helmet으로 연결돼 있다. 실제 사용자 화면의 증상 위치는 추가 응답 전이며 3D 외형의 신규 결함은 확인하지 않았다.

## 변경

- Enhancement.name에 선택적 클래스 인자를 추가해 네 계열 공용 머리 장비는 Knight/Dwarf에서 Helmet으로 표시한다. Elf/미지정 클래스의 Hood 및 Mage Hat은 유지한다.
- 가방 목록/상세·창고·미수령·폐기 확인·대장장이 구매/판매 확인·강화/회수·장비별 능력치 출처에 클래스 문맥을 전달한다. 미수령은 기존 아이콘과 같은 소유 영웅 기준, 창고는 선택 영웅 기준이다.
- 강화 접미사 유지. 저장 ID/아이템 소유권/능력치/3D 모델/아이콘 자산은 변경하지 않는다. 이전 Studio 전용 초기값도 유지한다.
- 명확한 표시 결함 수정으로 추가 게임성 리서치는 생략했다.

## 검증과 인계

- lua tests/headgear-display-name.spec.lua: 64검사 PASS. 4클래스×4계열 표시명·강화 접미사·모델 매핑·스탯 출처, 기본 Hood/마법사 모자 보존.
- lua tests/enhancement-current-equipment.spec.lua: 8,792검사 PASS.
- lua tests/equipment-families.spec.lua: 492검사 PASS.
- lua tests/studio-test-defaults.spec.lua: PASS.
- git diff --check: PASS. 고정 소스 로컬 빌드0.103.6은 build.json 참조.
- 미검증: 변경 UI의 Studio 실행·게시 클라이언트·실기기·사용자 수용. Roblox 게시/릴리스 태그 없음.

다음 담당: QA/사용자. 새 로컬 빌드에서 Knight/Dwarf의 가방·대장장이·강화 이름을 확인한다. 실제 착용 모델이나 아이콘 자체가 후드라면 재현 화면/장비/클래스 조건으로 추가 조사한다. 전체 TLT-028/057 게이트는 닫지 않는다.
