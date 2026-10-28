# K0 TD 몬스터 원본과 런타임 보존

후속 RPG 연결·실제 검증은 [연결 결과](td-monster-integration.md)와 [0.2.1 빌드 기록](build.md)에 남겼다. 아래 원본 인계 시점의 미검증 상태와 구분한다.

작업 ID: `TLT-002`, `TLT-032` 일부 · 2026-10-28 · 담당: 3D 모델링

Throne Defense의 현재 작업 트리에서 `MonsterModels` 런타임 XML과 고블린·슬라임·오우거의 Meshy 원본 GLB를 그대로 복사했다. [manifest.json](../../../assets/shared/td-monsters/manifest.json)에 원본 경로, SHA-256, 파일 크기, 세 모델의 모든 부품 좌표·ID와 검증 한계를 기록한다. 이것은 자산 출처와 런타임 입력의 보존이며 RPG에서의 로딩·전투·미술 수용 결과는 아니다.

## 파일과 출처

TD의 `default.project.json` 작업 트리는 `ServerStorage.MonsterModels`를 `assets/models/meshy-deepwood-slime-v1/runtime.rbxmx`에 연결한다. 조사 당시 TD HEAD는 `22ff3be95a8e9d3c034d83d93b8c540a36070ac2`이나 프로젝트 파일은 수정 상태, 모델 폴더들은 미추적 상태였다. HEAD만으로 해당 파일의 내용을 고정할 수 없으므로 아래 **실제 파일 해시**를 기준으로 삼는다.

| 복사된 파일 | TD 원본 경로 (`../throne-defense/` 아래) | SHA-256 | 크기 |
| --- | --- | --- | ---: |
| [runtime.rbxmx](../../../assets/shared/td-monsters/runtime.rbxmx) | `assets/models/meshy-deepwood-slime-v1/runtime.rbxmx` | `14e4e9492d280ce887b229cbe6deea5a7a90af2cb643760dc355bcdcb4433ef5` | 548,546 bytes |
| [고블린 원본](../../../assets/shared/td-monsters/source/Meshy_AI_Goblin_Bladebearer_20261025_texture_da014fd3.glb) | `assets/models/meshy-blocky-monsters-v1/source/Meshy_AI_Goblin_Bladebearer_20261025_texture_da014fd3.glb` | `90ece6137ab326db2e9b929383c5b98c3f2529b0f78bc7f4d1fc8dbba1dc0a7b` | 7,368,640 bytes |
| [슬라임 원본](../../../assets/shared/td-monsters/source/Meshy_AI_Grumpy_Green_Slime_1026021945_texture.glb) | `assets/models/meshy-deepwood-slime-v1/source/Meshy_AI_Grumpy_Green_Slime_1026021945_texture.glb` | `3adc1a12f3e89f6690047abb2c8cab3d6fbb4ae0f3726b87e2a5607d4d7324c2` | 6,033,596 bytes |
| [오우거 원본](../../../assets/shared/td-monsters/source/Meshy_AI_Grimfang_the_Bonecrusher_20261025_texture_5d91642a.glb) | `assets/models/meshy-blocky-monsters-v1/source/Meshy_AI_Grimfang_the_Bonecrusher_20261025_texture_5d91642a.glb` | `d5a01cdc860ce2bc0725594e89c01b574f095ac9cde4a84807b72640493af2b3` | 7,654,612 bytes |

원본과 복사본 SHA가 일치한다. 네 파일 모두 기존 `.gitattributes`의 Git LFS 대상이다. XML 전체는 원형 그대로 보존하므로 `MonsterModels` Folder 아래 **43개** Model이 들어 있으며, 3종 외의 원본 GLB를 복사하거나 다른 모델의 RPG 채택을 뜻하지 않는다. XML에 들어 있는 외부 Roblox ID도 바꾸지 않았다. 신규 생성·업로드·공개 설정 변경·게시를 하지 않았다.

## 템플릿 구조와 크기

`runtime.rbxmx`의 Folder `MonsterModels` 바로 아래 Model 이름은 정확히 `goblin`, `slime`, `ogre`다. `TargetHeight` NumberValue는 각각 **3.6 / 1.1 / 6.05**다. 부품은 `MeshAnchor` StringValue로 부위 이름을 보존하며 `EnemyPoseFloor` 문자열에도 TD 접지 보정용 데이터가 있다. 해당 데이터는 RPG 구현에서 자동으로 적용되는 기능이 아니다. 선택한 11 MeshPart는 모두 XML상 `Anchored=true`, `CanCollide=false`이고, 원본 XML 전체의 정적 검사에서 `Script`, `LocalScript`, `ModuleScript`, `Motor6D`, `Bone`은 발견하지 못했다.

