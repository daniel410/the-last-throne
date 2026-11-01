# Nia 헤어 연결부 수정

2026-11-01 · TLT-031/057/061/084 · ART/ENG → QA · 로컬 수정·미게시

첨부 화면의 높게 뜬 앞머리와 옆머리/땋기 시작점 사이 빈 공간을 수정했다. Nia만 v4에서 파생해 낮은 앞머리·정수리 연결 셸·옆머리 뿌리를 만들고, 땋은 머리를 얼굴 바깥쪽으로 옮겼다. 머리끈도 실제 끝 위치로 맞췄다. 89→80개 머리 파트. 얼굴·몸체·상호작용·다른 NPC는 유지한다.

원본: `assets/npcs/heads-v4/heads.json` (불변). 파생: `assets/npcs/nia-hair-v5/recipe.json`, `nia-hair-v5.blend`, `manifest.json`. 재생성: `python3 tools/fix-nia-hair.py`. 런타임: `src/shared/NPCHeadAssets/nia.luau`.

검증: Blender MCP 정면/왼쪽 모델 확인, Studio 0.58.28 Play 서버의 Nia FaceRig만 새 데이터로 교체해 실제 .74 스케일 근접3/4 화면에서 연결부 확인(`nia-fixed-connected`). 임시 카메라와 UI 숨김은 검사 후 해제한다. 기존 Blender 장면/작업 파일은 보존했다. 이 Play 적용은 저장된 Place 소스 변경/게시와 구분한다.

빌드·회귀 결과는 build.json/cast-native.log에 추가한다. 게시 클라이언트·실기기·사용자 최종 미술 수용은 미검증이다. 상위 티켓은 진행 중이며 다음 QA가 실제 게시본/실기기를 수용한다. 다른 진행 작업은 이 변경 커밋에서 제외한다.
