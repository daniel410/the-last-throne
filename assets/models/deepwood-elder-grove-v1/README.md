# Deepwood Elder Grove v1

TLT-061/elder-grove · 2026-11-12 · Blender MCP 직접 조형 → 실제 메시 수입·DW-03 게임 연결

[DW-03 콘셉트](../../concepts/2026-11-12-deepwood-epic-stories-v1/DW-03.png)의 거목·뿌리·보급 천막·광장·돌길·아치·식생·수레/통/상자를 한 구도로 제작했다. 기존 Blender 씬과 TD 원본은 보존했다. 타 게임 자산이나 외부 생성기를 사용하지 않은 **New** 자산이다. 일반 TD 수목은 주변에서 계속 재사용한다.

## 원본과 게임 템플릿

| 파일 | 용도 |
| --- | --- |
| `elder-grove.glb` | 실제34메시/53810삼각형, UV/노멀·내장 텍스처. 최대 메시7014삼각형 |
| `grove-atlas.png` | 직접 절차적으로 채색한1024×1024 색 텍스처1장. 숙련 아티스트의 수작업 마감과 동일하다는 뜻은 아님 |
| `geometry.json` | 컴포넌트/바운드/뿌리 중심선·배치 기준점 |
| `runtime.rbxmx` | 수입 후 방향·색·양면·고정·충돌을 교정한 실제 MeshPart34개. 게임이 이 정규화된 템플릿을 복제함 |
| `asset-manifest.json` | 원본 Model·자동 생성된34Mesh/1Image ID·소유자·교정·패키지 추적 |
| `grove-preview.png`, `camp-detail.png`, `grove-side.png` | Blender 전체/근접/측면 렌더. 실제 Studio 화면은 증거 폴더에서 구분 |
| `validation.json` | 로컬 GLB 구조/기하/UV/내장 이미지/해시 검사. 엔진 수용은 별도 |

업로드1회: Model **110278314469184**, 공통 이미지 **130333344924030**. 소유 계정9156786071, RPG Universe10773575153 문맥에서 업로드/승인했다. 모델·메시 자산 업로드와 Experience 게시를 구분하며, 이 작업으로 게임을 게시하거나 Creator Store 상품을 만들지 않았다.

원본 업로드 자산은 수입 시180도 회전·회색 곱색·단면이 남은 상태다. 게임은 이 원본 패키지를 다시 삽입하거나 자동 갱신하지 않고 **연결을 끊은 로컬 `runtime.rbxmx`**를 사용한다. 원본을 다시 수입하면 `normalize-deepwood-elder-grove.py`의 표식 교정이 필요하다. 원본 Model을 추가 업로드하거나 교정판으로 게시하지 않았다.

## 제작·검수 도구

- `tools/build-deepwood-elder-grove-blender.py`: Blender MCP에서 새 씬을 직접 만든다. Standard/sRGB/None/Exposure0/Gamma1/Curves Off. 활성 씬만 GLB로 내보내며 기존 씬을 저장소에 함께 저장하지 않는다. GLB·기하 JSON·코드가 편집/재현 원천이다.
- `tools/validate-deepwood-elder-grove.py`: 실제 GLB34메시·UV·내장 이미지1·외부 URI0·퇴화 삼각형0 검사.
- `tools/normalize-deepwood-elder-grove.py`: 수입 원본을 표식으로 교정하는 로컬 Studio Luau 생성. Trunk/Gateway와 다른 컴포넌트 중심을 비교하고34MeshPart의 색/양면/고정·16개 충돌 메시를 정규화한다. 의도한 제작 단위는1unit=1stud다.
- `tools/export-deepwood-elder-grove.py`: 연결된 바위28개와 작은 나무7개의 단순 몸체 데이터를 추출해 `DeepwoodElderGroveGeometry.luau` 생성.

원점은 Roblox(-280,18.08,-1728)이다. `DeepwoodElderGrove`가 기존 NPC/목표 좌표를 유지하면서 배치하고, 개별 컴포넌트를 스트리밍 단위로 나눈다. 미리보기의 원형 `GroveGround`는 실제 맵에서 숨기고 기존 지면을 사용한다. 큰 몸체는 실제 메시 충돌, 작은 나무와 바위는 보이는 형상 안의 단순 몸체로 근사한다. 넓은 평지·수목 반복·콘셉트의 전체 지형/회화 마감과의 차이는 남는다.

[고정 빌드·실제 Studio 화면·엔진 결과·미검증 범위](../../../docs/evidence/deepwood-elder-grove-20261112/README.md)를 따른다. 게시 클라이언트·실기기/협동 성능·최종 사용자 미술 수용은 별도다.
