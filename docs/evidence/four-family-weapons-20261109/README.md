# 最新4계열 무기·기어/가방 아이콘

2026-11-09 · TLT-028/029/032/041/052/073/082/084 · 0.93.0

사용자 요청: Meshy 최신 생성 Traveler(Common)·Tempered(Common)·Veteran(Uncommon)·Sentinel(Rare) 무기만 가져와 업데이트하고 각각의 기어/가방 아이콘을 만든다. 이전 Rare/Epic과 섞지 않는다. 사용자가 실제 TLT Studio의 asset:read/write와 assets 업로드 폴더 허용을 완료했다고 확인한 뒤 업로드했다.

## 변경과 출처

- Meshy 공개 UI의 최신 텍스처 완료20개 중 방패4개를 제외해 검·도끼·활·지팡이16개를 두 ZIP(10+6)으로 받았다. UI 생성시각은 2026-11-09 16:55–17:00 America/Toronto다. 이름 대신 Task ID·GLB 해시·원본 ZIP 멤버로 고정했다. 자동 이름이 Verdant Sentinel Bow인 활은 **Veteran**이다.
- [모델 manifest](../../../assets/models/four-family-weapons-meshy-v1/manifest.json), [GLB/Blender/Roblox 템플릿](../../../assets/models/four-family-weapons-meshy-v1/README.md), [아이콘16종·소형32종](../../../assets/ui/four-family-weapon-icons-v1/README.md).
- 원본16개 총24,702삼각형. 손잡이 원점·기존 길이와 도끼 절삭 방향을 맞췄다. 각 활의 고정 시위 면을 준비 GLB에서 제거하고 두 Beam과 해당 모델의 끝/중앙 Attachment를 연결했다. 원본 및 시위 제거 전 정규화 활4개는 보존한다.
- 아이콘은 실제16개 모델에서 직접 렌더했다. **Blender View Transform=Standard, Display=sRGB, Look=None, Exposure0, Gamma1, Use Curves=Off**. 색 텍스처는 sRGB. RGBA 투명 배경1024²16개와64²/48²각16개. 글자·테두리는 PNG에 넣지 않고 기존 TD UI 프레임을 유지한다.
- `FourFamilyWeaponVisuals`는 정확히16개 정의만 연결한다. `WeaponAppearance`는 서버가 확정한 `TLTEquippedWeapon`에 따라 실제 모델을 교체한다. `ItemSpriteAtlas.images` 개별ID를 공통 `ItemSprites.create`가 읽으므로 Gear/Bag 같은 장비는 같은 아이콘이다. Tempered의 기존 안정ID `*_fine` 유지. 다른 Rare/Epic·방패·화살·화살통·능력치·보유품·경제 수치는 이 작업에서 바꾸지 않는다.

## 업로드·Studio

모델16개와 이미지16개 업로드가 전부 **Approved/Active**다. GLB 가져오기로 생성된 하위 Mesh16/Texture16의 ID도 [기록](../../../assets/models/four-family-weapons-meshy-v1/native-import.json)했다. 직접 업로드32건과 자동 생성 하위32개를 구분한다. [업로드 응답](../../../assets/models/four-family-weapons-meshy-v1/uploaded.json)에 최종 operation.done 및 ID를 보존한다. 토큰·쿠키·키는 저장하지 않는다.

실제 `The Last Throne` Studio(place70829337938054)의 ServerStorage에16개 템플릿을 넣고 관련4개 모듈을 적용했다. 가져온 패키지의 스크립트/PackageLink는 런타임 템플릿에 포함하지 않는다. 우리 임시 가져오기16개와 export 임시 Folder는 정리했다. 현재 Studio 편집 메모리에 반영되었으며 **Place 게시/라이브 DataStore 변경은 하지 않았다**.

## 검증

