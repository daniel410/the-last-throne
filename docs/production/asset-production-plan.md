# 3D 자산 제작·공유·검증 계획

기준일: 2026-10-28 · 상태: 제작 계획 · 담당: 3D 모델링 에이전트

이 문서는 TD 자산을 RPG의 직접 조작·근접 시점·협동 전투에 맞게 전환하는 생산 계획이다. 문서는 한국어로 작성하고 게임 안의 이름·아이템 설명·표지판·상호작용·대사 및 기술 ID는 영어로 제작한다. 아래 신규 제작량과 예산은 **제안이며 실측 전**이다. 이번 계획 작성으로 Blender 원본, TD 소스, Studio 장면, Roblox 자산 또는 운영 게임을 변경하지 않았다.

## 1. 정본과 확인 범위

| 우선순위 | 제작 입력 | 적용 |
| --- | --- | --- |
| 1 | [현재 결정](../decisions.md) | 고정 플레이어 4클래스, 클래스별 2계열, 성녀 NPC/선택 지원, Deepwood 우선 제작 |
| 2 | [공유 세계관·자산](../shared-universe-and-assets.md), [공통 UI](../shared-ui-and-look-and-feel.md) | 기존 정체성과 원본을 최대한 공유하고 장르별 동작은 분리 |
| 3 | [공유 원본 레지스트리](../../assets/shared/td-asset-registry.json), [v1 출처](../../assets/concepts/2026-10-27-v1/source-manifest.json), [v2 출처](../../assets/concepts/2026-10-27-shared-ui-v2/source-manifest.json) | 경로·해시·용도·스냅샷 확인. 런타임 채택 또는 사용 권한 보증으로 해석하지 않음 |
| 4 | [TD 일반 프로젝트](../../../throne-defense/default.project.json)와 그 실제 참조 XML | 파일명 `latest`보다 실제 프로젝트 참조를 우선 |
| 5 | [TD 미술 가이드](../../../throne-defense/docs/art-style-guide.md), [모델링 가이드](../../../throne-defense/docs/modeling-workflow.md) | 원형·색·표면·가져오기 실패 사례. 과거 부분 수용을 RPG 수용으로 확대하지 않음 |
| 6 | 에픽·스토리·맵·전투·장비 상세 문서 | 필요한 동작·소켓·발판·상태·연출을 먼저 정의한 뒤 자산 선정 |

기사·드워프 전신, Deepwood 전경, 공통 UI 보드를 직접 확인했다. 청은 기사 천/도장, 은은 갑옷, 녹은 엘프, 갈/주황은 드워프, 백/금은 성녀의 식별 단서다. 컨셉의 미세 긁힘·식생 밀도·후면 장식은 그대로 실시간 제작 예산으로 약속하지 않는다. v2 UI 방향은 승인 기준이나 컨셉 속 한국어 글자를 게임 이미지에 굽지 않는다. 공통 패널·장식은 공유하고 실제 영문은 UI 텍스트로 렌더한다.

2026-10-28 로컬 파일을 대조한 결과, 레지스트리의 `ui.mobile-battle`과 `model.hero-weapon-adapter` SHA는 현행 TD 파일과 다르다. 나머지 등록 항목의 파일 SHA는 일치했다. 이 문서에서는 레지스트리를 수정하지 않았으며 재사용 착수 시 변경 사유·범위·채택 커밋을 다시 감사한다.

## 2. 보유량과 완성도의 실제 의미

