# 전체 공격·스킬 PixelFX 연결

2026-11-04 · TLT-005/032/033/055/057/084 · ENG/ART 자체 검증 → QA/DES

사용자가 PixelFX를 전체 공격/스킬에 적용하도록 요청했다. 기존 [도입 검토](../../research/2026-11-04-pixelfx-review.md)의 샘플을 게임용20종으로 확장해 네 영웅 기본 공격·128스킬, Selene 지원3행동, 몬스터 공격 방출/플레이어 확정 피격에 연결했다. **로컬 소스 구현이며 실제 화면/실기기/최종 미술 수용은 아직 아니다.** 피해·기술 정의·MP·쿨다운·해금·보상/저장·TD 소스/권리는 변경하지 않았다.

## 연결 범위

| 경로 | 적용 내용 |
| --- | --- |
| 기본 공격4클래스 | 복제된 행동 시각과 콤보의 접촉 시점에 검/도끼/활/비전 보조 효과. 명중하지 않은 공격에도 방출 표시 |
| 기존 공통12스킬 | 준비/접촉 지연을 따르고 Rapid Fire3발은 각각 재생. Provoke 같은 비피해 기술도 포함 |
| 추가116스킬 | 기존 K0AdvancedEffect의185타격 펄스와 연결. 준비 pulse0 제외, 원소/무기·연타별 분류 |
| 확정 적중 | K0HitEffect의 실제 피해가 발생한 위치에서 스킬에 맞는 국소 입자. 새 명중 판정/피해 생성 없음 |
| Selene | 실제 지원 확인 시 Heal/Protect/Cleanse에 금빛 치유/보호·서늘한 정화 효과 |
| 몬스터 | 기존51종 구성에 공통인 서버 K0EnemyAttackClock/Active를 사용한 공격 방출. 새 적 공격 정의/판정 생성 없음 |
| 플레이어 피격 | K0HurtAt/K0HurtDamage의 확정 체력 손실에 작은 적대색 섬광. 중복 타임스탬프 억제 |

[128개 개별 매핑](coverage.json) · [20종 렌더](runtime-textures.png) · [자산 원천과ID](../../../assets/effects/pixelfx-v1/source-manifest.json)

`PixelFXCatalog`가 기존 SkillPresentation/K0Config로부터 매핑을 만든다. `PixelFX`가 셀 재생/수명/상한/가림을 관리하며 `PixelFXController`가 복제된 기본/공통 행동만 관찰한다. 기존 AdvancedSkillVisual/K0HitEffects/K0EnemyVisual/SelenePresentation의 실제 연출 경로에 연결했다. 진행 중인 사용자 K0SwordVisual/도끼 동작·회피·로비·원정 변경은 편집/커밋에 포함하지 않는다.

## 자산과 성능 계약

공식 PixelFX 고정 커밋 `a84159688af3ca37a4be05a0d422b94451b2e24e`에서20PNG를 생성했고 Studio MCP upload_image가 모두 실제 자산ID를 반환했다. 전체320셀의 투명 여백/해시를 검사했다. Node v26.4.0, 임시 venv Pillow13.0.0을 사용했다. 신규 전역 패키지 설치나 기존 자산 덮어쓰기는 없다.

