# 기사 지정 영상3타 파생 모션

2026-11-14 · TLT-005/084. 참조는 사용자 지정 영상145~147초이며 [관찰·적용 범위](../../../docs/research/2026-11-14-knight-reference-combo.md)를 따른다.

원본은 기존 `mixamo-knight-v1/clips.json`의 소유 곡선과 승인된 TD 검/방패다. 외부 메시/애니메이션을 다운로드하지 않았다. `tools/solve-knight-thrust-native.luau`가 실제 R6/R15 소켓으로 계산한 자세를 `thrust-poses.json`에 보존한다. `tools/author-knight-reference-combo.py`가 내려베기·올려베기·찌르기의3개 런타임 모듈과 인덱스/해시 manifest를 생성한다. 원본 곡선·Blender 파일·기사 기술 변형은 변경하지 않는다.

신규 모션은 기존 곡선과 네이티브 전방운동학 기반 재저작이며, 새 Blender 독립 평가로 검증했다고 주장하지 않는다. [원천 해시](manifest.json), [후보/고정 빌드 검증·남은 수용](../../../docs/evidence/knight-reference-combo-20261114/README.md).
