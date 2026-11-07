# Gloamwood Meshy 몬스터8종 · 리그/모션 v1

작업 **TLT-065/032/033/gloamwood-meshy-20261107**. 사용자가 Meshy에서 제작한8종을 받아 기존 임시 블록 모델을 대체한다. [전체 출처/해시/자산ID](manifest.json), [업로드 응답](uploaded.json), [실제 Studio 가져오기](native-import.json), [리그 정의](rig-report.json), [표면/스킨/클립 검사](clip-validation.json), [구현·QA·미검증](../../../docs/evidence/gloamwood-meshy-20261107/README.md).

| 게임 ID | Meshy 원본 이름 | 삼각형 | 본 |
| --- | --- | ---: | ---: |
| Webling | Amethyst Arachnid | 2023 | 18 |
| Silkweaver | Amethyst Bone Spider | 2084 | 18 |
| Barkstalker | Mossfang Arachnid | 1976 | 18 |
| Gloambat | Amethyst Nightfang | 2099 | 6 |
| Venomcoil Centipede | Crimson Centipede | 1982 | 14 |
| Widow Queen | Amethyst Skullspider | 2070 | 18 |
| Ancient Hollowbark | Ancient Forest Golem | 1802 | 10 |
| Venomcoil King | Crimson Crystal Scorpion | 1876 | 14 |

`source/`는 Meshy 다운로드 GLB 원본이다. `rigged/`는 동일 표면에 본과 스킨을 추가한 편집 가능한 GLB8개다. 원본의 위치 배열은 동일하며 UV 최대 수치 오차는2.98e-8이다. 텍스처는 원본의 단일 base-color 이미지를 유지했다. `runtime.rbxm`은 실제 업로드된 스킨 MeshPart·Bone을 복제해 만든 Rojo용 폴더다. 가져오기에서 생긴 회색 Color를 원본 기본 baseColorFactor인 흰색으로 보정했다. 원본 업로드 패키지는 보존하며 런타임 복사본은 PackageLink 없이 사용한다.

거미4종은 각8다리의 상·하단16본, 박쥐는 좌우 날개/끝4본, 엔트는 양팔/다리의 상·하단8본을 Root/Body 아래에 둔다. 지네2종은12개 몸통 구간을 개별 제어한다. 지네의 작은 발은 해당 구간 스킨에 따라 움직이며 독립 발 IK는 없다. 모든 정점의 영향 합은1이고 최대2본이며 Root 정점 가중치는 없다.

종별 Idle/Walk/Attack/AttackAlt/Heavy/HeavyAlt/Stunned/Exposed/Return/Interrupted10슬롯을 GLB에 보존했다. 일부 대체/전환 슬롯은 같은 키 또는 중립 키를 공유하며80개의 서로 다른 전용 동작을 뜻하지 않는다. Open Cloud 가져오기에서는 본만 유지되고 클립은 제외되어 [추출 도구](../../../tools/export-gloamwood-meshy-clips.py)로 실제 GLB 로컬 델타를 게임 ModuleScript로 옮겼다. 지네 데이터는 Studio Source200,000바이트 제한에 맞춰 클립별 하위 모듈로 나눈다.

제작 재현: Blender5.2에서 별도 `TLT_Gloamwood_Meshy_v1` 씬에 source GLB8개를 가져오고, 메시 이름을 위 Meshy 이름의 밑줄 표기(`Amethyst_Arachnid` 등)로 지정한 뒤 [본/스킨/모션 제작 스크립트](../../../tools/author-gloamwood-meshy-blender.py)를 Blender MCP로 실행한다. 선택 개체와 해당 씬만 GLB로 내보낸다. [Studio 런타임 준비 스크립트](../../../tools/prepare-gloamwood-meshy-runtime.luau)는 승인된 가져오기 뒤 원본/리그 수·텍스처를 검사하고 별도 로컬 복사본을 만든다. 내보내기/업로드는 원본 메시나 기존 사용자 Blender 씬을 덮어쓰지 않는다.

새 Model8건을 계정9156786071에 업로드했고 승인 응답을 확인했다. 기록된 파생 Mesh8개와 색 텍스처8개의 로드를 검사했다. 별도 Animation 자산은 업로드하지 않았다. 플랫폼 내부 추가 파생 자산의 전체 수는 미집계다. Roblox Place는 게시하지 않았다.
