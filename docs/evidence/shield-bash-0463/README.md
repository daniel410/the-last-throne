# Shield Bash 방패 선행 수정 · 0.46.3

작업ID TLT-005/032, 2026-10-31. 사용자 관찰: Shield Bash 사용 중 방패가 검 뒤에 남는다. 원인이 명확한 좌표축/자세 결함이므로 제작 스킬의 결함 수정 예외에 따라 별도 외부 조사는 추가하지 않았다.

기존 동작의 실제 TD 메시 순방향 경계는 R6 방패가 검보다 2.6185stud 뒤, R15 1.6630stud 뒤였다. 레거시 방패 팔이 어깨 C0 기저 변환을 거치지 않고 검 팔과 검 로컬 회전도 전방으로 뻗은 것이 원인이다. 방패를 전방으로 내밀고 검은 몸 쪽으로 거두며, 왼팔·상체를 기존 native 기저 변환 경로로 보낸다. 범위는 정확히 `knight.common.bash` 하나다. 다른 계열 기술의 동작/서버 판정/5초 스턴/무기 원본/소켓은 변경하지 않는다.

## 제작 증거

- `assets/animations/shield-bash-v1/shield-bash.blend`: Blender MCP 내부 bpy로 실제 armature action `Knight_ShieldBash_Leading` 작성, 120fps 85샘플·9채널. 별도 Python 생성 프로그램을 실행하지 않았다.
- `01-author.mcp.json` / `01-author-result.json`: MCP 입력과 반환 샘플, `prepare-authoring.mjs`는 Node 요청 생성, `export-runtime.mjs`는 반환값→Luau 변환만 수행한다.
- `blender-review.png`: 프레임 0/8/24/36/55/84. Blender 검은 기존 TD 리뷰용 메시이며 런타임의 최신 Azure Oathblade는 아래 native 실제 장착으로 검증한다. Blender 그림을 최신 검 메시 검증으로 간주하지 않는다.
- `K0ShieldBashMotion`: 서버 시작 시각과 windup/active/recovery를 기준으로 보간한다. 방패 접촉 구간은 몸의 전방, 검은 회수 자세로 유지하고 이후 원래 자세로 복귀한다.

## 검증

- `probe.luau` / `probe.log`: 수정 전 수치 및 후보 FK 비교.
- `run-in-roblox --place /private/tmp/tlt-shield-0463-qa.rbxlx --script tests/shield-bash-leading-native.luau`: 미게시 Rojo QA fixture, **86검사 통과**. 실제 R6/R15 TD 방패/최신 검, 타격 직전 .195초와 Active .20/.25/.299초, 30/144Hz를 확인했다. 방패 선행 최소 R6 **0.7471stud**, R15 **1.4161stud**; 앞면 방향 dot 최소 **0.9178**. 루트 불변·검 소켓 유지·Idle 복귀·5초 스턴과 .2초 준비 시간 보존 확인.
- `tests/k0-melee-curves-native.luau` + 위 테스트: **3,290검사 통과** (3,204+86), `melee-native.log`. 기본 기사 검/드워프 도끼 곡선 회귀 포함.
- 첫 contact 테스트는 검 sourceKey를 잘못 예상한 fixture assertion으로 중단했다. 실제 AzureOathblade 키로 수정하고 통과했다(`leading-native-first.log` 보존).
- 오래된 `k0-skill-animation-native` 전체 실행은 Knight 포함 45검사 후 Elf Bow의 기존 String.Size.Z 기준에서 실패했다. 현재 활 시위 리그와 맞지 않는 과거 assertion이며 변경하지 않았다. `motion-native.log` 실패를 보존하고 현재 변경에 직접 맞는 위 native 검사로 검증했다. 해당 전체 스킬 검사를 성공으로 보고하지 않는다.

## 빌드 및 남은 수용

입력 소스 커밋 **c879d0d5f293dd36c63046e738a2a7121bdac5cf** 고정 후 Lobby/Battle **0.46.3** 빌드 성공. 두 산출물의 핵심 모듈21개·검증 입력2개가 고정 커밋과 일치한다(`source-verification.json`). 서버 Combat/Config/AdvancedSkills, 보상 정본과 원본 몬스터·무기 메시는 이전 커밋과 같다. 고정 Battle에서 **3,290 native 검사 통과**, `final-native.log`.

| 산출물 | SHA-256 |
| --- | --- |
| Lobby | b126388baeb6c3e727c6909bffa821dc97da846166ebd46c8c817a0be013842b |
| Battle | 1f91bee91681198ed601f174814385a83dbe26e8b3a37209dd80d79250125181 |

## 정상 Client 확인

고정 Lobby 0.46.3 파일을 별도 CLI QA Studio로 열고 Studio MCP Play를 시작했다(PlaceId0). 정상 CreateHero(knight) → StartTraining → Humanoid.MoveTo 동쪽 우회로 → 선택한 Goblin을 대상으로 Skill1 요청했다. 루트/HP/스킬 시각/서버 판정은 덮어쓰지 않았다. `client-observe.luau` / `client-observation.json`에160개 Heartbeat 관찰을 보존한다.

- 실제 R15 플레이어, 최신 AzureOathblade/기존 TD 방패 확인.
- 실제 Active .2403/.2542/.2708/.2880초에서 방패가 검 전체 경계보다 최소 **1.6572stud** 앞, 방패 앞면 dot **0.9178**.
- 정상 피해 Goblin HP **300→220**, 실제 서버 스턴 기간 **4.99993초** 확인.
- `client-contact-pose.jpg`: 정상 accepted cast의 **.2403초 자세를 Client 전용 복제 스틸로 기록**했다. 짧은 Active 장면을 검토하기 위한 정지 화면이며, 실시간 발동 장면/실기기 수용으로 주장하지 않는다. 촬영 동안 UI를 숨기고 카메라만 바꿨으며 이후 UI/카메라 복원·복제 스틸 제거 완료. 배경은 로비 복귀 후 스트리밍이 해제된 위치의 하늘이므로 맵 시각 수용 증거가 아니다.
- 검증 후 동일 Studio에서 다른 로컬 QA가 진행 중인 것이 확인되어 플레이 상태와 창을 보존했다. 소유한 CLI 대기 프로세스만 종료했으며 파일/Studio 플레이는 종료하지 않았다.

다음 담당은 QA/사용자이며 실기기·멀티플레이 지연·사용자 동작 수용은 후속이다. 실제 게시·릴리스 태그는 생성하지 않았다.
