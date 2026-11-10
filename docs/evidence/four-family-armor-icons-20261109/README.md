# 4계열 방어구 아이콘 · 2026-11-09

TLT-028/029/032/041/052/057/084. 사용자 요청: 최신 Traveler/Tempered/Veteran/Sentinel 후드·헬멧·방패·상의·장갑·부츠 컨셉을 대장간·기어·가방에 적용.

## 변경과 근거

`assets/concepts/2026-11-09-starter-equipment-v1/boards`의 hood/knight_helmet/dwarf_helmet/shield/coat/mage_robe/gloves/boots 8판을 직접 확인했다. 기존 [등급 미술 조사](../../research/2026-11-08-equipment-rarity-visuals.md)의 동일 계열 색상·실루엣 원칙을 재사용했다. imagegen 스킬과 프로젝트 제작 스킬을 적용했다.

`assets/ui/four-family-armor-icons-v1`에 32 PNG, 참조 열·해시·생성 프롬프트·Roblox 승인 결과·갤러리·ZIP을 보존했다. 네이티브 생성 결과1254×1254 RGBA를 수정 없이 사용한다. 투명 가장자리의 최대 alpha1/255는 보존하며 alpha128 이상 실루엣은 프레임 안에 여백이 있다. 새 Image32건 모두 Approved. 24개 정의와 기사/드워프 머리 변형8개를 등록했다.

공통 ItemSprites/ItemArtwork의 선택적 클래스 인자로 이미지를 결정한다. ArmoryView, EnhancementView, HeroStatsView, MobileHeroStatsView, InventoryGui에서 전달한다. 가방/미수령/착용품은 소유 영웅, 공유 창고는 선택 영웅 기준이다. 기본 후드는 엘프/마법사/클래스 미상, 기사는 기사 헬멧, 드워프는 드워프 헬멧이다. 기존16무기·2재료 이미지와 레거시 아틀라스는 유지했다. 가격·성능·서버 소유권·3D 변경 없음.

## 검증

- `uv run --with pillow python tools/validate-four-family-armor-icons.py`:32 PNG/해시/참조/알파/32승인/24정의+8변형 통과.
- ZIP CRC 통과. `git diff --check` 통과.
- 빌드0.94.0과 네이티브 통합 검증은 소스 고정 후 아래 기록에 추가한다.

실제 게시 클라이언트·실기기·사용자 미술 수용은 미검증이다. Place 게시/릴리스 태그는 수행하지 않는다. 다음 담당자는 UI QA/사용자 미술 검수다.
