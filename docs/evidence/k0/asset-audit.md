# K0 공유 3D 자산 조사

후속 갱신: 사용자의 기존 원본 재사용 지적에 따라 [고블린·슬라임·오우거 채택 기록](td-monster-sources.md)에 TD runtime/원본 GLB 복사와 실제 연결을 별도로 기록했다. 아래는 최초 조사 당시의 상태이며 최신 구현 상태를 뜻하지 않는다.

작업 ID: `TLT-002`, `TLT-032` 일부 조사 · 2026-10-28 · 담당: 3D 모델링
상태: **원본과 과거 증거 조사**. RPG 런타임 채택, 현재 Experience 권한, 실제 로딩·모션·미술 수용은 미검증이다.

## 조사 기준과 보존

- 사용자 요청에 따라 TD와 원형을 공유한다. 원본 조사만 했으며 TD 파일·승인 이미지·Roblox 에셋은 변경하거나 복사하지 않았다. 새 업로드·게임 게시·Studio 실행은 하지 않았다.
- TD 저장소의 HEAD는 `22ff3be95a8e9d3c034d83d93b8c540a36070ac2`이지만, `default.project.json`, `HeroWeaponVisuals.lua`, `EnemySystem.lua`는 수정 상태이고 이 보고서의 모델 폴더 및 여러 어댑터는 미추적 상태다. 따라서 이 HEAD가 아래 작업 트리 파일 내용을 고정한다고 주장하지 않는다. 아래 SHA-256은 조사 시점의 **실제 파일**을 식별한다.
- TD 현행 작업 트리 `default.project.json` SHA `6bf773a8306b10cfaeddba5f5f826665b7b8a9d6177dff1fe021174c35a28f47`의 `ServerStorage` 참조를 기준으로 한다. `TowerModels`, `HeroWeaponModels`, `MonsterModels`, `MapModels.ForestKit`은 각각 아래 XML을 가리킨다. 레지스트리의 경로·해시는 런타임 사용권 보증이 아니다.
- [기사](../../../assets/concepts/2026-10-27-shared-ui-v2/heroes/hero-knight.png), [고블린](../../../assets/concepts/2026-10-27-shared-ui-v2/monsters/goblin.png), [오우거](../../../assets/concepts/2026-10-27-shared-ui-v2/monsters/ogre.png) 참고 이미지를 직접 확인했다. 기사 은청 갑옷·방패, 고블린의 녹색 체형·작은 검, 오우거의 큰 체형·곤봉이 정체성 판단에 유용하다. 그림은 실제 3D 리그나 런타임 자산이 아니다.

아래 `TD/`는 이 저장소의 형제 디렉터리 `../throne-defense/`를 뜻한다. 외부 `rbxassetid`를 담은 XML은 모델 파일 자체와 Roblox가 제공하는 하위 Mesh/Image를 구분해 취급한다.

## 후보와 실제 파일

