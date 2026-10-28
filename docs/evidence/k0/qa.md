# Deepwood K0 독립 QA

2026-10-28 · 관련 작업: TLT-005/006/007/031/034의 첫 원형 · 담당: QA

**초기 프로토타입 빌드를 차단할 확정 런타임 결함은 이번 검사에서 발견하지 않았다. K0 전체·G1 통과는 아니다.** 순수 경계56개, 외형 생명주기 모의 시험, 실제 Roblox Studio의 빈 Place 소스 probe37개 검사를 통과했다. 실제 Player가 없는 Run 모드였으며 조작·UI 렌더/사용성·원격 요청·플레이어 리스폰·모바일/네트워크는 미검증이다.

## 1. 범위·버전·환경

- 코드 확인: `src/server/Combat`, `World`, `Cosmetics`, `src/client`, `src/shared/K0Config.luau`, `K0Text.luau`.
- 검사 시 Git HEAD: `b9faae2ebaacedd531d5c1b65d3c7d328af23a8e`. 그 위 작업 트리의13개 소스 바이트를 probe manifest로 고정했다. 이 HEAD가 새 구현을 이미 포함한 커밋이라는 뜻은 아니다.
- 게임 버전은 총괄이 첫 빌드용 `0.1.0`을 예약 중이다. QA는 VERSION·커밋/푸시·Rojo 게임 빌드·릴리스·게시를 실행하지 않았다.
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
