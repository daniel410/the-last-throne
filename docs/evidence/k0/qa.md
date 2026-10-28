# Deepwood K0 독립 QA

2026-10-28 · 관련 작업: TLT-005/006/007/031/034의 첫 원형 · 담당: QA

**현재 수용 상태: 0.1.0의 실제 Play 첫 스폰 결함이 확인됐으며, 0.1.1 수정의 실제 Play 수용은 대기다.** 아래1~5절은 최초 소스의 순수56개·외형 모의 시험·Player=0 native Run37개 통과 기록이다. 이 검사는 첫 플레이어의 잘못된 스폰을 탐지하지 못했다. 최신 결함·0.1.1 후보39개 소스 probe와 필수 Play 절차는6절을 따른다. K0 전체·G1 통과는 아니다.

## 1. 범위·버전·환경

- 코드 확인: `src/server/Combat`, `World`, `Cosmetics`, `src/client`, `src/shared/K0Config.luau`, `K0Text.luau`.
- 검사 시 Git HEAD: `b9faae2ebaacedd531d5c1b65d3c7d328af23a8e`. 그 위 작업 트리의13개 소스 바이트를 probe manifest로 고정했다. 이 HEAD가 새 구현을 이미 포함한 커밋이라는 뜻은 아니다.
- 최초 검사 당시 총괄이 첫 빌드용 `0.1.0`을 예약 중이었다. QA는 VERSION·커밋/푸시·Rojo 게임 빌드·릴리스·게시를 실행하지 않았다. 이후 실제 빌드/Play의 판단은6절과 총괄 후속 증거로 구분한다.
- 도구: 로컬 Lua, Rojo sourcemap, `run-in-roblox 0.3.0`, 실제 macOS Roblox Studio. 별도 `/private/tmp/tlt-k0-source-probe/tlt-k0-qa-empty.rbxlx`에 소스를 주입했다. 이 빈 XML/임시 Source fixture는 고정 커밋에서 만든 게임 빌드가 아니다.
- 기존 Studio3개(TD 시작 Place와 `td-hero-status-empty.rbxlx`2개)는 전후 모두 Edit였다. 이 인스턴스를 수정/재생/종료하지 않았고 별도 probe는 실행 후 종료됐다.
- TD 운영 코드·DataStore·상품/영수증·Place 게시·사용자 계정 잔액/성장은 변경하지 않았다.

## 2. 검사와 실제 결과

| 검사 | 명령/조건 | 결과와 한계 |
| --- | --- | --- |
| 순수 전투 경계 | `lua tests/k0-rules.spec.lua` | **56개 통과**. 준비/유효/회복·취소 창·방어/무적 반개구간·비용 경계·사거리/각도/NaN·이동 허용량. 실제 원격/물리/클라이언트 타이밍 검사는 아님 |
| 외형 생명주기 | `lua tests/k0-appearance.spec.lua` | **통과**. 기존/신규 플레이어 모형·늦은 R15/R6 손 생성·중복 시작·리스폰·손 교체·제거 후 연결 해제·기존 장비 보존·9개 비충돌 장식/소켓 계약. Instance/CFrame/이벤트 모의 환경이며 실제 아바타/물리/관통 수용은 아님 |
| 런타임 테스트 제외 | `rojo sourcemap --output /tmp/tlt-k0-qa-sourcemap.json` 후 filePaths 검사 | 종료0, 테스트 소스 매핑0. 기존 `src/server/Combat/K0Rules.spec.lua`를 `tests/k0-rules.spec.lua`로 옮겨 게임 ModuleScript가 되지 않게 함 |
| 영어 원문 | `K0Text` 테이블34개 문자열을 Lua로 읽고 Unicode 범위 검사·원문 수동 검토 | 한글0, 현재 원문은 영어. 실제 화면/폰트/줄바꿈·Roblox 자체 UI 언어를 검사한 결과는 아님. 월드 간판의 직접 영어 문구도 확인 |
| 저장/보상 격리 | src의 서비스/입력 경로 정적 검토 | DataStore/Marketplace/영수증/Teleport·XP/Coins/Diamonds 지급 경로 없음. Remote는 행동 의도만 받고 피해/자원/자격을 서버 코드에서 계산. 실제 부정 원격 전송은 미실행 |
| Studio 소스 probe | 아래 명령으로 새 빈 Place에서 ModuleScript Source 주입·RunService 실행 | **종료0,37개 통과, 실패0, 수집한 런타임 오류0**. ModuleScript11개 require와 서버/클라이언트 엔트리2개 native 컴파일 포함 |