다음 위치와 크기는 **원본 XML에 직렬화된 정규화 좌표**이며, 네 자리로 반올림했다. 정확한 수치와 각 3×3 회전행렬은 manifest에 있다. TD의 어댑터는 발 원점·Y 위·**+Z 정면**으로 해석하고 `TargetHeight / template:GetBoundingBox().Y` 배율을 사용한다. 세 종의 원본 파트에는 native 가져오기 보정인 Y 180도 회전이 직렬화되어 있으므로 회전을 버리거나 다시 무조건 180도를 더하지 않는다. RPG 캐릭터 방향·실제 접지는 별도 확인한다.

| 모델 | 부품 | 위치 `(X, Y, Z)` | 크기 `(X, Y, Z)` | Mesh ID |
| --- | --- | --- | --- | --- |
| goblin | LegL | `(-0.1958, 0.1100, 0.0674)` | `(0.3915, 0.2200, 0.3518)` | `78392327157438` |
| goblin | LegR | `(0.1958, 0.1105, -0.0541)` | `(0.3915, 0.2190, 0.3785)` | `100268725310905` |
| goblin | ArmL | `(-0.3456, 0.4477, 0.1436)` | `(0.1513, 0.4153, 0.3584)` | `127402469282462` |
| goblin | ArmR | `(0.4064, 0.4430, 0.1290)` | `(0.2728, 0.3618, 0.6287)` | `106102430341786` |
| goblin | Body | `(0.0649, 0.6100, 0.0377)` | `(0.7261, 0.7800, 0.6185)` | `77403549111699` |
| slime | Body | `(-0.0004, 0.5000, -0.0002)` | `(2.0734, 1.0000, 1.8153)` | `84245584635347` |
| ogre | LegL | `(-0.2278, 0.1100, 0.0117)` | `(0.4556, 0.2200, 0.4268)` | `76243711635467` |
| ogre | LegR | `(0.1798, 0.1103, -0.0331)` | `(0.3596, 0.2195, 0.3839)` | `77089513742534` |
| ogre | ArmL | `(-0.3877, 0.5048, 0.0239)` | `(0.2554, 0.5295, 0.3178)` | `108622715572697` |
| ogre | ArmR | `(0.4115, 0.5100, 0.0291)` | `(0.3030, 0.5400, 0.4952)` | `98353562560509` |
| ogre | Body | `(0.0107, 0.6100, 0.0151)` | `(0.9654, 0.7800, 0.5482)` | `98618217378067` |

세 모델의 색맵 ID는 각각 `134919664038207`, `75994104212849`, `90412861785322`다. 이 ID는 런타임 XML의 참조이며 원본 GLB 파일 자체가 아니다.

## 슬라임 원본과 런타임의 차이

슬라임 원본 GLB는 15,515삼각형·13,599정점과 2048² PBR 원본 3장을 포함한다는 TD 기록이 있다. 로컬 GLB 구조 검사에서는 메시 1개·이미지 3개·skin/animation 0개를 확인했다. TD에서 파생한 런타임은 얼굴·윗잎·바닥의 중요 면을 보호해 감량한 **2,989삼각형 Body 1개**이며, 1024² 색맵을 사용하고 normal/metalness 표현은 생략한다. 런타임 Mesh는 `84245584635347`, 색맵은 `75994104212849`다. 원본 GLB를 직접 붙여 런타임이 동일하다고 주장하지 않는다.

## 검사와 인계

- `shasum -a 256`과 복사 직후 양쪽 바이트 해시 비교: 위 XML과 GLB 3개가 TD 실제 파일과 일치.
- Python `xml.etree.ElementTree`: Folder·43 Model과 3종의 5+1+5 MeshPart, ID·위치·크기·회전·앵커 확인. 코드/관절 클래스 부재 확인은 정적 XML 범위다.
- GLB 2.0 JSON chunk 검사: 고블린 3,162삼각형, 슬라임 15,515삼각형, 오우거 3,166삼각형. 각 원본은 메시 1개·이미지 3개·skin/animation 0개다.
- `git check-attr filter diff merge -- <네 파일>`: 네 파일 모두 `lfs`. 실제 원격 LFS 업로드와 커밋·푸시는 통합 담당의 마감 단계에서 확인한다.
- Roblox Studio의 이번 모델 연결, RPG Place에서의 Mesh/Texture 로딩·시각·좌표·애니메이션·접지와 성능, 게시된 테스트 Experience 및 타 계정 권한은 **미검증**. 이전 [대표 자산 로딩 probe](asset-load-probe.md)는 Goblin/Ogre Body와 색맵만 포함하고 슬라임은 포함하지 않았다.

다음 담당: Engineer가 이 XML의 세 모델을 명시적으로 선택해 서버 전투와 분리된 시각 어댑터로 연결한다. QA는 원본 해시·LFS·부품 보존을 검사하고, 실제 테스트 클라이언트에서 전체 부위 로드·방향·접지·행동·권한을 확인한다. Meshy 제작 서비스의 원본 이용 조건과 현재 Experience별 권한은 별도로 확인해야 한다.
