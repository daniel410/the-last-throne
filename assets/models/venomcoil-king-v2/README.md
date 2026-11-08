# Venomcoil King · Meshy 최신 모델 v2

2026-11-07 · TLT-065/032/033/057/084. 사용자 요청으로 Meshy 작업공간의 최신 색상 모델 `Crimson Carapace Colo`를 GLB로 다운로드해 기존 King만 교체했다. [출처·SHA256·8종 채택표](manifest.json), [업로드 승인](uploaded.json), [Studio 가져오기](native-import.json), [리그](rig-report.json), [스킨·클립 검사](clip-validation.json).

원본은 `source/`, 표면/UV/텍스처를 보존한 14본 스킨과 10클립 슬롯은 `rigged/VenomcoilKing.glb`다. 2,458삼각형·3,218정점·원본 색 텍스처 바이트 동일·최대2본 가중치·Root 무가중치다. 작은 발은 몸통12구간 스킨을 따라 움직이며 독립 발 IK는 없다. 일부 대체/전환 슬롯은 같은 동작을 공유한다.

`runtime.rbxm`은 기존 Gloamwood 8종 중 King만 새 모델로 교체한 폴더다. 다른7종은 기존 복사본을 유지하며 기본/배틀 프로젝트 모두 이 파일을 사용한다. 구버전은 `../gloamwood-meshy-v1/`에 보존한다. 길이11.32stud를 유지하고 새 원형의 높이3.19208stud·폭3.90465stud를 따른다. 기존 R6 판정/이동/HP/피해/보상은 변경하지 않았다.

재현: Blender5.2의 별도 `TLT_VenomcoilKing_v2` 씬에 원본 GLB를 가져온 뒤 [제작 스크립트](../../../tools/author-venomcoil-king-v2.py)를 실행한다. 승인된 Roblox 가져오기에 [런타임 준비 스크립트](../../../tools/prepare-venomcoil-king-v2-runtime.luau)를 적용하고 `python3 tools/export-gloamwood-meshy-clips.py --base assets/models/venomcoil-king-v2`로 실제 본 rest 프레임/원본 표면을 검사한다. 10클립 중 Exposed에서만 미세 수치 정밀도 차이가 있어 기존 해당 모듈을 갱신했다.

Roblox 계정9156786071에 Model1건 `88842965200176`을 업로드했다. 파생 Mesh `138080691573925`, 색 Texture `93469012689254` 로드 Success를 확인했다. 별도 Animation 업로드는 없다. 런타임은 PackageLink 없는 로컬 복사본이며 가져오기 회색 틴트만 흰색으로 보정했다. 원본 업로드 패키지는 이 보정을 포함하지 않는다. [검증·화면·미게시·한계](../../../docs/evidence/venomcoil-king-20261107/README.md).

2026-11-07 꼬리 제보 후속(0.83.7): 원본/리그 전체2,458삼각형의 정점 좌표별 면 집합과 꼬리704정점/경계를 대조해 동일함을 확인했다. 원본 `doubleSided=true`를 가져오기에서 잃은 점을 복구하고 King만 `RenderFidelity.Precise`로 고정해 얇은 꼬리의 자동 단순화를 방지한다. 실제 잘림 원인은 재현되지 않았으며 이 설정 누락이 제보 원인이라고 단정하지 않는다. [전체 꼬리 화면·검증](../../../docs/evidence/venomcoil-tail-20261107/README.md).
