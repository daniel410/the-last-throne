# Deepwood K0 전투 공터 · 디자인 작업 기록

기록일: 2026-10-28 · 담당: 디자인 · 연결 작업: TLT-031, TLT-005/007의 월드 입력

아래 단독 엔진 시험에 사용한 `TrainingField.luau`의 SHA-256: `76f04a18427e889f4a98bf5098dedff84c17d897896fb10c3d9ee0a5a1768ed6`.

이 작업은 **독립 전투 실험장 블록아웃**이다. DW-01~02 전체 스토리 맵이나 TLT-031의 수용 완료를 뜻하지 않는다. 정식 게임 빌드·게시·릴리스는 이 작업에서 수행하지 않았다.

## 원천과 범위

- [Deepwood 맵 명세](../../deepwood-map-design.md)와 [좌표 초안](../../../assets/maps/deepwood-v1/layout.json)의 숲길·안전 시작·18~24 studs 주 통로, [기사 K0 명세](../../knight-combat-spec.md)의 평탄한 96×96 공터와 Goblin/Ogre 대응을 사용했다. 전체 지역 좌표를 그대로 지은 것이 아니라 원점 근처의 독립 실험장으로 재배치했다.
- [스토리 01](../../story-01-goblin-trail.md)과 승인 컨셉의 [숲길](../../../assets/concepts/2026-10-27-shared-ui-v2/world/story-01-goblin-trail.png), [Deepwood](../../../assets/concepts/2026-10-27-shared-ui-v2/world/epic-01-deepwood.png), [기사](../../../assets/concepts/2026-10-27-shared-ui-v2/heroes/hero-knight.png), [고블린](../../../assets/concepts/2026-10-27-shared-ui-v2/monsters/goblin.png)을 직접 확인했다. 밝은 녹색 숲·석재 길·대비되는 적 실루엣을 임시 기본 도형으로 표현했다. 그림 속 글자와 수치는 사용하지 않았다.
- 적 모델, 나무, 지형은 **직접 만든 K0 임시 도형**이다. 검증된 Throne Defense 모델이나 최종 RPG 리그·애니메이션이 아니다. 3D 담당이 조사한 TD `assets/models/maps-quality-v2/forest-kit-v3/runtime.rbxmx` 후보는 외부 메시 ID 사용 권한·해당 Experience 로딩·충돌·기기 성능이 미검증이므로 가져오지 않았다.

## 구현과 인계

| 항목 | 초기 구성 및 의미 |
| --- | --- |
| 모듈 | `src/server/World/TrainingField.luau`의 `create()`는 Workspace `DeepwoodK0` Model, 직계 `Enemies` Folder, `Spawn` SpawnLocation을 생성하고 `{folder, enemies, spawn}`을 반환한다. 재호출은 같은 인스턴스를 반환한다. |
| 유효 바닥 | 윗면 Y=0의 160×160 평면. X=-48~48, Z=-74~22의 96×96 범위는 충돌 가능한 장식을 비워 K0 회피를 시험한다. 외곽은 투명 충돌벽으로 닫고 나무 수관은 충돌/쿼리 대상에서 뺐다. |
| 시작과 통로 | Spawn 중심 X=-20, Z=56. 엄폐벽은 X=-36~-2, Z=38.5~41.5, 높이 6이며 우측 벽 사이 통로의 기하학적 폭은 22 studs다. 두 적의 초기 위치에서 시작점으로 직선 시야를 차단한다. `Duration=0`이라 생성 무적을 제공하지 않는다. |
| 적 | `Goblin`은 X=-18, Z=-10, 배율 0.85; `Ogre`는 X=20, Z=-30, 배율 1.45. 각 모델은 `EnemyKind` 속성, `Humanoid`, `HumanoidRootPart`, R6 이름의 바디와 `Motor6D`를 가지며 물리 이동과 피해를 받을 수 있는 임시 조립체다. 보존 복제·전투 수치·사망 후 재생성·AI는 전투 서비스 담당이다. |
| 베이스플레이트 | 기본 프로젝트의 동명 Baseplate는 가시성·충돌·터치·쿼리를 끄고 별도 지면 하나를 사용한다. 표지 문구는 영어 임시 현장 안내다. |

