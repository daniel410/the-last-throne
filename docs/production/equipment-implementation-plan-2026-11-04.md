# 장비 120종과 레전더리 40종 구현 계획

2026-11-04 · TLT-027/028/029/041/043/044/045/052/061/073/082/084 · PLAN → ART/ENG/DES → QA

사용자 요청은 생성 자산을 저장하고 구현 계획을 마련하는 것이다. **이미지 저장은 완료했고, 이번 산출물은 구현 순서·데이터 계약·검증 계획이다.** 게임 코드 변경·Roblox 업로드/게시·운영 데이터 수정은 수행하지 않는다. 아래 E01~E08은 기존 TLT의 하위 작업 표기이며 새 정식 티켓 번호나 구현 완료 상태가 아니다.

## 1. 저장 기준과 범위

기준 커밋은 `2b5f7dc1a370e9244297c31830f39ceca653ec0f`다. PNG41개(레전더리40+모아보기)는 LFS 전송이 완료됐으며 원격 main과 일치 확인했다. [레전더리 생성 기록](../../assets/concepts/2026-11-04-equipment-icons/generated-legendary-v1/generation.json), [제작 검증](../../assets/concepts/2026-11-04-equipment-icons/generated-legendary-v1/README.md), [세 등급 비교](../../assets/concepts/2026-11-04-equipment-icons/comparison.html)를 원본으로 보존한다.

| 범위 | 현재 자산 | 구현 목표 |
| --- | --- | --- |
| 공통 방어구/장신구 | 등급마다11종, MP 장신구3종 포함 | 4클래스 호환·장신구 슬롯 선택·MP 자격/중복 조건 |
| 기사 | 등급마다8종 | 검/방패·5부위 세트·별도 장신구 |
| 엘프/드워프/마법사 | 등급마다각7종 | 활/도끼/지팡이·5부위 세트·별도 장신구 |
| 등급 | Rare40/Epic40/Legendary40, 총120PNG | 외형과 개별 정의의 명시적 연결 |
| 제안 레코드 | Lv10×40계열×6등급=240 | 설계 입력으로만 사용, 미작성 스탯/효과를 자동 출시하지 않음 |

40은 품목 수다. 착용Lv40 또는 레전더리 최소Lv40을 뜻하지 않는다. 세대 확대는 레벨1/5/10/20/40/60/80별 실제 성장 예산이 마련된 범위만 진행하며 120이미지를840개 신규 아이템으로 자동 복제하지 않는다. 아이콘은 장착 3D 모델이 아니므로 캐릭터 외형 교체는 별도 ART/ENG 작업이다. Selene NPC 장비 트리·신규 총 장착은 추가하지 않는다.

## 2. 현재 코드와 연결 지점

아래는 현재 작업 트리의 소스 열람 결과이며 런타임 검증 결과와 구분한다. 다른 작업의 미커밋 코드는 이번에 편집하거나 기준 빌드로 고정하지 않는다.