```bash
python3 tests/make_k0_source_probe.py --output-dir /tmp/tlt-k0-source-probe
run-in-roblox --place /private/tmp/tlt-k0-source-probe/tlt-k0-qa-empty.rbxlx --script /private/tmp/tlt-k0-source-probe/source-probe.luau
```

native probe는 실제 서버 부트스트랩이 `DeepwoodK0`, 안전 Spawn, `K0Action` RemoteEvent, 초기 적2개를 만드는지 확인했다. 두 적의 서버 HP/자세 초기화·플레이어0일 때 Idle·연속 지면 위 물리 안정과 Goblin 사망→설정 시간 후 단일 재생성/HP/AI 복구도 확인했다.

| native 관측 | 실제 값 |
| --- | --- |
| Player 수 | 0 |
| Goblin | HP300, root Y≈2.5500, 속도≈0.0000064stud/s |
| Ogre | HP6000, root Y≈4.3500, 속도≈0.0000130stud/s |
| 사망 후 Goblin | 새 Model·HP300·Idle·적 총2개 유지 |
| 컴파일/실행 | ModuleScript11개 require·엔트리2개 컴파일, 총37개 검사 통과 |

stdout에는 `rbxassetid://203785492`의 asset type 불일치 경고1건이 별도로 나왔다. 현재 K0 소스에는 이 ID나 `rbxassetid` 참조가 없다. 경고 발생 원천은 미확정이며 K0 자체 자산 로딩 수용으로 처리하지 않는다. probe의 LogService 오류 수집은0이었다.

## 3. 지적·수정·남은 범위

| 항목 | 상태와 근거 |
| --- | --- |
| 기사 외형 시작 누락 | 최초 검토 때 `KnightAppearance.start()`가 시작점에 없음을 전달. 총괄이 연결한 소스를 재확인했고 native 부트스트랩도 성공. 실제 Player의 검/방패 화면은 미검증 |
| 기본 공격 홀드 미구현 | 최초 InputBegan/Activated 단발 호출을 전달. 총괄이 입력별 홀드 추적·0.14초 반복·방어 중 중단·포커스/리스폰 정리를 추가. 정적 재검토 완료, 실제 PC/터치/패드 입력 재검증 대기 |
| 테스트가 게임에 포함됨 | 총괄 요청으로 순수 시험을 tests/로 이동하고 실행 경로 수정.56개와 sourcemap 제외를 재확인 |
| 원격 입력의 동일성/리스폰 구분 | 현재 Remote는 action/direction만 받는다. 타입/길이/추가 인자·유한 벡터·버스트 제한·상태/자원/거리 검증은 있으나 `inputSeq`/`lifeId`가 없다. 오래된 입력·재전송 동일성·새 캐릭터 경계는 남은 구현/검증이며 TLT-006/034 완료 근거가 아님 |
| 서약 | 서약 게이지·공격/방어/완벽 방어의 서약 획득은 미구현. HP/스태미나·적 자세가 있다는 사실을 K0 전체 자원 구현 완료로 보고하지 않음 |
| 긴 서버 프레임/지연 | 실제 heartbeat가 짧은 유효 구간을 건너뛰는 경우·판정/모션 차이와80/150/250ms는 미검증. 순수 phase 경계 성공으로 실제 적중/네트워크 수용을 대신하지 않음 |

피해·방어·회피의 실제 교전과 안전 SP·리스폰 타이밍은 Player가 있는 클라이언트에서 이어서 검사해야 한다. 이번 native 물리 수용은 두 적의 **무교전 초기 상태/재생성**에 한정한다. AI 추적/경로 탐색·공격·자세 붕괴·플레이어 사망/재생성·타격 중단·원격 부정 요청은 아직 실행하지 않았다.

## 4. 테스트 산출물과 다음 담당

- [순수56개](../../../tests/k0-rules.spec.lua): 기존 검사를 보존하고 런타임 밖으로 이동.
- [외형 모의 생명주기](../../../tests/k0-appearance.spec.lua): 모델링 담당의 임시 fixture를 읽고 독립 재실행한 재현본.
- [Source probe 생성기](../../../tests/make_k0_source_probe.py): 현재 K0 소스13개와 해시를 빈 Place에 주입. Rojo 빌드/게시를 수행하지 않음.
- [빌드 후 native smoke](../../../tests/k0-build-smoke.luau): 소스 probe와 첫 고정 빌드 양쪽에서 같은37개 기준 사용. 실제 Player/클라이언트 수용은 제외.

