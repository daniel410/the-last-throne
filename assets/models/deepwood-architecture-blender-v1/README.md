# Deepwood Blender 건축 키트

TLT-061 · 2026-11-12 · Blender MCP 직접 조형, 로컬 게임 연결용.

기준은 [Deepwood 에픽/스토리 조감도](../../concepts/2026-11-12-deepwood-epic-stories-v1/index.html)다. Waystation·Shelter·Outpost·Watchtower·Barracks·Rootwood·AltarRuins·Storehouse·Quarry·Battlefield 10종, 691파트를 직접 제작했다. 외부 생성기나 다운로드 모델을 사용하지 않았다.

- `deepwood-architecture.glb`: 새 Deepwood 씬만 내보낸 편집 가능한 메시691개. 기존 Blender 씬14개는 보존했다.
- `kit.json`: Blender 오브젝트와 같은 크기·sRGB 색·재질·로컬 CFrame·기하 종류·충돌 의도. 런타임은 GLB를 업로드하는 대신 이 기하를 Roblox 기본형으로 재구성한다. 원통은24분할, 구형은 단순 메시여서 Blender 미리보기와 Roblox 곡면 테셀레이션에는 차이가 있다.
- `kit-preview.png`, `outpost-preview.png`: 실제 Blender 렌더. 게임 화면 증거와 구분한다.
- `validation.json`: GLB 메시 수·회전 직교 오차·산출물 SHA256 검증.
- 제작 코드: `tools/build-deepwood-architecture-blender.py`. Blender MCP의 안전 모드에서 실행하며 새 씬을 만든다. 반복 실행 시 새 씬이 추가되므로 기존 씬을 덮어쓰는 용도로 사용하지 않는다.
- 변환 코드: `python3 tools/export-deepwood-architecture.py`. `DeepwoodArchitectureTemplates.luau`를 생성하고 `DeepwoodArchitecture`가 실제 모델을 만든다. 작은 구역은 전체 비율을 유지해 축소한다.

색상 기준: Standard / sRGB / Look None / Exposure0 / Gamma1 / Curves Off. 제작·배치·충돌 검증과 미검증 범위는 [맵 증거](../../../docs/evidence/deepwood-concept-map-20261112/README.md)를 따른다.