| 기존 경로 | 확인한 상태 | 필요한 변경 |
| --- | --- | --- |
| [ItemCatalog](../../src/shared/ItemCatalog.luau) | 기존 Common/Uncommon/Rare, Lv1/5/10 중심·8슬롯 | 기존ID/수치 보존, 신규 정의·희귀도·세대·세트/아이콘 참조 추가 |
| [InventoryRules](../../src/server/Inventory/InventoryRules.luau), [InventoryService](../../src/server/Inventory/InventoryService.luau) | 서버 장착/집계·저장·미수령 경로 존재 | 신규 maxMana 집계키 초기화/허용 필드 검증, MP/세트 집계, 보스 지급의 멱등 적용 |
| [AccountStore](../../src/server/Inventory/AccountStore.luau) | UpdateAsync·계정 리스·SaveUnknown 처리 | 새 보상 원장/스키마·복구/진행 중 버전 계약 검증 |
| [Enhancement](../../src/shared/Enhancement.luau) | +9, power/armor/health만 강화 | 계약 유지, 신규 정의의 강화 가능성/회수 회귀 검사 |
| [SkillStatPreview](../../src/shared/SkillStatPreview.luau), [EquipmentImpact](../../src/shared/EquipmentImpact.luau), [CombatService](../../src/server/Combat/CombatService.luau) | 장비 HP/Armor/Power 반영·MP 비교행 존재, 새 장신구 MP 가산 경로 미연결 | 서버/비교창의 MP와 세트 계산을 같은 순수 함수로 통일 |
| [ItemSpriteAtlas](../../src/shared/ItemSpriteAtlas.luau), [ItemSprites](../../src/client/ItemSprites.luau), [ItemArtwork](../../src/client/ItemArtwork.luau) | definition.id별 단독 이미지 우선·아틀라스/기본 그림 경로 | 신규 definitionId별 업로드ID 연결, 오류 대체 그림·권한 확인 |
| [InventoryGui](../../src/client/InventoryGui.luau), [InventoryText](../../src/shared/InventoryText.luau) | 상세/비교·가방 UI | TD 원본 프레임 안에 등급/클래스/착용Lv/세트/MP/강화 상태 표시 |
| [DeepwoodService](../../src/server/Story/DeepwoodService.luau), [ExpeditionService](../../src/server/Network/ExpeditionService.luau), [Difficulty](../../src/shared/Difficulty.luau) | 전투/원정·난이도 기존 경로 | 사망 확정 훅/참여 원장·버전별 보스 풀 연결, 기존 처치/스토리 보상 보존 |

## 3. 데이터 계약과 먼저 결정할 값

신규 정의는 `definitionId`, `familyId`, `rarity`, `equipmentTier`, `level`, `slot`, `classId`, `stats`, `uniqueGroup`, `iconKey`, `nameKey`, `descriptionKey`, 필요 시 `setId`와 `setPieceId`를 가진다. 기존 런타임 필드 `level`을 착용 조건으로 사용하며 manifest의 `requiredLevel`과 명시적으로 변환한다. PNG 식별 이름을 안정ID로 덮어쓰지 않는다. 예시 신규ID `gear_knight_oathguard_sword_t10_legendary`는 **가칭**으로 E01에서 기존ID와 충돌 검사를 마친 뒤 고정한다. 같은 외형을 다른 세대가 재사용하면 각각의 definitionId를 같은 iconKey에 매핑한다.

인스턴스는 현재 `instanceId`, `definitionId`, `location`, `quantity`, `enhancementLevel`과 성공 투입 원장을 보존하고, 지급 출처/보상영수증·정의 버전을 연결한다. 중복 제한용 uniqueGroup과 최상위 희귀도 Unique는 다른 개념이다. 장신구의 같은 계열·다른 등급 중복 허용 여부도 uniqueGroup으로 명시하며 이름 비교로 판정하지 않는다.

| 결정 | 작업 기본안 | 결정 담당/시점 |
| --- | --- | --- |
| 착용Lv/세대 | 최초 개발 fixture는 기존 Lv10 제안 사용. 출시용 최소Lv는 등급만 보고 정하지 않음 | PLAN·QA, E01 종료 전 [개별120종 Lv10 시험표](equipment-item-stats-2026-11-04.md)를 검토해 첫 세대 매트릭스 고정 |
| 기본 스탯 | 같은 부위/세대 예산 Rare1.18/Epic1.28/Legendary1.40. Legendary는 Epic보다 약9.375% 큰 예산 | PLAN, E01에서 부위별 배분·반올림·무료 성장/가격 비교 |
| 세트 | 무기/head/body/hands/feet의5부위, 동일 세대/등급만 합산. 방패/장신구 제외 | PLAN·ENG, E04 전 2/4/5부위 보너스·개별 예산 차감 확정 |
| MP | 신규 스탯 키는 `maxMana` 가칭. 현재 derived의 `mana`와 어댑터로 연결 | ENG·PLAN, E03 전 필드 검증/자격/적용순서 고정 |
| 보스 드롭 | 보스·모드·세대별 완성표/개인 추첨. 6등급 확률과 보호는 기존 재리뷰대로 수용 보류 | PLAN·QA, E05 전 모든 유효 풀/보장 정책·확률 공개 고정 |