| 숫자 | 확인한 근거와 상태 | RPG 생산량으로 해석할 때의 주의 |
| --- | --- | --- |
| 영웅 5 | [Config.HERO_CLASSES](../../../throne-defense/src/Shared/Config.lua)의 `knight`, `elf`, `dwarf`, `mage`, `priestess` 5개 정의. TD 플레이어 영웅은 Roblox 캐릭터에 외형/무기를 붙이는 구조 | 독립된 완성 전신 모델 5개·RPG 플레이어 5종이 아님. 플레이어는 4클래스, 성녀는 Selene/NPC 지원용 |
| 타워 30 | `ServerStorage.TowerModels`가 [refresh runtime](../../../throne-defense/assets/models/meshy-factions-refresh-v1/runtime.rbxmx)을 참조. XML에 `Model` 30개·`MeshPart` 68개 존재 | 시각 템플릿 30개. XML 안에는 `Motor6D`/`Bone`이 없으며 TD 어댑터가 별도 기준 파트에 연결. RPG 리그/48기술 호환 완료가 아님 |
| 몬스터 40 | 현행 `THEME_ROSTERS` 4테마 × 10엔트리. `warlord`는 기본/분노 gameplay kind를 공유하고 시각 템플릿은 구분 | 카탈로그 40엔트리. 독립 행동 40종·고유 메시 형상 40개·RPG 몬스터 40종 수용을 뜻하지 않음 |
| 현행 몬스터 XML 43 | [slime 통합 runtime](../../../throne-defense/assets/models/meshy-deepwood-slime-v1/runtime.rbxmx)에 `Model` 43개·`MeshPart` 165개. 현행 카탈로그 밖 `clone`, `ice_slime`, `scout` 3개 포함 | 40카탈로그에 보존3종을 더한 템플릿 수. 추가3종을 자동 신규 콘텐츠로 세지 않음. 모든 템플릿의 `Motor6D`/`Bone`은 XML 기준 0개 |
| 영웅 무기 XML 4 | [3k runtime](../../../throne-defense/assets/models/meshy-hero-weapons-3k-v1/runtime.rbxmx)에 `elf`, `knight`, `dwarf`, `mage` 4개 `Model`·6개 `MeshPart` | 3k manifest는 knight/dwarf/mage 3개 감량본만 명시. elf 포함 4개가 모두 3k라고 주장하지 않음. 성녀 등불은 별도 코드/원형 조사 |
| 컨셉 40파일/39디자인 | [구 몬스터 컨셉 README](../../../throne-defense/assets/concepts/monsters/2026-10-25/blocky-v1/README.md)의 당시 Zombie 중복 집계 | 과거 숲 Zombie가 현행 Cave Slime으로 바뀌었으므로 과거 39고유 집계를 현재 런타임 전체 고유 메시 수로 재사용하지 않음 |

XML 3종에 Script/LocalScript/ModuleScript가 없는 것도 정적 확인했다. 이는 외부 의존 에셋, 실행 시 추가되는 코드, Studio 실제 동작을 모두 검증했다는 의미가 아니다. 타워 refresh [메타데이터](../../../throne-defense/assets/models/meshy-factions-refresh-v1/runtime-metadata.json)는 변경된 **17종**만 담는다. 이를 30종 전수 메타데이터로 쓰지 않고 나머지 13종의 보존 출처를 추적한다.

`forest-kit-v3` [manifest](../../../throne-defense/assets/models/maps-quality-v2/forest-kit-v3/manifest.json)는 38메시·53,144tri, 거목 제외로 기록한다. 해당 manifest의 `NOT UPLOADED`/`NOT INTEGRATED` 문구와 현행 프로젝트 참조 및 보존 Studio 증거가 같은 시점의 상태가 아니다. 출처 이력 충돌을 정리한 뒤 채택 상태를 갱신한다. 53,144tri를 전체 Deepwood 또는 RPG 목표 프레임 수로 읽지 않는다.

## 3. 재사용·파생·신규의 결정

`Reuse`는 형상/텍스처를 그대로 채택하고 어댑터만 연결하는 것, `Derived`는 원형을 보존하되 분할·리그·피벗·UV·감량·재질을 수정한 것, `New`는 기존 자산으로 필요한 행동/근접 품질을 충족하지 못해 새로 제작하는 것이다. 모든 항목은 먼저 후보로 등록하고 실제 검사 뒤 확정한다. 재사용률과 모든 TD 타워 출연을 목표로 삼지 않는다.

### 플레이어 4종과 Selene

| TD 키 → RPG 용도 | 우선 재사용할 정체성·부품 | 파생/신규 작업 | 완료 기준 |
| --- | --- | --- | --- |
| `knight` → Knight | 승인 초상·은청 갑옷·장검·방패 원형 | 직접 조작 리그, 분리 방패, 검 소켓, 방어/회피/3연격; 강철/성광 계열 장식 | 손/방패 관통 없음, 준비/적중/회복과 판정 일치, 청색 천 유지 |
| `elf` → Elf Archer | 녹색·곡선 활·화살, elf 무기 템플릿 | 시위·화살 분리, 양손 조준, 발사/회수 상태, 명궁/마법궁수 모션 | 시위 중복 없음, 실제 투사체 출구 일치, 조준 시 얼굴/시야 보존 |
| `dwarf` → Dwarf | 갈/주황·수염·도끼, dwarf 무기 | 낮은 체형의 이동/회피 리그, 투척/회수, 화약 보조총포·폭탄/재장전 | 키만 줄인 인간 비례가 아님, 손잡이 고정, 회수 중 복제 도끼 없음 |
| `mage` → Mage | 승인 초상·로브·Wand, mage 무기 | 로브 관절 분리, 비전/바람/기초 물; Pyro/Cryo·대지/번개·광역/궁극기 | 입문/두 계열 구분, 주문 예고 가독성, 과한 전면 발광 없음 |
| `priestess` → Selene/support NPC | 백금·등불·교단 원형, `nun` 및 [기존 착장 코드](../../../throne-defense/src/Server/HeroPriestVisuals.lua) | 개인 얼굴/실루엣 승인, 이동/회복/정화/보호 모션, 등불 소켓, 비전투 대화 | 플레이어 클래스 선택에 없음. 지원 없이도 본편 완결, 4인 모험 전투AI동료0 규칙 준수 |

