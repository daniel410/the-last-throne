# Selene TD 성녀 복원·새 NPC 로컬 적용 0.43.1

2026-10-31 · TLT-016/057/061/072/084 · ENG/ART → QA

사용자 최신 지시로 Selene는 생성형 native 원형 대신 기존 TD 성녀 `nun`의 원본Body/ArmR/ArmL 메시·텍스처·색상을 사용한다. 로비, Deepwood 대화, 야영지, 동행,30종 라이브러리/쇼케이스의 모든 생성 경로를 `SeleneVisual`로 통일했다. 이동/상호작용 계약에 맞는 투명ActorRoot와 영문이름표만 별도로 추가하고 균등 축척6.5studs/방향을 적용한다. 원본파일은 변경하지 않는다.

새 NPC29종과 TD Selene를 로비/Deepwood 실제 런타임·로비/전투 로컬 빌드에 반영한다. 후반 지역은 모델 라이브러리/앵커 계약으로 남는다. 사용자 선택대로 **로컬 Studio 빌드에만 적용하고 Roblox에는 게시하지 않는다.**

## 검증

- `assets/shared/td-selene/runtime.rbxmx` SHA256 `b72058845b8fe9c14d9532d1519baa415b610c0e7bd3cf2ff2c0ff6cb28e6ef6` 원본manifest 일치.
- `lua tests/selene-recruitment.spec.lua`:23검사 통과. 무료영입·스토리진행/동행상한 계약 보존.
- `run-in-roblox` / 동행 Source probe: **32검사 통과**. 원본3개 메시·텍스처·색상 보존과 기존 동행 회귀를 확인했다. [결과](selene-result.json)·[입력해시](selene-source-manifest.json).
- `run-in-roblox --place /tmp/tlt-npc-cast-v1/tlt-npc-cast-preview.rbxlx --script tests/npc-cast-native.luau`: **4,637검사 통과**.30명·1,632Parts, 로비·대화·야영지·라이브러리 TD모델과15개 Deepwood NPC·기존시설을 확인했다. [결과](cast-result.json)·[입력해시](cast-source-manifest.json).
- 소스 `fffbfe57cf6ca10331da99068a4011235237e47a` 고정 후 `python3 docs/evidence/selene-td-0431/build.py`: [Lobby](../../../builds/0.43.1/TheLastThrone-Lobby-0.43.1.rbxlx) / [Battle](../../../builds/0.43.1/TheLastThrone-Battle-0.43.1.rbxlx) 두 빌드 성공. [명령/해시](build.json).
- 두 실제 빌드에 `run-in-roblox --place <빌드경로> --script tests/npc-bootstrap-native.luau`: **Lobby99 / Battle95검사 통과**. 실제 초기화·라이브러리의TD성녀·로비 성녀MeshPart/대화앵커·Deepwood15개NPC·모듈컴파일을 확인했다. [로비결과](lobby-bootstrap-result.json) / [전투결과](battle-bootstrap-result.json) / [검사해시](bootstrap-test-manifest.json).
- 별도 Studio 창에서 `TheLastThrone-Lobby-0.43.1.rbxlx`가 열림을 Studio 연결 목록으로 확인했다. 기존 열린 운영 Place와 오래된 빌드 창은 변경하지 않았다. Roblox 게시·릴리스 태그는 수행하지 않았다.

기존Dawnspire 생성이미지 속 Selene는 이전컨셉으로 보존하고 갤러리·manifest에 런타임 기준에서 제외됨을 표시했다. 최종보행/시전모션·실기기·게시 계정 저장/다인플레이·후반맵은 미검증이다. 다음QA는 실제 기기/플레이 입력과 미술을 수용한다.

## 실제 로컬 플레이 배치 보정 0.43.2

0.43.1을 별도Studio에서 Play해 실제Player1명·로비6명·성녀nun/3MeshPart를 확인했다. 근접 화면에서 큰TD원형과 대장간 기둥의 시각 겹침을 발견해 성녀 위치를 로비offset(29,0,16)에서(25,0,20)으로 옮겼다. 네 기둥과 성녀 외형bounds 비겹침 검사를 추가하고0.43.2를 별도예약했다.0.43.1산출물은 덮어쓰지 않는다.
