# Gloamwood 스킨/모션 적용 조사

2026-11-07 · TLT-065/032/033 · 조회 근거와 적용안을 구분한다. 새 전투 규칙/밸런스 승인 문서가 아니다.

- **Diablo IV / 2021-12 개발 업데이트:** [Blizzard 원문](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021)은 게임플레이 가독성과 동작·피격 반응 연결을 설명한다. 현행 패치에 대한 관찰이 아니며 직접 게임을 실행하지 않았다. 이번 적용은 큰 실루엣/예고 동작·서버 접촉 시각 유지·기존 방향 피격 반응 합성이다. 성인용 잔혹 표현이나 규칙은 채택하지 않는다.
- **Roblox / 현재 문서:** [Rigging](https://create.roblox.com/docs/art/modeling/rigging)과 [Bone.Transform](https://create.roblox.com/docs/reference/engine/classes/Bone/Transform)은 스킨 가중치가 메시 자산에 저장되고 본의 변환을 직접 제어할 수 있음을 설명한다. [일반 모델 사양](https://create.roblox.com/docs/art/modeling/specifications)의20k tris/정점 최대4본·Root 무가중치를 검사했다. 우리 모델은 종별1.8~2.1k tris·최대2본이다.
- **실제 도구 관찰:** Meshy8원본에는 리그가 없었다. Blender로 본/가중치/클립을 추가했고 Roblox Open Cloud 가져오기에서는 본·단일 색 텍스처는 유지됐지만 클립은 제외됐다. 따라서 독립 R6 서버 권한을 유지하고, 가져온 스킨에 GLB 로컬 델타를 클라이언트에서 샘플링하는 기존 프로젝트 방식을 적용했다. 지네 대형 모듈은 Source 크기 제한에 맞춰 분할했다.

대안인 강체 조각 분할은 각 다리/마디에 여러 MeshPart가 필요하고 절단 틈/자산 수가 늘어난다. 단일 메시 스킨은 원형 표면과 draw-call 수를 보존하므로 채택했다. 비용은 본/스킨 계산·클립 메모리이며, 종별 지연 로드와260stud 기존 표시 갱신 범위를 따른다. 이 비용의 실제 모바일/4인+AI 측정은 아직 없다.

최소 검증은 실제8종/여러 배율·동작 접촉 위상·중단·사망·Root/HP 보존·16개 자산 로드와 기존49종 공격/TD10종 모션 회귀다. [실제 결과와 남은 실전/기기 검사](../evidence/gloamwood-meshy-20261107/README.md)를 QA에 인계한다. 발 지면 IK·경사 접지와 사용자 최종 미술 수용은 후속이다.
