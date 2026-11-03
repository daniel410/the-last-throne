# Frozen Vale · Ember Caldera 몬스터 20종 개별 리뷰

2026-11-03 · TLT-005/032/033/055/057/084 · ART/ENG/QA · 로컬 동작/리그 개선, 미게시.

[종별 수정 전후 갤러리](index.html) · [Frozen Vale 곡선](../../../assets/animations/frozen-vale-v2/manifest.json) · [Ember Caldera 곡선](../../../assets/animations/ember-caldera-v2/manifest.json) · [조사 근거](../../research/2026-11-03-regional-monster-motion.md).

| 종 | 개별 발견 | 적용한 변경 |
| --- | --- | --- |
| IceWolf | 공격 회수에 앞발이 크게 뒤집힘, 보행 리프트가 공격에 잔류 | 앞발 과회전을 없애고 몸통의 짧은 물기 예고/접촉, 대각 보행 |
| IceTroll | 곤봉 회수/몸통 회전이 크고 팔·다리가 같은 쪽으로 이동 | 작은 보폭·교차 팔, 준비72°/접촉-38°/회수-52° |
| IceBear | 앞발 회수55°로 발바닥이 정면으로 들림 | 짧은 앞발12°/17° 공격, 뒷발 지지·대각 보행 |
| IceGolem | 짧은 다리 대비 보폭0.5가 크고 몸을 비틂 | 다리 길이에 맞춘 보폭·지지60%, 내려치기 범위 축소 |
| IceElf | 지팡이·자유 손 과회전과 큰 보폭 | 작은 지팡이 시전·자유 손 고정·짧은 교차 보행 |
| IceTrollKing | 철퇴가 ArmL에 있는데 ArmR 빈손으로 주공격 | 무기 팔을 ArmL/Right Shoulder로 교정·반전 축·철퇴 끝 소켓, 실제 끝의 전방 이동 검사 |
| KingIceBear | 왕관/상체와 함께 큰 앞발 젖힘 | 큰 체형에 맞춘 짧은 보폭·앞발 공격17°, 지지 발 유지 |
| KingIceGolem | 장갑의 큰 회수·발 미끄러짐 | 준비57°/접촉-34°/회수-48°, 짧은 지지 보폭 |
| QueenIceElf | 지팡이와 드레스 조각이 팔 회전 때 갈라짐 | 두 팔을 몸통과 같은 축에 고정, 몸통 예고/시전 유지. 완전 팔 리깅은 후속 |
| AncientGlacierKing | 큰 몸체에 비해 제자리 기울기·회수가 과함 | 지지 보폭·몸통 회전 감소·무거운 준비60°/회수-49° |
| Imp | 날개 위쪽 경계가 어깨 축, 공격 때 날개/팔이 크게 벌어짐 | 어깨를±0.29/높이0.66으로 이동·작은 할퀴기28°/-20°/-28° |
| LavaSlime | 눌림/늘어남 때 부피가 바뀌고 많이 뜀 | 세로 변형65%·가로 역제곱근 부피 보존·리프트55% |
| Golem | 보폭과 몸통 비틀기가 과함 | 짧은 다리에 맞춘 보폭·교차 팔·내려치기53°/-31°/-44° |
| MagmaWorm | 일체형 바닥까지 공중으로 드는 널빤지 같은 돌진 | 리프트12%·기울기40%·짧은 전방 강타, 바닥 근처 유지 |
| VolcanoShaman | 지팡이 머리/밑자루·천의 다른 앵커 | 팔 고정·몸통 시전으로 접합 보존. 완전 팔 리깅은 후속 |
| MagmaImp | 날개 최고점이 팔 회전축, 크게 뒤집는 공격 | 실제 상완 쪽 축·짧은30°/-22°/-31° 공격·교차 보행 |
| MagmaGolem | 짧은 다리의 큰 보폭, 깊은 회수 | 지지60% 보폭·몸통 절제·56°/-33°/-47° |
| InfernoOverlord | 날개가 있는 팔을 크게 돌려 몸체를 가림 | 기존 해부학 축 유지·검 회수48°/-31°/-42°·교차 보행 |
| CalderaTitan | 큰 체형 전체의 흔들림과 다리 미끄러짐 | 짧은 지지 보폭·몸통 절제·무거운59°/-35°/-49° |
| KingVolcanoShaman | 지팡이/옷 조각이 떠다님 | 팔 고정·몸통 시전으로 접합 보존. 완전 팔 리깅은 후속 |

