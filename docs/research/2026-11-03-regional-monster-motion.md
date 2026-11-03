# Frozen Vale · Ember Caldera 개별 동작 개선 근거

2026-11-03 · TLT-005/032/033/055/057/084 · ART/ENG/QA.

[Deepwood 개별 리뷰 조사](2026-11-02-deepwood-individual-motion.md)를 재사용하고 두 공식 원천을 다시 확인했다. [Roblox Task Scheduler](https://create.roblox.com/docs/performance-optimization/microprofiler/task-scheduler)는 Motor6D.Transform을 PreSimulation에서 적용하도록 설명한다. [PlayStation 개발자 전투 분석](https://blog.playstation.com/2022/10/04/game-developers-explain-what-makes-god-of-war-2018s-combat-tick/)에서는 전투 예고의 구별과 무게에 맞는 궤적·회수를 설명한다. 이것은 본 게임의 미술 수용·기기 성능 증거가 아니다.

관찰/적용: 20종의 기존 TD 메시를 실제 Roblox 리그 행렬로 변환해 Blender에서 종별 보행·준비·접촉·회수를 비교했다. 인간형의 같은 쪽 팔/다리 동행, 네발 공격에 이전 보행 발 들기 잔류, 임프 날개 끝을 어깨로 삼은 축, Ice Troll King의 빈손 공격, 과한 웜/슬라임 변형을 각각 수정했다. 서버 접촉 위상0.62·AI·피해·루트·보상은 보존한다. 새 프레임 이벤트나 런타임 IK를 추가하지 않는다.

메시 한계: 주술사3종의 지팡이/천은 원본에서 Body·ArmR·ArmL로 나뉜다. 팔을 같은 몸통 축에 두어 접합을 유지하며 몸통 예고/시전은 남긴다. 새 완전 팔·손목 리그를 구현했다고 보고하지 않는다. 임프 날개도 팔 메시의 일부다. 종별 발견과 다음 담당자는 [리뷰 기록](../evidence/regional-monster-review-20261103/README.md)을 따른다.

최소 수용 실험: 평지6stud/s 지지 발 미끄러짐, 대각 네발 위상·회수 발 들기, 공격/스턴/노출 시 접지, 4공격×30/60/144Hz 접촉, 무기 실제 끝의 전방 이동, 루트/HP 불변을 엔진에서 검사한다. 경사·게시 클라이언트·지연·모바일·4인+AI 성능과 사용자 미술 수용은 후속이다.
