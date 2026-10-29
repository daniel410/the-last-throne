# Lv20 이전 6스킬 성장과 스킬트리 재구성

2026-10-29 · TLT-013/014/015/027/042/052/054~056/058 · PLAN → ENG·DES·ART·QA

## 결정과 설계 범위

사용자 요청: Lv20까지 기존 3개만 사용하는 구간에 새 스킬3개를 추가하고 트리를 다시 만든다. 네 클래스 모두 기존3개를 유지하고 전직 전 공통 액티브3개를 추가한다. 계열 기술을 앞당겨 새 기술로 세거나 강화 노드로 대체하지 않는다. 기존 계열12개와 Lv80 궁극기1개를 유지하므로 선택 경로는 **공통6 + 계열12 + 궁극기1 = 19개**로 확대하는 설계다. 이전16개 제한을 대체한다. 해금 레벨·영문명·효과·학습 방식은 아래 제안이며 밸런스/플레이 검증 전이다.

이 작업은 기획 재구성이다. 현재 런타임의 기본3개·선택 경로16개와 구분하며 새 기술·저장·HUD·빌드를 구현한 것으로 보고하지 않는다. 최초 클래스 고정·각2계열·전직20/40/60/80·79SP·316스탯P·Stamina 제거·리셋권 정책은 유지한다.

## 초반 학습과 편성

| 레벨 | 학습 제안 | 보유 액티브 | 전투 슬롯 |
| --- | --- | ---: | ---: |
| Lv1 | 기존 기본3개를 짧은 조작 훈련으로 모두 제공 | 3 | 3 |
| Lv5 | 새 기술 A: 단일 적/위치 대응 | 4 | 4 |
| Lv10 | 새 기술 B: 다른 형태의 공격/제어 | 5 | 5 |
| Lv15 | 새 기술 C: 자기 보호/거리 확보 | 6 | 5 |
| Lv20 첫 전직 완료 | 선택 계열 첫 액티브 | 7 | 5 |
| Lv40 두 번째 전직 완료 | 해당 단계 신규 기술 포함 | 계열표에 따름 | 5 |
| Lv60 세 번째 전직 완료 | 해당 단계 신규 기술 포함 | 계열표에 따름 | 5 |
| Lv80 마지막 전직 완료 | 계열 궁극기1 | 액티브18 + 궁극기1 | 일반5칸과 별도 궁극기 버튼 |

Lv5/10/15는 일정한 간격으로 새 선택을 주는 초안이다. 이전 정식 성장 제안의 기존3개 Lv1/5/10 분산 학습은 대체한다. 초기 세 기술을 한 번에 긴 설명으로 제시하지 않고 순차 조작 훈련으로 소개한다. 무료 학습과 SP 강화는 분리하며 레벨 도달 시 서버가 학습 자격을 부여하는 안이다. 사용자 후속 결정으로 Lv5에4번·Lv10에5번 슬롯이 열리므로 새 기술을 배울 때 영어 안내와 비교·교체 UI가 필요하다. 자동으로 기존 편성을 덮어쓰지 않는다. Lv15 기술은 일반 액티브이며 궁극기가 아니다.

## 클래스별 새 기술 12개

모든 새 영문명과 문자열은 가칭이다. 피해·MP·쿨다운·사거리·대상 상한·지속은 후속 정량 설계 대상이다. 강제 이동/제어는 일반 적 기준이며 보스 면역 시에도 공격 기술의 기본 피해는 남긴다.

