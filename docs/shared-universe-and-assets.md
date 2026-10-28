# Throne Defense와 공유할 세계관·캐릭터·3D 자산

버전0.24 · 갱신 기준2026-10-27 · [기획 본문](game-design.md) · [업데이트 제안서](../../throne-defense/docs/throne-chronicles-rpg-proposal.md)

초기 자산 목록·파일 후보의 조사 기준은 **2026-10-26**이다. **2026-10-27**에 공통 UI/이미지와 default.project.json의 실제3D 소스 경로를 추가 조사해 [공유 원본 레지스트리](../assets/shared/td-asset-registry.json)에 기록했다. 파일/소스 연결 확인과 새 업로드·RPG 런타임 적용은 구분한다. 사용자 결정과 활용 제안은 [기획 결정표](decisions.md)에서 구분한다.

## 1. 공유 범위와 독립 범위

사용자 결정으로 **메뉴·아이콘·이미지·3D 모델은 최대한 반드시 공유한다.** 동일 기능은 공통 원본과 버전을 쓰고 RPG 데이터/동작만 어댑터로 연결한다. 필요한 파생 자산은 원본 키와 사유를 기록한다. [공통 UI/룩앤필](shared-ui-and-look-and-feel.md)에 로비·배틀·상세 메뉴의 적용 기준과 패키지 분리 경계를 정리했다. 이번 작업에서 TD 소스 변경이나 공통 패키지 추출/런타임 연결은 수행하지 않았다.

두 게임은 동일 IP의 세계관·시각 정체성·캐릭터 원형을 공유하지만 각각 독립 Roblox Experience로 운영한다. Diamonds·명시된 업적/외형/이벤트는 외부 서버 권위 계약이 검증될 때만 공통으로 관리하고, RPG의 직접 전투·전직·퀘스트·일반 경제·캐릭터 저장은 장르별로 설계한다. **모델의 존재, 업로드, 런타임 적용, RPG 품질 통과는 각각 다른 상태**다.

**RPG 직업과 전투 경험을 먼저 설계하고, 적합한 TD 자산을 최대한 활용한다.** 기존 타워와 RPG 직업을 일대일로 대응시키지 않는다. 전직명·무기·역할·스킬트리·애니메이션을 기존 타워 목록에 맞출 의무는 없다. 필요한 모델·장비·동작이 없거나 품질/조작에 맞지 않으면 신규 제작하고, 기존 타워의 개성이 NPC·동료·지원 캐릭터에 더 적합하면 그 역할로 활용한다.

| 대상 | 공유할 것 | RPG에서 새로 만들거나 검증할 것 |
| --- | --- | --- |
| TD 영웅5종 | 종족/세력·무기·색·외형 콘셉트 | RPG 플레이어4종의 리그·직접 전투·두 전직 계열, 성녀는NPC/지원용 리그·AI·모션 |
| 타워30종 | 적합한 몸체·의상·무기·표현·팩션 문화 | 플레이어용 부분 활용 또는 NPC/동료/지원군 전환, 필요 자산 신규 제작 |
| 네 지역 테마 | 지역명·환경 문법·프롭·텍스처 | 자유 탐험 지형·생활권·다층 동선·던전·개인 세계 변화 |
| 몬스터·보스 | 이름·실루엣·종별 장비·메시 후보 | 플레이어 감지·어그로·공격 예고·판정·피격·보스 패턴 |
| 보라 포탈 | 원형 구조·공명 문양·침공의 상징 | 안전 이동/공격/균열 용도 식별·상호작용·체크포인트 |
| 수정 왕좌 | 수정·빛기둥·왕국의 상징 | 근접 디테일·파괴/복원 단계·이야기 장면·수호전 목표 |
| 로비 성채 | 성벽·탑·광장·왕좌/포탈의 배치 언어 | Dawnspire 생활권·NPC·상점·개인 복원 구역 |
| 음악·아이콘 | 테마·팩션·무기 아이콘의 원형 | 사용 권한, RPG의 동적 편곡·기술/장비 아이콘 |
| Diamonds | 기존 TD 잔액·확인된 구매/수령 기록과 공통 지갑 | 양쪽 동시 소비·지급·재시도·구버전 호환 검증, 이동 시 잔액 복사 없음 |
| 공통 업적·외형·이벤트 | 명시된 권리와 공통 수령 기록 | 게임별 외형 표현·이벤트 조건·추가 보상 구분 |
| TD 성장·상품 | 기존 진행·구매권 보존, 상품별 적용표 | RPG 성장·장비·스토리는 별도. TD Gold·RPG Coins를 환전하지 않음 |

