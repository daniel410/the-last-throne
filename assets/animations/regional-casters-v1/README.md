# MR-01 지역 주술사 스키닝 후보 v1

로컬 제작 후보이며 업로드·게임 연결 전이다. [전후 갤러리](../../../docs/evidence/regional-casters-mr01-20261103/index.html) · [검증/제한](../../../docs/evidence/regional-casters-mr01-20261103/README.md) · [manifest](manifest.json).

- `inputs/<Kind>.glb`: SHA256로 고정한 TD 분할 전 원본3개. 원본 텍스처·형상 보존용이다.
- `<Kind>-partitioned.glb`: 정규화 높이1, Y-up, 원본 +Z 정면의 Skin/Staff 표면 분리본. `partition.json`에 원본/분리 해시·경계·표면적 오차를 기록한다.
- `<Kind>-rigged.glb`:9뼈·10클립·Skin/Staff2메시를 가진 편집/가져오기 후보. Staff는 HandR 하위 뼈의 단일 소유다. 몸통·발 고정/양팔 스키닝이며 다리 리그 완성을 뜻하지 않는다.
- `bone-fixture.json`: 위 최종 GLB에서 별도 계산기가 읽은 rest/bind 행렬과90키자세. Roblox Bone 계약 시험 입력이며 스키닝된 Roblox 모델이 아니다.

제작: `python3 tools/prepare-regional-caster-meshes.py` → Blender MCP에서 `tools/author-regional-casters-blender.py` → `python3 tests/regional-caster-rigs.spec.py --output /tmp/mr01-results.json --native-fixture /tmp/mr01-bones.json`.

게임 연결 시 현재 `StoryMonsterSizing` 높이를 유지하고 원본 +Z 정면을 Roblox -Z 정면으로 변환한다. 원본 TD 런타임 템플릿의 변환을 새 GLB에 중복 적용하지 않는다. 기존 강체 Motor6D/5채널 곡선과 이 Bone 리그는 자동 호환되지 않는다. 정확한 Bone 어댑터·위상/취소·소켓/스트리밍·실제 가져오기 권한 검증이 필요하다. 현재 파일을 기존 자산ID에 덮어쓰지 않는다.