| 대상 | 현재 재사용 판단 | 로컬 원본·실제 SHA-256 |
| --- | --- | --- |
| 기사 검 | 형상과 PBR **Reuse 후보**. 손 연결·K0 3연격 검증은 별도 | `TD/assets/models/meshy-hero-weapons-v2/source/knight.glb` `6a55244cb6ffea4f57efb6aab33764f63824f5bf88ab468d95e6750bd969563f`; 3k 파생 `TD/assets/models/meshy-hero-weapons-3k-v1/knight/mesh-only.glb` `64286361e72b1ea51202fdb58c61d2cbdd54b5abb5a72bc51f6f57acd81f5f13` |
| 고블린 | 5부위 형상·색맵 **Reuse 후보**; 이동·공격·피격·회전은 별도 어댑터 | `TD/assets/models/meshy-blocky-monsters-v1/source/Meshy_AI_Goblin_Bladebearer_20261025_texture_da014fd3.glb` `90ece6137ab326db2e9b929383c5b98c3f2529b0f78bc7f4d1fc8dbba1dc0a7b`; 파생 `runtime/goblin/mesh-only.glb` `a0ba80885aad1b42cfb8cc5bcee0ac8f6e7f0a039f8deaa9391e989e53ad27dc` |
| 오우거 | 5부위 형상·색맵 **Reuse 후보**; 근접 카메라·곤봉 예고와 지면 접촉 별도 검증 | `TD/assets/models/meshy-blocky-monsters-v1/source/Meshy_AI_Grimfang_the_Bonecrusher_20261025_texture_5d91642a.glb` `d5a01cdc860ce2bc0725594e89c01b574f095ac9cde4a84807b72640493af2b3`; 파생 `runtime/ogre/mesh-only.glb` `7fd3863693565cedc3314a41552720691b0bdf886788df54ae5b671a6e38a7ae` |
| 숲 환경 | ForestKit **참고/Reuse 후보**; 전투 공간 및 충돌은 별도 블록아웃 | `TD/assets/models/maps-quality-v2/forest-kit-v3/forest-kit.blend` `4e493fb9cc871b2008aa04983c61046a67ac1d8e3fe36b460bb87363f12034ac`; `forest-kit.glb` `ba256e959f3e2cd6901ad12a596de055cff552bf9bd88d75dec377f103857558` |

고블린과 오우거 표의 `runtime/...`은 `TD/assets/models/meshy-blocky-monsters-v1/` 아래다. 각각의 `geometry.json` SHA는 `0cf2a98753869adac3c72a0e3e67a1c200d9079941a315010722049d34fc7408`, `6b1411b939f874519c2949fdfcece431fb8fb1a9fff6b3ad62f773c0169c71ce`다. 원본은 각각 3,162·3,166삼각형이고 관절 경계 cap이 포함된 파생본은 4,086·5,234삼각형이다. 이 숫자는 정적 파일 metadata이며 현재 RPG 성능 결과가 아니다.

### 실제 XML과 참조 ID

| 템플릿 | 실제 참조 | 구조 |
| --- | --- | --- |
| `TD/assets/models/meshy-hero-weapons-3k-v1/runtime.rbxmx` SHA `eca30419a3381c0e2bb2434e54619cc2dda0dbbc8c634d7da12094ad0f00416d` | `knight/Weapon` Mesh `rbxassetid://78152429410586`; PBR Color `129747040508630`, Normal `123540236668043`, Roughness `82984644200263`, Metalness `123863432588878` | 1 MeshPart, `SurfaceAppearance`; 파일에 별도 방패 없음 |
| `TD/assets/models/meshy-deepwood-slime-v1/runtime.rbxmx` SHA `14e4e9492d280ce887b229cbe6deea5a7a90af2cb643760dc355bcdcb4433ef5` | `goblin`: LegL `78392327157438`, LegR `100268725310905`, ArmL `127402469282462`, ArmR `106102430341786`, Body `77403549111699`; 색맵 `134919664038207` | 5 MeshPart |
| 같은 몬스터 XML | `ogre`: LegL `76243711635467`, LegR `77089513742534`, ArmL `108622715572697`, ArmR `98353562560509`, Body `98618217378067`; 색맵 `90412861785322` | 5 MeshPart |
| `TD/assets/models/maps-quality-v2/forest-kit-v3/runtime.rbxmx` SHA `d08038b65d548abf742d5517b46265c3d2e4688f42f04170341c639d3a0278d5` | `ForestKit`의 외부 Mesh ID 38개 | 시각 환경 38 MeshPart |
| `TD/assets/models/meshy-factions-refresh-v1/runtime.rbxmx` SHA `8402a11b665bdbe61240e76df62b2a0ca4fd4400ee8e322643f151c00fa6726f` | `swordsman`, `shieldbearer`는 각각 `Body`, `ArmR`로 구성 | 타워의 형상 참고. 독립 플레이어 기사 전신 리그나 별도 방패를 제공한다고 가정하지 않는다 |

