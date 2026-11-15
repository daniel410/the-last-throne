# 기사 기본3타 파생 모션

2026-11-14 · TLT-005/084. 첫 두 타는 [지정 영상 관찰](../../../docs/research/2026-11-14-knight-reference-combo.md), 세 번째 타는 최신 사용자 요청인 크게 가로베기를 따른다.

원본은 기존 `mixamo-knight-v1/clips.json` 소유 곡선과 승인된 TD 검/방패다. 외부 자산을 다운로드하지 않았다. `tools/solve-knight-sweep-native.luau`가 실제 R6/R15 소켓으로 계산한 130도 수평 궤적의 자세를 `sweep-poses.json`에 보존한다. `tools/author-knight-reference-combo.py`가 내려베기·올려베기·가로베기의 런타임 모듈과 인덱스/해시 manifest를 생성한다. 둘째 타는 셋째 타 준비로 연결하며, 가로베기 중 왼팔 방패를 낮춰 검과 겹치지 않게 한다. 기존 원본 곡선·Blender·기사 기술 변형은 유지한다.

네이티브 전방운동학 기반 재저작이며 새 Blender 평가 통과로 세지 않는다. [원천 해시](manifest.json), [검증·남은 수용](../../../docs/evidence/knight-horizontal-finisher-20261114/README.md). 이전 찌르기의 solver/자세 JSON은 과거 검증 원천으로 보존하며 현재 런타임에는 사용하지 않는다.
