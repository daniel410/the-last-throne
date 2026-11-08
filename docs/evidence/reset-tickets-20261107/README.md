# 스탯·스킬 리셋권 구현 · 0.82.0

2026-11-07 · TLT-041/043/047/052/057/084 · ENG/QA · 로컬 구현·Studio 소스 적용·미게시.

## 플레이 경로와 계약

Diamond Shop → RESET TICKETS → 각50 Diamonds 구매 확인 → 선택 영웅 BAG의 Items 필터 → RESET POINTS → 반환 투자P/미배분 잔액 미리보기 → CONFIRM RESET. 첫 클릭은 요청하지 않으며 닫기/다른 아이템 선택은 확인을 취소한다. 미투자·로비 밖에서는 사용 버튼 비활성이다.

스탯은 투자 STR/DEX/INT/VIT만0으로, 스킬은32개 인덱스의 숙련 투자만0으로 만든다. 레벨/XP·기본치·전직·자동 해금·편성·미배분 예산은 보존한다. 총316/79 예산에서 미배분을 계산하므로 별도 포인트를 더해 중복 환급하지 않는다. HP/MP/쿨다운 회복은 제공하지 않는다. 기존 `refreshEquipment`의 현재량 상한 제한과 쿨다운 보존 경로를 사용한다.

리셋권ID `stat_reset_ticket`/`skill_reset_ticket`, 가격50, 스택99, 계정 귀속. 구매는 다이아 차감과 가방 지급을, 사용은 권1개 차감과 성장 반환을 각각 기존 계정 단일 키 UpdateAsync/fence/영수증 경로에 묶는다. 구매 직후 자동 사용하지 않는다. 가방이 가득 차도 기존 미잠금 부분 스택이 있으면 합치며 새 슬롯이 필요하면 차감 전 거부한다. 공유 창고에 보관/다른 영웅으로 이동할 수 있으나 사용은 대상 영웅 가방에서만 한다. Gold 판매/묶음 상품/직접Robux 결제는 추가하지 않는다.

기존 TD 테마 프레임/버튼/재질·색을 사용해 두 종류의 인장 두루마리를 코드로 표시한다. 별도 이미지 업로드 없음. 상점 짧은 설명·50다이아·부족액 안내 및 가방 영어 preview/취소 안내를 연결한다.

## 검증과 한계

- `lua tests/reset-tickets.spec.lua`: **300 PASS**. 네 클래스/두 권·가격/잔액·구매/사용 분리·스택·가방 용량·로비/소유/버전·정확한 반환·투자0·재요청·동시 오래된 revision 거부·AccountStore 응답 유실 후 확정 영수증 복구·서버 fence 해제/재접속을 메모리 어댑터로 검사.
- `lua tests/inventory.spec.lua`: **271 PASS**.
- `lua tests/economy.spec.lua`: **42 PASS**.
- `lua tests/hero-progression.spec.lua`: **3711 PASS**.
- `lua tests/advanced-skills.spec.lua`: **1435 PASS**.
- 임시 Rojo Place에서 `run-in-roblox --place /tmp/tlt-reset-tickets-preview2.rbxlx --script tests/reset-tickets-native.luau`: **34 PASS / 종료0**. 실제 Luau 모듈·TD GUI 생성자에 비공개 fixture snapshot/클릭 함수를 주입해 상점 가격/잔액 비활성·가방 미리보기/포션 미편성·2단계 확인·닫기 취소·로비 밖 차단·실제 규칙의 소비/반환/재시도를 검사. 실제 플레이어 원격/계정은 사용하지 않는다. [native-preview.log](native-preview.log). 기존203785492 자산 타입 경고는 별도다.
- 최초 native fixture는 버튼 이름을 Primary로 잘못 지정해 실패했다. 실제 PrimaryAction으로 수정 후 재실행 통과. [native-initial.log](native-initial.log). 이를 제품 수정 전 결함 재현으로 간주하지 않는다.
- 현재 TLT Studio70829337938054 Edit에9개 소스를 문법 검사/동기화. 기존 HEAD와 다른 ItemCatalog/ArmoryView/InventoryGui의 사용자 수정은 문맥 패치로 보존했다. 백업 `ServerStorage.TLTBeforeResetTickets20261107`.
- `git diff --check`: PASS. 리서치는 [비교 검토](../../research/2026-11-07-reset-tickets.md)를 따른다.

실제 DataStore 장애·게시 서버 재접속·실제 터치/패드·다인·정상 플레이어 원격 구매/사용·최종 UI 시각 수용은 미검증이다. native 검사는 fixture 조작이며 실제 기기 검증과 구분한다. 다음 QA는 로비에서 두 상품을 구매/사용하고 다른 영웅에게 창고로 이전한 뒤 재접속을 확인한다. 부모 티켓 In Progress 유지. 게시/릴리스 태그 없음.

## 고정 빌드

구현 소스 커밋 후 `python3 tools/build-game.py --source HEAD --record docs/evidence/reset-tickets-20261107/build.json`으로 고정 빌드를 생성하고 동일 native를 재실행한다. 버전·소스·SHA256·상태는 build.json에 기록한다. 기존 데이터로 롤백할 때는 새 상품 정의를 유지해야 한다. 새 리셋권을 모르는 구버전은 프로필을 로드 거부할 수 있으므로 새 보유품을 삭제/초기화하지 않는다.

고정 빌드0.82.0 성공: 소스 `254d1f5603042b3a51e65080ea31f1d443462a44`, 산출물 SHA256 `c5478c50e8697d9a44435feb8eef748d2dd6bef9b0bafd6e52baf0869ad1ba49` 재대조. [build.json](build.json). 동일 고정 Place의 native 재실행 **34 PASS / 종료0**, [native-final.log](native-final.log). 입력 LFS 포인터0개·이번 변경 신규 대용량 자산 없음. 검증한 구현/기록을 origin/main에 푸시하고 원격 커밋 일치를 확인한다.