총괄이 VERSION/소스 커밋·푸시와 첫 빌드를 고정한 뒤 다음 명령으로 **그 빌드**를 검증한다. `<고정-빌드>`는 실제 성공 산출물 경로로 바꾼다. QA가 이 명령의 빌드 경로 실행을 이미 완료했다는 뜻은 아니다.

```text
run-in-roblox --place <고정-빌드> --script tests/k0-build-smoke.luau
```

이어서 PC 실제 클라이언트의 이동/마우스·3연격 홀드/중복 입력·방어/해제·회피 벽/지면·채팅/메뉴/포커스 전환·리스폰/늦은 입력·적 추적/공격을 검증한다. 터치/패드·기기별 화면·실기기 성능/부하·지연은 별도 결과를 남긴다. 현재는 첫 원형의 검증 기록이며 TLT 전체 Done이나 게임 게이트를 닫지 않는다. 커밋/푸시·빌드와 후속 수용의 다음 담당은 총괄/엔지니어·QA다.

## 5. 소스 스냅샷

probe의 `source-manifest.json` SHA256은 `0a698c879edef18f32b7ae7924fe6d834bddff1ee1dec67cc21b301921092019`다. 실행 후13개 소스를 다시 해시해 manifest와 차이0임을 확인했다. 원본 출력·manifest는 `/private/tmp/tlt-k0-source-probe/`에 있으며 장기 보존을 보장하지 않는다. 아래 지문으로 소스 바이트를 추적한다.

| 소스 | SHA256 |
| --- | --- |
| src/client/K0EnemyVisual.luau | `9ca2a78eeb898aac4b8af52c21d6ed673d5deb6e8300a13bdd6de8158f367cea` |
| src/client/K0Hud.luau | `cc4f303d24f392fb3a22a285b8d25f59d843d03fb1743fb900f7317813d10105` |
| src/client/K0SwordVisual.luau | `f12ae9986d2e6f234be57c86905d05eeee127dc4746f9ba3fb5e04f4d2270b2f` |
| src/client/K0Telegraphs.luau | `67ad953169df5ce62d1966b53525deed780f22f4410313f3b5d4bf434101116b` |
| src/client/init.client.luau | `d8403dec32e83e66c7d92fb98c70519617e3e98503472de10701c49f82d07ed6` |
| src/server/Combat/CombatService.luau | `ce8dce0ba46dbfa4668691308bb4cc391626865ecd8b4f4a22d60d37adc37377` |
| src/server/Combat/K0Rules.luau | `5281f757cd2e57ed4442cfbfb9fdaa9fdb3927d5853ac86c165c750c3208cdd4` |
| src/server/Cosmetics/KnightAppearance.luau | `42dc7ed609785e1f9b1a801bf2d92be2192a46642440468ae5d47289c0d5dea9` |
| src/server/World/TrainingField.luau | `747cab86cc15d3f17fad8d7860bd87c2b1128b8a06b7d4f58cd803f04d1c565b` |
| src/server/init.server.luau | `17737734f8904428a7302e3d4da6681f57f9c31b852a791db9b54305fa901338` |
| src/shared/Hello.luau | `68de9377a853c5dd3863901c12e8f29802b9d6d3dd01b99e44a8d332755cca8f` |
| src/shared/K0Config.luau | `40d3c41ea8d993abc35f96853a77228489586cc3dcba4372abce519085baeb8e` |
| src/shared/K0Text.luau | `abf34922a70d76a57847f950358d1accbb9faa4a62cf45d79c6b9c66815c9912` |

## 6. 0.1.0 스폰 결함과 0.1.1 후보 검증

### 실제 Play 결함: K0-QA-SPAWN-001

총괄이 **0.1.0 고정 빌드의 실제 Studio Play**에서 첫 플레이어가 안전 Spawn `(-20,0.1,56)` 대신 root `(0,3,0)`에 생성돼 Goblin 피해를 받는 것을 관측했다. 심각도는 첫 입장/안전 시작을 깨뜨리는 **S1**이며, 이 관측은 총괄의 실제 Play 결과다. QA가 같은 현상을 별도로 조작해 재현한 것으로 기입하지 않는다.

앞선 Run 모드 검사는 Player가0이고 Spawn 인스턴스의 존재만 확인했으므로 **이 결함을 탐지하지 못했다.** 두 적의 초기 물리가 안정됐거나37개가 통과했다는 사실은 플레이어 초기 위치·엔진의 캐릭터 생성 순서·이동 기준점·리스폰의 통과 증거가 아니었다. 실제 Play 수용을 생략할 수 없다.

### 수정 후보의 독립 정적/모의/native 결과

