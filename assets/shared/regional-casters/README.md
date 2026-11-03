# MR-01 실제 Roblox 가져오기 자산

2026-11-03 사용자 승인으로3종을 Me 개인 Model로 새 업로드했다. [자산ID·원본 SHA·권한 확인](manifest.json) · [0.62.8 연결·검증·제약](../../../docs/evidence/regional-casters-runtime-20261103/README.md).

- `imported.rbxm`: 실제 Importer가 만든3종과 편집용10클립/종을 Roblox 엔진으로 직렬화한 원본. 게임 프로젝트에는 직접 참조하지 않는다.
- `runtime.rbxm`: 공유9뼈·Body/Staff 메시·Motor6D 연결을 유지하고 편집 메타데이터만 제거한 `RegionalCasterModels` 폴더. 두 Rojo 프로젝트의 ServerStorage에서 참조한다.
- source: `assets/animations/regional-casters-v2/*-rigged.glb`; 원본/후보v1·v2를 덮어쓰지 않았다.

재현은 승인된 GLB를 Custom/Keep Zero Influence Bones ON으로 가져와 `ServerStorage.RegionalCasterImported`에 보존한 뒤 `tools/prepare-regional-caster-runtime.luau`를 Edit에서 실행한다. SerializationService의 binary를 그대로 저장한다. `MR01PreparedExports.ClipsN` 문자열을 순서대로 합친 텍스트는 `tools/split-regional-caster-clips.py --source <export.luau>`로30개 모듈로 나눈다.200KB Source 제한 때문에 전체를 한 ModuleScript에 넣지 않는다.

가져온 rest/mesh의(-X,+Y,-Z) 변환과 raw Pose local의 차이는 제작 도구가 rest 기준으로 보정한다. 새 외형에 강체 템플릿의 추가180도 yaw를 다시 적용하지 않는다. 소켓도 glTF 원본 점을 같은 native 좌표계로 옮긴다. 원본 raw KeyframeSequence의 Pose를 런타임 Bone.Transform에 그대로 대입하지 않는다.

Place 미게시·공개 판매/배포 미실행. 기존 TD 모델과 운영 Place는 변경하지 않았다.
