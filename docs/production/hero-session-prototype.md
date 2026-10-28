# 로비·영웅 세션 원형의 기술 계약

2026-10-28 · ENG · 관련 작업 TLT-041·051·008의 제한된 원형. 이 문서는 계정 저장·DS-01~04·전직/스킬·최종 직업 전투 완료를 뜻하지 않는다. 통합 실행 증거와 빌드 마감은 [로비 작업 기록](../evidence/k0/hero-lobby.md)의 별도 담당자가 관리한다.

## 실제 범위와 원천

사용자의 최신 요청은 기본 로비에서 네 원형 영웅을 만들고, 같은 접속에서 각각 선택해 튜토리얼/기본 공격을 시험하는 것이다. 최초 클래스는 **각 영웅별 불변**이다. 현재 원형은 클래스당 한 명·최대 네 명의 세션 영웅을 제공한다. 이 제한을 최종 계정 슬롯 수나 과금 정책으로 확정하지 않는다.

문서/제품 기준은 [공통 지침](../../AGENTS.md), [결정표](../decisions.md), [프롤로그 사양](../prologue-dawnspire-tutorial.md), [기술 계획](engineering-plan.md)이다. TD 시작 Place·운영 소스·DataStore·Diamonds·상품·구매권은 연결하지 않는다. 새 프레임워크나 라이브러리를 설치하지 않는다.

게임에는 `Session prototype: heroes and practice progress reset when you leave.`와 `Practice only: no story rewards or saved progress.`를 표시한다. 서버 메모리의 영웅과 연습 체크는 사망/로비 복귀 동안 유지되지만, 서버를 떠나거나 서버가 종료되면 사라진다. 재접속 복구를 제공하지 않는다. 장비는 현재 검증용 외형이며 영속 아이템 소유권/인벤토리가 아니다.

## 서버 소유권과 상태 전이

`src/server/Lobby/HeroSessionService.luau`가 플레이어별 roster와 `heroId → baseClassId`를 단독 소유한다. GUID는 서버가 만든다. 클라이언트는 새 영웅을 만들 클래스나 이미 소유한 heroId를 요청할 수 있지만 기존 영웅의 클래스를 바꾸는 API는 없다.

| 상태 | 실제 동작 | 전투 컨텍스트 |
| --- | --- | --- |
| LoadingLobby | 새 중립 캐릭터를 Dawnspire에 로드 | nil |
| Lobby | 서버가 전체 로비 바닥 범위·현재 생명·준비·생존을 검사한 뒤 생성/선택/출발 허용 | nil |
| LoadingTutorial | epoch를 먼저 올리고 기존 생명 권한을 철회한 뒤 선택 영웅의 새 Character 요청 | nil |
| Tutorial | 지정 훈련장 spawn에서 준비를 확인한 현재 생명만 전투/연습 허용 | 현재 영웅 snapshot |
| ReturningLobby | 전투 권한을 즉시 철회하고 새 중립 Character를 Dawnspire에 요청 | nil |
| SpawnFailed | 이전 생명은 계속 비활성. Retry Lobby로 새 복귀 요청 가능 | nil |

로비/훈련장은 같은 격리 Place 안의 서로 떨어진 공간이다. 이 이동은 TeleportService나 TD Experience 연동 검증이 아니다. 로비 바닥 중심 `(0,96,512)`, 범위 `160×40×160`은 `LobbyWorld.create().bounds`에서 받고, spawn의 14stud 근처로 생성/선택 범위를 제한하지 않는다. 바닥 밖·낙사 중·다른 지역·비유한 위치 요청은 거부하고 플랫폼으로 돌아오라는 영어 오류를 제공한다.

로비로 돌아오는 요청은 원형의 연습 중 언제든 허용한다. 이 동작은 전투 권한을 먼저 폐기하고 새 생명을 만들며 보상/성장을 주지 않는다. 실제 클래스 선택과 다른 영웅 출발은 로비에 살아서 도착한 뒤에만 가능하다.

### 영웅·생명 계약

```lua
HeroSessionService.getActiveHero(player)
-- nil 또는 { heroId, classId, epoch } : 선택 상태의 복사본

HeroSessionService.getCombatContext(player, character)
-- nil 또는 {
--   heroId, baseClassId, epoch, characterGeneration
-- } : Tutorial의 현재 준비된 Character에만 반환
```