엔지니어 수정은 `Players.CharacterAutoLoads=false`를 프로젝트에 직렬화하고, 별도 SpawnService가 지정 `RespawnLocation`·로드/재시도·사망 후 생성·잘못된 위치 복구를 맡는 구조다. CombatService는 `K0SpawnReady=true`까지 전투 등록/이동 기준점 수집을 기다린다. 클라이언트에는 `LOADING`·`RETRYING`·행동 가능한 영어 재시도 안내가 추가됐다. 이 구현을 정적으로 검토했으며 **실제 Player 생성의 수정 수용은 아직 아니다.**

| 검사 | 실제 결과 | 한계 |
| --- | --- | --- |
| `lua tests/k0-spawn.spec.lua` | 통과.4플레이어 모형·실패 재시도·늦은 Humanoid·위치 복구·중복 방지·사망/늦은 사망 이벤트·이탈을 결정적 스케줄러로 확인 | 엔지니어 fixture를 tests/로 이동해 독립 재실행. Roblox 엔진의 캐릭터 배치·실제 사용자/통신 검사가 아님 |
| `rojo sourcemap --output /tmp/tlt-k0-011-qa-sourcemap.json` | 종료0, tests/spec 소스 런타임 매핑0 | 실제 Place 빌드·Player 생성 검사가 아님 |
| 0.1.1 후보 소스 probe | 종료0, **39개 통과·실패0·수집 런타임 오류0**. ModuleScript12개 require(SpawnService 포함), 서버/클라이언트 엔트리2개 native 컴파일, 기존 적/물리/재생성 검사 유지 | Player0. 스폰 서비스 모듈/시작이 실행돼도 실제 스폰 수정은 판단 불가 |

```bash
python3 tests/make_k0_source_probe.py --output-dir /tmp/tlt-k0-011-source-probe
run-in-roblox --place /private/tmp/tlt-k0-011-source-probe/tlt-k0-qa-empty.rbxlx --script /private/tmp/tlt-k0-011-source-probe/source-probe.luau
```

생성기는 프로젝트의 `CharacterAutoLoads=false`가 없으면 실패하고, 그 설정을 빈 Place에 동일하게 적용한다. Lua소스14개와 `default.project.json`1개의 해시를 입력으로 기록했다. 수정된 `K0Text`·`K0Hud`·클라이언트 엔트리도 native 컴파일 대상에 포함했다. smoke 결과에는 `spawnCoverage = Spawn instance only; initial Player placement and respawn require real Play`를 명시했다. 앞서 관측한 ContentId203785492 타입 불일치 경고는 이번에도 stdout에 나왔으며 원천 미확정 상태다.

새 manifest SHA256은 `ff95a773b26263a0e47db86aad8faa30e40ed1e8e9e47c8e14b5f415a79c0f70`이다. 검사 종료 뒤15개 입력을 다시 해시해 변경0을 확인했다. 원본/출력은 `/private/tmp/tlt-k0-011-source-probe/`에 있다. QA는 이 과정에서 게임 빌드·버전/태그·커밋/푸시·기존 Studio Play를 실행하지 않았다.

### 0.1.1 고정 빌드의 필수 실제 Play 절차

다음 담당은 정확한 격리 Studio와 고정 빌드를 선택하는 총괄이다. **실제 Play를 시작하고 Player가1명 이상 존재하는지 확인한다. Run 모드·스크립트로 만든 가짜 Player/아바타·수동 Pivot으로 수정을 대신하지 않는다.** 결과에는 빌드 버전/소스 커밋/산출물 해시·Studio ID·Server/Client 컨텍스트·시각·화면/로그를 붙인다.