Throne Defense의 기존 게시본과 저장을 이 기획 작업으로 수정하지 않는다. 공유 자산 변경이 양쪽 게임에 바로 배포되는 구조를 피하고, 게임별 채택 버전을 기록한다. 같은 텍스처를 고칠 때에도 TD의 색·스케일·성능 요구와 RPG 근접 품질을 각각 확인한다.

독립 Experience 구성과 데이터 연동은 [연동 설계](experience-integration.md)를 따른다. 포탈 모델을 공유하는 것과 실제 TD↔RPG 개인 이동/복구를 구현하는 것은 별도 작업이며, 외부 권위 지갑·각 Experience 영수증 조정 계약을 검증한 뒤에만 공통 권리를 활성화한다.

### 1.1 자산별 활용 판단

| 활용 방식 | 선택 기준 | 예시와 후속 제작 |
| --- | --- | --- |
| 직접 재사용 | 역할·외형·리그·근접 품질·성능이 RPG 요구와 맞음 | 검증을 통과한 무기·장식·환경 소품 채택 |
| 부분 재사용·변형 | 일부 요소가 맞고 몸체/장비/동작 보완이 필요함 | Gunner의 총포를 참고하되 화약공병 몸체·재장전·조준 모션은 별도 제작 |
| NPC·동료·지원 캐릭터 | 기존 개성이 플레이어 직업보다 세계 인물/전술 지원에 잘 맞음 | Runesmith 제작 NPC, Mortar 지원 포대, 고유한 마법사 연구자 |
| 신규 제작 | 필요한 직업·단계·스킬을 표현할 자산이 없거나 개조가 품질을 떨어뜨림 | 각성 직업의 무기·몸체·전용 기술 모션·이펙트 제작 |

한 타워의 무기는 플레이어용으로 활용하고 몸체는 지원 NPC에 쓰는 등 복수 활용도 가능하다. 위 예시는 확정 배치가 아니며 적합성 검사 후 선택한다. 모든 타워를 RPG에 반드시 출연시키거나 특정 재사용률을 달성하는 것을 품질 목표로 삼지 않는다. 자산 레지스트리에 활용 방식·부분 재사용 범위·부족한 신규 항목·선택 이유·검증 결과를 기록한다.

### 1.2 Deepwood 첫 제작 맵 적용

2026-10-27 사용자 확인에 따라 **RPG의 첫 제작·전투 검증 맵과 첫 본격 필드는 Deepwood**로 둔다. Dawnspire는 기존 전체 서사의 왕도 거점·프롤로그 장소이며, 제작 순서와 본편의 장 순서를 구분한다. 기사 K0 실험장은 Deepwood 안의 작은 공터로 구성한다. 전체 지역과 제단 던전까지 한 번에 완성한 것으로 취급하지 않는다.

이번 조사는 TD의 현행 소스·Forest kit 파일과 보존된 Studio 실제 화면3장·컨셉 원본을 대조했다. 연결된 `Throne Defense` 편집 인스턴스의 Workspace에는 조사 시점에 GameMap이 없었으므로 새 맵을 생성하거나 플레이를 시작하지 않았다. 아래 실제 화면은 저장된 검토 자료이며 현재 게시본을 새로 촬영한 결과는 아니다.