표의 숫자 ID는 XML에서 관찰한 참조이며, 원본 바이너리·사용권·RPG Place의 로드 성공을 증명하지 않는다. 검·고블린·오우거의 해당 MeshPart는 XML에서 `Anchored=true`, `CanCollide=false`다. 세 XML의 조사 범위에서 `Motor6D`/`Bone`은 0개다. 이는 XML 내부에 관절이 없다는 사실이지, 아래 TD 어댑터로 애니메이션할 수 없다는 뜻은 아니다.

## 리그와 K0 연결 방향

1. **기사:** TD 플레이어는 Roblox 캐릭터에 검을 붙이는 구조다. `TD/src/Server/HeroWeaponMeshes.lua`는 검 template을 복제하고 손에 `Motor6D`를 생성한다. `HeroWeaponVisuals.lua`는 `RightHand`/`Right Arm`을 선택하고, `TD/src/Shared/HeroWeaponMotion.lua`는 상체·어깨·팔꿈치·손목 등 포즈를 제공한다. 이 어댑터는 K0 기준점일 뿐 RPG의 공격 타이밍과 방어·회피 완성본이 아니다. 레지스트리 `model.hero-weapon-adapter`의 과거 SHA `fe0a60744d3ea2ca5896f6d6b4825205f62b865debcc666e61c5f39bef92d688`과 현 파일 `7c5bb0c7ee928c5b288ca7e7d65c86a0f12dbcc1ccc22c0df05eab3d0eac6a96`이 다르므로 무심코 예전 기록을 채택하지 않는다.
2. **방패:** 무기 XML에는 독립 방패가 없다. 우선 분리된 임시 방패를 왼손/왼팔에 붙여 방어 가독성과 몸 관통을 시험한다. 타워 `shieldbearer`에서 방패 형상만 분리할 수 있는지는 원본과 소켓을 검토한 뒤 결정한다. 이 과정을 완성 장비 또는 최종 미술로 보고하지 않는다.
3. **적:** `TD/src/Server/EnemyLocomotion.lua`, `EnemySystem.lua`, `VisualFactoryEnemyMeshes.lua`에는 개별 부위의 보행·팔 포즈·발바닥 보정을 다루는 별도 로직이 있다. XML의 다섯 부위를 단순 weld하는 것만으로 보행과 전투가 완성되지는 않는다. 시각 파트와 서버 피해 판정·충돌은 분리하고 적 공격 예고/유효 구간·죽음·cleanup, 피벗·좌우 손·무기 추종·발 접지를 RPG에서 검증한다.
4. **환경:** ForestKit manifest SHA `ef5c072b85a79b119a358790bb63e89b255faa86c524a526738e73a9fceb09af`는 38메시·53,144삼각형과 거목 제외를 기술하며 `NOT UPLOADED`/`NOT INTEGRATED`로 표시한다. 이후 현재 작업 트리의 프로젝트 참조가 존재하므로 시점별 이력을 구분해야 한다. 파일 하나만으로 현재 Experience 사용 허가나 통합 완료를 추론하지 않는다. 바닥·벽 등 플레이 충돌은 별도 제작한다.

### K0 임시 기사 장비

현재 [KnightAppearance.luau](../../../src/server/Cosmetics/KnightAppearance.luau)는 외부 Roblox ID 없이 파란색·은색 계열 기본 Part 9개로 만든 **임시 검과 방패**다. `start()`는 기존·신규 플레이어의 R6/R15 손을 기다리고 리스폰·손 교체·반복 호출에서 자기 소유 표시 모델을 관리한다. 다른 기존 장비는 지우지 않는다. 검 `K0SwordJoint`는 손과 그립을 잇는 `Motor6D`로, 클라이언트가 `Transform`을 이용해 검의 시각 포즈를 조정할 수 있다. 다른 검 부위는 그립에 붙고 방패는 왼손에 붙는다. 파트는 충돌·터치·쿼리가 없고 판정·이동에 관여하지 않는다. 이것은 TD 원본의 채택·완성 갑옷·최종 애니메이션이 아니다.

