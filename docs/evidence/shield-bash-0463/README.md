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

입력 소스 커밋 고정 후 Lobby/Battle 0.46.3 빌드와 source/hash 검증을 진행한다. 아래 기록에 최종 결과를 추가한다. 실제 게시·릴리스 태그는 이 작업에 포함하지 않으며, 실기기/멀티플레이 지연 및 사용자 동작 수용은 후속이다.