| 확인한 요소 | TD의 근거 | RPG 적용 방향 |
| --- | --- | --- |
| 맵 식별과 경로 | [Config](../../throne-defense/src/Shared/Config.lua)의 `forest` 표시명 Deepwood. 현행 난이도4개·`forest-1`~`forest-4`, 세 평행 구간을 큰 U턴 두 개로 연결 | Easy `forest-1`을 기본 축척 참고로 삼고 자유 이동·갈림길·근접 교전 공간을 설계. TD 난이도·웨이브·패드 배치는 RPG 성장과 구분 |
| 거목·숲 군집 | [Forest kit 로더](../../throne-defense/src/Server/VisualFactoryForestKit.lua)의 `ForestLandmark` 높이48, `ForestTree` 군집 | 멀리서 방향을 알려 주는 거목과 숲의 깊이, 뿌리/바위 주변 탐험 공간. 기존 TD 좌표는 참고이며 RPG 배치는 새로 결정 |
| 지형·절벽·폭포 | [forest-kit-v3](../../throne-defense/assets/models/maps-quality-v2/forest-kit-v3/manifest.json)의 지형/석조/폭포38메시·53,144tri, 거목은 별도 재사용 | 적합한 메시를 선별해 재사용·변형. 수치는 kit 원본 범위이며 거목·전체 맵·RPG 성능 수치가 아님 |
| 석조 포탈 | 석재 아치·계단·청금 배너와 보라 소용돌이 | 첫 도착/귀환 지점 또는 봉인된 균열 후보. 안전 이동과 적 출현은 문양·프롬프트·작동 상태로 구별 |
| 수정 왕좌 | 실제 화면의 분홍/보라 수정·기단, TD의 수호 목표 | 첫 구역에서는 성역/수호 목표 참고. 왕좌의 개수·세계관 의미·실제 퀘스트 용도는 서사 사양에 맞춰 결정 |
| 굽은 돌길·초지·이끼 바위 | 실제 근접 화면의 석재 포장과 숲 색 | 초반 안전 동선·고블린 교전·오우거 공터를 연결하고 바위 뒤 선택 탐험 공간을 추가 |
| 충돌과 시야 | [기존 충돌 모듈](../../throne-defense/src/Server/VisualFactoryForestCollision.lua)은 별도 경사판과 외곽 경계를 사용. 시각 kit는 `CanCollide/CanQuery/CanTouch=false` | 플레이어 발판·회피/돌진·적 이동·카메라/공격 가림에 맞는 RPG 충돌/쿼리 규칙을 따로 작성. TD 충돌 설정을 그대로 전투 판정에 사용하지 않음 |

실제 확인한 자료는 [Studio 전경](../../throne-defense/docs/evidence/maps-quality-v2/forest-native-final-overview.jpg), [근접 거리](../../throne-defense/docs/evidence/maps-quality-v2/forest-native-final-play.jpg), [폭포 측면](../../throne-defense/docs/evidence/maps-quality-v2/forest-native-final-waterfall.jpg), [목표 컨셉](../../throne-defense/assets/concepts/maps-battle-target-v1/forest.png)이다. 컨셉의 높은 식생 밀도·정교한 성역/원경과 실제 보존 화면의 구현 밀도는 다르다. 컨셉 이미지를 실제 완성 맵으로 안내하지 않는다.

첫 구역의 공간 흐름은 **포탈 인근의 안전 도착점 → 돌길의 고블린 교전 → 거목이 보이는 오우거 공터 → 성역 방향의 다음 목표**로 제안한다. K0의96×96stud는 이 안의 전투 검사 구역 예산이며 Deepwood 전체 크기가 아니다. 폭포/절벽은 처음에는 풍경과 안전 경계로 활용하고 경사·좁은 통로·높이 차 전투는 기본기 확인 후 추가한다. 첫 본격 던전은 기존 계획의 「검은 뿌리의 제단」을 유지한다. 전체 주동선7지점·선택3구역·필수/선택 보스 배치는 [Deepwood 지역 설계](deepwood-region-design.md)에서 관리한다.

## 2. 영웅과 ID 대응

아래는 조사 기준의 기존 `Config.HERO_CLASSES`와 `Config.HERO_WEAPON_NAMES`의 정적 확인 결과다. 수치 밸런스나 영웅 레벨을 그대로 가져오는 표가 아니다.