## 과거 TD 증거와 현재 한계

- `TD/docs/evidence/meshy-hero-weapons-3k/report.md`는 2,999삼각형 기사 검의 TD Studio R15 실제 공격·클라이언트 preload와 당시 개인 `User 9156786071`의 Restricted·협업자 없음 확인을 기록한다. 경험 허용 목록은 당시 열거되지 않아 `null`이며 사용자 최종 미술, 모든 아바타, 실제폰/FPS와 게시 서버는 별도다.
- `TD/docs/evidence/blocky-monster-meshy/qa-result.md` 최종 요약은 TD 후보의 40슬롯 생성·보행·접지·로드 및 신규 153 Mesh/39 Image/3 Model에 대한 당시 개인 소유·Restricted·협업자 없음 증거를 기록한다. Experiences는 열거되지 않았다. 이후 별도 슬라임 변경이 포함된 현 XML 전체를 그 후보와 바이트 동일하다고 주장하지 않는다. 기존 TD 증거는 RPG에서 실행한 증거가 아니다.
- Meshy 원본의 저작·상업적 이용 조건 원문과 각 외부 에셋의 **현재** 소유·배포·대상 Experience 권한은 이번에 독립 확인하지 않았다. 사용자 지시의 공유 목적과 에셋 권한·제작 서비스 라이선스는 별도로 확인한다. 권한 오류를 공개 전환으로 해결하지 않는다.
- 실제 `MeshPart` 및 PBR/이미지 유형으로 로드하고 원본 모양·투명도·크기·전방·피벗·양손·바닥·카메라 거리 및 디바이스 성능을 확인해야 한다. 불러오기 실패 시 상태를 명시하고 임시 대체를 사용하며, 오류를 성공으로 보고하지 않는다.

## 이번 검증과 다음 담당

| 조건 | 실제 결과 |
| --- | --- |
| `git -C ../throne-defense rev-parse HEAD`와 지정 파일 `git status --short` | HEAD와 수정/미추적 상태 확인 |
| `shasum -a 256` | 위 XML·원본 GLB·파생 GLB·ForestKit 파일과 manifest의 실제 SHA 확인 |
| Python `xml.etree.ElementTree`로 XML의 `Item`·`Properties` 읽기 | 지정 이름·MeshPart·ID·Anchored·CanCollide 및 XML 내부 관절 클래스 확인 |
| 참고 이미지 3장 직접 열기 | 기사·고블린·오우거의 실루엣/색/무기 확인. 실제 게임 화면 검증 아님 |
| `luac -p src/server/Cosmetics/KnightAppearance.luau` | 구문 검사 통과 |
| 임시 Lua 모의 인스턴스/이벤트 테스트 | 기존·신규 플레이어, 지연된 R6/R15 손, 반복 시작·리스폰·손 교체·퇴장, 기존 장비 보존과 검 `Motor6D` 연결 통과. 실제 엔진 물리·복제를 실행한 결과는 아님 |
| Studio/게시된 클라이언트/실기기/실시간 권한 조회 | **미실행** |

다음 담당: Engineer가 리그·무기·적 시각 어댑터와 서버 전투를 연결하고, Designer가 블록아웃에 시각 후보를 배치하며, QA가 실제 RPG 환경의 로드·포즈·접지·근접 전투·권한 증거를 분리해 수집한다. 신규 형상·원본 복사/변경이나 업로드는 적용 범위와 재현 가능한 자산 추적을 확정한 뒤 진행한다. 조사 문서만으로 구현 티켓을 완료 처리하지 않는다.