BillboardGui는 AlwaysOnTop=false, ImageLabel은 Pixelated로 재생한다. 사용 API의 근거는 [Roblox BillboardGui](https://create.roblox.com/docs/reference/engine/classes/BillboardGui)와 [ImageLabel](https://create.roblox.com/docs/reference/engine/classes/ImageLabel) 공식 문서(2026-11-04 확인)다. 효과는 부가 정보로만 사용하며 바닥 고리·검 궤적·TD 무기/영웅 외형과 위험 예고는 기존3D를 보존한다.

공유 동시 상한24개, 거리80stud·최대6stud·최대1.6초, 필요할 때만 RenderStepped 연결을 유지한다. 사망/회피/블록/스턴·행동 시퀀스 교체/스트림 아웃·만료를 정리하고, 과거 기본/공통 타격과0.5초 넘게 늦은 추가 펄스·중복 펄스를 재생하지 않는다. 텍스처20개 원시 RGBA 합계20MiB(밉/엔진 오버헤드 제외)의 계산치이며 기기 메모리 측정이나 성능 PASS가 아니다. 전체 클라이언트 비동기 사전 로드 실패 시에도 전투 입력과 기존3D가 계속 동작한다.

## 검증 기록

| 검증 | 결과 | 증거/범위 |
| --- | --- | --- |
| `lua tests/pixelfx.spec.lua` |634 PASS | 실제 카탈로그/재생기/컨트롤러를 API double로 실행.128스킬/4기본·185추가펄스·지원/적대 효과·셀 재생·중복/지연/상한/취소. 엔진 렌더 아님 |
| `lua tests/skill-effects.spec.lua` |11,978 PASS | 기존116개 추가 기술3D 효과/전체 펄스·건너 취소 + PixelFX 전달 횟수 검증 |
| `luau-compile --null` |PASS | 신규/변경 모듈과 준비된 네이티브 fixture 구문 컴파일 |
| PNG/매니페스트 검사 |PASS |20 RGBA512×512/320셀4px여백·SHA256·실제 업로드ID 일치 |
| 이미지 검토 |PASS(시안) | 게임용20종 보드를 직접 열어 색/형태 확인. 실제 Roblox 캡처 아님 |
| Studio 동기화·네이티브 fixture |Blocked | 아래 Network capability 오류. 네이티브/Play·실제 텍스처 로드는 미실행 |

`cpu.log`, `compile.log`에 결과를 보존한다. `tests/pixelfx-native.luau`는 실제 인스턴스128기술·4기본/20프로필·물리 비개입/가림/취소/상한을 검사하도록 준비했으나 실행 성공으로 기록하지 않는다.

Studio를 실행하고 기존 `builds/0.69.6/TheLastThrone-Battle-0.69.6.rbxlx`를 열었다(PlaceId/GameId0, role Battle). 읽기와20개 이미지 업로드는 성공했으나 새 ModuleScript를 Shared에 배치하거나 기존 K0Config를 require하려면 MCP thread의 Network capability가 필요했다.

```text
The current thread cannot reparent 'PixelFXAssets' to 'ReplicatedStorage.Shared'
since 'ReplicatedStorage.Shared' has an additional value for the Capabilities property: Network
The current thread cannot require 'K0Config' since 'K0Config' has an additional
value for the Capabilities property: Network
```

Studio [`rbx-permissions` 지침 발췌](rbx-permissions/SKILL.md)는 이 상황에 대해 “only `Network` can be granted, under *Connect to the internet*”라고 안내한다. 사용자에게 Assistant Settings → MCP Permissions → Connect to the internet → Network 활성화를 요청했다. 권한을 우회하기 위해 Play/다른 컨텍스트로 실행하지 않는다. 권한 확인 이후 격리 Place를 다시 열어 재시도한다.

## 남은 수용과 인계

QA/DES: Network 권한 후 네이티브 fixture →20자산 실제 로드/320프레임·각 클래스 일반 조작/명중/빗나감·모든 기술128개/연타·Selene 지원·51종 적 공격을 확인한다. 이후 게시 테스트 Experience의 텍스처 이용 권한/모바일 가로/저사양·카메라 회전·밝은/어두운 지역·4인+AI 동시 효과/발열·위험 가림·스트림 아웃/재접속을 검증한다. 사용자 최종 미술 수용은 별도다.

이 작업은 게임 Place 게시/릴리스가 아니며 상위 티켓을 Done으로 바꾸지 않는다.

## 고정 빌드와 마감

소스 `6b8cb3ec1643e0649c38c8927e5ef9e7dfa1534d`를 커밋·푸시하고 같은 소스에서0.70.0 Lobby/Battle Rojo 빌드가 모두 성공했다. [build.json](build.json)에 버전/소스/명령/경로/바이트/해시를 보존한다. [pinned-checks.log](pinned-checks.log)는 고정 소스의 CPU12,612검사, 빌드SHA256 및 각 Place의 신규4모듈/자산ID20개 포함 검사를 기록한다. 원격 main과 소스 커밋 일치·LFS21/21(효과20+시안1,1.7MB) 전송 성공을 확인했다. 이후 증거 커밋은 빌드 입력 소스와 구분한다.

자체 Studio 검토 Place는 Don't Save로 닫았고 시작 화면으로 돌아갔다. 임시 변경/자동 복구 파일을 실제 게임 빌드에 저장하지 않았다. 새0.70.0 파일도 Studio 실행 검증/게임 게시/릴리스 태그로 보고하지 않는다. Network 권한 응답과 실제 렌더 검증은 남아 있다.