| TD 클래스 키 | 표시명·무기 | RPG 원형과 유지할 정체성 |
| --- | --- | --- |
| `knight` | Knight · Sword | 기사·은청·검/방패 원형, 강철기사/성기사 두 계열 |
| `elf` | Elf Archer · Bow & Arrow | 엘프 궁수·녹색·활/화살, 명궁/마법궁수 |
| `dwarf` | Dwarf Axe Thrower · Axe | 드워프·갈색/주황·투척 도끼 원형, 강철/화약. 화약 계열은 보조 총포·폭탄 활용 |
| `mage` | Mage · Wand | 비전/바람+기초 물 입문,20 Pyro/Cryo,40 Pyro 대지/Cryo 번개,60 광역,80 최강 주문 |
| `priestess` | Priest · Holy Lantern | 성녀·백금·성광/등불. RPG 플레이어 클래스가 아닌 교단NPC·선택형 지원 동료 |

TD 타워 팩션의 `wizard`는 플레이어 영웅의 `mage`에 대응한다. `priestess`는 표시명이 Priest여도 기존 키다. RPG 내부 ID는 별도 명명하되 명시적 대응표를 두고 표시명을 저장 키로 사용하지 않는다. `priestess`는 TD 키로 보존하고 RPG에서는NPC 원형/동료ID에 대응하며 플레이어 생성용 `baseClassId`에 포함하지 않는다. 타 클래스의 키를 전직 계열로 기록해서는 안 된다.

RPG 플레이어 원형4종과 세렌·에린·브란·이리아·셀레네5명은 각각 **플레이어 클래스와 개인 인물**이다. 성녀 셀레네는 주요 서사 인물·선택형 지원 동료로 유지한다. 리그·장비 키트를 공유할 수 있지만, 초상·얼굴·음성·개인 행동을 구분한다.

성녀의 플레이어 전환 제외와NPC 편성/지원 행동은 [동료·성녀 지원](companions-and-support.md)을 따른다. TD5원형 중4종은RPG 플레이어로, 성녀 원형은NPC로 활용하되 기존TD의 영웅/타워 구성과 진행은 보존한다.

## 3. 타워30종의 RPG 분류와 활용 후보

조사 기준 `Config.TOWER_LIST`의30개 정의를 빠짐없이 분류했다. **기존 타워 이름은 TD 소스 기준, 오른쪽 역할은 RPG 활용 제안**이다. 플레이어 직업과 타워의 일대일 대응, 모든 타워의 출연, 특정 재사용률을 확정하지 않는다. 먼저 RPG의 전투 경험을 설계한 뒤 적합한 몸체·무기·의상·모션·VFX를 선택한다.

| 클래스 | RPG 계열·학습 구간 | 기존 타워 | 활용 후보 |
| --- | --- | --- | --- |
| 기사 | 강철기사 | Swordsman / Shieldbearer / Ironwall / Lancer | 검·방패·창·반격 표현, 근접 교관·전선 방어군 |
| 기사 | 성기사 | Paladin / Crusader | 성광 검술·성전사·근접 광역, 서약 교관 |
| 엘프 | 명궁 | Archer / Rapid Shooter / Sharpshooter | 사격·속사·저격 표현, 궁술 교관·엄호군 |
| 엘프 | 마법궁수 | Storm Archer / Warden | 마법 화살·자연 제어, 정령 교관·통로 지원 |
| 엘프 | 공통 추적·지원 | Tracker | 추적 교관·정찰 NPC·일부 기술 표현 |
| 드워프 | 강철 | Axe Thrower / Twin Axe | 도끼 투척/회수·파쇄 표현, 도끼 교관 |
| 드워프 | 화약 | Gunner / Mortar / Grenadier | 총포·폭탄·포격 표현, 공성 교관·지원 포대 |
| 드워프 | 제작·장치 지원 | Runesmith | 제작 NPC·룬 장치·지원 병력 |
| 마법사 | Lv1~19 비전 입문 | Arcanist | 기초 비전 교관·마력 표현 |
| 마법사 | Lv1~19 바람 입문 | Zephyrmancer | 기초 바람 교관·돌풍 표현 |
| 마법사 | Lv20 Pyro 전직 | Pyromancer | 화염 교관·주력 화염 주문 표현 |
| 마법사 | Lv20 Cryo 전직 | Cryomancer | 빙결 교관·주력 서리 주문 표현 |
| 마법사 | Lv40 Pyro 대지 학습 | Geomancer | 대지 교관·지형/분출 표현 |
| 마법사 | Lv40 Cryo 번개 학습 | Voltmancer | 번개 교관·연쇄 주문 표현 |
| 성녀NPC | 심판·정화 지원 역할 | Judgment Priest / Inquisitor / High Priest | 성광·정화·심문 표현, 교단 인물·지원군 |
| 성녀NPC | 축복·보호 지원 역할 | Light Nun / Blessing Priest / Holy Cantor | 보호·축복 표현, 치유 시설·교단 NPC |