모든 종에 Idle/Walk/Attack/AttackAlt/Heavy/HeavyAlt/Stunned, 201표본의 Blender F-curve 평가 결과를 적용했다(20종·140클립·700채널). 기존 TD 원본 GLB/텍스처/Roblox 메시ID는 보존했다. 신규 메시 업로드·게임 게시를 수행하지 않았다. Deepwood 추가4종 메시 업로드 승인 대기는 별도 작업 그대로다.

## 검증과 재현

- `python3 tools/export-regional-motion-v2.py`: 표본·루프·유한값·지역 종 일치 검사, Luau/리그 메타데이터 생성.
- `python3 tests/frozen-vale-assets.spec.py` / `python3 tests/ember-caldera-assets.spec.py`: 기존 원본 및 v1 보관 자산 무결성 각71검사 통과.
- `python3 tools/assemble-regional-motion-suite.py --root <고정 소스> --output /tmp/regional-suite.luau`, `run-in-roblox --place <Battle.rbxlx> --script /tmp/regional-suite.luau`: 지역 리그·접지·공격/스턴·30/60/144Hz·소켓·Deepwood 회귀·스트리밍·전투 부트스트랩 검사. 빌드 고정 결과는 후속 `build.json`/`results.json`에 기록한다.
- `tools/capture-regional-monster-review.luau`: 기본 FrozenVale10종, `_G.TLTReviewRegion='EmberCaldera'`를 앞에 넣어 별도10종 캡처. 20종을 한 번에 출력하면1MiB 도구 제한을 넘으므로 분리한다.
- `tools/review-deepwood-model-blender.py`를 종별 원본 GLB·네이티브 캡처와 함께 실행. Blender 씬을 분리하고 원래 씬을 복원했다. 20종×7자세×전후=280원시 렌더, `assemble-regional-review.py`로20개 비교판 생성. 비교판은 네이티브 행렬의 Blender 재현이며 게시 클라이언트 관찰과 구분한다.

초기 검증 이력: 전체 옛 Frozen Vale 테스트는 동작 검사 뒤 스토리 저장 모의 객체가 `destination`의 새 의존 함수를 제공하지 못해 실패했다(`regression-first.log`). 이번 범위는 저장/스토리 변경이 없어 저장 모의 검사를 통과했다고 보고하지 않으며, 재현 도구는 명시적으로 기존 파일의 저장 주석 앞까지 동작 검사를 실행한다. Ember의 옛 검사는 주술사의 팔이 반드시 움직여야 한다고 가정해 실패했다(`native-final.log`). 의도한 팔 고정/접합 유지와 실제 몸통 시전 이동을 검사하도록 수정하고 재검사했다. 실패를 원본 무기 독립 리깅이 완료된 것으로 해석하지 않는다.

## 남은 수용 / 다음 담당

ART: 주술사3종의 독립 상완·팔꿈치·손목·지팡이 완전 소유 메시 재제작, 임프 팔과 날개의 독립 분리, 원본 강체 관절 절단면/캡의 최종 미술 개선. 이번 변경은 기존 분할 모델의 리그/곡선 개선이며20종 새 메시 전면 재제작이 아니다. IceElf 등 작은 움직임의 접합과 높은 공격각의 캡은 원본 한계가 남는다.

QA/디렉터: 경사 접지·실제 게시 클라이언트·모바일/게임패드·4인+AI 성능·사용자 눈으로 본 자연스러움 확인. 서버 타격/판정 범위·AI·HP·XP/Gold는 변경하지 않았다. 상위 티켓 전체 완료·출시 수용은 선언하지 않는다.
