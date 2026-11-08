# Standard 색상 기준 Blender 파생본

2026-11-08 · TLT-031/032/033/057/061~065/084

맵·캐릭터 색상 비교에는 이 폴더의 **Standard 파생본**을 사용한다. 기존 원본과 TD 원본, 미커밋 드워프 원본은 그대로 보존했다. `assets/` 이하 폴더는 원본의 프로젝트 상대 경로를 유지한다. 원본→파생본 대응은 [manifest.json](manifest.json), 실제 해시/장면별 설정은 [검증 기록](../../../docs/evidence/standard-color-20261108/blend-files.json)에 있다.

- `map-forest-kit.blend`: 현재 공유 숲 모듈의 TD forest-kit-v3 원본을 읽어 만든 Standard 비교본. TLT44지역 전체 맵이 아니다. TD 파일/게임은 변경하지 않았다.
- `live-character-scenes.blend`: 현재 열린8장면의 Standard 저장 사본. Gloamwood Meshy8종·Venomcoil King v2·기존 리뷰와 드워프 작업 장면을 보존한다.
- `selene.blend`: 현재 TLT Selene-repaired.glb를 그대로 가져온 Standard 비교본.
- `assets/.../*.blend`: 기존17원본 중 TLT16개 파일의 Standard 파생본. 미커밋 dwarf-refinement.blend의 수정 내용은 원본을 보존한 채 별도 사본에 포함된다. 과거 장면/동작 검사용 리그도 들어 있으며 최종 영웅 외형 수용으로 간주하지 않는다.

공통 설정: sRGB / Standard / None / Exposure0 / Gamma1 / Use Curves Off. 메시·UV·재질색을 임의로 진하게 만들지 않는다. 리그/게임 수치·Roblox 업로드/게시는 이 작업의 산출물이 아니다.

[전후 렌더 갤러리](../../../docs/evidence/standard-color-20261108/index.html) · [작업 보고](../../../docs/evidence/standard-color-20261108/README.md)