**Crusader는 Paladin과 함께 성기사 계열**이라는 사용자 결정을 따른다. 기존 회전 공격은 RPG에서 성광을 두른 근접 광역으로 발전시키는 후보이며, 기존 TD의 공격 속성·역할·코드를 바꾼 것이 아니다. 성기사는 계속 기사 클래스에 속하며 NPC 성녀의 지원 기술/성장을 가져오지 않는다.

Tracker의 공통 추적, Runesmith의 제작/장치 역할은 세 번째 전직 계열이 아니다. 드워프 화약 계열에 맞는 몸체·총포·조준/재장전 모션이 부족하면 새로 제작하고, Mortar는 플레이어 몸체 대신 지원 포대로 활용할 수 있다. 폭발 가독성과 터치 조작은 RPG용으로 검증한다.

마법사는 위 여섯 타워를 여섯 전직으로 만들지 않는다. 비전/바람은 입문, Pyro/Cryo는 두 전직 계열, 대지/번개는 각 계열의 추가 학습이다. 기초 물 마법의 교관·모션·효과는 적합한 기존 자산이 없으면 새로 제작한다. Lv60 광역·Lv80 최강 마법도 필요한 파생/신규 자산을 산정한다. 타워 자동 공격을 그대로 플레이어 기술로 쓰지 않으며, 자세한 학습은 [마법 분류](magic-schools-and-learning.md)를 따른다.

## 4. 네 테마의 몬스터 카탈로그

아래는 조사 기준 `Config.THEME_ROSTERS`의 테마별10개 엔트리를 직접 확인한 목록이다. 카탈로그40개는 고유 메시40개 또는 RPG 행동40개가 완성됐다는 뜻이 아니다. 예를 들어 숲의 Enraged Warlord는 기본 Warlord의 `kind`와 변형을 공유한다. 컨셉 README도40파일/39고유 디자인으로 구분한다.

| 테마·지역 | 일반 적5개 | 보스5개 |
| --- | --- | --- |
| forest · Deepwood | Goblin / Cave Slime / Orc Warrior / Ogre / Goblin Shaman | Orc Warlord / Goblin King / King Ogre / Enraged Warlord / King Shaman |
| snow · Frozen Vale | Ice Wolf / Ice Troll / Ice Bear / Ice Golem / Ice Elf | Ice Troll King / King Ice Bear / King Ice Golem / Queen Ice Elf / Ancient Glacier King |
| volcano · Ember Caldera | Imp / Lava Slime / Golem / Magma Worm / Volcano Shaman | Magma Imp / Magma Golem / Inferno Overlord / Caldera Titan / King Volcano Shaman |
| cemetery · Haunted Graveyard | Zombie / Skeleton / Mummy / Hellhound / Ghoul | Skeleton Knight / Lich / Death Knight / Lich Sovereign / Dread Commander |

과거 TD 문서의 “아이스 곰을 골렘으로 교체”, “일반몹4종” 같은 단계 기록과 현재 Config 카탈로그가 다르다. 이 표는 **조사 기준 소스의 목록**을 뜻하며 과거 기록을 삭제하거나 모든 게임에서 동일한 구성을 확정하는 결정이 아니다. RPG에서 각 적의 실제 배치·리그·역할은 별도 채택표로 승인/검증한다.

Goblin Scout·Ascendant Goblin King·King Clone처럼 Config에 별도 정의가 있는 항목도 위40엔트리와 구분한다. 사용 가능한 코드 정의 수를 실제 RPG 제작 몬스터 수로 합산하지 않는다.

RPG 행동 변환 우선순위는 Goblin → Ogre → Shaman → King Shaman으로 두어 측면 압박·예고·지원 적·복합 보스를 차례로 검증한다. 이후 장갑형·분열형·돌진형·주문형을 공통 행동 틀로 확장한다. TD의 경로 행진·왕좌 피해·웨이브 HP 값을 RPG에 그대로 복제하지 않는다.