플레이어 클래스 원형과 세렌·에린·브란·이리아·셀레네 개인 인물은 구분한다. 리그를 공유해도 얼굴·초상·고유 장식·대사 연출을 자동으로 동일 인물로 취급하지 않는다. 8계열×4단계의 **32전직 단계 정의**는 곧 신규 전신 모델32개를 뜻하지 않는다. 4기본 몸체+교환 장비+계열 장식으로 먼저 검증하고 핵심 실루엣이 달라야 하는 단계만 신규로 산정한다.

### 타워 30종 전수 활용 후보

표의 분류는 활용 제안이며 실제 배치 승인이 아니다. 동일 부품을 플레이어 장비와 NPC 양쪽에서 공유할 수 있다.

| TD 팩션 | 정확한 시각 키와 표시명 | 우선 활용·파생 |
| --- | --- | --- |
| Knight 강철 | `swordsman` Swordsman / `shieldbearer` Shieldbearer / `ironwall` Ironwall / `lancer` Lancer | 검·방패·중갑·창 부분 재사용; 교관/전선 NPC. 플레이어 계열에 창을 강제로 추가하지 않음 |
| Knight 성기사 | `paladin` Paladin / `crusader` Crusader | 성기사 장식/검술·성광 VFX, 서약 교관. Crusader는 성기사 계열 |
| Elf 명궁 | `archer` Archer / `rapid` Rapid Shooter / `sharpshooter` Sharpshooter | 활·가죽·조준 표현, 궁술 NPC. 타워 자동 공격 모션은 직접 조작용으로 재제작 |
| Elf 마법/추적 | `storm` Storm Archer / `warden` Warden / `tracker` Tracker | 마법화살·자연 장식·정찰 NPC. Tracker는 제3계열이 아님 |
| Dwarf 강철 | `axe` Axe Thrower / `twinaxe` Twin Axe | 도끼·손잡이·장갑 후보, 투척/회수용 분할 |
| Dwarf 화약/지원 | `gunner` Gunner / `mortar` Mortar / `grenadier` Grenadier / `runesmith` Runesmith | 총포·폭탄·포대·제작 NPC. Mortar 몸체를 플레이어에 강제 대응하지 않음 |
| Mage 입문 | `arcanist` Arcanist / `zephyrmancer` Zephyrmancer | 비전/바람 교관·지팡이·로브 후보. 기초 물 VFX 부족분은 신규 |
| Mage 두 계열/추가 학습 | `pyromancer` Pyromancer / `cryomancer` Cryomancer / `geomancer` Geomancer / `voltmancer` Voltmancer | Pyro/Cryo와 Lv40 대지/번개 학습의 장식·효과. 6개 독립 전직으로 만들지 않음 |
| Priest 축복/보호 | `nun` Light Nun / `blessing` Blessing Priest / `cantor` Holy Cantor | Selene/교단 NPC와 치유 시설, 등불·백금 복장 |
| Priest 심판/정화 | `judge` Judgment Priest / `inquisitor` Inquisitor / `grand` High Priest | 교단 인물·의식/지원 기술. 플레이어 성녀 트리 제작 없음 |

### 몬스터 40엔트리와 작업 묶음

| 지역 | 일반5 / 보스5 | 전환·신규 포인트 |
| --- | --- | --- |
| Deepwood | Goblin / Cave Slime / Orc Warrior / Ogre / Goblin Shaman; Orc Warlord / Goblin King / King Ogre / Enraged Warlord / King Shaman | 첫 재사용/파생 배치. Goblin→Ogre→Shaman→King Shaman 순으로 예고·어그로·근접/주문·복합 패턴 검증. Slime 분열 상한/저지 동작 추가 |
| Frozen Vale | Ice Wolf / Ice Troll / Ice Bear / Ice Golem / Ice Elf; Ice Troll King / King Ice Bear / King Ice Golem / Queen Ice Elf / Ancient Glacier King | 사족·대형 접지, 얼음장갑과 위험 바닥 분리, 눈 배경에서 흰 실루엣 확인 |
| Ember Caldera | Imp / Lava Slime / Golem / Magma Worm / Volcano Shaman; Magma Imp / Magma Golem / Inferno Overlord / Caldera Titan / King Volcano Shaman | 날개/웜/장갑 분할, 열원 장치, 용암 시각과 실제 위험 경계 일치 |
| Haunted Graveyard | Zombie / Skeleton / Mummy / Hellhound / Ghoul; Skeleton Knight / Lich / Death Knight / Lich Sovereign / Dread Commander | 사족·로브/망토, 골격과 구울 실루엣 구분, 죽음/정화/소환 동작, Lich Sovereign의 베이르 서사 어댑터 |

