# Deepwood 개별 동작 리뷰 근거

2026-11-02 · TLT-005/032/033/055/057/084. 기존 [v2 조사](2026-10-31-deepwood-monster-refinement-v2.md)를 재사용하며 공식 원천을 다시 열었다.

관찰: [Roblox Task Scheduler](https://create.roblox.com/docs/performance-optimization/microprofiler/task-scheduler)은 Motor6D.Transform의 PreSimulation 적용을 권장한다. [PlayStation 개발자 전투 분석](https://blog.playstation.com/2022/10/04/game-developers-explain-what-makes-god-of-war-2018s-combat-tick/)은 공격 예고의 구별과 무기 무게에 맞는 궤적/후속 동작을 설명한다. 이 자료가 본 게임의 실기기 성능이나 최종 미술 수용을 증명하지는 않는다.

적용: 서버 공격 시점과 피해를 유지하면서 종마다 준비·접촉·회수 각도를 리뷰했다. 작은 다리의 실제 이동량에 보폭을 맞추고, 거리로 평가한 걷기 곡선에 또 시간 보간을 적용해서 생긴 지연을 제거한다. 공격/스턴은 보행의 발 들기를 공유하지 않는다. source 무기가 몸통과 팔에 걸친 경우 단순 각도 수정으로 해결됐다고 보고하지 않고 별도 메시 후보/업로드/연결 검증으로 구분한다.

비용/실험: 기존 MeshPart/Motor6D와201표본 평가 구조를 유지하므로 별도 런타임 IK나 신규 프레임 연결을 추가하지 않는다. 평지6stud/s 지지 발 미끄러짐과30/60/144Hz의 접촉·루트·HP 불변을 검사한다. 실제 경사·클라이언트 지연·모바일·4인 성능과 사람의 미술 수용은 후속이다. [개별 관찰·결과·남은 일](../evidence/deepwood-individual-review-20261102/README.md).
