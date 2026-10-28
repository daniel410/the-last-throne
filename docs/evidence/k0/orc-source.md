# K0 Orc Warrior TD 원본 보존

후속 연결·검증 결과는 [오크 연결 기록](orc-integration.md)에 남긴다. 아래 미검증 내용은 원본 인계 시점의 상태다.

작업 ID: `TLT-002`, `TLT-032`, `TLT-033` 일부 · 2026-10-28 · 담당: 3D 모델링

일반 Orc Warrior는 이미 보존된 TD 런타임의 `MonsterModels/orc`를 사용한다. 이름이 비슷한 보스 `warlord`와는 별도 템플릿이다. 이번에는 TD 원본을 읽기만 하고 원본 GLB 한 개를 동일한 바이트로 복사해 [공유 자산 manifest](../../../assets/shared/td-monsters/manifest.json)에 `orc`를 추가했다. 기존 `runtime.rbxmx`는 수정하지 않았다.

## 원본과 런타임

| 항목 | 확인한 값 |
| --- | --- |
| 원본 GLB | [Meshy_AI_Ironhide_Warlord_20261025_texture_3545c9fe.glb](../../../assets/shared/td-monsters/source/Meshy_AI_Ironhide_Warlord_20261025_texture_3545c9fe.glb), 8,383,884 bytes |
| TD 원본 경로 | `../throne-defense/assets/models/meshy-blocky-monsters-v1/source/Meshy_AI_Ironhide_Warlord_20261025_texture_3545c9fe.glb` |
| 원본과 복사본 SHA-256 | `b612a43d660f11cf24a9b5216462fdf1cf7b98a2e49db625102006cc70fb5ad3`, 일치 |
| 원본 확인 근거 | TD `assets/models/meshy-blocky-monsters-v1/runtime/orc/geometry.json`의 `sourceFile`·`sourceSha256`. 파일명에 Warlord가 들어가지만 정규화 대상 키는 `orc`다. |
| 원본 GLB 구조 | 3,132삼각형·메시 1개·이미지 3개·skin/animation 0개. 원본과 파생본은 구분한다. |
| 런타임 XML | [runtime.rbxmx](../../../assets/shared/td-monsters/runtime.rbxmx), SHA-256 `14e4e9492d280ce887b229cbe6deea5a7a90af2cb643760dc355bcdcb4433ef5` 유지. 기존 Folder `MonsterModels`의 `orc` Model |
| 런타임 표시 | 5 MeshPart, 파생 기하 4,270삼각형, 공통 색맵 `rbxassetid://140427201929012`, `TargetHeight=4.6` |
| Git LFS | `git check-attr filter` 결과 원본 GLB의 filter는 `lfs`. 실제 원격 업로드는 통합 담당 마감 시 확인한다. |

TD HEAD는 기존 [몬스터 보존 기록](td-monster-sources.md)의 조사값과 같으며, TD 프로젝트 파일은 수정 상태이고 해당 모델 폴더는 미추적 상태였다. 따라서 HEAD만이 아니라 위 실제 해시와 경로로 추적한다. 이전 기록의 3종 원본은 당시 보존 범위이고, 현재 공유 폴더에는 오크를 포함한 4종 원본이 있다.

## 부품과 방향

아래 값은 XML의 정규화 좌표이며 표시를 위해 네 자리로 반올림했다. 정확한 크기·위치·회전행렬은 manifest의 `models.orc.parts`가 보존한다. 각 MeshPart는 `MeshAnchor`가 부품명과 같고 XML상 `Anchored=true`, `CanCollide=false`다.

| 부품 | 위치 `(X, Y, Z)` | 크기 `(X, Y, Z)` | Mesh ID |
| --- | --- | --- | --- |
| LegL | `(-0.1822, 0.1100, 0.0127)` | `(0.3644, 0.2200, 0.3708)` | `122434686618387` |
| LegR | `(0.1822, 0.1108, -0.0401)` | `(0.3644, 0.2185, 0.3242)` | `108357424176147` |
| ArmL | `(-0.3713, 0.5671, 0.0222)` | `(0.2227, 0.6541, 0.3837)` | `80036546875989` |
| ArmR | `(0.3905, 0.4860, 0.0984)` | `(0.2609, 0.7138, 0.7221)` | `126087041396792` |
| Body | `(-0.0163, 0.6100, -0.0426)` | `(0.6074, 0.7800, 0.4866)` | `91974284442570` |

원본 정규화 기록의 발 원점은 `(-0.018066510558128357, -0.4738770127296448, -0.07128900662064552)`, 원본 높이는 `0.9453130066394806`이다. TD 어댑터 계약은 발 원점·+Y 위·+Z 정면이며, 직렬화된 다섯 MeshPart 회전은 native 보정 Y 180도다. TD는 `TargetHeight / template:GetBoundingBox().Y`로 표시 배율을 계산한다. 회전 보정을 무조건 한 번 더 적용하지 않고 RPG에서 정면·접지를 직접 확인한다.

## 도끼와 오른팔의 소유권

TD `runtime/orc/geometry.json`의 `ownershipOverrides`는 **원본 도끼 연결섬 260삼각형 전체를 `ArmR`에 지정**한다. 로컬 원본 GLB에서 해당 260개 face를 읽어 발 원점/높이로 정규화하고, TD 파생 `runtime/orc/mesh-only.glb`의 각 노드 이동을 적용한 뒤 5개 부위의 삼각형 좌표와 독립 비교했다. 허용 오차 `2e-6`에서 **260/260이 ArmR에만 일치**, 다른 부위 일치는 0이었다. `ArmR` 전체는 cap을 포함한 620삼각형이므로 260개는 그 안의 도끼 원본 영역이다. 파생 mesh-only GLB의 SHA는 `3fc07009b59be3b7b001e69297ae36276e9ba69b4f66cf30eb6d6b5d50d08f11`이다.

TD의 `runtime/review/orc-textured-review/front.png`, `orc-walk-review/front.png`, `orc-walk-review/three-quarter.png`를 직접 열어 손의 도끼 형상을 확인했다. TD `runtime/package-review-log.json`은 도끼 전체의 팔 추종을 해당 후보에서 확인했다고 기록한다. 위 관찰과 로컬 기하 대조는 RPG에서 실제 Roblox Mesh ID의 공격 포즈·손·도끼 추종이 검증됐다는 뜻은 아니다.

## 검사와 다음 담당

- 원본과 복사본 전체 바이트 및 SHA-256 일치. GLB 2.0 헤더·JSON chunk를 읽어 원본 면 수와 mesh/image/skin/animation 개수를 확인했다.
- 기존 XML 해시는 변경되지 않았고 `orc`의 5부위 ID·크기·위치·회전·TargetHeight를 읽어 manifest에 반영했다. 신규 파일은 Git LFS 속성을 확인했다.
- **미검증:** 현재 RPG Studio/클라이언트에서 다섯 외부 Mesh와 색맵 로드, 실제 공격 중 오른팔·도끼 추종, 정면·발 접지, 게시된 테스트 Experience/타 계정 권한, 기기 성능. 이전 대표 로딩 probe에는 오크가 포함되지 않았다.
- Engineer는 `ArmR`을 어깨 기준으로 움직여 팔과 도끼가 함께 움직이도록 연결하고, QA는 원본/LFS와 실제 클라이언트에서 예고·공격·피격·정면·접지를 별도로 확인한다. 신규 자산 업로드·게시 또는 TD 변경은 수행하지 않았다.
