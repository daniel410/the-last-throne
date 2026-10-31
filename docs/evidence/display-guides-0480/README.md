# 에픽 공격 범위 / Settings · 0.48.1

- 작업: TLT-028/031/061/084 부분 구현 / ENG·DES·QA 자체 검증. 상위 티켓은 In Progress를 유지한다.
- 변경: Y=0에 고정된 공격 선을 실제 지면에 투영해 트레이닝·Deepwood 에픽과 경사에 표시한다. SETTINGS에 Enemy Attack Ranges / Navigation Trail / Objective Markers를 추가한다. 기본ON, 즉시 반영, 같은 접속의 리스폰·메뉴 재생성에 유지, 재접속 시 초기화다. 기존 지도 내비 토글과 연동한다. [조사/적용 판단](../../research/2026-10-31-display-guides-settings.md).
- 입구: 로비 상단 SETTINGS, 전투 미니맵 메뉴의 SETTINGS. 모달을 열면 이동·전투 입력과 근접 상호작용을 막고 다른 메뉴/리스폰/이동 상태에서는 닫는다. 별도 새 단축키는 추가하지 않는다.
- 표시 계약: 서버의 공격 원점·방향·거리·각도·Windup/Active를 그대로 읽는다. 일반 노란 선/방어 불가 붉은 선·경고 문구를 유지한다. 보스 보라색 CorruptionWarning도 로컬 표시만 변경한다. 피해·회복·보상·AI·DataStore·TD는 변경하지 않는다.
- 비용: 가까운180studs 이내의 공격 적만 선을 생성하고30Hz 갱신한다. 멀어지거나 스트리밍 제거 시 정리하고 늦게 들어온 리그/바닥에도 재연결한다. 실제 폰/4인 프레임 비용은 미측정이다.
- 소스 검증: `tests/display-guides-native.luau`를 격리 native fixture에서 실행해 **50개 통과/실패0**. 기본ON·독립 토글·메뉴 재생성/모달 종료·지반18고도·경사·트레이닝0고도·일반/방어불가·보스 경고OFF/ON·스트리밍·거리 정리를 확인했다. 기존 거대 K0EnemyClips의Source 주입 한도 때문에 이번 검사에 필요한 shared/client 모듈만 임시 runner로 주입했으며 게임 빌드 결과와 구분한다. 기존203785492 자산 유형 경고는 유지한다.
- 빌드·실제 화면/최종 회귀 결과는 후속 검증 기록에 덧붙인다. Roblox 게시·릴리스 태그는 요청 범위에 포함하지 않는다.
- 미검증: 실기기·4인·게시 클라이언트·후반 에픽의 미구현 맵·사용자 가독성 수용. 다음 담당 QA/사용자가 실제 Deepwood에서 표시와 메뉴를 확인한다.

실제 화면 검사에서 목표 BillboardGui의 기본 ResetOnSpawn 때문에 첫 모험 진입 시 표식이 삭제되는 기존 결함을 확인했다. ResetOnSpawn=false로 수정해 표식의 수명을 저널/설정과 맞춘0.48.1을 새 버전으로 빌드한다. 앞선0.48.0 빌드 파일은 덮어쓰지 않고 유지한다.

## 최종 빌드·검증 결과

- 최종0.48.1 소스 커밋: `c44d6ea1a74da8eeae60b9a99fa357157f4bf506`. Rojo7.7.1로 Lobby/Battle 빌드 성공. Git archive의 고정 입력만 사용해 다른 작업의 미커밋 변경을 제외했으며 LFS22개를 커밋 OID와 SHA256 대조했다. [최종 명령·산출물 해시](build.json), [앞선0.48.0 결과](build-0.48.0.json).
- 최종 결과물: `builds/0.48.1/TheLastThrone-Lobby-0.48.1.rbxlx` / `TheLastThrone-Battle-0.48.1.rbxlx`. 생성 파일은 Git ignore 정책에 따라 로컬 보존한다.
- 최종 빌드 검사: `run-in-roblox --place builds/0.48.1/TheLastThrone-Lobby-0.48.1.rbxlx --script tests/display-guides-native.luau` → **50개 통과, 실패0**. 앞선0.48.0 고정 빌드에서 같은50개 및 `tests/k0-resource-ui-native.luau` **4,811개 통과**를 확인했다. 0.48.1의 추가 변경은 목표 BillboardGui ResetOnSpawn뿐이므로 기존 대규모 HUD 검사는 반복하지 않았다.
- 내비게이션 회귀: `tests/navigation-always-on-native.luau`를 이번 소스의 격리 runner로 실행해60/10/6/1/0studs·이동 후 직선방향·OFF/ON·목표없음·훈련장·사망 및 지도 토글 동기화 PASS를 확인했다.
- 실제 Studio Client: 비게시0.48.0 Lobby 로컬 세션에서 SETTINGS 상단 버튼을 클릭해 메뉴를 열고 세 토글을 각각 실제 클릭했다. 세 속성 모두false로 바뀌는 것을 확인했고 `display-settings-0480` 화면 캡처로3개 행의 문구/버튼/화면 배치를 직접 확인했다. 0.48.1에서 Settings 화면 소스는 동일하다.
- 실제0.48.1 Client: Knight 생성→Deepwood 진입 후 `DeepwoodWaypoint` 존재와 `ResetOnSpawn=false`를 확인했다. 설정 API로 OFF→ON을 변경하면 marker false→true, 실제 지면 화살표 수0→40으로 바뀌었다. UI 클릭과 설정 API 주입 검증을 구분한다. QA용 무적 ForceField는 임시 Studio 세션에만 적용했고 종료 후 폐기했다.
- 미확인/실행 제한: 전투 미니맵 상단 버튼은 자동 입력 도구의 음수 GUI 좌표/안전영역 차이로 실제 클릭 성공을 확인하지 못했다. 메뉴 항목 생성·표시 및 연결은 코드/네이티브 GUI에서 확인했다. 실제 클라이언트의 경사 공격 전투 장면·터치/패드·작은 실제 기기·4인 성능·게시 권한 수용은 남아 있다. 자동 공격 장면 수집은 초기 퀘스트/스트리밍 상태에서 적이 없어 수용 증거로 채택하지 않았다.
- 테스트 Play/bridge를 종료했다. 기존 사용자 Studio와 TD 작업 파일은 변경하지 않았다. Roblox 게시 및 릴리스 태그는 생성하지 않았다. 다음 담당 QA/사용자는 최종 로컬 빌드의 정상 도보 진입·실제 공격 및 전투 메뉴 입력을 확인한다.