각 행의 형상/텍스처를 우선 `Reuse` 후보로 삼되 새로운 전방위 피격·경직·사망·공격·회전 때문에 필요한 부위만 `Derived`로 만든다. 리그 없는 TD 시각 메시를 단순 weld하는 것만으로 인간형/사족 애니메이션을 완료 처리하지 않는다. 후반 The First Warden·루칸·영원의 왕은 기존 정체성 대응이 확인되기 전 `New candidate`로 등록하고 몬스터40에 숨겨 산정하지 않는다.

## 4. 캐릭터·장비·애니메이션 제작 계약

### 리그와 교환 부품

1. 캐릭터 기본 리그는 G1에서 R15 호환 골격과 커스텀 분할 리그 중 하나를 실제 이동/무기 검사로 선택한다. 키/팔다리 비례가 다른 Dwarf는 독립 바인드 포즈를 두고 동작 재타기팅 가능 범위를 기록한다. TD 원본의 R6/R15 착장 지원을 RPG 양쪽 리그 지원 약속으로 확대하지 않는다.
2. 공통 제작 좌표는 Y 위, 발바닥 Y=0, 캐릭터 시각 정면 +Z로 명시한다. Blender Z-up 변환은 exporter에서 한 번 적용하고 엔진 이동/카메라 정면은 별도 어댑터로 확인한다. 비대칭 검/얼굴로 native 방향을 검사하며 무조건 Y180을 더하지 않는다.
3. 몸체/무기/방패/머리·손·발 장비를 교환 가능한 자산으로 분리한다. 접합 경계·몸체 가림 마스크·허용 체형·부품 버전을 기록한다. 장착 때문에 얼굴/종족/기본 체형을 재생성하지 않는다.
4. [장비의9슬롯](../equipment-bag-and-storage.md) `weapon`, `offhand`, `head`, `body`, `hands`, `feet`, `accessory1`, `accessory2`, `relic`을 그대로 쓴다. 망토를10번째 성능 슬롯으로 추가하지 않는다. 장신구/유물은 모두 가시 모델이 필요한 것은 아니며 표시에 필요한 품목만 제작한다.
5. 장검/방패·활/시위/화살·도끼·마법봉·총포·등불은 손에서 분리해 독립 피벗을 둔다. 합쳐진 원본 무기를 자를 때 손가락/손잡이 경계를 보존하고 중복 무기·숨은 도끼·화살을 검사한다.

| 소켓 ID 제안 | 용도 | 계약 |
| --- | --- | --- |
| `GripRight`, `GripLeft` | 주무기/보조 | 로컬 행렬·장착 손·좌우 반전 허용 여부·프로필 버전 |
| `BackSheath`, `HipSheath` | 납도/보조 휴대 | 전투/탐험 전환 때 한 인스턴스만 표시 |
| `Muzzle`, `ArrowNock`, `ProjectileOrigin` | 총구·시위 장전·투사체 | 모션/VFX 원점과 서버 논리 투사체 시작점 대응 |
| `TrailBase`, `TrailTip`, `CastOrigin` | 검 궤적·시전 | 가시 범위가 실제 판정을 오인시키지 않도록 길이/높이 검사 |
| `HeadFx`, `ChestFx`, `RelicFx` | 표식/상태·유물 | 화면 중앙/얼굴·위험 예고 가림 한도 포함 |

이 이름은 신규 기술 계약 제안이며 기존 TD 실제 소켓 이름으로 보고하지 않는다. Engineer와 리그/소켓 스키마를 동결한 뒤 전체 제작한다.

### 동작과 VFX