| 조건/명령 | 결과 |
| --- | --- |
| `python3 tools/validate-four-family-weapons.py` | 원본16해시·Task ID·32건 Approved·프로젝트 연결·아이콘48개 RGBA/알파·클리핑/개별 매핑 통과 |
| EditableMesh native 좌표48점×16 | 준비 원본768점 일치. 네이티브 좌표계180° 변환을 실측해 고정 |
| `tests/four-family-weapons-native.luau` / Studio MCP, PlaceId0·플레이어0 격리 candidate | **700검사 통과**. R6/R15×16장착, 클래스/장비ID·소스Task, 교체/중복방지·HP/루트 유지, 활0/.5/1/0, 도끼 방향/검 trail, Gear/Bag 공통 sprite, 기존Rare fallback, Mesh/Texture/Icon48리소스 로딩 Success |
| `tests/lobby-selected-weapons-native.luau` / 같은 격리 fixture | **49검사 통과**. 실제R6 모델로 기존 불완전 손/몸통 mock을 교체하고16계열 선택·해제 후 현재 외형을 확인 |
| `tests/elf-quiver-native.luau` / 같은 격리 fixture | **179검사 통과**. 기존R6/R15 화살통·장전/취소/복구 계약 |

[네이티브 결과](native-result.json) · [회귀 결과](regressions.json). `run-in-roblox`는 다른 채팅의50312포트 점유와 충돌해 최종 검증에 사용하지 않았고, 위 결과는 직접 연 격리 Studio에 MCP로 동일 테스트를 실행해 확보했다. 초기 preload 검사에서 mesh ID를 이미지 문자열로 읽는 harness 오류는 MeshPart/ImageLabel 인스턴스 preload로 수정했다. 기존 로비 테스트의 기본 Humanoid/R6 손만 있는 mock도 실제 R6 리그로 고쳤다. 이 두 초기 실패를 성공 결과로 계산하지 않는다.

아래는 실제 Roblox 편집 렌더다. 위→아래 Traveler/Tempered/Veteran/Sentinel, 왼쪽→오른쪽 검/도끼/활/지팡이. Blender Standard 비교 렌더와 구분한다. 화면은 격리 fixture의 검토용 배치이며 게임 UI/실계정 증거가 아니다.

![실제 Roblox16종](studio-models.png)

## 마감·남은 검증

게임 빌드는 `VERSION`과 소스 커밋을 고정한 뒤 `python3 tools/build-game.py --source <commit> --record docs/evidence/four-family-weapons-20261109/build.json`으로 기록한다. 새 장비ID별 외형 기능으로 MINOR를 올려0.93.0을 사용한다. 일반 빌드이며 릴리스 태그와 Roblox Place 게시는 없다.

미검증: 실제 계정의 저장/재접속 착용, 게시 클라이언트의 에셋 권한·조명, 모바일 아이콘 가독성·4인 성능·최종 사용자 미술 수용. 다음 담당은 QA/미술의 실클라이언트·기기 수용이며 부모 티켓을 완료 처리하지 않는다. 현재 UI 구현 절차와 승인 TD 룩앤필/개별 투명 아이콘 원칙을 재사용하는 자산 교체로서 경제/전투/UX 설계를 추가하지 않았다.

## 고정 빌드 결과

- 소스 `37e27d2e3b29944dc07a14b3ec3573f4c79aeeff`, 버전0.93.0. [빌드 기록](build.json).
- `builds/0.93.0/TheLastThrone-0.93.0.rbxlx` 16,509,787bytes, SHA256 `141da7a86c2fd7fe0408747b6f27376090f9f03ad3acd9baf19293143298fd54`.
- 고정된 빌드 파일을 별도 Studio로 열고 동일700검사를 다시 실행해 통과했다. 메시·텍스처·아이콘48개 모두 Success. [고정 빌드 네이티브 결과](fixed-build-native.json). frozen runtime RBXM SHA256 및 장비ID 모듈도 작업 정본과 일치했다.
- `git push origin main`: LFS88개/190MB 업로드 성공, 원격 main 소스37e27d2e 일치 확인. 증거 문서는 후속 커밋으로 저장한다.