후속 가독성 작업으로 고블린 오른팔에 짧은 칼, 오우거 오른팔에 곤봉을 기본 Part와 WeldConstraint로 붙였다. 모두 무게가 없는 임시 시각 소품이며 충돌·터치·쿼리는 꺼져 있다. 실제 TD 무기나 완성된 모델·애니메이션이 아니며 공격 판정은 담당하지 않는다. Python 일회성 소스 검사에서 네 소품의 오른팔 연결, 충돌·터치·쿼리 비활성, 무게 제거, WeldConstraint와 기존 en-US 키 사용을 확인했다. `rojo sourcemap default.project.json`에서도 모듈 인식이 유지됐다. 아래 단독 엔진 시험은 이 소품과 영어 키 연결을 추가하기 전 해시의 결과다. 소품의 카메라 가독성과 모션 연동은 통합 플레이에서 확인해야 한다.

전투 담당이 전한 설계는 각 적의 원래 위치에서 대상이 36 studs를 벗어나면 추적을 중단하고 귀환하는 것이다. 시작점은 각각 약 66·95 studs 거리여서 **초기 위치와 해당 설정을 가정하면** 추적 대상 밖이다. 벽은 초기 직선 시야를 막을 뿐, 독립적인 무적 구역이나 모든 가능한 원거리 공격 차단을 보장하지 않는다. 추적 관성·공격 범위·리스폰을 합동 플레이에서 다시 확인해야 한다.

## 실제 검증

| 조건과 명령 | 관찰 결과 | 증거의 한계 |
| --- | --- | --- |
| `rojo sourcemap default.project.json` | `Server.World.TrainingField`가 ModuleScript로 인식됨 | 빌드·구문 실행·게임 플레이의 증거가 아니다. |
| 빈 임시 Place와 `/private/tmp/tlt-k0-world-check.luau`: `run-in-roblox --place /private/tmp/td-hero-status-empty.rbxlx --script /private/tmp/tlt-k0-world-check.luau` | 두 번 호출 시 같은 객체 반환, 적 종류/바디/체력, 두 적의 100→75→0 피해, 시작점에서 두 적을 향한 광선의 `SpawnCover` 차단, 이동 경로 두 구간 광선 통과를 확인했다. 적과 지면을 제외한 높이 0~4의 96×96 범위 쿼리도 충돌 후보 0개였다. | 빈 Place의 단독 서버 모듈 시험이다. 완성한 플레이어 캐릭터·클라이언트·전투 서비스·기기 검증은 아니다. 임시 스크립트는 저장소 산출물이 아니다. |
| 빈 임시 Place와 `/private/tmp/tlt-k0-world-physics.luau`: `run-in-roblox --place /private/tmp/td-hero-status-empty.rbxlx --script /private/tmp/tlt-k0-world-physics.luau` | `RunService:Run()` 뒤 정지 2초에 Goblin 루트 Y=2.55, Ogre 루트 Y=4.35, 양쪽 발바닥 Y≈0. 각 `Humanoid:MoveTo()`에 +X 8 studs를 지시한 2초 뒤 X=-10.83/27.21로 이동했고 발바닥 Y≈0을 유지했다. | 두 단순 리그의 단방향 이동 실험이다. 내비게이션 장애물, 실제 적 행동, 플레이어·전투 충돌, 낙하·리스폰 등은 검증하지 않았다. |

두 Studio 실행에서 `ContentId: rbxassetid://203785492 failed due to: Asset type does not match requested type` 로그가 출력됐다. 발생원과 화면 영향은 아직 확인하지 못했다. 처음 `run-in-roblox --script …`만 실행했을 때는 도구가 빈 Place 생성을 지원하지 않아 실패했고, 위 명령처럼 별도의 빈 Place를 명시해 검사를 완료했다.

## 남은 검증과 다음 담당

- 엔지니어: 실제 시작 스크립트·서버 전투 서비스에 연결하고 타격 시야, 추적 제한, 적 사망 후 복제/원위치, 플레이어 재생성과 안전 시작을 검증한다.
- QA·디자인: 실제 플레이 빌드에서 기사와 적의 전투·벽 통과 차단·회피 거리·카메라·영어 표지, PC/터치·패드, 실기기 성능과 사용자 관찰을 확인한다. 한 장면에서 두 적이 동시에 접근할 때 난이도와 예고 가독성도 측정한다.
- 3D 모델링: 공유 원본의 해시·권한·Experience 로딩과 실제 RPG 리그/충돌/모션 적합성을 검증하고 교체 여부를 결정한다. 현재 블록아웃은 최종 자산이 아니다.
- 통합 담당: 발견된 자산 ID 로그의 원인·영향을 조사하고, 버전·소스 커밋을 고정한 게임 빌드에서 별도의 증거를 남긴다.