| 클래스·레벨 | 안정 ID / en-US 이름 | 형태와 독립 역할 | 기존 뿌리와 차이 |
| --- | --- | --- | --- |
| Knight Lv5 | knight_driving_thrust / Driving Thrust | 짧게 한 걸음 내딛으며 전방 직선 찌르기. 단일 적 압박 | Shield Bash의 방패 제어와 다른 검 단일 공격. 장거리 돌진/방어 성공 조건 없음 |
| Knight Lv10 | knight_crescent_cut / Crescent Cut | 전방 부채꼴 한 번 베기. 전방에 모인 적을 공격 | Whirlwind의 주변 회전과 다른 방향성·짧은 공격. 투사 검기 아님 |
| Knight Lv15 | knight_guarded_strike / Guarded Strike | 방패를 세우고 짧게 베어 자기 피해를 잠시 줄임 | Provoke와 별개 자기 보호 공격. 도발·방어 약화·표식·아군 보호 없음 |
| Elf Archer Lv5 | elf_retreating_shot / Retreating Shot | 화살 한 발과 짧은 뒤걸음으로 거리 확보 | Aimed Shot의 조준 고화력과 구분. 무적/공통 Dodge 대체 없음 |
| Elf Archer Lv10 | elf_pinning_shot / Pinning Shot | 낮게 쏘는 한 발로 일반 적을 잠시 감속 | Rapid Fire 연사와 달리 접근 억제. 보스 감속 면역 가능 |
| Elf Archer Lv15 | elf_arrow_screen / Arrow Screen | 가까운 전방 바닥에 화살을 쏟아 좁은 구역 접근 억제 | Multi Shot의 넓은 원거리 부채꼴과 다른 근거리 구역 공격. 덩굴/원소/MP 없음 |
| Dwarf Axe Thrower Lv5 | dwarf_hooking_chop / Hooking Chop | 도끼를 짧게 걸어 단일 적을 비틀며 자세 압박 | Overhead Smash의 큰 내려찍기보다 짧은 가로 타격. 강제 끌어당김 없음 |
| Dwarf Axe Thrower Lv10 | dwarf_low_sweep / Low Sweep | 전방 낮은 부채꼴 도끼 베기로 일반 적 감속 | Ground Slam의 주변 충격과 다른 전방 견제. 점프/지면 폭발 없음 |
| Dwarf Axe Thrower Lv15 | dwarf_braced_throw / Braced Throw | 잠깐 자세를 고정하고 전방 직선에 도끼를 관통 투척 | Axe Throw의 단일 투척과 다른 경로 공격. 시전 중 이동 제약, 총/폭탄/포격 없음 |
| Mage Lv5 | mage_wind_lance / Wind Lance | 직선의 작은 바람 창으로 정렬한 적 공격 | Mana Bolt 단일 비전과 다른 좁은 관통. 상위 원소/대규모 광역 없음 |
| Mage Lv10 | mage_tidal_ring / Tidal Ring | 발밑 작은 물 고리로 가까운 적 공격·감속 | Water Ball 원거리 단일 및 Gravity 표적 주변 제어와 구분. 빙결/냉기 아님 |
| Mage Lv15 | mage_arcane_ward / Arcane Ward | 짧은 자기 보호막으로 다음 대응 시간을 확보 | 공격/회복/MP 생성 없음. 공통 Block과 별도 MP·쿨다운, 지속 방패 대체 금지 |

Knight·Elf·Dwarf 새 기술은 물리·기술별 쿨다운이며 Mage 세 주문은 MP·기술별 쿨다운이다. 모든 이동은 서버가 충돌·낙하·통과 가능 거리로 제한한다. 관통/구역 기술은 서버 대상 상한과 중복 적중 규칙을 정한다. Arrow Screen은 설치 동료가 아니며 탄약 소모 상품을 새로 요구하지 않는다.

## 재구성한 3뿌리 트리

공통6개를 독립적인 여섯 계열로 늘리지 않는다. 기존3뿌리에 전직 전 보조 가지를 하나씩 붙이고, 각 기존 뿌리의 선택 계열 파생4개를 유지한다.

| 클래스 | 뿌리1 → 초반 가지 | 뿌리2 → 초반 가지 | 뿌리3 → 초반 가지 |
| --- | --- | --- | --- |
| Knight | Shield Bash → Lv5 Driving Thrust | Whirlwind → Lv10 Crescent Cut | Provoke → Lv15 Guarded Strike |
| Elf Archer | Aimed Shot → Lv5 Retreating Shot | Rapid Fire → Lv10 Pinning Shot | Multi Shot → Lv15 Arrow Screen |
| Dwarf Axe Thrower | Overhead Smash → Lv5 Hooking Chop | Axe Throw → Lv15 Braced Throw | Ground Slam → Lv10 Low Sweep |
| Mage | Mana Bolt → Lv5 Wind Lance | Water Ball → Lv10 Tidal Ring | Gravity → Lv15 Arcane Ward |

화살표는 학습 연결이며 뿌리를 장착하거나 SP를 투자해야 사용할 수 있다는 뜻이 아니다. 보조 가지는 선택 계열의 두 후속 가지 모두에서 유지한다. 새 공통 기술을 이후 계열 기술의 필수 선행으로 추가하지 않는다. 기존 계열의 뿌리별4개 연결과 Gunner의 독립 총·폭탄·포격 분류는 해당 상세표를 유지한다. 초반 기술과 같은 기능만 반복하는 계열 기술은 후속 밸런스 리뷰에서 공격 범위·동작·위험·효과의 차이를 검증한다.

- 기사: [강철기사](steel-knight-root-tree-2026-10-29.md) / [성기사](paladin-root-tree-2026-10-29.md)의 기존 계열 액티브12개와 궁극기를 이어 붙인다.
- 엘프·드워프·Mage: [6계열 상세표](dwarf-elf-mage-skill-trees-2026-10-29.md)의 계열 액티브12개와 궁극기를 이어 붙인다.
- 모든 계열: Lv20/40/60 전직 당일 최소1개 및 중간 레벨의 신규 액티브를 유지하고 Lv80 전직 시 새 궁극기를 제공한다. Mage 대지/번개는 Lv40 이전에 주지 않는다.