비율은 스탯별 무조건 곱셈 규칙이 아니다. 특히 power는 현재 공격력에 대한 퍼센트 보너스로 사용되므로 최종 피해가9.375% 커진다고 설명하지 않는다. Legendary+9 기본 예산은1.40×1.27=1.778, Epic+9는1.28×1.27=1.6256이며 실제 전투는 HP/Armor·스킬 계수까지 비교한다. Unique 효과는 별도 명세가 완성될 때까지 신규 지급을 비활성으로 둔다.

## 4. 작업 순서와 수용 조건

| 작업 | 담당·선행 | 변경/산출물 | 통과 조건과 상태 |
| --- | --- | --- | --- |
| E01 정의/밸런스 고정 | PLAN/ENG/QA, 시작점 | 신규120외형→정의/세대 대응표, 첫 세대 스탯·착용Lv·영어 문구, 정본JSON→Luau 생성 규칙 | ID/참조/등급/부위/클래스/빈 값 검사, 과거ID와 값 diff0. Lv10 시험 수치표 작성 완료·런타임 정의 고정/수용 대기 |
| E02 자산 등록 | ART/DES/ENG, E01 iconKey 필요 | PNG 알파 정리·48/64px TD 프레임 검수, Roblox 신규 업로드·권한/심사 상태, 이미지 레지스트리 | 실제 assetId·해시·소유자·사용 Experience 기록, 120매핑 누락0·옛아이콘 회귀0. 대기 |
| E03 데이터/장착/MP | ENG, E01 | 카탈로그·서버 검증/집계·공유 계산·비교창, 신규 정의 자동지급은 OFF | 4클래스/8슬롯·Lv/uniqueGroup·MP 자격·교체/해제·재접속 통과. 대기 |
| E04 강화/세트 | ENG/PLAN, E03 | 기존+9 연동·혼합 세트 집계/효과, UI 세트 상세 | 단계/성공원장 보존·강화 실패 멱등·MP 비강화·방패 제외·같은 부위 중복 미합산 통과. 대기 |
| E05 보스 보상/복구 | ENG/PLAN, E01/E03/E04·확률/보호 결정 | `BossLootTables`/`BossLootRules`/`BossLootService` 신규 모듈 가칭, 참여/처치/개인 결과 저널 | 지원/사망/단절/재시도·가방만석·동시서버·서버중단·버전교체에서 중복/손실0. 대기 |
| E06 UI 통합/단일 보스 시범 | DES/ENG/QA, E02~E05 | 가방/창고/미수령/보스 미리보기/강화창 실제 자산, Deepwood 테스트 모드 | 검→획득→저장→장착→+강화→해제→재접속 전과정, 승인 TD 룩/영어·PC/터치/패드 검수. 대기 |
| E07 전체 확장/경제 수용 | PLAN/ENG/QA, E06 | 세 등급40계열120정의의 출시 대상 세대·전지역 보스 표, 시뮬레이션·기기 보고 | 정의/이미지100% 대응, 본편 무료 Rare 경로·모드별 보상/시간·세트/강화 비교. 대기 |
| E08 테스트 게시/릴리스 | ENG/QA/디렉터, E07 | 고정 소스·VERSION·빌드해시·게시 테스트/회귀 보고·복구 절차 | 게시된 각 테스트 Experience 클라이언트·실기기·저장 검증 후 실제 릴리스 판단. 대기 |

E02는 E03~E05와 산출물별로 진행할 수 있으나 같은 파일은 한 담당자가 소유한다. E03~E04에서 준비할 첫 fixture는 4클래스 무기×3등급12종+기사 방패/공통 MP3종×3등급12종, 합계24정의로 시작하고 이어 4클래스 방어구4부위×3등급48종을 추가해 세트를 검증한다. E06은 이72정의의 전 과정을 연결하고 나머지48종은 E07에서 확장한다. 외형120개 등록 수와 실제 지급 가능한 정의 수를 따로 보고한다.