| 묶음 | 생산 단위·초기 제안 | 검증 |
| --- | --- | --- |
| 공통 이동/상태 | 클래스별 동작 세트1개: idle·walk·run·stop·turn·dodge·hit·stagger·death·revive·interact | 이동 속도/지면·급회전·경사에서 접지와 루프. 공유 클립도 클래스별 재타기팅 검사 |
| Knight K0 | idle/walk/run·3연격·방패 진입/유지/해제·block/parry·dodge·hit/stagger/death·상호작용, 약16클립 시작안 | [기사 명세](../knight-combat-spec.md)의 준비/유효/회복과 일치. 클립 수는 실제 분할 방식에 따라 재산정 |
| 능동 기술 | 기본 액티브36·궁극기12 정의에 대해 `animationProfileId`/`vfxProfileId`/예고/적중/회복 대응표 | 기술48개를 애니48개/VFX48개로 단순 계산하지 않음. 재사용/추가 단계·피격 반응 별도 |
| 적 행동 | 보행/대기·회전·공격 준비/유효/회복·피격·경직·사망을 종별 묶음으로 생산 | Goblin/대형 Ogre/Slime/사족/로브 대표의 다른 요구를 먼저 확인 |
| 환경 상태 | 포탈 닫힘/예고/활성/불안정/봉인, 왕좌 평상/균열/손상/복원/서약망 | 모양·밝기·동작·영문 안내로 상태 구분, 색 하나에 의존하지 않음 |

모든 전투 클립에 `actionId`, 길이, loop 여부, root 이동 정책, 준비/유효/회복 시각과 VFX 마커를 기록한다. 서버가 판정을 결정하고 클라이언트 애니메이션 마커가 피해 권한을 부여하지 않는다. VFX는 자원 소모 승인·취소·사망·재시도·장면 이탈에서 정리하며, 저품질 모드에서도 위험 바닥과 적 공격 예고는 보존한다.

## 5. 지역 모듈과 이야기 상태

TD 완성 전장을 확대하지 않고 지형·석조·나무·문장·포탈·왕좌를 모듈로 재편한다. 먼저 회색박스에서 카메라·돌진·회피·파티 폭·SP 복구 동선을 통과시킨 뒤 디테일을 추가한다.