### 4.1 Deepwood 10종의 현행 모델 연결

RPG 1차 컨셉은 [갤러리](../assets/concepts/2026-10-27-v1/index.html)와 [출처·제작 메모](../assets/concepts/2026-10-27-v1/README.md)에 모았다. 영웅4종은 TD의 승인된 hero-icons 초상을 기준으로 전신을 확장하고, 성녀는 기존 등불 성녀의 지원NPC 후보로 분리했다. 몬스터는 아래 현행10종에 대응하는 개별 컨셉PNG를 변경 없이 재사용하며, 좀비가 남은 구 모음 그림은 기준에서 제외한다. 새 이미지의 후면·하체·UI·지역 배치는 구현 전 제안이며 기존3D 모델의 정확한 재렌더나 새 개인 인물 외형 확정으로 취급하지 않는다.

2026-10-27에 `Config.THEME_ROSTERS.forest`, 일반 프로젝트의 `ServerStorage.MonsterModels` 참조, 그 실제 XML의10종 템플릿·MeshId를 대조했다. 현행 프로젝트는 [슬라임 통합 runtime](../../throne-defense/assets/models/meshy-deepwood-slime-v1/runtime.rbxmx)을 참조한다. 기존 모델의 형상 정보는 [블로키 몬스터 R2 메타데이터](../../throne-defense/assets/models/meshy-blocky-monsters-v1/runtime-metadata-r2.json), 추가 슬라임은 [통합 메타데이터](../../throne-defense/assets/models/meshy-deepwood-slime-v1/runtime-metadata.json)에서 확인했다.

| 구분 | 몬스터 | gameplay kind·variant | 실제 연결된 시각 키 | 템플릿 MeshPart 수 |
| --- | --- | --- | --- | --- |
| 일반 | Goblin | `goblin` | `goblin` | 5 |
| 일반 | Cave Slime | `slime` | `slime` | 1 |
| 일반 | Orc Warrior | `orc` | `orc` | 5 |
| 일반 | Ogre | `ogre` | `ogre` | 5 |
| 일반 | Goblin Shaman | `shaman` | `shaman` | 3 |
| 보스 | Orc Warlord | `warlord` | `warlord` | 5 |
| 보스 | Goblin King | `king` | `king` | 3 |
| 보스 | King Ogre | `king_ogre` | `king_ogre` | 3 |
| 보스 | Enraged Warlord | `warlord`·`enraged` | `warlord:enraged` | 1 |
| 보스 | King Shaman | `king_shaman` | `king_shaman` | 3 |

**오래된 forest 미리보기의 Zombie를 최신 명단으로 사용하지 않는다.** 현재 두 번째 자리는 Cave Slime이다. 현행 슬라임은1메시·2,989tri이고 TD에서 부모 사망 후 절반 크기/절반 최대HP의 자식2기로 분열하며 자식은 재분열하지 않는다. 기존 [실제 분열 비교 화면](../../throne-defense/docs/evidence/deepwood-slime/split-half/native-play-comparison.jpg)과 기록을 확인했다. RPG에서도 분열형 후보로 활용하되 개체 상한·근접 대응·보상은 RPG 기준으로 설계한다.

Enraged Warlord는 gameplay kind를 Orc Warlord와 공유하지만 **전용 `warlord:enraged` 외형 템플릿**이 연결돼 있다. 단순 색상 변경만 존재한다고 가정하지 않는다. Goblin Scout·Ascendant Goblin King·King Clone은 이10종 명단에 넣지 않는다.

이 확인은 현재 로컬 소스/프로젝트/모델 연결과 보존 화면의 대조다.10종을 이번에 새로 소환하거나 RPG 공격/리그/모션을 검증한 결과는 아니다. K0의 고블린·오우거는 첫 기본기 검증 범위이며 Deepwood 전체 몬스터를2종으로 줄이는 결정이 아니다.

## 5. 실제 파일 후보와 확인 범위

