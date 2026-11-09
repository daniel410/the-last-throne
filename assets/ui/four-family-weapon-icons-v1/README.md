# Traveler · Tempered · Veteran · Sentinel 무기 아이콘

2026-11-09 · TLT-028/029/032/041/052/073/082/084

최신 Meshy 실물 무기16종을 직접 렌더했다. 검·도끼·활·지팡이 ×4계열이며 방패·방어구·장신구는 제외한다. 기존 Rare/Epic 이미지와 혼합하지 않는다. Veteran 활의 Meshy 자동 이름은 Verdant Sentinel Bow지만 실제 선정 계열은 Veteran이다. 안정ID `*_fine`의 표시 이름은 Tempered다.

- `icons/`: 개별1024×1024 RGBA PNG16개. 실제 alpha 투명 배경, 글자·희귀도 테두리·바닥 없음.
- `64/`, `48/`: 같은 장면의 별도 소형 렌더32개. 각 크기에서 식별성 확인용.
- `manifest.json`: 아이템 정의ID·Meshy Task ID·Roblox 아이콘ID·해시.
- `alpha-report.json`:48개 픽셀 검사 결과. 외곽에 비투명 픽셀 없음.
- `gallery.html`: 원본 PNG를 그대로 표시하는 비교표. 게임 화면 증거와 구분한다.

Blender 비교 설정은 **View Transform=Standard**, Display=sRGB, Look=None, Exposure=0, Gamma=1, Use Curves=Off. 색 텍스처 sRGB, 렌더는 Cycles/투명 Film이다. Veteran/Sentinel 도끼 금속 자루 및 각 계열의 실제 모델 팔레트를 유지했다. TD 프레임은 런타임에서 기존 UI가 추가한다.

`ItemSpriteAtlas.images[definitionId]`에 개별 등록했다. 기어와 가방이 공통 `ItemSprites.create`를 사용하므로 같은 아이템은 두 화면에서 같은 PNG를 표시한다. 기존 재료 아이콘과 다른 Rare/Epic 등록은 유지한다. Roblox 업로드16개 모두 Approved, 네이티브 ImageLabel 로딩16/16 Success. 실제 게시 클라이언트·실기기는 후속 검증이다.

검증: `python3 tools/validate-four-family-weapons.py`.
