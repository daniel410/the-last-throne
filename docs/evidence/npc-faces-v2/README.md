# NPC 얼굴·헤어 개선 v2

2026-11-01 · TLT-031/057/061/084 · ART/ENG → QA · 로컬 시험판

Selene를 제외한29명의 돌출된 눈·코·입·볼을 제거하고 컨셉6보드를 참고한 투명 표정 아틀라스를 연결했다. 둥근 머리와 귀·쓸어 넘긴 헤어·땋은 머리·수염·고글을 Blender MCP에서 제작하고 같은 형상 레시피를 Luau로 내보냈다. 블록 몸체·복장·소품·대화/거래·호위·Selene TD 원본은 유지한다.

- [Blender 편집 원본](../../../assets/npcs/faces-v2/npc-heads-v2.blend): `TLT_NPC_Faces_v2` 장면. 작업 전에 열려 있던 애니메이션 장면도 보존한 사본이다. 이전 애니메이션 파일을 덮어쓰지 않았다. 몸체는 얼굴 검토용 단순 셸이며 실제 게임은 기존 복장을 사용한다.
- [얼굴 아틀라스](../../../assets/npcs/faces-v2/face-atlas.png):1145×1374 RGBA,229×229 셀5열6행,29명+빈셀1. 이미지 생성 도구 제작, 기존 컨셉을 참조한 신규 파생 이미지다. 텍스처 `rbxassetid://119430151832611` 업로드 성공.
- [형상 레시피](../../../assets/npcs/faces-v2/heads.json), `NPCHeadRecipes`/`NPCHeadVisual`/`NPCVisual`이 런타임 경로다. 서버 템플릿·고정/호위 외형 모두 같은 경로를 사용한다.
- [Blender 정면 검토](blender-lineup.png), [실제 Studio 근접 화면](studio-closeup.png). Blender 렌더와 게임 화면은 별개 증거다.

## 검증

`python3 tools/prepare-npc-preview.py` 후 `run-in-roblox --place /tmp/tlt-npc-cast-v1/tlt-npc-cast-preview.rbxlx --script tests/npc-cast-native.luau`: 최종 **3,780개 검사 통과**,30인물·1,309파트·Deepwood8고정배치. 둥근 머리/돌출 얼굴 제거·블록 팔다리·장식 비충돌·Selene 메시/텍스처 보존·대화/서비스·호위 피벗을 확인했다. 기존 TD 자산203785492 유형 불일치 경고가 남는다. 초기안4,023개 통과 후 헤어 부품을 줄여 최종 검사 수가 감소했다.

연결 Studio의 Edit 모드, Lobby Place70829337938054에 격리 검토 폴더 `TLTNPCFaceReviewV2`를 만들었다.29모델/29표정/29 `ImageLabel.IsLoaded=true`를 확인했다. 게임 게시·실제 Player 검증을 뜻하지 않는다. 검토용 모듈은 ServerStorage의 `TLTNPCFaceReviewModules`에 분리했다.

0.58.6 고정 산출물에서 `tests/npc-bootstrap-native.luau` 실행: Lobby **144개**, Battle **136개** 시작/소스 컴파일 검사 통과. `git diff --check`와 `git lfs fsck` 통과. 소스 커밋 `9edade4` 원격main 일치 및 LFS4/4·88MB 전송 성공 확인. [조사/채택 이유](../../research/2026-11-01-npc-face-decals.md). 빌드0.58.6의 소스 커밋·산출물 해시는 `build.json`에 기록한다. 무관한 로비/이동 및 이전 Blender 미커밋 변경은 포함하지 않는다.

## 남은 수용

평면 데칼은 측면에서 곡면UV 메시와 차이가 있고, 헤어/복장 재질의 세부는 컨셉 원화 수준이 아니다. 신규 이미지는 업로드/로컬 로드까지 확인했으며 게시된 양쪽 Place의 자산 권한·심사 이후 로드·모바일/다인 성능·사용자 최종 미술 수용은 미검증이다. 실제 게시와 릴리스 태그는 실행하지 않는다. 상위 티켓은 In Progress를 유지하며 다음 담당은 ART/QA다.