Lv15 기사 편성 예: Shield Bash / Driving Thrust / Guarded Strike는 단일 압박·자기 보호, Whirlwind / Crescent Cut / Provoke는 군중 처리·약화다. 엘프는 Aimed Shot / Retreating Shot / Pinning Shot으로 거리 유지, 드워프는 Overhead Smash / Low Sweep / Ground Slam으로 근접 다수 대응, Mage는 Mana Bolt / Wind Lance / Arcane Ward로 직선 공격·보호를 고를 수 있다. 모든 예시는 해당 기술 습득 후 편성하며 기본3개만으로도 진행 가능해야 한다.

## 포인트·제작량·저장 전환

스킬79P와 스탯316P를 늘리지 않는다. 기존 공통6 강화 노드는 C1~C3 기존 기술 숙련·C4~C6 새 공통 기술 숙련으로 재배치하는 안이다. 이전 C4~C6 보조 효과는 새 기술로 자동 이전하지 않고 기존 투자자에게 적용할 재분배/보상 정책을 ENG·PLAN이 별도로 확정해야 한다. 의미가 다른 저장 노드를 조용히 바꾸지 않는다. 216노드는 유지 가능한 예산 후보이며 전체 효과·랭크·투자 가능 경로를 확정한 숫자가 아니다.

액티브 정의 목표는 **4×6 + 8×12 = 120개**, 궁극기8개를 더해 **128개**다. 기존116개 대비 새 공통12개 증가이며 하나의 선택 경로는19개다. 두 계열에서 공유하는 초반 기술을 중복 제작 수로 세지 않는다. 새 애니메이션/VFX·아이콘/영어 설명·서버 판정·강화 효과의 제작 비용을 별도 산정한다.

기존 기술 ID와 편성을 보존한다. Lv5/10/15 이상 기존 캐릭터의 새 기술 자격은 로드 성공 후 서버가 멱등 복구한다. 실패한 로드는 신규 프로필로 덮어쓰지 않는다. 계열 재선택 시 공통6개와 각 기술 쿨다운을 유지한다. 스킬 교체·리셋·재접속을 통한 쿨다운 초기화 금지 계약을 검증한다. 이 문서로 데이터 마이그레이션을 실행하지 않는다.

## 영어 UI 원고

| 키 | en-US 초안 |
| --- | --- |
| skills.new_unlocked | New Skill Unlocked |
| skills.review_loadout | Open Skills to review your loadout. |
| skills.pre20_requirement | Reach Level {level} to unlock this skill. |
| skills.full_loadout | All skill slots are filled. Choose a skill to replace. |
| skills.unlock_failed | We could not unlock this skill. Reopen Skills to try again. |

새 기술 이름 키는 `skills.{stableId}.name`이며 위 표의 ID와 이름을 사용한다. 설명 원고는 정량 판정 확정 후 작성한다. 게임에 한국어 개발 설명을 노출하지 않는다.

## 검증·후속 담당

문서 수용: 네 클래스 각 신규3개·중복 없는12 ID, 해금5/10/15가20 미만, 6+12+1=19 및120+8=128, 기존3뿌리/8계열/전직/레벨별 슬롯/자원 유지 여부를 정적으로 확인한다. 보상 XP·레벨 곡선은 변경하지 않는다.

ENG·DES·ART 후속: 기술별 수치/대상/시전 취소·모션/VFX/아이콘 → 서버 해금·편성·C4~C6 이전 설계 → 런타임·트리 UI 구현. QA는 Lv4/5·9/10·14/15·19/20 경계와 전직 미완료, 기존 고레벨/로드 실패/중복/재접속/편성 유지, 물리 MP 없음·Mage MP 실패, 지형·보스 면역·다인 중첩을 검증한다.

재미 수용은 네 클래스 Lv1~20 솔로 및2/4인에서 새 기술의 실제 채택·교체 이유·기존기 대체 독점·배운 뒤 다음 해금까지의 체감 간격을 관찰한다. PC·터치·패드 편성 조작도 확인한다. 이번 문서 검증으로 재미·Studio·게시 클라이언트·저장·실기기를 통과 처리하지 않는다. 상위 구현 티켓은 미완료다.

### 이번 슬롯 구현 검증 기록

`lua tests/advanced-skills.spec.lua`: 946개 통과. 네 클래스의 Lv1/4/5/9/10/19/20/80 슬롯 수·서버 편성 허용/거부·전직 전 저장 검증·계열 기술 미해금 회귀를 포함한다. `lua tests/hero-progression.spec.lua`:71개 통과. `git diff --check` 통과. Studio GUI 회귀 기대값도 레벨 기준으로 갱신했으나 이번에는 실행하지 않았다. 빌드·Studio 실행·게시·실기기는 미검증이다.