1. **첫 입장/무입력3초:** Play 직후 첫 Character·root 위치를 가능한 빨리 기록하고, `RespawnLocation`이 `DeepwoodK0.Spawn`인지 확인한다. 로딩 중 위치와 `K0SpawnReady`/`K0SpawnStatus`·최초 `K0State`를 구분한다. 준비된 캐릭터는 안전 Spawn 근처에 있고, 전투가 준비되기 전에 원점에서 피해를 받거나 잘못된 이동 기준점에 고정되지 않아야 한다. 준비 후3초 동안 입력 없이 HP1000·적의 초기 공격 없음·안전 바닥을 확인한다.
2. **첫 조작:** 실제 클라이언트에서 WASD 이동 후 정지, 마우스 공격 홀드로1/2/3연격, 오른쪽 방어 홀드/해제, Space 회피를 수행한다. 위치가 정상 변하고 원점으로 되감기지 않는지, 상태·스태미나·검/방패·영어 HUD가 실제 캐릭터와 일치하는지 화면/서버 상태로 확인한다. 스크립트로 상태만 바꾼 결과를 실제 입력 통과로 처리하지 않는다.
3. **사망 후 리스폰:** 첫 캐릭터 인스턴스와 위치/시각을 기록한 뒤 격리 테스트 서버에서 의도적으로 HP0을 만든다. 사망 상태/입력 정리·설정된 재생성 지연 후 **새 캐릭터가 한 번만** 생기는지 확인한다. 새 root가 다시 안전 Spawn 근처에서 준비되고 HP1000/스태미나100으로 복구되는지, 무입력3초 동안 피해·원점 생성/되감김이 없는지 관측한다.
4. **리스폰 뒤 재조작/입력 정리:** 이동·공격·방어/해제·회피를 다시 수행하고 이전 캐릭터의 홀드/연격/콜백이 새 생명에 이어지지 않는지 확인한다. 채팅 입력과 포커스 이탈 때 공격/방어 입력이 정리되는지, HUD가 새 캐릭터의 HP/스태미나를 구독하는지도 확인한다.
5. **판정:** 첫 입장과 사망 후 안전 위치·초기 피해 방지·조작을 모두 확인한 실제 증거가 있어야 K0-QA-SPAWN-001을 수정 검증 완료로 바꾼다. 로딩 실패/재시도 안내 화면, 터치/패드·지연/실기기는 실행하지 않았다면 별도 미검증으로 남긴다.39개 native 성공만으로 이 결함을 닫지 않는다.

현재 판정은 **0.1.1 후보의 정적/모의/native 서버 검사는 통과, 실제 Play 수정 검증 대기**다. 총괄이 실제 고정 빌드의 Play 결과를 후속 증거로 추가한다.

## 7. 총괄의 0.1.1 고정 빌드 실제 Play 후속 확인

2026-10-28 · 소스 `2646dea48f8870e833cb33181be9ccdec22492de`, 빌드 SHA-256 `9c265365a4ef872c1e043bcac63c2c2d3f7d0464e2d6b5d22ebafc28a1f91a5e`. 이 절은 위 독립 QA의 후보 판정을 실행 이후 갱신한다. 빌드/로그 범위는 [빌드 기록](build.md)과 같다.

총괄이 `run-in-roblox`로 연 `PlaceId=0`의 별도 Studio Play 두 세션을 이용했다. TD와 기존 사용자의 Studio는 조작하지 않았다. 첫 세션에서는 Client의 첫 준비 상태가 root `(-20.014, 3.096, 56.011)`, Spawn 중심 `(-20, 0.1, 56)`, `K0SpawnReady=true`, `K0SpawnStatus=Ready`, `K0State=Idle`, HP1000/1000, 스태미나100이었다. 영어 HUD와 임시 검·방패도 존재하고 화면에 나타났다.

같은 세션에서 Studio 가상 마우스 왼쪽을 1.7초 유지했을 때 클라이언트가 관찰한 최대 `K0Combo=3`이었다. 오른쪽 버튼을 누르고 있을 때 `Block`, 스태미나96을, 버튼을 놓은 뒤 `Idle`을 확인했다. Space 키에는 `Dodge` 상태와 스태미나 최저70, 시작 위치에서 약7stud 이동을 관찰했다. 이 결과는 Studio에서 주입한 입력이며 물리 PC·터치·패드의 실기기 검사나 적을 맞힌 실전 교전이 아니다.

두 번째 별도 Play 세션에서는 준비된 첫 Character의 서버 HP를0으로 설정했다. 약5.8초 뒤 이전 객체와 다른 Character가 `(-20, 3.096, 56)`에서 준비됐고, `Idle`, HP1000/1000, 스태미나100과 `K0SpawnReady=true`를 확인했다. 수동 위치 이동은 사용하지 않았다. 이 두 관측으로 0.1.0의 원점 스폰 및 사망 후 원점 재생성 경로는 해당 조건에서 개선됐지만, 리스폰 후 재조작·3초 무입력·다인 동시 스폰·실제 네트워크의 전체 수용은 아직 남아 있으므로 작업 티켓 전체를 Done으로 바꾸지 않는다.

화면에서 표지 기둥이 글자를 가리는 문제가 확인됐다. `0.1.2`의 시각 수정 후 별도 화면 검증이 필요하다. 적 추적·실제 피해/사선·방어 타이밍·모바일/게임패드·지연·오래된 원격 입력·서약 자원도 여전히 미검증 또는 미구현이다.