두 API는 서버 전용·동기식이고 내부 테이블을 그대로 반환하지 않는다. `epoch`는 전환 시작·사망/제거·새 생명 경계에서 증가하며, `characterGeneration`은 SpawnService가 새 Character마다 증가시킨다. 영웅 전환에 기존 Character를 재사용하지 않는다.

`K0ClassId`, `K0HeroId`, `K0HeroEpoch`, `K0CharacterGeneration`, `K0SessionPhase`는 서버 상태에서 파생한 표현용 복제다. 전투는 클라이언트가 보낸 클래스나 이 속성에 대한 클라이언트 주장을 권위로 쓰지 않고 `getCombatContext`의 현재 네 필드를 검사한다. 전투 서비스는 heroId별 최초 클래스를 기억하고 입력·타격·AI 표적에서 오래된 컨텍스트를 거부한다.

### SpawnService와 늦은 콜백

```lua
SpawnService.start(lobby.spawn, {
  onLifeStarted = HeroSessionService.onLifeStarted,
  onReady = HeroSessionService.onReady,
  onLifeEnded = HeroSessionService.onLifeEnded,
})
SpawnService.requestSpawn(player, serverDestination, transitionId)
-- 성공 true / 거부 false, errorCode. transitionId는 양의 증가 정수.
-- 콜백: (player, character, generation, transitionId, reason?)
```

초기 요청 ID는 0이다. 기존 `CharacterAutoLoads=false`, 직렬 LoadCharacterAsync, 안전 배치, 불완전 로드 재시도, 지수 backoff를 유지한다. 각 플레이어의 `desiredRequest`에 목적지와 전이ID를 저장하고, 진행 중 로드는 원래 `loadRequest`를 캡처한다. 로딩 중 새 목적지가 오면 기존 로드를 마친 뒤 최신 요청의 Character 하나를 만든다. 과거 목적지의 준비 콜백으로 새 요청을 활성화하지 않는다.

요청이 바뀌지 않은 API 실패는 2/4/8초 상한 backoff로 재시도한다. 실패 시 CharacterAdded가 없다는 이유만으로 즉시 재시도하지 않는다. 캐릭터 제거/죽음과 플레이어 종료는 이전 generation의 타이머/리스너가 새 생명을 변경하지 못하도록 막는다.

초기화 순서는 World 생성 → HeroSessionService 등록 → 외형/팔레트 관찰 → CombatService에 동기 resolver 주입 → SpawnService 캐릭터 생성이다. 세션 레지스트리가 없는 상태에서 자동 Knight를 생성하지 않는다.

## Remote 요청과 방어

| RemoteEvent | 입력/출력 |
| --- | --- |
| `Remotes.K0HeroRequest` | `(action, requestId, argument?)` |
| `Remotes.K0HeroState` | `(snapshot, requestId?, errorCode?)` |

허용 action은 `GetState`, `CreateHero(classId)`, `SelectHero(heroId)`, `StartTutorial`, `ReturnLobby`다. requestId는 길이 1~48의 영문/숫자/밑줄/하이픈 문자열이며, 선택 heroId는 최대64자다. 추가 인자·테이블·허용 밖 클래스·임의 action을 거부한다. 서버가 Player의 roster와 현재 상태를 다시 확인한다. 목적지·CFrame·피해·레벨·재화·소유권을 클라이언트 입력으로 받지 않는다.

요청 버킷은 최대10, 초당4 보충이다. 초과 오류 응답도 0.5초 간격으로 제한한다. 최근32개의 요청 ID와 action/argument/결과를 보관해 재시도를 재생하고, 같은 ID의 다른 payload는 `RequestConflict`로 거부한다. 클래스당 하나의 영웅이라는 서버 불변식도 중복 생성과 늦은 재전송을 차단한다. 이 메모리 캐시는 영수증/영속 거래의 idempotency 구현이 아니다.

snapshot은 `revision`, `phase`, `heroes[{heroId,classId,practice}]`, `selectedHeroId`, `activeHeroId`, `canManage`, `canStart`, `maxHeroes`, `sessionOnly`다. 클라이언트는 오래된 revision을 표시하지 않고 요청 동안 연타를 제한하지만, 이 UI 제한 자체를 보안으로 간주하지 않는다.