조사 기준일에 아래 경로의 존재를 확인했다. README와 Config는 읽어 범위를 확인했고, 나머지3D/메타데이터 후보는 파일 탐색으로 찾은 것이다. 이 문서 작성 과정에서 메시를 열어 품질·라이선스·리깅·적용 버전을 전수 검증하지 않았다.

| 후보 | 참조 | 용도·현재 판단 |
| --- | --- | --- |
| 공유 원형 정의 | [Config.lua](../../throne-defense/src/Shared/Config.lua) | 영웅·무기·30타워·테마 몬스터의 코드 기준 |
| 미술 방향 | [art-style-guide.md](../../throne-defense/docs/art-style-guide.md) | 색·재질·무기·최신 컨셉 우선순위 확인 |
| 타워 컨셉30종 | [README](../../throne-defense/assets/concepts/towers/blocky-v1/README.md) | 투명 PNG 참고. 메시나 업로드 완성본이 아님 |
| 몬스터 컨셉40파일 | [README](../../throne-defense/assets/concepts/monsters/2026-10-25/blocky-v1/README.md) | 39고유 디자인. 삼각형 수·리그 보증 없음 |
| 몬스터 조형 표본 | [README](../../throne-defense/assets/models/monsters-concept-v2/README.md) | 일부 비교 표본이며 전체 완성 세트 아님 |
| 블로키 몬스터 메타데이터 | [runtime-metadata.json](../../throne-defense/assets/models/meshy-blocky-monsters-v1/runtime-metadata.json) | 적용 후보 추적용. RPG 호환성 미검증 |
| 영웅 무기 후보 | [runtime-metadata.json](../../throne-defense/assets/models/hero-weapons-latest-v1/runtime-metadata.json) | 무기 형상·장착 기준 확인 후보 |
| 저복잡도 타워 후보 | [sculpt-manifest.json](../../throne-defense/assets/models/compact-performance-v1/towers/sculpt-manifest.json) | 성능 비교 후보. 실제 최종 채택 여부 별도 |
| 몬스터 제작 목록 | [manifest.json](../../throne-defense/assets/models/monsters-production-v2/manifest.json) | 원본/파생 출처 확인 후보 |
| 성채 환경 재질 | [manifest.json](../../throne-defense/assets/models/lobby-concept-materials-v2/g1-native/runtime-upload/manifest.json) | 재질·UV·권한 확인 후보 |

파일명에 `latest`, `production`, `runtime`이 있어도 현재 런타임의 실제 채택본임을 보장하지 않는다. RPG 자산 등록 전 소스 코드·채택 메타데이터·실제 Studio 장면을 교차 확인한다. 공개 Roblox 자산 ID를 추측하거나 새로 업로드하지 않았다.

## 6. 재사용 파이프라인

**RPG 역할·전투 요구 정의 → 기존 후보 조사·출처/권한 확인 → 직접/부분 재사용·NPC/지원 배치·신규 제작 판단 → 필요한 파생/신규 제작 → 리그/애니메이션·근접 품질 → 충돌/판정 → 성능 → Studio/실기기 검증 → 버전 채택** 순으로 진행한다. 기존 모델을 먼저 고른 뒤 그 모델에 맞춰 직업의 핵심 행동을 축소하지 않는다.

자산 레지스트리에는 다음 필드를 둔다.

| 영역 | 기록할 내용 |
| --- | --- |
| 식별 | 공통 원형ID, 게임별 파생ID, 원본 저장소/경로/리비전, 파일 해시 |
| 활용 결정 | 플레이어/NPC/동료/지원 용도, 직접/부분 재사용/신규 제작, 활용 부품·신규 필요 항목·선택 이유 |
| 권한 | 제작/생성 출처, 사용 가능한 소유자, 라이선스, 업로드 권한·경험 사용 권한 |
| 형상 | 단위·축·피벗·키/반경, 삼각형·재질·텍스처 크기, 리그·무기 소켓 |
| 게임성 | 시각 메시/충돌/공격 판정 분리, 공격 모션, 기본 자세, 지원 LOD |
| 적용 | TD/RPG별 버전, Roblox ID가 있다면 실제 확인한 ID, 빌드 채택 상태 |
| 검증 | 가까운 카메라·전투 거리·지역 조명·실기기·리그/애니메이션 결과 |

