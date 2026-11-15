# 기사 기본3타 파생 모션

2026-11-15 · TLT-005/084. [지정 영상 재관찰과 드워프 비교](../../../docs/research/2026-11-15-knight-wide-combo.md)에 따라 내려베기→올려베기→크게 가로베기의 몸통 준비/회전을 확대한다.

원본은 기존 `mixamo-knight-v1/clips.json` 소유 곡선과 승인된 TD 검/방패다. 외부 자산을 다운로드하지 않았다. `tools/solve-knight-sweep-native.luau`가 실제 R6/R15 소켓과 몸통 회전을 함께 계산한160도 수평 궤적의 자세를 `sweep-poses.json`에 보존한다. R6 몸통 관절의 축 차이를 별도 반영한다. `tools/author-knight-reference-combo.py`가 첫 두 타의 어깨/몸통 준비와 후속 회전을 추가하고 런타임3모듈·인덱스/해시 manifest를 생성한다. 접촉 주변의 보정은0으로 두어 기존1/2타의 타격 자세를 유지한다. 둘째 타는 셋째 타 준비로 연결하며, 가로베기 중 왼팔 방패를 낮춰 검과 겹치지 않게 한다. 기존 원본 곡선·Blender·기사 기술 변형은 유지한다.

네이티브 전방운동학 기반 재저작이며 새 Blender 평가 통과로 세지 않는다. [원천 해시](manifest.json), [검증·남은 수용](../../../docs/evidence/knight-wide-combo-20261115/README.md). 이전 찌르기의 solver/자세 JSON은 과거 검증 원천으로 보존하며 현재 런타임에는 사용하지 않는다.