## 영어 UI와 최소 튜토리얼

`HeroLobbyGui`는 네 승인 TD 초상, Create Hero/Select Hero, 선택 영웅, Start Tutorial, 세션 초기화·클래스 고정 안내를 표시한다. 이미지가 로드되지 않아도 영문 클래스명과 버튼이 남는다. 원본 ImageId는 `knight=103255177842108`, `elf=80894238854345`, `dwarf=74628903359757`, `mage=91907986271282`이다. 현재 계정의 Studio preload 성공과 게시된 Experience 권한/실기기 표시 검증을 구분한다.

훈련 HUD는 실제 직업명과 연습 목표를 보여주며, 방패 버튼은 Knight만 표시한다. Dwarf는 손도끼, Mage는 나무 지팡이를 들고 근접 공격한다. Elf는 `Face an enemy to shoot.` 안내로 정면 활 공격을 설명한다. 구체 전투 계수/타격/화살 시각은 별도 전투 담당의 K0 원형이다.

연습은 다음 세 가지 서버 관찰로 표시한다. 이동은 현재 생명의 준비 지점에서 6stud 이상 이동, 기본 공격은 서버가 증가시킨 `K0AttackSeq`, 회피는 서버가 만든 `K0State=Dodge`다. 연습 체크는 영웅별 접속 동안만 유지되며 명중/보상/퀘스트 달성으로 승격하지 않는다. 세 체크를 마치면 자유 연습을 안내한다.

DS-01~04의 이야기·NPC·구출·550XP/Lv5/198Coins·스탯16P/스킬4P는 구현하지 않았다. 연습을 완료해도 보상이나 임의 Lv5 캐릭터를 주지 않으며 승인 보상 정본은 변경하지 않았다.

전투 입력은 Tutorial의 준비된 생명에서만 보내고, 로비 전환·캐릭터 제거·창 포커스 해제·텍스트 입력·CoreGui 메뉴 열림에서 유지 공격/방어를 해제한다. non-Knight는 방어 입력을 보내지 않는다. 클라이언트 표현 조건을 우회하더라도 서버의 컨텍스트 검사를 거쳐야 한다.

## 검증과 인계

| 검사 | 결과/한계 |
| --- | --- |
| `lua tests/k0-hero-session.spec.lua` | 실제 서비스 소스에 identity/물리 벡터/remote fixture를 주입한77검사 통과. 네 영웅을 같은 플레이어로 순차 활성화, 소유/불변 클래스, 중복/충돌/위조, 전체 바닥 범위, 사망·복귀·오래된 콜백·실패 복구 |
| `lua tests/k0-spawn.spec.lua` | 기존4인 회귀와 영구 API 실패 backoff, 로딩 중 최신 목적지 합치기, 플레이어별 spawn, 살아있는 Character 교체, 이전 death/세대 재사용 거부 통과 |
| Lua 파싱/공백 검사 | 서버 세션/Spawn/bootstrap, 새 로비 GUI와 영어 문자열 파싱 및 `git diff --check` 통과. Luau 클라이언트 실행과 별도 증거 |
| native/실제 플레이 | 독립 QA와 총괄 담당. 이 문서의 unit 통과로 실제 Roblox Player 로드·엔진 물리·키보드/터치/패드·레이아웃·초상 권한·전투 성공을 대신하지 않음 |

QA는 `tests/k0-hero-lobby-native.luau`에서 실제 함수와 native rig를 검사하고, 총괄은 실제 클라이언트에서 로비→네 영웅 생성→각각 튜토리얼→복귀→재선택, 낙사/사망/Reset/빠른 요청/창 전환, 모바일 세로·가로/패드 탐색을 확인한다. 최종 빌드·버전·커밋/푸시는 통합 담당자가 수행한다.

공식 Roblox 근거(2026-10-28 확인): [서버 경계의 입력·권한·빈도 검사](https://create.roblox.com/docs/scripting/security/client-server-boundary), [Player의 Character/LoadCharacterAsync/리스폰 API](https://create.roblox.com/docs/reference/engine/classes/Player), [GuiService 메뉴와 선택 API](https://create.roblox.com/docs/reference/engine/classes/GuiService). 이 API 문서 확인은 실제 Place 실행 증거와 별개다.
