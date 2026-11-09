# 최신 Meshy 4계열 무기16종

2026-11-09 · TLT-028/029/032/041/052/073/082/084

사용자 지시에 따라 Meshy에서 2026-11-09 16:55–17:00 America/Toronto에 생성된 텍스처 완료 묶음 중 Traveler(Common)·Tempered(Common)·Veteran(Uncommon)·Sentinel(Rare)의 검·도끼·활·지팡이만 선정했다. 방패4개, 회색 생성 단계, 이전 Rare/Epic은 제외한다. 이름 추측 대신 `manifest.json`의16개 Task ID로 고정했다. 특히 **Verdant Sentinel Bow는 Veteran 활**이며 `*_fine`은 기존 Tempered 안정ID다.

`source/`는 원본 GLB 그대로16개이며 원본 SHA256·다운로드 ZIP 멤버를 기록했다. 총24,702삼각형이다. `prepared/`는 손잡이 원점·기존 무기 길이에 맞춰 변환한 GLB16개다. 활의 중앙 고정 시위 면은 제거하고 실제 활 끝·시위 위치를 Attachment로 전달하여 기존 당김 애니메이션의 두 Beam으로 대체했다. 전체 활은 원본과 `normalized/*-intact.glb`에 보존한다. 무기 범위·공격력·서버 판정은 바꾸지 않는다.

`runtime.rbxm`은 ServerStorage용 스크립트 없는16개 템플릿 Folder다. Roblox 가져오기 후 각48점, 총768점의 실제 EditableMesh 좌표를 준비 원본과 대조해 방향·형상을 검증했다. `native-import.json`에 메시·텍스처ID와 결과를 기록했다. 흰 Color·원본 baseColorTexture를 사용하며 색을 임의 증폭하지 않는다. 원본은 PBR 금속/노멀 맵 없이 색 텍스처1장과 roughness=1/metalness=0을 사용한다.

`four-family-weapons-review.blend`는16개 아이콘 렌더 장면이다. **Standard / sRGB / None / Exposure0 / Gamma1 / CurvesOff**가 비교 기준이며 텍스처는 sRGB다. Roblox 조명 검증은 별도로 진행했다. 업로드된 모델16개와 아이콘16개 모두 Approved다. 가져오기 때 생성된 하위 Mesh/Texture32개 ID도 보존한다.

`FourFamilyWeaponVisuals`가 정확한16개 장비 정의만 연결한다. 기존 Rare/Epic, 기사 방패, 엘프 화살·화살통은 유지한다. R6/R15 각16종 장착·교체·활 당김·UI 이미지·로딩700검사 통과. 로비 선택49검사 및 기존 화살통179검사 통과. 실제 계정·게시 클라이언트·모바일·4인 성능은 미검증이며 Place 게시는 하지 않았다.

[아이콘](../../ui/four-family-weapon-icons-v1/README.md) · [증거](../../../docs/evidence/four-family-weapons-20261109/README.md)