최초에는 `assets/shared-source/`에 출처 참조, `assets/rpg-derived/`에 파생본, `assets/manifests/`에 대응표를 두는 구조를 제안한다. 실제 자산 복사·생성은 아직 수행하지 않았다. 원본을 직접 덮어쓰기보다 파생본과 변경 이유를 기록한다.

### 캐릭터·몬스터 수용조건

1. 기본 대기와 극단 자세에서 손·얼굴·무릎·무기·망토가 무너지지 않는다.
2. 무기 피벗·장착 손·시위·도끼 회수 방향이 실제 모션과 일치한다.
3. 근접 얼굴과 전투 거리 실루엣 양쪽에서 원형이 읽힌다.
4. 전직 장식이 동일 클래스의 무기·몸체 정체성과 공격 예고를 보존한다.
5. 시각 메시와 충돌을 분리하고, 원래 TD 스케일이 RPG 피격 범위를 결정하지 않는다.
6. 중립 조명과 실제 네 지역에서 색·금속/천/가죽·과한 발광을 비교한다.
7. 메시 구조 검사·Blender 렌더·Studio 렌더·모바일 FPS·사용자 미술 수용을 별도 기록한다.

### 환경·왕좌·포탈 수용조건

TD의 U자 길과 타워 패드를 RPG 탐험 지역으로 그대로 확대하지 않는다. 기존 돌길·나무·바위·성벽·설원/화산 재질을 모듈 키트로 사용해 왕복 동선·수직 이동·엄폐·시야를 새로 구성한다. 추락 복구와 스트리밍 경계도 확인한다.

왕좌는 평상시·균열·수호전 손상·복원·서약망 상태를, 포탈은 닫힘·예고·활성·불안정·봉인 완료 상태를 구분한다. 가까운 시점과 큰 전장 양쪽에서 상태가 읽히고, 상호작용 프롬프트가 전투 목표와 혼동되지 않아야 한다.

## 7. 공유 세계관 변경 절차

TD와 RPG 공통 사전에는 원형 클래스·팩션·몬스터 종·지역·왕좌·포탈의 의미를 둔다. RPG 전용 인물·사건·전직·서약망은 별도 영역에 기록한다. 새 역사적 사실이 TD의 서사와 충돌하면 “RPG에서 발견되는 숨은 진실”인지 “기존 설정 변경”인지 먼저 구분한다.

연대·지도·고유명의 공통 정본은 후속 세계관 설정집에서 확정한다. 공유 자산은 게임별 버전 채택을 통해 업데이트하고, 이전 버전의 파일·해시·권한·채택 이력을 남긴다. 이미 TD에서 검증한 자산이라는 이유로 RPG의 조작·리깅·성능 검증을 생략하지 않는다.

## Frozen Vale 상세 설계 연결

[에픽2의 TD10종 역할표](epic-02-frozen-vale-story.md#4-기존-몬스터10종과-선택-탐험)와 [맵 디자인](frozen-vale-map-design.md)에 설원 원본 컨셉/소스/모델 정체성 활용을 정리했다. [출처/해시 목록](../assets/maps/frozen-vale-v1/source-references.json)은 로컬 참조 기록이며 개별 리그/애니메이션 수용이나 런타임 공통 패키지 연결 완료를 뜻하지 않는다.

## Ember Caldera 상세 설계 연결

[에픽3 TD10종 역할표](epic-03-ember-caldera-story.md#4-td10종과-선택-탐험) · [맵 제작안](ember-caldera-map-design.md) · [원본 경로/해시](../assets/maps/ember-caldera-v1/source-references.json). 화산 원본 모델/환경/공통 UI 공유를 우선하며 개별 리그/모션·런타임 연결은 후속 검증한다.

## Haunted Graveyard 상세 설계 연결

[묘지10종 역할표](epic-04-haunted-graveyard-story.md#4-td10종과-선택-구역) · [맵 제작안](haunted-graveyard-map-design.md) · [원본 경로/해시](../assets/maps/haunted-graveyard-v1/source-references.json). 베이르는 Lich Sovereign 원본,선택 Lich는 별도 역할이다. 원본 컨셉/소스 참조와 개별 리그/모션/런타임 수용을 구분한다.
