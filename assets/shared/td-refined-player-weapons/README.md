# 플레이어 무기 시각 v2

2026-10-31 · TLT-005/032/033/055/057/084 부분 구현.

사용자의 새 무기 적용 요청에 따라 TD의 검증 가능한 최신 Meshy v2 원본을 RPG의 실제 플레이어 장착 경로에 연결했다. Knight는 Azure Oathblade, Dwarf는 Embercleaver, Mage는 Ember Crown Staff를 사용한다. Elf는 기존 TD 활/화살 메시와 앞서 Blender MCP로 제작한 변형·시위·노크·발사 동작을 함께 사용한다. 새 엘프 메시를 생성했다고 보고하지 않는다. 캐릭터 몸체와 독립 방패는 이번 교체 대상이 아니다.

원본 커밋·메시/PBR ID·삼각형 수·해시는 [manifest.json](manifest.json)과 [TD 메타데이터](td-source-metadata.json)에 있다. 새 업로드는 없으며 TD 파일은 변경하지 않았다. runtime.rbxmx는 원본 MeshPart/SurfaceAppearance를 유지하고 무해한 Grip/소켓/끝 Attachment를 추가한 파생본이다. 0.44.1은 드워프가 옆면으로 타격하던 오류를 고쳐 원본 기준 native Y축45도(0.44.0 대비 -135도)로 보정했다. [Blender 원본/축](../../animations/axe-edge-v1/manifest.json)과 [타격 계측](../../../docs/evidence/axe-edge-0441/README.md)을 참조한다. 버텍스/UV를 재생성하지 않았다.

Blender MCP 내부 bpy API로 세 새 무기의 TD 텍스처 검토 GLB를 가져와 배치하고 PBR 외형을 직접 확인했다. [Blender 원본](refined-weapon-review.blend)의 활성 씬은 TLT_Refined_Weapon_Source_Review이며 기존 동작 제작 씬도 보존한다. 별도 Python 생성 스크립트는 사용하지 않았다. [제작 호출·이미지·검증](../../../docs/evidence/deepwood-pacing-0440/README.md)을 따른다.

WeaponAppearance 시각 버전2와 KnightAppearance 관찰자가 네 클래스의 최초 장착·구버전 교체·무기 숨김/재장착·소켓 손실 복구·리스폰에 이 폴더를 사용한다. 서버 판정 사거리·피해·클래스/소유권은 기존 계약을 유지한다. R6/R15 엔진 검사116개와 새 원본을 포함한 동작 검사29,549개를 통과했다. 실제 게시 클라이언트 권한·실기기 성능·최종 미술 수용은 후속이다.