| 제작 지역 | 공유 후보 | RPG 신규/파생 모듈과 상태 | 상세 입력 |
| --- | --- | --- | --- |
| Deepwood 우선 | ForestKit38메시, ForestLandmark 거목, 돌길/아치/바위/폭포 | K0 공터, 주동선7지점·SP7·선택3구역·제단 던전; 조사물/사슬/오염장치·복원 상태 | [Deepwood 맵](../deepwood-map-design.md), [에픽1](../epic-01-deepwood-story.md) |
| Dawnspire | 성채/성문/왕좌/배너·공통 상점 원형 | 프롤로그4구간, 훈련장·장비/창고 거점·포탈 접근·개인 주민 복원 | [프롤로그 맵](../dawnspire-prologue-map-design.md) |
| Frozen Vale | 설원/얼음/북방 몬스터 원형 | SP7, 얼음길·기억장치·피난/교역 모듈·기억궁과 선택 공개 상태 | [Frozen Vale 맵](../frozen-vale-map-design.md) |
| Ember Caldera | 화산 바위/용암·드워프 장비 | SP7, 도시/지하·작업장·대체 열원·밸브·안전 발판·가동 전후 | [Ember Caldera 맵](../ember-caldera-map-design.md) |
| Haunted Graveyard | 묘비/석조·언데드·성녀 문법 | SP7, 이름/추모 장치·왕릉·정화/안식·개인 추모 선택 상태 | [Haunted Graveyard 맵](../haunted-graveyard-map-design.md) |
| Aether Spire·후반 성채/전선·The Fractured Crown | 승인된 석조/문장·포탈/왕좌·기존 팩션 | 중력/기억 장치·대피/호송·다섯 깃발·원형 왕좌와 최종 복원. 모듈 수는 스토리/회색박스 후 산정 | [본편 전체](../game-design.md#6-전체-서사와-지역-제작-구조) |

시각 메시와 플레이어 발판/적 이동/전투 쿼리/카메라 가림 충돌을 분리한다. ForestKit의 TD 기본 `CanCollide/CanQuery/CanTouch=false`를 RPG 전투 규칙으로 복제하지 않는다. 프롭 표면을 보고 오를 수 있다고 기대되는 곳, 회피가 막히는 곳, 공격이 벽을 통과하는 곳을 QA 장면에 포함한다. 스트리밍 진입·경계 이탈·재합류에서 발판이 먼저 준비되고, 낙하 복구가 해당 개인 SP와 연결되어야 한다.

개인 선택/복원 자산은 `sharedBase`와 `personalState`를 구분하고, 파티원의 다른 선택 때문에 길·필수 상호작용·보상이 사라지지 않게 한다. 시각 상태 전환을 새 전체 맵 복사본으로 해결하기 전에 모듈·재질·소품 차분으로 검토한다.

## 6. 품질·모바일 예산 제안

다음 값은 엔진 제한이나 이미 통과한 결과가 아니라 G1/G2에서 조정할 **초기 콘텐츠 예산**이다. 실제 테스트 기기·해상도·그래픽 단계·플레이어/적 수를 기록해 동결한다.

| 대상 | 시작 예산 제안 | 근거와 조정 원칙 |
| --- | --- | --- |
| 일반 플레이어 | 가시 몸체+장비 LOD0 합계15,000tri 이하, LOD1 약50%, LOD2 약25% | 얼굴/손/무기 실루엣 우선. 메시 수·draw call·스킨 계산과 함께 실측하며 초과 사유 기록 |
| 일반 적 / 주요 보스 | 각 LOD0 합계10,000 / 20,000tri 이하 | TD 블로키 패키지의 종별≤10k는 원본 예산. RPG용 보스20k는 신규 제안이며 허용 보증 아님 |
| 무기 | 무기 프로필별3,000tri 목표 | TD knight2,999/dwarf2,998/mage2,999 manifest 사례 참고. 방패·활·화살까지 합계 예산 따로 기록 |
| 텍스처 | 일반 적512²·플레이어/보스1024²를 기본 시작점, 예외2048²는 근접 이득/메모리 비교 후 | TD Slime1024²/2,989tri 실례와 기존 적512²를 구분. ColorMap/PBR 중복과 alpha overdraw를 함께 검사 |
| 환경 | 모듈별 LOD·그림자·가시거리·머티리얼 슬롯 기록, 전체 삼각형 상한은 G2 실측 후 결정 | 숲 전체를 하나의 거대 메시로 결합하지 않음. 인스턴싱·반복 재질·스트리밍 경계 검증 |
| 모바일 장면 | 최소 목표30FPS, p95 프레임33.3ms 이하를 시작 게이트로 제안 | 동일 기기10분 일반4인 전투·대표 보스·왕좌 수호 부하 측정. 메모리/로드/발열 기준은 G1 실측 후 별도 수치 동결 |
| 고성능 장면 | 60FPS 목표를 별도 측정 | PC 결과로 모바일 통과를 대체하지 않음. 후반8인 레이드는 독립 부하 프로필 |

LOD는 얼굴·무기·손잡이·예고 실루엣이 유지되어야 하며 전환 거리와 pop을 실제 카메라에서 정한다. 리그/텍스처/이펙트 단계 하향과 위험 정보 보존을 함께 설계한다. 총삼각형 감소만으로 FPS 개선을 주장하지 않는다.

## 7. 출처·공급망·가져오기·배포 계약

### 자산 레코드 제안

레지스트리를 확장할 때 `assetKey`, `sourceRepository`, `sourceCommit`, `sourcePath`, `sourceSha256`, `derivedFrom`, `reuseMode`, `reason`, `generatorOrAuthor`, `licenseEvidence`, `owner`, `permissionEvidence`, `assetIdsByType`, `allowedExperienceEvidence`, `rigProfile`, `socketProfileVersion`, `boundsAndUnits`, `trianglesByLod`, `materialsAndTextures`, `collisionProfile`, `tdAdoptedVersion`, `rpgAdoptedVersion`, `approvalStatus`, `reviewer`, `evidencePaths`, `rollbackVersion`을 보존한다. 미확인 값은 `unknown`이며 긍정적인 완료 값으로 채우지 않는다.

| 게이트 | 필수 검사·산출물 | 중단/수정 조건 |
| --- | --- | --- |
| 원본 수령 | 원본 불변 보존·SHA·제작자/생성 도구·라이선스·관련 승인·외부 의존 목록 | 출처 불명, 소유/재사용 범위 불명, 텍스처 누락 |
| 격리 검사 | 외부 모델 Script/LocalScript/ModuleScript·원격 require·알 수 없는 constraints/behaviors·숨은 part·외부 ID 확인 | 허용목록 밖 코드는 실행하지 않고 제거/검토. 외형과 임의 실행 코드를 묶어 채택하지 않음 |
| 기하/패키지 | finite 좌표/정상 index·법선/와인딩·UV/alpha·단위/피벗·리그/소켓·메시/텍스처 예산·외부 경로 해소 | 구조 검사를 미술 통과로 보고하지 않음. 결함 원본 대신 파생 수정 |
| native 가져오기 준비 | 파일명·실제 경로·SHA·종/파트 집합·미리보기·업로드가 발생하는지 확인 | `Upload to Roblox` OFF만으로 로컬 전용이라고 가정하지 않음. 기존 TD에서 OFF여도 Mesh/Image 생성 사례 있음 |
| 권한 확인 | 사용자 개인 소유·Restricted·비판매/배포OFF·타인/그룹 협업자 없음, 필요한 사용자 소유 Experience만 최소 허용 | Model 컨테이너 외 Mesh/Image/TexturePack/Animation 등 함께 생성된 유형도 각각 확인. 불명 상태는 완료 아님 |
| 런타임 검토 | 실제 ID·native MeshSize/정규화 Size/CFrame·재질·타입별 preload·사용 장면 | raw ID preload 실패만으로 재업로드하지 않음. 실제 타입 인스턴스 로드와 렌더 확인 |
| 채택 | 미술/모션/성능·권한 증거, 게임별 버전 pin·변경 영향·되돌림 후보 | TD/RPG를 동시에 강제 갱신하지 않음. 이전 해시/ID/파일/채택 이력 보존 |

기존 TD의 특정 TexturePack404 예외 승인은 당시 지정 작업의 기록이며 RPG 신규 제작 전체의 예외가 아니다. 공개 에셋을 비공개라고 재표기하거나 로드 성공을 권한 확인으로 대체하지 않는다. 권한 확인이 부족하면 원본 조사·로컬 파생 제작을 계속할 수 있지만 업로드/채택 완료는 보류한다. 현재 작업에서는 업로드를 실행하지 않는다.

## 8. 단계별 생산량·의존·종료 조건

아래는 기존 [G0~G8 로드맵](../production-roadmap.md)과 연결하는 제안이다. 단위는 신규 고유 메시 수가 아니라 **검사/채택할 작업 패키지**이며 재사용·파생·신규 결과를 각각 집계한다. 반복 등장하는 클래스·Selene·지역·적은 앞 단계 자산을 확장하는 누적 범위이며 단계별 숫자를 더해 신규 수량으로 계산하지 않는다. G2 실측 전 고정 일정/인건비/출시일을 산출하지 않는다.

| 단계 | 최소 생산 패키지 제안 | 선행 | 종료 증거 |
| --- | --- | --- | --- |
| G0 감사 | 영웅5원형·타워30템플릿·몬스터40카탈로그/43템플릿·무기4템플릿 전수 매핑, 환경5테마 묶음(Dawnspire·숲·설원·화산·묘지)의 후보 조사, 해시 불일치2건 처리 | 정본/허용 범위 | 각 후보의 Reuse/Derived/New/미채택·부족분·원본/권한 상태가 연결됨 |
| G1 K0 | Knight 리그1·검/방패 프로필1·Goblin/Ogre2·Deepwood96×96 공터1·포탈/왕좌 원형 각1·약16클립 시작안 | Engineer 리그/판정 계약 | 실제 조작·접지·3연격/방패/회피·예고·충돌·영문 표기 통과 |
| G1 K1/K2 | Shaman1 추가, Knight 두 계열 비교 묶음2, Elf/Mage 기본기 각1, Selene 지원 실험1, Dwarf 체형/도끼 파일럿1 | K0 기본기 | 근접/원거리/주문/지원의 가독성, 체형과 소켓 계약 동결. NPC 동료 상한 준수 |
| G2 대표 구간 | King Shaman1·포로/오염장치·제단/결전 공간·상태 전환 묶음1, 15~20분 구간의 필수 자산100% | 전투·퀘스트 상태·회색박스 | 솔로/4인 정상·전멸·재시도·재합류 렌더/충돌, 모바일 프로필·제작 처리량 확보 |
| G3 장비/기반 | 기본 몸체4·Selene1의 리그 패키지, 9슬롯 교환 검증표1·공통 무기군5(검/방패·활/화살·도끼·Wand·등불), Dawnspire 핵심 거점1 | 저장/아이템 ID·소켓·원형 승인 | 장착/해제/리스폰/재접속·낮은 품질·겹침·복원 상태 검증. 화약 총포는 추가 패키지로 별도 산정 |
| G4 클래스 확장 | 8계열 장식/무기/모션 프로필, 32전직 단계 대응표, 액티브36/궁극기12의 시각 대응표 | 기본리그·클래스/스킬 데이터 동결 | 정의별 누락0, 모션/VFX 재사용과 신규 수량 분리, 실제 플레이 수용 |
| G5 본편 | Deepwood10엔트리 우선 완성 후 후속3테마 각10채택 검사, 주요 공간7·던전6의 모듈 목록/상태/배치, 개인 인물5 패키지와 후반 신규 보스 | 지역별 스토리/회색박스·대표 구간 성능 | 장별 필수 자산100%, SP/복원/선택 상태·근접/전장 품질, 영어 텍스트 검사 |
| G6 최종 콘텐츠 | 레이드3의 전투별 패키지, 수호전/호송 병력/공성·지휘 지원 묶음 | 본편/8인 프로필·행동 정의 | 8인 부하·중첩 VFX·예고 보존·소환/퇴장 정리, 반복 세션 메모리 |
| G7 출시 | 선택된 공개 범위 자산100%의 출처/권한/해시/버전/기기 증거, fallback/rollback 묶음 | 범위·기기 목록 동결 | 미술·기술·QA 서명, TD 채택본 영향 검증. 미구현 본편 전체를 출시 완료로 표시하지 않음 |

### 루트 백로그에 연결할 작업

| ID 제안·우선순위 | 작업·담당 | 의존 | 수용 조건 |
| --- | --- | --- | --- |
| ART-001 · P0 | 자산/현행 참조/권한 전수 감사 · Modeling+Engineer | G0 | 5/30/40·43/4 수량 의미 일치, metadata17종의 보존13종 출처·해시 차이2건·ForestKit 상태 이력 정리 |
| ART-002 · P0 | 기본 리그·9슬롯·무기 소켓 계약 · Modeling+Engineer+Designer | ART-001, 전투명세 | Knight/Dwarf 실제 극단 자세와 활 시위로 검증, 스키마/버전 기록 |
| ART-003 · P0 | K0 미술/모션 패키지 · Modeling | ART-002, K0 회색박스/서버 판정 | Knight/Goblin/Ogre·검방패·공터, 판정/모션/가림/충돌 증거 |
| ART-004 · P0 | native 공급망/권한·버전 채택 절차 · Engineer+Modeling | ART-001 | 원본/파생/실제ID 유형별 증거·개인 소유/비공개·게임별 pin·rollback, 임의 업로드 없음 |
| ART-005 · P1 | G2 제단·보스·상태 연출 · Modeling+Designer | ART-003, G2 퀘스트 | 솔로/4인 재시도 포함 완주·VFX 정리·모바일 프로필 |
| ART-006 · P1 | 4클래스/Selene·장비/8계열 생산표 · Modeling+Planner | ART-002/005, 스킬데이터 | 32단계/48기술을 실제 메시·모션·효과 수로 재산정, 성녀 플레이어 제외 |
| ART-007 · P1 | 지역 모듈/40몬스터·후반 신규 보스 · Modeling+Planner+Designer | 지역별 스토리·회색박스 | 필수/선택·SP·복원·서사 상태별 자산 누락0, 레벨 디자인/QA 서명 |
| ART-008 · P1 | 실기기 최적화/출시 채택 감사 · QA+Engineer+Modeling | 해당 공개 범위 자산 통합 | LOD·메모리·프레임·로드/정리·영문·원본/버전/권한 증거, 사용자 미술 수용 별도 |

## 9. 미완료와 주요 리스크

- 영웅 전신 이미지와 TD 템플릿이 있어도 리그·48기술·장비 분할·근접 시점의 부족분은 남는다. 표본 리그를 통과하기 전에 전직32단계의 외형을 대량 제작하지 않는다.
- TD runtime/manifest/README는 서로 다른 시점의 기록을 포함한다. 프로젝트 참조·해시·모델 키·권한 증거·실제 장면을 연결해 채택한다.
- 공유 어댑터와 모바일 UI에 해시 변경이 있다. 다른 프로젝트의 현재 소스를 무조건 복사하거나 오래된 스냅샷으로 되돌리지 않는다.
- 원본 텍스처와 생성 도구의 출처가 존재해도 RPG 사용권·실제 비공개 상태를 전수 확정한 것은 아니다. 현 단계 권한/미술/모바일 결과는 미검증이다.
- 원경 식생·큰 로브·다중 궁극기의 근접 가림과 alpha overdraw는 삼각형 수로만 예측할 수 없다. 실제 전투 장면을 기준으로 줄인다.
- 후반 지역·보스·레이드의 세부 공간/동작은 아직 생산 입력이 부족하다. 기존40몬스터와7공간을 전체 신규 자산 공수의 상한으로 계산하지 않는다.

완료는 파일 생성, 구조 검사, 실제 로드, 실제 조작/렌더, 실기기 성능, 권한 확인, 사용자 미술 수용을 별개 상태로 기록한 뒤 해당 단계 조건이 모두 충족될 때 선언한다.