## 5. MP와 강화 적용 규칙

장비 집계→허용된 강화 양수 power/armor/health→세트 효과→영웅 파생치 계산 순서로 통일하는 기본안이다. 세트 효과와 개별 스탯을 중복 강화하지 않는다. 현재 +9 성공률100/90/80/70/60/50/40/30/20%, 목표n 비용 보석2n·마석max(0,n−3), Gold0, 실패 재료 소모/단계 보존, 성공 투입분80%회수를 유지한다. 과거+10·구재료 원장도 보존한다.

MP 보너스는 Mage와 첫 전직을 완료한 magic_archer Elf의 기존 MP 풀에만 더한다. Knight/Dwarf/그 외 Elf에게 새 풀을 만들지 않는다. 장착·해제·창고 이동·로드 후 `currentMana=min(currentMana,newMaxMana)`를 적용하고 최대치 증가만으로 현재MP를 채우지 않는다. 일반 레벨업 회복과 장비교체를 구분한다. MP 전용품은 강화 버튼을 비활성으로 표시하고 재료를 차감하지 않는다. Wellspring 같은 혼합품은 HP만 강화한다. 서로 다른 허용 품목의 MP 합산과 같은 uniqueGroup 중복 금지를 서버/비교창에서 일치시킨다.

## 6. 보스 지급과 보상 보존

기존 [보스 드롭 설계](boss-drop-reward-design-2026-11-04.md)와 [독립 재리뷰](../research/2026-11-04-boss-loot-independent-review.md)를 따른다. 서버가 `runId + bossSpawnId + userId + heroId + rewardKind`로 기회를 고정한다. 재소환/재요청으로 기회를 늘리지 않고 새 원정·별도 보스는 별도 키를 사용한다. 살아 있는 막타 공격자만 보상하지 않도록 피해·회복·보호·목표 기여와 사망/재접속 자격을 E05 전에 수치화한다. AI는 개인 추첨/소유권을 갖지 않는다.

처치/로스터의 내구성 기록→개인 RNG/보장 결과 고정→계정 원자 적용(아이템 또는 미수령+보호진도+영수증)→획득 확정 표시로 진행한다. UpdateAsync 재실행과 저장 불명 시 같은 결과를 재적용한다. 원정 기록/계정이 다른 키라면 저널 재조정 작업의 소유자·재시도·보존/정리 조건을 구현한다. 계정 결과가 내구성 기록되기 전 전원 이탈/서버중단 경계도 테스트한다. 로드 실패를 빈 신규 계정으로 저장하지 않는다.

초기 테스트의 강제 Legendary 지급은 개발자 전용 fixture이며 실제 드롭 확률로 노출하지 않는다. 세 등급 아이콘만 있다는 이유로 Common/Uncommon/Unique 확률을 Rare/Epic/Legendary에 재분배하지 않는다. 출시 표는 모든 클래스/등급 유효 풀이 있고 미획득 보호가 정의됐을 때 켠다. 낮은 Easy 확률·높은 고난이도 확률은 방향이며 현재0.5/2/5/10% Legendary 시험표를 이번에 승인하지 않는다. 유효 풀0은 콘텐츠 오류로 탐지하고 기존 보상은 정상 유지한다.

기존 스토리 XP/Gold/Diamonds 정본, 몬스터 XP/Gold, 완료 보석/마석, 상자/상점·실상품 권리는 별도 경로로 보존한다. 신규 보스 장비 지급으로 기존 권리를 삭제하지 않는다. 파티 인원에 비례해 개인 기본 추첨을 깎거나 AI 수만큼 추가 장비를 지급하지 않는다. 별도 효과를 도입하려면 개인/파티 보상량과 아이템/시간 검증이 먼저다.

