# Meshy 4계열 방어구 착용 모델

2026-11-11 · TLT-028/029/032/041/057/084 · ART·ENG.

사용자가 Meshy에 생성한 Traveler·Tempered·Veteran·Sentinel의 후드·헬멧·Mage Hat·코트·로브·장갑·부츠, 총28종이다. 무기/방패·아이콘·수치·가격·소유권은 이번 교체 범위에 포함하지 않는다. [기존 외형 조사](../../../docs/research/2026-11-08-equipment-rarity-visuals.md)를 재사용하며 별도 게임성 규칙을 추가하지 않는다.

`manifest.json`에 공개 UI에서 확인한 정확한 Task ID, 계열/부위/장비 정의/클래스, 다운로드 ZIP 멤버, 원본/준비본 SHA256을 고정했다. 이름에 Sentinel이 있다고 희귀도를 추정하지 않고 원본 색·형상과 승인 아이콘을 대조했다. 회색 생성 단계·이전 무기/방패는 제외했다. `source/`의28개 GLB는 다운로드 바이트 그대로다. 총43,892삼각형이며 각 메시20,000미만이다.

`prepared/`는 Roblox -Z 정면·블록 R15 기준 좌표로 맞춘 파생본이다. 장갑/부츠를 좌우와 손목/발목으로, 코트/로브를 몸통·허리·치맛자락과 로브 소매로 분할했다. 원래 삼각형과 UV/색 텍스처를 보존하며 분할선의 정점을 복제한다. 92개 부품의 실제 네이티브 메시에서24점씩, 총2,208점을 준비본과 대조했다. 가져오기에서 발생한180도 회전/중심 재배치를 보정했다. `geometry-report.json`, `native-import.json`에 각 메시/텍스처 ID·소켓·표본을 기록했다.

`four-family-armor-review.blend`는 별도 background Blender로 생성해 사용자의 live 장면을 보존했다. **Standard / sRGB / None / Exposure0 / Gamma1 / CurvesOff**를 적용했으며 원본 색 텍스처는 sRGB다. `renders/`는 원본 중립 비교 렌더다. Roblox 조명과 착용 검토는 별도 [작업 증거](../../../docs/evidence/four-family-armor-20261111/README.md)를 확인한다.

소유자9156786071에 직접 Model28개를 업로드했다. 로브4개의 소매 분할 보정은 같은 Model ID의 revision2다. 나머지는 revision1이며28개 모두 Approved/Active다. 최종92개 Mesh/28개 Texture ID는 `native-import.json`, 업로드 응답/버전은 `uploaded.json`·`upload-history.json`에 있다. 이전 로브 revision은 현재 런타임에 사용하지 않는다.

`runtime.rbxm`은 ServerStorage.FourFamilyArmorModels용 **스크립트·PackageLink 없는 고정 복제본**이다. 업로드 패키지의 자동 업데이트를 사용하지 않는다. 가져오기 패키지 원본이 아니라 이 검토한 복제본을 두 프로젝트/단일 빌드에 고정한다.

`FourFamilyArmorVisuals`는24개 기존 장비 정의를28개 템플릿에 연결한다. 공통 후드 정의는 Knight/Dwarf에서 헬멧, Elf/Mage에서 후드를 표시하고 Mage Hat/로브는 전용 정의를 사용한다. `ArmorAppearance`는 서버 확정 Head/Body/Hands/Feet 투영을 읽고 실제 신체 부위에 용접한다. 충돌/쿼리/접촉·물리 질량·전투 판정을 추가하지 않는다. 가려지는 몸/머리 액세서리는 착용 중만 숨기고 해제 시 원래 투명도를 복원한다. 머리 장비에는 [TD 파생 머리카락](../headgear-hair-td-v1/README.md)을 함께 붙이며 원래 Hair 액세서리도 착용 중 숨긴다. 지원하지 않는 장비는 기존 아바타 외형으로 돌아간다.

R6는 몸통/팔/다리 앵커로 대응한다. 옷감 물리/레이어드 의상 케이지가 아닌 분할 리지드 외형이므로 임의 UGC 체형·극단 자세의 접합 및 게시 클라이언트/실기기 성능·사용자 미술 수용은 별도다. 실패한 교체는 직전의 완전한 외형을 유지하고 오류 속성으로 구분한다. 소유/저장/이관/피해 권한을 만들지 않는다.

착용 보정은 `FourFamilyArmorVisuals.fit`의 버전으로 관리한다. 로브 앞뒤 깊이1.85배·모자0.25stud 하향·Knight/Dwarf 투구0.32stud 상향을 착용 체형 비율로 적용한다. 준비본/원본·업로드 ID는 유지하고 부품 크기와 소켓 위치를 함께 변환한다. [TD 참조·측면/눈높이 검증](../../../docs/evidence/mage-armor-fit-20261111/README.md).
