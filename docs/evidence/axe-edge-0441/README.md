# 0.44.1 드워프 도끼 칼날 정렬 수정

2026-10-31 · TLT-005/032/033/055/057/084 · ART/ENG 자체 검증. 사용자 지적: 도끼 날 대신 옆면으로 공격.

원인은0.44.0의 새 Embercleaver 메시 평면과 기존 손잡이 yaw/Blender 동작 축의 불일치였다. 이전 기본기 접촉에서 진행 방향과 넓은 면 법선의 내적 절댓값은 R6 .850/R15 .867로, 옆면이 진행 방향을 향했다. [이전 계측](before.log)·[후보 비교](candidate-angles.log).

Blender MCP 내부 API로 원본 기준 native yaw45도(직전 대비 -135도)를 제작하고 [회전/날/면 축](../../../assets/animations/axe-edge-v1/alignment.json)을 내보냈다. 파생 runtime.rbxmx의 도끼 배치와 끝 소켓을 함께 회전하고 CuttingEdge/Direction/FaceNormal 표식을 연결했다. MeshId/PBR·손 C0·공격 곡선·서버 피해/사거리/시간은 유지한다. 소스키 td:v2:Embercleaver:edge1로 실제 관찰자가 구형 외형을 교체한다. [Blender 원본/해시](../../../assets/animations/axe-edge-v1/manifest.json)·[검토 이미지](blender-edge.png).

네이티브 tests/axe-cutting-edge-native.luau는 R6/R15, 기본/내려찍기/지면 강타, 접촉 ±5ms와30/144Hz를 측정해150개를 통과했다. 실제 메시 두께 축과 표식 일치·손 소켓·서버 루트 불변을 포함한다. 날 방향/진행 방향 내적은 최소 .956, 옆면 성분 최대 .250였다. 최초 검사 오류는 월드 축과 로컬 표식 비교를 섞은 테스트 문제였고 손잡이 로컬 축으로 바로잡았다(native-edge-first.log/native-edge.log). 통과를 위해 날 임계값 .9/면 .35를 낮추지 않았다.

MCP safe mode는 초기 open() JSON 쓰기를 거부해 초기 결과를 남겼고, bpy 저장 연산자와 출력 JSON을 Node로 저장하는 방식으로 해결했다. 안전 모드는 유지한다. 실제 모델 제작/저장은 Blender 내부 API이며 별도 Python 스크립트는 사용하지 않았다.

기존 전체 동작29,549개 회귀와 실제 장착116개·고정 빌드/소스 대조·실제 Studio 확인은 최종 기록을 따른다. 자동 계측은 실기기·정상 네트워크·사용자 최종 미술 수용을 대신하지 않는다. 새로운 상점 아이템별 외형 모델링은 이번 결함 수정과 별도이며 TD/게시판은 변경하지 않는다. 다음 QA/DES는 실제 전투 시각과 각 기기를 수용한다.

고정 소스73f007177a16ee3091a97c0c925ef1c4c0a8c5bb에서 Lobby/Battle0.44.1 빌드를 성공했다([빌드/해시](build.json)). 최종 Battle 빌드의 날 정렬150개·실제 장착116개가 통과했다([최종 네이티브 로그](final-native.log)). 실제 Client에서의 시각 수용은 후속0.45.0 검토와 구분하며0.44.1을 게시하지 않았다.
