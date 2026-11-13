# Deepwood Elder Grove v1 — 로컬 후보

TLT-061/elder-grove · 2026-11-12 · **Blender 제작 완료, Roblox 수입·게임 연결 미완료**

[DW-03 콘셉트](../../concepts/2026-11-12-deepwood-epic-stories-v1/DW-03.png)를 기준으로 Blender MCP에서 새 `TLT_Deepwood_ElderGrove_v1` 씬을 직접 조형했다. 기존 Blender 씬과 TD 원본은 보존했다.

## 구성

- 거목 줄기/가지, 분리된 뿌리10개, 넓은 수관4묶음, 파란 천막과 목재 데크, 왕관 문양 깃발.
- 입구 석조 아치, 곡선 돌길과 광장, 보급 상자/통/수레/지도 테이블/등불.
- 작은 나무·관목·양치식물·꽃·지면 마감. 실제 게임의 인물·상호작용은 포함하지 않는다.
- **34메시·53810삼각형, 가장 큰 메시7014삼각형, 공통1024×1024 텍스처1장.** UV/노멀을 포함하고 GLB에 이미지를 내장했다. 나뭇잎은 불투명 기하다. 실기기 성능은 미검증이다.

## 파일과 제작

| 파일 | 용도 |
| --- | --- |
| `elder-grove.glb` | 편집·수입 가능한 실제 메시/UV/내장 텍스처 패키지. 기본형 재구성 데이터가 아님 |
| `grove-atlas.png` | 이 제작 코드에서 직접 절차적으로 채색한 색 텍스처. 외부 텍스처/AI 이미지 다운로드 없음 |
| `geometry.json` | 컴포넌트/바운드/기하 수·뿌리 중심선·게임 배치 기준점 |
| `grove-preview.png` | Blender 전체 조감도 렌더 |
| `camp-detail.png`, `grove-side.png` | Blender 근접/측면 비교 렌더 |
| `validation.json` | 실제 GLB의 기하·UV·내장 이미지·퇴화 삼각형·해시 검사 |

제작 원천은 `tools/build-deepwood-elder-grove-blender.py`다. **Blender MCP에서 실행**하며 새 씬을 생성한다. 같은 이름의 씬을 덮어쓰지 않으므로 반복 실행 시 명시적으로 구분한다. 최종 활성 씬만 GLB로 내보낸다. `.blend` 전체 저장으로 다른 작업의 씬을 저장소에 포함하지 않았다. GLB·JSON·제작 코드가 이 후보의 편집/재현 원천이다.

Blender 색상은 Standard/sRGB/Look None/Exposure0/Gamma1/Curves Off다. 재질은 공통 glTF PBR baseColorTexture와 Roughness0.88을 사용한다. 손으로 그린 미술 느낌을 향한 절차적 채색 후보이며, 숙련 아티스트의 수작업 텍스처 마감과 같다고 주장하지 않는다.

자산 분류는 **New**다. 승인 TD 거목은 기존 게임에서 재사용 중이지만, 이번 후보의 휘어진 줄기·뿌리 팬·천막과 연결된 구도를 만들기 위해 새 메시를 제작했다. 기존 TD 맵/일반 수목 전체를 이 후보로 교체한 것이 아니다. 타 게임 모델/텍스처/문양을 추출하지 않았다.

## 수입·검수 준비

`python3 tools/validate-deepwood-elder-grove.py`로 로컬 패키지를 검사한다. `python3 tools/prepare-deepwood-elder-grove-review.py`는 수입된 `ServerStorage.DeepwoodElderGroveImport`를 원래 좌표/크기로 정규화해 검수하는 Luau를 `/tmp`에 생성한다. 실제 수입34메시와 텍스처를 요구하며 기본형 대체는 없다. 단위/방향·스크립트 부재를 검사한 뒤 새 후보만 생성한다. **생성 코드의 컴파일만 확인했으며, 실제 수입/실행은 하지 못했다.**

기준점은 Roblox `(-280,18.08,-1728)`이다. Blender `(x,y,z)`를 Roblox `(x,z,-y)`로 옮긴다. 기존 DW-03 에린/셀레네/지도·준비·출발 목표는 이동하지 않는다. 기존 월드의 나무/옛 대표 건축 중복 제거·도로 그림 정리·작은 수목 충돌·장식/상호작용 중복·조명·게임 소스 연결은 실제 수입 후 엔진 검수 단계에서 처리해야 한다. 검수 후보를 그대로 최종 게임에 저장하면 안 된다.

수입 시도는 `asset:read` 권한 미부여로 Roblox Studio MCP 인증 단계에서 거부됐다. 실제 Roblox assetId·MeshId·ColorMap 권한은 아직 없다. [정확한 작업 상태·차단·검증 경계](../../../docs/evidence/deepwood-elder-grove-20261112/README.md)를 따른다.