## 7. 검증과 중단 복구

| 검증 묶음 | 실행 범위 | 수용 기준 |
| --- | --- | --- |
| 정적 | `python3 scripts/validate_equipment_icon_assets.py` + 신규 정의/로컬라이제이션/풀 검사 예정 | 현재120PNG 해시/등급/참조 PASS. 미래120정의의 필수필드·참조·확률100%·0풀 검사는 E01/E05에서 추가 |
| 기존 회귀 | tests/inventory.spec.lua, equipment-impact.spec.lua, enhancement-probability.spec.lua, difficulty-enhancement.spec.lua, reward-materials.spec.lua, item-shop-categories.spec.lua | 실제 구현 시 저장소 테스트 실행 환경에서 모두 PASS. 이번 계획 작성으로 재실행/통과했다고 표시하지 않음 |
| 서버 장애 | 중복/경합·UpdateAsync 콜백 재실행·로드실패/SaveUnknown·교환/강화/보스중단 | 결과 고정·소유권 유일·재료/보호진도 보존·복구 후 지급1회 |
| 전투/성장 | 4클래스×4난이도×1/2/3/4인, AI0 및 각 인원 상한2/2/1/1 | 솔로 무료 본편 완결, 클래스별 유효 풀/MP, 시간/실패 포함 순보상 측정. 4인+AI1 실기기 별도 수용 |
| 장비 조합 | 3등급×강화0/5/9, 세트0/2/4/5·혼합 등급/세대·과거+10 | 같은 조건 등급 예산 순서·비세트 유효성, 계산/비교창/실제 서버 일치 |
| 실제 UI/게시 | PC/모바일 가로/패드·48/64px·게시 로비/배틀·이동/재접속 | 승인 TD 원본/영어 문구·심사/권한/로드·미수령/저장대기 구별 |

출시 전 `enableNewGear`/`enableBossEquipmentDrops` 가칭 플래그와 고정 규칙 버전을 도입한다. 문제가 생기면 신규 원정의 드롭만 끄고 이미 소유한 정의·원장·미수령은 유지한다. 신규ID를 모르는 과거 서버로 단순 롤백하면 로드 검증이 실패할 수 있으므로 정의를 이해하는 호환 읽기 버전을 먼저 준비하고 오래된 writer를 차단한다. 진행 중 원정은 시작한 룰 버전을 보존한다. 이미 저장한 보상은 재추첨하지 않는다.

## 8. 이번 작업 결과와 다음 담당

저장된120이미지/제안240개 참조 검사는 `python3 scripts/validate_equipment_icon_assets.py`로 PASS. 계획의 코드/자산 상대 링크 및 `git diff --check`를 확인한다. 두 레전더리 이미지 모서리1/255 알파 잔여는 E02 보정 대상으로 유지한다. 신규 카탈로그·MP/세트·보스 지급/확률·실제 저장/Studio/게시/기기 검증은 미실행이다. 부모 티켓을 완료로 변경하지 않는다. 문서 작업이므로 VERSION/게임 빌드/릴리스 태그를 생성하지 않는다.

다음 담당은 PLAN/ENG의 **E01 첫 세대 정의표·스탯/레벨·ID 매핑 고정**이다. 근거는 [공식 자료 재확인](../research/2026-11-04-equipment-implementation-check.md), [장비 설계](hero-equipment-and-icon-plan-2026-11-04.md), [강화 계약](equipment-enhancement-v2-2026-11-03.md)이다. 구현 시점에는 현재 main·관련 미커밋 변경을 다시 확인하고 파일 소유 범위를 정한 뒤 시작한다.

추가 산출물: [개별 능력치120종](equipment-item-stats-2026-11-04.md)과 [수치 JSON](../../assets/balance/equipment-stats-plan-2026-11-04.json)에 E01 시험값을 작성했다. 예산 가중치와 세트/마나 세부값은 전투 수용 전 제안이며 실제 카탈로그 등록은 대기한다.
